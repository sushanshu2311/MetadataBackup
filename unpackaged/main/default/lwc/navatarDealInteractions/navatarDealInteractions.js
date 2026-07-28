import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const COLUMNS = [
    { label: 'Date',         fieldName: 'date',              type: 'text', initialWidth: 150 },
    { label: 'Subject',      fieldName: 'subjectFull',       type: 'text', wrapText: true },
    { label: 'Participants', fieldName: 'participantsLabel', type: 'text', initialWidth: 250 },
    { label: 'Type',         fieldName: 'badge',             type: 'text', initialWidth: 100 },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'View Details', name: 'view_detail' }] }
    },
];

const INTERACTIONS = [
    {
        id: 'i1',
        date: '20 May 2026',
        badge: 'MEETING',
        subject: 'Management meeting — Apex Care Partners HQ, London',
        preview: '68-min meeting. Mark Hargreaves confirmed retention interest. NHS Guildford CCG renewal strategy outlined. 4 tasks created.',
        people: ['TB', 'MHa', 'SC'],
        tags: ['Project Everest', 'Management', 'Retention'],
        expanded: false,
        detail: 'Attendees: Thomas Bennett (Ironwood), Mark Hargreaves (CEO), Sarah Chen (CFO). Duration: 68 minutes. Key outcomes: (1) Hargreaves confirmed open to 3-year earn-out with 15% equity rollover minimum. (2) NHS Guildford CCG contract renewal strategy outlined — contract runs to Mar 2027. (3) IT infrastructure gap acknowledged — £1.2–1.8M to remediate. (4) 4 tasks created: instruct legal on CMS, prepare meeting agenda, confirm retention terms, run CMS downside scenario.',
    },
    {
        id: 'i2',
        date: '07 May 2026',
        badge: 'CALL',
        subject: 'Process update — Advent International confirmed in process',
        preview: '15-min call with Michael Hartley. 4 bidders remaining. Management retention flagged as key differentiator.',
        people: ['TB', 'MH'],
        tags: ['Houlihan Lokey', 'Process', 'Advent'],
        expanded: false,
        detail: 'Thomas Bennett and Michael Hartley (Houlihan Lokey), 07 May 2026, 11:15, 15 minutes. Advent International confirmed in the process — 4 bidders remaining. Hartley indicated management retention will be the decisive factor. Kirkland & Ellis instructed to expedite retention term sheet.',
    },
    {
        id: 'i3',
        date: '12 Mar 2026',
        badge: 'EMAIL',
        subject: 'LOI submission — final process terms and financing structure',
        preview: '6-email thread. 4 bidders confirmed. Final bids 28 Mar. Equity-heavy structure preferred by sellers.',
        people: ['TB', 'MH'],
        tags: ['Houlihan Lokey', 'LOI', 'Terms'],
        expanded: false,
        detail: '6-email thread, 08–12 Mar 2026. Thomas Bennett and Michael Hartley. LOI submitted at 11–13× LTM EBITDA (£90–107M). Equity-heavy structure (65% equity target). 4 bidders confirmed remaining. Final bid deadline: 28 March 2026. Sellers preference: equity-heavy structure confirmed.',
    },
    {
        id: 'i4',
        date: '08 Mar 2026',
        badge: 'MEETING',
        subject: 'Management meeting — initial diligence, NHS referral network',
        preview: '52-min meeting. NHS referral relationships mapped. Self-pay pipeline validated. IT infrastructure gap first surfaced.',
        people: ['TB', 'MHa'],
        tags: ['Management', 'NHS', 'Due Diligence'],
        expanded: false,
        detail: 'Thomas Bennett and Mark Hargreaves, 08 Mar 2026, Apex Care HQ. 52 minutes. NHS referral relationships mapped — Guildford CCG is the largest at 16% of revenue. Self-pay growth validated at 18% YoY, 340 active patients. IT infrastructure gap first identified — 8 sites on legacy systems.',
    },
    {
        id: 'i5',
        date: '28 Jan 2026',
        badge: 'EMAIL',
        subject: 'NDA executed — Houlihan Lokey process confirmation',
        preview: 'NDA signed and returned. HL confirmed deal team and process timeline.',
        people: ['TB', 'MH'],
        tags: ['Houlihan Lokey', 'NDA'],
        expanded: false,
        detail: 'NDA signed and returned by Thomas Bennett. Houlihan Lokey confirmed deal team (Michael Hartley lead) and process timeline. Management meeting to be scheduled within 30 days of NDA. Process letter to follow.',
    },
    {
        id: 'i6',
        date: '22 Jan 2026',
        badge: 'CALL',
        subject: 'Initial teaser discussion — Project Everest introduction',
        preview: 'Michael Hartley introduced the deal verbally before sending the teaser. UK outpatient rehab, 22 sites.',
        people: ['TB', 'MH'],
        tags: ['Houlihan Lokey', 'Sourcing'],
        expanded: false,
        detail: 'Initial call — Thomas Bennett and Michael Hartley. Michael Hartley introduced Project Everest verbally before sending the teaser: UK outpatient rehabilitation, 22 clinic sites, £38M revenue, healthcare services sector. Criteria match confirmed. NDA to be requested.',
    },
];

