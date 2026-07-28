import { LightningElement, track } from 'lwc';

const COLUMNS = [
    {
        label: 'Person',
        fieldName: 'name',
        type: 'text',
        wrapText: true,
        initialWidth: 220,
        cellAttributes: { class: { fieldName: 'personCellClass' } }
    },
    {
        label: 'Group',
        fieldName: 'group',
        type: 'groupBadge',
        initialWidth: 150
    },
    {
        label: 'Role',
        fieldName: 'role',
        type: 'text',
        wrapText: true
    },
    {
        label: 'Contact',
        fieldName: 'contactUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'contact' }, target: '_blank' },
        initialWidth: 240
    },
    {
        label: 'Last Touchpoint',
        fieldName: 'lastTouchpoint',
        type: 'text',
        wrapText: true,
        initialWidth: 160
    },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'View detail', name: 'view' }] }
    }
];

const RAW_PEOPLE = [
    {
        id: 'tb',  g: 'internal',
        name: 'Thomas Bennett',    org: 'Ironwood Capital',
        group: 'Internal',         role: 'Deal Lead, Partner',
        contact: 'tbennett@ironwoodcap.com',
        last: '18 Jun 2026',       lastType: 'MEETING',
        how: 'Thomas is the Ironwood deal lead on Project Everest, having sourced the deal via Michael Hartley at Houlihan Lokey. He attended the management presentation on 12 June and is managing all DD workstreams.',
        deals: 'Project Lighthouse (Won), Project Beacon (Lost — LOI stage), Project Atlas (Won)',
        docs: 'CIM, Dr. Webb Regulatory Report, L.E.K. Financial Model v3'
    },
    {
        id: 'sp',  g: 'internal',
        name: 'Sarah Patel',       org: 'Ironwood Capital',
        group: 'Internal',         role: 'Associate',
        contact: 'spatel@ironwoodcap.com',
        last: '18 Jun 2026',       lastType: 'EMAIL',
        how: 'Sarah is the deal associate supporting Thomas Bennett on Project Everest. She attended the DD kick-off call and is coordinating the financial model update with L.E.K.',
        deals: 'Project Atlas (Won), Project Mesa (Won)',
        docs: 'L.E.K. Financial Model v3, Management Accounts Q1 2026'
    },
    {
        id: 'mh',  g: 'external',
        name: 'Michael Hartley',   org: 'Houlihan Lokey',
        group: 'Banker',           role: 'MD, Deal Lead',
        contact: 'mhartley@hl.com',
        last: '17 Jun 2026',       lastType: 'EMAIL',
        how: 'Michael sourced Project Everest for Ironwood Capital in January 2026. He has a 6-year relationship with Thomas Bennett across 4 completed transactions. He introduced Mark Hargreaves to Ironwood at the management presentation.',
        deals: 'Project Lighthouse, Project Beacon, Project Atlas, Project Mesa',
        docs: 'CIM, Process Letter, Dr. Webb Regulatory Report'
    },
    {
        id: 'kp',  g: 'external',
        name: 'Kate Patterson',    org: 'Houlihan Lokey',
        group: 'Banker',           role: 'Analyst',
        contact: 'kpatterson@hl.com',
        last: '16 Jun',            lastType: 'EMAIL',
        how: 'Kate is supporting Michael Hartley on the Project Everest process. She manages the data room and process communications.',
        deals: 'Project Everest only',
        docs: 'CIM, Process Letter'
    },
    {
        id: 'mw',  g: 'external',
        name: 'Dr. Marcus Webb',   org: 'Webb Regulatory Advisory',
        group: 'DD & Experts',     role: 'Regulatory Expert',
        contact: 'm.webb@webbreg.co.uk',
        last: '18 Jun 2026',       lastType: 'DOCUMENT',
        how: 'Dr. Webb was engaged by Ironwood Capital to conduct regulatory DD on Project Everest. His report identified the critical CMS supervision gap affecting three clinic sites.',
        deals: 'First Ironwood engagement',
        docs: 'Regulatory DD Report — Dr. M. Webb'
    },
    {
        id: 'sc',  g: 'external',
        name: 'Sandra Chen',       org: 'Kirkland & Ellis',
        group: 'DD & Experts',     role: 'Legal DD Lead',
        contact: 's.chen@kirkland.com',
        last: '10 Jun',            lastType: 'MEETING',
        how: 'Sandra is leading the legal DD for Ironwood Capital on Project Everest. She attended the DD kick-off call on 10 June. Her formal legal report is overdue — expected 16 June.',
        deals: 'Project Lighthouse, Project Atlas',
        docs: 'Legal DD Draft (AI Summary)'
    },
    {
        id: 'dr',  g: 'external',
        name: 'David Ross',        org: 'L.E.K. Consulting',
        group: 'DD & Experts',     role: 'Financial DD Lead',
        contact: 'd.ross@lek.com',
        last: '16 Jun',            lastType: 'EMAIL',
        how: 'David is leading financial DD for Ironwood Capital. He delivered the v3 financial model on 16 June confirming normalized EBITDA of $10.5M.',
        deals: 'Project Lighthouse, Project Everest',
        docs: 'L.E.K. Financial Model v3'
    },
    {
        id: 'mha', g: 'external',
        name: 'Mark Hargreaves',   org: 'Apex Care Partners',
        group: 'Target',           role: 'CEO',
        contact: 'm.hargreaves@apexcare.co.uk',
        last: '12 Jun',            lastType: 'MEETING',
        how: 'Mark is the CEO and founder of Apex Care Partners. He controls 14 of 22 NHS referral relationships personally. He has given verbal retention commitment but has been connecting with Advent International on LinkedIn in the past 10 days.',
        deals: 'Target on Project Everest',
        docs: 'Management Accounts Q1 2026, CIM'
    },
    {
        id: 'ra',  g: 'ai',
        name: 'Robert Ashford',    org: 'Apex Care Partners',
        group: 'In Navatar',       role: 'Non-Executive Director',
        contact: 'r.ashford@apexcare.co.uk',
        last: 'Apr 2022',          lastType: 'EMAIL',
        how: 'Robert has been a NED at Apex Care Partners since 2019. He has an 8-year personal relationship with Mark Hargreaves. He was introduced to Ironwood Capital by Michael Hartley at the 2022 HL process and is an existing Navatar contact.',
        deals: 'Not yet linked to Project Everest',
        docs: 'Identified via Apex Care board filings'
    },
    {
        id: 'rm',  g: 'ai',
        name: 'Dr. Rachel Morrison', org: 'NHS CMS Compliance Advisory',
        group: 'Not in Navatar',   role: 'CMS Supervision Expert',
        contact: 'AI sourced',
        last: 'No record',         lastType: '',
        how: 'Rachel is an NHS CMS compliance specialist referenced in footnotes of Dr. Webb\'s regulatory report. She has worked on CMS supervision remediation at two similar UK outpatient businesses in 2024–25. Warm path: Thomas Bennett — co-panellists at NHS Advisory Forum, Nov 2023.',
        deals: 'Not yet involved in any Ironwood deals',
        docs: 'Referenced in Dr. Webb Regulatory Report (footnote p.31)'
    },
    {
        id: 'jw',  g: 'ai',
        name: 'James Wren',        org: 'Advent International',
        group: 'Not in Navatar',   role: 'Associate, Healthcare PE',
        contact: 'AI sourced',
        last: 'No record',         lastType: '',
        how: 'James is confirmed on Advent\'s Project Everest bid team via LinkedIn activity and a reference in Houlihan Lokey\'s process email. Understanding Advent\'s team composition informs competitive positioning.',
        deals: 'Opponent on Project Everest (Advent bid team)',
        docs: 'Referenced in HL process email'
    }
];

