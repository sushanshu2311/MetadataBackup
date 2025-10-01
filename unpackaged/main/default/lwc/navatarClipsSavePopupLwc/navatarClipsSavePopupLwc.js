/****************************************************************************************************

** Module Name : Clips

** Description : Used save clip and show suggestion 

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

**************************************************************************************************** */
import { api, LightningElement, track, wire } from 'lwc';
import saveClip from '@salesforce/apex/NavatarClipsCtrl.saveClip';
import getSuggestion from '@salesforce/apex/NavatarClipsCtrl.getSuggestion';
import saveSuggestion from '@salesforce/apex/NavatarClipsCtrl.saveSuggestion';
import getClipNameAndSummary from '@salesforce/apex/NavatarClipsCtrl.getClipNameAndSummary';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';

import ClipObj from '@salesforce/schema/Clip__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import { publish, MessageContext} from 'lightning/messageService';
import clipIdmsg from "@salesforce/messageChannel/navatarClipAuraLwcChannel__c";
import { NavigationMixin } from 'lightning/navigation';

import checkSuggestedTag from '@salesforce/apex/NavatarNotesModalCtrl.checkSuggestedTag';

const columns = [
    { label: 'Reference Found', fieldName: 'Name' },
    { label: 'Type', fieldName: 'objectName', cellAttributes: { iconName: { fieldName: 'iconName' } }},
]; 

export default class NavatarClipsSavePopupLwc extends LightningElement {
    @track isDiscoverOpen = false;
    @api recordId;
    @api notes;
    @api taggedRecord;
    @api objInfo;
    @api clipName;
    @api clipSummary;
    clipId;
    @api isLoading;
    @track recentRecords = [];
    @track data = [];
    @track currentUserList = [];
    userId = Id;

    error;
    @track isModalOpen = true;
    @track isDiscoverOpen = false;
    itemCount = 0;
    columns = columns;

    summaryLabel = 'Summary';
    nameLabel = 'Name';

    @track isError = false;
    errorMessage = '';
 
    @wire(MessageContext) messageContext;

    // get clip name and clip summery field labels
    @wire(getObjectInfo, { objectApiName: ClipObj })
    oppInfo({ data, error }) {
        if (data){
            this.summaryLabel = data.fields.navpeII_dev18__Summary__c.label;
            this.nameLabel = data.fields.Name.label;
        } 
        else if (error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
        }
    }

    // get current user data
    @wire(getRecord, { recordId: Id, fields: [UserNameFld]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;  
        } else if (error) {
           
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
        }
        this.currentUserList = [];
        this.currentUserList.push({"objectName":"User","Name":this.currentUserName,"Id": this.userId,"iconName":"standard:user"});
       
    }

    // publish event on save of clip with clipid
    publishSaveMeg(){
        localStorage.setItem("savedClipId", '');
        let savemessage = { savemessage : this.clipId };
        publish(this.messageContext, clipIdmsg, savemessage);
        
    }

    publishOnError(){
        localStorage.setItem("savedClipId", '');
        let savemessage = { savemessage : 'close' };
        publish(this.messageContext, clipIdmsg, savemessage);
    }

    // get data from localStorage on load of popup
    connectedCallback(){
        
        this.clipId = localStorage.getItem("savedClipId");
        if(this.clipId != null && this.clipId != '' && this.clipId != 'null' &&  this.clipId != 'undefined' ){
            this.handleGetClipNameAndSummary();
        }
        this.notes = localStorage.getItem('clipData');
        this.recentRecords = localStorage.getItem('clipRecords');
        this.taggedRecord = localStorage.getItem('taggedRec');
    }

    // to get clip data on click of edit and set them into localStorage
    handleGetClipNameAndSummary(){
        this.isLoading = true;
        
        getClipNameAndSummary({
            clipId : this.clipId,
        }).then(data => {
            if(data != null){
                this.clipName = data.Name;
                this.clipSummary = data.navpeII_dev18__Summary__c;
            }
            this.isLoading = false;
        })
        .catch(error => {
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
            this.isLoading = false;
        });
    }

    // save clip name in variable
    handleChangeName(event){
        this.clipName =  event.target.value;
    }
    // save clip summery in variable
    handleChangeSummary(event){
        this.clipSummary =  event.target.value;
    }

