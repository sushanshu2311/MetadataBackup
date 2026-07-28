import { LightningElement, api, wire } from 'lwc';
import getInteractions from '@salesforce/apex/NavCompanyPageController.getInteractions';
import { AI_ACTIVITY, ACTIVITY_TYPE_OPTIONS } from 'c/navDemoData';

const PAGE_SIZE = 5;

const CRM_TYPE_LABELS = {
    email: 'Email',
    call: 'Call',
    meeting: 'Meeting',
    other: 'Interaction'
};

/**
 * FR-SHD-02 / FR-SHD-03 — the Activity feed.
 *
 * Chronological, newest first, mixing logged CRM interactions with the
 * AI-generated News, Insights and AI Recommendations. No user-controlled
 * sorting. 'Show more' is infinite scroll with no total count. Clicking a row
 * reveals the item in place.
 */
export default class NavActivityFeed extends LightningElement {
    @api recordId;

    searchTerm = '';
    typeFilter = [];
    openId;
    visibleCount = PAGE_SIZE;

    interactions = [];
    error;
    scrollHandler;
    revealPending = false;

    typeOptions = ACTIVITY_TYPE_OPTIONS;

    @wire(getInteractions, { recordId: '$recordId' })
    wiredInteractions({ data, error }) {
        if (data) {
            this.interactions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.interactions = [];
        }
    }

    /**
     * Infinite scroll without IntersectionObserver, which this org's component
     * runtime does not expose. Scroll events do not bubble, but a capturing
     * listener on the document still sees them from whichever element inside
     * the Lightning page is actually scrolling.
     */
    connectedCallback() {
        this.scrollHandler = () => this.revealMoreIfNeeded();
        document.addEventListener('scroll', this.scrollHandler, true);
        window.addEventListener('resize', this.scrollHandler);
    }

    disconnectedCallback() {
        document.removeEventListener('scroll', this.scrollHandler, true);
        window.removeEventListener('resize', this.scrollHandler);
    }

    renderedCallback() {
        // The feed may be short enough that the end is already on screen.
        this.revealMoreIfNeeded();
    }

    revealMoreIfNeeded() {
        if (!this.hasMore || this.revealPending) {
            return;
        }
        const sentinel = this.template.querySelector('[data-sentinel]');
        if (!sentinel) {
            return;
        }
        const viewportHeight = window.innerHeight || document.documentElement.clientHeight;
        if (sentinel.getBoundingClientRect().top <= viewportHeight + 120) {
            this.revealPending = true;
            this.visibleCount += PAGE_SIZE;
            Promise.resolve().then(() => {
                this.revealPending = false;
            });
        }
    }

    /** CRM interactions and AI items in one chronological list. */
    get allItems() {
        const fromCrm = this.interactions.map((row) => ({
            id: row.recordId,
            type: row.interactionType,
            typeLabel: CRM_TYPE_LABELS[row.interactionType] || 'Interaction',
            title: row.subject,
            source: row.primaryContactName,
            activityDate: row.activityDate,
            body: row.body
        }));

        const items = [...fromCrm, ...AI_ACTIVITY];
        items.sort((a, b) => {
            const left = a.activityDate || '';
            const right = b.activityDate || '';
            if (left === right) {
                return 0;
            }
            return left > right ? -1 : 1;
        });
        return items;
    }

    get matchingItems() {
        const term = this.searchTerm.trim().toLowerCase();
        return this.allItems.filter((item) => {
            if (this.typeFilter.length && !this.typeFilter.includes(item.type)) {
                return false;
            }
            if (!term) {
                return true;
            }
            const haystack = `${item.title || ''} ${item.source || ''} ${item.body || ''}`.toLowerCase();
            return haystack.includes(term);
        });
    }

    get visibleItems() {
        return this.matchingItems.slice(0, this.visibleCount).map((item) => ({
            ...item,
            isOpen: item.id === this.openId,
            isOpenAttr: item.id === this.openId ? 'true' : 'false'
        }));
    }

    get hasItems() {
        return this.matchingItems.length > 0;
    }

    /** Sentinel only renders while there is more to load — no count is shown. */
    get hasMore() {
        return this.matchingItems.length > this.visibleCount;
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value || '';
        this.resetPaging();
    }

    handleTypeFilter(event) {
        this.typeFilter = event.detail.values;
        this.resetPaging();
    }

    resetPaging() {
        this.visibleCount = PAGE_SIZE;
        this.openId = undefined;
    }

    handleToggle(event) {
        const id = event.currentTarget.dataset.id;
        this.openId = this.openId === id ? undefined : id;
    }
}