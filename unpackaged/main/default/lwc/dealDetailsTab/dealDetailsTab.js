import { LightningElement, api } from 'lwc';

const DETAIL_FIELDS = [
    { label: 'Sector',            value: 'Healthcare' },
    { label: 'Sub-Sector',        value: 'Outpatient Rehabilitation' },
    { label: 'Geography',         value: 'UK — 22 Sites' },
    { label: 'Revenue (LTM)',     value: '£38M' },
    { label: 'EBITDA (LTM)',      value: '£8.2M' },
    { label: 'EBITDA Margin',     value: '21.6%' },
    { label: 'Revenue CAGR',      value: '18% (3yr)' },
    { label: 'Valuation Range',   value: '£90–107M (11–13× EBITDA)' },
    { label: 'Structure',         value: 'Equity-heavy (65%), 3yr earn-out' },
    { label: 'Payer Mix',         value: 'NHS 65% / Self-pay 35%' },
    { label: 'Self-Pay Patients', value: '340 patients (+18% YoY)' },
    { label: 'Sites',             value: '22 UK outpatient sites' },
    { label: 'Source',            value: 'Houlihan Lokey (Michael Hartley)' },
    { label: 'NDA Signed',        value: '12 Feb 2026' },
    { label: 'LOI Submitted',     value: '14 Mar 2026' },
    { label: 'IC Approved',       value: '28 May 2026' },
    { label: 'Target Close',      value: 'Q3 2026' },
];

export default class DealDetailsTab extends LightningElement {
    @api recordId;
    detailFields = DETAIL_FIELDS;
}