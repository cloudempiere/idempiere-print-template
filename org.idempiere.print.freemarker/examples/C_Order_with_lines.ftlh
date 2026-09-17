<#include "styles.ftlh">
<style>
  h1 { font-size: 1.5em; margin-bottom: .1em; }
  table.meta td, table.meta th { border: 0; padding: 2px 12px 2px 0; }
  table.meta th { text-align: left; color: #555; white-space: nowrap; }
  .num { text-align: right; white-space: nowrap; }
  table.lines th { background: #f3f3f3; }
  table.lines tfoot td { font-weight: bold; border-top: 2px solid #999; }
</style>
<h1>Order ${DocumentNo!"-"}</h1>
<table class="meta">
  <tr>
    <th>Date</th><td><#if DateOrdered??>${DateOrdered?string('yyyy-MM-dd')}<#else>-</#if></td>
    <th>Business Partner</th><td>${(C_BPartner_ID.display)!"-"}</td>
  </tr>
  <tr>
    <th>PO Reference</th><td>${POReference!"-"}</td>
    <th>Sales Rep</th><td>${(SalesRep_ID.display)!"-"}</td>
  </tr>
</table>
<#-- 'lines' e 'taxes' vêm dos AD_PrintTemplate_Include (C_OrderLine / C_OrderTax) -->
<table class="lines">
  <thead>
    <tr><th>#</th><th>Product</th><th class="num">Qty</th><th class="num">Price</th><th class="num">Line Amt</th></tr>
  </thead>
  <tbody>
<#list lines as l>
    <tr>
      <td>${l.Line!"-"}</td>
      <td><#if (l.M_Product_ID)??>${(l.M_Product_ID.display)!"-"}<#else>${l.Description!"-"}</#if></td>
      <td class="num">${((l.QtyOrdered)!0)?string["#,##0.###"]}</td>
      <td class="num">${((l.PriceActual)!0)?string["#,##0.00"]}</td>
      <td class="num">${((l.LineNetAmt)!0)?string["#,##0.00"]}</td>
    </tr>
<#else>
    <tr><td colspan="5" class="muted">No lines.</td></tr>
</#list>
  </tbody>
  <tfoot>
    <tr><td colspan="4">Total Lines</td><td class="num">${((TotalLines)!0)?string["#,##0.00"]}</td></tr>
    <tr><td colspan="4">Grand Total</td><td class="num">${((GrandTotal)!0)?string["#,##0.00"]}</td></tr>
  </tfoot>
</table>
<#if taxes?has_content>
<h3>Tax</h3>
<table>
  <thead><tr><th>Tax</th><th class="num">Base</th><th class="num">Amount</th></tr></thead>
  <tbody>
<#list taxes as t>
    <tr>
      <td>${(t.C_Tax_ID.display)!"-"}</td>
      <td class="num">${((t.TaxBaseAmt)!0)?string["#,##0.00"]}</td>
      <td class="num">${((t.TaxAmt)!0)?string["#,##0.00"]}</td>
    </tr>
</#list>
  </tbody>
</table>
</#if>

