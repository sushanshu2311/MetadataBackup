import { LightningElement, api, wire } from 'lwc';
import getCompanyProfile from '@salesforce/apex/NavCompanyPageController.getCompanyProfile';

/**
 * FR-COMP-01 — the Company Profile panel on Overview.
 *
 * Read-only field values, two columns on desktop and one on phone. Sector,
 * Subsector and Geography are plain text: the links to Themes are out of scope
 * for v1.0. Blank values render as a hyphen.
 *
 * The displayed set is fixed here for now; making it customer-configurable
 * (any object field) is the rest of FR-COMP-01 and comes later.
 */
export default class NavCompanyProfile extends LightningElement {
    @api recordId;

    profile;
    error;

    @wire(getCompanyProfile, { recordId: '$recordId' })
    wiredProfile({ data, error }) {
        if (data) {
            this.profile = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.profile = undefined;
        }
    }

    get fields() {
        const p = this.profile;
        if (!p) {
            return [];
        }
        return [
            { key: 'sector', label: 'Sector', value: p.sector },
            { key: 'subsector', label: 'Subsector', value: p.subsector },
            { key: 'geography', label: 'Geography', value: p.geography },
            { key: 'hq', label: 'HQ', value: p.hq },
            { key: 'revenue', label: 'Revenue', value: p.revenue },
            { key: 'ebitda', label: 'EBITDA', value: p.ebitda },
            { key: 'ownership', label: 'Ownership', value: p.ownership },
            { key: 'employees', label: 'Employees', value: p.employees }
        ];
    }

    get hasError() {
        return Boolean(this.error);
    }
}