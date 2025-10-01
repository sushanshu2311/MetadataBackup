import { LightningElement, api, wire,track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; // To get metadata about a specific object
import { showNotification, validateAdvanceFilterLogic } from "./navatarResearchFilterFieldsLwcHelper"; // To import methods from another file
export default class NavatarResearchFilterFieldsLwc extends LightningElement {
    flag=true;
    firstTime=true;
    rte=false;
    @track storeData=[];
    @api objApiNamesList;       // Stores list of object api names
    @api enableAddRow;          // Enables add row link or not; boolean value
    @api enableAddFilterLogic;  // Enables add filter logic link or not; boolean value
    @api filterErrMsg = "";     // Stores error message if there is some error in the typed advance filter logic
    @api mandateFilter;
    objName = 'Account';        // Stores the provided object's api name
    fieldStruct = [];           // Holds the fieldList at all times from initial call till component cycle
    curObjIndex = 0;            // Stores current object index wrt objApiNamesList
    ignoreTheseTypes = ['ENCRYPTEDSTRING', 'ID', 'ADDRESS', 'SYSTEMMODSTAMP', 'JIGSAWCOMPANYID', 'JIGSAWCONTACTID', 'JIGSAW', 'MASTERRECORDID'];
    // Stores field types to be ignored when preparing object field's list
    @api
    filterList = [];            // Holds all the rows of filter(field,operator,filtervalue) which will be used for selection
    rowSize = 1;                // Maintains the row count for add/delete of rows
    enableFilterLogic = false;  // If user clears the advance filter logic then this will be set to false
    filterLogicVal = "";        // Retains the advance flter string entered by the user
    filterLogicTitle = "Add Filter Logic"; // Dynamic title of Advance filter logic button
    //Enables/disables add row button based on current filter list size
    get disableMoreRows() {
        return (this.rowSize >= 10 || this.filterList.length < 1);
    }

    //Added by Lakshya on 2021-08-31 to make filter component generic
    connectedCallback(){
        this.enableAddRow=false;
        if(this.objApiNamesList.length != 0){
            this.curObjIndex = this.objApiNamesList[0].toUpperCase() == 'ACCOUNT' ? 0 : -1;
        }
        this.storeData=[];
        this.timeoutId = setTimeout(()=>this.delayFunction(), 2000);
       
    }
    delayFunction(){
        this.enableAddRow=true;
        this.rte=true;
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
        console.log('!~~~~~~'+JSON.stringify(objectInfo));

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
        //alert('go');
        var rowTempList;
        if (this.filterList.length >= 1) {
            let rowList = JSON.parse(JSON.stringify(this.filterList));
            rowTempList=rowList;
            let temp = this.template.querySelectorAll("c-navatar-Research-Expression-Builder-Lwc");
            
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
      /*  if(this.firstTime){
            this.template.querySelector('.posibtn').classList.add('position_btn');
           
            this.firstTime=false;
        }*/
        if(rowTempList.length == 1){
            this.template.querySelector('.posibtn').classList.remove('btnposition_btn');
           // alert('check Jagrity on index 1 '+JSON.stringify(this.template.querySelector('.posibtn').classList));
   
        }else{
            this.template.querySelector('.posibtn').classList.add('btnposition_btn');
           // alert('check Jagrity on index more than > 1 '+JSON.stringify(this.template.querySelector('.posibtn').classList));
        }
    }

    //Deletion will occur here if any filter row is deleted by the user
    handleRowDeletion(event) {
        let index = 0;
        let delIndex = event.detail;
        let temp = this.template.querySelectorAll("c-navatar-Research-Expression-Builder-Lwc");
        
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
      
        if(this.rowSize == 1){
        this.template.querySelector('.posibtn').classList.remove('btnposition_btn');
       
        }
        console.log('3--'+JSON.stringify(this.filterList));
        (this.flag == true)? this.flag=false:this.flag=true;
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
        this.enableFilterLogic = false;
        this.filterLogicTitle = "Add Filter Logic";
        this.filterLogicVal = "";
        this.filterErrMsg = "";
        this.rowSize=1;
        return obj; // Ehatsham changes 
    }

    //Gets applied whenever user has any filters/Advance filter logic to be applied
    //Logic verification is also handled within
    @api
    handleApplyFilter() {
        let obj = {};
        let filterData = [];
        let temp = this.template.querySelectorAll("c-navatar-Research-Expression-Builder-Lwc");
        
        this.filterErrMsg = '';

        for (let count = 0; count < this.rowSize; count++) {
            if (temp[count].compData.fieldName != '') {
                filterData.push({
                    serialnumber: count + 1,
                    field: temp[count].compData.objName + ":" + temp[count].compData.fieldName + ":" +
                        temp[count].compData.searchVal.split(":")[1] + ":" + temp[count].compData.fDataType,
                    Value: temp[count].compData.filterVal,
                    Operator: temp[count].compData.filter
                });
            }
        }
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

    //Enables Advance filter logic & Clears the Same
    handleAdvanceFilterToggle() {
        this.enableFilterLogic = this.filterLogicTitle == "Add Filter Logic" ? true : false;
        this.filterLogicTitle = this.enableFilterLogic ? "Clear Filter Logic" : "Add Filter Logic";
        this.filterLogicVal = '';
        if (!this.enableFilterLogic)
            this.filterErrMsg = '';
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

@api 
saveSearchButtonComponentHandler(){
        console.log('bro filter list--->'+JSON.stringify(this.filterList));
        console.log('<-------fileter list end ---->');
        let rowList = JSON.parse(JSON.stringify(this.filterList));
            let temp = this.template.querySelectorAll("c-navatar-Research-Expression-Builder-Lwc");
            
            let index = 0;

            while (index < rowList.length) {
                rowList[index].filterData = temp[index].compData;
                index++;
            }
            var storData=[];
            storData = rowList;
            console.log('bro 2 modified filter list--->'+JSON.stringify(storData));
       /* var innerStructure;
        if(event.detail.pop != undefined && event.detail.pop == true){
           var index=event.detail.index;
        innerStructure ={indexValue:index};
        for(var i=parseInt(index);i<this.storeData.length-1 ;i++){
            this.storeData[parseInt(index)]=this.storeData[parseInt(index)+1];
        }
        this.storeData.pop();
        }else{
        console.log('------->'+JSON.stringify(event.detail));
       
       this.storeData.push(event.detail);
       console.log('store Data value -->'+this.storeData);
        */
       const passEvent = new CustomEvent('handlefieldfilter', {
        detail:storData
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
        .position_btn{
            position: relative;
            top: auto;
            right: 92px;
        }
        @media (max-width: 1512px) {
            .position_btn{
                right: 64px;
                left: -109px;
            }
        }`;
    this.template.querySelector('.main-Container-filter').appendChild(style);
  }
  recieveDataFromSearchComponent(event){
   console.log(JSON.stringify(event.detail));
  }
// ui change 15 dec

renderStageOfcmp(){
    (this.flag == true)? this.flag=false:this.flag=true;
}
}