import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDeals from '@salesforce/apex/NavCompanyPageController.getDeals';
import { DEAL_STATUS_OPTIONS, DEAL_INSIGHTS } from 'c/navDemoData';

/**
 * FR-COMP-09 — the Deals tab.
 *
 * All / Active / Closed / Passed, derived from the deal's stage. The stage
 * itself renders as plain text, with no badge, and there is no subtitle line
 * under the deal name. Clicking a row reveals the AI read on the deal.
 */
export default class NavCompanyDeals extends NavigationMixin(LightningElement) {
    @api recordId;

    statusFilter = [];
    openId;

    deals = [];
    error;

    statusOptions = DEAL_STATUS_OPTIONS;

    @wire(getDeals, { recordId: '$recordId' })
    wiredDeals({ data, error }) {
        if (data) {
            this.deals = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.deals = [];
        }
    }

    get visibleDeals() {
        return this.deals
            .filter((deal) => !this.statusFilter.length || this.statusFilter.includes(deal.bucket))
            .map((deal) => {
                const isOpen = deal.recordId === this.openId;
                return {
                    ...deal,
                    isOpen,
                    isOpenAttr: isOpen ? 'true' : 'false',
                    insight: DEAL_INSIGHTS[(deal.name || '').toLowerCase()]
                };
            });
    }

    get hasDeals() {
        return this.visibleDeals.length > 0;
    }

    get emptyMessage() {
        if (!this.deals.length) {
            return 'No deals on this company.';
        }
        return 'No deals match this filter.';
    }

    handleStatusFilter(event) {
        this.statusFilter = event.detail.values;
        this.openId = undefined;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? undefined : id;
    }

    handleOpenRecord(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: event.currentTarget.dataset.id, actionName: 'view' }
        });
    }
}