// AA-835: Removed Upload button — not present in design reference
import { LightningElement, api } from 'lwc';

const DOCUMENTS = [
    { id: 'd1', abbr: 'D', name: 'Regulatory Expert Report — Dr. Marcus Webb',  meta: 'Received Today · PDF, 47 pages',            status: 'Analysed' },
    { id: 'd2', abbr: 'A', name: 'Management Meeting Briefing — 18 Jun 2026',   meta: 'AI Generated · Today',                       status: 'AI'       },
    { id: 'd3', abbr: 'A', name: 'IC Review Pack — Project Everest',             meta: 'AI Generated · 28 May 2026 · 34 pages',      status: 'Approved' },
    { id: 'd4', abbr: 'D', name: 'CIM — Apex Care Partners',                    meta: 'Received 12 Feb 2026 · PDF, 94 pages',       status: 'Analysed' },
    { id: 'd5', abbr: 'X', name: 'Financial Model v3',                          meta: 'Internal · Updated 02 Jun 2026',             status: 'Manual'   },
    { id: 'd6', abbr: 'D', name: 'Legal DD Report — Kirkland & Ellis',          meta: 'Expected 16 Jun 2026',                       status: 'Awaited'  },
];

export default class DealDocumentsTab extends LightningElement {
    @api recordId;
    documents = DOCUMENTS;
}