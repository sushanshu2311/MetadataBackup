import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import { getAllUtilityInfo, open, close } from 'lightning/platformUtilityBarApi';
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

const ACTIONS_BY_ITEM = {
    'gap1': [
        { id: 'ra1', text: 'Draft instruction to Kirkland & Ellis re CMS gap' },
        { id: 'ra2', text: 'Add CMS gap to deal notes' },
        { id: 'ra3', text: 'Analyse financial impact of CMS exposure' },
    ],
    'ai1': [
        { id: 'ra1', text: 'Create task: Instruct Kirkland before 18 June' },
        { id: 'ra2', text: 'Draft instruction email to Kirkland & Ellis' },
        { id: 'ra3', text: 'Schedule call with Sandra Chen' },
    ],
};

const DEFAULT_ACTIONS = [
    { id: 'ra1', text: 'Draft instruction to Kirkland & Ellis re CMS gap' },
    { id: 'ra2', text: 'Add CMS gap to deal notes' },
    { id: 'ra3', text: 'Analyse financial impact of CMS exposure' },
];

let _msgCounter = 1;

export default class NavatarAskAIBar extends LightningElement {
    @wire(MessageContext) messageContext;

    @track inputText       = '';
    @track isTyping        = false;
    @track messages        = [];
    @track selectedContext = '';
    @track hasContext      = false;
    @track recommendedActions = DEFAULT_ACTIONS;
    @track showActions        = false;

    _subscription = null;

    suggestedQuestions = [
        { id: 'sq1', text: 'Summarize this deal' },
        { id: 'sq2', text: 'Find similar deals' },
        { id: 'sq3', text: 'Summarize documents received' },
        { id: 'sq4', text: 'What are the next steps?' },
        { id: 'sq5', text: 'Who in our network should we engage?' },
        { id: 'sq6', text: 'What are my open items?' },
    ];

    @track promptsExpanded  = false;
    @track settingsOpen     = false;
    @track selectedMode     = 'all';

    get hasMessages() { return this.messages.length > 0; }

    get settingsOptions() {
        return [
            { value: 'all',       label: 'All' },
            { value: 'claude',    label: 'Claude' },
            { value: 'coworker',  label: 'Coworker' },
        ].map(o => ({
            ...o,
            rowClass: 'settings-option' + (this.selectedMode === o.value ? ' settings-option--active' : '')
        }));
    }

    get computedRecommendedActions() {
        return this.recommendedActions.map(a => ({ ...a, btnClass: 'action-item' }));
    }

    handleToggleSettings() {
        this.settingsOpen = !this.settingsOpen;
    }

    handleSettingsSelect(event) {
        this.selectedMode = event.currentTarget.dataset.value;
        this.settingsOpen = false;
    }

    handleCloseDefaultView() {
        this.hasContext      = true;
        this.promptsExpanded = false;
    }

    handleTogglePrompts(evt) {
        evt.preventDefault();
        this.hasContext      = false;
        this.promptsExpanded = true;
    }

    connectedCallback() {
        console.log('[NavatarAskAIBar] connectedCallback — subscribing to LMS channel');
        this._subscription = subscribe(this.messageContext, NAVATAR_AI_CHANNEL, (msg) => {
            console.log('[NavatarAskAIBar] LMS message received:', JSON.stringify(msg));

            if (msg.reset) {
                // Reset to default suggestedQuestions view and close the utility bar
                this.selectedContext = '';
                this.hasContext      = false;
                this.messages        = [];
                getAllUtilityInfo().then(utilities => {
                    if (utilities && utilities.length > 0) {
                        const utility = utilities.find(u => u.utilityLabel === 'Ask AI') || utilities[0];
                        if (utility.utilityVisible) {
                            close(utility.id);
                        }
                    }
                }).catch(err => {
                    console.error('[NavatarAskAIBar] getAllUtilityInfo error on reset:', err);
                });
                return;
            }

            this.selectedContext       = msg.selectedContext;
            this.hasContext            = true;
            this.messages              = [];
            this.showActions           = true;
            this.recommendedActions    = ACTIONS_BY_ITEM[msg.itemId] || DEFAULT_ACTIONS;
            console.log('[NavatarAskAIBar] Calling getAllUtilityInfo...');
            getAllUtilityInfo().then(utilities => {
                console.log('[NavatarAskAIBar] getAllUtilityInfo result:', JSON.stringify(utilities));
                if (utilities && utilities.length > 0) {
                    const utility = utilities.find(u => u.utilityLabel === 'Ask AI') || utilities[0];
                    console.log('[NavatarAskAIBar] utility.utilityVisible:', utility.utilityVisible, '| id:', utility.id);
                    if (!utility.utilityVisible) {
                        open(utility.id, { autoFocus: true });
                    }
                } else {
                    console.warn('[NavatarAskAIBar] No utilities found — is this component in the utility bar?');
                }
            }).catch(err => {
                console.error('[NavatarAskAIBar] getAllUtilityInfo error:', err);
            });
        });
        console.log('[NavatarAskAIBar] Subscription result:', this._subscription);
    }

    handleInput(event) {
        this.inputText = event.target.value;
    }

    handleKeyDown(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this._send();
        }
    }

    handleSend() { this._send(); }

    handleSuggestionClick(event) {
        event.preventDefault();
        this.inputText       = event.currentTarget.dataset.text;
        this.hasContext      = true;
        this.showActions     = false;
        this.promptsExpanded = false;
        this._send();
    }

    handleActionClick(event) {
        this.inputText = event.currentTarget.dataset.text;
        this._send();
    }

    _send() {
        const text = (this.inputText || '').trim();
        if (!text) return;
        this.hasContext = true;

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