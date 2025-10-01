/****************************************************************************************************

** Module Name : Advance Research Lookup Functionality

** Description : Custom lookup component using dynamic objects

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-012-11          Ehatsham

****************************************************************************************************/
import lookUp from '@salesforce/apex/NavatarResearchSingleLookupCtrl.getRelatedData';
import getIconName from '@salesforce/apex/NavatarResearchSingleLookupCtrl.getIconName';
import getPreSelectedRecordName from '@salesforce/apex/NavatarResearchSingleLookupCtrl.getPreSelectedRecordName';
import { api, LightningElement, track, wire } from 'lwc';

export default class NavatarResearchSingleLookupLwc extends LightningElement {
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
    searchTerm;
    @track currentSearchTerm = '';
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    selectedRecord;
    @api indexvalue;
    @api callingfrom;
    //firstTimeRender=false;
    runningFunctionCheck=false;
    // search records on change of search string
    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = [];
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
           // alert(this.selectedId);
            console.log('lookup icon name ==',data);
            if(this.runningFunctionCheck == true ){
                this.handleRemovePill();
               // alert('vj');
            }
           
            //alert('monish ->'+this.objName);
        }
        else if (error) {
            console.log('Error is ' + JSON.stringify(error));
        }

    }
    
    // if there is any selected record on page load get name of that object
    connectedCallback(){
        
        
        if(this.selectedId != '' && this.selectedId != null && this.selectedId != undefined){
            
            getIconName( {sObjectName: this.objName}).then(iconData=>{
                this.iconName = iconData;
                this.fetchRecord();
            }).catch(error => { console.log(error)});
            
            
            

        }
        
    }
    fetchRecord(){
        getPreSelectedRecordName({"recId" : this.selectedId, "sObjectName" : this.objName}).then(data => {
            //this.timeoutId2 = setTimeout(this.delayFunction2.bind(this), 1000);
            this.selectedName = data;
            this.isValueSelected = true;
            //this.firstTimeRender=true;
            console.log('..>>'+this.objName+'--'+data);
            var purifiedData={Id:this.selectedId,Name:this.selectedName};
            //alert('this.selectedName -->'+this.selectedName);
            this.sendSelectedDataToParentComponent(purifiedData);
            
        }).catch(error => {
            console.log(error);
            this.isLoading = false;
            //this.firstTimeRender=true;
        });
    }
    delayFunction2(){
        
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
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        
    }

    //onblur event on input field
    onBlur() {
          this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
        // this.blurTimeout = setTimeout(() => {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'; this.searchTerm = "";this.records = [];}, 300);
    
    }
 // ui fix 10feb------------------------------
 @api lookupmethod(){
    this.blurTimeout = setTimeout(() => {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'; this.searchTerm = "";console.log("searchterm");this.records = [];}, 300);  
}
//  ui feb 10 feb end --------------
    // on select from record list
    onSelect(event) {
        this.selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        console.log('this.isRecSelected'+this.isRecSelected);
        if(this.isRecSelected == 'true'){
            this.selectedRecord = this.records.find(e => e.Id == event.currentTarget.dataset.id);
            console.log('..>>selectedRecord'+JSON.stringify(this.selectedRecord));
            this.sendSelectedDataToParentComponent(this.selectedRecord);
        }
        this.runningFunctionCheck=true;
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        this.records = [];
        this.searchTerm = '';
        this.currentSearchTerm = '';
       // alert('select outer');
    }

    sendSelectedDataToParentComponent(record) {
       // alert('I am inner'+this.indexvalue);
        
       // alert('I am inner'+this.iconName);
        let returnedObj = {iconValue:this.iconName, id : this.newCreatedRecordId, data : record, searchKey : this.searchTerm , obj:this.objName,indexData:this.indexvalue, currentFeatureDisabled:record.checkCurrentFun};
        console.log('returnedObj'+JSON.stringify(returnedObj));
       // this.checkValidity(returnedObj);  
        this.dispatchEvent(new CustomEvent('lookupselected', {detail:  returnedObj }));
         // alert('outer');
    }

    // handle remove record pill
    @api
    handleRemovePill(){
      // alert('one'); 
        this.isValueSelected = false;
        this.selectedId = '';
        this.searchTerm = '';
        this.currentSearchTerm = '';
        this.selectedRecord = '';
        this.records = [];
        var record={indexData:this.indexvalue,checkCurrentFun:false};
        if(this.indexvalue == 1){
            record.checkCurrentFun=true;
        }
        
        record.Id=''; 
        //alert('two'); 
   
    this.dispatchEvent(new CustomEvent('removedata', {detail:  record }));
      //  alert('calling');
    // this.sendSelectedDataToParentComponent(record);
    }

    // change search term value on change
    onChange(event) {
        console.log('changed='+this.objName);
        if(this.objName == undefined){
            this.objName='';
        }
        this.searchTerm = event.target.value;
        this.currentSearchTerm = event.target.value;
    }

    renderedCallback(){		
        const element1 = this.template.querySelector('[data-id="showLookupRecordDataId"]');
        if(this.callingfrom == 'specificRecordPage'){
            
            if (element1) {
                if (element1.classList.contains("droup_ul_alt")) {
                    element1.classList.remove("droup_ul_alt");
                    element1.classList.add("drop_ul");
                }
            }
        }else{
            
            if (element1) {
                if (element1.classList.contains("drop_ul")) {
                    element1.classList.remove("drop_ul");
                    element1.classList.add("droup_ul_alt");
                }
            }
        }
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

        }
    }`;	
        this.template.querySelector('.pill_div')?.appendChild(style);
    }

    
    

}