import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PEOPLE = [
    { id: 'p1', name: 'Thomas Bennett',    role: 'Deal Lead, Partner',    org: 'Ironwood Capital',          initials: 'TB', touchpoint: 'Today',    group: 'Internal',     email: 'tbennett@ironwoodcap.com',    interactions: 12 },
    { id: 'p2', name: 'Sarah Patel',       role: 'Analyst',               org: 'Ironwood Capital',          initials: 'SP', touchpoint: '14 Jun',   group: 'Internal',     email: 'spatel@ironwoodcap.com',      interactions: 7  },
    { id: 'p3', name: 'Michael Hartley',   role: 'MD Healthcare, Source', org: 'Houlihan Lokey',            initials: 'MH', touchpoint: 'Today',    group: 'Banker',       email: 'mhartley@hl.com',             interactions: 8  },
    { id: 'p4', name: 'Dr. Marcus Webb',   role: 'Regulatory Expert',     org: 'Webb Regulatory Advisory',  initials: 'MW', touchpoint: 'Today',    group: 'DD & Experts', email: 'm.webb@webbadvisory.com',     interactions: 3  },
    { id: 'p5', name: 'Karen Philips',     role: 'Commercial DD Lead',    org: 'L.E.K. Consulting',         initials: 'KP', touchpoint: '03 Jun',   group: 'DD & Experts', email: 'k.philips@lek.com',           interactions: 2  },
    { id: 'p6', name: 'Kirkland & Ellis',  role: 'Legal DD',              org: 'Legal Counsel',             initials: 'KE', touchpoint: '28 May',   group: 'DD & Experts', email: 'deal-team@kirkland.com',      interactions: 4  },
    { id: 'p7', name: 'Mark Hargreaves',   role: 'CEO, 12 years',         org: 'Apex Care Partners',        initials: 'MH', touchpoint: '20 May',   group: 'Target',       email: 'm.hargreaves@apexcare.co.uk', interactions: 5  },
    { id: 'p8', name: 'Sarah Chen',        role: 'CFO, joined 2023',      org: 'Apex Care Partners',        initials: 'SC', touchpoint: '20 May',   group: 'Target',       email: 's.chen@apexcare.co.uk',       interactions: 5  },
];

const RI_INTEL = [
    { id: 'ri1', iconName: 'utility:warning', title: 'Karen Philips (L.E.K.) has had no logged interaction in 12 days',               body: 'Commercial DD report expected 20 Jun — 6 days away. Last contact was email 03 Jun. Consider a check-in call to confirm timeline before the management meeting.' },
    { id: 'ri2', iconName: 'utility:warning', title: 'Mark Hargreaves not contacted in 26 days — retention package still unconfirmed', body: 'Last interaction was the 20 May management meeting. Verbal retention interest confirmed but no written terms agreed. Advent have approached him. Recommend direct contact before 18 Jun.' },
    { id: 'ri3', iconName: 'utility:add',     title: 'Warm path to Prof. Helen Cross (CMS specialist) not yet activated',              body: 'Prof. Cross identified as a connection via Jonathan Reid. Given the CMS gap flagged today, her input would be directly relevant.' },
    { id: 'ri4', iconName: 'utility:info',    title: 'Kirkland & Ellis — all interactions email only since LOI',                       body: 'No verbal update logged since LOI submission. The CMS gap falls within their scope. A call to brief them before 18 Jun would be useful.' },
];

export default class DealRiTab extends LightningElement {
    @api recordId;
    @track riFilter = 'all';

    riIntelItems = RI_INTEL;

    fullPeopleColumns = [
        { label: 'Person',          fieldName: 'name',         type: 'text',   wrapText: true },
        { label: 'Group',           fieldName: 'group',        type: 'text',   initialWidth: 130 },
        { label: 'Role',            fieldName: 'role',         type: 'text',   wrapText: true },
        { label: 'Email',           fieldName: 'email',        type: 'email' },
        { label: 'Last Touchpoint', fieldName: 'touchpoint',   type: 'text',   initialWidth: 130 },
        { label: 'Interactions',    fieldName: 'interactions', type: 'number', initialWidth: 110 },
        {
            type: 'action',
            typeAttributes: { rowActions: [
                { label: 'Log interaction', name: 'log'  },
                { label: 'View profile',    name: 'view' },
            ]},
        },
    ];

    get rfAll()      { return this.riFilter === 'all'          ? 'brand' : 'neutral'; }
    get rfInternal() { return this.riFilter === 'Internal'     ? 'brand' : 'neutral'; }
    get rfBanker()   { return this.riFilter === 'Banker'       ? 'brand' : 'neutral'; }
    get rfDd()       { return this.riFilter === 'DD & Experts' ? 'brand' : 'neutral'; }
    get rfTarget()   { return this.riFilter === 'Target'       ? 'brand' : 'neutral'; }

    get filteredPeople() {
        return this.riFilter === 'all'
            ? PEOPLE
            : PEOPLE.filter(p => p.group === this.riFilter);
    }

    handleRIFilter(event) {
        const val = event.currentTarget.dataset.value;
        this.riFilter = val;
        this.dispatchEvent(new ShowToastEvent({ title: `People filter — ${val === 'all' ? 'All groups' : val}`, variant: 'info', mode: 'dismissible' }));
    }

    handlePersonAction(event) {
        const action = event.detail.action.name;
        const row    = event.detail.row;
        this.dispatchEvent(new ShowToastEvent({ title: `${action === 'log' ? 'Log interaction' : 'View profile'} — ${row.name}`, variant: 'info', mode: 'dismissible' }));
    }
}