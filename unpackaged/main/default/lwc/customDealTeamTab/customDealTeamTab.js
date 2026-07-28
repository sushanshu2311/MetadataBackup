import { LightningElement, track } from 'lwc';
import { PEOPLE_DATA, PEOPLE_BRIEFINGS } from 'c/customDealDataService';

const FILTER_OPTIONS = [
    { value: 'all', label: 'All' },
    { value: 'external', label: 'External' },
    { value: 'internal', label: 'Internal' },
    { value: 'ai-recommended', label: 'AI Recommended' }
];

export default class CustomDealTeamTab extends LightningElement {
    @track activeFilter = 'all';
    @track searchText = '';
    @track expandedId = null;
    @track loadingId = null;
    @track readyIds = {};

    get filterOptions() {
        return FILTER_OPTIONS.map(f => ({
            ...f,
            cssClass: 'filter-pill' + (this.activeFilter === f.value ? ' filter-pill--active' : '')
        }));
    }

    get filteredPeople() {
        const search = this.searchText.toLowerCase();
        return PEOPLE_DATA
            .filter(p => {
                if (this.activeFilter !== 'all' && p.type !== this.activeFilter) return false;
                if (search) {
                    return p.name.toLowerCase().includes(search) ||
                        p.role.toLowerCase().includes(search) ||
                        p.group.toLowerCase().includes(search);
                }
                return true;
            })
            .map(p => {
                const isExpanded = this.expandedId === p.id;
                const isLoading = this.loadingId === p.id;
                const briefingReady = !!this.readyIds[p.id];
                let groupBadgeClass = 'group-badge';
                if (p.group === 'In Navatar') groupBadgeClass += ' group-badge--in-navatar';
                else if (p.group === 'Not in Navatar') groupBadgeClass += ' group-badge--not-in-navatar';
                return {
                    ...p,
                    groupBadgeClass,
                    isExpanded,
                    isLoading,
                    briefingReady,
                    expandkey: p.id + '_exp',
                    expandRowClass: 'briefing-row' + (isExpanded ? '' : ' expand-row--hidden'),
                    briefing: PEOPLE_BRIEFINGS[p.id] || '',
                    rowClass: 'person-row' + (isExpanded ? ' person-row--expanded' : ''),
                    emailHref: p.email ? 'mailto:' + p.email : null
                };
            });
    }

    handlePersonClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }

    handleRowClick(evt) {
        const id = evt.currentTarget.dataset.id;
        if (this.expandedId === id) {
            this.expandedId = null;
            this.loadingId = null;
            return;
        }
        this.expandedId = id;
        if (!this.readyIds[id]) {
            this.loadingId = id;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                if (this.expandedId === id) {
                    this.loadingId = null;
                    this.readyIds = { ...this.readyIds, [id]: true };
                }
            }, 1500);
        }
    }
}