import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { matchesQuery, nextKey } from 'c/navatarDealCimUtils';

const GROUP_LABEL = {
    dealteam: 'Deal Team',
    intermediary: 'Intermediary',
    company: 'Company contacts',
    advisors: 'Advisors & Experts',
    competitors: 'Competitors'
};

const GROUP_OPTIONS = [
    { value: '__all__', label: 'All' },
    { value: 'dealteam', label: 'Deal Team' },
    { value: 'intermediary', label: 'Intermediary' },
    { value: 'company', label: 'Company contacts' },
    { value: 'advisors', label: 'Advisors & Experts' },
    { value: 'competitors', label: 'Competitors' }
];

const INITIAL_TEAM = [
    {
        key: 'mh', group: 'intermediary', name: 'Michael Hartley', org: 'Houlihan Lokey', role: 'Lead Banker',
        email: 'mhartley@hl.com', connections: '3 connections', lastTouchpointDate: '5 Jun 2026', lastTouchpointBadge: 'Email',
        how: 'Sourced Project Everest for Ironwood — teaser sent 26 May 2026, CIM sent 5 June 2026. Six-year relationship with Thomas Bennett across four completed transactions.',
        internal: 'James Walker (Partner) · Thomas Bennett (Deal Lead)',
        interactions: { emails: 2, calls: 0, meetings: 0 },
        warmPaths: [{ arrow: '→', line: 'Sourced Project Lighthouse and Project Atlas (both won)', meta: 'Track record of actionable deal flow' }]
    },
    {
        key: 'kp', group: 'intermediary', name: 'Kate Patterson', org: 'Houlihan Lokey', role: 'Banker',
        email: 'kpatterson@hl.com', connections: '1 connection', lastTouchpointDate: '', lastTouchpointBadge: '',
        how: 'Supporting Michael Hartley on the Project Everest process. Manages the data room and process communications.',
        internal: 'Thomas Bennett · Sarah Patel (data room access)',
        interactions: { emails: 0, calls: 0, meetings: 0 },
        warmPaths: []
    },
    {
        key: 'mha', group: 'company', name: 'Mark Hargreaves', org: 'Apex Care Partners', role: 'Management (CEO)',
        email: 'm.hargreaves@apexcare.co.uk', connections: '', lastTouchpointDate: '', lastTouchpointBadge: '',
        how: 'CEO and founder of Apex Care Partners. Identified from the CIM received 5 June 2026 — contact record auto-created from the named management team in the document. No direct contact yet; Houlihan Lokey is currently the only access route.',
        internal: 'None yet — introduction expected via Michael Hartley once a management meeting is scheduled.',
        interactions: { emails: 0, calls: 0, meetings: 0 },
        warmPaths: []
    },
    {
        key: 'pa', group: 'company', name: 'Priya Anand', org: 'Apex Care Partners', role: 'Management (CFO)',
        email: 'p.anand@apexcare.co.uk', connections: '', lastTouchpointDate: '', lastTouchpointBadge: '',
        how: 'CFO of Apex Care Partners, named in the CIM financial summary. Contact record auto-created; no direct contact yet.',
        internal: 'None yet.',
        interactions: { emails: 0, calls: 0, meetings: 0 },
        warmPaths: []
    },
    {
        key: 'tb', group: 'dealteam', name: 'Thomas Bennett', org: 'Ironwood Capital', role: 'Deal Lead',
        email: 'tbennett@ironwoodcap.com', connections: '', lastTouchpointDate: '', lastTouchpointBadge: '',
        how: 'Ironwood deal lead on Project Everest. Received the teaser from Michael Hartley at Houlihan Lokey on 26 May 2026 and the CIM on 5 June 2026.',
        internal: 'Reports to James Walker (Managing Partner) · works daily with Sarah Patel (Associate)',
        interactions: { emails: 2, calls: 0, meetings: 0 },
        warmPaths: []
    },
    {
        key: 'sp', group: 'dealteam', name: 'Sarah Patel', org: 'Ironwood Capital', role: 'Analyst',
        email: 'spatel@ironwoodcap.com', connections: '', lastTouchpointDate: '', lastTouchpointBadge: '',
        how: 'Deal associate supporting Thomas Bennett on Project Everest from origination.',
        internal: 'Supports Thomas Bennett',
        interactions: { emails: 1, calls: 0, meetings: 0 },
        warmPaths: []
    },
    {
        key: 'mw', group: 'advisors', name: 'Dr. Marcus Webb', org: 'Webb Regulatory Advisory', role: 'Expert',
        email: '', connections: '1 connection', lastTouchpointDate: '', lastTouchpointBadge: '',
        how: 'AI-suggested regulatory expert, not yet engaged on Project Everest. Recommended based on two prior Ironwood engagements with a similar NHS-contracted, multi-site regulatory profile — Project Cedar (2024) and Project Beacon-Riverstone (2023) — both involving CQC/CMS-style compliance review.',
        internal: 'None — first-time recommendation for this deal.',
        interactions: { emails: 0, calls: 0, meetings: 0 },
        warmPaths: [{ arrow: '→', line: 'No direct warm path — sourced via comparable-deal history, not a personal Navatar connection', meta: 'Recommend direct outreach via Thomas Bennett given the time-sensitive regulatory signal' }],
        aiSourced: true
    }
];

