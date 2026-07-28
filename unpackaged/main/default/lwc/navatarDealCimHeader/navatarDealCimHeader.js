import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * SF-style object header: deal icon/name + Edit / Create Task / Log Interaction / chevron.
 * Overview is read-only at CIM stage (per design notes) so Edit is intentionally not rendered
 * here — only the two action buttons and the overflow chevron remain, matching the HTML.
 *
 * Fires:
 *   createtask       — bubbles up so the container can open the Tasks quick-add form
 *   loginteraction   — bubbles up so the container can route to the Interactions tab
 */
export default class NavatarDealCimHeader extends LightningElement {
    @api dealName = 'Project Everest';
    @api dealLabel = 'Deal';

    menuOpen = false;

    get chevronIcon() {
        return this.menuOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }

    handleCreateTask() {
        this.dispatchEvent(new CustomEvent('createtask'));
        this._toast('Create Task', 'Opening the Tasks quick-add form on the Overview tab.');
    }

    handleLogInteraction() {
        this.dispatchEvent(new CustomEvent('loginteraction'));
        this._toast('Log Interaction', 'Switched to the Interactions tab to log a new interaction.');
    }

    toggleMenu() {
        this.menuOpen = !this.menuOpen;
    }

    _toast(title, message) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant: 'success', mode: 'dismissable' }));
    }
}