import { LightningElement, api } from 'lwc';
import { CURRENT_SUMMARY } from 'c/customDealDataService';

const ENTITIES = [
    'Michael Hartley', 'Houlihan Lokey', 'Apex Care Partners',
    'Dr. Webb', 'Mark Hargreaves', 'Advent International', 'Kirkland & Ellis'
];

const ENTITY_PATTERN = new RegExp(
    `(${ENTITIES.map(e => e.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')})`,
    'g'
);

export default class CustomDealOverviewTab extends LightningElement {
    @api openCount = 4;

    get summarySegments() {
        return CURRENT_SUMMARY.split(ENTITY_PATTERN).map((part, i) => ({
            key: `seg-${i}`,
            text: part,
            cssClass: ENTITIES.includes(part) ? 'summary-entity' : ''
        }));
    }

    handleEditSummary() {
        // placeholder for edit action
    }

    handleFeedItemSelected(evt) {
        // Bubble the event up to dealPage
        this.dispatchEvent(new CustomEvent('feeditemselected', {
            detail: evt.detail,
            bubbles: true,
            composed: true
        }));
    }

    // Called by dealPage to pass a new task down to dealTasksCard
    addTask(task) {
        const taskCard = this.template.querySelector('c-custom-deal-tasks-card');
        if (taskCard) {
            taskCard.newTask = task;
        }
    }
}