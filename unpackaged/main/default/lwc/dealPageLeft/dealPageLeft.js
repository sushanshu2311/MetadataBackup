import { LightningElement, api, track } from 'lwc';

const BADGE_CSS = {
    'VINTON':    'badge fb-vinton',
    'EMAIL':     'badge fb-email',
    'CALL':      'badge fb-call',
    'DOCUMENT':  'badge fb-doc',
    'GAP':       'badge fb-gap',
    'AI':        'badge fb-ai',
    'RISK':      'badge fb-risk',
    'DEAL EVENT':'badge fb-deal',
    'BRIEFING':  'badge fb-briefing',
};

const INT_ICON = { 'VINTON': 'utility:event', 'CALL': 'utility:call', 'EMAIL': 'utility:email' };

const ALL_PEOPLE = [
    { id: 'r1', initials: 'TB',  name: 'Thomas Bennett',   org: 'Ironwood Capital',         groupKey: 'internal', groupLabel: 'Internal',     role: 'Deal Lead, Partner',    email: 'tbennett@ironwoodcap.com',    lastDate: 'Today 09:45', lastBadge: 'VINTON',   interactions: 12 },
    { id: 'r2', initials: 'SP',  name: 'Sarah Patel',      org: 'Ironwood Capital',         groupKey: 'internal', groupLabel: 'Internal',     role: 'Analyst',               email: 'spatel@ironwoodcap.com',      lastDate: '14 Jun 2026', lastBadge: 'EMAIL',    interactions: 7  },
    { id: 'r3', initials: 'MH',  name: 'Michael Hartley',  org: 'Houlihan Lokey',           groupKey: 'banker',   groupLabel: 'Banker',       role: 'MD Healthcare, Source', email: 'mhartley@hl.com',             lastDate: 'Today 09:00', lastBadge: 'CALL',     interactions: 8  },
    { id: 'r4', initials: 'MW',  name: 'Dr. Marcus Webb',  org: 'Webb Regulatory Advisory', groupKey: 'dd',       groupLabel: 'DD & Experts', role: 'Regulatory Expert',     email: 'm.webb@webbadvisory.com',     lastDate: 'Today 08:47', lastBadge: 'DOCUMENT', interactions: 3  },
    { id: 'r5', initials: 'KP',  name: 'Karen Philips',    org: 'L.E.K. Consulting',        groupKey: 'dd',       groupLabel: 'DD & Experts', role: 'Commercial DD Lead',    email: 'k.philips@lek.com',           lastDate: '03 Jun 2026', lastBadge: 'EMAIL',    interactions: 2  },
    { id: 'r6', initials: 'KE',  name: 'Kirkland & Ellis', org: 'Legal Counsel',            groupKey: 'dd',       groupLabel: 'DD & Experts', role: 'Legal DD',              email: 'deal-team@kirkland.com',      lastDate: '28 May 2026', lastBadge: 'EMAIL',    interactions: 4  },
    { id: 'r7', initials: 'MHa', name: 'Mark Hargreaves',  org: 'Apex Care Partners',       groupKey: 'target',   groupLabel: 'Target',       role: 'CEO, 12 years',         email: 'm.hargreaves@apexcare.co.uk', lastDate: '20 May 2026', lastBadge: 'VINTON',   interactions: 5  },
    { id: 'r8', initials: 'SC',  name: 'Sarah Chen',       org: 'Apex Care Partners',       groupKey: 'target',   groupLabel: 'Target',       role: 'CFO, joined 2023',      email: 's.chen@apexcare.co.uk',       lastDate: '20 May 2026', lastBadge: 'VINTON',   interactions: 5  },
];

