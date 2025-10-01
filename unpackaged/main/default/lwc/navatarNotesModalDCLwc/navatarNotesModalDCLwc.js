/****************************************************************************************************

** Module Name : Add contact to Deal Team Popup

** Description : 

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity 3.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2024-02-02          Sudhanshu       Split code from NavatarNotesModal

****************************************************************************************************/

import { LightningElement, api, track } from 'lwc';
import createDealTeamRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.createDealTeamRecords';
import getContactInfo from '@salesforce/apex/NavatarNotesTaggingCtrl.getRelatedContactsDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/NavatarPicklistCtrl.getPickListValues';

export default class NavatarNotesModalDCLwc extends LightningElement {
    @track globalCheck = false;
    @track contactTaggedRecords = [];
    @track errorMessage = [];
    @api newDealsTaggedList = [];
    @track isRedirectToParentScreen = true;
    @api selectedSuggestedData = [];
    @api allTaggedRecords = [];
    @api newTaggedRecordsList = [];
    @api atTaggedRecords = [];

    connectedCallback(){
        this.getAllDealTeamContacts();
        this.getOptionsDeal();
    }

    value = 'deal';
    //Fixed for Bug # 38195 started
    optionsDeal=[];
    getOptionsDeal() {
        getPickListValues({
            objApiName: 'navpeII_dev18__Deal_Team__c',
            fieldName: 'navpeII_dev18__Team_Member_Role__c',
            selectedValue : ''
        })
        .then(data => {
            this.optionsDeal= data;
        })
        .catch(error => {
            const errorToast = new ShowToastEvent({title: 'Error', message: error,variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
        });
        
    }//Fixed for Bug # 38195 ended

    hideRecordModal(){
        const ev = new CustomEvent("hiderecordmodal");
        this.dispatchEvent(ev);
    }

        /* JAGRITI : START */
    // handle the global checkbox to select or deselect of Deal team creation
    handleDealGlobalCheck(evt){  
        this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
        this.globalCheck = evt.target.checked;
        this.contactTaggedRecords.forEach(contactRec =>{
            contactRec.isSelected = evt.target.checked
        })
    }


     //{label: 'None' , value :''},
     objectTypeOptions = [{label : 'Account', value : 'Account'}, {label : 'Contact', value : 'Contact'}];

 
     // Method to navigate to parent component screen without reload
     navigateBackToParentScreen() {
         this.hideRecordModal();
     }
 
     //method handles the next flow after dela team modal closes
    //  cancelDealTeamCreate() {
    //      this.openFundTeamModal();
    //  }
     
     //method that takes in the deal records and pushes it into the list.
     addNewDeals(dealRecord) {
         
         let existingLength = (this.newDealsTaggedList.length)?this.newDealsTaggedList.length : 0;
         this.newDealsTaggedList.push({
             index : existingLength,
             recId : dealRecord.Id==undefined?dealRecord.recId:dealRecord.Id,//Fixed for Bug #00035103
             recName : dealRecord.Name
         })
     }
 
 // Method that retrieves all the tagged contact information for name and account
     getAllDealTeamContacts() {
         let contactTaggedRecordsLocal = [];
         this.taggedContactsList = [];
         this.contactTaggedRecords = [];
         this.allTaggedRecords.forEach(taggedRec =>{
             if(taggedRec.objectName == 'Contact') {
                 contactTaggedRecordsLocal.push(taggedRec.Id);
             }
         })
         this.selectedSuggestedData.forEach(ssRec =>{
             if(ssRec.objectName == 'Contact') {
                 contactTaggedRecordsLocal.push(ssRec.recId);
             }
         })
         this.atTaggedRecords.forEach(atRec =>{
             if(atRec.objectName == 'Contact') {
                 contactTaggedRecordsLocal.push(atRec.Id);
             }
         })
         this.newTaggedRecordsList.forEach(atRec =>{
             if(atRec.objectName == 'Contact') {
                 contactTaggedRecordsLocal.push(atRec.Id);
             }
         })
         if(contactTaggedRecordsLocal.length) {
            console.log('contactTaggedRecordsLocal' +JSON.stringify(contactTaggedRecordsLocal));
             getContactInfo({
                 contactIds : contactTaggedRecordsLocal
             })
             .then(res=>{
                 if(res.length) {
                     this.contactTaggedRecords = res;
                 }
             })
             .catch(err=>{
             })
         }
     }
     /* JAGRITI : START */
     // handle the global checkbox to select or deselect of Deal team creation
     handleDealGlobalCheck(evt){  
         this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
         this.globalCheck = evt.target.checked;
         this.contactTaggedRecords.forEach(contactRec =>{
             contactRec.isSelected = evt.target.checked
         })
     }
 
     // handle the Deal Team single checkbox select
     // ui fix for checkbox 13jan
     handleDealContactCheckBox(evt) {
         let selectedIndex = evt.currentTarget.dataset.id;
         this.contactTaggedRecords[selectedIndex].isSelected = evt.target.checked
         this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
         let countSelected=0;
         let countUnSelected=0;
         let selectedList = [];
 
         this.contactTaggedRecords.forEach(contactRec =>{
         if(!contactRec.isSelected){
             ++countUnSelected;
             //unselectedList.push(contactRec);
             //gcheckbox.checked=false;
         }
         else{
             ++countSelected;
             //gcheckbox.checked=true;
         }
     });
       console.log('countSelected'+countSelected);
       console.log('count unselected'+countUnSelected);
       console.log('contactTaggedRecords.length'+this.contactTaggedRecords.length);
       // console.log('unselectedList'+JSON.stringify(unselectedList));
       if(this.contactTaggedRecords.length === countSelected){
              this.globalCheck = true;
              }
             else{
             if(countSelected === 0){           
                 console.log('lenghth else iff 2228 == '+this.contactTaggedRecords.length);
                 this.globalCheck = false;
                 this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
             }
             else{
             console.log('lenghth == else else 2234 '+this.contactTaggedRecords.length);
             this.globalCheck = false;
             this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.add('dash-filter');
         }}
     }
     /* JAGRITI : END */
     // handle Deatl team contact Role change
     handleDealRoleChange(evt) {
         let currentId = evt.currentTarget.dataset.id;
         let selectedOption = evt.detail.value;
         this.contactTaggedRecords[currentId].role = selectedOption;
     }
 
     // handle deal team creation
    handleDealTeamCreate() {
         let selectedRecords = [];
         let selectedDealsId = [];
         this.contactTaggedRecords.forEach(taggedRec=>{
             if(taggedRec.isSelected) {
                 selectedRecords.push(taggedRec)
             }
         })
         if(!selectedRecords.length) {
            // Bug 00048102 fixed by Sudhanshu
             const event = new ShowToastEvent({title: 'Error',message: 'Select atleast a record.',variant: 'error',mode: 'dismissable'});
             this.dispatchEvent(event);
             return;
         }
         this.newDealsTaggedList.forEach(deal=>{
             selectedDealsId.push(deal.recId)
         })
         if(selectedRecords.length) {
             createDealTeamRecords({
                 dealJSONString : JSON.stringify(selectedRecords),
                 dealRecordsId : selectedDealsId
             })
             .then(res=>{
                // Bug 00046681 fixed by Sudhanshu on 24-07-2024
                 const successToast = new ShowToastEvent({title: 'Success', message: 'Contact was successfully added to your Deal.',variant: 'success',mode: 'dismissable'});
                 this.dispatchEvent(successToast);
                //  this.openFundTeamModal();
                const ev = new CustomEvent("openfundteammodal");
                this.dispatchEvent(ev);
             })
             .catch(err=>{
                 const errorToast = new ShowToastEvent({title: 'Error', message: 'Error in creating Deal Team',variant: 'error',mode: 'dismissable'});
                 this.dispatchEvent(errorToast);
                //  this.openFundTeamModal();
                const ev = new CustomEvent("openfundteammodal");
                this.dispatchEvent(ev);
             })
        }
    }

    cancelDealTeamCreate(){
        const ev = new CustomEvent("canceldealteamcreate");
        this.dispatchEvent(ev);
    }

    // 00045106 fixed by raju 09-05-2024
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.dash-filter:before{               
              content: '';
              display: block;
              width: var(--lwc-squareIconXSmallContent,0.5rem);
              height: 2px;
              border: 0;
              transform: translate3d(-50%, -50%, 0);
              background: var(--slds-c-checkbox-mark-color-foreground, var(--sds-c-checkbox-mark-color-foreground, var(--lwc-brandAccessible,rgb(1, 118, 211))));
              position: absolute;
              top: 58%;
              left: 8px;
              z-index: 1 !important;                          
          }`;
          this.template.querySelector('.clsMainContainer')?.appendChild(style);	
    }

}