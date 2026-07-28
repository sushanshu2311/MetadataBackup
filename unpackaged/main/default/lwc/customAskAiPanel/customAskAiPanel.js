import { LightningElement, api, track } from 'lwc';

const PROMPT_OPTIONS = [
    { id: 'p1', icon: '📋', text: 'Summarize this deal' },
    { id: 'p2', icon: '🔍', text: 'Find similar deals' },
    { id: 'p3', icon: '📄', text: 'Summarize documents received' },
    { id: 'p4', icon: '➡️', text: 'What are the next steps?' },
    { id: 'p5', icon: '🤝', text: 'Who in our network should we engage?' },
    { id: 'p6', icon: '✅', text: 'What are my open items?' }
];

const AI_OPTIONS = [
    { value: 'All', label: 'All AI' },
    { value: 'Claude', label: 'Claude' },
    { value: 'Coworker', label: 'Coworker' }
];

const ACTION_TYPE_MAP = {
    task: { icon: '☑', cls: 'action-icon--task' },
    email: { icon: '✉', cls: 'action-icon--email' },
    stub: { icon: '·', cls: 'action-icon--stub' }
};

export default class CustomAskAiPanel extends LightningElement {
    @api visible = false;
    @api mode = 'empty';   // 'empty' | 'actions' | 'chat'
    @api actionKey = null;
    @api actionTitle = '';
    @api actions = [];
    @api messages = [];

    @track inputText = '';
    @track inputFocused = false;
    @track selectedAI = 'All';
    @track aiSelectorOpen = false;
    @track promptsExpanded = false;

    // ─── Mode getters ──────────────────────────────────────────────────────────
    get isEmptyMode()   { return this.mode === 'empty'; }
    get isActionsMode() { return this.mode === 'actions'; }
    get isChatMode()    { return this.mode === 'chat'; }

    // ─── FAB class ─────────────────────────────────────────────────────────────
    get fabClass() {
        return 'ask-ai-fab' + (this.visible ? ' ask-ai-fab--hidden' : '');
    }

    // ─── Prompts ───────────────────────────────────────────────────────────────
    get promptOptions() {
        return PROMPT_OPTIONS;
    }

    get promptsToggleLabel() {
        return this.promptsExpanded ? '▲ Hide suggested prompts' : '▼ Suggested prompts';
    }

    // ─── Actions (with computed classes) ───────────────────────────────────────
    get actionsList() {
        return (this.actions || []).map(a => {
            const meta = ACTION_TYPE_MAP[a.type] || ACTION_TYPE_MAP.stub;
            return {
                ...a,
                btnClass: 'action-btn action-btn--' + a.type,
                iconClass: 'action-icon ' + meta.cls,
                iconText: meta.icon
            };
        });
    }

    // ─── Chat messages ─────────────────────────────────────────────────────────
    get chatMessages() {
        return (this.messages || []).map(m => ({
            ...m,
            isAi: m.role === 'ai',
            bubbleClass: 'chat-bubble chat-bubble--' + m.role
        }));
    }

    // ─── AI selector options ───────────────────────────────────────────────────
    get aiOptions() {
        return AI_OPTIONS.map(o => ({
            ...o,
            isSelected: o.value === this.selectedAI,
            dotStyle: o.value === 'Claude' ? 'background:#7C3AED' :
                      o.value === 'Coworker' ? 'background:#059669' : 'background:#0B2D5F'
        }));
    }

    // ─── Input ─────────────────────────────────────────────────────────────────
    get inputAreaClass() {
        return 'input-area' + (this.inputFocused ? ' input-area--focused' : '');
    }

    get isSendDisabled() {
        return !this.inputText || !this.inputText.trim();
    }

    // ─── Event handlers ────────────────────────────────────────────────────────
    handleFabClick() {
        this.dispatchEvent(new CustomEvent('fabclick', { bubbles: true, composed: true }));
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('panelclose', { bubbles: true, composed: true }));
    }

    handleBackToEmpty() {
        this.dispatchEvent(new CustomEvent('panelclose', { bubbles: true, composed: true }));
    }

    handleBackToActions() {
        // Signal parent to go back to actions mode — parent controls the mode prop
        this.dispatchEvent(new CustomEvent('backtoactions', { bubbles: true, composed: true }));
    }

    handlePromptClick(evt) {
        const prompt = evt.currentTarget.dataset.prompt;
        this.promptsExpanded = false;
        this.dispatchEvent(new CustomEvent('promptselected', {
            detail: { prompt },
            bubbles: true,
            composed: true
        }));
    }

    handleActionClick(evt) {
        const label = evt.currentTarget.dataset.label;
        const action = (this.actions || []).find(a => a.label === label);
        if (!action) return;
        this.dispatchEvent(new CustomEvent('actionexecuted', {
            detail: { action },
            bubbles: true,
            composed: true
        }));
    }

    handleInput(evt) {
        this.inputText = evt.target.value;
    }

    handleInputFocus() {
        this.inputFocused = true;
    }

    handleInputBlur() {
        this.inputFocused = false;
    }

    handleKeyDown(evt) {
        if (evt.key === 'Enter' && !evt.shiftKey) {
            evt.preventDefault();
            this.handleSend();
        }
    }

    handleSend() {
        if (!this.inputText || !this.inputText.trim()) return;
        const text = this.inputText.trim();
        this.inputText = '';
        this.dispatchEvent(new CustomEvent('messagesent', {
            detail: { text },
            bubbles: true,
            composed: true
        }));
    }

    handleAiSelectorToggle() {
        this.aiSelectorOpen = !this.aiSelectorOpen;
    }

    handleAiOptionClick(evt) {
        this.selectedAI = evt.currentTarget.dataset.value;
        this.aiSelectorOpen = false;
    }

    handleTogglePrompts() {
        this.promptsExpanded = !this.promptsExpanded;
    }

    // ─── Scroll chat to bottom when messages change ────────────────────────────
    renderedCallback() {
        if (this.isChatMode) {
            const container = this.template.querySelector('.chat-messages');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }
    }
}