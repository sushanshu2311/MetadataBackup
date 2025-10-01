import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarInlinePicklistComboboxLwc extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api fieldApiName;
    @api editable
    @track showPicklist = false;
    @track showEditButton = true;
 
   connectedCallback() {
        console.log(this.label);
        console.log(this.value);
        console.log(this.options);
        console.log(this.placeholder);
        console.log(this.fieldApiName);
        console.log(this.editable);
        //Commented below code by LK on 2023-03-20 to revert the Sharing Model
        //Reverted below code by LK on 2024-05-06 to fix 00045321 ; 00045719
        if(this.editable == true) {
             this.showEditButton = true;
        } else {
            this.showEditButton = false;
        }
   }

    closePicklist() {
        this.showPicklist = false;
    }
 
    handleChange(event) {
        //Added else condition and moved existing code inside if condition by LK on 2023-03-21 to revert the Sharing Model
        if(this.editable){
            //show the selected value on UI
            this.value = event.detail.value;
    
            //fire event to send context and selected value to the data table
            this.dispatchEvent(new CustomEvent('picklistchanged', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    data: { context: this.context, value: this.value, fieldApiName: this.fieldApiName }
                }
            }));
            this.closePicklist();//Added by LK on 2024-05-27 to fix 00045957
        } else {
            this.closePicklist();
            this.showToast(this, 'Error!', 'You do not have permission to edit this record!', 'error');
        }
    }
 
    handleClick(event) {
        this.showPicklist = true;
        
    }
    renderedCallback(){
    const style = document.createElement('style');
    style.innerText = `.picklistSection_css .slds-combobox_container .slds-dropdown-trigger_click .slds-dropdown, 
    .picklistSection_css .slds-dropdown-trigger_click:hover .slds-dropdown, 
    .picklistSection_css .slds-dropdown-trigger--click .slds-dropdown, 
    .picklistSection_css .slds-dropdown-trigger--click:hover .slds-dropdown{
        position: fixed !important;
        left: auto;
        right: auto;
        top: auto;
        width: 294px;
        max-height: 174px; 
        z-index: 9;
    }
    .slds-docked-form-footer{
        z-index: 8 !important;
    }
    section.slds-popover.slds-popover_edit{
        z-index: 9 !important;
    }
    /*00044505, 00045953 fixed by raju on dated 27-05-2024*/
    .shadowremovedatatableCls .slds-scrollable_y {
        max-height: 100%;
        height: 300px !important;
        overflow: hidden;
        overflow-y: auto;
    }
    @media (max-width: 768px) {
        /*00045766 fixed by raju on 30-05-2024*/
        .picklistSection .slds-truncate {            
            display: flex;
            align-items: center;
        }
    }
    @media (max-width: 1280px) {
        .picklistSection_css .slds-popover {
            width: 16rem !important;
        }
    }
    @media (min-width: 1281px) and (max-width: 1366px) {
        .picklistSection_css .slds-popover {
            width: 18rem !important;
        }
    }
    `;
    this.template.querySelector('.main-Container')?.appendChild(style);
}

    /* Added to display toast message by LK on 2023-03-20 to revert the Sharing Model */
    showToast(cmp, title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        cmp.dispatchEvent(event);
    }
}