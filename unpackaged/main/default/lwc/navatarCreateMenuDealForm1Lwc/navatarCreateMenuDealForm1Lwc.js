import { LightningElement , wire , api } from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import DEAL_OBJECT from '@salesforce/schema/Pipeline__c';
 
export default class navatarCreateMenuDealForm1Lwc extends LightningElement {

    recordTypeOptions = [];
    recordTypeValue = '';
    dealRecord = {};
    showRTSelector = false;
    isError = false;
    errorMessage = '';
    nameLabel = 'Deal Name';

    @wire(getObjectInfo, { objectApiName: DEAL_OBJECT })
    wiredObjectInfo({error, data}) {
        if (error) {
            console.error(JSON.stringify(error));
        } else if (data) {
            this.showRTSelector = false;
            let options = [];
            
            for (const [key, value] of Object.entries(data.recordTypeInfos)) {
                if(value.name !== 'Master' && value.available) {
                    this.showRTSelector = true;
                    options.push({label : value.name, value : value.recordTypeId});
                    if(value.defaultRecordTypeMapping) {
                        this.recordTypeValue = value.recordTypeId;
                    }
                }
            }
            this.recordTypeOptions = options;
        }
    };

    handleChange(event) {
        this.dealRecord[event.target.name] = event.target.value;
    }


    handleNext() {
        this.template.querySelectorAll("lightning-input").forEach(item => {
            let fieldValue=item.value;
            console.log('fieldValue date=='+fieldValue); 
            if(!fieldValue){
                this.isError = true;
                this.errorMessage = "These required fields must be completed: "+ this.nameLabel +'.';
                item.setCustomValidity(fieldErrorMsg); //+' '+fieldLabel
                 return;
            } else{
                item.setCustomValidity("");
                this.isError = false;
                const ev = new CustomEvent("handlenext",{detail : this.dealRecord});
                this.dispatchEvent(ev);
            }
            item.reportValidity();
            });

        // const All_Compobox_Valid = [...this.template.querySelectorAll('lightning-input')]
        // .reduce((validSoFar, input_Field_Reference) => {
        //     input_Field_Reference.reportValidity();
        //     return validSoFar && input_Field_Reference.checkValidity();
        // }, true);

        // if(All_Compobox_Valid){            
        //     const ev = new CustomEvent("handlenext",{detail : this.dealRecord});
        //     this.dispatchEvent(ev);
        // }        
    }

    handleBlur() {
        this.template.querySelectorAll("lightning-input").forEach(item => {
        let fieldValue=item.value;
        console.log('fieldValue date=='+fieldValue); 
        if(!fieldValue){
            this.isError = true;
            this.errorMessage = "These required fields must be completed: "+ this.nameLabel +'.';
            item.setCustomValidity(fieldErrorMsg); //+' '+fieldLabel
             return;
        } else{
            item.setCustomValidity("");
            this.isError = false;
        }
        item.reportValidity();
        });
    }

    closeModal() {
        const ev = new CustomEvent("closemodal");
        this.dispatchEvent(ev);        
    }
}