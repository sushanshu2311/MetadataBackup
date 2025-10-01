import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleOnLoadInfo from '@salesforce/apex/NavatarRecordAllInteractionsCtrl.handleOnLoadInfo';

export default class NavatarRecordAllInteractionsLwc extends NavigationMixin(LightningElement) {
    @api recordId = '';
    @api recordName = '';
    @api ltpId;

    header = '';
    actIdList = [];
    namespacePrefix = '';
    
    enableSpinner = false;
    redirectToInteractionPg = false;

    /* Fetches the parameters from the URL */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //Added JSON.stringify(currentPageReference.state) !== '{}' by LK on 2024-04-04
        if(currentPageReference && currentPageReference.state != undefined && JSON.stringify(currentPageReference.state) !== '{}'){
            let stateParams = currentPageReference.state;
            this.recordId = stateParams.c__recordId;
            this.recordName = stateParams.c__recordName;
            this.ltpId = stateParams.c__ltpId;
        }
    }
    
    connectedCallback(){
        this.handleOnLoadInfo();
    }

    /* Processes the info to be displayed on page load */
    handleOnLoadInfo(){
        this.enableSpinner = true;
        this.header = `All Interactions With ${this.recordName}`;
        handleOnLoadInfo({recordId : this.recordId})
        .then((result) => {
            this.namespacePrefix = result.namespacePrefix;
            if(result.actIdList){
                this.actIdList = result.actIdList;
            }
            this.redirectToInteractionPg = true;
            this.enableSpinner = false;
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
        });
    }

    /* Displays toast message */
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