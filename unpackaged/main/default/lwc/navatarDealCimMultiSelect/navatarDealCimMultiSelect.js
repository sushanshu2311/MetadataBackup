import { LightningElement, api, track } from 'lwc';
import { reconcileAllExclusive } from 'c/navatarDealCimUtils';

/**
 * Reusable pill-style multi-select filter dropdown.
 * Reused by Activity (Type), Team (Group) and Tasks (Owner) filter bars —
 * ports the HTML prototype's `.msdd` component into one LWC.
 *
 * Public API:
 *   options         [{ value, label }]  — first option is conventionally { value:'__all__', label:'All' }
 *   label           string              — prefix shown in the trigger, e.g. "Type"
 *   selectedValues  string[]            — controlled selection, defaults to ['__all__']
 *
 * Fires:
 *   filterchange  { selectedValues: string[] }  — values, excluding '__all__'
 */
export default class NavatarDealCimMultiSelect extends LightningElement {
    @api label = '';
    @api options = [];

    @track _selected = ['__all__'];
    isOpen = false;

    @api
    get selectedValues() {
        return this._selected;
    }
    set selectedValues(value) {
        this._selected = value && value.length ? value : ['__all__'];
    }

    get triggerLabel() {
        const prefix = this.label ? `${this.label}: ` : '';
        const chosen = this._selected.filter((v) => v !== '__all__');
        if (chosen.length === 0) return `${prefix}All`;
        if (chosen.length === 1) {
            const opt = this.options.find((o) => o.value === chosen[0]);
            return `${prefix}${opt ? opt.label : chosen[0]}`;
        }
        return `${prefix}${chosen.length} selected`;
    }

    get renderedOptions() {
        return this.options.map((o) => ({
            ...o,
            checked: this._selected.includes(o.value)
        }));
    }

    get panelClass() {
        return this.isOpen ? 'msdd-panel open' : 'msdd-panel';
    }

    get wrapClass() {
        return this.isOpen ? 'msdd open' : 'msdd';
    }

    toggleOpen(event) {
        event.stopPropagation();
        this.isOpen = !this.isOpen;
    }

    // Keeps clicks inside the open panel from bubbling to the document listener that closes it.
    stopClick(event) {
        event.stopPropagation();
    }

    closePanel() {
        this.isOpen = false;
    }

    handleOptionChange(event) {
        event.stopPropagation();
        const value = event.target.value;
        this._selected = reconcileAllExclusive(this._selected, value);
        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: { selectedValues: this._selected.filter((v) => v !== '__all__') }
            })
        );
    }

    connectedCallback() {
        this._docHandler = () => this.closePanel();
        document.addEventListener('click', this._docHandler);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._docHandler);
    }
}