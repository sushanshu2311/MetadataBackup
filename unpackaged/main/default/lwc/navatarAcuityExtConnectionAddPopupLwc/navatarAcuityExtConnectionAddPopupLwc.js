import { LightningElement , track, api } from 'lwc';
import insertContactRecord from '@salesforce/apex/NavatarCreateMenuContactCtrl.insertContactRecord';
import  CONTACT_OBJECT from '@salesforce/schema/Contact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NavatarAcuityExtConnectionAddPopupLwc extends LightningElement {
    @track isModalOpen = false;
    @track filesDisplay = false;
    //error;//Commented by LK on 2024-10-21 to fix 00047931
    //Added @api by LK on 2024-08-01 to fix 00046608 ; 00046613
    @api firstNameValue = '';//Added initialization by LK on 2024-06-11 to fix 00045991
    @api lastNameValue;
    @api accountRecordId;
    @api objectApiName;
    @api accountRecordName;
    contactRecord  = {'sobjectType' : CONTACT_OBJECT }
    phone;
    @api email;
    objeCheckAcc = false;
    accountRecId;
    newNameValue;
    @api
     openModal(text) {
         this.isModalOpen = true;
         this.checkData();
     }
     closeModal() {
         this.isModalOpen = false;
     }

     
    //Nikita S added
        checkData(){
        console.log('objApiName'+this.objectApiName);
        if(this.objectApiName == "Account"){
            this.objeCheckAcc = true;
        }else{
            this.objeCheckAcc = false;
        }
     }

     handleSelectedFirmRecord(event){
        let obj = {};
       obj = JSON.parse(event.detail);
       this.firmId  = obj.data.Id;
       this.firmName = obj.data.Name;
    }
    handleAccountName(event){
        this.accountNewName = event.detail;
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
            this.email = event.target.value;
            this.contactRecord.email = this.email;
        } 
    }
    handlePhone(event){
        if(event.target.dataset.id == 'phoneVal'){
            this.phone = event.target.value;
            this.contactRecord.phone = this.phone;
        } 
    }
    handleSave(){
        this.contactRecord.email = this.email;
        this.contactRecord.firstName = this.firstNameValue;//Added by lK on 2024-10-08 to fix 00047720
        this.contactRecord.lastName = this.lastNameValue;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
        });

        if(this.accountNewName !== ''){
            this.newNameValue = this.accountNewName;
           }

        //Nikita S added
        if(this.objectApiName == "Account"){
             this.accountRecId = this.accountRecordId;
        }else{
            this.accountRecId = this.firmId;
        }
        insertContactRecord({accountId:this.accountRecId,accountName:this.newNameValue,record:JSON.stringify(this.contactRecord)})
        .then(result=>{
                    if(result){
                        this.contactId = result.Id;
                        const toastEvent = new ShowToastEvent({
                            //Added this.firstNameValue by LK on 2024-05-27 to fix 00037882 ; 00045898 ; 00045899
                            //Updated text by LK on 2024-06-11 to fix 00045991
                            message: 'Contact "'+this.firstNameValue+(this.firstNameValue === '' ? '' : ' ') + this.lastNameValue+'" was created',
                            variant: 'success',
                        });
                        this.dispatchEvent(toastEvent);
                        this.closeModal();
                    }
                    }
                ).catch(error=>{
                    let errMsg = error.body.message;
                    if(errMsg.includes('DUPLICATES_DETECTED')){
                        errMsg = window.innerWidth > 768
                                 ? 'This record looks like an existing record. Please check potential duplicate records.'
                                 : 'Review the errors on this page.\nSimilar Record(s) Exist.';
                    }
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: errMsg,
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                    //Added above code and commented below line by LK on 2024-10-21 to fix 00047931
                    //this.error = error;

                    //this.closeModal();
                })  
    }

    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.auto_populate_field input{
            border: none !important;
            background: none !important;
            padding: 0px !important;
            font-size: 14px !important;
        } .auto_populate_css lightning-icon.slds-icon_container.slds-combobox__input-entity-icon.slds-icon-custom-custom34{
            display: none;
        }
        .auto_populate_css input{
            border: none !important;
            background: none !important;
            padding: 0px !important;
            font-size: 14px !important;
        }
    }`
    this.template.querySelector('.mainContainer')?.appendChild(style);
}
}