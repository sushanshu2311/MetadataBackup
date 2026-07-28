import { LightningElement, api, wire } from 'lwc';
import getCompanyProfile from '@salesforce/apex/NavCompanyPageController.getCompanyProfile';
import getContacts from '@salesforce/apex/NavCompanyPageController.getContacts';
import getDeals from '@salesforce/apex/NavCompanyPageController.getDeals';
import { buildCurrentSummary } from 'c/navDemoData';

/**
 * The Company Overview tab: Current Summary across the top, then Activity
 * beside Company Profile and Tasks.
 *
 * A FlexiPage region holds one component, so this wrapper is what gives the
 * tab its two-column layout. It collapses to a single column on phone.
 *
 * It also resolves the names referenced in the Current Summary against records
 * already on the page, so those references link to internal record ids.
 */
export default class NavCompanyOverview extends LightningElement {
    @api recordId;

    profile;
    contacts = [];
    deals = [];

    @wire(getCompanyProfile, { recordId: '$recordId' })
    wiredProfile({ data }) {
        if (data) {
            this.profile = data;
        }
    }

    @wire(getContacts, { recordId: '$recordId' })
    wiredContacts({ data }) {
        if (data) {
            this.contacts = data;
        }
    }

    @wire(getDeals, { recordId: '$recordId' })
    wiredDeals({ data }) {
        if (data) {
            this.deals = data;
        }
    }

    get summarySegments() {
        const idsByName = new Map();
        const remember = (name, id) => {
            if (name && id) {
                idsByName.set(name.toLowerCase(), id);
            }
        };

        if (this.profile) {
            remember(this.profile.name, this.profile.recordId);
        }
        this.contacts.forEach((contact) => remember(contact.name, contact.recordId));
        this.deals.forEach((deal) => {
            remember(deal.name, deal.recordId);
            remember(deal.sourceFirmName, deal.sourceFirmId);
            remember(deal.sourceContactName, deal.sourceContactId);
        });

        return buildCurrentSummary(idsByName);
    }
}