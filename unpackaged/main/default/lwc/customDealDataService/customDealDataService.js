// dealDataService.js — static data exports for Project Everest demo

export const CURRENT_SUMMARY =
    "Project Everest was sourced by Michael Hartley at Houlihan Lokey in January 2026. " +
    "Apex Care Partners is a UK outpatient rehabilitation business operating 22 clinic sites " +
    "currently in Due Diligence at 11–13× EBITDA with three competing bidders remaining. " +
    "Dr. Webb's regulatory report received today flagged a CMS supervision gap across three " +
    "clinic sites (Guildford, Brighton, Reading) — $5.2M revenue exposure not yet in any deal " +
    "notes or the financial model; specialist legal instruction is overdue before the 18 June " +
    "management meeting. CEO Mark Hargreaves controls 14 of 22 NHS referral relationships and " +
    "has given only verbal retention commitment — Advent International have approached him " +
    "directly, making written terms the most time-sensitive item on the deal. Kirkland & Ellis " +
    "legal DD report expected 16 June with no update received. Final bid deadline: 28 June 2026.";

// ─── Feed Items ───────────────────────────────────────────────────────────────
export const FEED_ITEMS = [
    {
        id: 'gap1',
        type: 'di',
        title: 'Claude detected a gap — CMS supervision risk not in deal notes',
        badge: 'Insights',
        date: '18 Jun 2026 09:14',
        source: 'AI Detected',
        body: 'The CMS supervision requirement change identified on page 18 of Dr. Webb\'s report does not appear in any deal notes, activity records, or open tasks.\n\nRevenue exposure: $5.2M across 3 clinic sites (Guildford, Brighton, Reading). Remediation cost estimate: $0.4M capex + $1.0M annualised opex. This exposure must be reflected in the L.E.K. Consulting financial model before the 28 June bid submission. The 18 June management meeting with Apex Care Partners makes legal instruction to Kirkland & Ellis today time-critical.'
    },
    {
        id: 'ai1',
        type: 'ai',
        title: 'Instruct Kirkland & Ellis on CMS gap before 18 June management meeting',
        badge: 'AI Recommendation',
        date: '18 Jun 2026 09:14',
        source: 'Navatar Intelligence',
        body: 'Immediate action required: instruct Kirkland & Ellis to address the CMS supervision gap identified in Dr. Webb\'s report before the 18 June management meeting.\n\n' +
              'The gap affects sites in Guildford, Brighton, and Reading ($5.2M revenue). Sandra Chen has not yet been briefed on this finding — the DD kick-off call on 10 June predates the report. Recommended action: send the Webb report to Sandra Chen today and request an addendum to the legal DD scope covering CMS compliance obligations.'
    },
    {
        id: 'ai2',
        type: 'ai',
        title: 'Request written retention terms from Mark Hargreaves — Advent contact confirmed',
        badge: 'AI Recommendation',
        date: '18 Jun 2026 08:45',
        source: 'Navatar Intelligence',
        body: 'Mark Hargreaves controls 14 of 22 NHS referral relationships and has given only a verbal retention commitment.\n\n' +
              'Advent International have approached him directly. Written retention terms are the single most time-sensitive item on this deal.\n\n' +
              'Recommended: Finalise written retention terms before 19 June to pre-empt competitive risk.'
    },
    {
        id: 'ai3',
        type: 'ai',
        title: 'Update financial model — add $5.2M CMS exposure to scenario analysis',
        badge: 'AI Recommendation',
        date: '18 Jun 2026 09:00',
        source: 'Navatar Intelligence',
        body: 'The current financial model (LEK v3, received 16 June) does not reflect the $5.2M CMS revenue exposure identified in Dr. Webb\'s report.\n\n' +
              'Updated model assumptions should reflect:\n' +
              '• Downside case with CMS remediation costs\n' +
              '• Revised EBITDA bridge\n' +
              '• Sensitivity on referral concentration (Hargreaves)\n\n' +
              'Recommended: S. Patel to update model by 20 June ahead of internal IC prep.'
    },
    {
        id: 'news1',
        type: 'news',
        title: 'NHS CMS outpatient supervision policy change — effective Q3 2026',
        badge: 'News',
        date: '18 Jun 2026 07:30',
        source: 'NHS England',
        body: 'The Care Quality Commission has issued updated supervision standards for outpatient rehabilitation clinics, effective Q3 2026. Clinics failing to meet clinical supervision ratios face enforcement action and potential registration suspension.\n\n' +
              'The new standards require at least one registered clinical supervisor per 8 therapy staff — a tighter ratio than the previous 1:12 guidance.\n\n' +
              'Relevant to: Apex Care Partners — Webb Report identifies non-compliance at 3 sites.'
    },
    {
        id: 'email1',
        type: 'email',
        title: 'RE: Project Everest — Dr. Webb Regulatory Report',
        badge: 'Email',
        date: '17 Jun 2026 16:42',
        source: 'Michael Hartley → Thomas Bennett',
        body: 'Tom,\n\nJust reviewed the Webb report you shared. The CMS supervision gap at three sites is more significant than the CIM suggested.\n\n' +
              'A few points:\n' +
              '1. You should instruct Kirkland immediately — this needs legal framing before the management meeting.\n' +
              '2. The $5.2M exposure figure needs to appear in the financial model before bid submission.\n' +
              '3. We can hold a brief call tomorrow to align on how to frame this in the bid letter.\n\n' +
              'Best,\nMichael'
    },
    {
        id: 'meet1',
        type: 'meeting',
        title: 'Management Presentation — Apex Care Partners',
        badge: 'Meeting',
        date: '12 Jun 2026',
        source: 'James Walker, Thomas Bennett, Michael Hartley, Mark Hargreaves, Sarah Chen',
        body: 'Management Presentation held at Houlihan Lokey offices, London.\n\n' +
              'Attendees: James Walker, Thomas Bennett, Sarah Chen (Navatar); Michael Hartley, Kate Patterson (HLK); Mark Hargreaves, CFO James Wren (Apex Care).\n\n' +
              'Key takeaways:\n' +
              '• Hargreaves presented the clinic expansion roadmap (target: 30 sites by 2028)\n' +
              '• NHS referral relationships confirmed as personal to Hargreaves — no formal transfer mechanism\n' +
              '• CFO Wren flagged potential CMS compliance review underway\n' +
              '• Retention conversation deferred — Hargreaves cited "advisor guidance"\n\n' +
              'Follow-up: Request written NHS referral data and formal retention term proposal.'
    },
    {
        id: 'di1',
        type: 'di',
        title: 'Bidder intelligence — Advent International bid team confirmed via LinkedIn',
        badge: 'Insights',
        date: '17 Jun 2026',
        source: 'AI Detected',
        body: 'Based on LinkedIn activity and banker communications, Advent International\'s bid team for Project Everest has been identified:\n\n' +
              '• Lead Partner: confirmed active on similar UK healthcare deals\n' +
              '• Advent have engaged a specialist CQC compliance advisor — suggesting they are aware of regulatory risk\n' +
              '• Intelligence indicates Advent\'s indicative range: $125–140M EV\n\n' +
              'Our position at $114–135M may need to be sharpened. Retention terms remain the key differentiator.'
    },
    {
        id: 'email2',
        type: 'email',
        title: 'Project Everest — Financial Model v3 from L.E.K.',
        badge: 'Email',
        date: '16 Jun 2026',
        source: 'David Ross → Thomas Bennett, Sarah Patel',
        body: 'Thomas, Sarah,\n\nPlease find attached LEK financial model v3. Key changes from v2:\n\n' +
              '• Updated EBITDA margin to 20.1% (from 22%) based on normalised 2025 actuals\n' +
              '• Added Guildford site ramp-up phasing\n' +
              '• Revised capex schedule based on management discussion\n' +
              '• EV range updated to $114–135M (entry 11–13× EBITDA)\n\n' +
              'Note: model does not yet reflect any CMS compliance remediation costs — awaiting Webb report.\n\n' +
              'David'
    },
    {
        id: 'news2',
        type: 'news',
        title: 'Advent International increases UK healthcare PE allocation by 40%',
        badge: 'News',
        date: '15 Jun 2026',
        source: 'Healthcare Investor',
        body: 'Advent International is reported to have increased its UK healthcare private equity allocation by 40% for 2026, citing strong pipeline and attractive valuations in the outpatient and rehabilitation sectors.\n\n' +
              'This corroborates intelligence that Advent has approached Apex Care Partners\' CEO directly and is a motivated and well-funded competitor in the Project Everest process.'
    },
    {
        id: 'di2',
        type: 'di',
        title: 'Mark Hargreaves LinkedIn activity — 3 connections to Advent International in past 10 days',
        badge: 'Insights',
        date: '16 Jun 2026',
        source: 'AI Detected',
        body: 'Navatar AI detected that Mark Hargreaves (CEO, Apex Care Partners) has connected with 3 senior Advent International professionals on LinkedIn in the past 10 days.\n\n' +
              '• Connections include Advent\'s UK Healthcare Partner and two Operating Partners\n' +
              '• Activity commenced shortly after the Round 2 process letter was issued\n\n' +
              'This corroborates direct approach intelligence and increases urgency of written retention terms.',
        isHidden: true
    },
    {
        id: 'meet2',
        type: 'meeting',
        title: 'DD Kick-off — L.E.K. Consulting & Kirkland & Ellis',
        badge: 'Meeting',
        date: '10 Jun 2026',
        source: 'Sarah Patel, David Ross, Sandra Chen',
        body: 'DD Kick-off call with L.E.K. Consulting and Kirkland & Ellis teams.\n\n' +
              'Attendees: Sarah Patel (Navatar); David Ross, Sandra Chen (LEK); Kirkland & Ellis TBC.\n\n' +
              'Agreed workstream split:\n' +
              '• Financial: LEK (Ross lead) — model, normalised EBITDA, working capital\n' +
              '• Regulatory/Clinical: Webb Associates — CQC compliance, CMS standards, clinical governance\n' +
              '• Legal: Kirkland & Ellis — corporate, employment, regulatory\n\n' +
              'Target: All DD reports by 20 June. Legal report by 16 June.',
        isHidden: true
    },
    {
        id: 'di3',
        type: 'di',
        title: 'Guildford CCG referral volume — 3-month downward trend flagged',
        badge: 'Insights',
        date: '14 Jun 2026',
        source: 'AI Detected',
        body: 'Analysis of NHS referral data shows Guildford CCG referral volumes to Apex Care Partners have declined over the past 3 months.\n\n' +
              '• Referral volume down 11% vs. prior 3-month period\n' +
              '• Trend pre-dates the CMS supervision gap identified by Dr. Webb\n' +
              '• May indicate early regulatory pressure or relationship deterioration\n\n' +
              'Recommend flagging to LEK for inclusion in financial model sensitivity analysis.',
        isHidden: true
    },
    {
        id: 'email3',
        type: 'email',
        title: 'Project Everest — Process Letter from Houlihan Lokey',
        badge: 'Email',
        date: '11 Jun 2026',
        source: 'Michael Hartley → Thomas Bennett',
        body: 'Thomas,\n\nPlease find attached the Round 2 process letter. Key points:\n\n' +
              '• Final bid deadline: 28 June 2026, 17:00 BST\n' +
              '• Bids to be submitted via secure data room\n' +
              '• Debt financing terms to be included\n' +
              '• Management retention proposals required with bid\n' +
              '• Site visits available 17–19 June (book via Kate Patterson)\n\n' +
              'Let me know if you have questions.\n\nMichael',
        isHidden: true
    },
    {
        id: 'ai4',
        type: 'ai',
        title: 'Engage Robert Ashford — NED Influence on Hargreaves retention material',
        badge: 'AI Recommendation',
        date: '15 Jun 2026',
        source: 'Navatar Intelligence',
        body: 'Robert Ashford is a healthcare sector advisor in the Navatar network with deep expertise in UK outpatient services.\n\n' +
              'He previously advised on Project Lighthouse (a similar deal won by Navatar in 2024) and has existing relationships with NHS trust procurement leads.\n\n' +
              'Recommended: Engage Ashford as a Non-Executive Director candidate to strengthen the retention narrative for Mark Hargreaves and provide independent sector credibility in the bid.',
        isHidden: true
    },
    {
        id: 'di4',
        type: 'di',
        title: 'L.E.K. EBITDA normalization confirmed at $10.5M — model updated',
        badge: 'Insights',
        date: '13 Jun 2026',
        source: 'AI Detected',
        body: 'L.E.K. Consulting has confirmed normalised EBITDA of $10.5M for Apex Care Partners, following adjustments for one-off items and management accounts reconciliation.\n\n' +
              '• Normalised margin: 19.4% (vs. 22% in CIM)\n' +
              '• Key adjustments: CEO remuneration, non-recurring Guildford costs, working capital seasonality\n' +
              '• Model v3 updated to reflect confirmed figures\n\n' +
              'Note: figure does not yet incorporate CMS remediation costs from Webb report.',
        isHidden: true
    },
    {
        id: 'news3',
        type: 'news',
        title: 'UK outpatient rehab M&A activity — Q2 2026 review',
        badge: 'News',
        date: '12 Jun 2026',
        source: 'Healthcare Finance',
        body: 'Q2 2026 has seen a surge in UK outpatient rehabilitation M&A activity, with 7 transactions completed or announced in the sector.\n\n' +
              '• Average entry multiple: 11.8× EBITDA\n' +
              '• PE buyers dominant (5 of 7 deals)\n' +
              '• NHS referral dependency flagged as key risk factor in 4 transactions\n\n' +
              'Apex Care Partners\' 11–13× entry range aligns with current market pricing.',
        isHidden: true
    },
    {
        id: 'meet3',
        type: 'meeting',
        title: 'Introductory Call — Apex Care Partners Management Team',
        badge: 'Meeting',
        date: '5 Jun 2026',
        source: 'Thomas Bennett, Michael Hartley, Mark Hargreaves',
        body: 'Initial introductory call with Apex Care Partners management team.\n\n' +
              'Attendees: Thomas Bennett (Navatar); Michael Hartley (HLK); Mark Hargreaves (CEO, Apex Care).\n\n' +
              'Key discussion points:\n' +
              '• Overview of business model and clinic network\n' +
              '• Growth strategy and expansion plans\n' +
              '• NHS referral relationships and regulatory environment\n' +
              '• Process timeline and next steps',
        isHidden: true
    },
    {
        id: 'email4',
        type: 'email',
        title: 'Project Everest — CIM received from Houlihan Lokey',
        badge: 'Email',
        date: '5 Jun 2026',
        source: 'Michael Hartley → Thomas Bennett',
        body: 'Thomas,\n\nPlease find attached the Confidential Information Memorandum for Project Everest (Apex Care Partners).\n\n' +
              'Key details:\n' +
              '• 22-site UK outpatient rehabilitation business\n' +
              '• Revenue: ~$113M | EBITDA: ~$25M (22% margin as guided)\n' +
              '• Process: competitive auction, Round 2 bids due late June\n' +
              '• NDA to be countersigned and returned\n\n' +
              'Happy to walk through the CIM on a call this week.\n\nBest,\nMichael',
        isHidden: true
    }
];

