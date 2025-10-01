import { api, LightningElement, track, wire } from 'lwc';
import getMetadata from '@salesforce/apex/NavatarCreateMenuContactCtrl.getMetaDataFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertContactRecord from '@salesforce/apex/NavatarCreateMenuContactCtrl.insertContactRecord';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; //Added by LK on 2024-08-27 to fix 00046122
import  CONTACT_OBJECT from '@salesforce/schema/Contact';
import { NavigationMixin } from "lightning/navigation";
export default class NavatarCreateMenuContactLwc extends NavigationMixin(LightningElement) {   

    @api companyCheck;
    error;
    firstName;
    lastName;
    phone;
    email;
    legalName;
    firmId;
    firstNameValue = '';//Added initialization by LK on 2024-08-22 to fix 00046122
    lastNameValue;
    contactId;
    emailValue;
    phoneValue;
    @track isModalOpen = true;
    accountNewName;
    areDetailsVisible = false;
    lastValue;
    isError = false;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })//Added by LK on 2024-08-27 to fix 00046122
    contactObjInfo;
    
   // to get metadata of labels
    @wire(getMetadata)
     labels({error,data}){
     if(data){
        this.firstName = data[0];
        this.lastName = data[1];
        this.phone = data[2];
        this.email = data[3];
        this.legalName = data[4];
        this.lastValue = data[5];
     }else if(error){
        this.genericShowToastMessage(error.body.message,'error','sticky');
     }
    }

    contactRecord  = {'sobjectType' : CONTACT_OBJECT }

    handleSave(){
        if(this.lastNameValue == undefined){
        this.template.querySelectorAll("lightning-input-field").forEach(item => {
            let fieldValue=item.value;
            if(!fieldValue){
                this.isError = true;
                this.errorMessage = "These required fields must be completed: "+ this.lastValue +'.';
                //Commented by LK on 2024-08-01 to fix 00046931
                //item.setCustomValidity(this.errorMessage); //+' '+fieldLabel
                 return;
            } else{
                //Commented by LK on 2024-08-01 to fix 00046931
                //item.setCustomValidity("");
                this.isError = false;
            }
            item.reportValidity();
            });
        }

        
            if(this.accountNewName !== ''){
                this.newNameValue = this.accountNewName;
               }
            

      // to insert new contact record
     if(this.lastNameValue !== undefined){        
     insertContactRecord({accountId:this.firmId,accountName:this.newNameValue,record:JSON.stringify(this.contactRecord)})
       .then(result=>{
                if(result){
                    this.contactId = result.Id;
                    //Added this.firstNameValue + ' ' by LK on 2024-04-25 to fix 00032871
                    //'Contact "' + this.firstNameValue + ' ' + this.lastNameValue+'" was created'
                    //Updated msg by LK on 2024-07-29 to fix 00046491
                    //Added condition to display space b/n FirstName & LastName conditionally by LK on 2024-08-22 to fix 00046122
                    //Added dynamic contact label by LK on 2024-08-27 to fix 00046122
                    //Removed dynamic success msg by LK on 2024-11-05 for same msg for desktop/mobile
                    this.genericShowToastMessage(`${this.contactObjInfo['data']['label']} "` + this.firstNameValue + (['', ' '].includes(this.firstNameValue) ? '' : ' ') + this.lastNameValue+'" was created.','Success','');
                    this[NavigationMixin.Navigate]({
                        type: "standard__recordPage",
                        attributes: {
                          objectApiName: "Contact",
                          actionName: "view",
                          recordId: this.contactId
                        }
                      });
                }
                }
             ).catch(error=>{
                // nikitaS critical bug fix
                this.isError = true;
                this.errorMessage = error.body.message;
                if(this.errorMessage.includes('DUPLICATES_DETECTED')){
                    this.errorMessage = window.innerWidth > 768
                                        ? 'This record looks like an existing record. Please check potential duplicate records.'
                                        : 'Review the errors on this page.\nSimilar Record(s) Exist.';
                }
                //Added above code and commented below line by LK on 2024-10-21 to fix 00047931
                //this.error = error;
            //    this.genericShowToastMessage(error.body.message,'error','sticky');
             })   
        }

    }

    //generic toast message show method
    genericShowToastMessage(messageNew,variantNew,modeNew){
        const toastEvent = new ShowToastEvent({
            message: messageNew,
            variant: variantNew,
            mode: modeNew
        });
        this.dispatchEvent(toastEvent);
     }

    handleLoad(){
        this.areDetailsVisible = true;
    }


    handleAccountName(event){
       this.accountNewName = event.detail;
    }

    handleSelectedFirmRecord(event){
        let obj = {};
       obj = JSON.parse(event.detail);
       this.firmId  = obj.data.Id;
       this.firmName = obj.data.Name;
    }

    handleFirstName(event){
        if(event.target.dataset.id == 'name1'){
            this.firstNameValue = event.target.value;
            this.contactRecord.firstName = this.firstNameValue;
        } 
    }

    handleLastName(event){
        if(event.target.dataset.id == 'name2'){
            this.lastNameValue = event.target.value;
            this.contactRecord.lastName = this.lastNameValue;
        } 
      
    }

    handleEmail(event){
        if(event.target.dataset.id == 'emailVal'){
            this.emailValue = event.target.value;
            this.contactRecord.email = this.emailValue;
        } 
    }

    handlePhone(event){
        if(event.target.dataset.id == 'phoneVal'){
            this.phoneValue = event.target.value;
            this.contactRecord.phone = this.phoneValue;
        } 
    }
   
 
   // to handle open and close modal
    @api
    openModal(recordsID) {
        // to open modal set isModalOpen track value as true
       this.recordId=recordsID;
        this.isModalOpen = true;
    }
    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'))
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = ` .slds-modal__container {
            width: 30rem !important;
        }
        .spinner_css.slds-spinner_container {
            right: -90vh !important;
            left: -90vh !important;
        }
        .error_custom_css .slds-has-error .slds-form-element__help{
            position: absolute;
            font-size: 12px;
            padding-left: 2px;
        }
        .lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
            position: absolute;
            right: 2px;
            top: 0px;
        }
        .slds-form-element__label:empty{
            display: none;
        }`;
        //   <!-- jagriti UI FIX 8 DEC -->
        this.template.querySelector('.mainContainer').appendChild(style);
    }}