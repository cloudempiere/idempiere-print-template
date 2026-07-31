# iDempiere Print Template Engine

OSGi plugin that plugs declarative template engines (FreeMarker first)
into iDempiere's print format engine — HTML/PDF output driven by
`AD_PrintFormat`, with no core code patches.

- Dictionary (`AD_PrintTemplate` + window + bridge process) ships as an
  embedded incremental 2Pack, installed automatically on bundle start.
- Rendering hooks through the `JasperProcess_ID` bridge; templates live
  in the database with classpath fallback.
- PDF output via openhtmltopdf; honors the report viewer's PDF/HTML
  type selection. Inline preview in the ZK viewer requires a small
  additive `ZkReportViewer` patch (not needed for batch/scheduler paths).
- Bonus: JSON export of any record in the native Export dialog
  (`IGridTabExporter`).

> ⚠️ **Early development.** Works end-to-end on iDempiere 12, but not
> production-ready — APIs and dictionary may change. We are tracking
> [IDEMPIERE-7070](https://idempiere.atlassian.net/browse/IDEMPIERE-7070)
> to decide, before a production release, between adopting its proposed
> report-content extension points and keeping the current bridge.

Requires iDempiere 12 / Java 17. Import `org.idempiere.print.freemarker`
as an Eclipse PDE project. License: GPL-2.0.
