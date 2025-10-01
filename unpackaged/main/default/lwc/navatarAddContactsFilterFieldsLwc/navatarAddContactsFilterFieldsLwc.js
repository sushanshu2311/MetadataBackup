import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; // To get metadata about a specific object
import { showNotification, validateAdvanceFilterLogic } from "./navatarAddContactsFilterFieldsHelperLwc"; // To import methods from another file

export default class NavatarAddContactsFilterFieldsLwc extends LightningElement {
    @api objApiNamesList;       // Stores list of object api names
    @api enableAddRow;          // Enables add row link or not; boolean value
    @api enableAddFilterLogic;  // Enables add filter logic link or not; boolean value
    @api filterErrMsg = "";     // Stores error message if there is some error in the typed advance filter logic
    @api mandateFilter;
    showAddRow = false;         //Bug Fix- 00042807 By Harshwardhan , added variable to hide + icon
    objName = 'Account';        // Stores the provided object's api name
    fieldStruct = [];           // Holds the fieldList at all times from initial call till component cycle
    curObjIndex = 0;            // Stores current object index wrt objApiNamesList
    ignoreTheseTypes = ['ENCRYPTEDSTRING', 'ID', 'ADDRESS', 'SYSTEMMODSTAMP', 'JIGSAWCOMPANYID', 'JIGSAWCONTACTID', 'JIGSAW', 'MASTERRECORDID'];
    // Stores field types to be ignored when preparing object field's list
    @api
    filterList = [];            // Holds all the rows of filter(field,operator,filtervalue) which will be used for selection
    rowSize = 1;                // Maintains the row count for add/delete of rows
   
    filterLogicVal = "";        // Retains the advance flter string entered by the user
    //Enables/disables add row button based on current filter list size
    get disableMoreRows() {
        return (this.rowSize >= 10 || this.filterList.length < 1);
    }

    //Added by Lakshya on 2021-08-31 to make filter component generic
    connectedCallback(){
        if(this.objApiNamesList.length != 0){
            this.curObjIndex = this.objApiNamesList[0].toUpperCase() == 'ACCOUNT' ? 0 : -1;
        }
    }

    //Fetches the object's metadata info; In our case objects will be multiple
    @wire(getObjectInfo, { objectApiName: '$objName' })
    getObjectInfo({ data, error }) {
        if (data) {
            let objInfo = data;
            this.fieldOptions(objInfo);
        }
        else if (error) {
            this.dispatchEvent(showNotification('Error!!', error, 'Error'));
        }
    }

