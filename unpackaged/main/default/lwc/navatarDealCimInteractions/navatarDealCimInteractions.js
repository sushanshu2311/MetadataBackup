import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import { matchesQuery } from 'c/navatarDealCimUtils';

const TYPE_OPTIONS = [
    { value: '__all__', label: 'All' },
    { value: 'meeting', label: 'Meetings' },
    { value: 'call', label: 'Calls' },
    { value: 'email', label: 'Emails' }
];

// Team names known on the deal — participants matching one of these render as a linked
// name; anyone else renders as plain text. Mirrors the HTML's renderParticipants() logic,
// which cross-references the Team tab roster.
const TEAM_NAMES = new Set([
    'Michael Hartley', 'Kate Patterson', 'Mark Hargreaves', 'Priya Anand',
    'Thomas Bennett', 'Sarah Patel', 'Dr. Marcus Webb'
]);

const INTERACTIONS = [
    {
        key: 'cim_int1', itype: 'email', badge: 'Email', date: '5 Jun 2026',
        subject: 'Project Everest — CIM and Process Update',
        snippet: 'Thomas, please find attached the CIM for Project Everest (Apex Care Partners)...',
        participants: ['Michael Hartley', 'Thomas Bennett'],
        body:
            'From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett<br>Date: 5 Jun 2026<br><br>' +
            'Thomas,<br><br>Please find attached the CIM for Project Everest (Apex Care Partners). Ironwood ' +
            'has been invited into the final round alongside two other parties.<br><br>This is a strong asset ' +
            '— market-leading position in outpatient rehab with highly defensible NHS contracts. The management ' +
            'team are excellent and Mark Hargreaves has confirmed he would stay on under the right ownership.' +
            '<br><br>Data room access details to follow.<br>Michael'
    },
    {
        key: 'cim_int2', itype: 'call', badge: 'Call', date: '6 Jun 2026',
        subject: 'Quick call — CIM follow-up',
        snippet: "Michael, thanks for sending this through — we'd like to move forward. Can we get a management meeting on the calendar?...",
        participants: ['Thomas Bennett', 'Michael Hartley'],
        body:
            '[Call notes — 6 Jun 2026, 10 min]<br><br>Thomas Bennett: Michael, thanks for sending this through — ' +
            "Apex Care looks like a strong fit, we'd like to move forward. Can we get a management meeting on the " +
            'calendar?<br><br>Michael Hartley: Glad to hear it. I\'ll check availability with Mark and come back ' +
            'to you this week. I\'ll also send the formal process letter shortly with the full timeline.'
    }
];

/**
 * Interactions tab — type filter + search + expandable rows. Participants render as full
 * names, hyperlinked only when the person is also on the Team tab (per the CIM Stage v2 spec).
 */
export default class NavatarDealCimInteractions extends LightningElement {
    @wire(MessageContext) messageContext;

    typeOptions = TYPE_OPTIONS;
    @track selectedTypes = [];
    @track searchQuery = '';
    @track expandedKey = null;

    get rows() {
        return INTERACTIONS.filter((i) => {
            const typeOk = this.selectedTypes.length === 0 || this.selectedTypes.includes(i.itype);
            const searchOk = matchesQuery(`${i.subject} ${i.snippet}`, this.searchQuery);
            return typeOk && searchOk;
        }).map((i) => {
            const isOpen = this.expandedKey === i.key;
            return {
                ...i,
                rowClass: 'int-row' + (isOpen ? ' row-open' : ''),
                isOpen,
                expKey: i.key + '-exp',
                expRowStyle: isOpen ? '' : 'display:none',
                participantsView: i.participants.map((name, idx) => ({
                    key: i.key + '-p' + idx,
                    name,
                    linked: TEAM_NAMES.has(name)
                }))
            };
        });
    }

    handleFilterChange(event) {
        this.selectedTypes = event.detail.selectedValues;
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
        const row = INTERACTIONS.find((i) => i.key === key);
        publish(this.messageContext, NAVATAR_AI_CHANNEL, {
            selectedContext: row ? row.subject : 'Interaction',
            itemId: 'row_interaction'
        });
    }

    stopClick(event) {
        event.stopPropagation();
    }
}