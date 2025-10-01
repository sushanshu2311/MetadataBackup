import { api, LightningElement } from 'lwc';
import setFilter from './navatarAddContactsExpressionBuilderHelperLwc';
import {
    ShowToastEvent
  } from 'lightning/platformShowToastEvent';

export default class  NavatarAddContactsExpressionBuilderLwc extends LightningElement {
    boolVar;
    @api rowSize;
    @api fieldStruct;
    @api index;
    @api isModalOpen = false;
    @api showPickList = false;
    @api compData;
    @api isFilterLogicEnabled = false;
    @api fromAdvanceSearch; //change for bug #00041444, 00041538 fixes by salauddin sheikh
    onlyNumber=false;
    @api fromSearchContact; //change for bug #00041444, 00041538 fixes by salauddin sheikh
    storeValueOfFilter=[]; 
    hideSearchIconAccordingToInnerFunctionality=true;
    renderedCallback() {
        if (this.template.querySelector('c-navatar-add-contacts-combobox-polymorphic-lwc').searchval != this.compData.searchVal) {
            this.template.querySelector('c-navatar-add-contacts-combobox-polymorphic-lwc').searchval = this.compData.searchVal
            
        }
    }

    
    //---------------------All the getters------------------------------------------------------
    get curType() {
        if (this.compData.fDataType == 'PERCENT' || this.compData.fDataType == 'PHONE'
            || this.compData.fDataType == 'CURRENCY' || this.compData.fDataType == 'DOUBLE'
            || this.compData.fDataType == "INTEGER")
            return 'number';
        else if (this.compData.fDataType == 'DATE' || this.compData.fDataType == 'DATETIME')
            return this.compData.fDataType == 'DATE' ? 'date' : 'datetime';
        else
            return 'text';
    }
    /* Purpose: to show AND Message if row is more than 1 */
    get enableAnd() {
        return (this.index < this.rowSize) && !this.isFilterLogicEnabled;
    }

    /* Purpose: to show delete button if row is more than 1 */
    get enableDelete() {
        return (this.index > 1);
    }
    get isFieldSelected() {
        return this.compData.fieldName == '' ? true : false;
    }
    get isOperatorSelected(){   // #00042408, #	00042367 added for operator null check by salauddin sheikh
        return this.compData.filter == '' ? true : false;
    }
    get optionPlaceHolder() {
        return this.compData.fieldName == '' ? '' : 'Select an Operator';
    }
    //-------------------------All the Event Handlers---------------------------------------------

    /* Purpose:
    if filter values are changed/set then the value will remain intact here
    */
    handleFilterChange(event) {
   
        this.hideSearchIconAccordingToInnerFunctionality = true;
        let curData = JSON.parse(JSON.stringify(this.compData));
        curData.filter = event.detail.value;
        curData.filterVal='';
        curData.curVal=[];
        this.compData = curData;
        if(this.compData.fDataType == 'REFERENCE' && (this.compData.filter == '=' || this.compData.filter == '!=' || this.compData.filter == 'like start' || this.compData.filter == '>' || this.compData.filter == '<' || this.compData.filter == '<=' || this.compData.filter == '>=' || this.compData.filter == 'like==' || this.compData.filter == 'not like!==')){ //changes for new research functionality on 27-03-2023 by Salauddin Sheikh
            this.hideSearchIconAccordingToInnerFunctionality = false;
           
        }
        
        console.log('handlefilterChange-->'+JSON.stringify(this.compData.filter));
        console.log('handlefilterChange-->'+JSON.stringify(this.compData));
    }

    /* Purpose:  if In comboboxsearch cmp picklist value is searched
    then this function will handle the event fired by the child here
    to reset already selected options and filled value */
    handleOptionSearch(event) {
        let res = {};
        res.searchVal = event.detail.value;
        res.curVal = [];
        res.filterVal = [];
        res.filterOptions = [];
        res.objName = '';
        res.fieldName = '';
        res.fDataType = '';
        res.isSearchable = false;
        res.isDateType = false;
        this.compData = res;
        console.log('i am handle option-->'+JSON.stringify(this.compData));
    }
    /* Purpose:  if In comboboxsearch cmp picklist value is selected
    then this function will handle the event fired by the child here */
    handleOptionSelect(event) {
        this.hideSearchIconAccordingToInnerFunctionality = false;
        // Ehatsham Changes 
        this.onlyNumber=false;
        
        let selectedList = event.detail.list;
        let res = {};
        console.log('~~~'+JSON.stringify(selectedList));
        res.searchVal = selectedList.displayName;
        res.objName = selectedList.objApiName; //displayName.split(':')[0];
        res.objApiName=selectedList.objApiName;
        res.fDataType = selectedList.dataType; 
        res.fieldName = selectedList.fieldName;
        res.childRelationShipName=selectedList.childRelationShipName;
        res.filterVal = '';
        res.curVal = [];
        res.isSearchable = false;
        res.isDateType = false;
        res.position=event.detail.index;
        if (res.fDataType == 'PICKLIST' || res.fDataType == 'MULTIPICKLIST' ||
            res.fDataType == 'REFERENCE' || res.fDataType == 'BOOLEAN') {
            res.isSearchable = true;
            //------------------Gui changes -----------------------------------
            
            //-----------------------------------------------------------------
        } else if (res.fDataType == 'DATE' || res.fDataType == 'DATETIME') {
            res.isDateType = true;
            
        }
        this.compData = JSON.parse(JSON.stringify(res));
        this.compData.filter = '';
        this.compData = setFilter({ curData: JSON.parse(JSON.stringify(this.compData)) });
        if(res.fDataType == 'NUMBER' || res.fDataType == 'INT' || res.fDataType == 'PHONE' || res.fDataType == 'CURRENCY' || res.fDataType == 'DOUBLE' || res.fDataType == 'PERCENT'){
        this.onlyNumber=true;
        }
        console.log('i am handle select-->'+JSON.stringify(this.compData));
    }
    /* Purpose:
    function will invoke the picklist popup component if clicked on the search icon.
    */
    handlePicklistSearch() {
        if (this.compData.objName !== '' && this.compData.fDataType !== '' && this.compData.fieldName !== '') {
            this.showPickList = true;
        }
    }
    /* Purpose:
    function will hide the picklist Popup component modal when the piclist popup modal will be closed.
    this function will be invoked when child component fires the event and it handles it
    */
    handleCloseModal() {
        this.showPickList = false;
    }

