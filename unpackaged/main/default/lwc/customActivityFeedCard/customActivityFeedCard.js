import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import { FEED_ITEMS, FEED_ACTIONS } from 'c/customDealDataService';

const BODY_ENTITIES = [
    'Michael Hartley', 'Houlihan Lokey', 'Apex Care Partners', 'Dr. Webb',
    'Mark Hargreaves', 'Advent International', 'Kirkland & Ellis', 'L.E.K. Consulting',
    'Sandra Chen'
];
const BODY_REGEX = new RegExp('(' + BODY_ENTITIES.map(e => e.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|') + ')', 'g');

function getBodySegments(body) {
    let key = 0;
    return body.split(BODY_REGEX).filter(p => p !== '').map(part => ({
        key: 'bs' + key++,
        text: part,
        cssClass: BODY_ENTITIES.includes(part) ? 'body-entity' : ''
    }));
}

const FILTER_OPTIONS = [
    { value: 'all', label: 'All' },
    { value: 'email', label: 'Emails' },
    { value: 'meeting', label: 'Meetings' },
    { value: 'di', label: 'Insights' },
    { value: 'news', label: 'News' },
    { value: 'ai', label: 'AI Recommendations' }
];

export default class CustomActivityFeedCard extends LightningElement {
    @wire(MessageContext) messageContext;

    @track activeFilter = 'all';
    @track searchText = '';
    @track expandedId = null;
    @track showHidden = false;

    get filterOptions() {
        return FILTER_OPTIONS.map(f => ({
            ...f,
            cssClass: 'filter-pill' + (this.activeFilter === f.value ? ' filter-pill--active' : '')
        }));
    }

    get allItems() {
        return FEED_ITEMS;
    }

    get filteredItems() {
        const search = this.searchText.toLowerCase();
        return this.allItems
            .filter(item => {
                if (item.isHidden && !this.showHidden) return false;
                if (this.activeFilter !== 'all' && item.type !== this.activeFilter) return false;
                if (search) {
                    return (
                        item.title.toLowerCase().includes(search) ||
                        item.body.toLowerCase().includes(search) ||
                        item.source.toLowerCase().includes(search)
                    );
                }
                return true;
            })
            .map(item => ({
                ...item,
                isExpanded: this.expandedId === item.id,
                itemClass: 'feed-item' + (this.expandedId === item.id ? ' feed-item--expanded' : ''),
                dateSource: item.date + ' · ' + item.source,
                bodySegments: getBodySegments(item.body)
            }));
    }

    get visibleCount() {
        return this.filteredItems.length;
    }

    get hiddenItems() {
        return this.allItems.filter(i => i.isHidden);
    }

    get hiddenCount() {
        return this.hiddenItems.length;
    }

    get showMoreVisible() {
        return !this.showHidden && this.hiddenCount > 0;
    }

    handleFilterClick(evt) {
        this.activeFilter = evt.currentTarget.dataset.filter;
        this.expandedId = null;
        this._fireReset();
    }

    handleSearch(evt) {
        this.searchText = evt.target.value;
    }

    handleItemClick(evt) {
        const id = evt.currentTarget.dataset.id;
        if (this.expandedId === id) {
            // Collapse
            this.expandedId = null;
            this._fireReset();
            publish(this.messageContext, NAVATAR_AI_CHANNEL, { reset: true });
        } else {
            // Expand
            this.expandedId = id;
            const item = FEED_ITEMS.find(i => i.id === id);
            const actions = FEED_ACTIONS[id] || [];
            this.dispatchEvent(new CustomEvent('feeditemselected', {
                detail: { key: id, title: item ? item.title : '', actions },
                bubbles: true,
                composed: true
            }));
            publish(this.messageContext, NAVATAR_AI_CHANNEL, {
                selectedContext: item ? item.title : '',
                itemId: id
            });
        }
    }

    handleShowMore() {
        this.showHidden = true;
    }

    _fireReset() {
        this.dispatchEvent(new CustomEvent('feeditemselected', {
            detail: null,
            bubbles: true,
            composed: true
        }));
    }
}