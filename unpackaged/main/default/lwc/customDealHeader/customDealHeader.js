import { LightningElement } from 'lwc';

export default class CustomDealHeader extends LightningElement {
    handleButtonClick(evt) {
        const button = evt.currentTarget.dataset.button;
        this.dispatchEvent(new CustomEvent('dispatched', {
            detail: { button },
            bubbles: true,
            composed: true
        }));
    }
}