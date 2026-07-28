import { LightningElement, track } from 'lwc';
import { CHAT_RESPONSES } from 'c/customDealDataService';

const TABS = ['overview', 'team', 'interactions', 'similarDeals', 'lenders', 'coInvestors', 'documents'];

export default class CustomDealPage extends LightningElement {
    @track activeTab = 'overview';
    @track aiPanelVisible = true;
    @track aiMode = 'empty';
    @track aiActionKey = null;
    @track aiActionTitle = '';
    @track aiActionsList = [];
    @track aiMessages = [];
    @track openTaskCount = 4;

    // ─── Tab helpers ───────────────────────────────────────────────────────────
    get isOverviewTab()     { return this.activeTab === 'overview'; }
    get isTeamTab()         { return this.activeTab === 'team'; }
    get isInteractionsTab() { return this.activeTab === 'interactions'; }
    get isSimilarDealsTab() { return this.activeTab === 'similarDeals'; }
    get isLendersTab()      { return this.activeTab === 'lenders'; }
    get isCoInvestorsTab()  { return this.activeTab === 'coInvestors'; }
    get isDocumentsTab()    { return this.activeTab === 'documents'; }

    _tabClass(idx) {
        return 'tab-pill' + (this.activeTab === TABS[idx] ? ' tab-pill--active' : '');
    }
    get tabClass0() { return this._tabClass(0); }
    get tabClass1() { return this._tabClass(1); }
    get tabClass2() { return this._tabClass(2); }
    get tabClass3() { return this._tabClass(3); }
    get tabClass4() { return this._tabClass(4); }
    get tabClass5() { return this._tabClass(5); }
    get tabClass6() { return this._tabClass(6); }

    // ─── Tab navigation ────────────────────────────────────────────────────────
    handleTabClick(evt) {
        this.activeTab = evt.currentTarget.dataset.tab;
    }

    // ─── Header button ─────────────────────────────────────────────────────────
    handleHeaderButton(evt) {
        const btn = evt.detail && evt.detail.button;
        if (btn === 'createtask') {
            // eslint-disable-next-line no-console
            console.log('Create Task triggered from header');
        }
    }

    // ─── Feed item selected (from activityFeedCard → dealOverviewTab → dealPage) ─
    handleFeedItemSelected(evt) {
        const payload = evt.detail;
        if (!payload) {
            this.aiMode = 'empty';
            this.aiActionKey = null;
            this.aiActionTitle = '';
            this.aiActionsList = [];
            return;
        }
        this.aiMode = 'actions';
        this.aiActionKey = payload.key;
        this.aiActionTitle = payload.title;
        this.aiActionsList = payload.actions || [];
    }

    // ─── AI Panel close ────────────────────────────────────────────────────────
    handlePanelClose() {
        this.aiPanelVisible = false;
    }

    // ─── FAB click ─────────────────────────────────────────────────────────────
    handleFabClick() {
        this.aiPanelVisible = true;
    }

    // ─── Prompt selected ───────────────────────────────────────────────────────
    handlePromptSelected(evt) {
        this._sendMessage(evt.detail.prompt);
    }

    // ─── Message sent ──────────────────────────────────────────────────────────
    handleMessageSent(evt) {
        this._sendMessage(evt.detail.text);
    }

    _sendMessage(text) {
        if (!text || !text.trim()) return;
        this.aiMode = 'chat';
        const userMsg = { id: Date.now() + '_u', role: 'user', text: text.trim(), time: this._now() };
        this.aiMessages = [...this.aiMessages, userMsg];
        // Simulate AI response after delay
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const responseText = CHAT_RESPONSES[text.trim()] ||
                'I\'m analysing that for you. Based on the current deal data for Project Everest, I\'ll have a detailed response shortly. In the meantime, please review the activity feed for the latest insights.';
            const aiMsg = { id: Date.now() + '_a', role: 'ai', text: responseText, time: this._now() };
            this.aiMessages = [...this.aiMessages, aiMsg];
        }, 1200);
    }

    // ─── Action executed ───────────────────────────────────────────────────────
    handleActionExecuted(evt) {
        const action = evt.detail.action;
        if (!action) return;

        if (action.type === 'task' && action.task) {
            this.openTaskCount = this.openTaskCount + 1;
            // Pass the new task to the overview tab's task card via event
            const newTaskEvt = new CustomEvent('newtask', { detail: { task: action.task }, bubbles: false });
            const overviewTab = this.template.querySelector('c-custom-deal-overview-tab');
            if (overviewTab) {
                overviewTab.addTask(action.task);
            }
            // Switch to chat with confirmation
            this.aiMode = 'chat';
            const confirmMsg = {
                id: Date.now() + '_a',
                role: 'ai',
                text: `Task created: "${action.task.title}" — assigned to ${action.task.assignee}, due ${action.task.due}. It has been added to the deal task list.`,
                time: this._now()
            };
            this.aiMessages = [...this.aiMessages, confirmMsg];
        } else if (action.type === 'email' && action.email) {
            const { to, subject, body } = action.email;
            const mailto = `mailto:${to}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
            window.open(mailto, '_self');
        } else if (action.type === 'stub') {
            this.aiMode = 'chat';
            const stubMsg = {
                id: Date.now() + '_a',
                role: 'ai',
                text: `"${action.label}" — this action would be executed in the full integration. For this demo, it has been logged.`,
                time: this._now()
            };
            this.aiMessages = [...this.aiMessages, stubMsg];
        }
    }

    _now() {
        const now = new Date();
        return now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    }
}