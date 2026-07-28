import { LightningElement, api } from 'lwc';

/**
 * Overview tab shell — composes Current Summary (full width) + a 65/35 split of
 * Activity Feed against Snapshot + Tasks, matching the HTML's `.ov-cols` layout.
 * Purely a layout/composition component; each child owns its own state.
 */
export default class NavatarDealCimOverview extends LightningElement {
    /** Called by the container when the header's "Create Task" button fires. */
    @api
    openTaskForm() {
        const tasksCmp = this.template.querySelector('c-navatar-deal-cim-tasks');
        if (tasksCmp) tasksCmp.openAddForm();
    }
}