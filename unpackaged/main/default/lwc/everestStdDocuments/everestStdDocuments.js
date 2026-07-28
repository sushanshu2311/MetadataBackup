import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Document', fieldName: 'name',   type: 'text', wrapText: true },
    { label: 'Source',   fieldName: 'srcTag', type: 'text', initialWidth: 130 },
    { label: 'Date',     fieldName: 'date',   type: 'text', initialWidth: 150 },
    { label: 'Details',  fieldName: 'meta',   type: 'text', initialWidth: 240 },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View summary', name: 'view' }] } },
];

const DOCS = [
    { id: 'd1', src: 'received',     srcTag: 'SharePoint',   name: 'Project Everest — Confidential Information Memorandum', date: '12 Feb 2026',      meta: 'PDF, 94 pages · Houlihan Lokey',
      summary: `Navatar Intelligence summary: The CIM presents Apex Care Partners as a market-leading UK outpatient rehabilitation business with strong NHS referral relationships. Key highlights include 22 clinic sites, $48M revenue, and a 21.6% EBITDA margin. The document emphasizes the defensibility of the NHS contract base but does not address CMS supervision compliance requirements introduced in Q4 2025.` },
    { id: 'd2', src: 'received',     srcTag: 'SharePoint',   name: 'Management Accounts — Q1 2026', date: '1 May 2026',         meta: 'Excel, 3 tabs · Apex Care Partners',
      summary: `Navatar Intelligence summary: Q1 management accounts confirm revenue of $11.9M (in line with FY run-rate of $48M) and EBITDA of $2.5M. Guildford site shows a 4% revenue decline versus Q4 2025 which warrants monitoring given the CMS supervision gap identified in Dr. Webb's report.` },
    { id: 'd3', src: 'received',     srcTag: 'Navatar',      name: 'Regulatory Due Diligence Report — Dr. M. Webb', date: '18 Jun 2026 08:47', meta: 'PDF, 47 pages · Webb Regulatory Advisory',
      summary: `Navatar Intelligence summary: Dr. Webb's report identifies a material CMS supervision compliance gap affecting three clinic sites (Guildford, Brighton, Reading). Page 18 details that the revised NHS supervision ratio (1:8 to 1:6) requires additional qualified supervisors at all three sites. Estimated remediation cost: $0.4M capex plus $1.0M annualized opex. Revenue at risk if non-compliant by Q3 2026: $5.2M. This finding is not yet reflected in the financial model or any deal notes.` },
    { id: 'd4', src: 'received',     srcTag: 'Navatar',      name: 'Financial Due Diligence Model v3 — L.E.K. Consulting', date: '16 Jun 2026',       meta: 'Excel, 12 tabs · L.E.K. Consulting',
      summary: `Navatar Intelligence summary: L.E.K.'s v3 model confirms normalized EBITDA of $10.5M after adjusting for one-off costs and management remuneration. The model does not yet incorporate the CMS compliance remediation costs identified in Dr. Webb's report. Entry multiple range of 11–13× EBITDA implies an enterprise value of $114–135M.` },
    { id: 'd5', src: 'ai-generated', srcTag: 'AI Generated', name: 'Legal DD Draft — Kirkland & Ellis (AI Summary)', date: '17 Jun 2026',       meta: 'Report · Navatar Intelligence',
      summary: `Navatar Intelligence summary: AI-generated summary based on available correspondence. Kirkland & Ellis's legal DD is overdue — the formal report was expected 16 June and has not been received. Based on the DD kick-off call transcript and email correspondence, key areas under review include employment contracts (Mark Hargreaves and 3 senior physios), NHS contract assignment provisions, and property leases across all 22 sites. The absence of the formal report is a risk given the 18 June management meeting.` },
];

export default class EverestStdDocuments extends LightningElement {
    @track activeFilter = 'all';
    @track searchTerm = '';
    @track selectedDoc = null;

    columns = COLUMNS;
    docs = DOCS;

    get filteredDocs() {
        let rows = this.docs;
        if (this.activeFilter !== 'all') {
            rows = rows.filter(d => d.src === this.activeFilter);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(d => d.name.toLowerCase().includes(s));
        }
        return rows;
    }

    get fAll()      { return this.activeFilter === 'all'          ? 'brand' : 'neutral'; }
    get fReceived() { return this.activeFilter === 'received'     ? 'brand' : 'neutral'; }
    get fAi()       { return this.activeFilter === 'ai-generated' ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.target.dataset.filter;
        this.selectedDoc = null;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
        this.selectedDoc = null;
    }

    handleRowAction(event) {
        this.selectedDoc = event.detail.row;
    }

    handleCloseDetail() {
        this.selectedDoc = null;
    }
}