// ─── Key Metrics ──────────────────────────────────────────────────────────────
export const KEY_METRICS = [
    { id: 'km1', label: 'Stage', value: 'Due Diligence' },
    { id: 'km2', label: 'Days in Stage', value: '68 days' },
    { id: 'km3', label: 'EV Range (Est.)', value: '$114–135M' },
    { id: 'km4', label: 'Entry Multiple', value: '11–13× EBITDA' },
    { id: 'km5', label: 'Competing Bidders', value: '3 remaining' },
    { id: 'km6', label: 'Final Bid Deadline', value: '28 Jun 2026' }
];

// ─── Tasks ────────────────────────────────────────────────────────────────────
export const TASKS_ALL = [
    { id: 't1', title: 'Instruct Kirkland on CMS supervision gap', assignee: 'T. Bennett', due: '18 Jun 2026', priority: 'High', done: false },
    { id: 't2', title: 'Request written retention terms — Hargreaves', assignee: 'T. Bennett', due: '19 Jun 2026', priority: 'High', done: false },
    { id: 't3', title: 'Update financial model — CMS exposure', assignee: 'S. Patel', due: '20 Jun 2026', priority: 'Medium', done: false },
    { id: 't4', title: 'Confirm final bid submission checklist with Houlihan Lokey', assignee: 'T. Bennett', due: '25 Jun 2026', priority: 'Medium', done: false },
    { id: 't5', title: 'Review Dr. Webb regulatory report', assignee: 'T. Bennett', due: '18 Jun 2026', priority: 'High', done: true }
];

