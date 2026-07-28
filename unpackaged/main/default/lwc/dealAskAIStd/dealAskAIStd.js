import { LightningElement, api, track } from 'lwc';

const CANNED = {
    'what are the key risks?':
        '3 high-priority risks:\n\n1. CMS supervision (High) – 3 sites, £4.1M. Flagged today by Dr. Webb. Legal instruction overdue.\n\n2. Key person dependency (High) – MH holds 14 of 22 NHS referral relationships. Advent competing. Retention not agreed.\n\n3. NHS referral concentration (High) – top 3 CCGs at 41% of revenue. Guildford (16%) renewing 2027.',
    'draft 18 jun meeting agenda':
        'Proposed Agenda – 18 June 2026:\n\n1. CMS supervision requirement – remediation plan (20 min)\n2. NHS Guildford CCG renewal strategy (15 min)\n3. Management retention – term sheet with MH (15 min)\n4. IT infrastructure – upgrade scope (10 min)\n5. Self-pay pipeline validation (10 min)\n6. Next steps to LOI completion (5 min)',
    'compare to project lighthouse':
        'Everest vs Lighthouse:\n\nRevenue: £38M vs £32M – Everest larger\nEBITDA margin: 21.6% vs 19.8% – Everest better\nEntry multiple: Lighthouse 10.8× – Everest 11–13× appropriate\nCMS risk: Both present – Lighthouse resolved via restructure (+£0.8M)\nBanker: Same – Michael Hartley, Houlihan Lokey',
    'pre-meeting action plan':
        'Before 18 June:\n\n1. Today – Instruct Kirkland & Ellis on CMS legal opinion (overdue)\n2. By 12 Jun – Finalise management meeting agenda\n3. By 14 Jun – Run CMS downside scenario (S. Patel)\n4. By 16 Jun – Confirm retention term sheet draft with Kirkland',
};

const FALLBACK = "I've checked the current intelligence on Project Everest. The most urgent item is the CMS legal instruction – it's overdue and the management meeting is 18 June. Want me to draft anything specific?";

let _id = 0;
const nowTime = () => new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

export default class DealAskAIStd extends LightningElement {
    @api recordId;
    @track isExpanded = false;
    @track isTyping   = false;
    @track inputText  = '';

    get collapseIcon() { return this.isExpanded ? 'utility:chevronup' : 'utility:chevrondown'; }

    handleToggle() { this.isExpanded = !this.isExpanded; }
    @track messages  = [
        {
            id:     ++_id,
            isAI:   true,
            text:   "Hi Thomas. Dr. Webb's report flagged a critical CMS gap this morning – not in your deal notes and the management meeting is 18 June. Legal instruction is overdue. Want me to draft the agenda or look into the CMS issue?",
            sender: 'Claude',
            time:   '09:14',
        },
    ];

    get decoratedMessages() {
        return this.messages.map(msg => ({
            ...msg,
            bubbleCss: msg.isAI
                ? 'slds-box slds-box_x-small slds-theme_shade'
                : 'slds-box slds-box_x-small slds-theme_info',
            metaCss: msg.isAI
                ? 'slds-text-body_small slds-text-color_weak slds-m-top_xx-small'
                : 'slds-text-body_small slds-text-color_weak slds-m-top_xx-small slds-text-align_right',
        }));
    }

    handleInput(event)  { this.inputText = event.detail.value; }

    handleKey(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.sendMessage();
        }
    }

    handleSuggest(event) {
        this.inputText = event.currentTarget.dataset.q;
        this.sendMessage();
    }

    sendMessage() {
        const text = (this.inputText || '').trim();
        if (!text) return;

        this.messages = [...this.messages, {
            id: ++_id, isAI: false, text, sender: 'You', time: nowTime(),
        }];
        this.inputText = '';
        this.isTyping  = true;

        const reply = CANNED[text.toLowerCase()] || FALLBACK;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.isTyping = false;
            this.messages = [...this.messages, {
                id: ++_id, isAI: true, text: reply, sender: 'Claude', time: nowTime(),
            }];
        }, 1400);
    }
}