import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getActionItems     from '@salesforce/apex/DealPageController.getActionItems';
import toggleTaskComplete from '@salesforce/apex/DealPageController.toggleTaskComplete';

const PLACEHOLDER_TASKS = [
    { id: 'p1', subject: 'Instruct legal on CMS supervision risk — 3 sites', dueDate: '2026-06-10', doneDate: null,     ownerInitials: 'T. Bennett', isCompleted: false, isOverdue: true,  source: 'AI'     },
    { id: 'p2', subject: 'Prepare management meeting agenda — regulatory',    dueDate: '2026-06-12', doneDate: null,     ownerInitials: 'T. Bennett', isCompleted: false, isOverdue: false, source: 'AI'     },
    { id: 'p3', subject: 'Confirm Mark Hargreaves retention terms',           dueDate: '2026-06-16', doneDate: null,     ownerInitials: 'T. Bennett', isCompleted: false, isOverdue: false, source: 'Manual' },
    { id: 'p4', subject: 'Run CMS downside scenario in model',                dueDate: '2026-06-14', doneDate: null,     ownerInitials: 'S. Patel',   isCompleted: false, isOverdue: false, source: 'AI'     },
    { id: 'p5', subject: 'Receive and log Dr. Webb expert report',            dueDate: null,         doneDate: 'Today',  ownerInitials: 'T. Bennett', isCompleted: true,  isOverdue: false, source: 'AI'     },
    { id: 'p6', subject: 'IC Review approved — go to LOI',                   dueDate: null,         doneDate: '28 May', ownerInitials: 'T. Bennett', isCompleted: true,  isOverdue: false, source: 'Manual' },
    { id: 'p7', subject: 'LOI submitted to Michael Hartley',                  dueDate: null,         doneDate: '14 Mar', ownerInitials: 'T. Bennett', isCompleted: true,  isOverdue: false, source: 'AI'     },
];

export default class DealActionItems extends LightningElement {
    @api recordId;
    @track mineOnly = true;
    @track _cn = '';
    _cnTimer = null;
    _wiredResult;

    @wire(getActionItems, { recordId: '$recordId', mineOnly: '$mineOnly' })
    wiredTasks(result) { this._wiredResult = result; }

    get rawTasks() {
        const data = this._wiredResult?.data;
        return (data && data.length > 0) ? data : PLACEHOLDER_TASKS;
    }

    get tasks() {
        return this.rawTasks.map(t => ({
            ...t,
            tcbCss:   t.isCompleted ? 'tcb done' : t.isOverdue ? 'tcb over' : 'tcb',
            tnCss:    t.isCompleted ? 'tn tnd'   : 'tn',
            dueCss:   t.isOverdue   ? 'td2 tdo'  : 'td2',
            dueLabel: t.isOverdue
                        ? `Overdue, ${this._fmtDate(t.dueDate)}`
                        : t.dueDate ? `Due ${this._fmtDate(t.dueDate)}` : '',
            doneLabel: t.doneDate ? `Done ${t.doneDate}` : 'Done',
        }));
    }

    _fmtDate(iso) {
        if (!iso) return '';
        try { return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' }); }
        catch { return iso; }
    }

    get openTasks()      { return this.tasks.filter(t => !t.isCompleted && (!this.mineOnly || ['T. Bennett', 'TB'].includes(t.ownerInitials))); }
    get completedTasks() { return this.tasks.filter(t =>  t.isCompleted); }
    get openLabel()      { return `${this.openTasks.length} Open`; }
    get hasCompleted()   { return this.completedTasks.length > 0; }
    get completedCount() { return this.completedTasks.length; }
    get isEmpty()        { return this.openTasks.length === 0 && !this.hasCompleted; }

    get tt() {
        return {
            mine: this.mineOnly  ? 'tt active' : 'tt',
            all:  !this.mineOnly ? 'tt active' : 'tt',
        };
    }

    _notify(msg) {
        if (this._cnTimer) clearTimeout(this._cnTimer);
        this._cn = msg;
        this._cnTimer = setTimeout(() => { this._cn = ''; this._cnTimer = null; }, 2000);
    }

    handleToggle(event) {
        const mode = event.currentTarget.dataset.mode;
        this._notify(`Click ${mode === 'mine' ? 1 : 2} — Show ${mode === 'mine' ? 'My' : 'All'} tasks`);
        this.mineOnly = mode === 'mine';
    }

    handleAdd() {
        this._notify('Click 3 — Add new action item');
    }

    handleCheck(event) {
        const id   = event.currentTarget.dataset.id;
        const task = this.rawTasks.find(t => t.id === id);
        if (!task) return;
        const openList = this.tasks.filter(t => !t.isCompleted && (!this.mineOnly || ['T. Bennett', 'TB'].includes(t.ownerInitials)));
        const doneList = this.tasks.filter(t => t.isCompleted);
        const allDisplayed = [...openList, ...doneList];
        const pos = allDisplayed.findIndex(t => t.id === id);
        const clickNum = pos >= 0 ? pos + 4 : 4;
        this._notify(`Click ${clickNum} — ${task.isCompleted ? 'Uncomplete' : 'Complete'}: ${task.subject.slice(0, 35)}`);
        this._toggle(id, !task.isCompleted);
    }

    async _toggle(taskId, complete) {
        if (taskId.startsWith('p')) return;
        try {
            await toggleTaskComplete({ taskId, complete });
            await refreshApex(this._wiredResult);
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: e?.body?.message, variant: 'error' }));
        }
    }
}