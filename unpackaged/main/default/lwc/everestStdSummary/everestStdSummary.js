import { LightningElement, track } from 'lwc';

const SUMMARY_HTML =
    `Project Everest was sourced by <a href="#">Michael Hartley</a> at <a href="#">Houlihan Lokey</a> in January 2026. ` +
    `<a href="#">Apex Care Partners</a> is a UK outpatient rehabilitation business operating 22 clinic sites currently in Due Diligence at 11–13× EBITDA with three competing bidders remaining. ` +
    `<a href="#">Dr. Webb</a>'s regulatory report received today flagged a CMS supervision gap across three clinic sites (Guildford, Brighton, Reading) — $5.2M revenue exposure not yet in any deal notes or the financial model; specialist legal instruction is overdue before the 18 June management meeting. ` +
    `CEO <a href="#">Mark Hargreaves</a> controls 14 of 22 NHS referral relationships and has given only verbal retention commitment — <a href="#">Advent International</a> have approached him directly, making written terms the most time-sensitive item on the deal. ` +
    `<a href="#">Kirkland &amp; Ellis</a> legal DD report expected 16 June with no update received. Final bid deadline: 28 June 2026.`;

export default class EverestStdSummary extends LightningElement {
    @track summaryHtml = SUMMARY_HTML;
    @track isEditing = false;
    @track editValue = SUMMARY_HTML;

    handleEdit() {
        this.editValue = this.summaryHtml;
        this.isEditing = true;
    }

    handleChange(event) {
        this.editValue = event.target.value;
    }

    handleSave() {
        this.summaryHtml = this.editValue;
        this.isEditing = false;
    }

    handleCancel() {
        this.editValue = this.summaryHtml;
        this.isEditing = false;
    }
}