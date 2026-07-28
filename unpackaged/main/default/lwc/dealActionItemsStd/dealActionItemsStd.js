import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const OPEN_COLUMNS = [
    { label: 'Task',   fieldName: 'subject',      type: 'text',  wrapText: true },
    { label: 'Due',    fieldName: 'dueLabel',      type: 'text',  cellAttributes: { class: { fieldName: 'dueLabelCss' } } },
    { label: 'Owner',  fieldName: 'ownerInitials', type: 'text'},
    { label: 'Source', fieldName: 'source',        type: 'text'  },
];

const COMPLETED_COLUMNS = [
    { label: 'Task',   fieldName: 'subject',  type: 'text', wrapText: true },
    { label: 'Done',   fieldName: 'dueLabel', type: 'text', initialWidth: 130 },
    { label: 'Source', fieldName: 'source',   type: 'text', initialWidth: 90  },
];

const PLACEHOLDER_TASKS = [
    { id: 'p1', subject: 'Attend management meeting — Birmingham 28 Feb 2026', dueLabel: '28 Feb 2026', ownerInitials: 'Thomas Bennett', isCompleted: false, source: 'MANUAL' },
    { id: 'p2', subject: 'Review CIM analysis and prepare meeting questions',   dueLabel: '25 Feb 2026', ownerInitials: 'Sarah Okonkwo',  isCompleted: false, source: 'AI'     },
    { id: 'p3', subject: 'Research Apex Care management team ahead of meeting', dueLabel: '25 Feb 2026', ownerInitials: 'Sarah Okonkwo',  isCompleted: false, source: 'AI'     },
    { id: 'p4', subject: 'Acknowledge teaser — Michael Hartley',               dueLabel: '05 Feb 2026', ownerInitials: 'Thomas Bennett', isCompleted: true,  source: 'AI'     },
    { id: 'p5', subject: 'Request NDA and process letter',                      dueLabel: '10 Feb 2026', ownerInitials: 'Sarah Okonkwo',  isCompleted: true,  source: 'MANUAL' },
    { id: 'p6', subject: 'Review CIM and prepare initial analysis',             dueLabel: '20 Feb 2026', ownerInitials: 'Sarah Okonkwo',  isCompleted: true,  source: 'AI'     },
];

export default class DealActionItemsStd extends LightningElement {
    @api recordId;
    @track mineOnly    = false;
    @track searchTerm  = '';
    @track _tasks      = PLACEHOLDER_TASKS.map(t => ({ ...t }));

    // ── Filter state ─────────────────────────────────────────────────────────

    get mineVariant() { return this.mineOnly  ? 'brand' : 'neutral'; }
    get allVariant()  { return !this.mineOnly ? 'brand' : 'neutral'; }

    get _filtered() {
        const base = this.mineOnly
            ? this._tasks.filter(t => t.ownerInitials === 'Thomas Bennett')
            : this._tasks;
        const term = (this.searchTerm || '').toLowerCase();
        return term ? base.filter(t => t.subject.toLowerCase().includes(term)) : base;
    }

    get openTasks()         { return this._filtered.filter(t => !t.isCompleted); }
    get completedTasks()    { return this._filtered.filter(t =>  t.isCompleted); }
    get openLabel()         { return `${this.openTasks.length} OPEN`; }
    get hasOpenTasks()      { return this.openTasks.length > 0; }
    get hasCompletedTasks() { return this.completedTasks.length > 0; }
    get completedCount()    { return this.completedTasks.length; }
    get completedRowIds()   { return this.completedTasks.map(t => t.id); }

    get openColumns()      { return OPEN_COLUMNS; }
    get completedColumns() { return COMPLETED_COLUMNS; }

    // ── Decorated task list with due-label CSS ────────────────────────────────

    get decoratedOpenTasks() {
        return this.openTasks.map(t => ({
            ...t,
            dueLabelCss: t.dueLabel.toLowerCase().startsWith('overdue')
                ? 'slds-text-body_small slds-text-color_error'
                : 'slds-text-body_small slds-text-color_weak'
        }));
    }

    get allDecoratedTasks() {
        return this._filtered.map(t => ({
            ...t,
            dueLabelCss: t.dueLabel.toLowerCase().startsWith('overdue')
                ? 'slds-text-body_small slds-text-color_error'
                : 'slds-text-body_small slds-text-color_weak'
        }));
    }

    // ── Handlers ─────────────────────────────────────────────────────────────

    _notify(message) {
        // this.dispatchEvent(new ShowToastEvent({ title: 'Action Items', message, variant: 'info' }));
    }

    handleToggle(event) {
        this.mineOnly = event.currentTarget.dataset.mode === 'mine';
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value;
    }

    handleAdd() {
        this._notify('Add new action item');
    }

    handleOpenRowSelection(event) {
        event.detail.selectedRows.forEach(row => {
            const task = this._tasks.find(t => t.id === row.id);
            this._tasks = this._tasks.map(t =>
                t.id === row.id ? { ...t, isCompleted: true, dueLabel: 'Done Today' } : t
            );
            this._notify(`Completed: ${task ? task.subject.slice(0, 40) : ''}`);
        });
    }

    handleCompletedRowSelection(event) {
        const stillSelected = new Set(event.detail.selectedRows.map(r => r.id));
        this._tasks = this._tasks.map(t => {
            if (t.isCompleted && !stillSelected.has(t.id)) {
                this._notify(`Reopened: ${t.subject.slice(0, 40)}`);
                return { ...t, isCompleted: false };
            }
            return t;
        });
    }
}