export const TASKS_MINE = [
    { id: 't1', title: 'Instruct Kirkland on CMS supervision gap', assignee: 'T. Bennett', due: '18 Jun 2026', priority: 'High', done: false },
    { id: 't2', title: 'Request written retention terms — Hargreaves', assignee: 'T. Bennett', due: '19 Jun 2026', priority: 'High', done: false },
    { id: 't5', title: 'Review Dr. Webb regulatory report', assignee: 'T. Bennett', due: '18 Jun 2026', priority: 'High', done: true }
];

// ─── People ───────────────────────────────────────────────────────────────────
export const PEOPLE_DATA = [
    { id: 'p1', name: 'Thomas Bennett', company: 'Ironwood Capital', group: 'Internal', role: 'Deal Lead, Partner', email: 'tbennett@ironwoodcap.com', lastTouchpoint: '18 Jun 2026', lastTouchType: 'Meeting', type: 'internal' },
    { id: 'p2', name: 'Sarah Patel', company: 'Ironwood Capital', group: 'Internal', role: 'Associate', email: 'spatel@ironwoodcap.com', lastTouchpoint: '18 Jun 2026', lastTouchType: 'Email', type: 'internal' },
    { id: 'p3', name: 'Michael Hartley', company: 'Houlihan Lokey', group: 'Banker', role: 'MD, Deal Lead', email: 'mhartley@hl.com', lastTouchpoint: '17 Jun 2026', lastTouchType: 'Email', type: 'external' },
    { id: 'p4', name: 'Kate Patterson', company: 'Houlihan Lokey', group: 'Banker', role: 'Analyst', email: 'kpatterson@hl.com', lastTouchpoint: '16 Jun', lastTouchType: 'Email', type: 'external' },
    { id: 'p5', name: 'Dr. Marcus Webb', company: 'Webb Regulatory Advisory', group: 'DD & Experts', role: 'Regulatory Expert', email: 'm.webb@webreg.co.uk', lastTouchpoint: '18 Jun 2026', lastTouchType: 'Document', type: 'external' },
    { id: 'p6', name: 'Sandra Chen', company: 'Kirkland & Ellis', group: 'DD & Experts', role: 'Legal DD Lead', email: 's.chen@kirkland.com', lastTouchpoint: '10 Jun', lastTouchType: 'Meeting', type: 'external' },
    { id: 'p7', name: 'David Ross', company: 'L.E.K. Consulting', group: 'DD & Experts', role: 'Financial DD Lead', email: 'd.ross@lek.com', lastTouchpoint: '16 Jun', lastTouchType: 'Email', type: 'external' },
    { id: 'p8', name: 'Mark Hargreaves', company: 'Apex Care Partners', group: 'Target', role: 'CEO', email: 'm.hargreaves@apexcare.co.uk', lastTouchpoint: '12 Jun', lastTouchType: 'Meeting', type: 'external' },
    { id: 'p9', name: 'Robert Ashford', company: 'Apex Care Partners', group: 'In Navatar', role: 'Non-Executive Director', email: 'r.ashford@apexcare.co.uk', lastTouchpoint: 'Apr 2022', lastTouchType: 'Email', type: 'ai-recommended', inNavatar: true },
    { id: 'p10', name: 'Dr. Rachel Morrison', company: 'NHS CMS Compliance Advisory', group: 'Not in Navatar', role: 'CMS Supervision Expert', email: null, lastTouchpoint: null, lastTouchType: null, type: 'ai-recommended', inNavatar: false },
    { id: 'p11', name: 'James Wren', company: 'Advent International', group: 'Not in Navatar', role: 'Associate, Healthcare PE', email: null, lastTouchpoint: null, lastTouchType: null, type: 'ai-recommended', inNavatar: false }
];

