import { LightningElement, track } from 'lwc';
import { SIMILAR_DEALS } from 'c/customDealDataService';

export default class CustomDealSimilarDealsTab extends LightningElement {
    @track searchText = '';
    @track expandedId = null;

    get filteredDeals() {
        const search = this.searchText.toLowerCase();
        return SIMILAR_DEALS
            .filter(d => {
                if (!search) return true;
                return d.name.toLowerCase().includes(search) ||
                    d.sector.toLowerCase().includes(search) ||
                    d.outcome.toLowerCase().includes(search);
            })
            .map(d => ({
                ...d,
                isExpanded: this.expandedId === d.id,
                expandkey: d.id + '_exp',
                expandRowClass: 'expand-row' + (this.expandedId === d.id ? '' : ' expand-row--hidden'),
                rowClass: 'deal-row' + (this.expandedId === d.id ? ' deal-row--expanded' : '')
            }));
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }

    handleRowClick(evt) {
        const id = evt.currentTarget.dataset.id;
        this.expandedId = this.expandedId === id ? null : id;
    }
}