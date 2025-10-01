/****************************************************************************************************
** Module Name : Acuity 2.0 - Quick Deal Creation
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14       Virendra Kumar
****************************************************************************************************/
import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getCloneConfirmation from'@salesforce/apex/NavatarCreateMenuDealCtrl.getCloneConfirmation';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_ID from '@salesforce/schema/Pipeline__c.Company__c';
import IMPORT_STATUS from '@salesforce/schema/Pipeline__c.Import_Status__c'

export default class navatarImportFromFirmLwc extends LightningElement {
    columnsdeal = [
        { label: 'Select All',type:'text', fieldName: 'Selectall', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' }},
    ];

    showCloneOption = false;
    showImportDetails = false; 
    isCheckedClip = false;
    isCheckedInteraction = false;

    importStatus = null;
    cloneConfirmationDetails;

    dealId;
    accId;
    _recordId;
    
    //get Deal Id
    @api set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    //get Deal record Details
    @wire (getRecord, {recordId:'$recordId', fields: [ACCOUNT_ID, IMPORT_STATUS]})
    loadFields({error, data}){
        if(error){  
            this.showToast('Error!', JSON.stringify(error), 'error', 'sticky');
        }else if(data){
            //Store account Id from Deal
            this.accId = getFieldValue(data, ACCOUNT_ID);
            //store Import Status details from Deal
            this.importStatus = getFieldValue(data, IMPORT_STATUS);
            if(this.accId) {
                this.fetchCloneConfirmation();
            }
        }
        
    }
    
    //Method used to get clone confirmation for the related child
    fetchCloneConfirmation() {
        getCloneConfirmation({accId : this.accId})
            .then(result =>{
                this.cloneConfirmationDetails = JSON.parse(result);
                //To handle clone confirmation when status is there.
                if(this.importStatus !== null) {
                    this.isCheckedClip = this.cloneConfirmationDetails.isClipExist && !this.importStatus.includes('All Clips') ? true: false;
                    this.isCheckedInteraction = this.cloneConfirmationDetails.isInteractionExist && !this.importStatus.includes('All Interaction') ? true: false;
                }else {
                    //handle if status is not populated and related child records are present with Firm.
                    this.isCheckedClip = this.cloneConfirmationDetails.isClipExist;
                    this.isCheckedInteraction = this.cloneConfirmationDetails.isInteractionExist;
                }
                
                if(this.isCheckedClip ||  this.isCheckedInteraction) {                         
                    this.showImportDetails = true;              
                    this.showCloneOption = true;

                }else {
                    this.showToast('Error', 'The records either doesn\'t exist or has already been cloned.', 'error', 'sticky');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(error =>{
                console.error(JSON.stringify(error)); 
        })
    }

    //Load the page to refresh the data on the screen.
    handleCloneScreenSave() {
         this.dispatchEvent(new CloseActionScreenEvent());
        // setTimeout(() => {
        //     window.location.reload();
        // }, 3000);        
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //Handle Generic Toast message
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

}