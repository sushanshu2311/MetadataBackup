import { LightningElement, track } from 'lwc';

// ── P&L Summary ──────────────────────────────────────────────────────────────

const PL_COLUMNS = [
    { label: 'Metric',  fieldName: 'metric', type: 'text', wrapText: true },
    { label: 'FY2023A', fieldName: 'fy23',   type: 'text', initialWidth: 140 },
    { label: 'FY2024A', fieldName: 'fy24',   type: 'text', initialWidth: 140 },
    { label: 'FY2025A', fieldName: 'fy25',   type: 'text', initialWidth: 140 },
    { label: 'FY2026E', fieldName: 'fy26',   type: 'text', initialWidth: 140 },
    { label: 'FY2027E', fieldName: 'fy27',   type: 'text', initialWidth: 140 },
];

const PL_DATA = [
    { id: 'r1', metric: 'Revenue (£M)',   fy23: '29.4',  fy24: '33.8',  fy25: '38.2',  fy26: '42.6',  fy27: '47.1'  },
    { id: 'r2', metric: 'Revenue Growth', fy23: '—',     fy24: '15.0%', fy25: '13.0%', fy26: '11.5%', fy27: '10.6%' },
    { id: 'r3', metric: 'EBITDA (£M)',    fy23: '5.6',   fy24: '6.9',   fy25: '7.9',   fy26: '8.9',   fy27: '10.1'  },
    { id: 'r4', metric: 'EBITDA Margin',  fy23: '19.0%', fy24: '20.4%', fy25: '20.7%', fy26: '20.9%', fy27: '21.4%' },
];

// ── Deal Benchmarks ───────────────────────────────────────────────────────────

const BENCH_COLUMNS = [
    { label: 'Deal',            fieldName: 'deal',          type: 'text', wrapText: true },
    { label: 'Sector',          fieldName: 'sector',        type: 'text', wrapText: true, initialWidth: 150 },
    { label: 'Revenue',         fieldName: 'revenue',       type: 'text', initialWidth: 100 },
    { label: 'EBITDA %',        fieldName: 'ebitdaPct',     type: 'text', initialWidth: 120 },
    { label: 'Entry Multiple',  fieldName: 'multiple',      type: 'text', initialWidth: 140 },
    { label: 'Revenue Quality', fieldName: 'revenueQuality',type: 'text', wrapText: true, initialWidth: 200 },
    { label: 'Outcome',         fieldName: 'outcome',       type: 'text', wrapText: true, initialWidth: 180 },
];

const BENCHMARKS = [
    { id: 'b1', deal: 'Project Everest (CURRENT)\nApex Care Partners · UK',      sector: 'Outpatient Rehab',    revenue: '£38M', ebitdaPct: '21.6%', multiple: '11–13×', revenueQuality: 'NHS-contracted, 22 sites', outcome: 'DUE DILIGENCE' },
    { id: 'b2', deal: 'Project Lighthouse\nUK Outpatient Rehab · Closed Nov 2023',sector: 'Outpatient Rehab',    revenue: '£42M', ebitdaPct: '19.6%', multiple: '10.8×', revenueQuality: 'NHS-contracted, 28 sites', outcome: 'WON · IRONWOOD' },
    { id: 'b3', deal: 'Project Beacon\nUK Outpatient Rehab · Lost LOI Stage',     sector: 'Outpatient Rehab',    revenue: '£26M', ebitdaPct: '18.2%', multiple: '9.5×',  revenueQuality: 'NHS + private mix',        outcome: 'LOST · LOI STAGE' },
    { id: 'b4', deal: 'Project Atlas\nUK Allied Health · Closed Q1 2025',         sector: 'Allied Health',       revenue: '£35M', ebitdaPct: '22.1%', multiple: '11.0×', revenueQuality: 'NHS framework, multi-site', outcome: 'WON · IRONWOOD' },
    { id: 'b5', deal: 'UK Healthcare Services\nSector median · 2023–2025 · n=14', sector: 'Healthcare Services', revenue: '£32M', ebitdaPct: '19.5%', multiple: '10.5×', revenueQuality: 'Mixed',                    outcome: 'SECTOR BENCHMARK' },
];

// ── Return Scenarios ──────────────────────────────────────────────────────────

const SCENARIO_COLUMNS = [
    { label: 'Scenario',       fieldName: 'scenario',      type: 'text', wrapText: true },
    { label: 'Entry EV',       fieldName: 'entryEv',       type: 'text', initialWidth: 120 },
    { label: 'Entry Multiple', fieldName: 'entryMultiple', type: 'text', initialWidth: 120 },
    { label: 'Exit EV',        fieldName: 'exitEv',        type: 'text', initialWidth: 120 },
    { label: 'Exit Multiple',  fieldName: 'exitMultiple',  type: 'text', initialWidth: 170 },
    { label: 'IRR',            fieldName: 'irr',           type: 'text', initialWidth: 120 },
    { label: 'MOIC',           fieldName: 'moic',          type: 'text', initialWidth: 120 },
    { label: 'Hurdle',         fieldName: 'hurdle',        type: 'text', initialWidth: 140 },
];

const SCENARIOS = [
    { id: 's1', scenario: 'Base Case\nCMS resolved · Hargreaves retained',          entryEv: '£58M', entryMultiple: '12×', exitEv: '£183M', exitMultiple: '14×',   irr: '25%', moic: '2.8×', hurdle: 'ABOVE HURDLE' },
    { id: 's2', scenario: 'Downside\nCMS partially resolved · Hargreaves retained', entryEv: '£50M', entryMultiple: '11×', exitEv: '£127M', exitMultiple: '12×',   irr: '15%', moic: '2.4×', hurdle: 'ABOVE HURDLE' },
    { id: 's3', scenario: 'Stress\nCMS unresolved · Hargreaves departs',            entryEv: '£50M', entryMultiple: '11×', exitEv: '£58M',  exitMultiple: '10.5×', irr: '4%',  moic: '1.2×', hurdle: 'BELOW HURDLE' },
];

// ── Component ─────────────────────────────────────────────────────────────────

export default class NavatarDealFinancials extends LightningElement {
    @track activeTab      = 'all';
    @track benchSearch    = '';

    plColumns       = PL_COLUMNS;
    plData          = PL_DATA;
    benchColumns    = BENCH_COLUMNS;
    benchmarks      = BENCHMARKS;
    scenarioColumns = SCENARIO_COLUMNS;
    scenarioData    = SCENARIOS;

    get tabAll()    { return this.activeTab === 'all'    ? 'brand' : 'neutral'; }
    get tabPL()     { return this.activeTab === 'pl'     ? 'brand' : 'neutral'; }
    get tabBench()  { return this.activeTab === 'bench'  ? 'brand' : 'neutral'; }
    get tabReturn() { return this.activeTab === 'return' ? 'brand' : 'neutral'; }

    get showPL()     { return this.activeTab === 'all' || this.activeTab === 'pl'; }
    get showBench()  { return this.activeTab === 'all' || this.activeTab === 'bench'; }
    get showReturn() { return this.activeTab === 'all' || this.activeTab === 'return'; }

    get filteredBenchmarks() {
        if (!this.benchSearch) return this.benchmarks;
        const s = this.benchSearch.toLowerCase();
        return this.benchmarks.filter(b =>
            b.deal.toLowerCase().includes(s) || b.sector.toLowerCase().includes(s)
        );
    }

    handleTab(event) {
        this.activeTab = event.currentTarget.dataset.tab;
    }

    handleBenchSearch(event) {
        this.benchSearch = event.detail.value;
    }
}