export const PEOPLE_BRIEFINGS = {
    p1: 'Thomas Bennett is the deal lead for Project Everest and has been managing the process since sourcing in January 2026. He has a strong relationship with Michael Hartley at Houlihan Lokey and led the management presentation in June. Thomas is responsible for all key decision points and is the primary contact for legal and banker communications.',
    p2: 'Sarah Patel joined the deal team in March 2026 and is leading the financial modelling workstream. She has been working closely with the LEK team on the EBITDA bridge and capex schedule. Sarah\'s most recent task is to update the model to reflect the CMS revenue exposure identified in the Webb report.',
    p3: 'Michael Hartley is a Managing Director at Houlihan Lokey running the sell-side process for Apex Care Partners. He has a long-standing relationship with Navatar and sourced this deal directly. Michael has been responsive and helpful in the process but his recent communications suggest he is managing multiple interested parties carefully.',
    p4: 'Kate Patterson is the Director at Houlihan Lokey supporting Michael Hartley on the Apex Care process. She manages day-to-day logistics including data room access, site visit bookings, and process letter distribution. She is the primary operational contact at the bank.',
    p5: 'Dr. Marcus Webb is an independent clinical regulatory advisor commissioned to assess Apex Care\'s CQC compliance and CMS supervision standards. His report, received today, identifies material compliance gaps at three sites. Webb has extensive experience advising PE firms on UK healthcare regulatory risk and is well regarded in the sector.',
    p6: 'Sandra Chen is a Financial Analyst at LEK Consulting supporting David Ross on the financial due diligence. She has been building the detailed site-level financial model and contributed to the normalised EBITDA analysis. Sandra flagged potential working capital seasonality in v3 of the model.',
    p7: 'David Ross is a Partner at LEK Consulting leading the financial due diligence for Project Everest. He delivered the v3 financial model on 16 June, updating margins and EV range. David is a specialist in UK healthcare services and has worked with Navatar on two previous transactions.',
    p8: 'Mark Hargreaves is the CEO of Apex Care Partners and the critical retention risk in this deal. He personally manages 14 of 22 NHS trust relationships and has given only a verbal retention commitment to date. Intelligence suggests Advent International have approached him directly, making written retention terms urgent.',
    p9: 'Robert Ashford is a healthcare sector advisor in the Navatar network with deep expertise in UK outpatient services. He previously advised on Project Lighthouse (a similar deal won by Navatar in 2024) and has contacts across NHS trust procurement teams. Navatar AI recommends engaging him for sector intelligence and potential introductions.',
    p10: 'Dr. Rachel Morrison is a CQC compliance specialist not currently in the Navatar network. Her published work on CMS supervision standards is directly relevant to the gap identified in the Webb report. Navatar AI recommends a warm introduction via Robert Ashford to obtain a rapid second opinion on remediation options.',
    p11: 'James Wren is the CFO of Apex Care Partners and attended the management presentation on 12 June. He flagged a potential CMS compliance review during the presentation. Navatar AI recommends building a separate relationship with Wren as a secondary management contact and potential ally in retention discussions.'
};

