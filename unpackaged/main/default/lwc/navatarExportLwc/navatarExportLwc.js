import { LightningElement,wire,track,api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/navatarXLSX";
export default class NavatarExportLwc extends LightningElement {
    @track accFieldTypeMap=[];
    @track objectNameList=[];// = ['Account','Contact','Deal','Fund','Fundraising','Theme','Clip','Intraction','Pipeline__c'];
    @track objectFieldNameMap = {};
    @track ObjectLabelNameMap = {};
    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetNameList = []; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    filename;// Name of the file

    librariesLoaded = false;
    //End


    emptyAllrecords(){
        this.accFieldTypeMap=[];
        this.objectNameList=[];// = ['Account','Contact','Deal','Fund','Fundraising','Theme','Clip','Intraction','Pipeline__c'];
        this.objectFieldNameMap = {};
        this.ObjectLabelNameMap = {};
        this.xlsHeader = []; // store all the headers of the the tables
        this.workSheetNameList = []; // store all the sheets name of the the tables
        this.xlsData = []; // store all tables data
        this.filename;// Name of the file
    
        this.librariesLoaded = false;
    }

    renderedCallback() {
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        Promise.all([loadScript(this, workbook + "/xlsx/xlsx.full.min.js")])
          .then(() => {
            console.log("success");
          })
          .catch(error => {
            console.log("failure");
            console.log('Error ::: '+error)
            
          });
        //this.download();
    }

    //This method will create list of fields and Label Names
    createMapOfObjectFieldLabelNames(storeMapData){
        console.log('createMapOfObjectFieldLabelNames storeMapData ::: '+JSON.stringify(storeMapData));
        for(var i = 0; i < this.objectNameList.length; i++){
            console.log('createMapOfObjectFieldLabelNames ::: '+this.objectNameList[i]);
            this.accFieldTypeMap=storeMapData[this.objectNameList[i]];
            var objectFieldNameList = [];
            var ObjectLabelNameList = [];
            if(this.accFieldTypeMap){
                for(var rec in this.accFieldTypeMap){
                    objectFieldNameList.push(this.accFieldTypeMap[rec].fieldName);
                    ObjectLabelNameList.push(this.accFieldTypeMap[rec].fieldLabel);
                
                }
                this.objectFieldNameMap[this.objectNameList[i].toLowerCase()+'Field'] = objectFieldNameList;
                this.ObjectLabelNameMap[this.objectNameList[i].toLowerCase()+'Label'] = ObjectLabelNameList;
            }
        }
    }

    //Comment add
    createListOfObject(globalFieldTypeCasting){
        for(var key in globalFieldTypeCasting){
            console.log('globalFieldTypeCasting key ::: '+key);
            if(!this.objectNameList.includes(key)){
                this.objectNameList.push(key);
            }
        }
        console.log('Whole Map Data ::::: '+this.objectNameList);
    }

    //Samiulla Pathan: This method will check for user selected records and prepares the map of all selected records type and sends it to 
    //Parameter : 
    //globalFieldTypeCasting : This variable holds the list of all field and label which we are going to show on sheet
    //selectedData : This holds user selected records from popup
    //comingWholeMapData : This variables holds all categories records
    //componentReference : This var holds the name of calling component
    //devFileName : Name of the file, which is used for downloading with same name
    @api serverDatamakingAsExportRecord(globalFieldTypeCasting, selectedData, comingWholeMapData, componentReference, devFileName){
        console.log('globalFieldTypeCasting ::: '+JSON.stringify(globalFieldTypeCasting));
        console.log('selectedData ::: '+JSON.stringify(selectedData));
        console.log('comingWholeMapData ::: '+JSON.stringify(comingWholeMapData));
        this.emptyAllrecords();
        this.createListOfObject(globalFieldTypeCasting);
        var storeMapData=globalFieldTypeCasting;
        this.filename = devFileName;
        this.createMapOfObjectFieldLabelNames(storeMapData);
        var allExportRecordsList = [];
        var wholeMapData=comingWholeMapData;
        var chooseData= selectedData;
        for(var l=0;l < chooseData.length; l++){
            var access1;
            var access2;
            console.log();
            access1=chooseData[l]["allCategoriers"];
            var g=0; 
            var  newformateData=[];
            var objectLabelName = chooseData[l]["object"].split(" ").join("").toLowerCase()+'Label';
            var objectFieldName = chooseData[l]["object"].split(" ").join("").toLowerCase()+'Field';
            var objectLabelData = this.ObjectLabelNameMap[objectLabelName];
            var objectFieldData = this.objectFieldNameMap[objectFieldName];
            //Check if fields records are exisits or not.
            if(objectLabelData){
                for( g=0;g<wholeMapData.length;g++){
                    access2 =wholeMapData[g]["allCategoriers"];
                    if(access1 == access2){
                        var listData=[];
                        listData=wholeMapData[g]['List'];
                        newformateData = this.replaceFieldNameWithLabelName(listData, objectLabelData, objectFieldData);
                    }
                }
                var AccountMap = {};
                var accountWholeData = {};
                newformateData = this.sortRecordsAsPerScreen(newformateData,objectLabelData);
                AccountMap['Header']= this.mapCheckKeysExistsWithLabel(newformateData, objectLabelData, 'headers');//this.ObjectLabelNameMap['AccountLabel'];
                AccountMap['Record']= this.mapCheckKeysExistsWithLabel(newformateData, objectLabelData, 'records');
                accountWholeData[access1] = AccountMap;
                allExportRecordsList.push(accountWholeData);
            }
        }
        for(var dt = 0; dt<allExportRecordsList.length;dt++){
            for(var single in allExportRecordsList[dt]){
                this.xlsFormatter(allExportRecordsList[dt][single].Header, allExportRecordsList[dt][single].Record, single);
            }
        }
        //this.template.querySelector("c-xlsx-main").download();
        if(allExportRecordsList.length > 0){
            this.download();
        }
        
    }

    sortRecordsAsPerScreen(newformateData, objectLabelData){
        var sortedArray = [];
        for(var i = 0;i<newformateData.length;i++){
            var sorterMap = {};
            for(var j=0;j<objectLabelData.length;j++){
                sorterMap[objectLabelData[j]] = newformateData[i][objectLabelData[j]];
            }
            sortedArray.push(sorterMap);
        }
        return sortedArray;
    }

    //This method will create new Map, which we want show in ExcelSheet and remove all unwanted records
    mapCheckKeysExistsWithLabel(objectRecords, listOfLabels, decisionStr){
        var exortsRecordsList = [];
        var labelNameList = [];
        for(var i =0;i<objectRecords.length;i++){
            var exportRecordsMap = {};
            for(var removeKey in objectRecords[i]) {
                if(listOfLabels.includes(removeKey)){
                    exportRecordsMap[removeKey] = objectRecords[i][removeKey];
                    //Check if record is exists in the list
                    if(!labelNameList.includes(removeKey)){
                        labelNameList.push(removeKey);
                    }
                }
            }
            exortsRecordsList.push(this.addDataWhichMissingInRecord(exportRecordsMap, listOfLabels));
        }

        if(decisionStr === 'records'){
            return exortsRecordsList;
        }else{
            return labelNameList;
        }
        
    }

    addDataWhichMissingInRecord(exortsRecordsList, listOfLabels){
        for(var i =0;i<listOfLabels.length;i++){
            if(typeof exortsRecordsList[listOfLabels[i]] === 'undefined'){
                exortsRecordsList[listOfLabels[i]] = ' ';
            }
        }
        return exortsRecordsList;
    }

    //This method will check for fieldName and replace that field name with Label Name
    replaceFieldNameWithLabelName(listData, labelNameList, fieldNameList){

        var newformateData = [];
        for(var j in listData){
            var convertString = JSON.stringify(listData[j]);
            for(var i=0;i<fieldNameList.length;i++){
                if(convertString.includes( fieldNameList[i])){
                    convertString = convertString.replace(fieldNameList[i],labelNameList[i]);
                }
            }
            if(convertString!='' || convertString!=null){
                newformateData.push(JSON.parse(convertString));
            }
        }
        return newformateData;
    }

    xlsFormatter(header, data, sheetName) {
        let Header = header;
        this.xlsHeader.push(Header);
        this.workSheetNameList.push(sheetName);
        this.xlsData.push(data);
    }


    download() {
        try{
           // const XLSX = window.XLSX;
            let xlsData = this.xlsData;
            let xlsHeader = this.xlsHeader;
            let ws_name = this.workSheetNameList;
            let createXLSLFormatObj = Array(xlsData.length).fill([]);
            //let xlsRowsKeys = [];
            /* form header list */
            xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])
            /* form data key list */
            xlsData.forEach((item, selectedRowIndex)=> {
                let xlsRowKey = Object.keys(item[0]);
                item.forEach((value, index) => {
                    var innerRowData = [];
                    xlsRowKey.forEach(item=>{
                        innerRowData.push(value[item]);
                    })
                    createXLSLFormatObj[selectedRowIndex].push(innerRowData);
                })
        
            });
            /* creating new Excel */
            //The book_new utility function creates an empty workbook with no worksheets.
            //Spreadsheet software generally require at least one worksheet and enforce the requirement in the user interface.
            // This library enforces the requirement at write time, throwing errors if an empty workbook is passed to write functions.
            var wb = XLSX.utils.book_new();

            /* creating new worksheet */
            var ws = Array(createXLSLFormatObj.length).fill([]);

            for (let i = 0; i < ws.length; i++) {
                /* converting data to excel format and puhing to worksheet */
                //Create a worksheet from an array of arrays of JS values
                //The aoa_to_sheet utility function walks an "array of arrays" in row-major order,
                // generating a worksheet object. The following snippet generates a sheet with cell A1 set to the string A1,cell B1 set to B1, etc:
                /*
                    var worksheet = XLSX.utils.aoa_to_sheet([
                        ["A1", "B1", "C1"],
                        ["A2", "B2", "C2"],
                        ["A3", "B3", "C3"]
                    ]);
                */
                let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
                ws[i] = [...ws[i], data];
                console.log('fitToColumn ::: '+JSON.stringify(this.fitToColumn(createXLSLFormatObj[i])))
                        //this.fitToColumn(createXLSLFormatObj);
                XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
            }
            /* Write Excel and Download */
            XLSX.writeFile(wb, this.filename,{cellStyles: true});
        }catch(err){
            console.log('Error JOSN::: '+JSON.stringify(err));
            console.log('Error ::: '+err);
        }
    }
    fitToColumn(arrayOfArray) {
        // get maximum character of each column
        return arrayOfArray[0].map((a, i) => ({ wch: Math.max(...arrayOfArray.map(a2 => a2[i] ? a2[i].toString().length : 0)) }));
    }

}