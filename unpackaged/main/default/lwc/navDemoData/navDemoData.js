/**
 * Demo content for the Company record screen.
 *
 * Everything here is what Claude is specified to generate — Current Summary,
 * Activity Insights / News / AI Recommendations, Network paths, Landscape,
 * contact briefings — plus the two product concepts the screens read but that
 * have no field behind them yet (Connections counts, interaction participants
 * beyond the primary contact).
 *
 * It is deliberately one module so there is a single seam to replace when
 * generation timing is settled (BRD OI-7) and the Connections wiring lands.
 * CRM data does NOT belong here — that comes from NavCompanyPageController.
 */

// ---------------------------------------------------------------- Current Summary

// Segments render as plain text, or as a link when the named record resolves to an id.
const SUMMARY_SEGMENTS = [
    { record: 'Apex Care Partners' },
    {
        text:
            ' is a founder-led US outpatient rehabilitation platform — 22 sites, $48M revenue at ~22% EBITDA, ' +
            'Atlanta HQ. It came to us through '
    },
    { record: 'Houlihan Lokey' },
    { text: ' under ' },
    { record: 'Project Everest' },
    {
        text:
            ': teaser mid-June, NDA executed, and the CIM received this week. This record and its management ' +
            'contacts were created automatically from the CIM. We are at initial review — no management meeting ' +
            'or diligence yet. The open questions are management retention and payer concentration. The strongest ' +
            'route to CEO '
    },
    { record: 'Mark Hargreaves' },
    { text: ' is through banker ' },
    { record: 'Michael Hartley' },
    { text: '; the direct line from James Walker should be held in reserve so as not to bypass the process. ' },
    { text: 'Next step: work through the CIM and decide whether to request a management meeting.' }
];

/**
 * Resolves the summary against records already on the page so inline entity
 * references become real record links rather than dead anchors.
 * @param {Map<string,string>} idsByName lower-cased record name -> record id
 */
export function buildCurrentSummary(idsByName) {
    return SUMMARY_SEGMENTS.map((segment, index) => {
        const name = segment.record;
        const recordId = name ? idsByName.get(name.toLowerCase()) : undefined;
        return {
            key: `seg-${index}`,
            text: name || segment.text,
            recordId: recordId || null,
            isLink: Boolean(recordId)
        };
    });
}

// ------------------------------------------------------------------- Activity

/** AI-generated feed items, merged with logged interactions by the feed component. */
export const AI_ACTIVITY = [
    {
        id: 'ai-auto-create',
        type: 'insight',
        typeLabel: 'Insight',
        title: 'Apex Care Partners and 5 contacts auto-created from the CIM',
        source: 'Navatar Intelligence',
        activityDate: '2026-06-27',
        body:
            'On receipt of the CIM, Navatar created the Apex Care Partners company record and extracted five ' +
            'contacts (management, board, and a founding advisor). The banker was routed to Network rather than ' +
            'added as a company contact.'
    },
    {
        id: 'ai-initial-screen',
        type: 'recommendation',
        typeLabel: 'AI Recommendation',
        title: 'Initial screen — fits the healthcare services thesis; recommend proceeding to first review',
        source: 'Navatar Intelligence',
        activityDate: '2026-06-27',
        body:
            'Initial screen: Apex fits the US healthcare-services thesis — recurring outpatient volumes, ' +
            'founder-led, scaled at 22 sites. Recommend proceeding to a first review of the CIM. Watch items: ' +
            'management retention and payer concentration.'
    },
    {
        id: 'ai-news-sector',
        type: 'news',
        typeLabel: 'News',
        title: 'Outpatient rehab consolidation continues across the Southeast',
        source: 'Healthcare M&A',
        activityDate: '2026-06-12',
        body:
            'Trade press: outpatient rehabilitation consolidation continues across the Southeast, with several ' +
            'platform deals announced this year. Supportive backdrop for the Apex thesis.'
    }
];

export const ACTIVITY_TYPE_OPTIONS = [
    { label: 'Meetings', value: 'meeting' },
    { label: 'Calls', value: 'call' },
    { label: 'Emails', value: 'email' },
    { label: 'News', value: 'news' },
    { label: 'Insights', value: 'insight' },
    { label: 'AI Recommendations', value: 'recommendation' }
];

// ------------------------------------------------------------------- Contacts

export const CONTACT_CATEGORY_OPTIONS = [
    { label: 'Primary', value: 'primary' },
    { label: 'Alumni', value: 'alumni' },
    { label: 'Extended Network', value: 'extended' },
    { label: 'AI Recommended', value: 'ai' }
];

export const CATEGORY_LABELS = {
    primary: 'Primary',
    alumni: 'Alumni',
    extended: 'Extended Network',
    ai: 'AI Recommended'
};

