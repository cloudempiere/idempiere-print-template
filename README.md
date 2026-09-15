# iDempiere Print Template Engine

OSGi plugin that plugs declarative template engines (FreeMarker first)
into iDempiere's print format engine — HTML/PDF output driven by
`AD_PrintFormat`, with no core code patches.

- Dictionary (`AD_PrintTemplate` + window) ships as an
  embedded incremental 2Pack, installed automatically on bundle start.
- Rendering hooks through the report-content API introduced by
  [IDEMPIERE-7070](https://idempiere.atlassian.net/browse/IDEMPIERE-7070); templates live
  in the database with classpath fallback.
- PDF output via openhtmltopdf; honors the report viewer's PDF/HTML
  type selection in UI, batch and scheduler paths.
- Bonus: JSON export of any record in the native Export dialog
  (`IGridTabExporter`).

> ⚠️ **Early development.** Works end-to-end on iDempiere 14, but not
> production-ready — APIs and dictionary may change.

Requires iDempiere 14 / Java 17. Import `org.idempiere.print.freemarker`
as an Eclipse PDE project. License: GPL-2.0.
