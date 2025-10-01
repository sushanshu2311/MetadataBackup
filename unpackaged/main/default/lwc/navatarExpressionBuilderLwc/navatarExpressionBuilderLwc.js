import { api, LightningElement } from 'lwc';
import setFilter from './navatarExpressionBuilderLwcHelper';

export default class NavatarExpressionBuilderLwc extends LightningElement {
    @api rowSize;
    @api fieldStruct;
    @api index; 
    @api isModalOpen = false;
    @api showPickList = false;
    @api compData;
    @api isFilterLogicEnabled = false;

    renderedCallback() {
        if (this.template.querySelector('navpeII_dev18-navatar-research-combobox-with-search-lwc').searchval != this.compData.searchVal) {
            this.template.querySelector('navpeII_dev18-navatar-research-combobox-with-search-lwc').searchval = this.compData.searchVal
            console.log('in searchlookup ' + JSON.stringify(this.compData));
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

    get enableAddRow() {
        return this.index == 1;
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
    get optionPlaceHolder() {
        return this.compData.fieldName == '' ? '' : 'Select an Option';
    }
    //-------------------------All the Event Handlers---------------------------------------------

    /* Purpose:
    if filter values are changed/set then the value will remain intact here
    */
    handleFilterChange(event) {
        let curData = JSON.parse(JSON.stringify(this.compData));
        curData.filter = event.detail.value;
        this.compData = curData;
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
    }
    /* Purpose:  if In comboboxsearch cmp picklist value is selected
    then this function will handle the event fired by the child here */
    handleOptionSelect(event) {
        let selectedList = event.detail;
        let res = {};
        res.searchVal = selectedList.displayName;
        res.objName = selectedList.displayName.split(':')[0];
        res.fDataType = selectedList.dataType;
        res.fieldName = selectedList.fieldName;
        res.filterVal = '';
        res.curVal = [];
        res.isSearchable = false;
        res.isDateType = false;
        if (res.fDataType == 'PICKLIST' || res.fDataType == 'MULTIPICKLIST' ||
            res.fDataType == 'REFERENCE' || res.fDataType == 'BOOLEAN') {
            res.isSearchable = true;
        } else if (res.fDataType == 'DATE' || res.fDataType == 'DATETIME') {
            res.isDateType = true;
        }
        this.compData = JSON.parse(JSON.stringify(res));
        this.compData.filter = '=';
        this.compData = setFilter({ curData: JSON.parse(JSON.stringify(this.compData)) });
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

    handleAddRow(){
        const selectedEvent = new CustomEvent("addrow");
        this.dispatchEvent(selectedEvent);
    }

    /* Purpose:  */
    handleDelete() {
        const selectedEvent = new CustomEvent("deleterows", { detail: this.index });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    /* Purpose:
    functon will handle and intact any changes to current component's input search field
    which will ideally be populated after selection from  piclistpopup component
    */
    handleUpdateSearch(event) {
        let curData = JSON.parse(JSON.stringify(this.compData));
        let searchValue = event.detail.value;
        if (this.compData.fDataType == 'DATETIME' && searchValue != '') {
            //searchValue = searchValue.replace('Z', '').replace('T', ' ');
            //Commented above line & added below line by Lakshya on 20211014 to resolve datetime selection issue on selecting the date
            searchValue = searchValue != null ? searchValue.split('T')[0] + ' 00:00:00' : curData.filterVal;
        }
        curData.filterVal = searchValue;
        if (searchValue == '' || searchValue == undefined) {
            curData.curVal = [];
        } else {
            curData.curVal = searchValue.split(',');
        }
        this.compData = curData;
    }
    /* Purpose:
    functon will populate the results of selected values from picklistPopup component
     back to its component search input
    */
    handlePicklistPopupSave(event) {
        let updatedVal;
        let curData = JSON.parse(JSON.stringify(this.compData));
        if (curData.fDataType != 'BOOLEAN') {
            let finList = event.detail.filter(item => !curData.curVal.includes(item));
            let jointArray = [...curData.curVal, ...finList];
            curData.curVal = jointArray;
            updatedVal = curData.curVal.join(',');
            curData.filterVal = updatedVal;
        } else {
            curData.curVal = event.detail;
            curData.filterVal = event.detail;
        }
        this.compData = curData;
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.z_index_css .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            z-index: 9;
        }`;
    this.template.querySelector('.main-Container')?.appendChild(style);
}}