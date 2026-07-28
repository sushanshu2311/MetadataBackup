import { LightningElement, api } from 'lwc';
import { LANDSCAPE_ROWS, LANDSCAPE_CATEGORY_OPTIONS } from 'c/navDemoData';

/**
 * FR-COMP-08 — the Landscape tab.
 *
 * Comparables, add-ons and companies that came up in discussions around this
 * company. Fully AI-generated, so the rows come from navDemoData until the
 * public / private data sourcing is wired up.
 */
export default class NavCompanyLandscape extends LightningElement {
    @api recordId;

    searchTerm = '';
    categoryFilter = [];
    openId;

    categoryOptions = LANDSCAPE_CATEGORY_OPTIONS;

    get rows() {
        const term = this.searchTerm.trim().toLowerCase();
        return LANDSCAPE_ROWS.filter((row) => {
            if (this.categoryFilter.length && !this.categoryFilter.includes(row.category)) {
                return false;
            }
            if (!term) {
                return true;
            }
            const haystack = `${row.company} ${row.companyMeta} ${row.type} ${row.why} ${row.source}`.toLowerCase();
            return haystack.includes(term);
        }).map((row) => {
            const isOpen = row.id === this.openId;
            return { ...row, isOpen, isOpenAttr: isOpen ? 'true' : 'false' };
        });
    }

    get hasRows() {
        return this.rows.length > 0;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value || '';
        this.openId = undefined;
    }

    handleCategoryFilter(event) {
        this.categoryFilter = event.detail.values;
        this.openId = undefined;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? undefined : id;
    }
}