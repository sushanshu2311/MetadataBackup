import { LightningElement, track } from 'lwc';
import { DOCUMENTS_DATA } from 'c/customDealDataService';

const FILTER_OPTIONS = [
    { value: 'all', label: 'All' },
    { value: 'Received', label: 'Received' },
    { value: 'AI Generated', label: 'AI Generated' }
];

export default class CustomDealDocumentsTab extends LightningElement {
    @track activeFilter = 'all';
    @track searchText = '';
    @track expandedId = null;

    get filterOptions() {
        return FILTER_OPTIONS.map(f => ({
            ...f,
            cssClass: 'filter-pill' + (this.activeFilter === f.value ? ' filter-pill--active' : '')
        }));
    }

    get filteredDocs() {
        const search = this.searchText.toLowerCase();
        return DOCUMENTS_DATA
            .filter(d => {
                if (this.activeFilter !== 'all' && d.type !== this.activeFilter) return false;
                if (search) {
                    return d.name.toLowerCase().includes(search) ||
                        d.source.toLowerCase().includes(search) ||
                        d.meta.toLowerCase().includes(search);
                }
                return true;
            })
            .map(d => ({
                ...d,
                isExpanded: this.expandedId === d.id,
                itemClass: 'doc-item' + (this.expandedId === d.id ? ' doc-item--expanded' : ''),
                nameClass: 'doc-name' + (this.expandedId === d.id ? ' doc-name--active' : ''),
                sourceLabel: d.type === 'AI Generated' ? 'AI GENERATED' : d.source.toUpperCase(),
                sourceBadgeClass: 'source-badge' + (d.type === 'AI Generated' ? ' source-badge--ai' : ''),
                metaLine: d.date + ' · ' + d.meta
            }));
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }

    handleDocClick(evt) {
        const id = evt.currentTarget.dataset.id;
        this.expandedId = this.expandedId === id ? null : id;
    }
}