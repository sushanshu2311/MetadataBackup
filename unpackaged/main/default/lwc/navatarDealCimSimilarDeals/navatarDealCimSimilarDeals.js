import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import { matchesQuery } from 'c/navatarDealCimUtils';

const DEALS = [
    {
        key: 's1', name: 'Project Lighthouse', sector: 'UK Healthcare Services', subSector: 'Outpatient Rehab',
        revenue: '$53M', multiple: '12×', outcome: 'Won · Closed', match: '94%',
        detail:
            'Project Lighthouse was an Ironwood Capital acquisition of a UK outpatient rehabilitation business ' +
            '($53M revenue, 12× EBITDA entry multiple) completed in Q3 2024. Key parallels with Project Everest: ' +
            'NHS contract dependency, single founder-CEO, CQC-regulated sites.<br><br>Lessons: (1) Written ' +
            'retention package for CEO agreed before exclusivity — critical given NHS relationship concentration. ' +
            '(2) Regulatory DD uncovered compliance gaps at 2 sites post-exclusivity — remediation cost factored ' +
            'into price chip. (3) Advent International was also in the final round on Lighthouse and dropped out ' +
            'at LOI stage.'
    },
    {
        key: 's2', name: 'Project Cedar', sector: 'UK Healthcare Services', subSector: 'Community Diagnostics',
        revenue: '$39M', multiple: '10.5×', outcome: 'Won · Closed', match: '82%',
        detail:
            'Project Cedar was an Ironwood Capital acquisition of a UK community diagnostics group ($39M revenue, ' +
            '10.5× EBITDA entry multiple) completed in Q2 2024. The business operated NHS-contracted community ' +
            'diagnostic centres across the Midlands.<br><br>Dr. Marcus Webb was engaged for regulatory due ' +
            'diligence and identified a CQC staffing-ratio gap at two sites pre-exclusivity — resolved via a ' +
            'negotiated price adjustment rather than a deal-breaking issue.'
    },
    {
        key: 's3', name: 'Project Beacon-Riverstone', sector: 'UK Healthcare Services', subSector: 'Domiciliary Nursing',
        revenue: '$31M', multiple: '11×', outcome: 'Won · Closed', match: '79%',
        detail:
            'Project Beacon-Riverstone was an Ironwood Capital acquisition of a UK domiciliary nursing provider ' +
            '($31M revenue, 11× EBITDA entry multiple) completed in Q4 2023. NHS and local-authority contracted, ' +
            "multi-site care delivery model.<br><br>Dr. Marcus Webb's regulatory report flagged a nursing " +
            'supervision ratio shortfall at three sites — directly analogous to the supervision-ratio issue ' +
            'flagged in the Project Everest CIM analysis.'
    }
];

/**
 * Similar Deals tab — AI-generated matches (labelled per the CIM Stage v2 spec), search,
 * expandable rows with the historical deal detail used to inform the current bid.
 */
export default class NavatarDealCimSimilarDeals extends LightningElement {
    @wire(MessageContext) messageContext;

    @track searchQuery = '';
    @track expandedKey = null;

    get rows() {
        return DEALS.filter((d) => matchesQuery(`${d.name} ${d.subSector}`, this.searchQuery)).map((d) => {
            const isOpen = this.expandedKey === d.key;
            return { ...d, rowClass: 'int-row' + (isOpen ? ' row-open' : ''), isOpen, expKey: d.key + '-exp', expRowStyle: isOpen ? '' : 'display:none' };
        });
    }

    handleSearch(event) {
        this.searchQuery = event.target.value;
    }

    handleRowClick(event) {
        const key = event.currentTarget.dataset.key;
        if (this.expandedKey === key) {
            this.expandedKey = null;
            publish(this.messageContext, NAVATAR_AI_CHANNEL, { reset: true });
            return;
        }
        this.expandedKey = key;
        const deal = DEALS.find((d) => d.key === key);
        publish(this.messageContext, NAVATAR_AI_CHANNEL, {
            selectedContext: deal ? deal.name : 'Comparable deal',
            itemId: 'row_similar'
        });
    }

    stopClick(event) {
        event.stopPropagation();
    }
}