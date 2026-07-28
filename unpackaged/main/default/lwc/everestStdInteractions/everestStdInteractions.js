import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Date',         fieldName: 'date',    type: 'text', initialWidth: 150 },
    { label: 'Subject',      fieldName: 'subject', type: 'text', wrapText: true },
    { label: 'Participants', fieldName: 'parts',   type: 'text', initialWidth: 130 },
    { label: 'Type',         fieldName: 'type',    type: 'text', initialWidth: 100 },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] } },
];

const INTERACTIONS = [
    { id: 'i1', itype: 'email',   date: '18 Jun 2026 09:05', subject: 'RE: Dr. Webb Regulatory Report — CMS Findings', parts: 'MH · TB',      type: 'Email',
      raw: `From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett &lt;tbennett@ironwoodcap.com&gt;<br>Date: 18 Jun 2026 09:05<br><br>Thomas,<br><br>Thanks for reviewing the report. The supervision gap on page 18 is significant — I'd recommend getting Kirkland to look at this before the management meeting. Mark hasn't been briefed on the finding yet from our side.<br><br>Let me know if you want to jump on a call this afternoon.<br><br>Best,<br>Michael` },
    { id: 'i2', itype: 'meeting', date: '12 Jun 2026',       subject: 'Management Presentation — Apex Care Partners',    parts: 'TB · SP · MH', type: 'Meeting',
      raw: `[Vinton Transcript — Management Presentation · 12 Jun 2026 · 10:00–12:30]<br><br>0:00:12 Mark Hargreaves: Good morning everyone. Thank you for making the trip to Guildford. I'd like to start with a brief overview of where Apex Care has come from before handing to our CFO.<br><br>0:12:44 Thomas Bennett: Mark, can you talk us through your NHS referral relationships — specifically how dependent the business is on the Guildford CCG contracts?<br><br>0:13:22 Mark Hargreaves: The Guildford CCG relationship is our most mature — we've held that contract for 11 years. We have similar long-standing relationships across 14 of our 22 sites.<br><br>0:43:01 Mark Hargreaves: I'm committed to the business for the long term. The right partner is more important to me than the economics at this stage.` },
    { id: 'i3', itype: 'email',   date: '16 Jun 2026',       subject: 'Project Everest — Financial Model v3',            parts: 'DR · TB',      type: 'Email',
      raw: `From: David Ross &lt;d.ross@lek.com&gt;<br>To: Thomas Bennett; Sarah Patel<br>Date: 16 Jun 2026<br><br>Thomas, Sarah,<br><br>Model v3 attached. Key changes:<br>– Normalized EBITDA confirmed at $10.5M (21.9% margin)<br>– Adjusted for one-off legal costs in FY25 ($0.5M)<br>– Management remuneration adjustment ($0.3M)<br><br>Note: model does not yet include CMS remediation scenarios. Please advise.<br><br>David` },
    { id: 'i4', itype: 'call',    date: '10 Jun 2026',       subject: 'DD Kick-off Call — L.E.K. & Kirkland',            parts: 'TB · DR · SC', type: 'Call',
      raw: `[Vinton Transcript — DD Kick-off Call · 10 Jun 2026 · 09:00–10:15]<br><br>0:00:08 Thomas Bennett: Good morning. Before we kick off I want to flag the timeline. DD closes 28 June, management meeting 18 June. David, Sandra — we'll need key outputs by 20 June at the latest.<br><br>0:08:33 David Ross: Noted. L.E.K. will focus on revenue quality and EBITDA normalization first. Draft model by 16 June.<br><br>0:09:47 Sandra Chen: Kirkland will prioritise employment contracts and NHS assignment provisions. Hargreaves contract first.<br><br>0:41:22 Sarah Patel: The data room doesn't include compliance certificates. Is that normal for this type of process?<br><br>0:42:01 Sandra Chen: Good spot Sarah — I'll raise that with the data room team.` },
    { id: 'i5', itype: 'email',   date: '11 Jun 2026',       subject: 'Project Everest — Process Letter',                parts: 'MH · TB',      type: 'Email',
      raw: `From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett<br>Date: 11 Jun 2026<br><br>Thomas,<br><br>Please find the formal process letter for Project Everest. Key dates:<br>– Management presentation: 12 June<br>– Final bids: 28 June, 12:00 noon<br>– Exclusivity decision: w/c 30 June<br><br>Three bidders in final round: Ironwood Capital, Advent International, and one undisclosed party.<br><br>Best,<br>Michael` },
];

export default class EverestStdInteractions extends LightningElement {
    @track activeFilter = 'all';
    @track searchTerm = '';
    @track selectedItem = null;

    columns = COLUMNS;
    interactions = INTERACTIONS;

    get filteredInteractions() {
        let rows = this.interactions;
        if (this.activeFilter !== 'all') {
            rows = rows.filter(i => i.itype === this.activeFilter);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(i => i.subject.toLowerCase().includes(s));
        }
        return rows;
    }

    get fAll()     { return this.activeFilter === 'all'     ? 'brand' : 'neutral'; }
    get fEmail()   { return this.activeFilter === 'email'   ? 'brand' : 'neutral'; }
    get fCall()    { return this.activeFilter === 'call'    ? 'brand' : 'neutral'; }
    get fMeeting() { return this.activeFilter === 'meeting' ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.target.dataset.filter;
        this.selectedItem = null;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
        this.selectedItem = null;
    }

    handleRowAction(event) {
        this.selectedItem = event.detail.row;
    }

    handleCloseDetail() {
        this.selectedItem = null;
    }
}