const INTERACTIONS = [
    {
        id: 'i1', date: '20 May 2026', type: 'VINTON', badgeCss: 'badge fb-vinton',
        subject: 'Management meeting — Apex Care Partners HQ, London',
        preview: '68-min meeting. Mark Hargreaves confirmed retention interest. NHS Guildford CCG renewal strategy outlined. 4 tasks created.',
        notes: 'Full meeting at Apex Care HQ, London. Duration: 68 minutes.\n\nMark Hargreaves confirmed interest in a retention package — open to a 3-year earn-out tied to NHS referral volume KPIs. Advent International have made a competing approach which management are aware of.\n\nNHS Guildford CCG contract renewal: runs to March 2027, management confident of renewal based on clinical outcomes data.\n\nSelf-pay pipeline: 340 patients, 18% YoY growth, ahead of CIM projections.\n\nIT infrastructure: legacy system across 8 sites, estimated remediation £1.2–1.8M. Gartner scope to be confirmed by 17 Jun.\n\n4 action items created by Claude.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital',      avStyle: 'background:#0B2D5F' },
            { id: 'p2', initials: 'MH', name: 'Mark Hargreaves', org: 'Apex Care Partners',    avStyle: 'background:#555555' },
            { id: 'p3', initials: 'SC', name: 'Sarah Chen',      org: 'Apex Care Partners',    avStyle: 'background:#555555' },
        ],
        tags: ['Project Everest', 'Management', 'Retention'],
    },
    {
        id: 'i2', date: '07 May 2026', type: 'CALL', badgeCss: 'badge fb-call',
        subject: 'Process update — Advent International confirmed in process',
        preview: '15-min call with Michael Hartley. 4 bidders remaining. Management retention flagged as key differentiator.',
        notes: '15-minute call with Michael Hartley (Houlihan Lokey).\n\n• 4 bidders now confirmed remaining in the process\n• Advent International are one of the four — confirmed by HL\n• Management retention flagged by vendor as key differentiator for the winning bid\n• Final bids due 28 March — Hartley requested Kirkland retention term sheet by end of week\n• Process timeline unchanged',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital', avStyle: 'background:#0B2D5F' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey',   avStyle: 'background:#3a5fa5' },
        ],
        tags: ['Houlihan Lokey', 'Process', 'Advent'],
    },
    {
        id: 'i3', date: '12 Mar 2026', type: 'EMAIL', badgeCss: 'badge fb-email',
        subject: 'LOI submission — final process terms and financing structure',
        preview: '6-email thread. 4 bidders confirmed. Final bids 28 Mar. Equity-heavy structure preferred by sellers.',
        notes: '6-email thread summarised by Claude. Thread dates: 08–12 March 2026.\n\n• 4 bidders confirmed remaining\n• Final bid deadline: 28 March 2026\n• Thomas confirmed equity-heavy structure (65% equity) preferred by sellers\n• No exclusivity offered at this stage\n• Seller preference for completion by end of Q3 2026\n• Kirkland & Ellis confirmed as legal counsel',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital', avStyle: 'background:#0B2D5F' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey',   avStyle: 'background:#3a5fa5' },
        ],
        tags: ['Houlihan Lokey', 'LOI', 'Terms'],
    },
    {
        id: 'i4', date: '08 Mar 2026', type: 'VINTON', badgeCss: 'badge fb-vinton',
        subject: 'Management meeting — initial diligence, NHS referral network',
        preview: '52-min meeting. NHS referral relationships mapped. Self-pay pipeline validated. IT infrastructure gap first surfaced.',
        notes: 'Second management meeting, 52 minutes, at Ironwood Capital offices.\n\nNHS referral network mapping: 22 active CCG referral relationships. 14 of 22 directly managed by Mark Hargreaves personally — key person risk identified and logged.\n\nSelf-pay pipeline validated against CIM projections: broadly in line, slight upside on physiotherapy segment.\n\nIT infrastructure: first surfacing of legacy system issue across 8 of 22 sites. Management aware, no remediation plan in place yet.\n\nActions: map full referral relationship matrix, request IT scope from management.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital',   avStyle: 'background:#0B2D5F' },
            { id: 'p2', initials: 'MH', name: 'Mark Hargreaves', org: 'Apex Care Partners', avStyle: 'background:#555555' },
        ],
        tags: ['Management', 'NHS', 'Due Diligence'],
    },
    {
        id: 'i5', date: '28 Jan 2026', type: 'EMAIL', badgeCss: 'badge fb-email',
        subject: 'NDA executed — Houlihan Lokey process confirmation',
        preview: 'NDA signed and returned. HL confirmed deal team and process timeline.',
        notes: 'NDA signed and returned to Houlihan Lokey.\n\nMichael Hartley confirmed deal team on seller side and process timeline:\n• CIM to be distributed week of 10 February\n• Management meetings: early March\n• Final bids: late March\n• Exclusivity: not offered, competitive process\n\nHL confirmed Ironwood are on the approved buyer list.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital', avStyle: 'background:#0B2D5F' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey',   avStyle: 'background:#3a5fa5' },
        ],
        tags: ['Houlihan Lokey', 'NDA'],
    },
    {
        id: 'i6', date: '22 Jan 2026', type: 'CALL', badgeCss: 'badge fb-call',
        subject: 'Initial teaser discussion — Project Everest introduction',
        preview: 'Michael Hartley introduced the deal verbally before sending the teaser. UK outpatient rehab, 22 sites.',
        notes: 'Initial call with Michael Hartley, Houlihan Lokey. Duration: approx 20 minutes.\n\nHartley introduced Project Everest verbally ahead of sending the teaser document:\n• UK outpatient rehabilitation, 22 sites\n• Revenue £38M, strong EBITDA margin\n• NHS + self-pay revenue mix (65/35)\n• Founder-owned, management keen to remain\n• Competitive process, 8–10 parties receiving teaser\n\nThomas confirmed interest. NDA to follow.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital', avStyle: 'background:#0B2D5F' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey',   avStyle: 'background:#3a5fa5' },
        ],
        tags: ['Houlihan Lokey', 'Sourcing'],
    },
];

