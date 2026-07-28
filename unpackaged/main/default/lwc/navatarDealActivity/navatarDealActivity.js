import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';

const COLUMNS = [
    { label: 'Type',     fieldName: 'badge',     type: 'text', initialWidth: 200 },
    {
        label: 'Activity', type: 'button',
        typeAttributes: { label: { fieldName: 'title' }, name: 'open_ai', variant: 'base' },
    },
    { label: 'When',     fieldName: 'timestamp', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] }
    }
];

const FEED_ITEMS = [
    // ── News ─────────────────────────────────────────────────────────────────
    { id: 'n1', badge: 'NEWS',              filterCat: 'news',           timestamp: 'PE Wire · 19 Feb 2026',        iconName: 'utility:news',           title: 'Graphite Capital acquires majority stake in CommuniCare Group',       preview: "Comparable / competitor transaction. CommuniCare Group operates in the same community care sector as Apex Care. Graphite's move confirms continued PE appetite for UK outpatient and community care assets." },
    // ── Deal Intelligence ────────────────────────────────────────────────────
    { id: 'i1', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:einstein',       title: 'CIM processed — Apex Care Partners identified',                       preview: 'Apex Care Partners identified from overnight CIM processing. 4-page CIM analysis filed covering business overview, financial profile, strategic context, and key considerations.' },
    { id: 'i2', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:contact',        title: '2 contacts created — Mark Hargreaves and Sarah Chen',                  preview: 'Mark Hargreaves (CEO) and Sarah Chen (CFO) extracted from CIM and created as Navatar contacts. Linked to Apex Care Partners and Project Everest.' },
    { id: 'i3', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:activity',       title: 'News monitoring activated — Apex Care Partners',                      preview: 'Apex Care Partners added to monitoring. Relevant news, regulatory events, and market developments will be surfaced automatically.' },
    { id: 'i4', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:connected_apps', title: '3 bolt-on targets identified',                                        preview: 'Compass Community Care, Severn Health Group, and PrimeCare Bristol flagged as potential add-on acquisitions based on sector and geography match.' },
    { id: 'i5', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:summary',        title: 'Investment highlights extracted from CIM',                            preview: 'Highlights: strong referral network, consistent revenue growth, NHS contract stability, management tenure. Key considerations: NHS concentration, management retention, site expansion execution risk.' },
    // ── AI Recommendations ──────────────────────────────────────────────────
    { id: 'r1', badge: 'AI RECOMMENDATION', filterCat: 'recommendation', timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:einstein',       title: 'Prepare management meeting questions',                                preview: "CIM analysis has surfaced four areas requiring direct clarification: GP referral network exclusivity arrangements, NHS contract renewal profile, site expansion pipeline, and management team depth below CEO/CFO level." },
    { id: 'r2', badge: 'AI RECOMMENDATION', filterCat: 'recommendation', timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:einstein',       title: 'Research management team ahead of meeting',                          preview: 'Mark Hargreaves and Sarah Chen have been created as contacts. Background research on both is recommended before the 28 Feb meeting. LinkedIn, Companies House, and prior transaction history to be reviewed.' },
    { id: 'r3', badge: 'AI RECOMMENDATION', filterCat: 'recommendation', timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:einstein',       title: 'Monitor bolt-on targets — no action required yet',                   preview: 'Compass Community Care, Severn Health Group, and PrimeCare Bristol are being monitored. No action required at this stage.' },
    { id: 'r4', badge: 'AI RECOMMENDATION', filterCat: 'recommendation', timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:einstein',       title: 'Verify EBITDA normalisation with management',                         preview: "CIM states £8.1M EBITDA. Ironwood's initial view post-normalisation is £7.9M — a £200K gap. Confirm adjustments with management at the meeting." },
    { id: 'r5', badge: 'AI RECOMMENDATION', filterCat: 'recommendation', timestamp: '18 Feb 2026 · 08:00am',       iconName: 'utility:einstein',       title: 'Assess platform potential at management meeting',                     preview: "Apex Care's South West England footprint and outpatient model are consistent with a regional platform thesis. Confirm management appetite for acquisition-led growth at the meeting." },
    // ── News (cont.) ─────────────────────────────────────────────────────────
    { id: 'n2', badge: 'NEWS',              filterCat: 'news',           timestamp: 'NHS England · 18 Feb 2026',    iconName: 'utility:news',           title: 'NHS outpatient waiting list falls for third consecutive quarter',      preview: "Positive market tailwind for Apex Care's NHS referral revenue. Sustained reduction in outpatient waiting lists supports volume stability across NHS-contracted community care providers." },
    // ── Deal Intelligence (cont.) ────────────────────────────────────────────
    { id: 'i6', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '10 Feb 2026 · 03:00pm',       iconName: 'utility:description',    title: 'NDA executed — process letter received from Houlihan Lokey',          preview: 'Houlihan Lokey process letter confirms structured auction. Management meeting scheduled 28 Feb 2026 in Birmingham.' },
    // ── News (cont.) ─────────────────────────────────────────────────────────
    { id: 'n3', badge: 'NEWS',              filterCat: 'news',           timestamp: 'Houlihan Lokey · 05 Feb 2026', iconName: 'utility:news',           title: 'UK private healthcare M&A volumes up 23% in 2025',                    preview: 'Houlihan Lokey sector report confirms strong market context for Project Everest process. Increased deal activity supports competitive auction dynamics and valuation assumptions.' },
    // ── Deal Intelligence (cont.) ────────────────────────────────────────────
    { id: 'i7', badge: 'DEAL INTELLIGENCE', filterCat: 'intelligence',   timestamp: '03 Feb 2026 · 09:15am',       iconName: 'utility:new_window',     title: 'Deal record created — teaser received from Michael Hartley',          preview: 'Teaser received from Michael Hartley, Houlihan Lokey. Project Everest created. UK outpatient rehabilitation, 22 sites, £38M revenue. Criteria match confirmed. Acknowledgment drafted.' },
];

const PAGE_SIZE = 9;

export default class NavatarDealActivity extends LightningElement {
    @wire(MessageContext) messageContext;

    @track activeFilter  = 'all';
    @track searchTerm    = '';
    @track selectedItem  = null;
    @track showAll       = false;

    columns   = COLUMNS;
    feedItems = FEED_ITEMS;

    get _allFiltered() {
        let items = this.activeFilter === 'all'
            ? this.feedItems
            : this.feedItems.filter(i => i.filterCat === this.activeFilter);
        if (this.searchTerm) {
            const term = this.searchTerm.toLowerCase();
            items = items.filter(i =>
                i.title.toLowerCase().includes(term) ||
                i.preview.toLowerCase().includes(term)
            );
        }
        return items;
    }

    get filteredFeed() {
        return this.showAll ? this._allFiltered : this._allFiltered.slice(0, PAGE_SIZE);
    }

    get hasMore()       { return !this.showAll && this._allFiltered.length > PAGE_SIZE; }
    get remainingCount(){ return this._allFiltered.length - PAGE_SIZE; }
    get showMoreLabel() { return `Show ${this.remainingCount} more items ↓`; }

    get fAll()            { return this.activeFilter === 'all'            ? 'brand' : 'neutral'; }
    get fEmail()          { return this.activeFilter === 'email'          ? 'brand' : 'neutral'; }
    get fMeeting()        { return this.activeFilter === 'meeting'        ? 'brand' : 'neutral'; }
    get fIntelligence()   { return this.activeFilter === 'intelligence'   ? 'brand' : 'neutral'; }
    get fNews()           { return this.activeFilter === 'news'           ? 'brand' : 'neutral'; }
    get fRecommendation() { return this.activeFilter === 'recommendation' ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.currentTarget.dataset.filter;
        this.selectedItem = null;
        this.showAll = false;
    }

    handleSearch(event) {
        this.searchTerm  = event.detail.value;
        this.selectedItem = null;
    }

    handleRowAction(event) {
        const { action, row } = event.detail;
        console.log('[NavatarDealActivity] handleRowAction fired — action:', action.name, '| row title:', row.title);
        if (action.name === 'open_ai') {
            console.log('[NavatarDealActivity] Publishing LMS message with selectedContext:', row.title);
            publish(this.messageContext, NAVATAR_AI_CHANNEL, { selectedContext: row.title });
            console.log('[NavatarDealActivity] LMS publish complete');
        } else {
            this.selectedItem = this.selectedItem && this.selectedItem.id === row.id ? null : row;
        }
    }

    handleCloseDetail() {
        this.selectedItem = null;
    }

    handleShowMore() { this.showAll = true; }
}