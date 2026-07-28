import { LightningElement, api } from 'lwc';
import { NETWORK_ROWS } from 'c/navDemoData';

/**
 * FR-COMP-07 — the Network tab (labelled 'Warm Paths' in the mockups).
 *
 * Routes into the company, derived from External Connections and enhanced to
 * two levels. Strength is Strong or Warm only, rendered as plain text.
 * Clicking a row reveals why the route matters.
 *
 * Rows are AI-generated, so they come from navDemoData for now.
 */
export default class NavCompanyNetwork extends LightningElement {
    @api recordId;

    openId;

    get rows() {
        return NETWORK_ROWS.map((row) => {
            const isOpen = row.id === this.openId;
            return { ...row, isOpen, isOpenAttr: isOpen ? 'true' : 'false' };
        });
    }

    get hasRows() {
        return this.rows.length > 0;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? undefined : id;
    }
}