// ─── Interactions ─────────────────────────────────────────────────────────────
export const INTERACTIONS_DATA = [
    {
        id: 'i1',
        type: 'email',
        date: '18 Jun 2026 09:05',
        subject: 'RE: Dr. Webb Regulatory Report — CMS Findings',
        snippet: 'Thanks Thomas — I\'ve reviewed the report. The supervision ga...',
        participants: ['Michael Hartley', 'Thomas Bennett'],
        body: 'Tom,\n\nThanks for sharing the Webb report. The supervision gap at Guildford, Brighton, and Reading is more significant than we anticipated from the CIM.\n\nA few immediate actions:\n1. Kirkland must be instructed today — this needs legal framing before the management meeting on 18 June.\n2. The $5.2M exposure needs to be in the financial model before bid submission.\n3. Let\'s align on how to frame this in the bid letter — can we speak tomorrow morning?\n\nBest,\nMichael'
    },
    {
        id: 'i2',
        type: 'meeting',
        date: '12 Jun 2026',
        subject: 'Management Presentation — Apex Care Partners',
        snippet: 'Good morning everyone, thank you for making the trip to Guildf...',
        participants: ['Thomas Bennett', 'Sarah Patel', 'Michael Hartley'],
        body: 'Management Presentation held at Houlihan Lokey offices, London.\n\nKey takeaways:\n• Hargreaves presented the clinic expansion roadmap (target: 30 sites by 2028)\n• NHS referral relationships confirmed as personal to Hargreaves — no formal transfer mechanism\n• CFO Wren flagged potential CMS compliance review underway\n• Retention conversation deferred — Hargreaves cited "advisor guidance"\n\nFollow-up: Request written NHS referral data and formal retention term proposal.'
    },
    {
        id: 'i3',
        type: 'email',
        date: '16 Jun 2026',
        subject: 'Project Everest — Financial Model v3',
        snippet: 'Thomas, please find attached the updated model. EBITDA nor...',
        participants: ['David Ross', 'Thomas Bennett'],
        body: 'Thomas,\n\nPlease find attached LEK financial model v3. Key changes from v2:\n\n• Updated EBITDA margin to 20.1% (from 22%) based on normalised 2025 actuals\n• Added Guildford site ramp-up phasing\n• Revised capex schedule based on management discussion\n• EV range updated to $114–135M (entry 11–13× EBITDA)\n\nNote: model does not yet reflect any CMS compliance remediation costs — awaiting Webb report.\n\nDavid'
    },
    {
        id: 'i4',
        type: 'call',
        date: '10 Jun 2026',
        subject: 'DD Kick-off Call — L.E.K. & Kirkland',
        snippet: '0:00 TB: Good morning everyone. Before we kick off I want to fl...',
        participants: ['Thomas Bennett', 'David Ross', 'Sandra Chen'],
        body: '0:00 TB: Good morning everyone. Before we kick off I want to flag that the Webb report has identified a CMS supervision issue that will affect the legal scope.\n\nAgreed workstream split:\n• Financial: LEK (Ross lead) — model, normalised EBITDA, working capital\n• Regulatory/Clinical: Webb Associates — CQC compliance, CMS standards, clinical governance\n• Legal: Kirkland & Ellis (to be instructed) — corporate, employment, regulatory\n\nTarget: All DD reports by 20 June. Legal report by 16 June.'
    },
    {
        id: 'i5',
        type: 'email',
        date: '11 Jun 2026',
        subject: 'Project Everest — Process Letter',
        snippet: 'Dear Thomas, please find attached the formal process letter for...',
        participants: ['Michael Hartley', 'Thomas Bennett'],
        body: 'Dear Thomas,\n\nPlease find attached the formal process letter for Round 2 of Project Everest. Key points:\n\n• Final bid deadline: 28 June 2026, 17:00 BST\n• Bids to be submitted via secure data room\n• Debt financing terms to be included\n• Management retention proposals required with bid\n• Site visits available 17–19 June (book via Kate Patterson)\n\nBest regards,\nMichael Hartley\nHoulihan Lokey'
    }
];