export const CATEGORY_ORDER = ['primary', 'alumni', 'extended', 'ai'];

/** Contacts found by AI in the CIM that are not yet in the system. */
export const SUGGESTED_CONTACTS = [
    {
        recordId: 'suggested-karen-liu',
        name: 'Karen Liu',
        org: 'Apex Care Partners · detected from CIM',
        role: 'Head of Payer Relations',
        email: null,
        lastTouchpoint: null,
        category: 'ai',
        isSuggested: true
    }
];

/** Briefings and the Connections count, keyed by contact name. */
export const CONTACT_INSIGHTS = {
    'mark hargreaves': {
        connections: 2,
        how:
            'Founder-CEO of Apex Care Partners and the decision-maker on a sale. Auto-created from the CIM; no ' +
            'direct contact yet. During the process, access is mediated by the banker.',
        internal: 'Met James Walker at an industry event · reachable via the banker',
        depth: { emails: 0, calls: 0, meetings: 0 },
        network: [
            {
                id: 'h1',
                line: 'Thomas Bennett → Michael Hartley (banker)',
                meta: 'Controlled route during the process'
            },
            { id: 'h2', line: 'James Walker — direct, hold for now', meta: 'Do not bypass the banker' }
        ]
    },
    'sarah chen': {
        connections: 0,
        how:
            'CFO of Apex Care Partners; named in the CIM. Will own the financial workstream if the deal ' +
            'progresses. No contact yet.',
        internal: 'None — auto-created from CIM',
        depth: { emails: 2, calls: 0, meetings: 0 },
        network: []
    },
    'patricia nolan': {
        connections: 0,
        how:
            'Chief Medical Officer; named in the CIM as clinical lead across the 22-site network. Relevant to ' +
            'quality and clinical diligence later. No contact yet.',
        internal: 'None — auto-created from CIM',
        depth: { emails: 0, calls: 0, meetings: 0 },
        network: []
    },
    'thomas reilly': {
        connections: 0,
        how:
            'Co-founder and former COO, now in an advisory role per the CIM. Useful for operational history and ' +
            'culture, less so for the transaction itself.',
        internal: 'None — auto-created from CIM',
        depth: { emails: 0, calls: 0, meetings: 0 },
        network: []
    },
    'gregory vance': {
        connections: 1,
        how:
            'Non-Executive Chairman of Apex Care. James Walker served with him on a prior healthcare board, ' +
            'giving us a warm route to the board independent of the banker.',
        internal: 'James Walker (prior board service)',
        depth: { emails: 0, calls: 0, meetings: 0 },
        network: [
            { id: 'v1', line: 'James Walker — prior board service together', meta: 'Warm route to the board' }
        ]
    },
    'karen liu': {
        connections: 0,
        how:
            'Named in a CIM appendix as Head of Payer Relations — relevant given payer concentration is a watch ' +
            'item. Detected from the document; surfaced as a suggested contact for review.',
        internal: 'None — detected from CIM appendix',
        depth: { emails: 0, calls: 0, meetings: 0 },
        network: []
    }
};

// -------------------------------------------------------------------- Network

export const NETWORK_ROWS = [
    {
        id: 'nw1',
        reaches: 'Mark Hargreaves',
        reachesMeta: 'CEO & Founder, Apex Care',
        via: 'Thomas Bennett → Michael Hartley (Houlihan)',
        strength: 'Strong',
        basis: 'Banker controls the process',
        detail:
            'Reaches Mark Hargreaves (CEO & Founder) via Thomas Bennett → Michael Hartley (Houlihan, sell-side). ' +
            'In a managed process the banker controls access to management — this is the primary, strongest route. ' +
            'Route all substantive process communication and management requests through Hartley.'
    },
    {
        id: 'nw2',
        reaches: 'Mark Hargreaves',
        reachesMeta: 'CEO & Founder, Apex Care',
        via: 'James Walker (direct)',
        strength: 'Warm',
        basis: 'Met at industry event',
        detail:
            'Reaches Mark Hargreaves (CEO & Founder) directly via James Walker, who met him at an industry ' +
            'event. Going around the banker this early in a process is sensitive and can damage standing — keep ' +
            'in reserve unless the banker channel stalls.'
    },
    {
        id: 'nw3',
        reaches: 'Gregory Vance',
        reachesMeta: 'Non-Executive Chairman, Apex Care',
        via: 'James Walker (direct)',
        strength: 'Warm',
        basis: 'Prior board service together',
        detail:
            'Reaches Gregory Vance (Non-Executive Chairman) via James Walker, from prior board service together. ' +
            'A warm route to the board, independent of the banker — useful for reading governance and founder ' +
            'sentiment without going through the process.'
    }
];

// ------------------------------------------------------------------ Landscape

