<#include "styles.ftlh">
<style>
  h2 { margin-bottom: .15em; }
  .num { text-align: right; white-space: nowrap; }
  tr.grouphdr td { background: #e5edff; font-weight: bold; }
  tr.subtotal td { font-style: italic; border-top: 1px solid #bbb; }
  tfoot td { font-weight: bold; border-top: 2px solid #999; background: #f3f3f3; }
</style>
<h2>Customers by Group &mdash; Credit</h2>
<#-- 1) filtro: so IsCustomer (Boolean); 2) ordena por grupo (id) p/ agrupar -->
<#assign customers = rows?filter(r -> (r.IsCustomer)!false)>
<#assign sorted = customers?sort_by(["C_BP_Group_ID","id"])>
<div class="muted">${ctx.client_name!""} &middot; ${(ctx.now?string('yyyy-MM-dd HH:mm'))!""} &middot; ${customers?size} of ${count} partners</div>
<#assign prevKey = -1>
<#assign subLimit = 0><#assign subUsed = 0><#assign subCount = 0>
<#assign grandLimit = 0><#assign grandUsed = 0>
<table>
  <thead>
    <tr>
      <th>Search Key</th><th>Name</th><th>Sales Rep</th>
      <th class="num">Credit Limit</th><th class="num">Credit Used</th><th class="num">Available</th>
    </tr>
  </thead>
  <tbody>
<#list sorted as r>
  <#assign key = (r.C_BP_Group_ID.id)!0>
  <#if key != prevKey>
    <#if prevKey != -1>
    <tr class="subtotal">
      <td colspan="3">Subtotal (${subCount})</td>
      <td class="num">${subLimit?string["#,##0.00"]}</td>
      <td class="num">${subUsed?string["#,##0.00"]}</td>
      <td class="num">${(subLimit - subUsed)?string["#,##0.00"]}</td>
    </tr>
    </#if>
    <tr class="grouphdr"><td colspan="6">${(r.C_BP_Group_ID.display)!"(no group)"}</td></tr>
    <#assign prevKey = key>
    <#assign subLimit = 0><#assign subUsed = 0><#assign subCount = 0>
  </#if>
  <#assign lim = (r.SO_CreditLimit)!0>
  <#assign used = (r.SO_CreditUsed)!0>
    <tr>
      <td>${r.Value!"-"}</td>
      <td>${r.Name!"-"}</td>
      <td>${(r.SalesRep_ID.display)!"-"}</td>
      <td class="num">${lim?string["#,##0.00"]}</td>
      <td class="num">${used?string["#,##0.00"]}</td>
      <td class="num">${(lim - used)?string["#,##0.00"]}</td>
    </tr>
  <#assign subLimit = subLimit + lim>
  <#assign subUsed = subUsed + used>
  <#assign subCount = subCount + 1>
  <#assign grandLimit = grandLimit + lim>
  <#assign grandUsed = grandUsed + used>
<#else>
    <tr><td colspan="6" class="muted">No customers found.</td></tr>
</#list>
  <#if prevKey != -1>
    <tr class="subtotal">
      <td colspan="3">Subtotal (${subCount})</td>
      <td class="num">${subLimit?string["#,##0.00"]}</td>
      <td class="num">${subUsed?string["#,##0.00"]}</td>
      <td class="num">${(subLimit - subUsed)?string["#,##0.00"]}</td>
    </tr>
  </#if>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="3">Grand Total (${customers?size})</td>
      <td class="num">${grandLimit?string["#,##0.00"]}</td>
      <td class="num">${grandUsed?string["#,##0.00"]}</td>
      <td class="num">${(grandLimit - grandUsed)?string["#,##0.00"]}</td>
    </tr>
  </tfoot>
</table>

