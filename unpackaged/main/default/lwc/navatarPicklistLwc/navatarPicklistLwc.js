/****************************************************************************************************

** Module Name : Activity Associations

** Description : Show picklist dynamic by passing object name and fieldAPI.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
import {LightningElement,api,track} from 'lwc';
import getPickListValues from '@salesforce/apex/NavatarPicklistCtrl.getPickListValues';
//import getFieldLabel from '@salesforce/apex/PicklistController.getFieldLabel';

export default class DynamicPicklistLWC extends LightningElement {
    @track options;
	@api selectedOption;
	@track isAttributeRequired = false;
	@api fieldName;
	@api objectName;
	@api fieldLabelName;
	@api fieldApiName;
	@api inputCls;
	@api isRequired = false;	/// Bug 00044242 Fixed by Sudhanshu on 07-05-2024

	// get picklist all values 
	connectedCallback() {
        console.log('Dynamic Picklist==='+this.objectName+ '==='+this.fieldName);
		getPickListValues({
            objApiName: this.objectName,
            fieldName: this.fieldName,
            selectedValue : this.selectedOption
        })
        .then(data => {
            this.options = data;
			for(let opt of this.options){
				if(opt.isSelected){
					this.selectedOption = opt.value;
				}
			}
        })
        .catch(error => {
            this.displayError(error);
        });
	}

	//return current selected picklist value
    @api get currentSelectedOption(){
        return this.selectedOption;
    }

	// return field api name
    @api get currentFieldApi(){
        return this.fieldName;
    }

	// return class name
    @api get currentInputClass(){
        return this.inputCls;
    }

	//fire event on change of picklist
	selectionChangeHandler(event) {
		this.dispatchEvent(new CustomEvent('selected', {
			detail: event.target.value
		}));
		console.log('event.target.value=',event.target.value);
		console.log('event.detail.value=',event.detail.value);
        this.selectedOption = event.target.value;
	}

	// display error
	displayError(error) {
		this.error = 'Unknown error';
		if (Array.isArray(error.body)) {
			this.error = error.body.map(e => e.message).join(', ');
		} else if (typeof error.body.message === 'string') {
			this.error = error.body.message;
		}
	}

	// show picklist as disabled
	get isPicklistDisabled() {
		return (this.options &&
			this.contrFieldValue !== 'Select') ? false : true;
	}

	renderedCallback() {	
        const style = document.createElement('style');	
        style.innerText = ``;       	
		this.template.querySelector('.main-Container')?.appendChild(style);	
	}
}