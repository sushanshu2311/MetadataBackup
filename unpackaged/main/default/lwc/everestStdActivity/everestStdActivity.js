import { LightningElement, track } from 'lwc';

const FEED = [
    { id: 'gap1',   cat: 'insights',       badge: 'Insights',          title: 'Claude detected a gap — CMS supervision risk not in deal notes', date: '18 Jun 2026', meta: '18 Jun 2026 09:14 · AI Detected',
      body: `The CMS supervision requirement change identified on page 18 of <a href="#">Dr. Webb</a>'s report does not appear in any deal notes, activity records, or open tasks.<br><br>Revenue exposure: <strong>$5.2M across 3 clinic sites</strong> (Guildford, Brighton, Reading). Remediation cost estimate: $0.4M capex + $1.0M annualized opex. This exposure must be reflected in the <a href="#">L.E.K. Consulting</a> financial model before the 28 June bid submission. The 18 June management meeting with <a href="#">Apex Care Partners</a> makes legal instruction to <a href="#">Kirkland &amp; Ellis</a> today time-critical.` },
    { id: 'ai1',    cat: 'recommendation', badge: 'AI Recommendation', title: 'Instruct Kirkland & Ellis on CMS gap before 18 June management meeting', date: '18 Jun 2026', meta: '18 Jun 2026 09:14 · Navatar Intelligence',
      body: `Immediate action required: instruct <a href="#">Kirkland &amp; Ellis</a> to address the CMS supervision gap identified in <a href="#">Dr. Webb</a>'s report before the 18 June management meeting.<br><br>The gap affects sites in Guildford, Brighton, and Reading ($5.2M revenue). <a href="#">Sandra Chen</a> has not yet been briefed on this finding — the DD kick-off call on 10 June predates the report. Recommended action: send the Webb report to Sandra Chen today and request an addendum to the legal DD scope covering CMS compliance obligations.` },
    { id: 'ai2',    cat: 'recommendation', badge: 'AI Recommendation', title: 'Request written retention terms from Mark Hargreaves — Advent contact confirmed', date: '18 Jun 2026', meta: '18 Jun 2026 08:45 · Navatar Intelligence',
      body: `<a href="#">Mark Hargreaves</a> has made 3 LinkedIn connections with <a href="#">Advent International</a> team members in the past 10 days. His retention is critical — he controls 14 of 22 NHS referral relationships.<br><br>Verbal commitment given at the 12 June management presentation is insufficient. Written terms should be agreed before the management meeting on 18 June. Warm path: <a href="#">Robert Ashford</a> (NED) has known Hargreaves for 8 years and may be able to facilitate — he was introduced by <a href="#">Michael Hartley</a> at the 2022 process.` },
    { id: 'ai3',    cat: 'recommendation', badge: 'AI Recommendation', title: 'Update financial model — add $5.2M CMS exposure to scenario analysis', date: '18 Jun 2026', meta: '18 Jun 2026 09:00 · Navatar Intelligence',
      body: `The <a href="#">L.E.K. Consulting</a> financial model (v3, received 16 June) does not include the CMS remediation costs identified in <a href="#">Dr. Webb</a>'s report.<br><br>Required additions: $0.4M capex (one-off), $1.0M p.a. opex, and a revenue sensitivity scenario showing the $5.2M downside if non-compliant by Q3 2026. <a href="#">Sarah Patel</a> should coordinate the model update with <a href="#">David Ross</a> at L.E.K. before the bid submission.` },
    { id: 'news1',  cat: 'news',           badge: 'News',              title: 'NHS CMS outpatient supervision policy change — effective Q3 2026', date: '18 Jun 2026', meta: '18 Jun 2026 07:30 · NHS England',
      body: `<a href="#">NHS England</a> published updated CMS outpatient supervision guidance on 18 June 2026, effective Q3 2026. The revised ratio (1:6 from 1:8) will require additional qualified supervisors at outpatient facilities with more than 150 patient contacts per week.<br><br><a href="#">Apex Care Partners</a>' three largest sites (Guildford, Brighton, Reading) all exceed this threshold. This guidance is directly relevant to the gap identified in <a href="#">Dr. Webb</a>'s regulatory report.` },
    { id: 'email1', cat: 'email',          badge: 'Email',             title: 'RE: Project Everest — Dr. Webb Regulatory Report', date: '17 Jun 2026', meta: '17 Jun 2026 16:42 · Michael Hartley → Thomas Bennett',
      body: `From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett &lt;tbennett@ironwoodcap.com&gt;<br>Date: 17 Jun 2026 16:42<br><br>Thomas,<br><br>Please find attached Dr. Webb's regulatory report, received from the <a href="#">Apex Care Partners</a> data room today. I wanted to flag page 18 specifically — the CMS supervision section raises some questions that may need to go back to management before the 18 June meeting.<br><br>Happy to jump on a call if useful.<br><br>Best,<br>Michael` },
    { id: 'meet1',  cat: 'meeting',        badge: 'Meeting',           title: 'Management Presentation — Apex Care Partners', date: '12 Jun 2026', meta: '12 Jun 2026 · James Walker, Thomas Bennett, Michael Hartley, Mark Hargreaves, Sarah Chen',
      body: `[Vinton transcript — 12 Jun 2026, 10:00–12:30]<br><br>0:00:12 Mark Hargreaves: Good morning everyone, thank you for making the trip to Guildford. I'd like to start with a brief overview of where Apex Care has come from before handing over to our CFO for the financial walk-through.<br><br>0:12:44 Thomas Bennett: Mark, can you talk us through your NHS referral relationships — specifically how dependent the business is on the Guildford CCG contracts?<br><br>0:13:22 Mark Hargreaves: The Guildford CCG relationship is our most mature — we've held that contract for 11 years. I personally maintain the relationship with the CCG lead. We have similar long-standing relationships across 14 of our 22 sites.<br><br>0:42:15 Thomas Bennett: And in terms of continuity post-transaction — have you given thought to your own position?<br><br>0:43:01 Mark Hargreaves: I'm committed to the business for the long term. The right partner is more important to me than the economics at this stage.` },
    { id: 'di1',    cat: 'insights',       badge: 'Insights',          title: 'Bidder intelligence — Advent International bid team confirmed via LinkedIn', date: '17 Jun 2026', meta: '17 Jun 2026 · AI Detected',
      body: `James Wren (Associate, Healthcare PE) at <a href="#">Advent International</a> connected with two <a href="#">Apex Care Partners</a> board members and Kate Patterson at <a href="#">Houlihan Lokey</a> on LinkedIn within the past 7 days.<br><br>This confirms Advent's active presence on the <a href="#">Project Everest</a> process. Advent increased their UK healthcare PE allocation by 40% in Q1 2026 (see News). Their typical entry multiple in this sector is 11–14× EBITDA, making them a credible bidder at the current price range.` },
    { id: 'email2', cat: 'email',          badge: 'Email',             title: 'Project Everest — Financial Model v3 from L.E.K.', date: '16 Jun 2026', meta: '16 Jun 2026 · David Ross → Thomas Bennett, Sarah Patel',
      body: `From: David Ross &lt;d.ross@lek.com&gt;<br>To: Thomas Bennett; Sarah Patel<br>Date: 16 Jun 2026<br><br>Thomas, Sarah,<br><br>Please find attached financial model v3. Key changes from v2:<br>– Normalized EBITDA confirmed at $10.5M (21.9% margin)<br>– Adjusted for one-off legal costs in FY25 ($0.5M)<br>– Management remuneration adjustment ($0.3M) confirmed with <a href="#">Apex Care Partners</a> CFO<br><br>Note: model does not yet include any CMS remediation scenarios. Please advise if you need these modelled separately.<br><br>David` },
    { id: 'news2',  cat: 'news',           badge: 'News',              title: 'Advent International increases UK healthcare PE allocation by 40%', date: '15 Jun 2026', meta: '15 Jun 2026 · Healthcare Investor',
      body: `<a href="#">Advent International</a> announced a 40% increase to their UK healthcare private equity allocation in their Q1 2026 investor update, with a particular focus on outpatient and community care assets. The firm cited the NHS's continuing outsourcing program and demographic tailwinds as the primary drivers.<br><br>This signals Advent will be aggressive on <a href="#">Project Everest</a>. Their healthcare team has been strengthened with two new hires from Bridgepoint in Q4 2025.` },
    { id: 'di2',    cat: 'insights',       badge: 'Insights',          title: 'Mark Hargreaves LinkedIn activity — 3 connections to Advent International in past 10 days', date: '16 Jun 2026', meta: '16 Jun 2026 · AI Detected',
      body: `<a href="#">Mark Hargreaves</a> made LinkedIn connections with 3 <a href="#">Advent International</a> team members on 8, 12, and 14 June 2026 — including James Wren (Associate) and the Advent Healthcare PE Partner.<br><br>This pattern suggests Hargreaves is conducting his own parallel evaluation of Advent as a potential acquirer. Given his control of 14 NHS referral relationships, this is a material retention risk. Recommended action: accelerate written retention term discussions.` },
    { id: 'meet2',  cat: 'meeting',        badge: 'Meeting',           title: 'DD Kick-off — L.E.K. Consulting & Kirkland & Ellis', date: '10 Jun 2026', meta: '10 Jun 2026 · Thomas Bennett, Sarah Patel, David Ross, Sandra Chen',
      body: `[Vinton transcript — 10 Jun 2026, 09:00–10:15]<br><br>0:00:08 Thomas Bennett: Good morning everyone. Before we kick off I want to flag the timeline. We're in DD until 28 June, management meeting on 18 June. David, Sandra — we'll need the key outputs by 20 June at the latest.<br><br>0:08:33 David Ross: Noted. L.E.K. will focus on revenue quality and EBITDA normalization first. We'll have a draft model by 16 June.<br><br>0:09:47 Sandra Chen: Kirkland will prioritise employment contracts and NHS assignment provisions. The Hargreaves contract will be the first thing we review.<br><br>0:41:22 Sarah Patel: One thing I wanted to flag — the data room doesn't include any compliance certificates. Is that normal for this type of process?` },
    { id: 'di3',    cat: 'insights',       badge: 'Insights',          title: 'Guildford CCG referral volume — 3-month downward trend flagged', date: '14 Jun 2026', meta: '14 Jun 2026 · AI Detected',
      body: `Guildford CCG referral volume to <a href="#">Apex Care Partners</a>' Guildford site has declined 6% over the past 3 months, based on publicly available CCG reporting data.<br><br>This is the highest-revenue single site (approx. $6.1M p.a.). A continued decline would compound the CMS remediation risk already identified for this location. The Q1 management accounts show a 4% revenue decline at this site versus Q4 2025, consistent with the CCG referral trend.` },
    { id: 'email3', cat: 'email',          badge: 'Email',             title: 'Project Everest — Process Letter from Houlihan Lokey', date: '11 Jun 2026', meta: '11 Jun 2026 · Michael Hartley → Thomas Bennett',
      body: `From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett<br>Date: 11 Jun 2026<br><br>Thomas,<br><br>Please find attached the formal process letter for <a href="#">Project Everest</a>. Key dates:<br>– Management presentation: 12 June<br>– Final bids: 28 June, 12:00 noon<br>– Exclusivity decision: w/c 30 June<br><br>Three bidders in the final round: Ironwood Capital, <a href="#">Advent International</a>, and one undisclosed party.<br><br>Best,<br>Michael` },
    { id: 'ai4',    cat: 'recommendation', badge: 'AI Recommendation', title: 'Engage Robert Ashford — NED influence on Hargreaves retention material', date: '15 Jun 2026', meta: '15 Jun 2026 · Navatar Intelligence',
      body: `<a href="#">Robert Ashford</a> (Non-Executive Director, <a href="#">Apex Care Partners</a>) has an 8-year relationship with <a href="#">Mark Hargreaves</a> and sits on the Apex Care board.<br><br>He is well-positioned to facilitate the retention conversation given his independence from both management and bidders. He is an existing Navatar contact (introduced via <a href="#">Michael Hartley</a> at the 2022 HL process) — an outreach request via Hartley would be appropriate. Recommended: ask Hartley to request a 20-minute call between Ashford and Thomas Bennett before 20 June.` },
    { id: 'di4',    cat: 'insights',       badge: 'Insights',          title: 'L.E.K. EBITDA normalization confirmed at $10.5M — model updated', date: '13 Jun 2026', meta: '13 Jun 2026 · AI Detected',
      body: `<a href="#">L.E.K. Consulting</a> confirmed EBITDA normalization at $10.5M following review of management remuneration and one-off items in FY25.<br><br>This supersedes the CIM figure of $10.0M. At the bid range of 11–13× EBITDA, the normalized figure implies EV of $114–135M. The CMS remediation cost ($1.0M p.a. opex) would reduce normalized EBITDA to $9.4M if fully loaded, implying a restated EV range of $103–122M at the same multiple range.` },
    { id: 'news3',  cat: 'news',           badge: 'News',              title: 'UK outpatient rehab M&A activity — Q2 2026 review', date: '12 Jun 2026', meta: '12 Jun 2026 · Healthcare Finance',
      body: `UK outpatient rehabilitation M&A activity reached a 5-year high in Q2 2026, driven by NHS outsourcing and post-COVID backlog recovery. Four transactions completed above 11× EBITDA in the quarter.<br><br>Healthcare-focused PE firms including <a href="#">Advent International</a>, Bridgepoint, and IK Partners were all active. The trend supports the upper end of the 11–13× entry multiple range being discussed for <a href="#">Project Everest</a>.` },
    { id: 'meet3',  cat: 'meeting',        badge: 'Meeting',           title: 'Introductory Call — Apex Care Partners Management Team', date: '9 Jun 2026', meta: '9 Jun 2026 · Thomas Bennett, Michael Hartley, Mark Hargreaves',
      body: `[Vinton transcript — 9 Jun 2026, 15:00–16:00]<br><br>0:01:33 Thomas Bennett: Mark, thanks for making the time. We've reviewed the CIM in detail and we're very interested in the business. Can you walk us through your vision for the next 3–5 years?<br><br>0:02:44 Mark Hargreaves: Absolutely. We see significant whitespace in the South East — potentially 8 additional sites within 5 years. The NHS outsourcing trend is accelerating and our referral relationships give us first-mover advantage in most of our geographies.<br><br>0:38:12 Michael Hartley: Mark, shall we move on to the financial walk-through?<br><br>0:38:30 Mark Hargreaves: Of course.` },
    { id: 'email4', cat: 'email',          badge: 'Email',             title: 'Project Everest — CIM received from Houlihan Lokey', date: '5 Jun 2026', meta: '5 Jun 2026 · Michael Hartley → Thomas Bennett',
      body: `From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett<br>Date: 5 Jun 2026<br><br>Thomas,<br><br>Please find attached the CIM for Project Everest (<a href="#">Apex Care Partners</a>). Ironwood has been invited into the final round alongside two other parties.<br><br>This is a strong asset — market-leading position in outpatient rehab with highly defensible NHS contracts. The management team are excellent and <a href="#">Mark Hargreaves</a> has confirmed he would stay on under the right ownership.<br><br>Data room access details to follow.<br>Michael` },
];

