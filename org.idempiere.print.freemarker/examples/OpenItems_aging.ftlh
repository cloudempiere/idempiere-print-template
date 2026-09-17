<#-- Open Items — Aging. RV_OpenItem list mode (IsForm='N'). Grouped by BP, aging buckets. -->
<#include "styles.ftlh">
<#-- pass 1: aging buckets (DaysDue > 0 = overdue) -->
<#assign b0 = 0><#assign b1 = 0><#assign b2 = 0><#assign b3 = 0><#assign grand = 0>
<#list rows as r>
  <#assign amt = (r.OpenAmt)!0>
  <#assign d = (r.DaysDue)!0>
  <#assign grand = grand + amt>
  <#if d gt 60><#assign b3 = b3 + amt>
  <#elseif d gt 30><#assign b2 = b2 + amt>
  <#elseif d gt 0><#assign b1 = b1 + amt>
  <#else><#assign b0 = b0 + amt></#if>
</#list>
<#assign cur = "">
<#if rows?size gt 0><#assign cur = (rows[0].C_Currency_ID.display)!""></#if>
<style>
  @page { size: A4 landscape; margin: 12mm; }
  * { box-sizing: border-box; }
  body { font-family: sans-serif; color: #263238; font-size: 10pt; margin: 0; }
  .head { border-bottom: 3px solid #1b5e20; padding-bottom: 4mm; margin-bottom: 6mm; }
  .head .t { font-size: 20pt; font-weight: bold; color: #1b5e20; }
  .head .m { color: #78909c; font-size: 9pt; }
  .cards { width: 100%; border-collapse: separate; border-spacing: 3mm 0; margin-bottom: 7mm; }
  .cards td { width: 20%; vertical-align: top; padding: 4mm; border-top: 3px solid; }
  .cards .lbl { font-size: 8pt; text-transform: uppercase; letter-spacing: .5px; color: #607d8b; }
  .cards .val { font-size: 13pt; font-weight: bold; margin-top: 1mm; }
  .c-cur { background: #e8f5e9; border-color: #2e7d32; } .c-cur .val { color: #2e7d32; }
  .c-b1  { background: #fff8e1; border-color: #f9a825; } .c-b1 .val { color: #f9a825; }
  .c-b2  { background: #fff3e0; border-color: #ef6c00; } .c-b2 .val { color: #ef6c00; }
  .c-b3  { background: #ffebee; border-color: #c62828; } .c-b3 .val { color: #c62828; }
  .c-tot { background: #1b5e20; border-color: #1b5e20; } .c-tot .lbl, .c-tot .val { color: #fff; }
  table.items { width: 100%; border-collapse: collapse; }
  table.items th { background: #1b5e20; color: #fff; padding: 2.6mm 3mm; text-align: left; font-size: 8pt;
    text-transform: uppercase; letter-spacing: .4px; }
  table.items td { padding: 2.4mm 3mm; border-bottom: 1px solid #eceff1; }
  .num { text-align: right; white-space: nowrap; }
  tr.grp td { background: #eef3ee; font-weight: bold; color: #1b5e20; border-top: 1px solid #cfd8dc; }
  tr.sub td { font-style: italic; border-top: 1px solid #cfd8dc; }
  .pill { display: inline-block; padding: 1px 7px; border-radius: 8px; font-size: 8pt; font-weight: bold; }
  .p-cur { background: #e8f5e9; color: #2e7d32; } .p-b1 { background: #fff8e1; color: #b28704; }
  .p-b2 { background: #fff3e0; color: #ef6c00; } .p-b3 { background: #ffebee; color: #c62828; }
  tfoot td { background: #1b5e20; color: #fff; font-weight: bold; font-size: 12pt; }
</style>

<div class="head">
  <div class="t">Open Items — Aging</div>
  <div class="m">${ctx.client_name!""} &middot; as of ${(ctx.now?string('MMMM d, yyyy'))!""}
    &middot; ${count} open item<#if count != 1>s</#if></div>
</div>

<table class="cards"><tr>
  <td class="c-cur"><div class="lbl">Not due</div><div class="val">${b0?string["#,##0.00"]}</div></td>
  <td class="c-b1"><div class="lbl">1 – 30 days</div><div class="val">${b1?string["#,##0.00"]}</div></td>
  <td class="c-b2"><div class="lbl">31 – 60 days</div><div class="val">${b2?string["#,##0.00"]}</div></td>
  <td class="c-b3"><div class="lbl">60+ days</div><div class="val">${b3?string["#,##0.00"]}</div></td>
  <td class="c-tot"><div class="lbl">Total open ${cur}</div><div class="val">${grand?string["#,##0.00"]}</div></td>
</tr></table>

<#assign sorted = rows?sort_by(["C_BPartner_ID","id"])>
<#assign prevKey = -1><#assign sub = 0><#assign subN = 0>
<table class="items">
  <thead>
    <tr><th>Document</th><th>Invoiced</th><th>Due</th><th class="num">Days</th><th>Status</th><th class="num">Open Amount</th></tr>
  </thead>
  <tbody>
<#list sorted as r>
  <#assign key = (r.C_BPartner_ID.id)!0>
  <#if key != prevKey>
    <#if prevKey != -1>
    <tr class="sub"><td colspan="5">Subtotal (${subN})</td><td class="num">${sub?string["#,##0.00"]}</td></tr>
    </#if>
    <tr class="grp"><td colspan="6">${(r.C_BPartner_ID.display)!"(no partner)"}</td></tr>
    <#assign prevKey = key><#assign sub = 0><#assign subN = 0>
  </#if>
  <#assign d = (r.DaysDue)!0>
  <#assign p = "cur"><#if d gt 60><#assign p = "b3"><#elseif d gt 30><#assign p = "b2"><#elseif d gt 0><#assign p = "b1"></#if>
    <tr>
      <td>${r.DocumentNo!"-"}</td>
      <td><#if r.DateInvoiced??>${r.DateInvoiced?string('yyyy-MM-dd')}<#else>-</#if></td>
      <td><#if r.DueDate??>${r.DueDate?string('yyyy-MM-dd')}<#else>-</#if></td>
      <td class="num">${d?string["#,##0"]}</td>
      <td><span class="pill p-${p}"><#if d gt 0>${d?string["#,##0"]}d overdue<#else>current</#if></span></td>
      <td class="num">${((r.OpenAmt)!0)?string["#,##0.00"]}</td>
    </tr>
  <#assign sub = sub + ((r.OpenAmt)!0)><#assign subN = subN + 1>
<#else>
    <tr><td colspan="6">No open items.</td></tr>
</#list>
  <#if prevKey != -1>
    <tr class="sub"><td colspan="5">Subtotal (${subN})</td><td class="num">${sub?string["#,##0.00"]}</td></tr>
  </#if>
  </tbody>
  <tfoot>
    <tr><td colspan="5">Total Open ${cur}</td><td class="num">${grand?string["#,##0.00"]}</td></tr>
  </tfoot>
</table>