export default class DealPageLeft extends LightningElement {
    @api recordId;
    @track activeTab   = 'overview';
    @track riFilter    = 'all';

    // Interaction modal state
    @track selectedInt  = null;
    @track intEditMode  = false;
    @track editSubject  = '';
    @track editNotes    = '';

    // Local copy of interactions so edits persist within the session
    @track _interactions = INTERACTIONS.map(i => ({ ...i, people: [...i.people], tags: [...i.tags] }));

    // ── Tab / RI ──────────────────────────────────────────────
    handleTabSelect(event) { this.activeTab = event.detail.value; }
    goToRI()               { this.activeTab = 'ri'; }
    handleRiFilter(event)  { this.riFilter  = event.currentTarget.dataset.g; }

    get rfc() {
        const p = v => v === this.riFilter ? 'rgt active' : 'rgt';
        return { all: p('all'), internal: p('internal'), banker: p('banker'), dd: p('dd'), target: p('target') };
    }

    get riPeople() {
        const people = this.riFilter === 'all' ? ALL_PEOPLE : ALL_PEOPLE.filter(p => p.groupKey === this.riFilter);
        return people.map(p => ({ ...p, lastBadgeCss: BADGE_CSS[p.lastBadge] || 'badge' }));
    }

    get riCountLabel() {
        const n = this.riPeople.length;
        return `${n} ${n === 1 ? 'person' : 'people'}`;
    }

    // ── Interactions list ─────────────────────────────────────
    get interactions() { return this._interactions; }

    // ── Interaction modal ─────────────────────────────────────
    get showIntModal()  { return this.selectedInt !== null; }
    get intViewMode()   { return !this.intEditMode; }

    get selectedIntIcon() {
        return this.selectedInt ? (INT_ICON[this.selectedInt.type] || 'utility:activity') : 'utility:activity';
    }

    handleIntClick(event) {
        const id = event.currentTarget.dataset.id;
        this.selectedInt = this._interactions.find(i => i.id === id) || null;
        this.intEditMode = false;
    }

    closeIntModal() {
        this.selectedInt = null;
        this.intEditMode = false;
    }

    handleIntEdit() {
        this.editSubject = this.selectedInt.subject;
        this.editNotes   = this.selectedInt.notes;
        this.intEditMode = true;
    }

    handleIntDelete() {
        // Stub — no action taken
    }

    handleEditSubjectChange(event) { this.editSubject = event.target.value; }
    handleEditNotesInput(event)    { this.editNotes   = event.detail.value; }

    handleIntSave() {
        const idx = this._interactions.findIndex(i => i.id === this.selectedInt.id);
        if (idx >= 0) {
            const updated = { ...this._interactions[idx], subject: this.editSubject, notes: this.editNotes };
            this._interactions = [
                ...this._interactions.slice(0, idx),
                updated,
                ...this._interactions.slice(idx + 1),
            ];
            this.selectedInt = updated;
        }
        this.intEditMode = false;
    }

    handleIntCancel() { this.intEditMode = false; }

    handleModalBgClick() { this.closeIntModal(); }
    stopProp(event) { event.stopPropagation(); }

    // ── Click map ─────────────────────────────────────────────
    @track showClickMap  = false;
    @track clickPoints   = [];

    toggleClickMap() {
        this.showClickMap = !this.showClickMap;
        if (this.showClickMap) {
            // Allow one frame for any conditional renders to settle
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => this._buildClickMap(), 50);
        } else {
            this.clickPoints = [];
        }
    }

    closeClickMap() { this.showClickMap = false; this.clickPoints = []; }

    _buildClickMap() {
        const RULES = [
            { sel: 'a',          fn: el => el.textContent.trim() || 'Link' },
            { sel: '.rgt',       fn: el => `RI filter: ${el.textContent.trim()}` },
            { sel: '.filter-pill', fn: el => `Filter: ${el.textContent.trim()}` },
            { sel: '.int-row',   fn: el => `Interaction row: ${el.querySelector('.int-subj')?.textContent?.trim()?.slice(0, 40) || 'row'}` },
            { sel: '.int-act-btn', fn: el => `Modal btn: ${el.title || 'button'}` },
            { sel: 'button',     fn: el => el.title || el.textContent.trim().slice(0, 40) || 'Button' },
        ];

        const seen = new Set();
        const points = [];
        let num = 1;

        RULES.forEach(({ sel, fn }) => {
            this.template.querySelectorAll(sel).forEach(el => {
                if (seen.has(el)) return;
                seen.add(el);
                const rect = el.getBoundingClientRect();
                if (rect.width < 2 || rect.height < 2) return;
                const cx = rect.left + rect.width  / 2;
                const cy = rect.top  + rect.height / 2;
                points.push({
                    id:    `cp${num}`,
                    num,
                    label: `${num} — ${fn(el)}`,
                    style: `top:${cy - 10}px;left:${cx - 10}px`,
                });
                num++;
            });
        });

        this.clickPoints = points;
    }
}