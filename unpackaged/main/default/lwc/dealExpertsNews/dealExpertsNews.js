import { LightningElement, api } from 'lwc';

const NEWS = [
    { id: 'n1', title: 'NHS England announces £340M outpatient rehab funding increase 2026–27', sourceDate: 'Reuters Health, 07 Jun', sentiment: 'Positive'   },
    { id: 'n2', title: 'Advent International acquires CareFirst Rehab — 13.2× EBITDA',          sourceDate: 'Mergermarket, 03 Jun',   sentiment: 'Comparable' },
    { id: 'n3', title: 'CQC publishes updated supervision guidelines — effective Q3 2026',       sourceDate: 'CQC.org.uk, 28 May',     sentiment: 'Watch'      },
    { id: 'n4', title: 'Apex Care Partners opens new clinic — Cheltenham',                       sourceDate: 'Apex Press, 15 May',     sentiment: 'Growth'     },
];

export default class DealExpertsNews extends LightningElement {
    @api recordId;
    get newsItems() { return NEWS; }
    handleViewAll() {}
}