// ─── Similar Deals ────────────────────────────────────────────────────────────
export const SIMILAR_DEALS = [
    {
        id: 'sd1',
        name: 'Project Lighthouse',
        geography: 'UK Healthcare Services',
        sector: 'Outpatient Rehab',
        revenue: '$53M',
        multiple: '12×',
        outcome: 'Won · Closed',
        match: 94,
        body: 'Project Lighthouse was a UK outpatient rehabilitation business acquired by Navatar in 2024. The deal featured similar NHS referral concentration risk and a competitive process with 4 bidders. Navatar won at 12× after securing a written retention agreement with the founding CEO 10 days before bid submission. Key lesson: early written retention terms were a decisive differentiator.'
    },
    {
        id: 'sd2',
        name: 'Project Beacon',
        geography: 'UK Healthcare Services',
        sector: 'Outpatient Rehab',
        revenue: '$35M',
        multiple: '9.5×',
        outcome: 'Lost · LOI Stage',
        match: 88,
        body: 'Project Beacon was a UK outpatient rehabilitation group that went to a competitive process in 2023. Navatar submitted an LOI at 9.5× but lost to a strategic buyer at a higher multiple. The deal had similar CQC compliance exposure which Navatar priced in but competitors did not. Key lesson: strategic buyers often ignore regulatory risk — financial models must be realistic.'
    },
    {
        id: 'sd3',
        name: 'Project Atlas',
        geography: 'UK Healthcare Services',
        sector: 'Allied Health Services',
        revenue: '$44M',
        multiple: '11×',
        outcome: 'Won · Closed',
        match: 81,
        body: 'Project Atlas was a UK allied health services business acquired by Navatar in 2022. The deal involved 3 competing bidders and a complex regulatory environment. Navatar\'s DD team identified a compliance gap early and used it as a negotiation lever to reduce the purchase price by $8M. Key lesson: regulatory gaps identified early can be value creation opportunities.'
    }
];

// ─── Lenders ──────────────────────────────────────────────────────────────────
export const LENDERS_DATA = [
    { id: 'l1', firm: 'Ares Management', type: 'Unitranche', contact: 'David Saunders', status: 'Engaged', lastActivity: '14 Jun 2026', aiRecommended: false },
    { id: 'l2', firm: 'Owl Rock Capital', type: 'Senior', contact: 'Rachel Moore', status: 'Contacted', lastActivity: '10 Jun 2026', aiRecommended: false },
    { id: 'l3', firm: 'Golub Capital', type: 'Unitranche', contact: 'James Whitfield', status: 'Contacted', lastActivity: '7 Jun 2026', aiRecommended: false },
    { id: 'l4', firm: 'HPS Investment Partners', type: 'Mezz', contact: null, status: 'AI Recommended', lastActivity: '—', aiRecommended: true },
    { id: 'l5', firm: 'Benefit Street Partners', type: 'Senior', contact: null, status: 'AI Recommended', lastActivity: '—', aiRecommended: true },
    { id: 'l6', firm: 'Monroe Capital', type: 'Mezz', contact: null, status: 'AI Recommended', lastActivity: '—', aiRecommended: true }
];

// ─── Co-Investors ─────────────────────────────────────────────────────────────
export const CO_INVESTORS_DATA = [
    { id: 'ci1', firm: 'GIC Private Limited', type: 'SWF', contact: 'Marcus Tan', status: 'Soft Circle', lastActivity: '16 Jun 2026', aiRecommended: false },
    { id: 'ci2', firm: 'Hamilton Lane', type: 'LP', contact: 'Sarah Okonkwo', status: 'Soft Circle', lastActivity: '15 Jun 2026', aiRecommended: false },
    { id: 'ci3', firm: 'Pantheon Ventures', type: 'LP', contact: 'Oliver Brennan', status: 'Reviewing Materials', lastActivity: '13 Jun 2026', aiRecommended: false },
    { id: 'ci4', firm: 'Harbourvest Partners', type: 'LP', contact: 'Claire Dubois', status: 'Reviewing Materials', lastActivity: '11 Jun 2026', aiRecommended: false },
    { id: 'ci5', firm: 'Temasek Holdings', type: 'SWF', contact: 'Wei Liang', status: 'Soft Circle', lastActivity: '10 Jun 2026', aiRecommended: false },
    { id: 'ci6', firm: 'LGT Capital Partners', type: 'Family Office', contact: 'Franz Meier', status: 'NDA Signed', lastActivity: '6 Jun 2026', aiRecommended: false },
    { id: 'ci7', firm: 'Stepstone Group', type: 'LP', contact: 'Anna Svensson', status: 'NDA Signed', lastActivity: '4 Jun 2026', aiRecommended: false },
    { id: 'ci8', firm: 'Pictet Alternative Advisors', type: 'Family Office', contact: 'Laurent Vidal', status: 'Introductory Call', lastActivity: '28 May 2026', aiRecommended: false },
    { id: 'ci9', firm: 'Adams Street Partners', type: 'LP', contact: 'Michael Gross', status: 'Introductory Call', lastActivity: '22 May 2026', aiRecommended: false },
    { id: 'ci10', firm: 'Mubadala Investment Company', type: 'SWF', contact: 'Khalid Al Rashid', status: 'Introductory Call', lastActivity: '19 May 2026', aiRecommended: false },
    { id: 'ci11', firm: 'Partners Group', type: 'LP', contact: null, contactBlue: true, status: 'AI Recommended', lastActivity: '—', aiRecommended: true },
    { id: 'ci12', firm: 'Alpinvest Partners', type: 'LP', contact: null, contactBlue: true, status: 'AI Recommended', lastActivity: '—', aiRecommended: true },
    { id: 'ci13', firm: 'Coller Capital', type: 'LP', contact: null, contactBlue: true, status: 'AI Recommended', lastActivity: '—', aiRecommended: true },
    { id: 'ci14', firm: 'Horsley Bridge Partners', type: 'Family Office', contact: null, contactBlue: false, status: 'AI Recommended', lastActivity: '—', aiRecommended: true },
    { id: 'ci15', firm: 'Unigestion', type: 'LP', contact: null, contactBlue: false, status: 'AI Recommended', lastActivity: '—', aiRecommended: true }
];

