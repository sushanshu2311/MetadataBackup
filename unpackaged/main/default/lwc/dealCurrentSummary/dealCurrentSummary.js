import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AI_DEAL_SUMMARY from '@salesforce/schema/navpeII__Pipeline__c.AI_Deal_Summary__c';

const FIELDS = [AI_DEAL_SUMMARY];

const AI_STUBS = [
    '<p><strong>Project Everest — Apex Care Partners</strong> is a specialist residential care operator generating £38M revenue with £8.2M EBITDA (21.6% margin) and 18% CAGR over three years. The business is positioned in the Due Diligence phase with a target entry multiple of 11–13× EBITDA, following LOI execution on 14 March 2026.</p><p>Key person dependency on CEO Mark Hargreaves (controls 14 of 22 NHS referral relationships) represents the primary retention risk and is under active negotiation. CMS supervision affects three sites (Guildford, Brighton, Reading) with £4.1M revenue exposure — Dr. Marcus Webb\'s independent regulatory report (received today) identifies a gap on page 18 that requires legal review by Kirkland &amp; Ellis.</p><p>Competitor Advent International is actively engaged; banker Michael Hartley at Houlihan Lokey is managing the process. Recommended next step: resolve CMS scenario modelling and confirm Hargreaves retention terms before IC submission.</p>',
    '<p><strong>AI Generated — Updated Analysis</strong></p><p>Apex Care Partners presents a compelling residential care acquisition at £38M revenue, £8.2M EBITDA, 18% CAGR. Entry at 11–13× EBITDA remains attractive versus sector comps. Due Diligence is progressing well with two open risk items requiring resolution before IC.</p><p><strong>Priority risks:</strong> (1) CMS regulatory supervision at 3 sites (£4.1M exposure) — Webb report flags compliance gap at p.18, Kirkland &amp; Ellis legal review pending. (2) CEO retention: Hargreaves controls 14/22 NHS referral relationships; retention package not yet agreed.</p><p>Advent International remains a competing bidder. Process managed by Houlihan Lokey (Hartley). Recommend accelerating CMS scenario modelling and locking Hargreaves retention terms before IC — failure on either point materially impacts valuation floor.</p>',
];

export default class DealCurrentSummary extends LightningElement {
    @api recordId;
    @track isEditing    = false;
    @track isSaving     = false;
    @track isExpanded   = true;
    @track summaryMode  = 'ai';
    @track aiStubIndex  = 0;
    @track draftSummary = '';

    formats = ['bold', 'italic', 'underline', 'strike', 'list', 'indent', 'align', 'link'];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    get summary()    { return AI_STUBS[this.aiStubIndex]; }
    get hasSummary() { return true; }

    get pillAiVariant()     { return this.summaryMode === 'ai'     ? 'brand' : 'neutral'; }
    get pillManualVariant() { return this.summaryMode === 'manual' ? 'brand' : 'neutral'; }

    get expandLabel() { return this.isExpanded ? '▲ Show less' : '▼ Show more'; }

    handlePillClick(event) {
        const mode = event.currentTarget.dataset.mode;
        if (mode === 'manual') {
            this.summaryMode  = 'manual';
            this.draftSummary = this.summary;
            this.isEditing    = true;
        } else {
            this.summaryMode  = 'ai';
            this.aiStubIndex  = (this.aiStubIndex + 1) % AI_STUBS.length;
            this.dispatchEvent(new ShowToastEvent({ title: 'AI summary updated', variant: 'info', mode: 'dismissible' }));
        }
    }

    toggleExpand() { this.isExpanded = !this.isExpanded; }

    handleEdit() {
        this.draftSummary = this.summary;
        this.isEditing    = true;
    }

    handleChange(event) { this.draftSummary = event.target.value; }

    handleCancel() {
        this.isEditing    = false;
        this.draftSummary = '';
    }

    async handleSave() {
        this.isSaving = true;
        try {
            await updateRecord({ fields: { Id: this.recordId, AI_Deal_Summary__c: this.draftSummary } });
            this.isEditing = false;
            this.dispatchEvent(new ShowToastEvent({ title: 'Saved', message: 'Summary updated successfully.', variant: 'success' }));
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error saving summary',
                message: error?.body?.message ?? 'An unexpected error occurred.',
                variant: 'error',
            }));
        } finally {
            this.isSaving = false;
        }
    }
}