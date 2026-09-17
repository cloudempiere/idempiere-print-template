<#include "styles.ftlh">
<style>
  h2 { margin-bottom: .15em; }
  .num { text-align: right; white-space: nowrap; }
  tfoot td { font-weight: bold; border-top: 2px solid #999; }
</style>
<h2>Business Partners</h2>
<div class="muted">${ctx.client_name!""} &middot; ${(ctx.now?string('yyyy-MM-dd HH:mm'))!""} &middot; ${count} records</div>
<#-- FreeMarker 2.3.33 NAO tem ?sum: soma na mao com <#assign> (namespace-scoped persiste no <#list>) -->
<#assign grandTotal = 0>
<table>
  <thead>
    <tr>
      <th>Search Key</th><th>Name</th><th>BP Group</th><th>Sales Rep</th><th class="num">Credit Limit</th>
    </tr>
  </thead>
  <tbody>
<#list rows as r>
    <tr>
      <td>${r.Value!"-"}</td>
      <td>${r.Name!"-"}</td>
      <td>${(r.C_BP_Group_ID.display)!"-"}</td>
      <td>${(r.SalesRep_ID.display)!"-"}</td>
      <td class="num"><#if (r.SO_CreditLimit)??>${r.SO_CreditLimit?string["#,##0.00"]}<#else>-</#if></td>
    </tr>
  <#assign grandTotal = grandTotal + (r.SO_CreditLimit)!0>
</#list>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="4">Total (${count})</td>
      <td class="num">${grandTotal?string["#,##0.00"]}</td>
    </tr>
  </tfoot>
</table>

