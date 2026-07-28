import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Person',          fieldName: 'name',       type: 'text', initialWidth: 180 },
    { label: 'Group',           fieldName: 'groupLabel', type: 'text', initialWidth: 130 },
    { label: 'Role',            fieldName: 'role',       type: 'text' },
    { label: 'Contact',         fieldName: 'email',      type: 'text', initialWidth: 210 },
    { label: 'Last Touchpoint', fieldName: 'lastTouch',  type: 'text', initialWidth: 150 },
    { label: 'Interactions',    fieldName: 'count',      type: 'text', initialWidth: 110 },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] } }
];

const GROUP_LABELS = {
    internal: 'Internal',
    banker:   'Banker',
    dd:       'DD & Experts',
    target:   'Target',
    ai:       'AI Recommended',
};

const PEOPLE = [
    // ── Internal ─────────────────────────────────────────────────────────────
    {
        id: 'p1', initials: 'TB', name: 'Thomas Bennett', org: 'Ironwood Capital', group: 'internal', role: 'Deal Lead, Partner',
        email: 'tbennett@ironwoodcap.com', lastTouch: '10 Feb 2026', lastBadge: 'EMAIL', count: 4, notContacted: false, competitor: false,
        howWeKnow:   'Thomas is the Ironwood Capital deal lead on Project Everest. As a Partner, he has been the primary point of contact with Houlihan Lokey since the teaser was received on 3 Feb 2026.',
        dealHistory: 'Project Lighthouse (Deal Lead, Closed Nov 2023) · Project Beacon (Board Observer)',
        dealDocs:    'Project Everest Teaser · Apex Care CIM',
    },
    {
        id: 'p2', initials: 'SO', name: 'Sarah Okonkwo', org: 'Ironwood Capital', group: 'internal', role: 'Analyst',
        email: 'sokonkwo@ironwoodcap.com', lastTouch: '18 Feb 2026', lastBadge: 'CIM', count: 2, notContacted: false, competitor: false,
        howWeKnow:   'Sarah is the lead analyst on Project Everest, responsible for CIM processing, task management, and deal tracking.',
        dealHistory: 'Project Lighthouse (Analyst)',
        dealDocs:    'Apex Care CIM · CIM Analysis (4-page, filed 18 Feb 2026)',
    },
    // ── Banker ───────────────────────────────────────────────────────────────
    {
        id: 'p3', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey', group: 'banker', role: 'MD, Healthcare IB',
        email: 'mhartley@hl.com', lastTouch: '10 Feb 2026', lastBadge: 'EMAIL', count: 3, notContacted: false, competitor: false,
        howWeKnow:   'Michael is the MD at Houlihan Lokey running the Project Everest auction process. He sent the original teaser on 3 Feb 2026 and issued the process letter on 10 Feb 2026.',
        dealHistory: 'Project Lighthouse (Sell-side Adviser)',
        dealDocs:    'Project Everest Teaser · Process Letter (10 Feb 2026)',
    },
    // ── Target ───────────────────────────────────────────────────────────────
    {
        id: 'p4', initials: 'MHa', name: 'Mark Hargreaves', org: 'Apex Care Partners', group: 'target', role: 'CEO · 12 years',
        email: 'm.hargreaves@apexcare.co.uk', lastTouch: '18 Feb 2026', lastBadge: 'CIM', count: 1, notContacted: false, competitor: false,
        howWeKnow:   'Mark Hargreaves is CEO of Apex Care Partners. Identified from CIM processing on 18 Feb 2026. No direct contact has been made — management meeting scheduled 28 Feb 2026 in Birmingham.',
        dealHistory: 'No prior deal history with Ironwood',
        dealDocs:    'Apex Care CIM (source)',
    },
    {
        id: 'p5', initials: 'SC', name: 'Sarah Chen', org: 'Apex Care Partners', group: 'target', role: 'CFO',
        email: 's.chen@apexcare.co.uk', lastTouch: '18 Feb 2026', lastBadge: 'CIM', count: 1, notContacted: false, competitor: false,
        howWeKnow:   'Sarah Chen is CFO of Apex Care Partners. Identified from CIM processing on 18 Feb 2026. No direct contact has been made — management meeting scheduled 28 Feb 2026 in Birmingham.',
        dealHistory: 'No prior deal history with Ironwood',
        dealDocs:    'Apex Care CIM (source)',
    },
    // ── AI Recommended ───────────────────────────────────────────────────────
    {
        id: 'p6', initials: 'JW', name: 'James Whitfield', org: 'Barclays PE', group: 'ai', role: 'MD — warm path to Hargreaves',
        email: null, lastTouch: null, lastBadge: null, count: null, notContacted: true, competitor: false,
        howWeKnow:   'AI-identified warm path to Mark Hargreaves via Thomas Bennett\'s network. James is a Managing Director at Barclays PE. Not yet contacted — connection not yet activated.',
        dealHistory: null,
        dealDocs:    null,
    },
].map(p => ({ ...p, groupLabel: GROUP_LABELS[p.group] }));

const GROUP_FILTERS = [
    { value: 'all',      label: 'All' },
    { value: 'internal', label: 'Internal' },
    { value: 'banker',   label: 'Banker' },
    { value: 'dd',       label: 'DD & Experts' },
    { value: 'target',   label: 'Target' },
    { value: 'ai',       label: 'AI Recommended' },
];

export default class NavatarDealPeople extends LightningElement {
    @track activeGroup    = 'all';
    @track searchTerm     = '';
    @track selectedPerson = null;

    columns      = COLUMNS;
    groupFilters = GROUP_FILTERS;

    get filteredPeople() {
        let people = PEOPLE;
        if (this.activeGroup !== 'all') {
            people = people.filter(p => p.group === this.activeGroup);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            people = people.filter(p =>
                p.name.toLowerCase().includes(s) ||
                p.org.toLowerCase().includes(s) ||
                p.role.toLowerCase().includes(s)
            );
        }
        return people;
    }

    get totalCount() {
        return this.filteredPeople.length;
    }

    get fAll()      { return this.activeGroup === 'all'      ? 'brand' : 'neutral'; }
    get fInternal() { return this.activeGroup === 'internal' ? 'brand' : 'neutral'; }
    get fBanker()   { return this.activeGroup === 'banker'   ? 'brand' : 'neutral'; }
    get fDd()       { return this.activeGroup === 'dd'       ? 'brand' : 'neutral'; }
    get fTarget()   { return this.activeGroup === 'target'   ? 'brand' : 'neutral'; }
    get fAi()       { return this.activeGroup === 'ai'       ? 'brand' : 'neutral'; }

    handleGroupFilter(event) {
        this.activeGroup  = event.currentTarget.dataset.group;
        this.selectedPerson = null;
    }

    handleSearch(event) {
        this.searchTerm   = event.detail.value;
        this.selectedPerson = null;
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.selectedPerson = this.selectedPerson && this.selectedPerson.id === row.id ? null : row;
    }

    handleCloseDetail() {
        this.selectedPerson = null;
    }
}