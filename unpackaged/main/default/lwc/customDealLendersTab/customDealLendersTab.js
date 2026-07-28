import { LightningElement, track } from 'lwc';
import { LENDERS_DATA } from 'c/customDealDataService';

const FILTER_OPTIONS = [
    { value: 'all', label: 'All' },
    { value: 'ai', label: 'AI Recommended' },
    { value: 'active', label: 'Active' }
];

export default class CustomDealLendersTab extends LightningElement {
    @track activeFilter = 'all';
    @track searchText = '';

    get filterOptions() {
        return FILTER_OPTIONS.map(f => ({
            ...f,
            cssClass: 'filter-pill' + (this.activeFilter === f.value ? ' filter-pill--active' : '')
        }));
    }

    get filteredLenders() {
        const search = this.searchText.toLowerCase();
        return LENDERS_DATA
            .filter(l => {
                if (this.activeFilter === 'ai' && !l.aiRecommended) return false;
                if (this.activeFilter === 'active' && l.aiRecommended) return false;
                if (search) {
                    return l.firm.toLowerCase().includes(search) ||
                        l.type.toLowerCase().includes(search) ||
                        l.contact.toLowerCase().includes(search);
                }
                return true;
            })
            .map(l => ({
                ...l,
                statusClass: 'status-badge' + (l.aiRecommended ? ' status-badge--ai' : '')
            }));
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }
}