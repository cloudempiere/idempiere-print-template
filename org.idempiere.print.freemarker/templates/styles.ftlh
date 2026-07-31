<#-- Base stylesheet default do plugin (fallback classpath — spec §4.8).
     Um AD_PrintTemplate chamado "styles.ftlh" no banco sobrepõe este arquivo.
     @page controla tamanho/margens do PDF (openhtmltopdf); inócuo no HTML. -->
<style>
  @page { size: A4; margin: 18mm; }
  body { font-family: sans-serif; margin: 2em; color: #1f2937; }
  h1, h2, h3 { margin: 0 0 .4em 0; }
  table { width: 100%; border-collapse: collapse; margin-top: 1em; }
  th, td { padding: 8px; border-bottom: 1px solid #ddd; text-align: left; }
  th { background: #f3f3f3; }
  .muted { color: #6b7280; font-size: .85em; }
  .total { font-weight: bold; text-align: right; }
</style>
