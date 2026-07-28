import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Deal',           fieldName: 'deal',     type: 'text', initialWidth: 160 },
    { label: 'Company',        fieldName: 'company',  type: 'text', initialWidth: 180 },
    { label: 'Sector',         fieldName: 'sector',   type: 'text', initialWidth: 160 },
    { label: 'Revenue',             fieldName: 'ev',       type: 'text', initialWidth: 120  },
    { label: 'Multiple',       fieldName: 'multiple', type: 'text', initialWidth: 120  },
    // { label: 'Year',           fieldName: 'year',     type: 'text', initialWidth: 70  },
    { label: 'Outcome',      fieldName: 'relevance',type: 'text' },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] } }
];

const DEALS = [
    {
        id: 'sim1',
        deal:      'Project Lighthouse',
        company:   'BrightPath Health',
        sector:    'Healthcare Services',
        ev:        '£84M',
        multiple:  '11.5×',
        year:      '2023',
        source:    'Houlihan Lokey',
        relevance: 'Direct — same banker, same sector, same geography',
        detail:    'BrightPath Health — healthcare services provider. Sold via Houlihan Lokey in 2023. Direct comparable: same banker running the Project Everest process, same sector, same UK geography. Entry multiple of 11.5× sits at the lower end of the 11–13× indicative range for Project Everest.',
    },
    {
        id: 'sim2',
        deal:      'Project Cedar',
        company:   'CommuniCare Group',
        sector:    'Community Care',
        ev:        '£62M',
        multiple:  '10.8×',
        year:      '2022',
        source:    'Canaccord',
        relevance: 'Similar NHS/self-pay mix',
        detail:    'CommuniCare Group — community care provider with a comparable NHS/self-pay revenue mix. Sold via Canaccord in 2022 at 10.8×. Note: Graphite Capital has just acquired a majority stake in CommuniCare (19 Feb 2026) — confirms continued PE appetite for this sector and sets a current market reference point.',
    },
    {
        id: 'sim3',
        deal:      'Project Falcon',
        company:   'MedServices UK',
        sector:    'Outpatient Services',
        ev:        '£115M',
        multiple:  '13.2×',
        year:      '2024',
        source:    'Rothschild',
        relevance: 'Upper end of range — premium for growth',
        detail:    'MedServices UK — outpatient services. Sold via Rothschild in 2024 at 13.2×. Represents the upper end of the indicative entry multiple range for Project Everest. Premium driven by above-market revenue growth profile — comparable to Apex Care\'s 13–15% CAGR.',
    },
    {
        id: 'sim4',
        deal:      'Project Alto',
        company:   'Meridian Health',
        sector:    'Healthcare Services',
        ev:        '£71M',
        multiple:  '11.0×',
        year:      '2023',
        source:    'Lincoln International',
        relevance: 'Regulatory precedent — CQC event at DD',
        detail:    'Meridian Health — healthcare services. Sold via Lincoln International in 2023 at 11.0×. Key precedent: a CQC inspection event arose during due diligence. The process continued and closed — provides a useful reference if regulatory matters surface during Project Everest DD.',
    },
];

export default class NavatarDealSimilarDeals extends LightningElement {
    @track searchTerm  = '';
    @track selectedDeal = null;

    columns = COLUMNS;
    deals   = DEALS;

    get filteredDeals() {
        if (!this.searchTerm) return this.deals;
        const s = this.searchTerm.toLowerCase();
        return this.deals.filter(d =>
            d.deal.toLowerCase().includes(s)    ||
            d.company.toLowerCase().includes(s) ||
            d.sector.toLowerCase().includes(s)
        );
    }

    handleSearch(event) {
        this.searchTerm  = event.detail.value;
        this.selectedDeal = null;
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.selectedDeal = this.selectedDeal && this.selectedDeal.id === row.id ? null : row;
    }

    handleCloseDetail() {
        this.selectedDeal = null;
    }
}