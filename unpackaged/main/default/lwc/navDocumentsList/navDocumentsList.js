import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDocuments from '@salesforce/apex/NavCompanyPageController.getDocuments';
import { DOCUMENT_INSIGHTS } from 'c/navDemoData';

/**
 * FR-SHD-06 — the Documents tab.
 *
 * Source tags are Navatar or SharePoint. No From column, no page counts and no
 * version history — the name only. The title opens the file with standard
 * Salesforce behaviour (previewable types preview, the rest download);
 * clicking the row reveals the AI read on the document.
 */
export default class NavDocumentsList extends NavigationMixin(LightningElement) {
    @api recordId;

    searchTerm = '';
    openId;

    documents = [];
    error;

    @wire(getDocuments, { recordId: '$recordId' })
    wiredDocuments({ data, error }) {
        if (data) {
            this.documents = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.documents = [];
        }
    }

    get rows() {
        const term = this.searchTerm.trim().toLowerCase();
        return this.documents
            .filter((row) => {
                if (!term) {
                    return true;
                }
                const haystack = `${row.title || ''} ${row.dealName || ''} ${row.source || ''}`.toLowerCase();
                return haystack.includes(term);
            })
            .map((row) => {
                const isOpen = row.recordId === this.openId;
                return {
                    ...row,
                    isOpen,
                    isOpenAttr: isOpen ? 'true' : 'false',
                    insight: DOCUMENT_INSIGHTS[(row.title || '').toLowerCase()]
                };
            });
    }

    get hasRows() {
        return this.rows.length > 0;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value || '';
        this.openId = undefined;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? undefined : id;
    }

    handlePreview(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: { pageName: 'filePreview' },
            state: { selectedRecordId: event.currentTarget.dataset.id }
        });
    }
}