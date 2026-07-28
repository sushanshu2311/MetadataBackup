// AA-833: Replaced manual layout with lightning-datatable to fix Tags column overflow
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const INT_ICON = { 'Meeting': 'utility:groups', 'Call': 'utility:call', 'Email': 'utility:email', 'Briefing': 'utility:description', 'Deal Event': 'utility:event' };

const COLUMNS = [
    { label: 'Date',    fieldName: 'date',        type: 'text',   initialWidth: 110 },
    { label: 'Type',    fieldName: 'type',        type: 'text',   initialWidth: 90  },
    { label: 'Subject', fieldName: 'subject',     type: 'button', wrapText: true,
      typeAttributes: { label: { fieldName: 'subject' }, name: 'view', variant: 'base' } },
    { label: 'People',  fieldName: 'peopleLabel', type: 'text',   initialWidth: 180 },
    { label: 'Tags',    fieldName: 'tagsLabel',   type: 'text',   wrapText: true, initialWidth: 200 },
];

const INTERACTIONS = [
    {
        id: 'i1', date: '20 May 2026', type: 'Meeting',
        subject: 'Management meeting — Apex Care Partners HQ, London',
        peopleLabel: 'T. Bennett, M. Hargreaves, S. Chen', tagsLabel: 'Retention · NHS · Strategy',
        notes: 'Full meeting at Apex Care HQ, London. Duration: 68 minutes.\n\nMark Hargreaves confirmed interest in a retention package — open to a 3-year earn-out tied to NHS referral volume KPIs. Advent International have made a competing approach which management are aware of.\n\nNHS Guildford CCG contract renewal: runs to March 2027, management confident of renewal based on clinical outcomes data.\n\nSelf-pay pipeline: 340 patients, 18% YoY growth, ahead of CIM projections.\n\nIT infrastructure: legacy system across 8 sites, estimated remediation £1.2–1.8M. Gartner scope to be confirmed by 17 Jun.\n\n4 action items created by Claude.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital'   },
            { id: 'p2', initials: 'MH', name: 'Mark Hargreaves', org: 'Apex Care Partners' },
            { id: 'p3', initials: 'SC', name: 'Sarah Chen',      org: 'Apex Care Partners' },
        ],
        tags: ['Project Everest', 'Management', 'Retention'],
    },
    {
        id: 'i2', date: '07 May 2026', type: 'Call',
        subject: 'Process update — Advent International confirmed in process',
        peopleLabel: 'T. Bennett, M. Hartley', tagsLabel: 'Houlihan Lokey · Process · Advent',
        notes: '15-minute call with Michael Hartley (Houlihan Lokey).\n\n• 4 bidders now confirmed remaining in the process\n• Advent International are one of the four — confirmed by HL\n• Management retention flagged by vendor as key differentiator for the winning bid\n• Final bids due 28 March — Hartley requested Kirkland retention term sheet by end of week\n• Process timeline unchanged',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey'   },
        ],
        tags: ['Houlihan Lokey', 'Process', 'Advent'],
    },
    {
        id: 'i3', date: '12 Mar 2026', type: 'Email',
        subject: 'LOI submission — final process terms and financing structure',
        peopleLabel: 'T. Bennett, M. Hartley', tagsLabel: 'Houlihan Lokey · LOI · Terms',
        notes: '6-email thread summarised by Claude. Thread dates: 08–12 March 2026.\n\n• 4 bidders confirmed remaining\n• Final bid deadline: 28 March 2026\n• Thomas confirmed equity-heavy structure (65% equity) preferred by sellers\n• No exclusivity offered at this stage\n• Seller preference for completion by end of Q3 2026\n• Kirkland & Ellis confirmed as legal counsel',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey'   },
        ],
        tags: ['Houlihan Lokey', 'LOI', 'Terms'],
    },
    {
        id: 'i4', date: '08 Mar 2026', type: 'Meeting',
        subject: 'Management meeting — initial diligence, NHS referral network',
        peopleLabel: 'T. Bennett, M. Hargreaves', tagsLabel: 'Management · NHS · Due Diligence',
        notes: 'Second management meeting, 52 minutes, at Ironwood Capital offices.\n\nNHS referral network mapping: 22 active CCG referral relationships. 14 of 22 directly managed by Mark Hargreaves personally — key person risk identified and logged.\n\nSelf-pay pipeline validated against CIM projections: broadly in line, slight upside on physiotherapy segment.\n\nIT infrastructure: first surfacing of legacy system issue across 8 of 22 sites. Management aware, no remediation plan in place yet.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital'   },
            { id: 'p2', initials: 'MH', name: 'Mark Hargreaves', org: 'Apex Care Partners' },
        ],
        tags: ['Management', 'NHS', 'Due Diligence'],
    },
    {
        id: 'i5', date: '28 Jan 2026', type: 'Email',
        subject: 'NDA executed — Houlihan Lokey process confirmation',
        peopleLabel: 'T. Bennett, M. Hartley', tagsLabel: 'Houlihan Lokey · NDA',
        notes: 'NDA signed and returned to Houlihan Lokey.\n\nMichael Hartley confirmed deal team on seller side and process timeline:\n• CIM to be distributed week of 10 February\n• Management meetings: early March\n• Final bids: late March\n• Exclusivity: not offered, competitive process\n\nHL confirmed Ironwood are on the approved buyer list.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey'   },
        ],
        tags: ['Houlihan Lokey', 'NDA'],
    },
    {
        id: 'i6', date: '22 Jan 2026', type: 'Call',
        subject: 'Initial teaser discussion — Project Everest introduction',
        peopleLabel: 'T. Bennett, M. Hartley', tagsLabel: 'Houlihan Lokey · Sourcing',
        notes: 'Initial call with Michael Hartley, Houlihan Lokey. Duration: approx 20 minutes.\n\nHartley introduced Project Everest verbally ahead of sending the teaser document:\n• UK outpatient rehabilitation, 22 sites\n• Revenue £38M, strong EBITDA margin\n• NHS + self-pay revenue mix (65/35)\n• Founder-owned, management keen to remain\n• Competitive process, 8–10 parties receiving teaser\n\nThomas confirmed interest. NDA to follow.',
        people: [
            { id: 'p1', initials: 'TB', name: 'Thomas Bennett',  org: 'Ironwood Capital' },
            { id: 'p2', initials: 'MH', name: 'Michael Hartley', org: 'Houlihan Lokey'   },
        ],
        tags: ['Houlihan Lokey', 'Sourcing'],
    },
];

