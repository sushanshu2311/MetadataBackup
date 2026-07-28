import { LightningElement, track } from 'lwc';
import { INTERACTIONS_DATA } from 'c/customDealDataService';

const FILTER_OPTIONS = [
    { value: 'all', label: 'All' },
    { value: 'email', label: 'Emails' },
    { value: 'call', label: 'Calls' },
    { value: 'meeting', label: 'Meetings' }
];

const TYPE_LABELS = { email: 'Email', call: 'Call', meeting: 'Meeting' };

export default class CustomDealInteractionsTab extends LightningElement {
    @track activeFilter = 'all';
    @track searchText = '';
    @track expandedId = null;

    get filterOptions() {
        return FILTER_OPTIONS.map(f => ({
            ...f,
            cssClass: 'filter-pill' + (this.activeFilter === f.value ? ' filter-pill--active' : '')
        }));
    }

    get filteredInteractions() {
        const search = this.searchText.toLowerCase();
        return INTERACTIONS_DATA
            .filter(item => {
                if (this.activeFilter !== 'all' && item.type !== this.activeFilter) return false;
                if (search) {
                    return item.subject.toLowerCase().includes(search) ||
                        item.participants.join(' ').toLowerCase().includes(search);
                }
                return true;
            })
            .map(item => ({
                ...item,
                isExpanded: this.expandedId === item.id,
                expandkey: item.id + '_exp',
                expandRowClass: 'expand-row' + (this.expandedId === item.id ? '' : ' expand-row--hidden'),
                participantsStr: item.participants.map(p => p.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)).join(' · '),
                typeLabel: TYPE_LABELS[item.type] || item.type,
                rowClass: 'int-row' + (this.expandedId === item.id ? ' int-row--expanded' : ''),
                typeBadgeClass: 'type-badge type-badge--' + item.type
            }));
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }

    handleRowClick(evt) {
        const id = evt.currentTarget.dataset.id;
        this.expandedId = this.expandedId === id ? null : id;
    }
}