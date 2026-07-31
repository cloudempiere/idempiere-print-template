-- ============================================================================
-- SEED DO PACK OUT — Print Template Engine 2Pack 1.0.0 (VERSÃO ÚNICA,
-- inclui Fase 3 — decisão 15/07: sem bump enquanto nada foi distribuído)
-- Spec: riskora/docs/SPEC_IDEMPIERE_PRINT_TEMPLATE_ENGINE.md §12 (v0.3)
--
-- Cria o registro AD_Package_Exp "org.idempiere.print.freemarker" com os
-- details na ordem de import. O Export é disparado pela janela Pack Out
-- (login System Administrator / client System); o zip sai em
-- {java.io.tmpdir}/packout<AD_User_ID>/ (ex.: /tmp/packout100/).
--
-- Os 6 details SQL são statements ÚNICOS (o SQLStatementElementHandler
-- executa cada um inteiro, sem split) e idempotentes — cobrem a parte que
-- toca o AD_PrintFormat (sem detail type "Column" no Pack Out) e os
-- appends de DisplayLogic (portáveis: preservam gates pré-existentes).
-- ============================================================================

\set ON_ERROR_STOP on

BEGIN;

DO $BODY$
DECLARE
    seq_exp    integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Package_Exp');
    seq_det    integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Package_Exp_Detail');
    v_exp      integer;
    v_et       integer := (SELECT AD_EntityType_ID FROM AD_EntityType WHERE EntityType='PRT');
    v_ref      integer := (SELECT AD_Reference_ID FROM AD_Reference WHERE Name='PRT_TemplateEngineType' AND EntityType='PRT');
    v_tbl_tpl  integer := (SELECT AD_Table_ID FROM AD_Table WHERE TableName='AD_PrintTemplate');
    v_tbl_inc  integer := (SELECT AD_Table_ID FROM AD_Table WHERE TableName='AD_PrintTemplate_Include');
    v_win      integer := (SELECT AD_Window_ID FROM AD_Window WHERE Name='Print Template' AND EntityType='PRT');
    v_proc     integer := (SELECT AD_Process_ID FROM AD_Process WHERE Value='PrintTemplate_ReportStarter');
    v_menu     integer := (SELECT AD_Menu_ID FROM AD_Menu WHERE Name='Print Template' AND EntityType='PRT');
    v_procval  integer := (SELECT AD_Process_ID FROM AD_Process WHERE Value='PrintTemplate_Validate');
    v_msg1     integer := (SELECT AD_Message_ID FROM AD_Message WHERE Value='ExportJSON');
    v_msg2     integer := (SELECT AD_Message_ID FROM AD_Message WHERE Value='ExportRecordAsJSON');
    v_sql      varchar;
