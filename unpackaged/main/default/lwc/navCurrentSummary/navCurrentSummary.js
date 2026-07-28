import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/**
 * FR-SHD-01 — the AI-generated narrative at the top of Overview.
 *
 * Carries an AI badge, is not editable in v1.0, and has no 'show more': the
 * text is capped at roughly five lines and scrolls in place if it overruns.
 * Inline entity references are links to internal record ids.
 */
export default class NavCurrentSummary extends NavigationMixin(LightningElement) {
    /** [{ key, text, recordId, isLink }] from navDemoData.buildCurrentSummary */
    @api segments = [];

    get hasSummary() {
        return this.segments && this.segments.length > 0;
    }

    handleNavigate(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                actionName: 'view'
            }
        });
    }
}