import { LightningElement, api, track } from 'lwc';
import { TASKS_ALL, TASKS_MINE } from 'c/customDealDataService';

export default class CustomDealTasksCard extends LightningElement {
    @api openCount = 0;
    @track activeFilter = 'all';
    @track searchText = '';
    @track tasksDone = {};
    @track extraTasks = [];
    @track flashId = null;

    // Called by parent to prepend a new task
    @api
    set newTask(task) {
        if (!task) return;
        const id = 'new_' + Date.now();
        const t = { ...task, id, done: false };
        this.extraTasks = [t, ...this.extraTasks];
        this.flashId = id;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => { this.flashId = null; }, 1500);
    }
    get newTask() { return null; }

    get filterAllClass() {
        return 'filter-pill' + (this.activeFilter === 'all' ? ' filter-pill--active' : '');
    }
    get filterMineClass() {
        return 'filter-pill' + (this.activeFilter === 'mine' ? ' filter-pill--active' : '');
    }

    get baseList() {
        return this.activeFilter === 'mine' ? TASKS_MINE : TASKS_ALL;
    }

    get openTaskCount() {
        return [...this.extraTasks, ...this.baseList].filter(t => {
            return !(t.id in this.tasksDone ? this.tasksDone[t.id] : t.done);
        }).length;
    }

    get filteredTasks() {
        const search = this.searchText.toLowerCase();
        const combined = [...this.extraTasks, ...this.baseList];
        return combined
            .filter(t => {
                if (search && !t.title.toLowerCase().includes(search)) return false;
                return true;
            })
            .map(t => {
                const isDone = t.id in this.tasksDone ? this.tasksDone[t.id] : t.done;
                const isFlash = this.flashId === t.id;
                let metaText = t.assignee;
                if (t.due) {
                    metaText = isDone
                        ? 'Completed ' + t.due + ' · ' + t.assignee
                        : 'Due ' + t.due + ' · ' + t.assignee;
                }
                return {
                    ...t,
                    done: isDone,
                    metaText,
                    rowClass: 'task-row' + (isDone ? ' task-row--done' : '') + (isFlash ? ' task-row--flash' : ''),
                    checkClass: 'task-check' + (isDone ? ' task-check--done' : ''),
                    titleClass: 'task__title' + (isDone ? ' task__title--done' : '')
                };
            });
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }

    handleToggle(evt) {
        const id = evt.currentTarget.dataset.id;
        const currentDone = id in this.tasksDone
            ? this.tasksDone[id]
            : ([...this.extraTasks, ...TASKS_ALL, ...TASKS_MINE].find(t => t.id === id) || {}).done || false;
        this.tasksDone = { ...this.tasksDone, [id]: !currentDone };
    }

    handleAddTask() {
        this.dispatchEvent(new CustomEvent('addtaskclick', { bubbles: true, composed: true }));
    }
}