import { LightningElement, track } from 'lwc';

const SUMMARY = 'Apex Care Partners (Project Everest) is a UK-based outpatient and community care provider operating 22 sites across South West England. Revenue of £38.2M in FY2025, with EBITDA of £7.9M (20.7% margin) — the CIM states £8.1M; Ironwood\'s view post-normalisation is £7.9M. The NHS/self-pay split is 62%/38%. The business has grown consistently at 13–15% per annum. The CIM has been processed and a 4-page analysis filed. Two management contacts have been created: Mark Hargreaves (CEO) and Sarah Chen (CFO). News monitoring is now active. Three potential bolt-on targets have been identified in the South West England market. A management meeting has been scheduled for 28 Feb 2026 in Birmingham.';

export default class NavatarDealOverview extends LightningElement {
    @track summaryText = SUMMARY;
    @track isEditing   = false;
    @track editText    = SUMMARY;

    handleEdit() {
        this.editText  = this.summaryText;
        this.isEditing = true;
    }

    handleChange(event) {
        this.editText = event.detail.value;
    }

    handleSave() {
        this.summaryText = this.editText;
        this.isEditing   = false;
    }

    handleCancel() {
        this.isEditing = false;
    }
}