// ─── Documents ────────────────────────────────────────────────────────────────
export const DOCUMENTS_DATA = [
    {
        id: 'doc1',
        name: 'Project Everest — Confidential Information Memorandum',
        source: 'SharePoint',
        type: 'Received',
        date: '12 Feb 2026',
        meta: 'PDF, 94 pages · Houlihan Lokey',
        body: 'The CIM provides a comprehensive overview of Apex Care Partners\' business, including clinic locations, NHS referral relationships, financial performance (2022–2025 actuals), management team biographies, and growth strategy. Key issues identified: EBITDA margin guidance appears optimistic vs. management accounts; NHS referral section lacks site-level detail; no mention of CMS compliance obligations.'
    },
    {
        id: 'doc2',
        name: 'Management Accounts — Q1 2026',
        source: 'SharePoint',
        type: 'Received',
        date: '1 May 2026',
        meta: 'Excel, 3 tabs · Apex Care Partners',
        body: 'Q1 2026 management accounts for Apex Care Partners. Normalised EBITDA of £18.4M (19.4% margin) vs. CIM guidance of 22%. Working capital shows Q3 seasonality. Site-level P&L reveals Guildford site underperforming vs. plan — likely related to CMS compliance issues flagged in Webb report.'
    },
    {
        id: 'doc3',
        name: 'Regulatory Due Diligence Report — Dr. M. Webb',
        source: 'Navatar',
        type: 'Received',
        date: '18 Jun 2026 08:47',
        meta: 'PDF, 47 pages · Webb Regulatory Advisory',
        body: 'Clinical and regulatory due diligence report by Dr. Marcus Webb. Key finding: CMS supervision gap at Guildford, Brighton, and Reading sites — estimated $5.2M revenue exposure if enforcement action taken. Remediation estimated at £800K–1.2M. Report recommends immediate specialist legal instruction and disclosure review. This is the most material DD finding to date.'
    },
    {
        id: 'doc4',
        name: 'Financial Due Diligence Model v3 — L.E.K. Consulting',
        source: 'Navatar',
        type: 'Received',
        date: '16 Jun 2026',
        meta: 'Excel, 12 tabs · L.E.K. Consulting',
        body: 'LEK financial model v3 with updated EBITDA margin (20.1%), revised capex schedule, and Guildford site ramp-up phasing. EV range: $114–135M at 11–13× EBITDA. Note: model does not yet incorporate CMS remediation costs from Webb report — update required before bid submission.'
    },
    {
        id: 'doc5',
        name: 'Legal DD Draft — Kirkland & Ellis (AI Summary)',
        source: 'Navatar',
        type: 'AI Generated',
        date: '17 Jun 2026',
        meta: 'Report · Navatar Intelligence',
        body: 'AI-generated draft legal DD scope for Kirkland & Ellis instruction, based on Webb report findings and standard PE healthcare DD framework. Covers: corporate structure, employment contracts (Hargreaves retention), CMS compliance and regulatory risk, NHS contract review, IP and data protection, litigation review. Includes specific requests related to CMS gap at three identified sites. Ready for Thomas Bennett review before sending.'
    }
];

