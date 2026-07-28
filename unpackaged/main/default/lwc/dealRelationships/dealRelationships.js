// AA-831: Interactions column right-aligned via cellAttributes
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const RELATIONSHIPS = [
    { id: 'r1', name: 'Thomas Bennett',   group: 'Internal',     role: 'Deal Lead, Partner',    touchpoint: 'Today',   interactions: '12' },
    { id: 'r2', name: 'Sarah Patel',      group: 'Internal',     role: 'Analyst',               touchpoint: '14 Jun',  interactions: '7'  },
    { id: 'r3', name: 'Michael Hartley',  group: 'Banker',       role: 'MD Healthcare, Source', touchpoint: 'Today',   interactions: '8'  },
    { id: 'r4', name: 'Dr. Marcus Webb',  group: 'DD & Experts', role: 'Regulatory Expert',     touchpoint: 'Today',   interactions: '3'  },
    { id: 'r5', name: 'Karen Philips',    group: 'DD & Experts', role: 'Commercial DD Lead',    touchpoint: '03 Jun',  interactions: '2'  },
    { id: 'r6', name: 'Kirkland & Ellis', group: 'DD & Experts', role: 'Legal DD',              touchpoint: '28 May',  interactions: '4'  },
    { id: 'r7', name: 'Mark Hargreaves',  group: 'Target',       role: 'CEO, 12 years',         touchpoint: '20 May',  interactions: '5'  },
    { id: 'r8', name: 'Sarah Chen',       group: 'Target',       role: 'CFO, joined 2023',      touchpoint: '20 May',  interactions: '5'  },
];

export default class DealRelationships extends LightningElement {
    @api recordId;
    relationships = RELATIONSHIPS;

    relColumns = [
        { label: 'Person',          fieldName: 'name',         type: 'text',   wrapText: false },
        { label: 'Group',           fieldName: 'group',        type: 'text',   initialWidth: 130 },
        { label: 'Role',            fieldName: 'role',         type: 'text',   wrapText: true },
        { label: 'Last Touchpoint', fieldName: 'touchpoint',   type: 'text',   initialWidth: 130 },
        { label: 'Interactions',    fieldName: 'interactions', type: 'text',   initialWidth: 110 },
    ];

    goToRI() {
        this.dispatchEvent(new ShowToastEvent({ title: 'Full Relationship Intelligence', variant: 'info', mode: 'dismissible' }));
    }
}