    /* Purpose:  */
    handleDelete() {
        const selectedEvent = new CustomEvent("deleterows", { detail: this.index });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        if(this.fromAdvanceSearch || this.fromSearchContact == undefined){  //change for bug #00041444 fixes by salauddin sheikh
            this.fromSearchContact = false;
        }
       else if(this.fromSearchContact){
            this.fromSearchContact = true;
        }
        if(this.boolVar == true){
            this.boolVar=false;
        }else{
            this.boolVar=true;
        }
    }
    /* Purpose:
    functon will handle and intact any changes to current component's input search field
    which will ideally be populated after selection from  piclistpopup component
    */
    handleUpdateSearch(event) {
        let curData = JSON.parse(JSON.stringify(this.compData));
        let searchValue = event.detail.value;
       
        var specials=/[*|\":<>[\]{}`\\()\';@&$]/;
        var alphabet=/[a-zA-Z]/;
        if(this.onlyNumber){
        if(specials.test(event.detail.value) || alphabet.test(event.detail.value) ){
            const evt = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                message: 'Please Enter Number Only, Remove Text From Input Field',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            
            return 1;
        }
    }
    
       
        
   // }
        if (this.compData.fDataType == 'DATETIME' && searchValue != '') {
            //searchValue = searchValue.replace('Z', '').replace('T', ' ');
            //Commented above line & added below line by Lakshya on 20211014 to resolve datetime selection issue on selecting the date
            searchValue = searchValue != null ? searchValue.split('T')[0] + ' 00:00:00' : curData.filterVal;
        }
        
        if (searchValue == '' || searchValue == undefined) {
            curData.curVal = [];
        } else {
            curData.curVal = searchValue.split(',');
        }
        
        curData.filterVal = searchValue;
        this.compData = curData;
        console.log('handleUpdateSearch -----> '+JSON.stringify(this.compData));
    }
    /* Purpose:
    functon will populate the results of selected values from picklistPopup component
     back to its component search input
    */
    handlePicklistPopupSave(event) {
        let updatedVal;
        let curData = JSON.parse(JSON.stringify(this.compData));
        console.log('on save ID-->'+JSON.stringify(event.detail.Id));
        console.log('on save label-->'+JSON.stringify(event.detail.label));
        
        if (curData.fDataType != 'BOOLEAN') {
            console.log('on next after filter-->'+ event.detail.Id.filter(item => !curData.curVal.includes(item)));
            let jointArrayOfIds;
            if(curData.fDataType == 'REFERENCE'){
                let secList = event.detail.Id.filter(item => !curData.curVal.includes(item));
                 jointArrayOfIds = [...curData.curVal, ...secList];
            }else{
                let secList = event.detail.label.filter(item => !curData.curVal.includes(item));
                jointArrayOfIds = [...curData.curVal, ...secList];
            }
            let finList = event.detail.label.filter(item => !curData.curVal.includes(item));
            let jointArray = [...curData.curVal, ...finList];
            console.log('joint Array-->'+jointArray);
            curData.curVal = jointArrayOfIds;
            updatedVal = jointArray.join(',');
            curData.filterVal = updatedVal;
        } else {
           // alert('inner level test1');
            curData.curVal = event.detail;
            curData.filterVal = event.detail;
           // alert('inner level test2');
        }
        this.compData = curData;
        console.log('##i am send call-->'+JSON.stringify(this.compData));
        this.sendDataFromSearchLookUptoFilter(this.compData);
        console.log('##i am send call2-->'+JSON.stringify(this.compData));

    }
    
  
    sendDataFromSearchLookUptoFilter(compDataValue){
        console.log(JSON.stringify(compDataValue));
        var structureMaker={objectName:compDataValue.objName,filerValue:compDataValue.filterVal,fieldName:compDataValue.fieldName,DataType:compDataValue.fDataType,isSearchable:compDataValue.isSearchable,isDateType:compDataValue.isSearchable};
        
        console.log('Structure Maker -->'+JSON.stringify(structureMaker));
        const passEvent = new CustomEvent('searchcomponentdatahandler', {
            detail:structureMaker
        });
        this.dispatchEvent(passEvent);
    }
    renderedCallback() {
        console.log(this.isRendered);
        this.isRendered = true;
        const style = document.createElement('style');
        style.innerText =`.position_btn .slds-button{
            height:30px;
            width:30px;
            border: none;
        }
        .position_btn .slds-button_icon{
            fill: #0176d3 !important;
        } 
        .zIndex_Css .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            z-index: 9 !important;
        }`;
    this.template.querySelector('.main-Container-searchlook').appendChild(style);
  }
   
}