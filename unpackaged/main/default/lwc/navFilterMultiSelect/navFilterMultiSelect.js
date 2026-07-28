import { LightningElement, api } from 'lwc';

/**
 * The one filter pattern used product-wide (FR-SHD-07): a multi-select
 * dropdown of checkboxes with an explicit, exclusive "All".
 *
 * Selecting All clears the rest; selecting anything else clears All; clearing
 * everything falls back to All. Emits `filterchange` with the selected values,
 * where an empty array means All.
 *
 * Built on SLDS dropdown markup rather than `lightning-button-menu`, which
 * renders its label in brand blue at 13px with no hook to change either.
 */
export default class NavFilterMultiSelect extends LightningElement {
    /** Prefix shown on the button, e.g. "Type" renders "Type: All". */
    @api label;
    /** [{ label, value }] — do not include an All entry, it is added here. */
    @api options = [];

    selected = [];
    open = false;
    outsideClickHandler;

    connectedCallback() {
        this.outsideClickHandler = () => this.close();
        document.addEventListener('click', this.outsideClickHandler);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.outsideClickHandler);
    }

    get triggerClass() {
        const base = 'slds-dropdown-trigger slds-dropdown-trigger_click';
        return this.open ? `${base} slds-is-open` : base;
    }

    get menuLabel() {
        const prefix = this.label ? `${this.label}: ` : '';
        if (!this.selected.length) {
            return `${prefix}All`;
        }
        if (this.selected.length === 1) {
            const only = this.options.find((o) => o.value === this.selected[0]);
            return `${prefix}${only ? only.label : this.selected[0]}`;
        }
        return `${prefix}${this.selected.length} selected`;
    }

    get menuItems() {
        const items = [{ value: '__all__', label: 'All', checked: this.selected.length === 0 }];
        this.options.forEach((option) => {
            items.push({
                value: option.value,
                label: option.label,
                checked: this.selected.includes(option.value)
            });
        });
        return items;
    }

    /** Clicks inside the dropdown must not reach the close-on-outside listener. */
    handleContain(event) {
        event.stopPropagation();
    }

    handleToggle(event) {
        event.stopPropagation();
        this.open = !this.open;
    }

    close() {
        this.open = false;
    }

    handleSelect(event) {
        const value = event.target.dataset.value;

        if (value === '__all__') {
            this.selected = [];
        } else if (this.selected.includes(value)) {
            this.selected = this.selected.filter((v) => v !== value);
        } else {
            this.selected = [...this.selected, value];
        }

        this.dispatchEvent(
            new CustomEvent('filterchange', { detail: { values: [...this.selected] } })
        );
    }
}