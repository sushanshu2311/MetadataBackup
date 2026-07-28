import { LightningElement } from 'lwc';

const METRICS = [
    { label: 'Stage',              value: 'Due Diligence' },
    { label: 'Days in Stage',      value: '68 days' },
    { label: 'EV Range (Est.)',    value: '$114–135M' },
    { label: 'Entry Multiple',     value: '11–13× EBITDA' },
    { label: 'Competing Bidders',  value: '3 remaining' },
    { label: 'Final Bid Deadline', value: '28 Jun 2026' },
];

export default class EverestStdKeyMetrics extends LightningElement {
    metrics = METRICS;
}