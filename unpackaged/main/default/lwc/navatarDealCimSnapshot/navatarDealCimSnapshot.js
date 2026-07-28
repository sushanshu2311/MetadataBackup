import { LightningElement, api } from 'lwc';
import { emDash, daysBetween, formatDays } from 'c/navatarDealCimUtils';

// Fixed "as of" date used to compute Days in Stage — mirrors the HTML prototype's DEAL_AS_OF
// constant so the demo shows a stable number rather than drifting with the real clock.
const DEAL_AS_OF = '2026-06-06';

/**
 * Snapshot panel — read-only per the CIM Stage v2 spec (Competing Bidders and Investment
 * Criteria Match were removed here; Days in Stage is derived, not stored). Blank values render
 * as an em dash to match the prototype's convention.
 */
export default class NavatarDealCimSnapshot extends LightningElement {
    @api stage = 'CIM Received';
    @api stageEntryDate = '2026-06-05';
    @api evRange = '$105–120M';
    @api entryMultiple = '10.5–12× EBITDA';
    @api finalBidDeadline = '';

    get fields() {
        const days = daysBetween(this.stageEntryDate, DEAL_AS_OF);
        return [
            { label: 'Stage', value: emDash(this.stage) },
            { label: 'Days in Stage', value: formatDays(days) },
            { label: 'EV Range (Est.)', value: emDash(this.evRange) },
            { label: 'Entry Multiple', value: emDash(this.entryMultiple) },
            { label: 'Final Bid Deadline', value: emDash(this.finalBidDeadline) || 'Not yet set' }
        ].map((f, i) => ({ ...f, key: 'kv' + i }));
    }
}