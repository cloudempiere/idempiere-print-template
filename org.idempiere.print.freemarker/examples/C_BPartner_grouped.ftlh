<#include "styles.ftlh">
<style>
  h2 { margin-bottom: .15em; }
  .num { text-align: right; white-space: nowrap; }
  tr.grouphdr td { background: #e5edff; font-weight: bold; }
  tr.subtotal td { font-style: italic; border-top: 1px solid #bbb; }
  tfoot td { font-weight: bold; border-top: 2px solid #999; background: #f3f3f3; }
</style>
<h2>Business Partners by Group</h2>
<div class="muted">${ctx.client_name!""} &middot; ${(ctx.now?string('yyyy-MM-dd HH:mm'))!""} &middot; ${count} records</div>

<#-- ordena por grupo (id numerico) e detecta a virada acumulando via <#assign> -->
<#assign sorted = rows?sort_by(["C_BP_Group_ID","id"])>
<#assign prevKey = -1>
<#assign subTotal = 0>
<#assign subCount = 0>
<#assign grandTotal = 0>
<table>
  <thead>
    <tr><th>Search Key</th><th>Name</th><th>Sales Rep</th><th class="num">Credit Limit</th></tr>
  </thead>
  <tbody>
<#list sorted as r>
  <#assign key = (r.C_BP_Group_ID.id)!0>
  <#if key != prevKey>
    <#if prevKey != -1>
    <tr class="subtotal"><td colspan="3">Subtotal (${subCount})</td><td class="num">${subTotal?string["#,##0.00"]}</td></tr>
    </#if>
    <tr class="grouphdr"><td colspan="4">${(r.C_BP_Group_ID.display)!"(no group)"}</td></tr>
    <#assign prevKey = key>
    <#assign subTotal = 0>
    <#assign subCount = 0>
  </#if>
    <tr>
      <td>${r.Value!"-"}</td>
      <td>${r.Name!"-"}</td>
      <td>${(r.SalesRep_ID.display)!"-"}</td>
      <td class="num"><#if (r.SO_CreditLimit)??>${r.SO_CreditLimit?string["#,##0.00"]}<#else>-</#if></td>
    </tr>
  <#assign amt = (r.SO_CreditLimit)!0>
  <#assign subTotal = subTotal + amt>
  <#assign subCount = subCount + 1>
  <#assign grandTotal = grandTotal + amt>
</#list>
  <#if prevKey != -1>
    <tr class="subtotal"><td colspan="3">Subtotal (${subCount})</td><td class="num">${subTotal?string["#,##0.00"]}</td></tr>
  </#if>
  </tbody>
  <tfoot>
    <tr><td colspan="3">Grand Total (${count})</td><td class="num">${grandTotal?string["#,##0.00"]}</td></tr>
  </tfoot>
</table>

