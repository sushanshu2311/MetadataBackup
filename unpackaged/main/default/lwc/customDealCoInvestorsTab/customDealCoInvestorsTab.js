import { LightningElement, track } from 'lwc';
import { CO_INVESTORS_DATA } from 'c/customDealDataService';

const FILTER_OPTIONS = [
    { value: 'all', label: 'All' },
    { value: 'ai', label: 'AI Recommended' },
    { value: 'active', label: 'Active' }
];

export default class CustomDealCoInvestorsTab extends LightningElement {
    @track activeFilter = 'all';
    @track searchText = '';

    get filterOptions() {
        return FILTER_OPTIONS.map(f => ({
            ...f,
            cssClass: 'filter-pill' + (this.activeFilter === f.value ? ' filter-pill--active' : '')
        }));
    }

    get filteredCoInvestors() {
        const search = this.searchText.toLowerCase();
        return CO_INVESTORS_DATA
            .filter(ci => {
                if (this.activeFilter === 'ai' && !ci.aiRecommended) return false;
                if (this.activeFilter === 'active' && ci.aiRecommended) return false;
                if (search) {
                    return ci.firm.toLowerCase().includes(search) ||
                        ci.type.toLowerCase().includes(search) ||
                        (ci.contact && ci.contact.toLowerCase().includes(search));
                }
                return true;
            })
            .map(ci => ({
                ...ci,
                statusClass: 'status-badge' + (ci.aiRecommended ? ' status-badge--ai' : '')
            }));
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }
}