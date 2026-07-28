import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import { matchesQuery } from 'c/navatarDealCimUtils';

const TYPE_OPTIONS = [
    { value: '__all__', label: 'All' },
    { value: 'meeting', label: 'Meetings' },
    { value: 'call', label: 'Calls' },
    { value: 'email', label: 'Emails' },
    { value: 'news', label: 'News' },
    { value: 'di', label: 'Insights' },
    { value: 'ai', label: 'AI Recommendations' }
];

// Newest-first; `more:true` items are the ones carried forward from the Teaser stage,
// hidden behind "Show N more items" until the user asks for them.
const FEED_ITEMS = [
    {
        key: 'cim1',
        type: 'email',
        badge: 'Email',
        title: 'Project Everest — CIM received from Houlihan Lokey, Apex Care Partners revealed',
        meta: '5 Jun 2026 09:05 · Michael Hartley → Thomas Bennett',
        body:
            'From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett<br>Date: 5 Jun 2026<br><br>' +
            'Thomas,<br><br>Please find attached the CIM for Project Everest (Apex Care Partners). Ironwood has ' +
            'been invited into the final round alongside two other parties.<br><br>This is a strong asset — ' +
            'market-leading position in outpatient rehab with highly defensible NHS contracts. The management ' +
            'team are excellent and Mark Hargreaves has confirmed he would stay on under the right ownership.' +
            '<br><br>Data room access details to follow.<br>Michael',
        more: false
    },
    {
        key: 'cim_auto',
        type: 'di',
        badge: 'Insights',
        title: 'Navatar auto-created Apex Care Partners company record and 2 management contacts from CIM',
        meta: '5 Jun 2026 · AI Detected',
        body:
            'Navatar Intelligence extracted the company name, website, and named management team from the CIM ' +
            'and created the Apex Care Partners account record along with contact records for Mark Hargreaves ' +
            '(CEO) and Priya Anand (CFO). Web research enriched the account record with public-facing site and ' +
            'registration details. No manual entry required.',
        more: false
    },
    {
        key: 'cim_cms_flag',
        type: 'di',
        badge: 'Insights',
        title: 'Claude flagged NHS CMS supervision change as an emerging regulatory consideration',
        meta: '5 Jun 2026 · AI Detected',
        body:
            'The CIM analysis identified a Key Consideration worth validating early: NHS England has signaled a ' +
            'forthcoming change to outpatient supervision ratios that may affect multi-site providers with high ' +
            "patient-contact volumes. Apex Care Partners' 22-site footprint makes this a reasonable diligence " +
            'item to scope ahead of the management meeting, rather than wait for formal DD.',
        more: false
    },
    {
        key: 'cim_ai_webb',
        type: 'ai',
        badge: 'AI Recommendation',
        title: 'AI Recommendation — Engage Dr. Marcus Webb for regulatory diligence',
        meta: '5 Jun 2026 · Navatar Intelligence',
        body:
            'Dr. Marcus Webb (Webb Regulatory Advisory) was engaged by Ironwood on two prior deals with a similar ' +
            'NHS-contracted, multi-site regulatory profile — Project Cedar (2024) and Project Beacon-Riverstone ' +
            '(2023), both involving CQC/CMS-style compliance review.<br><br>Given the supervision-ratio signal ' +
            'flagged in the CIM, an early conversation with Webb would let regulatory risk be scoped before the ' +
            'management meeting rather than discovered mid-DD.',
        more: false
    },
    {
        key: 'cim_simdeals',
        type: 'di',
        badge: 'Insights',
        title: 'Similar deals identified — Project Lighthouse, Project Cedar, Project Beacon-Riverstone',
        meta: '5 Jun 2026 · AI Detected',
        body:
            'Three comparable deals from Ironwood’s history match Apex Care Partners on sector, NHS-contract ' +
            'structure, and regulatory profile: Project Lighthouse (won, outpatient rehab), Project Cedar (won, ' +
            'community diagnostics), and Project Beacon-Riverstone (won, domiciliary nursing). Full detail in ' +
            'the Similar Deals tab.',
        more: false
    },
    {
        key: 'teaser_criteria',
        type: 'di',
        badge: 'Insights',
        title: 'Investment criteria check completed — 4 of 5 matched',
        meta: '26 May 2026 09:15 · AI Detected',
        body:
            'Healthcare services sector ✓ · UK geography ✓ · Revenue within $20–75M target range ✓ · ' +
            'Contracted/recurring revenue base ✓ · Risk profile not yet assessable (pending CIM). Full criteria ' +
            "match will be confirmed once the CIM is received and the company's regulatory and " +
            'customer-concentration profile can be assessed.',
        more: true
    },
    {
        key: 'teaser_auto',
        type: 'di',
        badge: 'Insights',
        title: 'Navatar auto-created Project Everest deal record — banker, sector, and geography matched from teaser',
        meta: '26 May 2026 09:11 · AI Detected',
        body:
            'Navatar Intelligence matched the sender (mhartley@hl.com) to the existing Michael Hartley contact ' +
            'record at Houlihan Lokey, extracted sector (Healthcare Services), geography (United Kingdom), and ' +
            'indicative revenue range ($40–50M) from the teaser attachment, and created this deal record without ' +
            'manual entry.<br><br>No existing Navatar record matches the disclosed profile, so this is treated ' +
            'as a new opportunity rather than a repeat deal.',
        more: true
    },
    {
        key: 'teaser1',
        type: 'email',
        badge: 'Email',
        title: 'Project Everest — Teaser received from Houlihan Lokey',
        meta: '26 May 2026 09:10 · Michael Hartley → Thomas Bennett',
        body:
            'From: Michael Hartley &lt;mhartley@hl.com&gt;<br>To: Thomas Bennett &lt;tbennett@ironwoodcap.com&gt;' +
            '<br>Date: 26 May 2026<br><br>Thomas,<br><br>Please find attached a teaser for a new opportunity ' +
            "we're bringing to a small group of parties — Project Everest. UK outpatient healthcare services " +
            'business, NHS-contracted revenue base, multi-site, revenue in the $40–50M range. Company name ' +
            'withheld at this stage given the limited circulation.<br><br>Best,<br>Michael',
        more: true
    }
];

