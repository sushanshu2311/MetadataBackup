import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getInteractions from '@salesforce/apex/NavCompanyPageController.getInteractions';
import { INTERACTION_TYPE_OPTIONS, INTERACTION_PARTICIPANTS } from 'c/navDemoData';

const TYPE_LABELS = { email: 'Email', call: 'Call', meeting: 'Meeting', other: 'Interaction' };

/**
 * FR-SHD-05 — the Interactions tab: logged emails, calls and meetings.
 *
 * Participants show as full names, linked when the person exists as a contact
 * and plain text otherwise. Search covers the subject, the body and the
 * participants. Clicking a row reveals the message or the notes.
 */
export default class NavInteractionsList extends NavigationMixin(LightningElement) {
    @api recordId;

    searchTerm = '';
    typeFilter = [];
    openId;

    interactions = [];
    error;

    typeOptions = INTERACTION_TYPE_OPTIONS;

    @wire(getInteractions, { recordId: '$recordId' })
    wiredInteractions({ data, error }) {
        if (data) {
            this.interactions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.interactions = [];
        }
    }

    get rows() {
        const term = this.searchTerm.trim().toLowerCase();

        return this.interactions
            .map((row) => {
                const names =
                    INTERACTION_PARTICIPANTS[(row.subject || '').toLowerCase()] ||
                    (row.primaryContactName ? [row.primaryContactName] : []);

                const participants = names.map((name, index) => ({
                    key: `${row.recordId}-p${index}`,
                    name,
                    // Only the activity's own contact is a record we can link to.
                    recordId: name === row.primaryContactName ? row.primaryContactId : null,
                    isLinked: name === row.primaryContactName && Boolean(row.primaryContactId)
                }));

                const isOpen = row.recordId === this.openId;
                return {
                    ...row,
                    typeLabel: TYPE_LABELS[row.interactionType] || 'Interaction',
                    participants,
                    isOpen,
                    isOpenAttr: isOpen ? 'true' : 'false'
                };
            })
            .filter((row) => {
                if (this.typeFilter.length && !this.typeFilter.includes(row.interactionType)) {
                    return false;
                }
                if (!term) {
                    return true;
                }
                const people = row.participants.map((p) => p.name).join(' ');
                const haystack = `${row.subject || ''} ${row.body || ''} ${people}`.toLowerCase();
                return haystack.includes(term);
            });
    }

    get hasRows() {
        return this.rows.length > 0;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value || '';
        this.openId = undefined;
    }

    handleTypeFilter(event) {
        this.typeFilter = event.detail.values;
        this.openId = undefined;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? undefined : id;
    }

    handleOpenContact(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: event.currentTarget.dataset.id, actionName: 'view' }
        });
    }
}