// ─── Feed Actions ─────────────────────────────────────────────────────────────
export const FEED_ACTIONS = {
    gap1: [
        {
            type: 'email',
            label: 'Email Kirkland & Ellis — Instruct on CMS Gap',
            email: {
                to: 'kirkland@kirkland.com',
                subject: 'Project Everest — Urgent: CMS Supervision Gap Instruction',
                body: 'Dear Team,\n\nWe have received Dr. Webb\'s regulatory report identifying a CMS supervision gap across three Apex Care Partners sites (Guildford, Brighton, Reading) with estimated revenue exposure of $5.2M.\n\nWe require urgent legal DD instruction covering CMS compliance, regulatory risk, and disclosure obligations. Please confirm scope and availability.\n\nRegards,\nThomas Bennett'
            }
        },
        { type: 'task', label: 'Create task: Update financial model for CMS exposure', task: { title: 'Update financial model for CMS exposure', assignee: 'S. Patel', due: '20 Jun', priority: 'High' } },
        { type: 'stub', label: 'Add to deal notes' }
    ],
    ai1: [
        { type: 'task', label: 'Create task: Finalise CEO retention terms', task: { title: 'Finalise CEO retention terms with Hargreaves', assignee: 'T. Bennett', due: '19 Jun', priority: 'High' } },
        { type: 'stub', label: 'Draft retention term sheet' },
        { type: 'stub', label: 'Flag to IC' }
    ],
    ai2: [
        { type: 'stub', label: 'Chase Kirkland for status update' },
        { type: 'stub', label: 'Escalate to deal lead' },
        { type: 'stub', label: 'Add to risk log' }
    ],
    ai3: [
        { type: 'stub', label: 'Assign model update to S. Patel' },
        { type: 'stub', label: 'Add to IC prep agenda' }
    ],
    news1: [
        { type: 'stub', label: 'Add to competitive intelligence log' }
    ],
    email1: [
        { type: 'stub', label: 'Reply to Michael Hartley' },
        { type: 'stub', label: 'Add to deal notes' }
    ],
    meet1: [
        { type: 'stub', label: 'Log follow-up actions' },
        { type: 'stub', label: 'Request NHS referral data' }
    ],
    di1: [
        { type: 'stub', label: 'Add to IC memo' },
        { type: 'stub', label: 'Create retention risk task' }
    ],
    email2: [
        { type: 'stub', label: 'Acknowledge receipt' },
        { type: 'stub', label: 'Share with IC team' }
    ],
    news2: [
        { type: 'stub', label: 'Add to regulatory risk section' }
    ],
    di2: [
        { type: 'stub', label: 'Update bid strategy' }
    ],
    meet2: [
        { type: 'stub', label: 'Log meeting notes' }
    ],
    email3: [
        { type: 'stub', label: 'Acknowledge process letter' },
        { type: 'stub', label: 'Book site visits via Kate Patterson' }
    ],
    ai4: [
        { type: 'stub', label: 'Initiate lender conversations' }
    ],
    email4: [
        { type: 'stub', label: 'Follow up with Dr. Morrison' }
    ]
};

// ─── Chat Responses ───────────────────────────────────────────────────────────
export const CHAT_RESPONSES = {
    'Summarize this deal': 'Project Everest is a competitive auction for Apex Care Partners, a UK outpatient rehabilitation business with 22 clinic sites. Sourced by Michael Hartley at Houlihan Lokey in January 2026, the deal is currently in Due Diligence at 11–13× EBITDA with three bidders remaining. Key risks: CMS supervision gap ($5.2M exposure, three sites), CEO retention (Hargreaves controls 14/22 NHS relationships, verbal commitment only, Advent have approached him), and Kirkland legal report overdue. Final bid deadline: 28 June 2026.',
    'Find similar deals': 'Three comparable deals found in Navatar\'s deal history:\n\n1. Project Lighthouse (94% match) — UK outpatient rehab, Won at 10.5× EBITDA in 2024. Key parallel: NHS referral concentration resolved by written CEO retention 10 days before bid.\n\n2. Project Beacon (88% match) — UK physiotherapy clinics, Lost LOI at 12× to strategic buyer at 14×. Key lesson: strategic buyers ignore regulatory risk.\n\n3. Project Atlas (81% match) — Irish outpatient services, Won at 11.2× in 2022. CQC gap used as price negotiation lever, reducing purchase price by $8M.',
    'Summarize documents received': 'Four documents received to date:\n\n• CIM (5 Jun) — 84-page overview from HLK. EBITDA margin guidance appears optimistic; NHS referral section lacks detail.\n\n• Management Accounts FY2025 (8 Jun) — Normalised EBITDA £18.4M (19.4% margin vs. 22% guided). Guildford underperforming.\n\n• Webb Regulatory Report (18 Jun, today) — CMS gap at 3 sites, $5.2M exposure, £800K–1.2M remediation. Most material finding to date.\n\n• LEK Model v3 (16 Jun) — EV $114–135M. Does not yet reflect CMS remediation costs.\n\nOne AI-generated document: Kirkland instruction draft — ready for review.',
    'What are the next steps?': 'Immediate priorities (next 48 hours):\n\n1. Instruct Kirkland & Ellis on CMS gap — OVERDUE. Legal instruction must precede management presentation.\n\n2. Finalise written CEO retention terms with Hargreaves — Advent have made direct approach. This is the single highest-risk item.\n\n3. Update financial model — S. Patel to incorporate $5.2M CMS exposure and remediation costs before bid submission.\n\n4. Confirm final bid checklist with Houlihan Lokey (due 25 Jun).\n\nDeadline: 28 June 2026, 17:00 BST.',
    'Who in our network should we engage?': 'Three people recommended by Navatar AI for this deal:\n\n1. Robert Ashford (In Navatar) — Healthcare sector advisor who worked on Project Lighthouse. Has NHS trust procurement contacts. Recommend immediate call re: referral network dynamics.\n\n2. Dr. Rachel Morrison (Not in Navatar) — CQC compliance specialist. Her published work is directly relevant to the Webb report findings. Recommend warm intro via Ashford for rapid second opinion.\n\n3. James Wren (Not in Navatar) — CFO of Apex Care. Met at management presentation. Building a separate relationship with Wren could provide deal intelligence and help with retention discussions.',
    'What are my open items?': 'You have 2 open high-priority tasks assigned to you (T. Bennett):\n\n1. Instruct Kirkland & Ellis on CMS Gap — Due 18 Jun (OVERDUE)\n   The Webb report makes this urgent. Kirkland instruction draft is ready in documents.\n\n2. Finalise CEO retention terms with Hargreaves — Due 19 Jun (TOMORROW)\n   Advent have approached Hargreaves directly. Written terms before bid submission are critical.\n\n1 medium-priority task: Confirm bid checklist with Houlihan Lokey (due 25 Jun).\n\n1 completed: Review Webb regulatory DD report.'
};