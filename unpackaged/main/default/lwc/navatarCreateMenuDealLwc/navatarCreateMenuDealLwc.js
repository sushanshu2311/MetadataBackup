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
import { LightningElement,wire} from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class navatarCreateMenuDealLwc extends NavigationMixin(LightningElement) {
    //Defined variables
    showDealCreateForm = true;
    isAccountNeeded = false;
    showCompanyForSelection = false;
    showCompanyRelatedData = false;
    selectContactToAdd = false;

    dealRecord = {};
    accountName = '';
    dealId = '';
    accId = '';
    companyRT = '';
    enableSpinner = false;
    New_Deal_Success_Message = 'Deal "{0}" was created.';
    New_Deal_And_Firm_Success_Message = 'Deal "{0}" and Firm "{1}" was created.';

    //Method to get Company Record Type Id
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    wiredObjectInfo({error, data}) {
        if (error) {
            console.error(JSON.stringify(error));
        } else if (data) {
        for (const [key, value] of Object.entries(data.recordTypeInfos)) {
                if(value.name === 'Company') {
                    this.companyRT = value.recordTypeId;
                }
            }
        }
    };

    //Handle next for 1st Screen
    handleNext(event){
        //Store deal record details
       this.dealRecord = event.detail;
       this.showDealCreateForm = false;
       this.isAccountNeeded = true;
     }

     //Handle 2nd Screen No functionlity and create Deal to navigate
    handleNo() {
        this.enableSpinner = true;
        this.createDealRecord(true, true);       
    }

    //Handle Yes for 2nd Screen to show 3rd screen and hide current
    handleYes() {
        this.showCompanyForSelection = true;
        this.isAccountNeeded = false;
    }

    //Deal Creation Logic
    createDealRecord(navigate, afterAccountCreation) {
        this.enableSpinner = true;
        console.log('navigate : ',navigate , ' afterAccountCreation : ',afterAccountCreation);
        const dealInput = {
            apiName: 'navpeII_dev18__Pipeline__c',
            fields: this.dealRecord,
          }; 

         //Create record for Deal
          createRecord(dealInput).then((record) => {
            this.dealId = record.id;
            if(!navigate) {
                if(this.dealId !== null && this.dealId != undefined && this.dealId !== '') {
                    //On Deal Creation
                    this.showToast(' ', this.New_Deal_Success_Message.replace('{0}',this.dealRecord.Name), 'success', 'dismissable');                    
                    this.showCompanyRelatedData = true;
                    this.showCompanyForSelection = false;
                    this.enableSpinner = false;
                }
            }else if(navigate) {   
                if(afterAccountCreation) {
                    this.accountName = this.accountName === ''? this.dealRecord.Name : this.accountName;
                    
                    this.showToast(' ', this.New_Deal_And_Firm_Success_Message.replace('{0}',this.dealRecord.Name).replace('{1}', this.accountName),'success', 'sticky');
                }else {
                    this.showToast(' ', this.New_Deal_Success_Message.replace('{0}',this.dealRecord.Name), 'success', 'sticky'); 
                }
                setTimeout(() => {
                    this.handleNavigation(record.id);  
                }, 2000);

            }          
          });
    }

    //Account create logic
    createAccountRecord() {
        let accountRecord = {Name : this.accountName, RecordTypeId :this.companyRT};
        
        const accountInput = {
            apiName: 'Account',
            fields: accountRecord,
          }; 
         //Create record for Deal
          createRecord(accountInput).then((record) => {
            this.accId = record.id;
            this.dealRecord.navpeII_dev18__Company__c = record.id;
            this.createDealRecord(true, true); 
          });
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

    //handle navigation to deal record
    handleNavigation(recId) {
        try {            
            window.open("/lightning/r/navpeII_dev18__Pipeline__c/"+recId+"/view", "_self");
            //this.enableSpinner = false;
        } catch (error) {
            console.error(JSON.stringify(error));
        }
       
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.dispatchEvent(new CustomEvent('closemodal'));
        
    }

    //handle save for 3rd Save, where account is selected to create or update for deal
    handleSave(event) { 
        //logic when account record is selected and deal needs to be attached  
        if(event.detail.startsWith('001')) {
            console.log('Account Selected');
            this.accId = event.detail;
            this.dealRecord.navpeII_dev18__Company__c = event.detail;
            this.createDealRecord(false, false);
        }else {
            console.log('Account Not Selected');
            //handle when no account record is selected and new needs to be created
            this.accountName = event.detail;
            this.createAccountRecord();
        }
    }

    //handle back functionality on 3rd screen
    handleBack() {
        this.showCompanyForSelection = false;
        this.isAccountNeeded = true;
    }

    //handle Clone functionlity for 4th screen
    handleCloneScreenSave() {
        this.selectContactToAdd = true;
        this.showCompanyRelatedData = false;        
    }

    handleCloneContactSave() {    
        this.enableSpinner = true;
        setTimeout(() => {
            this.handleNavigation(this.dealId);
        }, 2000);   
    }
 
    handleNoChild() {
        this.handleCloneScreenSave();
    }

    handleNoContact() {
        this.enableSpinner = true;
        setTimeout(() => {
            this.handleNavigation(this.dealId);
        }, 3000);

    }
}