    // save clip
    handleSaveClip(){
        // check name field data
        
        this.template.querySelectorAll("lightning-input").forEach(item => {
            let fieldValue=item.value;
             
            if(!fieldValue){
                this.isError = true;
                this.errorMessage = "These required fields must be completed: "+ this.nameLabel +'.';
                item.setCustomValidity(fieldErrorMsg); //+' '+fieldLabel
                return;
            }
            else{
                item.setCustomValidity("");
                this.isError = false;
            }
            item.reportValidity();
        });
        // check name field data
        
        this.isLoading = true;
        saveClip({
            taggedRecord : this.taggedRecord,
            note : this.notes,
            name : this.clipName,
            summary : this.clipSummary,
            clipId : this.clipId
        }).then(data => {
            if(data.includes('Error')){
                const event = new ShowToastEvent({title: 'Error',message: data,variant: 'error',mode: 'sticky'});
                this.dispatchEvent(event);
                this.isLoading = false;
                this.publishOnError();
                this.dispatchEvent(new CustomEvent('closemodal'));
            }else{
                if(this.clipId != null && this.clipId != '' && this.clipId != 'null' && this.clipId != 'undefined'){
                    const event = new ShowToastEvent({title: 'Success',message: 'Clip "'+this.clipName+'" was saved.',variant: 'success',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }else{
                    const event = new ShowToastEvent({title: 'Success',message: 'Clip "'+this.clipName+'" was created.',variant: 'success',mode: 'dismissable'});
                    this.dispatchEvent(event);
                   
                }
                this.clipId = data;

                //close save clip modal
                this.isModalOpen = false;
                this.isLoading = false;

                //clear clip info
                localStorage.setItem("taggedRec", JSON.stringify(this.currentUserList));
                localStorage.setItem("clipRecords", ''); 
                //get suggestion based on drag-drop, copy-paste and typing
                // this.handleGetSuggestion();
                this.checkSuggestedEnable();
            }
            
        })
        .catch(error => {
            this.isLoading = false;
            this.isModalOpen = false;
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
        });
    }

    //get suggestion based on drag-drop, copy-paste and typing
    handleGetSuggestion(){
        this.isLoading = true;
        getSuggestion({
            ObjectInfo : this.objInfo,
            recentRecords : this.recentRecords,
            taggedRecord : this.taggedRecord
        }).then(data => {
            this.isLoading = false;

            //if suggestion found show suggestion modal otherwise close modal
            if(data.length > 0){
                // this.checkSuggestedEnable(data);
                this.isDiscoverOpen = true;
                this.data = data;
            }else{
                this.clipName = '';
                this.clipSummary = '';
                this.publishSaveMeg();
                this.dispatchEvent(new CustomEvent('closemodal'));
                
            }
            
        })
        .catch(error => {
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
            this.isLoading = false;
            this.isDiscoverOpen = false;
        });  
    }

    // to save selected suggestion
    handleSaveSuggestion(){
        this.isLoading = true;
        this.getSelectedRec();
        saveSuggestion({
            clipId : this.clipId,
            selectedRecords : JSON.stringify(this.selectedRecords),
        }).then(data => {
            const event = new ShowToastEvent({title: 'Success',message: 'Clip "'+this.clipName+'" was saved.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(event);

            this.publishSaveMeg();
            this.isLoading = false;
            this.isDiscoverOpen = false;
            this.clipName = '';
            this.clipSummary = '';
            
            this.dispatchEvent(new CustomEvent('closemodal'));

            
        })
        .catch(error => {
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
            this.isLoading = false;
            this.isDiscoverOpen = false;
        });  
    }
    
    //shows selected record count on suggestion modal
    getSelectedRec() {
        this.selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.itemCount = this.selectedRecords.length;
    }
    
    //to open modal
    @api
    openModal() {
         // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        setTimeout(() => {
            let sectmodal = this.template.querySelector(".slds-modal");
            let bodyClose = sectmodal.closest('body');
            bodyClose.style.overflow = "hidden";
        }, 200);
    }

    // to close modal
    closeModal() {
        //this.publishCloseMeg();
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    closeModalSuggested(){
        this.publishSaveMeg();
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    closeQuickAccountContact(){
        this.isModalOpen = false; 
        let sectmodal = this.template.querySelector(".slds-modal");
        let bodyClose = sectmodal.closest('body');
        bodyClose.style.overflow = "auto";
    }

    //  to apply css
    renderedCallback() {
        const style = document.createElement('style');
         style.innerText = `
         .slds-textarea{
            min-height:100px;
       
         }
         @media (max-width: 70em) {
         .max_ht_css .slds-textarea{
            max-height:150px;
            overflow-y:auto;
         }}`;
        try {
            this.template.querySelector('.mainContainer').appendChild(style);
        } catch (err) {
        }
    }


    checkSuggestedEnable(){
        checkSuggestedTag()
            .then(data => {
                if(data == 'true'){
                    // this.isDiscoverOpen = true;
                    // this.data = res;
                    this.handleGetSuggestion();
                    
                }else{
                    this.clipName = '';
                    this.clipSummary = '';
                    this.publishSaveMeg();
                    this.dispatchEvent(new CustomEvent('closemodal'));
                }
            })
            .catch(error => {
                // this.displayError(error);
            });
    }
 
}