<#-- Sales Order — Deluxe. C_Order document (IsForm='Y'). lines/taxes via convention. -->
<#assign taxTotal = 0>
<#list taxes as t><#assign taxTotal = taxTotal + (t.TaxAmt)!0></#list>
<#assign cur = (C_Currency_ID.display)!"">
<style>
  @page { size: A4; margin: 12mm 12mm 14mm; }
  * { box-sizing: border-box; }
  body { font-family: sans-serif; color: #263238; font-size: 10.5pt; margin: 0; }
  .band { background: #1b5e20; color: #fff; padding: 7mm 8mm; margin-bottom: 8mm; }
  .band table { width: 100%; }
  .band td { border: 0; vertical-align: middle; padding: 0; }
  .brand { font-size: 20pt; font-weight: bold; letter-spacing: 1px; }
  .sub { color: #a5d6a7; font-size: 8.5pt; text-transform: uppercase; letter-spacing: 2px; }
  .doc { text-align: right; }
  .doc .t { font-size: 15pt; font-weight: bold; }
  .doc .d { color: #c8e6c9; font-size: 9pt; }
  .cols { width: 100%; }
  .cols > table { width: 100%; }
  .cols td { vertical-align: top; width: 50%; border: 0; padding: 0 4mm 0 0; }
  .card { background: #e8f5e9; border-left: 4px solid #43a047; padding: 5mm 6mm; }
  .card h3 { margin: 0 0 2mm 0; color: #1b5e20; font-size: 8.5pt; text-transform: uppercase; letter-spacing: 1px; }
  .card .big { font-size: 12pt; font-weight: bold; }
  .kv { width: 100%; }
  .kv td { border: 0; padding: 1.2mm 0; }
  .kv .k { color: #78909c; width: 44%; }
  table.items { width: 100%; border-collapse: collapse; margin-top: 9mm; }
  table.items th { background: #1b5e20; color: #fff; padding: 3mm; text-align: left; font-size: 8.5pt;
    text-transform: uppercase; letter-spacing: .5px; }
  table.items td { padding: 3mm; border-bottom: 1px solid #e0e0e0; vertical-align: top; }
  table.items tr.alt td { background: #f5f7f5; }
  .num { text-align: right; white-space: nowrap; }
  .prod { font-weight: bold; }
  .prod .d { font-weight: normal; color: #90a4ae; font-size: 9pt; }
  .totbox { width: 74mm; margin-left: auto; margin-top: 8mm; border-collapse: collapse; }
  .totbox td { padding: 2.4mm 4mm; border: 0; }
  .totbox .lbl { color: #607d8b; }
  .totbox .grand td { background: #1b5e20; color: #fff; font-size: 13pt; font-weight: bold; }
  .terms { margin-top: 11mm; border-top: 2px solid #43a047; padding-top: 4mm; color: #546e7a; font-size: 9pt; }
  .stamp { margin-top: 2mm; color: #b0bec5; font-size: 8pt; }
</style>

<div class="band">
  <table><tr>
    <td>
      <div class="brand">${ctx.client_name!"Garden World"}</div>
      <div class="sub">Sales Order</div>
    </td>
    <td class="doc">
      <div class="t">#${DocumentNo!"-"}</div>
      <div class="d"><#if DateOrdered??>${DateOrdered?string('MMM d, yyyy')}<#else>-</#if></div>
    </td>
  </tr></table>
</div>

<div class="cols">
  <table><tr>
    <td>
      <div class="card">
        <h3>Bill To</h3>
        <div class="big">${(C_BPartner_ID.display)!"-"}</div>
        <div>${(C_BPartner_Location_ID.display)!""}</div>
      </div>
    </td>
    <td>
      <table class="kv">
        <tr><td class="k">PO Reference</td><td>${POReference!"-"}</td></tr>
        <tr><td class="k">Sales Rep</td><td>${(SalesRep_ID.display)!"-"}</td></tr>
        <tr><td class="k">Payment Term</td><td>${(C_PaymentTerm_ID.display)!"-"}</td></tr>
        <tr><td class="k">Date Promised</td><td><#if DatePromised??>${DatePromised?string('MMM d, yyyy')}<#else>-</#if></td></tr>
        <tr><td class="k">Currency</td><td>${cur}</td></tr>
      </table>
    </td>
  </tr></table>
</div>

<table class="items">
  <thead>
    <tr><th>#</th><th>Product</th><th class="num">Qty</th><th class="num">Unit Price</th><th class="num">Amount</th></tr>
  </thead>
  <tbody>
<#list lines as l>
    <tr<#if l?index % 2 == 1> class="alt"</#if>>
      <td>${l.Line!"-"}</td>
      <td class="prod">
        <#if (l.M_Product_ID)??>${(l.M_Product_ID.display)!"-"}<#else>${l.Description!"-"}</#if>
        <#if (l.M_Product_ID)?? && (l.Description!"")?has_content><div class="d">${l.Description}</div></#if>
      </td>
      <td class="num">${((l.QtyOrdered)!0)?string["#,##0.###"]} ${(l.C_UOM_ID.display)!""}</td>
      <td class="num">${((l.PriceActual)!0)?string["#,##0.00"]}</td>
      <td class="num">${((l.LineNetAmt)!0)?string["#,##0.00"]}</td>
    </tr>
<#else>
    <tr><td colspan="5">No lines.</td></tr>
</#list>
  </tbody>
</table>

<table class="totbox">
  <tr><td class="lbl">Subtotal</td><td class="num">${((TotalLines)!0)?string["#,##0.00"]} ${cur}</td></tr>
  <tr><td class="lbl">Tax</td><td class="num">${taxTotal?string["#,##0.00"]} ${cur}</td></tr>
  <tr class="grand"><td>Grand Total</td><td class="num">${((GrandTotal)!0)?string["#,##0.00"]} ${cur}</td></tr>
</table>

<div class="terms">
  <strong>Payment:</strong> ${(C_PaymentTerm_ID.display)!"-"} &middot; <strong>Currency:</strong> ${cur}.
  Thank you for your business — ${ctx.client_name!"Garden World"}.
  <div class="stamp">Generated ${(ctx.now?string('yyyy-MM-dd HH:mm'))!""}</div>
</div>