export const LANDSCAPE_CATEGORY_OPTIONS = [
    { label: 'Similar', value: 'similar' },
    { label: 'Complementary', value: 'complementary' },
    { label: 'Surfaced in discussions', value: 'surfaced' }
];

export const LANDSCAPE_ROWS = [
    {
        id: 'ls1',
        company: 'Cardinal Rehab Group',
        companyMeta: 'US Outpatient Rehab',
        type: 'Comparable',
        category: 'similar',
        why: 'HL advised on $67M sale — valuation reference',
        source: 'Cap IQ',
        detail:
            'Cardinal Rehab Group — US outpatient rehab; Houlihan Lokey advised on its $67M sale. The closest ' +
            'recent comparable for Apex and a useful valuation reference; also a potential future add-on.'
    },
    {
        id: 'ls2',
        company: 'Lakeside Surgical Partners',
        companyMeta: 'US Healthcare Services',
        type: 'Alt target',
        category: 'similar',
        why: 'Adjacent first-look candidate',
        source: 'AI · sector map',
        detail:
            'Lakeside Surgical Partners — adjacent US healthcare services business; a credible first-look ' +
            'candidate flagged by the sector map. Track alongside Apex.'
    },
    {
        id: 'ls3',
        company: 'Coastal Therapy Network',
        companyMeta: 'Physical Therapy',
        type: 'Add-on',
        category: 'complementary',
        why: 'PT add-on for a buy-and-build around Apex',
        source: 'AI · sector map',
        detail:
            'Coastal Therapy Network — physical-therapy platform; a natural buy-and-build add-on around an Apex ' +
            'acquisition. AI-derived from the sector map; not yet contacted.'
    },
    {
        id: 'ls4',
        company: 'Blackbrook Capital',
        companyMeta: 'PE Firm',
        type: 'Co-investor',
        category: 'surfaced',
        why: 'Building a US outpatient platform',
        source: 'Conference, Mar 2026',
        detail:
            'Blackbrook Capital — building a US outpatient platform; introduced to James Walker at a March 2026 ' +
            'conference. Possible co-investor should we pursue Apex.'
    },
    {
        id: 'ls5',
        company: 'Sterling Health Partners',
        companyMeta: 'Strategic Acquirer',
        type: 'Strategic',
        category: 'surfaced',
        why: 'Named in the CIM as a comparable strategic buyer',
        source: 'CIM',
        detail:
            'Sterling Health Partners — named in the CIM as a comparable strategic acquirer in the space. Useful ' +
            'as a read on strategic interest and pricing.'
    }
];

// --------------------------------------------------------------------- Deals

/** AI read on a deal, keyed by deal name. */
export const DEAL_INSIGHTS = {
    'project everest':
        'Current process. Apex Care Partners — US outpatient rehabilitation, 22 sites, $48M revenue, ~22% ' +
        'EBITDA. NDA executed and the CIM received; initial review. Sourced by Houlihan Lokey. Preliminary EV ' +
        'range $430–480M, to be tested against the CIM. No management meeting or diligence yet.'
};

export const DEAL_STATUS_OPTIONS = [
    { label: 'Active', value: 'active' },
    { label: 'Closed', value: 'closed' },
    { label: 'Passed', value: 'passed' }
];

// -------------------------------------------------------------- Interactions

export const INTERACTION_TYPE_OPTIONS = [
    { label: 'Meetings', value: 'meeting' },
    { label: 'Calls', value: 'call' },
    { label: 'Emails', value: 'email' }
];

/**
 * Full participant lists, keyed by interaction subject. Salesforce holds one
 * primary contact per activity, so the rest sit here until Shared Activities
 * or the Acuity interaction pop-up supplies them.
 */
export const INTERACTION_PARTICIPANTS = {
    'project everest — cim': ['Michael Hartley', 'Thomas Bennett', 'Sarah Chen'],
    'project everest — nda executed': ['Michael Hartley', 'Thomas Bennett'],
    'intro call — project everest opportunity': ['Thomas Bennett', 'Michael Hartley', 'Mark Hargreaves'],
    'project everest — teaser': ['Michael Hartley', 'Thomas Bennett']
};

// ----------------------------------------------------------------- Documents

/** AI read on a document, keyed by title. */
export const DOCUMENT_INSIGHTS = {
    'project everest - cim':
        'CIM for Project Everest (Apex Care Partners), received Jun 27, 2026. The company record and its ' +
        'contacts were auto-created from this document.',
    'project everest - nda (executed)':
        'Executed mutual NDA with Houlihan Lokey for Project Everest, dated Jun 20, 2026.',
    'project everest - teaser':
        'Two-page teaser for Project Everest — anonymised outpatient rehabilitation platform, received ' +
        'Jun 16, 2026, ahead of the NDA.'
};