import { LightningElement, api } from 'lwc';

const TABS = [
    { id: 'ov', label: 'Overview' },
    { id: 'ppl', label: 'Team' },
    { id: 'int', label: 'Interactions' },
    { id: 'comp', label: 'Similar Deals' },
    { id: 'doc', label: 'Documents' }
];
// Details tab intentionally excluded per the CIM Stage v2 spec.

/**
 * Top-level tab strip. Purely presentational + emits `tabselect` — the
 * container (navatarDealCimApp) owns which tab is active and toggles visibility.
 */
export default class NavatarDealCimTabs extends LightningElement {
    @api activeTab = 'ov';

    get tabs() {
        return TABS.map((t) => ({
            ...t,
            className: 'mt' + (t.id === this.activeTab ? ' active' : '')
        }));
    }

    handleClick(event) {
        const tabId = event.currentTarget.dataset.id;
        if (tabId === this.activeTab) return;
        this.dispatchEvent(new CustomEvent('tabselect', { detail: { tabId } }));
    }
}