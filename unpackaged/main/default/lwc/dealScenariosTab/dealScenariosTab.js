import { LightningElement, api } from 'lwc';

const SCENARIOS = [
    { id: 's1', scenario: 'Base — CMS resolved, MH retained',    multiple: '12.0×', price: '£98.4M', irr: '28.4%', moic: '3.4×' },
    { id: 's2', scenario: 'Downside — CMS partial, MH retained', multiple: '11.0×', price: '£90.2M', irr: '19.1%', moic: '2.5×' },
    { id: 's3', scenario: 'Stress — CMS unresolved, MH departs', multiple: '9.5×',  price: '£77.9M', irr: '11.3%', moic: '1.7×' },
];

export default class DealScenariosTab extends LightningElement {
    @api recordId;
    scenarios = SCENARIOS;

    scenarioColumns = [
        { label: 'Scenario',    fieldName: 'scenario', type: 'text', wrapText: true },
        { label: 'Entry ×',     fieldName: 'multiple', type: 'text', initialWidth: 90  },
        { label: 'Entry Price', fieldName: 'price',    type: 'text', initialWidth: 110 },
        { label: 'IRR',         fieldName: 'irr',      type: 'text', initialWidth: 80  },
        { label: 'MOIC',        fieldName: 'moic',     type: 'text', initialWidth: 80  },
    ];
}