import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { matchesQuery } from 'c/navatarDealCimUtils';

const DOCUMENTS = [
    {
        key: 'd1',
        name: 'Project Everest — Confidential Information Memorandum (Apex Care Partners)',
        sourceTag: 'Email',
        date: '5 Jun 2026',
        docType: 'PDF · 45 pages',
        summary:
            'Navatar Intelligence summary: full CIM for Apex Care Partners — a 22-site UK outpatient rehabilitation ' +
            'provider, $48M LTM revenue, $10.0M EBITDA (20.8% margin). Confirms NHS-contracted revenue base, ' +
            "founder-CEO Mark Hargreaves, and Ironwood's inclusion in a 3-party final round. Management indicates " +
            'openness to retention post-transaction.'
    }
];

/**
 * Documents tab — filter bar and From column removed per the CIM Stage v2 spec, so only
 * search + the expandable Document/Source/Date/Type table remain. Row d1 (the CIM) is wired
 * to the AI's dedicated "row_document_cim" context, matching the HTML's special case.
 */
export default class NavatarDealCimDocuments extends LightningElement {
    @wire(MessageContext) messageContext;

    @track searchQuery = '';
    @track expandedKey = null;

    get rows() {
        return DOCUMENTS.filter((d) => matchesQuery(d.name, this.searchQuery)).map((d) => {
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
        const doc = DOCUMENTS.find((d) => d.key === key);
        publish(this.messageContext, NAVATAR_AI_CHANNEL, {
            selectedContext: doc ? doc.name : 'Document',
            itemId: key === 'd1' ? 'row_document_cim' : 'row_document'
        });
    }

    handleOpenDoc(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new ShowToastEvent({ title: 'Opening document', message: 'This demo does not have a live document viewer wired up.', variant: 'info' })
        );
    }
}