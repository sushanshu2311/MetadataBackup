import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { matchesQuery, nextKey } from 'c/navatarDealCimUtils';

const OWNER_OPTIONS = [
    { value: '__all__', label: 'All' },
    { value: 'mine', label: 'Mine' }
];

const INITIAL_TASKS = [
    { key: 't1', owner: 'mine', done: false, title: 'Review CIM and recommend next step', meta: 'Due 9 Jun 2026 · T. Bennett' },
    { key: 't2', owner: 'other', done: false, title: 'Re-assess investment criteria now that CIM received', meta: 'Due 6 Jun 2026 · S. Patel' },
    { key: 't3', owner: 'other', done: false, title: 'Scope regulatory DD — NHS CMS supervision', meta: 'Due 12 Jun 2026 · S. Patel' },
    { key: 't4', owner: 'mine', done: false, title: 'Confirm financial DD provider (L.E.K. recommended)', meta: 'Due 10 Jun 2026 · T. Bennett' },
    { key: 't5', owner: 'mine', done: true, title: 'Send acknowledgment to Michael Hartley', meta: 'Completed 26 May 2026 · T. Bennett' },
    { key: 't6', owner: 'other', done: true, title: 'Confirm deal lead assignment', meta: 'Completed 27 May 2026 · J. Walker' }
];

/**
 * Overview → Tasks card. Owner multi-select (All/Mine) + search share one render pass.
 * Task titles are intentionally inert links — matching the HTML prototype's documented,
 * deliberate placeholder (`openTaskDetail` is wired but no detail view/modal exists yet).
 * The "+" add-task affordance and the completion toggle are fully functional, client-side.
 */
export default class NavatarDealCimTasks extends LightningElement {
    ownerOptions = OWNER_OPTIONS;
    @track selectedOwners = [];
    @track searchQuery = '';
    @track tasks = INITIAL_TASKS;
    @track showAddForm = false;
    newTitle = '';

    get tasksView() {
        return this.tasks
            .filter((t) => {
                const ownerOk = this.selectedOwners.length === 0 || this.selectedOwners.includes(t.owner);
                const searchOk = matchesQuery(t.title, this.searchQuery);
                return ownerOk && searchOk;
            })
            .map((t) => ({
                ...t,
                titleClass: t.done ? 'tt tt-done' : 'tt',
                circleClass: t.done ? 'tc done' : 'tc',
                metaClass: t.done ? 'td td-done' : 'td'
            }));
    }

    handleFilterChange(event) {
        this.selectedOwners = event.detail.selectedValues;
    }

    handleSearch(event) {
        this.searchQuery = event.target.value;
    }

    handleToggleDone(event) {
        const key = event.currentTarget.dataset.key;
        this.tasks = this.tasks.map((t) => (t.key === key ? { ...t, done: !t.done } : t));
    }

    // Intentionally inert — mirrors the HTML's openTaskDetail() no-op placeholder hook.
    handleTitleClick(event) {
        event.preventDefault();
    }

    handleOpenAdd() {
        this.showAddForm = true;
    }

    /** Exposed so the header's "Create Task" button can open this form from outside. */
    @api
    openAddForm() {
        this.showAddForm = true;
    }

    handleNewTitleChange(event) {
        this.newTitle = event.target.value;
    }

    handleAddTask() {
        const title = (this.newTitle || '').trim();
        if (!title) return;
        this.tasks = [
            { key: nextKey('task'), owner: 'mine', done: false, title, meta: 'Due date not set · You' },
            ...this.tasks
        ];
        this.newTitle = '';
        this.showAddForm = false;
        this.dispatchEvent(
            new ShowToastEvent({ title: 'Task created', message: title, variant: 'success' })
        );
    }

    handleCancelAdd() {
        this.newTitle = '';
        this.showAddForm = false;
    }
}