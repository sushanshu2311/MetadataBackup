import { LightningElement, track } from 'lwc';

// Task column has no initialWidth → fills all remaining space
const OPEN_COLUMNS = [
    { label: 'Task',   fieldName: 'subject', type: 'text', wrapText: true ,initialWidth: 150},
    { label: 'Due',    fieldName: 'due',     type: 'text', initialWidth: 50,
      cellAttributes: { class: { fieldName: 'dueCss' } } },
    { label: 'Owner',  fieldName: 'owner',   type: 'text', initialWidth: 50 },
    { label: 'Source', fieldName: 'source',  type: 'text', initialWidth: 50 },
];

const DONE_COLUMNS = [
    { label: 'Task',   fieldName: 'subject', type: 'text', wrapText: true },
    { label: 'Done',   fieldName: 'due',     type: 'text', initialWidth: 150 },
    { label: 'Source', fieldName: 'source',  type: 'text', initialWidth: 110 },
];

const TASKS = [
    { id: 't1', subject: 'Instruct legal on CMS supervision risk — 3 sites', owner: 'T. Bennett', due: 'Overdue, 10 Jun', isOverdue: true,  isDone: false, source: 'AI',     mine: true  },
    { id: 't2', subject: 'Prepare management meeting agenda — regulatory',   owner: 'T. Bennett', due: 'Due 12 Jun',      isOverdue: false, isDone: false, source: 'AI',     mine: true  },
    { id: 't3', subject: 'Confirm Mark Hargreaves retention terms',          owner: 'T. Bennett', due: 'Due 16 Jun',      isOverdue: false, isDone: false, source: 'MANUAL', mine: true  },
    { id: 't4', subject: 'Run CMS downside scenario in model',               owner: 'S. Patel',   due: 'Due 14 Jun',      isOverdue: false, isDone: false, source: 'AI',     mine: false },
    { id: 't5', subject: 'Receive and log Dr. Webb expert report',           owner: 'T. Bennett', due: 'Done Today',      isOverdue: false, isDone: true,  source: 'AI',     mine: true  },
    { id: 't6', subject: 'IC Review approved — go to LOI',                  owner: 'T. Bennett', due: 'Done 28 May',     isOverdue: false, isDone: true,  source: 'MANUAL', mine: true  },
    { id: 't7', subject: 'LOI submitted to Michael Hartley',                 owner: 'T. Bennett', due: 'Done 14 Mar',     isOverdue: false, isDone: true,  source: 'AI',     mine: true  },
];

export default class NavatarActionItems extends LightningElement {
    @track activeView = 'mine';
    @track searchTerm = '';
    @track _tasks = TASKS.map(t => ({ ...t }));

    openColumns = OPEN_COLUMNS;
    doneColumns  = DONE_COLUMNS;

    get isMine() { return this.activeView === 'mine'; }
    get mineVariant() { return this.activeView === 'mine' ? 'brand' : 'neutral'; }
    get allVariant()  { return this.activeView === 'all'  ? 'brand' : 'neutral'; }

    get _filtered() {
        const base = this.activeView === 'mine'
            ? this._tasks.filter(t => t.mine)
            : this._tasks;
        const term = (this.searchTerm || '').toLowerCase();
        return term ? base.filter(t => t.subject.toLowerCase().includes(term)) : base;
    }

    get openTasks()      { return this._filtered.filter(t => !t.isDone); }
    get doneTasks()      { return this._filtered.filter(t =>  t.isDone); }
    get openCount()      { return this.openTasks.length; }
    get openLabel()      { return `${this.openCount} OPEN`; }
    get hasOpenTasks()      { return this.openTasks.length > 0; }
    get hasCompletedTasks() { return this.doneTasks.length > 0; }
    get completedCount()    { return this.doneTasks.length; }
    get completedRowIds()   { return this.doneTasks.map(t => t.id); }

    get openTasksData() {
        return this.openTasks.map(t => ({
            ...t,
            dueCss: t.isOverdue ? 'slds-text-color_error' : 'slds-text-color_brand',
        }));
    }

    get doneTasksData() { return this.doneTasks; }

    handleMine()  { this.activeView = 'mine'; }
    handleAll()   { this.activeView = 'all'; }

    handleSearch(event) { this.searchTerm = event.detail.value; }

    handleOpenRowSelection(event) {
        event.detail.selectedRows.forEach(row => {
            this._tasks = this._tasks.map(t =>
                t.id === row.id ? { ...t, isDone: true, due: 'Done Today' } : t
            );
        });
    }

    handleCompletedRowSelection(event) {
        const stillSelected = new Set(event.detail.selectedRows.map(r => r.id));
        this._tasks = this._tasks.map(t =>
            t.isDone && !stillSelected.has(t.id) ? { ...t, isDone: false } : t
        );
    }
}