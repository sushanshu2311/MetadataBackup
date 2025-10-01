/****************************************************************************************************

** Module Name : Add contact to Fundraising Popup

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
import getPickListValues from '@salesforce/apex/NavatarPicklistCtrl.getPickListValues';
import getContactInfo from '@salesforce/apex/NavatarNotesTaggingCtrl.getRelatedContactsDetails';
import createFundTeamRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.createFundTeamRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarNotesModalFDRCLwc extends LightningElement {
    @api newFundRaisingRecords = [];
    @track fundRaisingContacts = [];
    @api allTaggedRecords=[];
    @api selectedSuggestedData=[];
    @api atTaggedRecords=[];
    @api newTaggedRecordsList=[];
    @api isRedirectToParentScreen = false;
    @track isFundTeamError = false;     // bug id 00044239 fixed on 27-02-2024

    @track globalFundCheck = false;
    @track errorMessage = [];

    connectedCallback(){
        this.getOptionsFund();
        this.getAllFundTeamContacts();
    }

    //Fixed for Bug # 38195 started
    optionsFund=[];
    getOptionsFund() {
        getPickListValues({
            objApiName: 'navpeII_dev18__Fundraising_Contact__c',
            fieldName: 'navpeII_dev18__Role__c',
            selectedValue : ''
        })
        .then(data => {
            this.optionsFund= data;
        })
        .catch(error => {
            const errorToast = new ShowToastEvent({title: 'Error', message: error,variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
        });
        // return [
        //     { label: '--None--', value: '' }, //critical bug fix by Nikita S Bug # 34749
        //     { label: 'Advisor', value: 'Advisor' },
        //     { label: 'Business User', value: 'Business User' },
        //     { label: 'Decision Maker', value: 'Decision Maker' },
        //     { label: 'Evaluator', value: 'Evaluator' },
        //     { label: 'Executive Sponsor', value: 'Executive Sponsor' },
        //     { label: 'Gatekeeper', value: 'Gatekeeper' },
        //     { label: 'Influencer', value: 'Influencer' },
        //     { label: 'Other', value: 'Other' },
        // ];
    }//Fixed for Bug # 38195 ended
   
    // handle new funds added to tagged records

    addNewFundRaising(fundRecord) {
        let existingLength = (this.newFundRaisingRecords.length)?this.newFundRaisingRecords.length : 0;
        this.newFundRaisingRecords.push({
            index : existingLength,
            recId : fundRecord.Id==undefined?fundRecord.recId:fundRecord.Id,//Fixed for Bug #00038202
            recName : fundRecord.Name
        })
    }
    // method to handle the fund team contacts information
    getAllFundTeamContacts() {
        let contactTaggedRecordsLocal = [];
        this.fundRaisingContacts = [];
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
            getContactInfo({
                contactIds : contactTaggedRecordsLocal
            })
            .then(res=>{
                if(res.length) {
                    this.fundRaisingContacts = res;
                }
            })
            .catch(err=>{
            })
        }
    }
    // hhandle individual fund check box creating fund team
    /* JAGRITI : START */
    // ui fix 16jan
    handleFundContactCheckBox(evt) {
        let selectedIndex = evt.currentTarget.dataset.id;
        this.fundRaisingContacts[selectedIndex].isSelected = evt.target.checked;
        this.template.querySelector('[data-id="fundraisingId"]').classList.remove('dash-filter');
        //console.log('gcheckbox'+JSON.stringify(gcheckbox));

        let countSelected=0;

        let countUnSelected=0;
        let selectedList = [];

        this.fundRaisingContacts.forEach(contactRec =>{

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
         console.log('contactTaggedRecords.length'+this.fundRaisingContacts.length);
        // console.log('unselectedList'+JSON.stringify(unselectedList));
        if(this.fundRaisingContacts.length === countSelected){
            this.globalFundCheck = true;
        }
        else{
            
            if(countSelected === 0){           
                // console.log('lenghth else iff 2228 == '+this.contactTaggedRecords.length);
                this.globalFundCheck = false;
                this.template.querySelector('[data-id="fundraisingId"]').classList.remove('dash-filter');
            }
            else{
            // console.log('lenghth == else else 2234 '+this.contactTaggedRecords.length);
            this.globalFundCheck = false;
            this.template.querySelector('[data-id="fundraisingId"]').classList.add('dash-filter');
        }

        }
    }
    // handle the global checkbox to select or deselect of Fund team creation
// ui fix 16jan
    handleFundGlobalCheck(evt){
        this.globalFundCheck = evt.target.checked;
        this.template.querySelector('[data-id="fundraisingId"]').classList.remove('dash-filter');
        this.fundRaisingContacts.forEach(contactRec =>{
            contactRec.isSelected = evt.target.checked
        })
    }
    /* JAGRITI : END */
    // handle the gfund role check

    handlefundRoleChange(evt) {
        let currentId = evt.currentTarget.dataset.id;
        let selectedOption = evt.detail.value;
        this.fundRaisingContacts[currentId].role = selectedOption;
    }
    // handle the gfund team create

    handleFundTeamCreate() {
        let selectedFundContacts = [];
        let fundIds = [];
        this.fundRaisingContacts.forEach(fundRec =>{
            if(fundRec.isSelected) {
                selectedFundContacts.push(fundRec)
            }
        })
        if(!selectedFundContacts.length) {
            // Bug 00048102 fixed by Sudhanshu
            // this.errorMessage=['Select atleast a record.'];
            // this.errorHeader = 'Review the errors on this page';
            // this.isFundTeamError = true;
            //const event = new ShowToastEvent({title: 'Error',message: 'Select atleast a record.',variant: 'error',mode: 'dismissable'});
            //this.dispatchEvent(event);

            const event = new ShowToastEvent({title: 'Error',message: 'Select atleast a record.',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(event);
            return;
        }
        this.newFundRaisingRecords.forEach(fund=>{
            fundIds.push(fund.recId);
        })
        if(selectedFundContacts.length) {
            createFundTeamRecords({
                fundJSONString : JSON.stringify(selectedFundContacts),
                fundRecordIds : fundIds
            })
            .then(res=>{
                //critical Bug Fix Nikita S
                const successToast = new ShowToastEvent({title: 'Success', message: 'Contact was successfully added to your Fundraising.',variant: 'success',mode: 'dismissable'});
                this.dispatchEvent(successToast);
                if(!this.isRedirectToParentScreen) {
                    window.location.reload();
                }
                else {
                    // this.navigateBackToParentScreen();
                    const ev = new CustomEvent("navigatebacktoparentscreen");
                    this.dispatchEvent(ev);
                }
            })
            .catch(err=>{
                const errorToast = new ShowToastEvent({title: 'Error', message: 'Error in creating Fundraising Contact(s)',variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(errorToast);
                if(!this.isRedirectToParentScreen) {
                    window.location.reload();
                }
                else {
                    // this.navigateBackToParentScreen();
                    const ev = new CustomEvent("navigatebacktoparentscreen");
                    this.dispatchEvent(ev);
                }
            })
            
        }

    }
    hideRecordModal(){
        const ev = new CustomEvent("navigatebacktoparentscreen");
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