export default class EverestStdActivity extends LightningElement {
    @track activeFilter = 'all';
    @track searchTerm = '';
    @track openId = null;

    feed = FEED;

    get filteredFeed() {
        let rows = this.feed;
        if (this.activeFilter !== 'all') {
            rows = rows.filter(i => i.cat === this.activeFilter);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(i => i.title.toLowerCase().includes(s));
        }
        return rows;
    }

    // add inline-expand state + chevron icon per item
    get decoratedFeed() {
        return this.filteredFeed.map(i => ({
            ...i,
            isOpen: i.id === this.openId,
            iconName: i.id === this.openId ? 'utility:chevrondown' : 'utility:chevronright',
        }));
    }

    get fAll()            { return this.activeFilter === 'all'            ? 'brand' : 'neutral'; }
    get fEmail()          { return this.activeFilter === 'email'          ? 'brand' : 'neutral'; }
    get fMeeting()        { return this.activeFilter === 'meeting'        ? 'brand' : 'neutral'; }
    get fInsights()       { return this.activeFilter === 'insights'       ? 'brand' : 'neutral'; }
    get fNews()           { return this.activeFilter === 'news'           ? 'brand' : 'neutral'; }
    get fRecommendation() { return this.activeFilter === 'recommendation' ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.target.dataset.filter;
        this.openId = null;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
        this.openId = null;
    }

    toggleItem(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? null : id;
    }

    handleKey(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            this.toggleItem(event);
        }
    }
}