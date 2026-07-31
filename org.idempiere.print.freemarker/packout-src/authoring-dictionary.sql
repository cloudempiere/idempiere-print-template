-- ============================================================================
-- AUTORIA DO DICIONÁRIO — Print Template Engine (Fase 1)
-- Spec: riskora/docs/SPEC_IDEMPIERE_PRINT_TEMPLATE_ENGINE.md §6/§12 (v0.3)
--
-- Este script é de AUTORIA LOCAL (dev DB): monta o dicionário sob EntityType
-- PRT para depois exportar via Pack Out → META-INF/2Pack_1.0.0.zip.
-- NÃO é migration de produção e NÃO acompanha o bundle — o 2Pack acompanha.
--
-- IDs: alocados via nextidfunc (locais, descartáveis). Os UUIDs gerados aqui
-- viram a identidade canônica do pacote após o Pack Out (spec §6.6).
--
-- Os UPDATEs de DisplayLogic na janela 240 são APPEND-style (preservam o
-- gate @COF_isTemplateDOCX@ do fork) — replicar como SQLStatement no 2Pack.
-- ============================================================================

\set ON_ERROR_STOP on

BEGIN;

-- ----------------------------------------------------------------------------
-- 0. DDL físico
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AD_PrintTemplate (
    AD_PrintTemplate_ID   NUMERIC(10)   NOT NULL,
    AD_PrintTemplate_UU   VARCHAR(36)   DEFAULT NULL,
    AD_Client_ID          NUMERIC(10)   NOT NULL,
    AD_Org_ID             NUMERIC(10)   NOT NULL,
    IsActive              CHAR(1)       DEFAULT 'Y' NOT NULL CHECK (IsActive IN ('Y','N')),
    Created               TIMESTAMP     DEFAULT statement_timestamp() NOT NULL,
    CreatedBy             NUMERIC(10)   NOT NULL,
    Updated               TIMESTAMP     DEFAULT statement_timestamp() NOT NULL,
    UpdatedBy             NUMERIC(10)   NOT NULL,
    Name                  VARCHAR(120)  NOT NULL,
    Description           VARCHAR(255)  DEFAULT NULL,
    Help                  VARCHAR(2000) DEFAULT NULL,
    TemplateEngineType    CHAR(2)       DEFAULT 'FM' NOT NULL,
    TemplateBody          TEXT          NOT NULL,
    OutputContentType     VARCHAR(60)   DEFAULT 'text/html' NOT NULL,
    OutputFileExtension   VARCHAR(10)   DEFAULT 'html' NOT NULL,
    TemplateEncoding      VARCHAR(20)   DEFAULT 'UTF-8' NOT NULL,
    IsBinaryOutput        CHAR(1)       DEFAULT 'N' NOT NULL CHECK (IsBinaryOutput IN ('Y','N')),
    AD_Table_ID           NUMERIC(10)   DEFAULT NULL,
    CONSTRAINT AD_PrintTemplate_pkey PRIMARY KEY (AD_PrintTemplate_ID),
    CONSTRAINT AD_PrintTemplate_UU_uq UNIQUE (AD_PrintTemplate_UU),
    CONSTRAINT AD_PrintTemplate_Name_uq UNIQUE (AD_Client_ID, AD_Org_ID, Name)
);