    //Gets the object metadata in current user's context and maps the same to create picklist options
    fieldOptions(objectInfo) {
        let itemList = this.fieldStruct;

        if (objectInfo.fields) {
            let fieldsInfo = Object.values(objectInfo.fields).sort((a, b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
            let curIndex = itemList.length;

            for (let key in fieldsInfo) {
                if (!(this.ignoreTheseTypes.includes(fieldsInfo[key].apiName.toUpperCase())
                    || this.ignoreTheseTypes.includes(fieldsInfo[key].dataType.toUpperCase())
                    || (fieldsInfo[key].length > 255 && fieldsInfo[key].dataType == 'TextArea')
                )) {
                    if(fieldsInfo[key].filterable == true ){
                    
                    itemList.push({
                        objName: objectInfo.custom ? objectInfo.apiName : objectInfo.apiName,
                        objApiName: objectInfo.apiName,
                        label: fieldsInfo[key].label,
                        displayName: (objectInfo.label + ':' + fieldsInfo[key].label).replace(/\s/g, ' '),
                        fieldName: fieldsInfo[key].apiName,
                        dataType: fieldsInfo[key].dataType.toUpperCase(),
                        index: curIndex++,
                        childRelationShipName: fieldsInfo[key].relationshipName,
                    });
                }
                }
            }
            //Modified by Lakshya on 2021-08-31 to make filter component generic
            if (this.objApiNamesList.length != 0) {
                if (this.objApiNamesList[0].toUpperCase() != 'ACCOUNT' && this.curObjIndex == -1) {
                    itemList.length = 0;
                }
                if (this.curObjIndex < this.objApiNamesList.length) {
                    this.curObjIndex = this.curObjIndex + 1;
                    this.objName = this.objApiNamesList[this.curObjIndex];
                }
            }
        }
        if (this.curObjIndex == this.objApiNamesList.length) {
            this.fieldStruct = itemList;
            let item = [
                {
                    index: 1,
                    filterData: {
                        objName: "",
                        filterVal: "",
                        searchVal: "",
                        filter: "=",
                        isDateType: false,
                        isSearchable: false,
                        curVal: [],
                        filterOptions: [],
                        fDataType: "",
                        fieldName: ""
                    }
                }
            ];
            this.filterList = item;
        }
    }
    //Responsible for inserting new filter rows
    handleRowInsertion() {
        if (this.filterList.length >= 1) {
            let rowList = JSON.parse(JSON.stringify(this.filterList));
            let temp = this.template.querySelectorAll("c-navatar-add-contacts-expression-builder-lwc");
            let index = 0;

            while (index < rowList.length) {
                rowList[index].filterData = temp[index].compData;
                index++;
            }
            rowList.push({
                index: rowList.length + 1,
                filterData: {
                    objName: "",
                    filterVal: "",
                    searchVal: "",
                    filter: "",
                    isDateType: false,
                    isSearchable: false,
                    curVal: [],
                    filterOptions: [],
                    fDataType: "",
                    fieldName: ""
                }
            });
            this.filterList = rowList;
            this.rowSize = rowList.length;
        }
    }

    //Deletion will occur here if any filter row is deleted by the user
    handleRowDeletion(event) {
        let index = 0;
        let delIndex = event.detail;
        let temp = this.template.querySelectorAll("c-navatar-add-contacts-expression-builder-lwc");
        let rowList = JSON.parse(JSON.stringify(this.filterList));
        rowList.splice(delIndex - 1, 1);

        while (index < rowList.length) {
            if (index < delIndex - 1) {
                rowList[index].filterData = temp[index].compData;
            }
            else {
                rowList[index].index = rowList[index].index - 1;
                rowList[index].filterData = temp[index + 1].compData;
            }
            index++;
        }
        this.filterList = rowList;
        this.rowSize = rowList.length;
    }
    //Resets all the filters to its initial state and shows list of contacts without filters
    @api
    handleClearFilter() {
        this.filterList = [];
        this.fieldStruct = [];
        let obj = {};
        obj.filterData = [];
        obj.filterString = '';
        console.log('-----------' + JSON.stringify(this.objApiNamesList));
        this.curObjIndex = 0;
        this.objName = this.objApiNamesList[0];
        this.filterLogicVal = "";
        this.filterErrMsg = "";
        this.rowSize=1;
        return obj; // 00029530 by vishesh
    }

    //Gets applied whenever user has any filters/Advance filter logic to be applied
    //Logic verification is also handled within
    @api
    handleApplyFilter() {
        let obj = {};
        let filterData = [];
        let temp = this.template.querySelectorAll("c-navatar-add-contacts-expression-builder-lwc");
        this.filterErrMsg = '';
        let boolRecTypeReference = false; // variable added for bug -00042599

        for (let count = 0; count < this.rowSize; count++) {
            if (temp[count].compData.fieldName != '') {
                if(temp[count].compData.fDataType == 'REFERENCE' && temp[count].compData.fieldName == 'RecordTypeId'){//Added Condition for bug -00042599 by Harshwardhan
                    boolRecTypeReference = true; 
                }
                filterData.push({
                    serialnumber: count + 1,
                    field: temp[count].compData.objName + ":" + temp[count].compData.fieldName + ":" +
                        temp[count].compData.searchVal.split(":")[1] + ":" + temp[count].compData.fDataType,
                    Value: temp[count].compData.filterVal,
                    Operator: temp[count].compData.filter
                });
            }
        }
        //Bug Fix - 00042599 Starts -- By Harshwardhan Singh Karki
        console.log('@filterData'+JSON.stringify(filterData));
        let splitData= filterData[0].Value.toString();
        let splitDataList=[];
        splitDataList=splitData.split(",");
        let newForString='';
        if(splitDataList.length > 1 && boolRecTypeReference == true){
            for(let i=0;i<splitDataList.length;i++){
                if(newForString == ''){
                   newForString= splitDataList[i]+'\'';
                }else{
                 if(i != splitDataList.length - 1){
                     newForString=newForString+','+'\''+splitDataList[i]+'\'';
                 }
                 else{
                     newForString=newForString+','+'\''+splitDataList[i];
                 }            
                }
             }
             filterData[0].Value = newForString;
             console.log('@filterData22'+newForString);
        }
        //Bug Fix - 00042599 Ends
        if (filterData.length >= 1) {
            if (this.filterLogicVal != "") {
                let result = validateAdvanceFilterLogic(filterData, this.filterLogicVal);
                if (result.filterErrMsg != '') {
                    obj.filterErrMsg = this.filterErrMsg = result.filterErrMsg;
                }
                else {
                    obj.filterData = filterData;
                    obj.filterString = result.finalFilterList.join(",");
                }
            }
            else {
                obj.filterData = filterData;
                obj.filterString = '';
            }
        }
        else if (this.mandateFilter) {
            obj.filterErrMsg = 'Please select a search criteria.';
            this.dispatchEvent(showNotification('Error!!', 'Please select a search criteria.', 'Error'));
        }
        return obj;
    }


    //Keeps the value changes of advance filter logic string intact
    handleFilterChange(evt) {
        this.filterLogicVal = evt.target.value;
    }

    //Opens add filter logic helptext window
    handleShowInfo() {
        let strWindowFeatures = "location=yes,scrollbars=yes,status=yes,height=570,width=600";
        window.open("https://help.salesforce.com/articleView?id=filter_logic", "_blank", strWindowFeatures);
    }
}