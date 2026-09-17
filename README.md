# iDempiere Print Template Engine

OSGi plugin that plugs declarative template engines (FreeMarker first)
into iDempiere's print format engine — HTML/PDF/CSV/XLSX output driven by
`AD_PrintFormat`, with no core code patches.

- Rendering hooks through the report-content API introduced by
  [IDEMPIERE-7070](https://idempiere.atlassian.net/browse/IDEMPIERE-7070);
  templates live in the database (`AD_PrintTemplate`) with classpath fallback.
- **Document mode** (`IsForm='Y'`): one rendering per record; multi-record
  selections are merged (PDF pages / HTML page-breaks).
- **List/report mode** (`IsForm='N'`): a single rendering over all records,
  exposed to the template as the `rows` collection — tables, grouping,
  subtotals and totals, all in FreeMarker.
- Output honors the report viewer's type selection (UI, batch, scheduler).
  PDF via openhtmltopdf; list formats also **export to CSV and XLSX**.
- Bonus: JSON export of any record in the native Export dialog
  (`IGridTabExporter`).

Dictionary (`AD_PrintTemplate` + window) ships as an embedded incremental
2Pack, installed automatically on bundle start.

> 🧪 **Beta.** Works end-to-end on iDempiere 14. Usable, but the APIs and
> dictionary may still change — pin a commit if you depend on it.

## Templates

Each template is FreeMarker. The data model exposes the record's columns at
top level (foreign keys as `{id, display}`), plus `ctx` (client/org/user/
language/now) and `assets` (template attachments, base64). List mode adds
`rows` (one map per record) and `count`.

Working examples live in [`examples/`](examples/):

- `C_Order.ftlh` — document (invoice-style form)
- `C_BPartner_list.ftlh` — flat listing with a total
- `C_BPartner_grouped.ftlh` — grouped by BP Group with subtotals
- `C_BPartner_customers_grouped.ftlh` — filtered + grouped + calculated column

A fuller authoring guide (data model, available built-ins, and gotchas) is
kept in `spec/` (not versioned).

## Build & install

Requires iDempiere 14 / Java 17. Import `org.idempiere.print.freemarker`
as an Eclipse PDE project, or build headless with `mvn -U verify` (embedded
runtime libraries are fetched by Maven — `lib/` is not committed).

## Credits

Report-content integration (IDEMPIERE-7070) was contributed by
**Markus Bozem** (@mbozem); authorship is preserved in the git history.
This fork extends that work with multi-record documents, list/report mode
and CSV/XLSX export.

License: GPL-2.0.