/**
 * Team tab — single All/group multi-select (no sections), search, add/edit/remove, and
 * per-row expand (How We Know Them / Internal Connections / Interaction Depth / Warm Paths).
 * Dr. Marcus Webb's row is wired to the AI's scripted "row_team_webb" context (matching the
 * HTML's special-case), everyone else uses the generic "row_team" context.
 */
export default class NavatarDealCimTeam extends LightningElement {
    @wire(MessageContext) messageContext;

    groupOptions = GROUP_OPTIONS;
    @track selectedGroups = [];
    @track searchQuery = '';
    @track team = INITIAL_TEAM;
    @track expandedKey = null;

    @track showForm = false;
    formMode = 'add';
    editKey = null;
    formName = '';
    formOrg = '';
    formRole = '';
    formEmail = '';
    formCat = 'dealteam';
    formError = '';

    get formTitle() {
        return this.formMode === 'edit' ? 'Edit Team Member' : this.formCat === 'company' ? 'New Deal Contact' : 'New Deal Team Member';
    }

    get catOptions() {
        return GROUP_OPTIONS.filter((o) => o.value !== '__all__').map((o) => ({
            ...o,
            selected: o.value === this.formCat
        }));
    }

    get teamView() {
        return this.team
            .filter((p) => {
                const groupOk = this.selectedGroups.length === 0 || this.selectedGroups.includes(p.group);
                const text = `${p.name} ${p.org} ${p.role} ${p.email}`;
                const searchOk = matchesQuery(text, this.searchQuery);
                return groupOk && searchOk;
            })
            .map((p) => {
                const isOpen = this.expandedKey === p.key;
                return {
                    ...p,
                    groupLabel: GROUP_LABEL[p.group] || p.group,
                    rowClass: 'ppl-row' + (isOpen ? ' row-open' : ''),
                    isOpen,
                    expKey: p.key + '-exp',
                    expRowStyle: isOpen ? '' : 'display:none',
                    emailDisplay: p.email || '—',
                    stats: [
                        { key: 'emails', label: 'Emails', value: p.interactions.emails },
                        { key: 'calls', label: 'Calls', value: p.interactions.calls },
                        { key: 'meetings', label: 'Meetings', value: p.interactions.meetings }
                    ],
                    warmPathsView: (p.warmPaths || []).map((w, i) => ({ ...w, key: p.key + '-wp-' + i }))
                };
            });
    }

    // Prevents an inline link click (name/org/email) from also toggling the row expansion.
    stopClick(event) {
        event.stopPropagation();
        event.preventDefault();
    }

    handleFilterChange(event) {
        this.selectedGroups = event.detail.selectedValues;
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
        const person = this.team.find((p) => p.key === key);
        publish(this.messageContext, NAVATAR_AI_CHANNEL, {
            selectedContext: person ? person.name : 'Contact',
            itemId: key === 'mw' ? 'row_team_webb' : 'row_team'
        });
    }

    handleOpenAdd(event) {
        this.formMode = 'add';
        this.editKey = null;
        this.formName = '';
        this.formOrg = '';
        this.formRole = '';
        this.formEmail = '';
        this.formCat = event.currentTarget.dataset.cat || 'dealteam';
        this.formError = '';
        this.showForm = true;
    }

    handleOpenEdit(event) {
        event.stopPropagation();
        const key = event.currentTarget.dataset.key;
        const person = this.team.find((p) => p.key === key);
        if (!person) return;
        this.formMode = 'edit';
        this.editKey = key;
        this.formName = person.name;
        this.formOrg = person.org;
        this.formRole = person.role;
        this.formEmail = person.email;
        this.formCat = person.group;
        this.formError = '';
        this.showForm = true;
    }

    handleRemove(event) {
        event.stopPropagation();
        const key = event.currentTarget.dataset.key;
        this.team = this.team.filter((p) => p.key !== key);
        if (this.expandedKey === key) {
            this.expandedKey = null;
            publish(this.messageContext, NAVATAR_AI_CHANNEL, { reset: true });
        }
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleCatChange(event) {
        this.formCat = event.target.value;
    }

    handleSave() {
        const name = (this.formName || '').trim();
        if (!name) {
            this.formError = 'Name is required.';
            return;
        }
        if (this.formMode === 'edit' && this.editKey) {
            this.team = this.team.map((p) =>
                p.key === this.editKey
                    ? { ...p, name, org: this.formOrg, role: this.formRole, email: this.formEmail, group: this.formCat }
                    : p
            );
        } else {
            this.team = [
                ...this.team,
                {
                    key: nextKey('team'),
                    group: this.formCat,
                    name,
                    org: this.formOrg,
                    role: this.formRole || '—',
                    email: this.formEmail,
                    connections: '',
                    lastTouchpointDate: '',
                    lastTouchpointBadge: '',
                    how: 'Added manually to the deal team. No interaction history yet.',
                    internal: '—',
                    interactions: { emails: 0, calls: 0, meetings: 0 },
                    warmPaths: []
                }
            ];
        }
        this.dispatchEvent(new ShowToastEvent({ title: 'Team member saved', message: name, variant: 'success' }));
        this.showForm = false;
    }

    handleCancel() {
        this.showForm = false;
        this.formError = '';
    }
}