const PEOPLE = RAW_PEOPLE.map(p => ({
    ...p,
    groupVariant: p.group === 'In Navatar' ? 'brand' : 'neutral',
    contactUrl: p.contact.includes('@') ? `mailto:${p.contact}` : null,
    lastTouchpoint: p.lastType ? `${p.last} · ${p.lastType}` : p.last
}));

export default class EverestStdTeam extends LightningElement {
    @track activeFilter = 'all';
    @track searchTerm = '';
    @track selectedPerson = null;

    columns = COLUMNS;
    people = PEOPLE;

    renderedCallback() {
        // Defer one microtask so lightning-datatable finishes painting its rows
        Promise.resolve().then(() => this._styleGroupButtons());
    }

    _styleGroupButtons() {
        const groupStyles = {
            'Internal':       { background: '#e8e8e8', borderColor: '#c9c9c9', color: '#3e3e3c' },
            'Banker':         { background: '#e8e8e8', borderColor: '#c9c9c9', color: '#3e3e3c' },
            'Target':         { background: '#e8e8e8', borderColor: '#c9c9c9', color: '#3e3e3c' },
            'DD & Experts':   { background: '#e8e8e8', borderColor: '#c9c9c9', color: '#3e3e3c' },
            'In Navatar':     { background: '#9b1c49', borderColor: '#0176d3', color: '#ffffff'  },
            'Not in Navatar': { background: 'transparent', borderColor: '#c9c9c9', color: '#3e3e3c' }
        };

        const datatable = this.template.querySelector('lightning-datatable');
        if (!datatable) return;

        datatable.querySelectorAll('lightning-button').forEach(lb => {
            const s = groupStyles[lb.label];
            if (!s) return;
            const btn = lb.querySelector('button');
            if (!btn) return;
            btn.style.background  = s.background;
            btn.style.borderColor = s.borderColor;
            btn.style.color       = s.color;
        });
    }

    get filteredPeople() {
        let rows = this.people;
        if (this.activeFilter !== 'all') {
            rows = rows.filter(p => p.g === this.activeFilter);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(p =>
                p.name.toLowerCase().includes(s) ||
                p.org.toLowerCase().includes(s) ||
                p.role.toLowerCase().includes(s)
            );
        }
        return rows;
    }

    get fAll()      { return this.activeFilter === 'all'      ? 'brand' : 'neutral'; }
    get fExternal() { return this.activeFilter === 'external' ? 'brand' : 'neutral'; }
    get fInternal() { return this.activeFilter === 'internal' ? 'brand' : 'neutral'; }
    get fAi()       { return this.activeFilter === 'ai'       ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.target.dataset.filter;
        this.selectedPerson = null;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
        this.selectedPerson = null;
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'view') {
            this.selectedPerson = event.detail.row;
        }
    }

    handleCloseDetail() {
        this.selectedPerson = null;
    }
}