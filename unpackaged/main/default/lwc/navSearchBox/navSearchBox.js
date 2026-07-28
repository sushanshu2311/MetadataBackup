import { LightningElement, api } from 'lwc';

/**
 * The section search box.
 *
 * Hand-rolled on `slds-input` rather than `lightning-input`: the base component
 * renders at 13px in a 32px control and publishes no font-size hook, which is
 * too heavy against the 11px type on these screens.
 *
 * Emits `search` with the current value on every keystroke (live search).
 */
export default class NavSearchBox extends LightningElement {
    @api placeholder = 'Search...';
    @api value = '';

    handleInput(event) {
        this.dispatchEvent(
            new CustomEvent('search', { detail: { value: event.target.value } })
        );
    }
}