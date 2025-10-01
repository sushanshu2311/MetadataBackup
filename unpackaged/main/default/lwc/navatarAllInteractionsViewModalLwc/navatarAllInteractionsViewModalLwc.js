/****************************************************************************************************

** Module Name : View Popup

** Description : Show all fields and attach files on page

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity 3.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        
** 2.0        2024-02-02          Sudhanshu       Changes for Custom fields 
** 2.1        2024-02-27          Sudhanshu       Changes for Delete Notes functionality
** 2.2        2024-04-11          Deepak          Changes for View Notes on blank screen
****************************************************************************************************/

import { LightningElement, track, api,wire } from 'lwc';
import handleInteractionsInfo from '@salesforce/apex/NavatarAcuityCtrl.handleInteractionsInfo';
import getFileList from '@salesforce/apex/NavatarAcuityCtrl.getFileList';
import { NavigationMixin } from 'lightning/navigation';
/* Added the below line by Lakshya on 2023-11-03 to check if activity is archived or, not (00043006) */
import checkActivityArchivedState from '@salesforce/apex/NavatarNotesModalCtrl.checkActivityArchivedState';
/* Added the below line by Lakshya on 2023-11-03 to display toast message (00043006) */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSearchableObjName from '@salesforce/apex/NavatarAcuityCtrl.getSearchableObjName';
// import TASK_OBJECT from '@salesforce/schema/Task';
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getTaskLabel from '@salesforce/apex/NavatarAcuityCtrl.getTaskLabel';
import getEventLabel from '@salesforce/apex/NavatarAcuityCtrl.getEventLabel';
import checkArchiveData from '@salesforce/apex/NavatarAcuityCtrl.checkArchiveData';
import deleteActivity from '@salesforce/apex/NavatarAcuityCtrl.deleteActivity';
import checkDeleteAccess from '@salesforce/apex/NavatarNotesModalCtrl.checkDeleteAccess';
import deleteAttachment from '@salesforce/apex/NavatarAcuityCtrl.deleteAttachment';
import { CurrentPageReference } from 'lightning/navigation';
//Rich Textarea Requirement - Sudhanshu
import checkRichTextDesp from '@salesforce/apex/NavatarNotesModalCtrl.checkRichTextDesp';



export default class NavatarAllInteractionsViewModalLwc extends NavigationMixin(LightningElement) {
    @track isModalOpenview = false;
    @track mySlideV;
    @track filesDisplay = false;
    @track indexMap ={'minIndex':0,'maxIndex':0,'currentIndex':0};
    @track prevdisableButtonMock = true;
    @track nextDisableButtonMock = true;
    @track tagDataList =[];
    @track tagDataList1 =[]; //for smoke round testing critical bug 00035293 -->
    @api gridDataList = [];
    @track selectedData = {};
    @track openEditModal = false;
    @track showLeftRightChangeArrow = true;
    @track callComponentnFunctionality = 'view';
    @track fileDataList = [];
    @track isAttachment = false;
    ////////////////////////////////////
    @track searchableObjectStr;
    @track taskLayoutFields = '';
    @track eventLayoutFields = '';
    @track textareahight = 0;
    @track followTaskLayoutFields = '';
    @track taskLayoutFields = '';
    @track actSubType = '';
    isRedirectToRecord = false;
    redirectToParent = true;
    recId;  //Activity ID
    objType;    //Activity object API name (Task/Event)
    openSuggestedTag = false;
    isTask = false;
    isCall = false;
    displayClipIcon = false;
    displayActDate = false;
    displayDate = false;
    directlyOpenSuggestedTag = false;
    isInfoMessage = false;  //Changes for View Notes on blank screen
    @track taskOtherField='';
    @track eventOtherField='';
    @api objectLabel='';
    @track taskLable= new Map();
    @track eventLable= new Map();
    redirectId;//Manonit
    displayFileEditDelButton = true; // Added to hide or display buttons in view modal on the basis of type of activity
    

    // @wire(getObjectInfo, { objectApiName: TASK_OBJECT })
    // oppInfo({ data, error }) {
    //     if (data)
    //     {
    //         alert(data);
    //         this.objectLabel=data;
    //     }
    // }