export default class DealInteractionsTab extends LightningElement {
    @api recordId;
    @track selectedInt = null;
    @track intEditMode = false;
    @track editSubject = '';
    @track editNotes   = '';

    @track _interactions = INTERACTIONS.map(i => ({ ...i, people: [...i.people], tags: [...i.tags] }));

    columns = COLUMNS;

    get tableData()        { return this._interactions; }
    get totalCountLabel()  { return `${this._interactions.length} logged`; }
    get showIntModal()     { return this.selectedInt !== null; }
    get intViewMode()      { return !this.intEditMode; }
    get selectedIntIcon()  { return this.selectedInt ? (INT_ICON[this.selectedInt.type] || 'utility:activity') : 'utility:activity'; }

    handleLogInteraction() {
        this.dispatchEvent(new ShowToastEvent({ title: 'Log new interaction', variant: 'info', mode: 'dismissible' }));
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'view') {
            this.selectedInt = this._interactions.find(i => i.id === event.detail.row.id) || null;
            this.intEditMode = false;
        }
    }

    closeIntModal() { this.selectedInt = null; this.intEditMode = false; }

    handleIntEdit() {
        this.editSubject = this.selectedInt.subject;
        this.editNotes   = this.selectedInt.notes;
        this.intEditMode = true;
    }

    handleIntCancel() { this.intEditMode = false; }

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
}