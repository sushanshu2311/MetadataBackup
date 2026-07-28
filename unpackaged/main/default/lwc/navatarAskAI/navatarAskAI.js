import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';

const CANNED_RESPONSES = {
    'What are the key risks?':
        '3 high-priority risks:\n\n1. CMS supervision (High) — 3 sites, £4.1M. Flagged today. Legal instruction overdue.\n\n2. Key person dependency (High) — MH holds 14 of 22 NHS referral relationships. Advent competing. Retention not agreed.\n\n3. NHS referral concentration (High) — top 3 CCGs at 41% of revenue.',
    'Draft 18 Jun meeting agenda':
        'Proposed Agenda — 18 June 2026:\n\n1. CMS supervision — remediation plan (20 min)\n2. NHS Guildford CCG renewal (15 min)\n3. Management retention — term sheet (15 min)\n4. IT infrastructure — upgrade scope (10 min)\n5. Next steps (10 min)',
    'Compare to Project Lighthouse':
        'Everest vs Lighthouse:\n\nRevenue: £38M vs £32M\nEBITDA margin: 21.6% vs 19.8%\nEntry multiple: Lighthouse 10.8× — Everest 11–13× appropriate\nBanker: Same — Michael Hartley, Houlihan Lokey',
    'Pre-meeting action plan':
        'Before 18 June:\n\n1. Today — Instruct Kirkland on CMS legal opinion\n2. By 12 Jun — Finalise meeting agenda\n3. By 14 Jun — Run CMS downside scenario\n4. By 16 Jun — Confirm retention term sheet',
    'Add Advent intelligence to deal notes':
        'Done. Added to deal notes:\n\n"Advent International bid team confirmed via LinkedIn. James Wren (Associate) active on deal. Key risk: management retention competition — Advent known to move quickly on founder arrangements."\n\nRecommendation: raise retention term sheet before next management meeting.',
    'Assess competitive bid risk from Advent':
        'Competitive risk from Advent: HIGH\n\nAdvent closed 3 healthcare PE deals in the past 18 months. James Wren (Associate) has prior relationship with Mark Hargreaves. If Advent moves on a retention package before Ironwood, risk to deal completion increases significantly.\n\nSuggested action: brief Thomas Bennett before end of day.',
};

let _msgCounter = 1;

export default class NavatarAskAI extends LightningElement {
    @track isOpen    = false;
    @track inputText = '';
    @track isTyping  = false;
    @track messages  = [];
    @track selectedContext = 'Bidder intelligence — Advent International bid team confirmed via LinkedIn';

    @wire(MessageContext) messageContext;

    _subscription = null;

    connectedCallback() {
        this._subscription = subscribe(this.messageContext, NAVATAR_AI_CHANNEL, (msg) => {
            this.selectedContext = msg.selectedContext;
            this.messages        = [];
            this.isOpen          = true;
        });
    }

    recommendedActions = [
        { id: 'ra1', text: 'Add Advent intelligence to deal notes' },
        { id: 'ra2', text: 'Assess competitive bid risk from Advent' },
    ];

    get hasMessages() { return this.messages.length > 0; }

    handleOpen()  { this.isOpen = true; }
    handleClose() { this.isOpen = false; }

    handleInput(event) {
        this.inputText = event.detail.value;
    }

    handleKeyDown(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this._send();
        }
    }

    handleSend() { this._send(); }

    handleActionClick(event) {
        this.inputText = event.currentTarget.dataset.text;
        this._send();
    }

    _send() {
        const text = (this.inputText || '').trim();
        if (!text) return;

        this.messages = [...this.messages, {
            id:          'u' + (_msgCounter++),
            text,
            timestamp:   'You',
            listClass:   'slds-chat-listitem slds-chat-listitem_outbound',
            bubbleClass: 'slds-chat-message__text slds-chat-message__text_outbound',
        }];
        this.inputText = '';
        this.isTyping  = true;

        const reply = CANNED_RESPONSES[text]
            || "I'm analysing that now — let me check the latest deal data and come back to you.";

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.isTyping = false;
            this.messages = [...this.messages, {
                id:          'a' + (_msgCounter++),
                text:        reply,
                timestamp:   'Navatar Intelligence',
                listClass:   'slds-chat-listitem slds-chat-listitem_inbound',
                bubbleClass: 'slds-chat-message__text slds-chat-message__text_inbound',
            }];
        }, 900);
    }
}