BEGIN
    IF v_et IS NULL OR v_ref IS NULL OR v_tbl_tpl IS NULL OR v_tbl_inc IS NULL
       OR v_win IS NULL OR v_proc IS NULL OR v_menu IS NULL THEN
        RAISE EXCEPTION 'Artefato PRT ausente (et=% ref=% tpl=% inc=% win=% proc=% menu=%) — rodar authoring-dictionary.sql antes',
            v_et, v_ref, v_tbl_tpl, v_tbl_inc, v_win, v_proc, v_menu;
    END IF;
    IF EXISTS (SELECT 1 FROM AD_Package_Exp WHERE Name='org.idempiere.print.freemarker' AND PK_Version='1.0.0') THEN
        RAISE EXCEPTION 'Pack Out org.idempiere.print.freemarker 1.0.0 já semeado';
    END IF;

    v_exp := nextidfunc(seq_exp, 'N');
    INSERT INTO AD_Package_Exp (AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
        Updated, UpdatedBy, Name, PK_Version, Version, Description, Instructions, UserName,
        Processing, Processed, AD_Package_Exp_UU)
    VALUES (v_exp, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'org.idempiere.print.freemarker', '1.0.0', '12',
        'Print Template Engine — dicionário (EntityType PRT): AD_PrintTemplate(+Include), Ref List TemplateEngineType, janela, menu, processo ponte, coluna+DisplayLogic no AD_PrintFormat via SQL',
        'Instalado automaticamente pelo Incremental2PackActivator do bundle org.idempiere.print.freemarker (META-INF/2Pack_1.0.0.zip)',
        'Murilo Habermann Torquato', 'N', 'N', generate_uuid());

    -- Ordem de import = Line
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description,
        AD_EntityType_ID, AD_Reference_ID, AD_Table_ID, AD_Window_ID, AD_Process_ID, AD_Menu_ID,
        AD_Package_Exp_Detail_UU)
    VALUES
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 10,  'ET',
         'EntityType PRT', v_et, NULL, NULL, NULL, NULL, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 20,  'REF',
         'Ref List PRT_TemplateEngineType (FM/VL/TH/MS/HB)', NULL, v_ref, NULL, NULL, NULL, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 25,  'P',
         'Processo PrintTemplate_Validate (Fase 3 — ANTES da tabela: coluna Button FK nele)', NULL, NULL, NULL, NULL, v_procval, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 30,  'T',
         'Tabela AD_PrintTemplate (+ colunas + elements + DDL)', NULL, NULL, v_tbl_tpl, NULL, NULL, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 40,  'T',
         'Tabela AD_PrintTemplate_Include (+ colunas + elements + DDL)', NULL, NULL, v_tbl_inc, NULL, NULL, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 50,  'W',
         'Janela Print Template (tabs Template + Include)', NULL, NULL, NULL, v_win, NULL, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 60,  'P',
         'Processo ponte PrintTemplate_ReportStarter (JasperReport = marcador)', NULL, NULL, NULL, NULL, v_proc, NULL, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 70,  'M',
         'Menu Print Template', NULL, NULL, NULL, NULL, NULL, v_menu, generate_uuid());

    -- Fase 3: mensagens do Export JSON (AD_Package_Exp_Detail tem coluna própria AD_Message_ID)
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, AD_Message_ID, AD_Package_Exp_Detail_UU)
    VALUES
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 72, 'MSG',
         'AD_Message ExportJSON (Fase 3)', v_msg1, generate_uuid()),
        (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 74, 'MSG',
         'AD_Message ExportRecordAsJSON (Fase 3)', v_msg2, generate_uuid());

    -- SQL 80: coluna física no AD_PrintFormat
    v_sql := $S$ALTER TABLE AD_PrintFormat ADD COLUMN IF NOT EXISTS AD_PrintTemplate_ID NUMERIC(10) DEFAULT NULL$S$;
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, SQLStatement, DBType, AD_Package_Exp_Detail_UU)
    VALUES (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 80, 'SQL',
        'DDL: coluna AD_PrintFormat.AD_PrintTemplate_ID', v_sql, 'Postgres', generate_uuid());

    -- SQL 90: AD_Column no dicionário (element já existe — criado pelo import da tabela na Line 30)
    v_sql := $S$INSERT INTO AD_Column (AD_Column_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy, Name, ColumnName, AD_Table_ID, AD_Reference_ID, FieldLength, IsKey, IsParent, IsMandatory, IsTranslated, IsIdentifier, SeqNo, IsEncrypted, IsSelectionColumn, IsUpdateable, IsAlwaysUpdateable, Version, EntityType, AD_Column_UU, Description, AD_Element_ID) SELECT nextidfunc((SELECT AD_Sequence_ID::integer FROM AD_Sequence WHERE Name='AD_Column'),'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100, 'Print Template', 'AD_PrintTemplate_ID', 493, 19, 22, 'N', 'N', 'N', 'N', 'N', 0, 'N', 'N', 'Y', 'N', 0, 'PRT', generate_uuid(), 'Renderiza este formato via template declarativo (a ponte JasperProcess_ID é setada automaticamente)', (SELECT AD_Element_ID FROM AD_Element WHERE UPPER(ColumnName)='AD_PRINTTEMPLATE_ID' ORDER BY AD_Element_ID LIMIT 1) WHERE NOT EXISTS (SELECT 1 FROM AD_Column WHERE AD_Table_ID=493 AND UPPER(ColumnName)='AD_PRINTTEMPLATE_ID')$S$;
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, SQLStatement, DBType, AD_Package_Exp_Detail_UU)
    VALUES (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 90, 'SQL',
        'Dicionário: AD_Column AD_PrintTemplate_ID no AD_PrintFormat (guardado por NOT EXISTS)', v_sql, 'Postgres', generate_uuid());

    -- SQL 100: AD_Field na janela 240 / tab 425 (IDs oficiais do core — estáveis)
    v_sql := $S$INSERT INTO AD_Field (AD_Field_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy, Name, Description, AD_Tab_ID, AD_Column_ID, IsDisplayed, DisplayLength, SeqNo, IsSameLine, IsHeading, IsFieldOnly, IsReadOnly, IsEncrypted, EntityType, AD_Field_UU) SELECT nextidfunc((SELECT AD_Sequence_ID::integer FROM AD_Sequence WHERE Name='AD_Field'),'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100, 'Print Template', 'Renderiza via template declarativo em vez do layout', 425, (SELECT AD_Column_ID FROM AD_Column WHERE AD_Table_ID=493 AND UPPER(ColumnName)='AD_PRINTTEMPLATE_ID'), 'Y', 22, 260, 'N', 'N', 'N', 'N', 'N', 'PRT', generate_uuid() WHERE NOT EXISTS (SELECT 1 FROM AD_Field f JOIN AD_Column c ON c.AD_Column_ID=f.AD_Column_ID WHERE f.AD_Tab_ID=425 AND UPPER(c.ColumnName)='AD_PRINTTEMPLATE_ID')$S$;
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, SQLStatement, DBType, AD_Package_Exp_Detail_UU)
    VALUES (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 100, 'SQL',
        'Dicionário: AD_Field Print Template na tab 425 (janela 240)', v_sql, 'Postgres', generate_uuid());

    -- SQL 110: Trl do field novo (idiomas de sistema do destino)
    v_sql := $S$INSERT INTO AD_Field_Trl (AD_Field_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Field_Trl_UU) SELECT f.AD_Field_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100, f.Name, f.Description, f.Help, 'N', generate_uuid() FROM AD_Field f JOIN AD_Column c ON c.AD_Column_ID=f.AD_Column_ID CROSS JOIN AD_Language l WHERE f.AD_Tab_ID=425 AND UPPER(c.ColumnName)='AD_PRINTTEMPLATE_ID' AND l.IsSystemLanguage='Y' AND NOT EXISTS (SELECT 1 FROM AD_Field_Trl t WHERE t.AD_Field_ID=f.AD_Field_ID AND t.AD_Language=l.AD_Language)$S$;
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, SQLStatement, DBType, AD_Package_Exp_Detail_UU)
    VALUES (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 110, 'SQL',
        'Trl do field novo (backfill nos idiomas de sistema)', v_sql, 'Postgres', generate_uuid());

    -- SQL 120: DisplayLogic dos fields da tab 425 — APPEND (preserva gates pré-existentes)
    v_sql := $S$UPDATE AD_Field f SET DisplayLogic = COALESCE(f.DisplayLogic || ' & ', '') || '@AD_PrintTemplate_ID@=0', Updated=NOW(), UpdatedBy=100 FROM AD_Column c WHERE c.AD_Column_ID=f.AD_Column_ID AND f.AD_Tab_ID=425 AND c.ColumnName IN ('HeaderMargin','FooterMargin','IsStandardHeaderFooter','AD_PrintColor_ID','AD_PrintFont_ID','AD_PrintPaper_ID','IsTableBased','IsBreakPagePerRecord','JasperProcess_ID') AND (f.DisplayLogic IS NULL OR f.DisplayLogic NOT LIKE '%AD_PrintTemplate_ID%')$S$;
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, SQLStatement, DBType, AD_Package_Exp_Detail_UU)
    VALUES (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 120, 'SQL',
        'DisplayLogic append nos fields da tab 425 (oculta config irrelevante quando template setado)', v_sql, 'Postgres', generate_uuid());

    -- SQL 130: DisplayLogic das tabs de AD_PrintFormatItem — APPEND
    v_sql := $S$UPDATE AD_Tab SET DisplayLogic = COALESCE(DisplayLogic || ' & ', '') || '@AD_PrintTemplate_ID@=0', Updated=NOW(), UpdatedBy=100 WHERE AD_Window_ID=240 AND AD_Table_ID=489 AND (DisplayLogic IS NULL OR DisplayLogic NOT LIKE '%AD_PrintTemplate_ID%')$S$;
    INSERT INTO AD_Package_Exp_Detail (AD_Package_Exp_Detail_ID, AD_Package_Exp_ID, AD_Client_ID, AD_Org_ID,
        IsActive, Processing, Created, CreatedBy, Updated, UpdatedBy, Line, Type, Description, SQLStatement, DBType, AD_Package_Exp_Detail_UU)
    VALUES (nextidfunc(seq_det,'N'), v_exp, 0, 0, 'Y', 'N', NOW(), 100, NOW(), 100, 130, 'SQL',
        'DisplayLogic append nas tabs de Format Item (some quando template setado)', v_sql, 'Postgres', generate_uuid());

    RAISE NOTICE 'Pack Out semeado: AD_Package_Exp_ID=% (13 details)', v_exp;
END
$BODY$;

COMMIT;
