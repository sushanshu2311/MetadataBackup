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
import {LightningElement, track, api, wire} from 'lwc';
import getRelatedContacts from '@salesforce/apex/NavatarCreateMenuDealCtrl.getRelatedContacts';
import cloneSelectedContacts from '@salesforce/apex/NavatarCreateMenuDealCtrl.cloneSelectedContacts';
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import role_field from '@salesforce/schema/Deal_Team__c.Team_Member_Role__c';
import DEAL_TEAM_OBJECT from '@salesforce/schema/Deal_Team__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarCreateMenuDealForm5Lwc extends LightningElement {
 
    @api accId;
    @api dealId;
    @api dealName;
    @track globalCheck = false; //Added by LK on 2024-10-04 to fix 00047571
    @track contacts = [];
    @track roleOptions = [];
    @track recordTypes = [];
    isContactExists = false;
    isFirst = true;
    unselectedContact = [];
    selectedContacts = [];
    objectName = DEAL_TEAM_OBJECT;
    handleSelectedContacts = false;
    New_Deal_Team_Success_Message = 'Contact was successfully added to your Deal.';

    loadContacts(){
        getRelatedContacts({accId : this.accId})
        .then(result =>{            
            this.contacts = result;
            if(this.contacts.length === 0) {
                const ev = new CustomEvent("handlenocontact");
                this.dispatchEvent(ev);
                this.isFirst = false;
            }else {
                this.isFirst = false;
                const ev = new CustomEvent("handleyescontact");
                this.dispatchEvent(ev);
                this.isContactExists = true;
            }
            return this.contacts;
        }) 
        .catch(error =>{
            console.error('Error', JSON.stringify(error));
        })
    } 

    @wire(getObjectInfo, { objectApiName: DEAL_TEAM_OBJECT })
        objectInfo;


    @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: role_field})
        getRol({ error, data }) {
        if (data) {
            this.roleOptions = data.values;      
        }else if(error) {
            console.error(error);
        }
    }

    get fetchcontacts() {
        if(this.isFirst) {
            let result;
            if(this.roleOptions.length > 0) {
                result = this.loadContacts();
            }
            return result;
        }
    }

    handleSave() {
        cloneSelectedContacts({dealId : this.dealId, cloneIds : JSON.stringify(this.selectedContacts )})
        .then(result =>{
         console.log('result',JSON.stringify(result));
         let dealTeamNames = '';
         if(result) {
            result.forEach((eachTeam)=>{
                dealTeamNames = dealTeamNames + eachTeam.Name + ',';
            });
         }
         if(dealTeamNames !== '') {
            dealTeamNames =  dealTeamNames.replace(/,*$/, '');
            this.showToast('Success', this.New_Deal_Team_Success_Message, 'success', 'dismissable');
         }         
         
         const ev = new CustomEvent("handlesave");
         this.dispatchEvent(ev);
        })
        .catch(error => {
            console.error('error',error);
        })
    }

    handleCheckbox(event) {
        if(event.detail.checked) {
        this.selectedContacts.push({id:event.target.value});
        console.log('selectedContacts',JSON.stringify(this.selectedContacts));
        }
        if(!event.detail.checked) {
             const index = this.selectedContacts.findIndex((obj => obj.id == event.target.value));
             this.selectedContacts.splice(index, 1);
             console.log('selectedContacts',JSON.stringify(this.selectedContacts));
    }
        //Added if else ladder by LK on 2024-10-04 to fix 00047571
        if(this.contacts.length === this.selectedContacts.length){
            this.globalCheck = true;
            this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
        } else if(this.selectedContacts.length === 0){
            this.globalCheck = false;
            this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
        } else {
            this.globalCheck = false;
            this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.add('dash-filter');
        }
}

   

    handleRoleChange(event) {
        this.selectedContacts.forEach((eachCon)=>{
            if(eachCon.id == event.target.name) {
                eachCon.role = event.target.value;
            }
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
    handleSelectAll(event) {
        this.selectedContacts = [];
        this.handleSelectedContacts = event.detail.checked;  
        //START : Added by LK on 2024-10-04 to fix 00047571
        this.template.querySelector('[data-id="dealGlobalCheckId"]').classList.remove('dash-filter');
        this.globalCheck = event.detail.checked;
        //END
        console.log('this.contacts',this.contacts); 
        if(event.detail.checked) {
        this.contacts.forEach((contact)=>{
            this.selectedContacts.push({id:contact.Id});    
            });
        }
        
        console.log('selectedContacts',JSON.stringify(this.selectedContacts));
    }
    closeModal() {
        const ev = new CustomEvent("closemodal");
        this.dispatchEvent(ev);
    }

    renderedCallback() {
        const style = document.createElement('style');
        //Added "dash-filter" by LK on 2024-10-04 to fix 00047571
        style.innerText = ` .slds-rich-text-editor__toolbar{
            display:none !important;

        }
        .mainDiv .slds-form-element__label{
            display:none;
        }
        .dash-filter:before{               
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
        try {
            this.template.querySelector('.mainContainer').appendChild(style);
        } catch (err) {
            console.log(err)
        }

}

}