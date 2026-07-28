import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/NavCompanyPageController.getContacts';
import createContact from '@salesforce/apex/NavCompanyPageController.createContact';
import removeContact from '@salesforce/apex/NavCompanyPageController.removeContact';
import {
    CONTACT_CATEGORY_OPTIONS,
    CATEGORY_LABELS,
    CATEGORY_ORDER,
    SUGGESTED_CONTACTS,
    CONTACT_INSIGHTS
} from 'c/navDemoData';

/**
 * FR-COMP-03 to FR-COMP-06 — the Contacts tab.
 *
 * Primary        = contacts at the company
 * Alumni         = affiliations with role Former Employee
 * Extended       = every other affiliation
 * AI Recommended = found by AI in the CIM, not yet in the system
 *
 * With the filter on All the list is flat; selecting specific categories
 * segregates them under headings. Contacts can be added and removed.
 */
export default class NavCompanyContacts extends NavigationMixin(LightningElement) {
    @api recordId;

    searchTerm = '';
    categoryFilter = [];
    openId;
    showAddForm = false;
    formError = '';
    saving = false;

    newName = '';
    newRole = '';
    newEmail = '';
    newCategory = 'primary';

    wiredResult;
    contacts = [];
    error;

    /** Suggested contacts are not records, so removing one is session-only. */
    dismissedSuggestions = [];

    categoryOptions = CONTACT_CATEGORY_OPTIONS;

    get categoryChoices() {
        return CONTACT_CATEGORY_OPTIONS.map((option) => ({ label: option.label, value: option.value }));
    }

    @wire(getContacts, { recordId: '$recordId' })
    wiredContacts(result) {
        this.wiredResult = result;
        if (result.data) {
            this.contacts = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.contacts = [];
        }
    }

    /** CRM contacts plus the AI-suggested ones, decorated for display. */
    get allRows() {
        const suggested = SUGGESTED_CONTACTS.filter(
            (row) => !this.dismissedSuggestions.includes(row.recordId)
        );
        return [...this.contacts, ...suggested].map((row) => {
            const insight = CONTACT_INSIGHTS[(row.name || '').toLowerCase()] || {};
            const connections = insight.connections || 0;
            const isOpen = row.recordId === this.openId;
            return {
                ...row,
                categoryLabel: CATEGORY_LABELS[row.category] || row.category,
                connectionsLabel:
                    connections === 0
                        ? 'No connections'
                        : `${connections} connection${connections === 1 ? '' : 's'}`,
                hasConnections: connections > 0,
                hasTouchpoint: Boolean(row.lastTouchpoint),
                isOpen,
                isOpenAttr: isOpen ? 'true' : 'false',
                insightHow: insight.how,
                insightInternal: insight.internal || '-',
                depthEmails: insight.depth ? insight.depth.emails : 0,
                depthCalls: insight.depth ? insight.depth.calls : 0,
                depthMeetings: insight.depth ? insight.depth.meetings : 0,
                networkPaths: insight.network || [],
                hasNetworkPaths: Boolean(insight.network && insight.network.length)
            };
        });
    }

    get matchingRows() {
        const term = this.searchTerm.trim().toLowerCase();
        return this.allRows.filter((row) => {
            if (this.categoryFilter.length && !this.categoryFilter.includes(row.category)) {
                return false;
            }
            if (!term) {
                return true;
            }
            const haystack = `${row.name || ''} ${row.role || ''} ${row.org || ''} ${row.email || ''}`.toLowerCase();
            return haystack.includes(term);
        });
    }

    /**
     * All -> one flat section with no heading.
     * Specific categories -> one section each, in fixed order, with headings.
     */
    get sections() {
        const rows = this.matchingRows;
        if (!this.categoryFilter.length) {
            return rows.length ? [{ key: 'all', label: null, showLabel: false, rows }] : [];
        }
        return CATEGORY_ORDER.filter((category) => this.categoryFilter.includes(category))
            .map((category) => ({
                key: category,
                label: CATEGORY_LABELS[category],
                showLabel: true,
                rows: rows.filter((row) => row.category === category)
            }))
            .filter((section) => section.rows.length > 0);
    }

    get hasRows() {
        return this.sections.length > 0;
    }

    get addButtonLabel() {
        return this.showAddForm ? 'Cancel' : 'Add Contact';
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

    handleOpenRecord(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: event.currentTarget.dataset.id, actionName: 'view' }
        });
    }

    // -------------------------------------------------------------- add / remove

    toggleAddForm() {
        this.showAddForm = !this.showAddForm;
        this.formError = '';
        if (!this.showAddForm) {
            this.resetForm();
        }
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    async handleAdd() {
        const fullName = (this.newName || '').trim();
        if (!fullName) {
            this.formError = 'Name is required.';
            return;
        }
        const parts = fullName.split(/\s+/);
        const lastName = parts.length > 1 ? parts.slice(1).join(' ') : parts[0];
        const firstName = parts.length > 1 ? parts[0] : null;

        this.saving = true;
        try {
            await createContact({
                recordId: this.recordId,
                firstName,
                lastName,
                title: this.newRole,
                email: this.newEmail,
                category: this.newCategory
            });
            await refreshApex(this.wiredResult);
            this.showAddForm = false;
            this.resetForm();
            this.dispatchEvent(
                new ShowToastEvent({ variant: 'success', message: `${fullName} added.` })
            );
        } catch (e) {
            this.formError = e.body ? e.body.message : 'The contact could not be added.';
        } finally {
            this.saving = false;
        }
    }

    async handleRemove(event) {
        event.stopPropagation();
        const contactId = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;

        // A suggested contact has no record behind it, so it just leaves the list.
        if (contactId.startsWith('suggested-')) {
            this.dismissedSuggestions = [...this.dismissedSuggestions, contactId];
            this.openId = undefined;
            return;
        }

        try {
            await removeContact({ recordId: this.recordId, contactId });
            await refreshApex(this.wiredResult);
            this.openId = undefined;
            this.dispatchEvent(new ShowToastEvent({ variant: 'success', message: `${name} removed.` }));
        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    variant: 'error',
                    title: 'Could not remove the contact',
                    message: e.body ? e.body.message : 'Please try again.'
                })
            );
        }
    }

    resetForm() {
        this.newName = '';
        this.newRole = '';
        this.newEmail = '';
        this.newCategory = 'primary';
        this.formError = '';
    }
}