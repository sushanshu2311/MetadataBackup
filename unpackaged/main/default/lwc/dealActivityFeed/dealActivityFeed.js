import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FEED_ITEMS = [
    { id: 'f1',  badge: 'GAP',         filterCat: 'intelligence', timestampLabel: 'Today · 09:14',       title: 'Claude detected a gap — CMS supervision risk not in deal notes',         preview: 'The CMS supervision requirement change on page 18 of Dr. Webb\'s report does not appear in any deal notes. Revenue exposure: £4.1M across 3 clinic sites.' },
    { id: 'f2',  badge: 'DOCUMENT',    filterCat: 'intelligence', timestampLabel: 'Today · 08:47',       title: 'Regulatory expert report received — Dr. Marcus Webb',                    preview: 'Critical (p.18): CMS supervision change — 3 sites, £4.1M. Legal opinion required. Material (p.24): CQC Guildford staffing ratios flagged.' },
    { id: 'f3',  badge: 'AI ANALYSIS', filterCat: 'intelligence', timestampLabel: 'Today · 09:00',       title: 'AI scenario analysis updated — CMS risk reflected',                      preview: 'Base (12×, £98.4M): IRR 28.4%, MOIC 3.4×. Downside (11×, £90.2M): IRR 19.1%, MOIC 2.5×. Stress (9.5×): Below hurdle.' },
    { id: 'f4',  badge: 'DEAL EVENT',  filterCat: 'intelligence', timestampLabel: '28 May 2026',         title: 'IC Review approved — proceed to LOI at 11–13× EBITDA',                  preview: 'IC Review approved 28 May 2026. Condition: management retention package to be agreed by close of DD.' },
    { id: 'f5',  badge: 'MEETING',     filterCat: 'meeting',      timestampLabel: '20 May 2026',         title: 'Management meeting notes logged — Apex Care HQ',                        preview: 'Attendees: Thomas Bennett, Mark Hargreaves, Sarah Chen — 68 minutes. MH confirmed retention interest, open to 3-year earn-out.' },
    { id: 'f6',  badge: 'CALL',        filterCat: 'meeting',      timestampLabel: '07 May 2026',         title: 'Call notes — Thomas Bennett with Michael Hartley',                      preview: 'Michael Hartley confirmed Advent International are in the process. Management retention will be decisive.' },
    { id: 'f7',  badge: 'RISK FLAG',   filterCat: 'intelligence', timestampLabel: '12 May 2026',         title: 'Risk flagged — Key person dependency on Mark Hargreaves',               preview: '14 of 22 NHS referral relationships personally held by Hargreaves. Revenue at risk if departs: est. £22.4M (59%).' },
    { id: 'f8',  badge: 'EMAIL',       filterCat: 'email',        timestampLabel: '12 Mar 2026',         title: 'Email thread summarised — LOI terms with Michael Hartley',              preview: '6-email thread, 08–12 Mar 2026. 4 bidders confirmed remaining. Final bid deadline: 28 March 2026.' },
    { id: 'f9',  badge: 'AI INSIGHT',  filterCat: 'intelligence', timestampLabel: '02 Mar 2026',         title: 'Warm path identified — Apex Care via Dr. Sarah Okonkwo',                preview: 'Dr. Okonkwo sits on the Apex Care clinical advisory board (since 2024). Call completed 07 Mar — positive view of management.' },
    { id: 'f10', badge: 'BRIEFING',    filterCat: 'meeting',      timestampLabel: '08 Mar 2026 · 08:00', title: 'Pre-meeting briefing delivered — Management meeting, Apex Care HQ',   preview: 'Auto-generated 08:00, 08 Mar. Open items: NHS referral mapping, IT scope, self-pay trajectory.' },
    { id: 'f11', badge: 'DEAL EVENT',  filterCat: 'intelligence', timestampLabel: '14 Mar 2026',         title: 'LOI submitted to Michael Hartley — 11–13× EBITDA',                      preview: 'LOI submitted 14 Mar 2026 at 11–13× LTM EBITDA (£90–107M). Equity-heavy structure (65%). One of 4 remaining bidders.' },
    { id: 'f12', badge: 'DOCUMENT',    filterCat: 'intelligence', timestampLabel: '12 Feb 2026',         title: 'CIM received and processed — company identified as Apex Care Partners', preview: '22-site UK outpatient rehabilitation. 18% CAGR. NHS + self-pay (65/35). Management: Mark Hargreaves CEO (12yr), Sarah Chen CFO.' },
    { id: 'f13', badge: 'DEAL EVENT',  filterCat: 'intelligence', timestampLabel: '22 Jan 2026',         title: 'Deal created — teaser received from Michael Hartley',                   preview: 'Deal created 22 Jan 2026. Teaser from Michael Hartley, Houlihan Lokey. UK outpatient rehabilitation, 22 sites, £38M revenue.' },
];

export default class DealActivityFeed extends LightningElement {
    @api recordId;
    @track activeFilter   = 'all';
    @track viewMode       = 'expand';
    @track expandedFeedId = null;

    get expandVariant() { return this.viewMode === 'expand' ? 'brand' : 'neutral'; }
    get popupVariant()  { return this.viewMode === 'popup'  ? 'brand' : 'neutral'; }

    get fAll()     { return this.activeFilter === 'all'          ? 'brand' : 'neutral'; }
    get fEmail()   { return this.activeFilter === 'email'        ? 'brand' : 'neutral'; }
    get fMeeting() { return this.activeFilter === 'meeting'      ? 'brand' : 'neutral'; }
    get fIntel()   { return this.activeFilter === 'intelligence' ? 'brand' : 'neutral'; }

    get visibleFeedItems() {
        const items = this.activeFilter === 'all'
            ? FEED_ITEMS
            : FEED_ITEMS.filter(i => i.filterCat === this.activeFilter);
        return items.map((item, idx) => ({
            ...item,
            idx,
            isExpanded: this.expandedFeedId === item.id && this.viewMode === 'expand',
            openLabel:  this.expandedFeedId === item.id ? 'Close ▲' : 'Open ▼',
        }));
    }

    setViewMode(event) {
        const mode = event.currentTarget.dataset.mode;
        this.dispatchEvent(new ShowToastEvent({ title: `View: ${mode}`, variant: 'info', mode: 'dismissible' }));
        this.viewMode = mode;
        this.expandedFeedId = null;
    }

    handleFilter(event) {
        const val = event.currentTarget.dataset.value;
        this.activeFilter   = val;
        this.expandedFeedId = null;
    }

    handleFeedClick(event) {
        const id = event.currentTarget.dataset.id;
        if (this.viewMode === 'expand') {
            this.expandedFeedId = this.expandedFeedId === id ? null : id;
        }
    }

    handleCloseFeedItem(event) {
        event.stopPropagation();
        this.expandedFeedId = null;
    }

    stopProp(event) { event.stopPropagation(); }

    handleLoadMore() {
        this.dispatchEvent(new ShowToastEvent({ title: 'Load earlier activity', variant: 'info', mode: 'dismissible' }));
    }
}