import { LightningElement, track } from 'lwc';

const COLUMNS = [
    { label: 'Task', fieldName: 'taskDisplay', type: 'text', wrapText: true },
];

const TASKS = [
    { id: 't1', subject: 'Instruct Kirkland on CMS supervision gap',                   due: 'Due 18 Jun 2026 · T. Bennett',       status: 'Open',      mine: true },
    { id: 't2', subject: 'Request written retention terms — Hargreaves',               due: 'Due 19 Jun 2026 · T. Bennett',       status: 'Open',      mine: true },
    { id: 't3', subject: 'Update financial model — CMS exposure',                      due: 'Due 20 Jun 2026 · S. Patel',         status: 'Open',      mine: false },
    { id: 't4', subject: 'Confirm final bid submission checklist with Houlihan Lokey', due: 'Due 25 Jun 2026 · T. Bennett',       status: 'Open',      mine: false },
    { id: 't5', subject: 'Review Dr. Webb regulatory report',                          due: 'Completed 18 Jun 2026 · T. Bennett', status: 'Completed', mine: true },
];

export default class EverestStdTasks extends LightningElement {
    @track tasks = TASKS.map(t => ({ ...t }));
    @track activeFilter = 'all';
    @track searchTerm = '';

    columns = COLUMNS;

    get filteredTasks() {
        let rows = this.tasks;
        if (this.activeFilter === 'mine') {
            rows = rows.filter(t => t.mine);
        }
        if (this.searchTerm) {
            const s = this.searchTerm.toLowerCase();
            rows = rows.filter(t => t.subject.toLowerCase().includes(s));
        }
        // fold the v10 details (due · owner) into the single column
        return rows.map(t => ({ ...t, taskDisplay: `${t.subject} — ${t.due}` }));
    }

    // completed tasks are the "checked" rows
    get completedIds() {
        return this.tasks.filter(t => t.status === 'Completed').map(t => t.id);
    }

    get openLabel() {
        const open = this.filteredTasks.filter(t => t.status === 'Open').length;
        return `${open} Open`;
    }

    get fAll()  { return this.activeFilter === 'all'  ? 'brand' : 'neutral'; }
    get fMine() { return this.activeFilter === 'mine' ? 'brand' : 'neutral'; }

    handleFilter(event) {
        this.activeFilter = event.target.dataset.filter;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
    }

    handleRowSelection(event) {
        const selected = new Set(event.detail.selectedRows.map(r => r.id));
        const visible = new Set(this.filteredTasks.map(t => t.id));
        this.tasks = this.tasks.map(t => {
            if (!visible.has(t.id)) return t; // don't touch rows hidden by filter/search
            return { ...t, status: selected.has(t.id) ? 'Completed' : 'Open' };
        });
    }

    handleAdd() {
        const n = this.tasks.length + 1;
        this.tasks = [
            { id: `tnew${n}`, subject: 'New task', due: 'Due —', status: 'Open', mine: true },
            ...this.tasks,
        ];
    }
}