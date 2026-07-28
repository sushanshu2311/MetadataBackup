import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Deal',     fieldName: 'deal',     type: 'text' },
    { label: 'Sector',   fieldName: 'sector',   type: 'text' },
    { label: 'Revenue',  fieldName: 'revenue',  type: 'text', initialWidth: 110 },
    { label: 'Multiple', fieldName: 'multiple', type: 'text', initialWidth: 110 },
    { label: 'Outcome',  fieldName: 'outcome',  type: 'text' },
    { label: 'Match',    fieldName: 'match',    type: 'text', initialWidth: 100 },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] } },
];

const DEALS = [
    { id: 's1', deal: 'Project Lighthouse', region: 'UK Healthcare Services', sector: 'Outpatient Rehab',        revenue: '$53M', multiple: '12×',  outcome: 'Won · Closed',    match: '94%',
      detail: `Project Lighthouse was an Ironwood Capital acquisition of a UK outpatient rehabilitation business ($53M revenue, 12× EBITDA entry multiple) completed in Q3 2024. Key parallels with Project Everest: NHS contract dependency, single founder-CEO, CQC-regulated sites. Lessons: (1) Written retention package for CEO agreed before exclusivity — critical given NHS relationship concentration. (2) Regulatory DD uncovered compliance gaps at 2 sites post-exclusivity — remediation cost factored into price chip. (3) Advent International was also in the final round on Lighthouse and dropped out at LOI stage.` },
    { id: 's2', deal: 'Project Beacon',     region: 'UK Healthcare Services', sector: 'Outpatient Rehab',        revenue: '$35M', multiple: '9.5×', outcome: 'Lost · LOI Stage', match: '88%',
      detail: `Project Beacon was a contested process for a UK outpatient rehab business ($35M revenue, 9.5× entry multiple). Ironwood lost at LOI stage to a strategic buyer who paid a 15% premium over the PE range. Key learnings applicable to Project Everest: (1) NHS referral relationship concentration was the central diligence issue — Ironwood's model penalised the lack of written management incentives. (2) The strategic buyer moved faster on management retention terms. This reinforces the urgency of written terms with Mark Hargreaves.` },
    { id: 's3', deal: 'Project Atlas',      region: 'UK Healthcare Services', sector: 'Allied Health Services',  revenue: '$44M', multiple: '11×',  outcome: 'Won · Closed',    match: '81%',
      detail: `Project Atlas was an Ironwood Capital acquisition of a UK allied health services business ($44M revenue, 11× EBITDA entry multiple) completed in Q1 2025. Parallels with Project Everest: similar revenue and margin profile, NHS contract base, multi-site. The main difference: Atlas had CQC compliance fully evidenced in the data room. The CMS supervision gap on Everest is a more complex regulatory issue than Atlas faced.` },
];

export default class EverestStdSimilarDeals extends LightningElement {
    @track searchTerm = '';
    @track selectedDeal = null;

    columns = COLUMNS;
    deals = DEALS;

    get filteredDeals() {
        if (!this.searchTerm) return this.deals;
        const s = this.searchTerm.toLowerCase();
        return this.deals.filter(d =>
            d.deal.toLowerCase().includes(s) ||
            d.sector.toLowerCase().includes(s)
        );
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
        this.selectedDeal = null;
    }

    handleRowAction(event) {
        this.selectedDeal = event.detail.row;
    }

    handleCloseDetail() {
        this.selectedDeal = null;
    }
}