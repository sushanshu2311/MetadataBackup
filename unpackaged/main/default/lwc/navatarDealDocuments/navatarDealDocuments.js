import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Document', fieldName: 'name',      type: 'text' },
    { label: 'Type',     fieldName: 'typeLabel', type: 'text', initialWidth: 100 },
    { label: 'Date',     fieldName: 'date',      type: 'text', initialWidth: 130 },
    { label: 'Source',   fieldName: 'from',      type: 'text', initialWidth: 170 },
    { label: 'Status',   fieldName: 'status',    type: 'text', initialWidth: 240 },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] } }
];

const DOCUMENTS = [
    // ── Received ─────────────────────────────────────────────────────────────
    {
        id: 'd1', source: 'received', typeLabel: 'External',
        name:   'Apex Care CIM',
        date:   '18 Feb 2026',
        from:   'Houlihan Lokey',
        status: 'Processed · 4-page analysis filed',
        detail: 'Received from Houlihan Lokey on 18 Feb 2026. CIM processed overnight. 4-page analysis filed covering business overview, financial profile (£38.2M revenue, £7.9M EBITDA), strategic context, and key considerations. Source of all financial data at this stage — management-provided, unaudited.',
    },
    {
        id: 'd2', source: 'received', typeLabel: 'External',
        name:   'Project Everest Teaser',
        date:   '03 Feb 2026',
        from:   'Houlihan Lokey',
        status: 'Processed',
        detail: 'Received from Michael Hartley, Houlihan Lokey on 3 Feb 2026. UK outpatient rehabilitation, 22 sites, £38M revenue. Criteria match confirmed against Ironwood investment parameters. Acknowledgment drafted and sent.',
    },
];

export default class NavatarDealDocuments extends LightningElement {
    @track activeFilter  = 'all';
    @track searchTerm    = '';
    @track selectedDoc   = null;

    columns   = COLUMNS;
    documents = DOCUMENTS;

    get filteredDocs() {
        let docs = this.activeFilter === 'all'
            ? this.documents
            : this.documents.filter(d => d.source === this.activeFilter);
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            docs = docs.filter(d =>
                d.name.toLowerCase().includes(s) ||
                d.from.toLowerCase().includes(s) ||
                d.status.toLowerCase().includes(s)
            );
        }
        return docs;
    }

    get fAll()         { return this.activeFilter === 'all'          ? 'brand' : 'neutral'; }
    get fReceived()    { return this.activeFilter === 'received'     ? 'brand' : 'neutral'; }
    get fAiGenerated() { return this.activeFilter === 'ai-generated' ? 'brand' : 'neutral'; }
    get fInternal()    { return this.activeFilter === 'internal'     ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.currentTarget.dataset.filter;
        this.selectedDoc  = null;
    }

    handleSearch(event) {
        this.searchTerm  = event.detail.value;
        this.selectedDoc = null;
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.selectedDoc = this.selectedDoc && this.selectedDoc.id === row.id ? null : row;
    }

    handleCloseDetail() {
        this.selectedDoc = null;
    }
}