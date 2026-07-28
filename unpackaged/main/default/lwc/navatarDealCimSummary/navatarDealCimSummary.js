import { LightningElement, api } from 'lwc';

/**
 * "Current Summary" AI card at the top of Overview. Read-only per the CIM Stage v2 spec
 * (the header Edit affordance was removed) — this component only renders the summary text.
 */
export default class NavatarDealCimSummary extends LightningElement {
    @api summaryHtml =
        'Project Everest was revealed today as <a href="javascript:void(0);">Apex Care Partners</a> — ' +
        'a UK outpatient rehabilitation business operating 22 NHS-contracted clinic sites — sourced via ' +
        '<a href="javascript:void(0);">Michael Hartley</a> at <a href="javascript:void(0);">Houlihan Lokey</a>. ' +
        'The CIM confirms LTM revenue of $48M and EBITDA of $10.0M (20.8% margin). Ironwood has been invited ' +
        'into the final round alongside two other undisclosed parties. Management, including CEO ' +
        '<a href="javascript:void(0);">Mark Hargreaves</a>, has indicated openness to staying on post-transaction. ' +
        'Navatar auto-created the Apex Care Partners company record and contacts for the named management team ' +
        'directly from the CIM document. The AI-generated CIM analysis flags one early item to validate in ' +
        'diligence — a forthcoming change to NHS CMS outpatient supervision requirements. The investment ' +
        'criteria check run at Teaser stage matched 4 of 5 — the one open item, risk profile, was deferred ' +
        "pending the CIM; the CIM's regulatory and management-concentration signals mean that item stays open " +
        'rather than closing out automatically. A formal process letter is expected shortly with the bid timeline.';
}