    connectedCallback(){
          this.getOtherField();
          this.getTaskFieldLable();
          this.getEventFieldLable();
    }

    /* Added below method by Sudhanshu on 2024-01-01 to get Custom Field Label */
    getOtherField(){
        getSearchableObjName().then(data=>{
            this.taskOtherField=data[0];
            this.eventOtherField=data[1];
            this.taskOtherField= this.taskOtherField.split(',');
            this.eventOtherField= this.eventOtherField.split(',');
        })
        .catch((err=>{
        }))
    }

    isUrl = false;
    // To open View Component with Blank background
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('118')
        if (currentPageReference && currentPageReference.state.hasOwnProperty('c__params')) {
            this.urlParamsMap = JSON.parse(currentPageReference.state.c__params);
            console.log('121',this.urlParamsMap['recId'],)
            if(this.urlParamsMap != null){
                this.isUrl = true;
                this.openModalSingleComponent(this.urlParamsMap['recId'], this.urlParamsMap['recType'], this.urlParamsMap['mode']);
            }
        }
    }


    /* Added below method by Sudhanshu on 2024-01-01 to get Task Field Label */
    getTaskFieldLable(){
        getTaskLabel().then(data=>{
            // this.taskLable=data;

            for (let key in data) {
               
                this.taskLable.set(key,data[key]);
             }
             
        })
        .catch((err=>{
        }))
    }

    /* Added below method by Sudhanshu on 2024-01-01 to get Event Field Label */
    getEventFieldLable(){
        getEventLabel().then(data=>{
            // this.taskLable=data;

            for (let key in data) {
               
                this.eventLable.set(key,data[key]);
             }
             
        })
        .catch((err=>{
        }))
    }

    customFieldinfo ={};
    /* Added below method by Sudhanshu on 2024-01-01 to Set Custom Field Label & Value  */
    setCustomFieldValue(event){

        if(this.isTask == true)
        {
            this.setFieldValue(this.taskOtherField, event, this.taskLable);
            
        }
        else if(this.isCall == true){
            this.setFieldValue(this.taskOtherField, event, this.taskLable);
           
        }
        else{
            this.setFieldValue(this.eventOtherField, event, this.eventLable);
            
        }

    }
    aMap = [];
    

    setFieldValue(fieldList,event,labelList){
        this.customFieldinfo =[];
        this.aMap=[];
        let isLeftField=false;
        let isRightField = false;
        let count=1;
        let key=0;
        let j=-1;       // Bug 00045508 fix by Sudhanshu on 09-05-2024
        for(let i=0; i<fieldList.length; i++)
        {
            // this.aMap[key] = this.aMap[key] || [];
            // this.aMap[key].push({label:labelList.get(fieldList[i]),value:event.actInfo[fieldList[i]]});
            

            if(event.actInfo[fieldList[i].replace('__c','__r')]!= null)
            {
                // Bug 00046116,45381 fixed by Sudhanshu 28-06-2024
                const [, fieldType] = labelList.get(fieldList[i]).split('@@@');     
                const [fieldLabel] = labelList.get(fieldList[i]).split('@@@');
                let recName = fieldList[i].replace('__c','__r');
                let fieldRec=event.actInfo[recName];
                console.log('ActInfo==>'+JSON.stringify(fieldRec.Name));
                if(labelList.has(fieldList[i]))      // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
                {
                    j++;    // Bug 00045508 fix by Sudhanshu on 09-05-2024
                    if(count != key)
                    {
                        this.aMap.push({key:key,label1:fieldLabel,value1:fieldRec.Name, checkbox1:fieldType ==='BOOLEAN' ? true: false, textarea1:fieldType ==='TEXTAREA' ? true: false,label2:'',value2:'',checkbox2:'',textarea2:''});
                    }
                    else
                    {
                        const objIndex = this.aMap.findIndex(item => item.key === key);
                        if (objIndex !== -1) {
                            this.aMap[objIndex]['label2'] = fieldLabel;
                            this.aMap[objIndex]['value2'] = fieldRec.Name;
                            this.aMap[objIndex]['checkbox2'] = fieldType ==='BOOLEAN' ? true: false;
                            this.aMap[objIndex]['textarea2'] = fieldType ==='TEXTAREA' ? true: false;
                            // Trigger re-rendering to reflect the updated value
                            this.aMap = [...this.aMap];
                        }
                    }
                    
                    count = key;     // Bug 00045508 fix by Sudhanshu on 09-05-2024  
                }
            }
            else{
                if(labelList.has(fieldList[i]))      // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
                {
                    const [, fieldType] = labelList.get(fieldList[i]).split('@@@');
                    const [fieldLabel] = labelList.get(fieldList[i]).split('@@@');
                    console.log('ActInfo==>'+JSON.stringify(event.actInfo[fieldList[i]]));
                    j++;        // Bug 00045508 fix by Sudhanshu on 09-05-2024
                    if(count != key)    
                    {
                        this.aMap.push({key:key,label1:fieldLabel,value1:event.actInfo[fieldList[i]],checkbox1:fieldType ==='BOOLEAN' ? true: false,textarea1:fieldType ==='TEXTAREA' ? true: false,label2:'',value2:'',checkbox2:'',textarea2:''});
                    }
                    else{
                        const objIndex = this.aMap.findIndex(item => item.key === key);
                        if (objIndex !== -1) {
                            this.aMap[objIndex]['label2'] = fieldLabel;
                            this.aMap[objIndex]['value2'] = event.actInfo[fieldList[i]];
                            this.aMap[objIndex]['checkbox2'] = fieldType ==='BOOLEAN' ? true: false;
                            this.aMap[objIndex]['textarea2'] = fieldType ==='TEXTAREA' ? true: false;
                            // Trigger re-rendering to reflect the updated value
                            this.aMap = [...this.aMap];
                        }
                    }
                    count = key;    // Bug 00045508 fix by Sudhanshu on 09-05-2024
                }
            }
            
            if(j % 2 != 0 ){        // Bug 00045508 fix by Sudhanshu on 09-05-2024
                key++;
            }
        }
        // fieldList.forEach(rec=>{
        //     if( count % 2 != 0 ){
        //         isLeftField = false;
        //         isRightField= true;
        //     }else{
        //         isLeftField = true;
        //         isRightField = false;
        //     }
            
            // if(event.actInfo[rec.replace('__c','__r')]!= null)
            // {
            //     let recName = rec.replace('__c','__r');
            //     let fieldRec=event.actInfo[recName];
            //     console.log('ActInfo==>'+JSON.stringify(fieldRec.Name));
            //     if(labelList.has(rec))      // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
            //     {
            //         this.customFieldinfo.push({key:labelList.get(rec),value:fieldRec.Name,isLeftField:isLeftField,isRightField:isRightField});
            //         count= count+1;
            //     }
            // }
            // else{
            //     if(labelList.has(rec))      // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
            //     {
            //         this.customFieldinfo.push({key:labelList.get(rec),value:event.actInfo[rec],isLeftField:isLeftField,isRightField:isRightField});
            //         count= count+1;
            //     }
            // }
            this.customFieldinfo = this.aMap;
            console.log('Data ==>>'+JSON.stringify(this.aMap));

        // });
    }
    isRichTxtEnable = false;
    richTxtDescription = '';
    // method for check Rich Text Area Field enable or not
    checkRichTextDespEnable(recordID){
        this.richTxtDescription = ''; // Bug 00047405 Fixed By Sudhanshu 
        checkRichTextDesp({
            recordId : recordID
        })
            .then(data => {
                this.isRichTxtEnable = data[0].isRichText === 'true' ? true : false;
                if(recordID != null && recordID != '' && this.isRichTxtEnable){
                    this.richTxtDescription = data[0].richDescription == '' ? this.selectedData.detail.replaceAll('\n','<br>') : data[0].richDescription ;
                }
                
            })
            .catch(error => {
                // this.displayError(error);
            });
    }

    
    @api
    openModalNew(selectedDataOpen, gridDataListLocal,redirectId) {
        if(gridDataListLocal == [] || !gridDataListLocal.length || gridDataListLocal.length == 0){
            this.showLeftRightChangeArrow = false;
        } else {
            this.gridDataList = JSON.parse(JSON.stringify(gridDataListLocal));
            this.indexMap.maxIndex = this.gridDataList.length-1;
        }
        if(redirectId != null && redirectId != '');
        this.redirectId=redirectId;//Manonit Bug Fix 00045538
        console.log('@@@@ManoRedirect',this.redirectId);
        console.log('line 44'+JSON.stringify(selectedDataOpen));
        this.actSubType = selectedDataOpen.type;
        //Added By Harshwardhan on 26 March,2023 for List Email Condition
        if((this.actSubType == 'List Email')){
            this.displayFileEditDelButton = false;         
        }  
        else{
            this.displayFileEditDelButton = true;         //Manonit List Emai Change for other activity type
        } 
        this.setSelectedDataForScreen(selectedDataOpen);
        this.setCustomFieldValue(selectedDataOpen);    /* Added by Sudhanshu on 2024-01-01   */
        this.isModalOpenview = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpenview = false;
        this.isInfoMessage = true;//Phase 3 - CR

        this.currentindexno = 0; 
        this.i = 0;
        this.getdisabled = false;
        this.prevdisableButton = true;
        this.currentindex = 0;
        const ev = new CustomEvent("navigatebacktoparentscreen");   /*Manonit Change */
                    this.dispatchEvent(ev);
        /* for caousel reset*/  
    }
  
    handleNoteClickTaskview(event){ 
        /* Added below method and moved existing code in else condition by Lakshya on 2023-11-03 to display warning when editing archived activity */
        let activityId = this.selectedData.hasOwnProperty('actId') ? this.selectedData.actId : this.selectedData.subjRef.substring(1);
        checkActivityArchivedState({
            activityId : activityId,
            activityType : activityId.slice(0, 3) === '00T' ? 'Task' : 'Event'
        })
        .then(res=>{
            if(res === 'true'){
                //Modified the toast mode to "dismissable" on 2023-11-06 to fix the issue (00043006)
                // Bug 00046851,00047232 fixed by Sudhanshu on 24-07-2024
                this.showToast(this, 'Error', 'You do not have permission to edit Archived records. Please contact your Navatar Administrator.', 'error', 'dismissible');
            } else {
                this.isModalOpenview = false;
                this.openEditModal = true;
                this.recId = this.selectedData.hasOwnProperty('actId')
                            ? this.selectedData.actId
                            : this.selectedData.subjRef.substring(1);
                this.objType = this.selectedData.type;
                this.openSuggestedTag = false;
            }
        })
        .catch((err=>{
            this.showToast(this, 'Error!', err, 'error', 'sticky');
        }))
    }

    /* Added below method by Lakshya on 2023-11-03 to display toast message (00043006) */
    showToast(cmp, title, message, variant, mode){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        cmp.dispatchEvent(event);
    }

    /* Carousel*/ 
     currentindexno = 0; 
     i = 0;
     @track getdisabled = false;
     @track prevdisableButton = true;
     @track currentindex = 0;
     
    /* Carousel*/ 
    filesDisplayclick(event){
        this.filesDisplay = true;
     }
    
     renderedCallback(){
    this.textAreaField = this.template.querySelector('[data-id="textAreaId"]'); 
    if(this.textAreaField != null){        
        this.textAreaField.style.height = "auto";
        this.textAreaField.style.height = this.textAreaField.scrollHeight + "px";
    }
         const style = document.createElement('style');
         style.innerText = `.arrowBtn .slds-button__icon{
            height: 30px;
            width: 30px;
         }

         /*00044967,00045682 fixed by raju on  09-05-2024 */
         .nocross .slds-pill__remove{
            display: none !important;
         }
         /*00047522 fixed by raju on dated 22-10-2024*/        
         .my-pill .slds-pill {
            max-width: 200px !important;
         }

         .arrowBtn .slds-button:focus{
            box-shadow:none !important;
            border:none !important;
            outline: none!important;
         } 

         .attatchedFileCls .slds-pill__label {
            color: #666 !important;
            cursor: auto !important;
         }

         .attatchedFileCls .slds-pill {
            background-color: #F3F3F3 !important;
         }  
         
         .clsForButtonSize .slds-button__icon {
            width: 1.1rem !important;
            height: 1.1rem !important;
         }
         .clsRemoveCrossIcon .slds-pill__remove {
            display: none !important;
         }
         .clsDelete button.slds-button_icon-brand{
            background-color: #c23934 !important;
            border: 1px solid #c23934 !important;
         }
         .clsDelete button.slds-button_icon-brand:hover{
            background-color: #a61a14 !important;
            border: 1px solid #a61a14 !important;
         }
        .noteareacssinteractions textarea.slds-textarea{
            border: none !important;
            padding: 0px 0px;
            box-shadow: none;
            background-color: inherit;
            resize: none;
            height: ${this.textareahight}px;

          }
        .noteareacssinteractions .slds-form-element__label:empty{
             display: none;
          }
          .slds-file-selector__dropzone{
            padding: 0;
        }
        .slds-file-selector__body{
           max-width: 36px;
           overflow-x: hidden;
           white-space: nowrap;
           max-height: 28px;
           overflow: hidden;
           justify-content: start;
           gap: 15px;
           border: 1px solid #ddd;
           cursor: pointer;
        }
        .slds-file-selector__button{
           padding-left:10px;
        }
        .topic2 .slds-form-element__label{
            display: none;
        }
         `;
         try {
             this.template.querySelector('.main-container').appendChild(style);
         } catch (err) {
         }
     }

     setSelectedDataForScreen(selectedDataLocal) {
        const taskSubType = ["Call", "Email", "List Email"];
        this.isTask = selectedDataLocal.type == 'Task'?true:false;
        this.isCall = taskSubType.includes(selectedDataLocal.type) ? true : false;  // Bug 00045800 fixed by Sudhanshu on 24-05-2024
        
        // Bug 00046720,00046721 fixed by Sudhanshu on 19-07-2024
        if((selectedDataLocal.type == 'List Email')){
            this.displayFileEditDelButton = false;         
        }
        else{
        this.displayFileEditDelButton = true;         
        }
        console.log('selectedDataLocal'+JSON.stringify(selectedDataLocal));
        this.selectedData = selectedDataLocal; 
        this.recId = this.selectedData.hasOwnProperty('actId')
                            ? this.selectedData.actId
                            : this.selectedData.subjRef.substring(1); 
        this.checkRichTextDespEnable(this.recId);

        // UI fix critical 00038072 1 march
        setTimeout(() => {   
            let textar = this.template.querySelector(".txtar");
            textar.value = this.selectedData.detail;
            console.log(25+textar.scrollHeight,"scoll90909");
            if(25+textar.scrollHeight<100){
                this.textareahight = 100;
            }
            else if(25+textar.scrollHeight>286){
                this.textareahight = 286;
            }
            else{
                this.textareahight = 25+textar.scrollHeight;
            }
            this.renderedCallback();
        }, 0);
           // UI fix critical 00038072 1 march

        if(selectedDataLocal.type == 'Task'){
            this.selectedData.iconName = 'standard:task';
        }  
        else if(selectedDataLocal.type == 'Event'){
            this.selectedData.iconName = 'standard:event';
        } 
        else if(selectedDataLocal.type == 'Email'){
            this.selectedData.iconName = 'standard:email';
        }
        
        if(this.selectedData.hasOwnProperty('actDate')){
            this.displayActDate = true;
        } else {
            this.displayDate = true;
        }
        this.displayActDate = true;
        let actId = this.selectedData.hasOwnProperty('actId')
                    ? this.selectedData.actId
                    : this.selectedData.subjRef.substring(1);
        this.setFileData(actId)// take the record Id
        //Add if condition for handling date
        this.indexMap.currentIndex = parseInt(this.selectedData.index);
        this.prevdisableButtonMock = (this.selectedData.index == this.indexMap.minIndex);
        this.nextDisableButtonMock = (this.selectedData.index == this.indexMap.maxIndex);
        var tagsData = this.selectedData.tagsInfo|| this.selectedData.references;
        if(this.selectedData.tagsInfo){
            tagsData = tagsData.concat(this.selectedData.participantsInfo);
        }
        if(this.selectedData.references){
            tagsData = tagsData.concat(this.selectedData.attendees);
        }
       // tagsData = tagsData.;
        var sortTagData = [];
        var sortValue = 1;
        var mapTagValue = new Map();
    var isThemeTagList = false; //Added by Tejaswini - 00034978
        tagsData.forEach(element => {
            //sortValue = element.sortValue;
            if(element.sortValue!= undefined){
                if(mapTagValue.has(element.sortValue)){
                   
                    mapTagValue.set(element.sortValue, mapTagValue.get(element.sortValue).concat(element));
                }
                else{
                    var ele = [];
                    ele.push(element);
                    mapTagValue.set(element.sortValue, ele);
                }
            }
        //Added by Tejaswini - 00034978
        else if(element.sortValue== undefined) {	
            isThemeTagList = true;
        }

        });
    //Added by Tejaswini - 00034978
    if((tagsData !='' || tagsData!= undefined)&& isThemeTagList) {	
        this.setTagData(tagsData)
    }
    else{
        var sortTag =[];
        //Added by anurag as part of 35156
        for (let i = 1; i <= 8; i++) {
            if(mapTagValue.has(i)){
                sortTag = sortTag.concat(mapTagValue.get(i));
            }
            
          }
          if(sortTag !='' || sortTag!= undefined) {
            this.setTagData(sortTag)
        }
     } 
     } 

     setFileData(activityId) {
        this.isLoading = true;
        this.fileDataList = [];
        getFileList({
            activityId : activityId
        })
        .then(res=>{
            console.log('res=> '+JSON.stringify(res));
            if(res.length === 0){
                console.log('no attachment found');
                this.isAttachment = false;
            }
            else{
                this.isAttachment = true;
            }
            this.fileDataList = res;
            this.displayClipIcon = this.fileDataList.length > 0;
            this.isLoading=false;
        })
        .catch((err=>{
            console.log('557',err)
            this.isLoading=false;
        }))
     }

     setTagData(tagData) {
        this.tagDataList = [];
        this.tagDataList = tagData;
        this.tagDataList1=[]; //for smoke round testing critical bug 00035293 -->
        for(let x=0;x<this.tagDataList.length;x++){
        this.tagDataList1[x]=this.tagDataList[x];
        if(this.tagDataList[x].iconName==="standard:user"){ // For resolving smoke round package issue bug 00039301
            this.tagDataList1[x].isuser=true;
        }
        else{
            this.tagDataList1[x].isuser=false;
        }
    }
    console.log('this.tagDataList'+JSON.stringify(this.tagDataList1));   
     }

     prevslidemock(evt) {
        var currentIndexLocal = this.indexMap.currentIndex - 1;
        if(currentIndexLocal >= this.indexMap.minIndex) {           
            this.setSelectedDataForScreen(this.getIndexedRecord(currentIndexLocal));
            this.setCustomFieldValue(this.getIndexedRecord(currentIndexLocal)); /* Added by Sudhanshu on 2024-01-01   */
        }
     }

     nextslidemock(evt) {
        var currentIndexLocal = this.indexMap.currentIndex + 1;
        if(currentIndexLocal <= this.indexMap.maxIndex) {
            this.setSelectedDataForScreen(this.getIndexedRecord(currentIndexLocal));
            this.setCustomFieldValue(this.getIndexedRecord(currentIndexLocal));     /* Added by Sudhanshu on 2024-01-01   */
        }

     }

     getIndexedRecord(index) {
        var indexedData = {};
        for(var d in this.gridDataList) {
            if(this.gridDataList[d].index == index) {
                indexedData = this.gridDataList[d];
                break;
            }
        }
        return indexedData;

     }

     @api
     openModalSingleComponent(recordId, objectType, componentName) {
        // Bug 44986 fixed by sudhanshu 18-04-2024
        if(this.isUrl){
          this.getOtherField();
          this.getTaskFieldLable();
          this.getEventFieldLable();
        }
        this.showLeftRightChangeArrow = false;
        this.callComponentnFunctionality = componentName;
        if(this.callComponentnFunctionality !== 'view'){
            this.handleNoteEdit(recordId, objectType, componentName);
        } else {
            let nameSpaceprefix = 'navpeII_dev18__';
            let activityRecIdList = [];
            activityRecIdList.push(recordId);//00T8I000004rgvqUAA'
            // Bug 00047632 Fixed By Sudhanshu on 30-05-2025
            handleInteractionsInfo({
                namespacePrefix : nameSpaceprefix,
                actIdList : activityRecIdList,
                isAcuity : false
            })
            .then(res => {
                console.log('res res',res);
                if(res.length > 0){
                this.isModalOpenview = true;
                let recordWrapper = {};
                recordWrapper = JSON.parse(JSON.stringify(res[0]));
                if(recordWrapper.hasOwnProperty('actDate')){
                    recordWrapper.date = recordWrapper.actDate;
                }
                this.actSubType = res[0].type;//Added By Harshwardhan on 26 March,2023 for List Email Condition
                if((this.actSubType == 'List Email')){
                    this.displayFileEditDelButton = false;         
                }
                else{
                this.displayFileEditDelButton = true;      // Manonit change for Other Activity SubType   
                }
                
                this.selectedData = {};
                recordWrapper.index = 0;
                this.setSelectedDataForScreen(recordWrapper);
                this.setCustomFieldValue(recordWrapper);// changed MERGED CODE
                this.showLeftRightChangeArrow = false;
                }else{
                    this.isModalOpenview = false;   
                    this.isInfoMessage = true;//Phase 3 - CR
                }
            })
            .catch(err =>{
            })
        }
        
     }

     handleTagDataClick(ev){
        let dataId = ev.currentTarget.dataset.id;
        window.open(dataId, "_blank");
     }

    handleNoteEdit(recordId, objectType, componentName){
        this.recId = recordId;
        this.objType = objectType;
        this.openEditModal = true;
        this.openSuggestedTag = componentName === 'addTag';
        this.directlyOpenSuggestedTag = componentName === 'addTag';
    }

    noteModalClosed(){
        this.openEditModal = false;
        console.log('@@@@@@567 view')
        this.isInfoMessage = true;//Phase 3 - CR
    }

    handleCloseModal() {
        this.noteModalClosed();
        console.log('@@@@@@570 view')
        this.isInfoMessage = true;//Phase 3 - CR
    }

    handleFilePreview(evt) {
        //alert(evt.currentTarget.dataset.id)
        let versionId = evt.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview',
                recordId: versionId,
                objectApiName: 'ContentVersion',
                actionName: 'view',
            },
            state : {
                selectedRecordId: versionId
            }
        });
    }

     // ---------------Delete Note Functionality Start---------------------

    @track isLoading = false;
    handleClickDelete(){
        // this.isModalOpenview = false;
        // this.isDelete = true;
        this.isLoading = true;
        checkArchiveData({recordId : this.recId})
            .then(data => {
                if(data){
                    this.isLoading = false;
                    // Bug 00045774 Fixed by Sudhanshu on 17-05-2024
                    const errorToast = new ShowToastEvent({title: 'Error', message: 'You do not have permission to delete Archived records.Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(errorToast);
                }else{
                    
                    this.isLoading = false;
                    this.isModalOpenview = false;
                    this.isDelete = true;

                    // const modalPopup = this.template.querySelector('c-navatar-Delete-Ineraction-Modal-Lwc');
                    // modalPopup.openModal();
                }
            })
            .catch(error => {
                this.isLoading = false;
                const errorToast = new ShowToastEvent({title: 'Error', message: error,variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(errorToast);
            });
    }

 
    @track isDelete = false;
    // @api subject = '' ;

    // @api
    // openModal(){
    //     this.isDelete = true;
    // }
    // checkUserAccess(){
    //     this.isLoading = true;
    //     checkDeleteAccess({recordId : this.recId})
    //         .then(data => {
    //             if(data){
    //                 this.isDeleteAccess = true;
    //                 this.handleDeleteNote();
    //             }else{
    //                 this.isDelete = false;
    //                 this.isDeleteAccess = false;
    //                 this.isLoading = false;
    //             }
    //         })
    //         .catch(error => {
    //             this.isLoading = false;
    //             const errorToast = new ShowToastEvent({title: 'Error', message: error,variant: 'error',mode: 'dismissable'});
    //             this.dispatchEvent(errorToast);
    //         });
    // }

    @track isDeleteAccess=true;
    @track isLoading=false;
    handleDeleteNote(){
        this.isLoading = true;
        deleteActivity({
            actId : this.recId
        })
        .then(res => {
            // Bug 00046263 fixed by Sudhanshu on 03-07-2024
            const successToast = new ShowToastEvent({title: 'Success', message: '"'+this.selectedData.subject+'" was deleted.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(successToast);
            this.isLoading = false;
            this.isDelete = false;
            window.location.reload();
        })
        .catch(err =>{
            this.isLoading = false;
            if(err.body.message.includes('INSUFFICIENT_ACCESS_OR_READONLY'))
            {
                // this.isDelete = false;      // Bug 00044969 fixed by Sudhanshu on 27-05-2024
                // this.isDeleteAccess = false;
                // Bug 00044443 Fixed on 01-04-2024 by sudhanshu
                const event = new ShowToastEvent({title: 'Error',message:'There\'s a problem saving this record. You might not have permission to edit it, or it might have been deleted or archived. Contact your administrator for help.',variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(event);
                this.isLoading = false;
            }
            else
            {
                const event = new ShowToastEvent({title: 'Error',message:err.body.message,variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(event);
            }          
        })
    }

    closeDelete(){
        this.isModalOpenview = true;    // Bug 00047681 fixed by Sudhanshu on 07-10-2024
        this.isDelete = false;
        this.isInfoMessage = true;//Phase 3 - CR Bug - 00044605
    }

    closeAccessModal(){
        this.isDeleteAccess = true;
    }

    get acceptedFormats() {
        return [];
    }

    // Method added by sudhanshu 13-03-2024 for handle file upload
    handleUploadFinished(event) {
        // Get the list of uploaded files
        // const uploadedFiles = event.detail.files;

        this.filesList = event.detail.files;
        this.isLoading = true;
        this.setFileData(this.recId);
        // Success message added by sudhanshu on 12-04-2024
        if(this.filesList.length == 1)
        {
            const event = new ShowToastEvent({title: 'Success',message:this.filesList.length+' File was added to Interaction.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(event);
        }
        if(this.filesList.length > 1)
        {
            const event = new ShowToastEvent({title: 'Success',message:this.filesList.length+' Files were added to Interaction.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(event);
        }
        this.isLoading = false;
        console.log("No. of files uploaded : " + this.filesList.length);
    }

    @track isDeleteAttachment = false;
    @track fileId = '';
    @track filesList
    @track fileName = '';

    // method added by sudhanshu for handle Delete attachment 18-03-2024
    onDeleteAttachment(){
        // this.fileId = event.currentTarget.dataset.id;
        this.fileName= '';
        this.isLoading = true;
        this.fileDataList .forEach(rec=>{
            if(rec.contentDocumentId == this.fileId )
            {
                this.fileName = rec.title;
            }
        });
        deleteAttachment({
            fileId : this.fileId
        })
        .then(res => {
            // bug 00045444 fixed by sudhanshu on 16-05-2024
            const successToast = new ShowToastEvent({title: 'Success', message: 'File "'+this.fileName+'" was deleted.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(successToast);
            this.isLoading = false;
            this.setFileData(this.recId);
            this.closeAttachment();
        })
        .catch(err =>{
            this.isLoading = false;
           
                if(err.body.message.includes('INSUFFICIENT_ACCESS_OR_READONLY'))
                {
                    const event = new ShowToastEvent({title: 'Error',message: 'You do not have permission to delete this file. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }
                else
                {
                    const event = new ShowToastEvent({title: 'Error',message:err.body.message,variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }            
        })
    }

    // method added by Sudhanshu for open delete attachment popup
    handleAttachment(event){
        event.preventDefault();
        this.fileId = event.currentTarget.dataset.id; // Bug 00048153 fixed by Sudhanshu
        checkArchiveData({recordId : this.recId})
            .then(data => {
                if(data){
                    // this.isLoading = false;
                    // Bug 00047890 Fixed by Sudhanshu
                    // Bug 00047955 fixed by Sudhanshu on 13-11-2024
                    const errorToast = new ShowToastEvent({title: 'Error', message: 'You do not have permission to delete file on Archived records. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(errorToast);
                }else{
                    
                    
                    this.isDeleteAttachment = true;
                    this.isModalOpenview = false;
                }
            })
            .catch(error => {
                this.isLoading = false;
                const errorToast = new ShowToastEvent({title: 'Error', message: error,variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(errorToast);
            });

        
    }

    // method Added by Sudhanshu for close Delete attachment popup
    closeAttachment(){
        this.isDeleteAttachment = false;
        this.isModalOpenview = true;
    }
}