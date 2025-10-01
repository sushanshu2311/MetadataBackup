import { LightningElement, wire,track,api } from 'lwc';
import insertRecord from '@salesforce/apex/NavatarCreateMenuFirmCtrl.insertRecord';
import getResponceData from '@salesforce/apex/NavatarCreateMenuFirmCtrl.getResponceData';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class navatarCreateMenuFirmLwc extends NavigationMixin(LightningElement) {   

 error;
 recordTypepicklist;
 statusValue;
 typeRecordId;
 Name;
 labelName;
 recordType;
 @track isModalOpen = true;
 @track firmId;
 areDetailsVisible = false;
 isError = false;
 labelValue;
    

// to get metadata 
 @wire(getResponceData)
 getResponceData({error,data}){
    if(data){
        this.recordTypepicklist = data.getUserDetails;
        this.labelName = data.getFieldLabels[0];
        this.recordType = data.getFieldLabels[1];
        this.labelValue = data.getFieldLabels[2];
        this.recordTypepicklist.forEach(acc =>{
            if(acc.isDefaultRecordType === true){
                this.statusValue = acc.value;
            }
        });

    }else if(error){
        this.genericShowToastMessage(error.body.message,'error','sticky');
    }
 }



 handleLoad(){
    this.areDetailsVisible = !this.areDetailsVisible;
 }


handleRecordTypeChange(event){
    this.statusValue = event.target.value;
}

handleName(event){
    if(event.target.dataset.id == 'name'){
        this.Name = event.target.value;
    } 
}


handleSave(){

    if(this.Name == undefined){
    this.template.querySelectorAll("lightning-input-field").forEach(item => {
        let fieldValue=item.value;
        if(!fieldValue){
            this.isError = true;
            this.errorMessage = "These required fields must be completed: "+ this.labelValue +'.';
            //Commented by LK on 2024-08-01 to fix 00046931
            //item.setCustomValidity(fieldErrorMsg); //+' '+fieldLabel
             return;
        } else{
            //Commented by LK on 2024-08-01 to fix 00046931
            //item.setCustomValidity("");
            this.isError = false;
        }
        item.reportValidity();
        });
    }

    
    

    // this.template.querySelectorAll('lightning-input-field').forEach(element => {
    //     element.reportValidity();
    // });

    // insert new record of firm
    
    if(this.Name !== undefined){
    insertRecord({recordTypeId:this.statusValue,name:this.Name})
    .then(result=>{
            if(result){
                this.firmId = result.Id;
				
				//Text msg updated by LK on 2024-10-10 to fix 00047784
                this.genericShowToastMessage('Firm "' +this.Name+ '" was created.','Success','');

                this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                  objectApiName: "Account",
                  actionName: "view",
                  recordId: this.firmId
                }
              });
            }
             }).catch(error=>{
                this.genericShowToastMessage(error.body.message,'error','sticky');
             })
            }
}


    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'))
     }
    
   
    @api
    openModal(recordsID) {
        // to open modal set isModalOpen track value as true
        this.recordId=recordsID;
        this.isModalOpen = true;
        setTimeout(() => {

            let sectmodal = this.template.querySelector(".slds-modal");

            let bodyClose = sectmodal.closest('body');

            bodyClose.style.overflow = "hidden";

            console.log(bodyClose,'bodyClose');

        }, 0);
       
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
    
   
   
  
   
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = ` .slds-modal__container { width: 30rem !important;
        }
        .spinner_css.slds-spinner_container {
            right: -90vh !important;
            left: -90vh !important;
        }
        .error_custom_css .slds-has-error .slds-form-element__help{
            position: absolute;
        }`;
        this.template.querySelector('.mainContainer').appendChild(style);
    }}