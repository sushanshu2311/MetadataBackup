import { LightningElement, api } from 'lwc';

const FINANCIALS = [
    { id: 'fn1', metric: 'Revenue',        fy23: '£27.1M', fy24: '£32.2M', fy25: '£38.0M', fy26e: '£44.5M' },
    { id: 'fn2', metric: 'Revenue Growth', fy23: '—',      fy24: '+18.8%', fy25: '+18.0%', fy26e: '+17.1%' },
    { id: 'fn3', metric: 'EBITDA',         fy23: '£5.2M',  fy24: '£6.8M',  fy25: '£8.2M',  fy26e: '£9.8M'  },
    { id: 'fn4', metric: 'EBITDA Margin',  fy23: '19.2%',  fy24: '21.1%',  fy25: '21.6%',  fy26e: '22.0%'  },
    { id: 'fn5', metric: 'Capex',          fy23: '£1.1M',  fy24: '£1.4M',  fy25: '£1.6M',  fy26e: '£2.1M'  },
];

export default class DealFinancialsTab extends LightningElement {
    @api recordId;
    financialRows = FINANCIALS;

    financialColumns = [
        { label: 'Metric', fieldName: 'metric', type: 'text', wrapText: true },
        { label: 'FY23A',  fieldName: 'fy23',   type: 'text', initialWidth: 100, cellAttributes: { alignment: 'right' } },
        { label: 'FY24A',  fieldName: 'fy24',   type: 'text', initialWidth: 100, cellAttributes: { alignment: 'right' } },
        { label: 'FY25A',  fieldName: 'fy25',   type: 'text', initialWidth: 100, cellAttributes: { alignment: 'right' } },
        { label: 'FY26E',  fieldName: 'fy26e',  type: 'text', initialWidth: 100, cellAttributes: { alignment: 'right' } },
    ];
}