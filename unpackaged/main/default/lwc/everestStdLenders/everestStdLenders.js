import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Firm',          fieldName: 'firm',    type: 'text', initialWidth: 220 },
    { label: 'Type',          fieldName: 'fType',   type: 'text', initialWidth: 130 },
    { label: 'Contact',       fieldName: 'contact', type: 'text', initialWidth: 170 },
    { label: 'Status',        fieldName: 'status',  type: 'text', initialWidth: 160 },
    { label: 'Last Activity', fieldName: 'last',    type: 'text' },
];

const LENDERS = [
    { id: 'l1', ls: 'active', firm: 'Ares Management',          fType: 'Unitranche', contact: 'David Saunders',  status: 'Engaged',        last: '14 Jun 2026' },
    { id: 'l2', ls: 'active', firm: 'Owl Rock Capital',         fType: 'Senior',     contact: 'Rachel Moore',    status: 'Contacted',      last: '10 Jun 2026' },
    { id: 'l3', ls: 'active', firm: 'Golub Capital',            fType: 'Unitranche', contact: 'James Whitfield', status: 'Contacted',      last: '7 Jun 2026' },
    { id: 'l4', ls: 'ai',     firm: 'HPS Investment Partners',  fType: 'Mezz',       contact: '—',               status: 'AI Recommended', last: '—' },
    { id: 'l5', ls: 'ai',     firm: 'Benefit Street Partners',  fType: 'Senior',     contact: '—',               status: 'AI Recommended', last: '—' },
    { id: 'l6', ls: 'ai',     firm: 'Monroe Capital',           fType: 'Mezz',       contact: '—',               status: 'AI Recommended', last: '—' },
];

export default class EverestStdLenders extends LightningElement {
    @track activeFilter = 'all';
    @track searchTerm = '';

    columns = COLUMNS;
    lenders = LENDERS;

    get filteredLenders() {
        let rows = this.lenders;
        if (this.activeFilter !== 'all') {
            rows = rows.filter(l => l.ls === this.activeFilter);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(l => l.firm.toLowerCase().includes(s));
        }
        return rows;
    }

    get fAll()    { return this.activeFilter === 'all'    ? 'brand' : 'neutral'; }
    get fAi()     { return this.activeFilter === 'ai'     ? 'brand' : 'neutral'; }
    get fActive() { return this.activeFilter === 'active' ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.target.dataset.filter;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
    }
}