export default class NavatarDealInteractions extends NavigationMixin(LightningElement) {
    @track interactions        = INTERACTIONS.map(i => ({ ...i }));
    @track searchTerm          = '';
    @track selectedInteraction = null;
    @track activeFilter        = 'all';

    columns = COLUMNS;

    get fAll()      { return this.activeFilter === 'all'     ? 'brand' : 'neutral'; }
    get fEmails()   { return this.activeFilter === 'EMAIL'   ? 'brand' : 'neutral'; }
    get fCalls()    { return this.activeFilter === 'CALL'    ? 'brand' : 'neutral'; }
    get fMeetings() { return this.activeFilter === 'MEETING' ? 'brand' : 'neutral'; }

    get filteredInteractions() {
        let items = this.activeFilter === 'all'
            ? this.interactions
            : this.interactions.filter(i => i.badge === this.activeFilter);
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            items = items.filter(i =>
                i.subject.toLowerCase().includes(s) ||
                i.preview.toLowerCase().includes(s)
            );
        }
        return items;
    }

    get tableData() {
        return this.filteredInteractions.map(i => ({
            ...i,
            subjectFull:       `${i.subject}\n${i.preview}`,
            participantsLabel: i.people.join(' · '),
        }));
    }

    get totalCount()  { return this.interactions.length; }
    get loggedLabel() { return `${this.totalCount} logged`; }

    handleFilter(event) {
        this.activeFilter = event.currentTarget.dataset.filter;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'view_detail') {
            const urlMap = {
                'i1': 'https://navatargroup11.lightning.force.com/lightning/n/navpeII__View_Interaction?c__params=%7B%22recId%22%3A%2200Ual00000HEtKcEAL%22%2C%22recType%22%3A%22Event%22%2C%22mode%22%3A%22view%22%7D',
                'i2': 'https://navatargroup11.lightning.force.com/lightning/n/navpeII__View_Interaction?c__params=%7B%22recId%22%3A%2200Tal00000nr3NgEAI%22%2C%22recType%22%3A%22Task%22%2C%22mode%22%3A%22view%22%7D',
                'i3': 'https://navatargroup11.lightning.force.com/lightning/n/navpeII__View_Interaction?c__params=%7B%22recId%22%3A%2200Tal00000nr7LhEAI%22%2C%22recType%22%3A%22Task%22%2C%22mode%22%3A%22view%22%7D',
                'i4': 'https://navatargroup11.lightning.force.com/lightning/n/navpeII__View_Interaction?c__params=%7B%22recId%22%3A%2200Ual00000HEx6TEAT%22%2C%22recType%22%3A%22Event%22%2C%22mode%22%3A%22view%22%7D',
                'i5': 'https://navatargroup11.lightning.force.com/lightning/n/navpeII__View_Interaction?c__params=%7B%22recId%22%3A%2200Tal00000nr7QXEAY%22%2C%22recType%22%3A%22Task%22%2C%22mode%22%3A%22view%22%7D',
                'i6': 'https://navatargroup11.lightning.force.com/lightning/n/navpeII__View_Interaction?c__params=%7B%22recId%22%3A%2200Tal00000nquLGEAY%22%2C%22recType%22%3A%22Task%22%2C%22mode%22%3A%22view%22%7D',
            };
            const url = urlMap[event.detail.row.id];
            if (url) {
                window.open(url, '_blank');
            }
        }
    }

    handleLoadAll() {}
}