/**
 * Overview → Activity feed. Type multi-select + search share one render pass, matching the
 * HTML prototype's renderFeed(). Expanding a row publishes the item as context to the
 * navatarAskAIBar utility-bar component over LMS; collapsing resets the bar.
 */
export default class NavatarDealCimActivityFeed extends LightningElement {
    @wire(MessageContext) messageContext;

    typeOptions = TYPE_OPTIONS;
    @track selectedTypes = [];
    @track searchQuery = '';
    @track expandedKey = null;
    @track showMore = false;

    get visibleCount() {
        return FEED_ITEMS.filter((i) => !i.more).length;
    }

    get hiddenCount() {
        return FEED_ITEMS.length - this.visibleCount;
    }

    get showMoreLabel() {
        return `Show ${this.hiddenCount} more items ▾`;
    }

    get items() {
        return FEED_ITEMS.filter((item) => {
            if (item.more && !this.showMore) return false;
            const typeOk = this.selectedTypes.length === 0 || this.selectedTypes.includes(item.type);
            const searchOk = matchesQuery(item.title, this.searchQuery);
            return typeOk && searchOk;
        }).map((item) => ({
            ...item,
            rowClass: 'fi' + (this.expandedKey === item.key ? ' fi-open' : ''),
            isOpen: this.expandedKey === item.key
        }));
    }

    handleFilterChange(event) {
        this.selectedTypes = event.detail.selectedValues;
    }

    handleSearch(event) {
        this.searchQuery = event.target.value;
    }

    handleShowMore() {
        this.showMore = true;
    }

    handleItemClick(event) {
        const key = event.currentTarget.dataset.key;
        const item = FEED_ITEMS.find((i) => i.key === key);
        if (this.expandedKey === key) {
            this.expandedKey = null;
            publish(this.messageContext, NAVATAR_AI_CHANNEL, { reset: true });
            return;
        }
        this.expandedKey = key;
        publish(this.messageContext, NAVATAR_AI_CHANNEL, {
            selectedContext: item.title,
            itemId: key
        });
    }
}