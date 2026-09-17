<#-- Sales Order — Presentation. C_Order (IsForm='Y'): cover + about page + proposal. -->
<#assign taxTotal = 0>
<#list taxes as t><#assign taxTotal = taxTotal + (t.TaxAmt)!0></#list>
<#assign cur = (C_Currency_ID.display)!"">
<#assign brand = ctx.client_name!"Garden World">
<style>
  @page { size: A4; margin: 0; }
  * { box-sizing: border-box; }
  body { font-family: sans-serif; color: #263238; margin: 0; font-size: 10.5pt; line-height: 1.5; }

  /* ---- Cover (full page) ---- */
  .cover { height: 297mm; background: #1b5e20; color: #fff; padding: 32mm 26mm; page-break-after: always; }
  .cover .eyebrow { color: #a5d6a7; text-transform: uppercase; letter-spacing: 4px; font-size: 10pt; }
  .cover .brand { font-size: 44pt; font-weight: bold; letter-spacing: 1px; margin: 4mm 0 2mm; }
  .cover .tagline { color: #c8e6c9; font-size: 13pt; }
  .cover .rule { width: 40mm; height: 3px; background: #66bb6a; margin: 10mm 0; }
  .client { background: #ffffff; color: #263238; padding: 8mm; width: 105mm; }
  .client h4 { margin: 0 0 3mm; color: #1b5e20; text-transform: uppercase; letter-spacing: 1px; font-size: 9pt; }
  .client .name { font-size: 16pt; font-weight: bold; }
  .client table { width: 100%; margin-top: 4mm; }
  .client td { border: 0; padding: 1.2mm 0; font-size: 9.5pt; }
  .client .k { color: #78909c; width: 42%; }
  .cover .foot { margin-top: 16mm; color: #a5d6a7; font-size: 9pt; }

  /* ---- Content pages ---- */
  .page { padding: 24mm 22mm; page-break-after: always; }
  .page.last { page-break-after: auto; }
  h2 { color: #1b5e20; font-size: 20pt; margin: 0 0 2mm; }
  .lead { color: #66738a; font-size: 12pt; margin-bottom: 8mm; }
  p { margin: 0 0 4mm; }

  .pillars { width: 100%; border-collapse: separate; border-spacing: 4mm 0; margin-top: 6mm; }
  .pillars td { width: 33%; vertical-align: top; background: #e8f5e9; border-top: 3px solid #43a047;
    padding: 6mm 5mm; border-radius: 0; }
  .pillars h3 { margin: 0 0 2mm; color: #1b5e20; font-size: 11pt; }
  .pillars p { font-size: 9.5pt; color: #52606d; margin: 0; }

  table.items { width: 100%; border-collapse: collapse; margin-top: 4mm; }
  table.items th { background: #1b5e20; color: #fff; padding: 3mm; text-align: left; font-size: 8.5pt;
    text-transform: uppercase; letter-spacing: .5px; }
  table.items td { padding: 3mm; border-bottom: 1px solid #e0e0e0; }
  table.items tr.alt td { background: #f5f7f5; }
  .num { text-align: right; white-space: nowrap; }
  .totbox { width: 78mm; margin-left: auto; margin-top: 7mm; border-collapse: collapse; }
  .totbox td { padding: 2.4mm 4mm; border: 0; }
  .totbox .lbl { color: #607d8b; }
  .totbox .grand td { background: #1b5e20; color: #fff; font-size: 13pt; font-weight: bold; }
  .cond { margin-top: 10mm; }
  .cond table { width: 100%; }
  .cond td { border: 0; vertical-align: top; width: 50%; padding: 0 6mm 4mm 0; }
  .cond .k { color: #1b5e20; font-weight: bold; font-size: 9pt; text-transform: uppercase; letter-spacing: .5px; }
</style>

<#-- ================= PAGE 1 — COVER ================= -->
<div class="cover">
  <div class="eyebrow">Commercial Proposal</div>
  <div class="brand">${brand}</div>
  <div class="tagline">Everything your garden needs — grown with care.</div>
  <div class="rule"></div>

  <div class="client">
    <h4>Prepared for</h4>
    <div class="name">${(C_BPartner_ID.display)!"-"}</div>
    <table>
      <tr><td class="k">Location</td><td>${(C_BPartner_Location_ID.display)!"-"}</td></tr>
      <tr><td class="k">Order</td><td>#${DocumentNo!"-"}</td></tr>
      <tr><td class="k">Date</td><td><#if DateOrdered??>${DateOrdered?string('MMMM d, yyyy')}<#else>-</#if></td></tr>
      <tr><td class="k">Sales Rep</td><td>${(SalesRep_ID.display)!"-"}</td></tr>
    </table>
  </div>

  <div class="foot">${brand} &middot; Prepared ${(ctx.now?string('MMMM d, yyyy'))!""}</div>
</div>

<#-- ================= PAGE 2 — ABOUT ================= -->
<div class="page">
  <h2>About ${brand}</h2>
  <div class="lead">Growing partnerships since day one.</div>

  <p>For over three decades, ${brand} has helped gardeners, farms and commercial
  growers turn bare soil into thriving landscapes. What began as a single neighborhood
  nursery is today a full-line supplier of plants, seeds, tools, irrigation and
  landscaping solutions — trusted by hobbyists and professionals alike.</p>

  <p>Our catalog spans everything from heirloom seeds and nursery-grown stock to
  professional-grade tools, soils, fertilizers and irrigation systems. Each item is
  selected by people who garden themselves, so you get products that actually perform
  in the field — not just on the shelf.</p>

  <p>We believe great gardens and responsible growing go hand in hand. That is why we
  source locally wherever possible, favor organic and peat-free options, and back every
  order with expert advice and dependable delivery. When you order from ${brand}, you
  get a partner invested in what you grow next.</p>

  <table class="pillars">
    <tr>
      <td>
        <h3>Quality</h3>
        <p>Hand-picked nursery stock and professional tools, chosen by growers for growers.</p>
      </td>
      <td>
        <h3>Sustainability</h3>
        <p>Locally sourced, organic and peat-free options that respect the land.</p>
      </td>
      <td>
        <h3>Service</h3>
        <p>Expert guidance and reliable delivery, from first seed to full harvest.</p>
      </td>
    </tr>
  </table>
</div>

<#-- ================= PAGE 3 — PROPOSAL ================= -->
<div class="page last">
  <h2>Your Proposal</h2>
  <div class="lead">Order #${DocumentNo!"-"} — products &amp; commercial conditions.</div>

  <table class="items">
    <thead>
      <tr><th>#</th><th>Product</th><th class="num">Qty</th><th class="num">Unit Price</th><th class="num">Amount</th></tr>
    </thead>
    <tbody>
<#list lines as l>
      <tr<#if l?index % 2 == 1> class="alt"</#if>>
        <td>${l.Line!"-"}</td>
        <td><#if (l.M_Product_ID)??>${(l.M_Product_ID.display)!"-"}<#else>${l.Description!"-"}</#if></td>
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

  <div class="cond">
    <table>
      <tr>
        <td><div class="k">Payment Term</div>${(C_PaymentTerm_ID.display)!"-"}</td>
        <td><div class="k">Currency</div>${cur}</td>
      </tr>
      <tr>
        <td><div class="k">Delivery</div>${(C_BPartner_Location_ID.display)!"As agreed"}</td>
        <td><div class="k">Proposal Validity</div>30 days from issue date</td>
      </tr>
    </table>
  </div>
</div>
