import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';

/**
 * navatarDealCimApp — top-level container for the Project Everest / CIM Stage deal record
 * page. Owns which tab is active (Overview default, per the CIM Stage v2 spec) and wires the
 * header's Create Task / Log Interaction buttons to the right child tab. The Details tab from
 * the original HTML is intentionally not implemented anywhere in this bundle.
 *
 * Ask AI is provided by the existing `navatarAskAIBar` utility-bar component (deployed
 * separately, targeted at lightning__UtilityBar) — every row/feed item across the tabs
 * publishes its context onto the shared NavatarAI__c Lightning Message Channel, which
 * navatarAskAIBar already subscribes to. The floating "Ask AI" button here simply opens
 * that utility panel with a deal-level (non-item) context.
 */
export default class NavatarDealCimApp extends LightningElement {
    @api recordId;
    @api dealName = 'Project Everest';

    @wire(MessageContext) messageContext;

    activeTab = 'ov';

    get isOverview() { return this.activeTab === 'ov'; }
    get isTeam() { return this.activeTab === 'ppl'; }
    get isInteractions() { return this.activeTab === 'int'; }
    get isSimilarDeals() { return this.activeTab === 'comp'; }
    get isDocuments() { return this.activeTab === 'doc'; }

    handleTabSelect(event) {
        this.activeTab = event.detail.tabId;
    }

    handleCreateTask() {
        this.activeTab = 'ov';
        // Wait a tick for the Overview panel to (re)render before reaching into its Tasks child.
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        Promise.resolve().then(() => {
            const overview = this.template.querySelector('c-navatar-deal-cim-overview');
            if (overview) overview.openTaskForm();
        });
    }

    handleLogInteraction() {
        this.activeTab = 'int';
    }

    handleOpenAskAI() {
        publish(this.messageContext, NAVATAR_AI_CHANNEL, {
            selectedContext: this.dealName,
            itemId: null
        });
    }
}