/****************************************************************************************************

** Module Name : Activity Associations

** Description : Custom lookup component using dynamic objects

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
import lookUp from '@salesforce/apex/NavatarSingleLookupCtrl.getRelatedData';
import getIconName from '@salesforce/apex/NavatarSingleLookupCtrl.getIconName';
import getPreSelectedRecordName from '@salesforce/apex/NavatarSingleLookupCtrl.getPreSelectedRecordName';
import { api, LightningElement, track, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

export default class navatarSingleLookupLwc extends LightningElement {
    @track storeLookUpList;
    @api objName;
    @api fieldName;
    @track iconName;
    @api fieldLabelName
    @api filter = '';
    @api searchPlaceholder='Search';
    @track selectedName;
    @track records = [];
    @track isValueSelected = false;
    @track blurTimeout;
    @api selectedId;
    @api inputCls;
    @api isRecSelected = '';
    @api contactCheck;
    searchTermString;
    @track currentSearchTerm = '';
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @api triggerComponent = '';
    @api newCreatedRecordId = ''
    @api isThemePage;
	selectedRecord; // critical bug fix nikitaS
    @api indexvalue;
    error;
    @api isRequired = false;    // Bug 00044242 Fixed by Sudhanshu on 07-05-2024
   
    // search records on change of search string
    @wire(lookUp, {searchTerm : '$searchTermString', myObject : '$objName'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
           // this.records = [];
        }
        if(this.records == ''){
            this.checkData();
        }
		
    }
    checkData(){
        if(this.records == '' && this.searchTermString !== null && this.contactCheck == "true"){
            this.sendSelectedDataToParentComponent(this.searchTermString);
    }
}  

    // show record list only when size > 0
    get isRecordsFound(){
        return this.records.length > 0 ? true : false;
    }

    // get icon name of object
    @wire(getIconName, {sObjectName: '$objName'})
    gettingiconName({ error, data }) {
        if (data) {
            this.iconName = data;
            console.log('lookup icon name ==',data);
        }
        else if (error) {
            console.log('Error is ' + JSON.stringify(error));
        }

    }
    
    // if there is any selected record on page load get name of that object
    connectedCallback(){
        if(this.selectedId != null && this.selectedId != undefined){
            getPreSelectedRecordName({"recId" : this.selectedId, "sObjectName" : this.objName}).then(data => {
                this.selectedName = data;
                this.isValueSelected = true;
            }).catch(error => {
                console.log(error);
                this.isLoading = false;
            });
        }
        
    }

    //31515 -- added to error message if blank input
    @api get showerror(){
        console.log('found error==');
        this.template.querySelectorAll("lightning-input").forEach(item => {
            console.log('found error==');
            if(this.selectedId == ''){
                item.setCustomValidity('Complete this field');
                //isValidated = false;
            }
            else{
                item.setCustomValidity("Complete this field");
            }
            item.reportValidity();
        });
    }

    // return current selected recordid
    @api get currentSelectedRecord(){
        return this.selectedId;
    }

    // get field api 
    @api get currentFieldApi(){
        return this.fieldName;
    }

    // return class name
    @api get currentInputClass(){
        return this.inputCls;
    }

    @api get searchTerm(){
        return this.currentSearchTerm;
    }
    
    // handle click on input.
    handleClick() {
        this.searchTermString = '';
        this.currentSearchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    //onblur event on input field
    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    // on select from record list
    onSelect(event) {
        this.isRecSelected = 'true';
        this.selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        if(this.isThemePage || this.isRecSelected == 'true'){
        this.selectedRecord = this.records.find(e => e.Id == event.currentTarget.dataset.id);
        this.sendSelectedDataToParentComponent(this.selectedRecord);
        this.isRecSelected = 'false';
        }
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        this.records = [];
    }

//     sendSelectedDataToParentComponent(record) {
//         if(this.contactCheck == "true" && record !== null &&  this.records == ''){
//          this.dispatchEvent(new CustomEvent('accountselected', {detail: record  }));
//         }
//         else{
//         let returnedObj = {id : this.newCreatedRecordId, data : record, searchKey : this.searchTerm};
//         this.dispatchEvent(new CustomEvent('lookupselected', {detail:  JSON.stringify(returnedObj) }));
            
//    }
// }

    // handle remove record pill
    handleRemovePill() {
        this.isValueSelected = false;
        this.selectedId = '';
        this.searchTermString = '';
        this.currentSearchTerm='';
        this.selectedRecord = '';
        this.records = [];
        // to remove selected value
        // critical bug fix nikitaS
         this.sendSelectedDataToParentComponentOnRemove(this.selectedRecord);
       
    }

    // change search term value on change
    onChange(event) {
		if(this.objName == undefined){
            this.objName='Account';
        }
        this.searchTermString = event.target.value;
        this.currentSearchTerm = event.target.value;
    }

    renderedCallback(){		
        const style = document.createElement('style');
        style.innerText = `.pillwidth span.slds-pill {
            width: 100%;
        }
        .pillwidth lightning-button-icon.slds-pill__remove{
            position: absolute;
            right: 0;
        }
        .pillwidth .slds-pill{
            justify-content: flex-start !important;
        }
        .slds-form-element__label:empty{
            display: none;

        }`;	
        this.template.querySelector('.pill_div')?.appendChild(style);
    }

    sendSelectedDataToParentComponent(record) {
        //critical bug change nikitaS
        if(this.contactCheck == "true" && record !== null && this.records == ''){
        	this.dispatchEvent(new CustomEvent('accountselected', {detail: record  }));
        }else{
            console.log('inside else'+JSON.stringify(record));
	        let returnedObj = {id : this.newCreatedRecordId, data : record, searchKey : this.searchTerm, obj:this.objName,indexData:this.indexvalue};
	        this.dispatchEvent(new CustomEvent('lookupselected', {detail:  JSON.stringify(returnedObj) }));
      }
       
    }

    //critical bug fix nikitaS
    sendSelectedDataToParentComponentOnRemove(record){
        if(record == ''){
            console.log('inside if comp'+JSON.stringify(record));
            let returnedObj = {id : this.newCreatedRecordId, data : record, searchKey : this.searchTerm, obj:this.objName,indexData:this.indexvalue};
	        this.dispatchEvent(new CustomEvent('lookupselected', {detail:  JSON.stringify(returnedObj) }));
        }
    
}
}