CREATE TABLE IF NOT EXISTS AD_PrintTemplate_Include (
    AD_PrintTemplate_Include_ID NUMERIC(10)   NOT NULL,
    AD_PrintTemplate_Include_UU VARCHAR(36)   DEFAULT NULL,
    AD_PrintTemplate_ID         NUMERIC(10)   NOT NULL,
    AD_Client_ID                NUMERIC(10)   NOT NULL,
    AD_Org_ID                   NUMERIC(10)   NOT NULL,
    IsActive                    CHAR(1)       DEFAULT 'Y' NOT NULL CHECK (IsActive IN ('Y','N')),
    Created                     TIMESTAMP     DEFAULT statement_timestamp() NOT NULL,
    CreatedBy                   NUMERIC(10)   NOT NULL,
    Updated                     TIMESTAMP     DEFAULT statement_timestamp() NOT NULL,
    UpdatedBy                   NUMERIC(10)   NOT NULL,
    AD_Table_ID                 NUMERIC(10)   NOT NULL,
    TargetName                  VARCHAR(60)   NOT NULL,
    WhereClause                 VARCHAR(2000) DEFAULT NULL,
    OrderByClause               VARCHAR(255)  DEFAULT NULL,
    SeqNo                       NUMERIC(10)   DEFAULT 10 NOT NULL,
    IncludeNested               CHAR(1)       DEFAULT 'N' NOT NULL CHECK (IncludeNested IN ('Y','N')),
    MaxRows                     NUMERIC(10)   DEFAULT NULL,
    CONSTRAINT AD_PrintTemplate_Include_pkey PRIMARY KEY (AD_PrintTemplate_Include_ID),
    CONSTRAINT AD_PrintTemplate_Include_UU_uq UNIQUE (AD_PrintTemplate_Include_UU),
    CONSTRAINT AD_PrintTemplate_Include_Target_uq UNIQUE (AD_PrintTemplate_ID, TargetName),
    CONSTRAINT ADPrintTemplate_ADPrintTemplateInclude FOREIGN KEY (AD_PrintTemplate_ID)
        REFERENCES AD_PrintTemplate(AD_PrintTemplate_ID)
);

ALTER TABLE AD_PrintFormat ADD COLUMN IF NOT EXISTS AD_PrintTemplate_ID NUMERIC(10) DEFAULT NULL;

-- ----------------------------------------------------------------------------
-- Helper de coluna (pg_temp — some no fim da sessão)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pg_temp.prt_addcol(
    p_table_id    integer,
    p_name        varchar,
    p_colname     varchar,
    p_ref         integer,
    p_refval      integer,
    p_len         integer,
    p_iskey       char,
    p_isparent    char,
    p_ismand      char,
    p_ident_seq   integer,      -- 0 = não identifier
    p_updateable  char,
    p_default     varchar,
    p_desc        varchar
) RETURNS integer AS $FN$
DECLARE
    v_id  integer;
    v_el  integer;
BEGIN
    SELECT AD_Element_ID INTO v_el FROM AD_Element
     WHERE UPPER(ColumnName)=UPPER(p_colname) ORDER BY AD_Element_ID LIMIT 1;
    IF v_el IS NULL THEN
        RAISE EXCEPTION 'AD_Element ausente pra ColumnName=%', p_colname;
    END IF;
    v_id := nextidfunc((SELECT AD_Sequence_ID::integer FROM AD_Sequence WHERE Name='AD_Column'), 'N');
    INSERT INTO AD_Column (
        AD_Column_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, ColumnName, AD_Table_ID, AD_Reference_ID, AD_Reference_Value_ID, FieldLength,
        IsKey, IsParent, IsMandatory, IsTranslated, IsIdentifier, SeqNo, IsEncrypted,
        IsSelectionColumn, IsUpdateable, IsAlwaysUpdateable, Version, EntityType, AD_Column_UU,
        Description, DefaultValue, AD_Element_ID
    ) VALUES (
        v_id, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        p_name, p_colname, p_table_id, p_ref, p_refval, p_len,
        p_iskey, p_isparent, p_ismand, 'N', CASE WHEN p_ident_seq > 0 THEN 'Y' ELSE 'N' END,
        COALESCE(NULLIF(p_ident_seq,0),0), 'N',
        'N', p_updateable, 'N', 0, 'PRT', generate_uuid(),
        p_desc, p_default, v_el
    );
    RETURN v_id;
END;
$FN$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 1. Dicionário
-- ----------------------------------------------------------------------------
DO $BODY$
DECLARE
    seq_entitytype integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_EntityType');
    seq_element    integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Element');
    seq_reference  integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Reference');
    seq_reflist    integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Ref_List');
    seq_table      integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Table');
    seq_sequence   integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Sequence');
    seq_window     integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Window');
    seq_tab        integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Tab');
    seq_field      integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Field');
    seq_menu       integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Menu');
    seq_process    integer := (SELECT AD_Sequence_ID FROM AD_Sequence WHERE Name='AD_Process');

    v_ref_engine   integer;
    v_tbl_tpl      integer;
    v_tbl_inc      integer;
    v_win          integer;
    v_tab_tpl      integer;
    v_tab_inc      integer;
    v_menu         integer;
    v_proc         integer;
    v_pf_col       integer;
    v_pf_field     integer;
    v_parent_menu  integer;
    v_el           integer;
    n              integer;
