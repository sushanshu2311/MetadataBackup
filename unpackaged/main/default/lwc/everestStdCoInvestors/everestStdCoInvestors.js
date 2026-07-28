import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Firm',          fieldName: 'firm',    type: 'text', initialWidth: 230 },
    { label: 'Type',          fieldName: 'fType',   type: 'text', initialWidth: 140 },
    { label: 'Contact',       fieldName: 'contact', type: 'text', initialWidth: 170 },
    { label: 'Status',        fieldName: 'status',  type: 'text', initialWidth: 180 },
    { label: 'Last Activity', fieldName: 'last',    type: 'text' },
];

const COINVESTORS = [
    { id: 'c1',  ls: 'active', firm: 'GIC Private Limited',          fType: 'SWF',           contact: 'Marcus Tan',       status: 'Soft Circle',         last: '16 Jun 2026' },
    { id: 'c2',  ls: 'active', firm: 'Hamilton Lane',                fType: 'LP',            contact: 'Sarah Okonkwo',    status: 'Soft Circle',         last: '15 Jun 2026' },
    { id: 'c3',  ls: 'active', firm: 'Pantheon Ventures',            fType: 'LP',            contact: 'Oliver Brennan',   status: 'Reviewing Materials', last: '13 Jun 2026' },
    { id: 'c4',  ls: 'active', firm: 'Harbourvest Partners',         fType: 'LP',            contact: 'Claire Dubois',    status: 'Reviewing Materials', last: '11 Jun 2026' },
    { id: 'c5',  ls: 'active', firm: 'Temasek Holdings',             fType: 'SWF',           contact: 'Wei Liang',        status: 'Soft Circle',         last: '10 Jun 2026' },
    { id: 'c6',  ls: 'active', firm: 'LGT Capital Partners',         fType: 'Family Office', contact: 'Franz Meier',      status: 'NDA Signed',          last: '6 Jun 2026' },
    { id: 'c7',  ls: 'active', firm: 'Stepstone Group',              fType: 'LP',            contact: 'Anna Svensson',    status: 'NDA Signed',          last: '4 Jun 2026' },
    { id: 'c8',  ls: 'active', firm: 'Pictet Alternative Advisors',  fType: 'Family Office', contact: 'Laurent Vidal',    status: 'Introductory Call',   last: '28 May 2026' },
    { id: 'c9',  ls: 'active', firm: 'Adams Street Partners',        fType: 'LP',            contact: 'Michael Gross',    status: 'Introductory Call',   last: '22 May 2026' },
    { id: 'c10', ls: 'active', firm: 'Mubadala Investment Company',  fType: 'SWF',           contact: 'Khalid Al Rashid', status: 'Introductory Call',   last: '19 May 2026' },
    { id: 'c11', ls: 'ai',     firm: 'Partners Group',               fType: 'LP',            contact: '—',                status: 'AI Recommended',      last: '—' },
    { id: 'c12', ls: 'ai',     firm: 'Alpinvest Partners',           fType: 'LP',            contact: '—',                status: 'AI Recommended',      last: '—' },
    { id: 'c13', ls: 'ai',     firm: 'Coller Capital',               fType: 'LP',            contact: '—',                status: 'AI Recommended',      last: '—' },
    { id: 'c14', ls: 'ai',     firm: 'Horsley Bridge Partners',      fType: 'Family Office', contact: '—',                status: 'AI Recommended',      last: '—' },
    { id: 'c15', ls: 'ai',     firm: 'Unigestion',                   fType: 'LP',            contact: '—',                status: 'AI Recommended',      last: '—' },
];

export default class EverestStdCoInvestors extends LightningElement {
    @track activeFilter = 'all';
    @track searchTerm = '';

    columns = COLUMNS;
    coInvestors = COINVESTORS;

    get filteredCoInvestors() {
        let rows = this.coInvestors;
        if (this.activeFilter !== 'all') {
            rows = rows.filter(c => c.ls === this.activeFilter);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(c => c.firm.toLowerCase().includes(s));
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