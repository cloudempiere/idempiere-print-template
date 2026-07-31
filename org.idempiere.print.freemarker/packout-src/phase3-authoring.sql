-- ============================================================================
-- AUTORIA FASE 3 — Validar/Prever + Export JSON (delta pro 2Pack 1.0.1)
-- Spec: riskora/docs/SPEC_IDEMPIERE_PRINT_TEMPLATE_ENGINE.md §13 Fase 3
--
-- Delta sobre o dicionário 1.0.0:
--   1. AD_Process PrintTemplate_Validate (classname TemplateValidateProcess)
--   2. AD_PrintTemplate.Processing (Button 28 → processo acima) + DDL + field
--   3. AD_Message ExportJSON / ExportRecordAsJSON (usadas pelo patch de fork
--      do WRecordInfo)
--   4. Trl backfill dos novos artefatos
-- Pack Out 1.0.1 (seed-packout-101.sql): P → T → W → MSG×2
-- ============================================================================

\set ON_ERROR_STOP on

BEGIN;

ALTER TABLE AD_PrintTemplate ADD COLUMN IF NOT EXISTS Processing CHAR(1) DEFAULT NULL;

DO $BODY$
DECLARE
    seq_process integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Process');
    seq_column  integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Column');
    seq_field   integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Field');
    seq_message integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Message');
    v_tbl_tpl   integer := (SELECT AD_Table_ID FROM AD_Table WHERE TableName='AD_PrintTemplate');
    v_tab_tpl   integer := (SELECT AD_Tab_ID FROM AD_Tab WHERE AD_Table_ID=(SELECT AD_Table_ID FROM AD_Table WHERE TableName='AD_PrintTemplate') AND EntityType='PRT');
    v_el_proc   integer := (SELECT AD_Element_ID FROM AD_Element WHERE UPPER(ColumnName)='PROCESSING' ORDER BY AD_Element_ID LIMIT 1);
    v_proc      integer;
    v_col       integer;
BEGIN
    IF EXISTS (SELECT 1 FROM AD_Process WHERE Value='PrintTemplate_Validate') THEN
        RAISE EXCEPTION 'Fase 3 já autorada neste banco';
    END IF;

    -- 1. Processo Validar/Prever
    v_proc := nextidfunc(seq_process,'N');
    INSERT INTO AD_Process (AD_Process_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Value, Name, Description, AccessLevel, EntityType, Classname, IsReport, IsDirectPrint,
        ShowHelp, IsBetaFunctionality, Statistic_Count, Statistic_Seconds, AD_Process_UU)
    VALUES (v_proc, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'PrintTemplate_Validate', 'Validate Print Template',
        'Valida a sintaxe do template e gera prévia com um registro de amostra',
        '7', 'PRT', 'org.idempiere.print.template.TemplateValidateProcess', 'N', 'N',
        'Y', 'N', 0, 0, generate_uuid());

    -- 2. Coluna Processing (Button → processo) + field
    v_col := nextidfunc(seq_column,'N');
    INSERT INTO AD_Column (AD_Column_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, ColumnName, AD_Table_ID, AD_Reference_ID, FieldLength, AD_Process_ID,
        IsKey, IsParent, IsMandatory, IsTranslated, IsIdentifier, SeqNo, IsEncrypted,
        IsSelectionColumn, IsUpdateable, IsAlwaysUpdateable, Version, EntityType, AD_Column_UU,
        Description, AD_Element_ID)
    VALUES (v_col, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'Process Now', 'Processing', v_tbl_tpl, 28, 1, v_proc,
        'N', 'N', 'N', 'N', 'N', 0, 'N',
        'N', 'Y', 'Y', 0, 'PRT', generate_uuid(),
        'Validar sintaxe e gerar prévia do template', v_el_proc);

    INSERT INTO AD_Field (AD_Field_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, AD_Tab_ID, AD_Column_ID, IsDisplayed, DisplayLength, SeqNo,
        IsSameLine, IsHeading, IsFieldOnly, IsReadOnly, IsEncrypted, EntityType, AD_Field_UU)
    VALUES (nextidfunc(seq_field,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'Validate / Preview', 'Valida sintaxe e gera prévia com registro de amostra',
        v_tab_tpl, v_col, 'Y', 23, 150, 'N', 'N', 'N', 'N', 'N', 'PRT', generate_uuid());

    -- 3. Mensagens do Export JSON (patch WRecordInfo)
    INSERT INTO AD_Message (AD_Message_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Value, MsgText, MsgTip, MsgType, EntityType, AD_Message_UU)
    VALUES
        (nextidfunc(seq_message,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100,
         'ExportJSON', 'Export JSON', NULL, 'I', 'PRT', generate_uuid()),
        (nextidfunc(seq_message,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100,
         'ExportRecordAsJSON',
         'Export the current record and its children as JSON — useful to feed an AI prompt when authoring a print template',
         NULL, 'I', 'PRT', generate_uuid());

    RAISE NOTICE 'Fase 3: process %, column %, tab %', v_proc, v_col, v_tab_tpl;
END
$BODY$;

-- 4. Trl backfill (idempotente — mesmos padrões da autoria 1.0.0)
INSERT INTO AD_Process_Trl (AD_Process_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Process_Trl_UU)
SELECT p.AD_Process_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       p.Name, p.Description, p.Help, 'N', generate_uuid()
FROM AD_Process p CROSS JOIN AD_Language l
WHERE p.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Process_Trl t WHERE t.AD_Process_ID=p.AD_Process_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Field_Trl (AD_Field_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Field_Trl_UU)
SELECT f.AD_Field_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       f.Name, f.Description, f.Help, 'N', generate_uuid()
FROM AD_Field f CROSS JOIN AD_Language l
WHERE f.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Field_Trl t WHERE t.AD_Field_ID=f.AD_Field_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Message_Trl (AD_Message_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, MsgText, MsgTip, IsTranslated, AD_Message_Trl_UU)
SELECT m.AD_Message_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       m.MsgText, m.MsgTip, 'N', generate_uuid()
FROM AD_Message m CROSS JOIN AD_Language l
WHERE m.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Message_Trl t WHERE t.AD_Message_ID=m.AD_Message_ID AND t.AD_Language=l.AD_Language);

-- Trl pt_BR dos rótulos novos
UPDATE AD_Message_Trl SET MsgText='Exportar JSON', IsTranslated='Y', Updated=NOW()
 WHERE AD_Language='pt_BR' AND AD_Message_ID=(SELECT AD_Message_ID FROM AD_Message WHERE Value='ExportJSON');
UPDATE AD_Message_Trl SET MsgText='Exporta o registro atual e seus filhos como JSON — útil pra alimentar um prompt de IA ao criar um template de impressão', IsTranslated='Y', Updated=NOW()
 WHERE AD_Language='pt_BR' AND AD_Message_ID=(SELECT AD_Message_ID FROM AD_Message WHERE Value='ExportRecordAsJSON');
UPDATE AD_Field_Trl SET Name='Validar / Prévia', IsTranslated='Y', Updated=NOW()
 WHERE AD_Language='pt_BR' AND AD_Field_ID=(SELECT AD_Field_ID FROM AD_Field WHERE EntityType='PRT' AND Name='Validate / Preview');
UPDATE AD_Process_Trl SET Name='Validar Print Template', IsTranslated='Y', Updated=NOW()
 WHERE AD_Language='pt_BR' AND AD_Process_ID=(SELECT AD_Process_ID FROM AD_Process WHERE Value='PrintTemplate_Validate');

COMMIT;