BEGIN
    IF EXISTS (SELECT 1 FROM AD_EntityType WHERE EntityType='PRT') THEN
        RAISE EXCEPTION 'EntityType PRT já existe — autoria já aplicada neste banco';
    END IF;

    -- 1.1 EntityType
    INSERT INTO AD_EntityType (AD_EntityType_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
        Updated, UpdatedBy, EntityType, Name, Description, AD_EntityType_UU)
    VALUES (nextidfunc(seq_entitytype,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'PRT', 'Print Template Engine', 'iDempiere Print Template Engine plugin (org.idempiere.print.freemarker)',
        generate_uuid());

    -- 1.2 Elements novos (11)
    INSERT INTO AD_Element (AD_Element_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
        Updated, UpdatedBy, ColumnName, Name, PrintName, EntityType, AD_Element_UU, Description)
    SELECT nextidfunc(seq_element,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100,
           els.cname, els.nm, els.pn, 'PRT', generate_uuid(), els.ds
    FROM (VALUES
        ('AD_PrintTemplate_ID',         'Print Template',         'Print Template',   'Template declarativo usado pra renderizar o registro (substitui o layout do print format)'),
        ('AD_PrintTemplate_UU',         'AD_PrintTemplate_UU',    'AD_PrintTemplate_UU', NULL),
        ('AD_PrintTemplate_Include_ID', 'Print Template Include', 'Include',          'Tabela filha incluída no data model do template'),
        ('AD_PrintTemplate_Include_UU', 'AD_PrintTemplate_Include_UU', 'AD_PrintTemplate_Include_UU', NULL),
        ('TemplateEngineType',          'Template Engine Type',   'Engine',           'Engine que processa o template (FreeMarker, Velocity, ...)'),
        ('TemplateBody',                'Template Body',          'Template',         'Código-fonte do template'),
        ('OutputContentType',           'Output Content Type',    'Content Type',     'MIME type da saída renderizada'),
        ('OutputFileExtension',         'Output File Extension',  'File Extension',   'Extensão do arquivo de saída (sem ponto)'),
        ('TemplateEncoding',            'Template Encoding',      'Encoding',         'Encoding do template e da saída'),
        ('IsBinaryOutput',              'Binary Output',          'Binary',           'Saída é binária (ex.: PDF pós-processado) em vez de texto'),
        ('TargetName',                  'Target Name',            'Target Name',      'Nome da coleção no data model do template (ex.: lines, taxes)'),
        ('IncludeNested',               'Include Nested',         'Nested',           'Inclui netos via o mesmo mecanismo de includes'),
        ('MaxRows',                     'Max Rows',               'Max Rows',         'Limite defensivo de linhas carregadas pro data model')
    ) AS els(cname, nm, pn, ds);

    -- 1.3 Reference List TemplateEngineType
    v_ref_engine := nextidfunc(seq_reference,'N');
    INSERT INTO AD_Reference (AD_Reference_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
        Updated, UpdatedBy, Name, Description, ValidationType, EntityType, AD_Reference_UU)
    VALUES (v_ref_engine, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'PRT_TemplateEngineType', 'Template engine do Print Template Engine', 'L', 'PRT', generate_uuid());

    INSERT INTO AD_Ref_List (AD_Ref_List_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
        Updated, UpdatedBy, Value, Name, AD_Reference_ID, EntityType, AD_Ref_List_UU)
    VALUES
        (nextidfunc(seq_reflist,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100, 'FM', 'FreeMarker',  v_ref_engine, 'PRT', generate_uuid()),
        (nextidfunc(seq_reflist,'N'), 0, 0, 'N', NOW(), 100, NOW(), 100, 'VL', 'Velocity',    v_ref_engine, 'PRT', generate_uuid()),
        (nextidfunc(seq_reflist,'N'), 0, 0, 'N', NOW(), 100, NOW(), 100, 'TH', 'Thymeleaf',   v_ref_engine, 'PRT', generate_uuid()),
        (nextidfunc(seq_reflist,'N'), 0, 0, 'N', NOW(), 100, NOW(), 100, 'MS', 'Mustache',    v_ref_engine, 'PRT', generate_uuid()),
        (nextidfunc(seq_reflist,'N'), 0, 0, 'N', NOW(), 100, NOW(), 100, 'HB', 'Handlebars',  v_ref_engine, 'PRT', generate_uuid());
    -- só FM ativo — os demais ativam quando o respectivo plugin existir

    -- 1.4 AD_Table + AD_Sequence das 2 tabelas
    v_tbl_tpl := nextidfunc(seq_table,'N');
    v_tbl_inc := nextidfunc(seq_table,'N');
    INSERT INTO AD_Table (AD_Table_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, TableName, AccessLevel, EntityType, IsView, IsDeleteable, IsSecurityEnabled,
        IsHighVolume, ImportTable, IsChangeLog, ReplicationType, IsCentrallyMaintained,
        IsShowInDrillOptions, AD_Table_UU)
    VALUES
        (v_tbl_tpl, 0, 0, 'Y', NOW(), 100, NOW(), 100, 'Print Template', 'AD_PrintTemplate',
         '6', 'PRT', 'N', 'Y', 'N', 'N', 'N', 'Y', 'L', 'Y', 'N', generate_uuid()),
        (v_tbl_inc, 0, 0, 'Y', NOW(), 100, NOW(), 100, 'Print Template Include', 'AD_PrintTemplate_Include',
         '6', 'PRT', 'N', 'Y', 'N', 'N', 'N', 'Y', 'L', 'Y', 'N', generate_uuid());
    -- AccessLevel 6 = System+Client: template default do pacote (System) + custom por tenant

    INSERT INTO AD_Sequence (AD_Sequence_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, IsTableID, IsAutoSequence, IsAudited, StartNewYear,
        StartNo, IncrementNo, CurrentNext, CurrentNextSys, AD_Sequence_UU)
    VALUES
        (nextidfunc(seq_sequence,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100, 'AD_PrintTemplate',
         'Table AD_PrintTemplate', 'Y', 'Y', 'N', 'N', 1000000, 1, 1000000, 200000, generate_uuid()),
        (nextidfunc(seq_sequence,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100, 'AD_PrintTemplate_Include',
         'Table AD_PrintTemplate_Include', 'Y', 'Y', 'N', 'N', 1000000, 1, 1000000, 200000, generate_uuid());

    -- 1.5 Colunas — AD_PrintTemplate
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Print Template',        'AD_PrintTemplate_ID',  13, NULL,        22, 'Y','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'AD_PrintTemplate_UU',   'AD_PrintTemplate_UU',  10, NULL,        36, 'N','N','N', 0, 'Y', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Client',                'AD_Client_ID',         19, NULL,        22, 'N','N','Y', 0, 'N', '@#AD_Client_ID@', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Organization',          'AD_Org_ID',            19, NULL,        22, 'N','N','Y', 0, 'N', '@#AD_Org_ID@', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Active',                'IsActive',             20, NULL,         1, 'N','N','Y', 0, 'Y', 'Y', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Created',               'Created',              16, NULL,         7, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Created By',            'CreatedBy',            18, 110,         22, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Updated',               'Updated',              16, NULL,         7, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Updated By',            'UpdatedBy',            18, 110,         22, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Name',                  'Name',                 10, NULL,       120, 'N','N','Y', 1, 'Y', NULL, 'Resolvível por <#include "Name"> e pelo fallback de classpath');
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Description',           'Description',          10, NULL,       255, 'N','N','N', 0, 'Y', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Comment/Help',          'Help',                 14, NULL,      2000, 'N','N','N', 0, 'Y', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Template Engine Type',  'TemplateEngineType',   17, v_ref_engine,  2, 'N','N','Y', 0, 'Y', 'FM', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Template Body',         'TemplateBody',         36, NULL,         0, 'N','N','Y', 0, 'Y', NULL, 'Código-fonte do template');
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Output Content Type',   'OutputContentType',    10, NULL,        60, 'N','N','Y', 0, 'Y', 'text/html', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Output File Extension', 'OutputFileExtension',  10, NULL,        10, 'N','N','Y', 0, 'Y', 'html', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Template Encoding',     'TemplateEncoding',     10, NULL,        20, 'N','N','Y', 0, 'Y', 'UTF-8', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Binary Output',         'IsBinaryOutput',       20, NULL,         1, 'N','N','Y', 0, 'Y', 'N', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_tpl, 'Table',                 'AD_Table_ID',          19, NULL,        22, 'N','N','N', 0, 'Y', NULL, 'Tabela primária esperada (validação opcional)');

    -- 1.6 Colunas — AD_PrintTemplate_Include
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Print Template Include','AD_PrintTemplate_Include_ID', 13, NULL, 22, 'Y','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'AD_PrintTemplate_Include_UU','AD_PrintTemplate_Include_UU', 10, NULL, 36, 'N','N','N', 0, 'Y', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Print Template',        'AD_PrintTemplate_ID',  19, NULL,        22, 'N','Y','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Client',                'AD_Client_ID',         19, NULL,        22, 'N','N','Y', 0, 'N', '@#AD_Client_ID@', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Organization',          'AD_Org_ID',            19, NULL,        22, 'N','N','Y', 0, 'N', '@#AD_Org_ID@', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Active',                'IsActive',             20, NULL,         1, 'N','N','Y', 0, 'Y', 'Y', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Created',               'Created',              16, NULL,         7, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Created By',            'CreatedBy',            18, 110,         22, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Updated',               'Updated',              16, NULL,         7, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Updated By',            'UpdatedBy',            18, 110,         22, 'N','N','Y', 0, 'N', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Table',                 'AD_Table_ID',          19, NULL,        22, 'N','N','Y', 0, 'Y', NULL, 'Tabela filha a carregar (FK reversa pro registro raiz)');
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Target Name',           'TargetName',           10, NULL,        60, 'N','N','Y', 1, 'Y', NULL, 'Nome da coleção no data model (ex.: lines)');
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Sql WHERE',             'WhereClause',          10, NULL,      2000, 'N','N','N', 0, 'Y', NULL, 'Filtro adicional (sem prefixo AND)');
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Sql ORDER BY',          'OrderByClause',        10, NULL,       255, 'N','N','N', 0, 'Y', NULL, NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Sequence',              'SeqNo',                11, NULL,        22, 'N','N','Y', 0, 'Y', '10', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Include Nested',        'IncludeNested',        20, NULL,         1, 'N','N','Y', 0, 'Y', 'N', NULL);
    PERFORM pg_temp.prt_addcol(v_tbl_inc, 'Max Rows',              'MaxRows',              11, NULL,        22, 'N','N','N', 0, 'Y', NULL, NULL);

    -- 1.7 Coluna nova no AD_PrintFormat (tabela core 493, coluna EntityType PRT)
    v_pf_col := pg_temp.prt_addcol(493, 'Print Template', 'AD_PrintTemplate_ID', 19, NULL, 22, 'N','N','N', 0, 'Y', NULL,
        'Renderiza este formato via template declarativo (a ponte JasperProcess_ID é setada automaticamente)');

    -- 1.8 Janela + tabs
    v_win := nextidfunc(seq_window,'N');
    INSERT INTO AD_Window (AD_Window_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, WindowType, EntityType, IsSOTrx, IsDefault, IsBetaFunctionality, AD_Window_UU)
    VALUES (v_win, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'Print Template', 'Templates declarativos pra renderização de print format (FreeMarker etc.)',
        'M', 'PRT', 'N', 'N', 'N', generate_uuid());

    v_tab_tpl := nextidfunc(seq_tab,'N');
    v_tab_inc := nextidfunc(seq_tab,'N');
    INSERT INTO AD_Tab (AD_Tab_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, AD_Window_ID, AD_Table_ID, SeqNo, TabLevel, IsSingleRow, IsSortTab,
        IsReadOnly, HasTree, IsTranslationTab, EntityType, IsInfoTab, IsInsertRecord, IsAdvancedTab, AD_Tab_UU)
    VALUES
        (v_tab_tpl, 0, 0, 'Y', NOW(), 100, NOW(), 100, 'Template', 'Template declarativo',
         v_win, v_tbl_tpl, 10, 0, 'N', 'N', 'N', 'N', 'N', 'PRT', 'N', 'Y', 'N', generate_uuid()),
        (v_tab_inc, 0, 0, 'Y', NOW(), 100, NOW(), 100, 'Include', 'Tabelas filhas do data model',
         v_win, v_tbl_inc, 20, 1, 'N', 'N', 'N', 'N', 'N', 'PRT', 'N', 'Y', 'N', generate_uuid());

    UPDATE AD_Table SET AD_Window_ID=v_win, Updated=NOW(), UpdatedBy=100
     WHERE AD_Table_ID IN (v_tbl_tpl, v_tbl_inc);

    -- 1.9 Fields gerados das colunas (chave entra NÃO-exibida — o GridTable
    -- precisa do field da coluna-chave pra montar o WHERE do save; sem ele:
    -- "No key Found" + "No Persistent Object". UU/audit ficam fora.)
    INSERT INTO AD_Field (AD_Field_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, AD_Tab_ID, AD_Column_ID, IsDisplayed, DisplayLength, SeqNo,
        IsSameLine, IsHeading, IsFieldOnly, IsReadOnly, IsEncrypted, EntityType, AD_Field_UU)
    SELECT nextidfunc(seq_field,'N'), 0, 0, 'Y', NOW(), 100, NOW(), 100,
        c.Name, c.Description, t.tab_id, c.AD_Column_ID,
        CASE WHEN c.IsKey='Y' THEN 'N' ELSE 'Y' END,
        LEAST(GREATEST(COALESCE(c.FieldLength,20),1),60),
        CASE WHEN c.IsKey='Y' THEN 0
             ELSE 10 * ROW_NUMBER() OVER (PARTITION BY t.tab_id ORDER BY c.AD_Column_ID) END,
        'N', 'N', 'N', 'N', 'N', 'PRT', generate_uuid()
    FROM (VALUES (v_tbl_tpl, v_tab_tpl), (v_tbl_inc, v_tab_inc)) AS t(table_id, tab_id)
    JOIN AD_Column c ON c.AD_Table_ID = t.table_id
    WHERE c.ColumnName NOT LIKE '%_UU'
      AND c.ColumnName NOT IN ('Created','CreatedBy','Updated','UpdatedBy');

    -- 1.10 Field do AD_PrintTemplate_ID na janela 240 (tab 425), perto do JasperProcess_ID
    v_pf_field := nextidfunc(seq_field,'N');
    INSERT INTO AD_Field (AD_Field_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, AD_Tab_ID, AD_Column_ID, IsDisplayed, DisplayLength, SeqNo,
        IsSameLine, IsHeading, IsFieldOnly, IsReadOnly, IsEncrypted, EntityType, AD_Field_UU)
    VALUES (v_pf_field, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'Print Template', 'Renderiza via template declarativo em vez do layout',
        425, v_pf_col, 'Y', 22, 260, 'N', 'N', 'N', 'N', 'N', 'PRT', generate_uuid());

    -- 1.11 Menu (mesmo pai do Print Format na tree 10)
    SELECT Parent_ID INTO v_parent_menu FROM AD_TreeNodeMM
     WHERE AD_Tree_ID=10 AND Node_ID=(SELECT AD_Menu_ID FROM AD_Menu WHERE Name='Print Format' AND Action='W' AND IsActive='Y' LIMIT 1);

    v_menu := nextidfunc(seq_menu,'N');
    INSERT INTO AD_Menu (AD_Menu_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Name, Description, Action, AD_Window_ID, EntityType, IsSummary, IsReadOnly, IsSOTrx, IsCentrallyMaintained, AD_Menu_UU)
    VALUES (v_menu, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'Print Template', 'Templates declarativos de impressão', 'W', v_win, 'PRT', 'N', 'N', 'N', 'Y', generate_uuid());

    INSERT INTO AD_TreeNodeMM (AD_Tree_ID, Node_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
        Updated, UpdatedBy, Parent_ID, SeqNo, AD_TreeNodeMM_UU)
    VALUES (10, v_menu, 0, 0, 'Y', NOW(), 100, NOW(), 100, COALESCE(v_parent_menu,0), 5, generate_uuid());

    -- 1.12 AD_Process ponte
    -- JasperReport = marcador NÃO-NULO: satisfaz o lookup do JasperProcess_ID
    -- (Reference 400: AD_Process.JasperReport IS NOT NULL) sem desviar a
    -- execução — com Classname preenchido, ServerProcessCtl roda a classe
    -- (só marca setReportingProcess(true)).
    v_proc := nextidfunc(seq_process,'N');
    INSERT INTO AD_Process (AD_Process_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
        Value, Name, Description, AccessLevel, EntityType, Classname, IsReport, IsDirectPrint,
        JasperReport, ShowHelp, IsBetaFunctionality, Statistic_Count, Statistic_Seconds, AD_Process_UU)
    VALUES (v_proc, 0, 0, 'Y', NOW(), 100, NOW(), 100,
        'PrintTemplate_ReportStarter', 'Print Template Report Starter',
        'Ponte do Print Template Engine — executado via JasperProcess_ID do print format',
        '3', 'PRT', 'org.idempiere.print.template.TemplateReportStarter', 'Y', 'N',
        'PrintTemplateEngine:bridge', 'S', 'N', 0, 0, generate_uuid());

    -- 1.13 DisplayLogic na janela 240 — APPEND (preserva gates do fork, ex. COF_isTemplateDOCX)
    UPDATE AD_Field f
       SET DisplayLogic = COALESCE(f.DisplayLogic || ' & ', '') || '@AD_PrintTemplate_ID@=0',
           Updated=NOW(), UpdatedBy=100
      FROM AD_Column c
     WHERE c.AD_Column_ID=f.AD_Column_ID AND f.AD_Tab_ID=425
       AND c.ColumnName IN ('HeaderMargin','FooterMargin','IsStandardHeaderFooter','AD_PrintColor_ID',
                            'AD_PrintFont_ID','AD_PrintPaper_ID','IsTableBased','IsBreakPagePerRecord',
                            'JasperProcess_ID')
       AND (f.DisplayLogic IS NULL OR f.DisplayLogic NOT LIKE '%AD_PrintTemplate_ID%');
    GET DIAGNOSTICS n = ROW_COUNT;
    RAISE NOTICE 'DisplayLogic aplicado em % fields da tab 425', n;

    UPDATE AD_Tab
       SET DisplayLogic = COALESCE(DisplayLogic || ' & ', '') || '@AD_PrintTemplate_ID@=0',
           Updated=NOW(), UpdatedBy=100
     WHERE AD_Window_ID=240 AND AD_Table_ID=489
       AND (DisplayLogic IS NULL OR DisplayLogic NOT LIKE '%AD_PrintTemplate_ID%');
    GET DIAGNOSTICS n = ROW_COUNT;
    RAISE NOTICE 'DisplayLogic aplicado em % tabs de PrintFormatItem', n;

    RAISE NOTICE 'PRT: tables %/%, window %, tabs %/%, menu %, process %, pf_col %',
        v_tbl_tpl, v_tbl_inc, v_win, v_tab_tpl, v_tab_inc, v_menu, v_proc, v_pf_col;
END
$BODY$;

-- ----------------------------------------------------------------------------
-- 2. Trl backfill (idiomas de sistema; IsTranslated=N — traduções vêm depois)
-- ----------------------------------------------------------------------------
INSERT INTO AD_Element_Trl (AD_Element_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, PrintName, Description, Help, PO_Name, PO_PrintName, PO_Description, PO_Help,
    IsTranslated, AD_Element_Trl_UU)
SELECT e.AD_Element_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       e.Name, e.PrintName, e.Description, e.Help, e.PO_Name, e.PO_PrintName, e.PO_Description, e.PO_Help,
       'N', generate_uuid()
FROM AD_Element e CROSS JOIN AD_Language l
WHERE e.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Element_Trl t WHERE t.AD_Element_ID=e.AD_Element_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Reference_Trl (AD_Reference_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Reference_Trl_UU)
SELECT r.AD_Reference_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       r.Name, r.Description, r.Help, 'N', generate_uuid()
FROM AD_Reference r CROSS JOIN AD_Language l
WHERE r.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Reference_Trl t WHERE t.AD_Reference_ID=r.AD_Reference_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Ref_List_Trl (AD_Ref_List_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, IsTranslated, AD_Ref_List_Trl_UU)
SELECT r.AD_Ref_List_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       r.Name, r.Description, 'N', generate_uuid()
FROM AD_Ref_List r CROSS JOIN AD_Language l
WHERE r.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Ref_List_Trl t WHERE t.AD_Ref_List_ID=r.AD_Ref_List_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Window_Trl (AD_Window_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Window_Trl_UU)
SELECT w.AD_Window_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       w.Name, w.Description, w.Help, 'N', generate_uuid()
FROM AD_Window w CROSS JOIN AD_Language l
WHERE w.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Window_Trl t WHERE t.AD_Window_ID=w.AD_Window_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Tab_Trl (AD_Tab_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, CommitWarning, IsTranslated, AD_Tab_Trl_UU)
SELECT b.AD_Tab_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       b.Name, b.Description, b.Help, b.CommitWarning, 'N', generate_uuid()
FROM AD_Tab b CROSS JOIN AD_Language l
WHERE b.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Tab_Trl t WHERE t.AD_Tab_ID=b.AD_Tab_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Field_Trl (AD_Field_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Field_Trl_UU)
SELECT f.AD_Field_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       f.Name, f.Description, f.Help, 'N', generate_uuid()
FROM AD_Field f CROSS JOIN AD_Language l
WHERE f.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Field_Trl t WHERE t.AD_Field_ID=f.AD_Field_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Menu_Trl (AD_Menu_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, IsTranslated, AD_Menu_Trl_UU)
SELECT m.AD_Menu_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       m.Name, m.Description, 'N', generate_uuid()
FROM AD_Menu m CROSS JOIN AD_Language l
WHERE m.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Menu_Trl t WHERE t.AD_Menu_ID=m.AD_Menu_ID AND t.AD_Language=l.AD_Language);

INSERT INTO AD_Process_Trl (AD_Process_ID, AD_Language, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
    Updated, UpdatedBy, Name, Description, Help, IsTranslated, AD_Process_Trl_UU)
SELECT p.AD_Process_ID, l.AD_Language, 0, 0, 'Y', NOW(), 100, NOW(), 100,
       p.Name, p.Description, p.Help, 'N', generate_uuid()
FROM AD_Process p CROSS JOIN AD_Language l
WHERE p.EntityType='PRT' AND l.IsSystemLanguage='Y'
  AND NOT EXISTS (SELECT 1 FROM AD_Process_Trl t WHERE t.AD_Process_ID=p.AD_Process_ID AND t.AD_Language=l.AD_Language);

-- ----------------------------------------------------------------------------
-- 3. Sanity
-- ----------------------------------------------------------------------------
DO $CHK$
DECLARE n integer;
BEGIN
    SELECT COUNT(*) INTO n FROM AD_Column WHERE EntityType='PRT';
    IF n <> 37 THEN RAISE EXCEPTION 'Esperava 37 AD_Column PRT (19+17+1), achou %', n; END IF;
    SELECT COUNT(*) INTO n FROM AD_Ref_List WHERE EntityType='PRT';
    IF n <> 5 THEN RAISE EXCEPTION 'Esperava 5 AD_Ref_List PRT, achou %', n; END IF;
    SELECT COUNT(*) INTO n FROM AD_Column WHERE EntityType='PRT' AND AD_Element_ID IS NULL;
    IF n <> 0 THEN RAISE EXCEPTION '% AD_Column PRT sem AD_Element_ID', n; END IF;
    SELECT COUNT(*) INTO n FROM information_schema.columns
     WHERE table_name='ad_printformat' AND column_name='ad_printtemplate_id';
    IF n <> 1 THEN RAISE EXCEPTION 'Coluna física AD_PrintFormat.AD_PrintTemplate_ID ausente'; END IF;
    SELECT COUNT(*) INTO n FROM AD_Process WHERE Value='PrintTemplate_ReportStarter' AND JasperReport IS NOT NULL;
    IF n <> 1 THEN RAISE EXCEPTION 'Processo ponte ausente ou sem marcador JasperReport'; END IF;
    RAISE NOTICE 'Sanity OK';
END
$CHK$;

COMMIT;
