/*
** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 2.0        2024-03-20          Manonit          Flexible Mobile UIAttachment on Mobile
** 2.1        2024-04-02          Manonit          View Attachment on Mobile
*/


import { LightningElement, track, api, wire } from 'lwc';
import handleInteractionsInfo from '@salesforce/apex/NavatarAcuityCtrl.handleInteractionsInfo';
import getFileList from '@salesforce/apex/NavatarAcuityCtrl.getFileList';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getTaskLabel from '@salesforce/apex/NavatarAcuityCtrl.getTaskLabel';
import getEventLabel from '@salesforce/apex/NavatarAcuityCtrl.getEventLabel';
import getSearchableObjName from '@salesforce/apex/NavatarAcuityCtrl.getSearchableObjName';
import deleteAttachment from '@salesforce/apex/NavatarAcuityCtrl.deleteAttachment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import checkArchiveData from '@salesforce/apex/NavatarAcuityCtrl.checkArchiveData';
import deleteActivity from '@salesforce/apex/NavatarAcuityCtrl.deleteActivity';
import { RefreshEvent } from 'lightning/refresh';
import checkActivityArchivedState from '@salesforce/apex/NavatarNotesModalCtrl.checkActivityArchivedState';

//Rich Textarea Requirement - Sudhanshu
import checkRichTextDesp from '@salesforce/apex/NavatarNotesModalCtrl.checkRichTextDesp';

export default class NavatarAllInteractionsViewModalMobileLwc extends NavigationMixin(LightningElement) {
    @track isModalOpenview = false;
    @track mySlideV;
    @track filesDisplay = false;
    @track indexMap ={'minIndex':0,'maxIndex':0,'currentIndex':0};
    @track prevdisableButtonMock = true;
    @track nextDisableButtonMock = true;
    @track tagDataList =[];
    @track tagDataList1 =[]; //for smoke round testing critical bug 00035293
    @api gridDataList = [];
    @track selectedData = {};
    @track openEditModal = false;
    @track showLeftRightChangeArrow = true;
    @track callComponentnFunctionality = 'view';
    @track fileDataList = [];
    @track isAttachment = false ;
    @track redirectId = '';
    isRedirectToRecord = false;
    redirectToParent = true;
    recId;  //Activity ID
    objType;    //Activity object API name (Task/Event)
    openSuggestedTag = false;
    displayActDate = false;
    displayDate = false;
    isTask = false;
    isCall=false;
    displayEditButton = true; // Added to hide or display buttons in view modal on the basis of type of activity
    isShowAttatchedFile=true;
    @track taskOtherField='';
    @track eventOtherField='';
    @api objectLabel='';
    @track taskLable= new Map();
    @track eventLable= new Map();
    enableSpinner=true;
    connectedCallback(){
        //this.getOtherField();
        //this.getTaskFieldLable(); 
        //this.getEventFieldLable();
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

  customFieldinfo =[];
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

  setFieldValue(fieldList,event,labelList){
      this.customFieldinfo =[];
      let isLeftField=false;
      let isRightField = false;
      let count=0;
      fieldList.forEach(rec=>{
        
        /*  if( count % 2 != 0 ){
              isLeftField = false;
              isRightField= true;
          }else{
              isLeftField = true;
              isRightField = false;
          }
          */
       
          if(event.actInfo[rec.replace('__c','__r')]!= null)
          {  
              const [, fieldType] = labelList.get(rec).split('@@@');    
              const [fieldLabel] = labelList.get(rec).split('@@@');
              let recName = rec.replace('__c','__r');
              let fieldRec=event.actInfo[recName];
              console.log('ActInfo==>'+JSON.stringify(fieldRec.Name));
              if(labelList.has(rec))      // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
              {
                  //this.customFieldinfo.push({key:labelList.get(rec),value:fieldRec.Name,isLeftField:isLeftField,isRightField:isRightField});
                  this.customFieldinfo.push({key:fieldLabel,value:fieldRec.Name,checkbox:fieldType ==='BOOLEAN' ? true: false, textarea:fieldType ==='TEXTAREA' ? true: false});

                  
                //   count= count+1;
              }
          }
          else{
             if(labelList.has(rec))      // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
              {    const [, fieldType] = labelList.get(rec).split('@@@');    
                   const [fieldLabel] = labelList.get(rec).split('@@@');
                  //this.customFieldinfo.push({key:labelList.get(rec),value:event.actInfo[rec],isLeftField:isLeftField,isRightField:isRightField});
                  this.customFieldinfo.push({key:fieldLabel,value:event.actInfo[rec],checkbox:fieldType ==='BOOLEAN' ? true: false, textarea:fieldType ==='TEXTAREA' ? true: false});
                  
                //   count= count+1;
              }
          }
          
          console.log('Data ==>>'+this.customFieldinfo);

      });
      
  }

    isRichTxtEnable = false;
    richTxtDescription = '';
    // // method for check Rich Text Area Field enable or not
    checkRichTextDespEnable(recordID){
        this.richTxtDescription = '';   // Bug 00047742 ; 00048178 fixed by Sudhanshu on 13-11-2024
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



    /*Manonit Change End*/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //alert('Inside Interactions');
    if (currentPageReference && currentPageReference.state.c__selectedData != undefined) {
        //alert('Inside Interactions If');
        this.openModalNew(currentPageReference.state.c__selectedData,currentPageReference.state.c__tableData);
    }
    else if(currentPageReference && currentPageReference.state.c__recordId != undefined){
        //alert('Inside Interactions Else If');
        this.recId=currentPageReference.state.c__recordId;
        this.openModalSingleComponent(this.recId, currentPageReference.state.c__objectType,
        currentPageReference.state.c__componentName);
       }
    }
    @api
    openModalNew(selectedDataOpen, gridDataListLocal) {
        if(gridDataListLocal == [] || !gridDataListLocal.length || gridDataListLocal.length == 0){
            this.showLeftRightChangeArrow = false;
        } else {
            this.gridDataList = JSON.parse(JSON.stringify(gridDataListLocal));
            this.indexMap.maxIndex = this.gridDataList.length-1;
        }
        this.setSelectedDataForScreen(selectedDataOpen);
      //  alert('Start Custom');
        this.setCustomFieldValue(selectedDataOpen);   //Manonit
      //  alert('End Custom');
        this.isModalOpenview = true;
    }
     closeModal() {
         // to close modal set isModalOpen tarck value as false
         this.isModalOpenview = false;

        this.currentindexno = 0; 
        this.i = 0;
        this.getdisabled = false;
        this.prevdisableButton = true;
        this.currentindex = 0;
       
         /* for caousel reset*/  
    }
  
    handleNoteClickTaskview(event){ 
        this.isModalOpenview = false;
        this.openEditModal = true;
        this.recId = this.selectedData.hasOwnProperty('actId')
                     ? this.selectedData.actId
                     : this.selectedData.subjRef.substring(1);
        this.objType = this.selectedData.type;
        this.openSuggestedTag = false;
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
     isRenderTextAreea = false;
     renderedCallback(){
        this.textAreaField = this.template.querySelector('[data-id="textAreaId"]');        
 
        if(this.textAreaField != null && this.isRenderTextAreea===false){
            this.isRenderTextAreea = true;
            this.textAreaField.style.height = "auto";
            this.textAreaField.style.height = this.textAreaField.scrollHeight + "px";

            //00045813 fixed by raju on dated 24-05-2024
            this.textAreaField.style.outline = 'none';
            this.textAreaField.style.border = '0 none #FFF';
            this.textAreaField.style.boxShadow  = 'none';
        }

         const style = document.createElement('style');
         style.innerText = `.arrowBtn .slds-button__icon{
            height: 30px;
            width: 30px;
         }

         .clsDelete button.slds-button_icon-brand{
            background-color: #c23934 !important;
            border: 1px solid #c23934 !important;
         }
         .clsDelete button.slds-button_icon-brand:hover{
            background-color: #a61a14 !important;
            border: 1px solid #a61a14 !important;
         }
            /*00046447 fixed by Raju on 01-07-2024*/
        .attatchedFileCls .slds-pill {
            max-width: 320px !important;
         }

         /*00047428, 00047429 fixed by raju on dated 03-10-2024 */
         .noteareacss table {
            width: 100% !important;
            margin-left: 0 !important;
         }
 
          .noteareacss table tr td p {
                word-wrap: break-word;
                word-break: break-all;
          }
         
         .arrowBtn .slds-button:focus{
            box-shadow:none !important;
            border:none !important;
            outline: none!important;
         } 
          .clsRemoveBorderFromTextarea .slds-textarea {

            border:none !important;

            overflow: hidden;

            outline:none;

            box-shadow: none !important;

         }
         .for_mob button.slds-button{
            height:33px !important;
         }
        .noteareacss textarea.slds-textarea{
            
            resize: none;
          }
          .noteareacss textarea.slds-textarea:active{
            box-shadow:none;
          }
          .noteareacss textarea.slds-textarea:focus{
            box-shadow:none;
          }
          
          .noteareacss .slds-form-element__label:empty{
            display: none;
          }
          .nocross .slds-pill__remove {
            display: none !important;
        }
        `;
         try {
             this.template.querySelector('.main-container').appendChild(style);
         } catch (err) {
         }
     }

     setSelectedDataForScreen(selectedDataLocal) {
        const taskSubType = ["Call", "Email", "List Email"]; //00045817 Bug Fix By Manonit
        this.isTask = selectedDataLocal.type == 'Task'?true:false;
        this.isCall = taskSubType.includes(selectedDataLocal.type) ? true : false;
        
        this.selectedData = selectedDataLocal;
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
        let actId = this.selectedData.hasOwnProperty('actId')
                    ? this.selectedData.actId
                    : this.selectedData.subjRef.substring(1);
        this.recId = actId;
        this.checkRichTextDespEnable(this.recId);
        this.setCustomFieldValue(selectedDataLocal);
        this.setFileData(actId)// take the record Id
        //Add if condition for handling date
        this.indexMap.currentIndex = parseInt(this.selectedData.index);
        this.prevdisableButtonMock = (this.selectedData.index == this.indexMap.minIndex);
        this.nextDisableButtonMock = (this.selectedData.index == this.indexMap.maxIndex);
        var tagsData = this.selectedData.tagsInfo || this.selectedData.references;
       if(this.selectedData.tagsInfo){
        tagsData = tagsData.concat(this.selectedData.participantsInfo);
    }
    if(this.selectedData.references){
        tagsData = tagsData.concat(this.selectedData.attendees);
    }
    var sortTagData = [];
    var sortValue = 1;
    var mapTagValue = new Map();
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
    });
    var sortTag =[];
    //46202 Bug Fix By Manonit
    for (let i = 1; i <= 8; i++) {
        if(mapTagValue.has(i)){
            sortTag = sortTag.concat(mapTagValue.get(i));
        }
        
      }
      if(sortTag !='' || sortTag!= undefined) {
        this.setTagData(sortTag)
    }
    this.enableSpinner=false;
 } 

     setFileData(activityId) {
        this.fileDataList = [];
        getFileList({
            activityId : activityId
        })
        .then(res=>{
            console.log('res=> '+JSON.stringify(res));
            if(res.length===0){
                this.isAttachment = false;
            }
            else{
                this.isAttachment = true;
            }
            this.fileDataList = res;

        })
        .catch((err=>{
        }))
     }

     setTagData(tagData) {
        this.tagDataList = [];
        this.tagDataList = tagData;
        this.tagDataList1=[];  //for smoke round testing critical bug 00035293
        for(let x=0;x<this.tagDataList.length;x++){
            this.tagDataList1[x]=this.tagDataList[x];
            if(this.tagDataList[x].iconName==="standard:user"){ // For resolving smoke round package issue bug 00039301
                this.tagDataList1[x].isuser=true;
            }
            else{
                this.tagDataList1[x].isuser=false;
            }
        }
    }

     prevslidemock(evt) {
        var currentIndexLocal = this.indexMap.currentIndex - 1;
        if(currentIndexLocal >= this.indexMap.minIndex) {           
            this.setSelectedDataForScreen(this.getIndexedRecord(currentIndexLocal))
            this.setCustomFieldValue(this.getIndexedRecord(currentIndexLocal));
        }
     }

     nextslidemock(evt) {
        var currentIndexLocal = this.indexMap.currentIndex + 1;
        if(currentIndexLocal <= this.indexMap.maxIndex) {
            this.setSelectedDataForScreen(this.getIndexedRecord(currentIndexLocal))
            this.setCustomFieldValue(this.getIndexedRecord(currentIndexLocal));
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
        if(componentName.includes('@@@@')){  // for critical bug '00034568'
            const myArray = componentName.split('@@@@');
            this.callComponentnFunctionality = myArray[0]; 
            this.redirectId = myArray[1]!="undefined"?myArray[1]:null;
            //this.redirectId = myArray[1];
        }
        else{
            this.callComponentnFunctionality = componentName;
        }
        this.showLeftRightChangeArrow = false;
        
        if(this.callComponentnFunctionality !== 'view'){
            this.handleNoteEdit(recordId, objectType, componentName);
        } else {
            this.enableSpinner=true;// 46474 Bug Fix By Manonit
            let nameSpaceprefix = 'navpeII_dev18__';
            let activityRecIdList = [];
            activityRecIdList.push(recordId);//00T8I000004rgvqUAA'
            // Bug 00047632 Fixed by Sudhanshu on 30-05-2025
            handleInteractionsInfo({
                namespacePrefix : nameSpaceprefix,
                actIdList : activityRecIdList,
                isAcuity : false
            })
            .then(res => {
                this.isModalOpenview = true;
                
                //Added By Harshwardhan for hiding edit button in view popup for list email
                if(res[0].type == 'List Email'){
                    this.displayEditButton = false;
                }else{
                    this.displayEditButton = true;//Phase 3 Critical Bug - 00045470
                }
                let recordWrapper = res[0];
                this.selectedData = {};
                recordWrapper.index = 0;
                this.getOtherField();
                this.getTaskFieldLable();
                this.getEventFieldLable();
               
                setTimeout(() => {
                    this.setSelectedDataForScreen(recordWrapper);
                    
                }, 2000); 
               
                this.showLeftRightChangeArrow = false;
            })
            .catch(err =>{
            })
        }
        
     }
     handleNoteClickTaskviewMob(){  //00045557 Bug Fix By Manonit 
         //let activityId = this.selectedData.hasOwnProperty('actId') ? this.selectedData.actId : this.selectedData.subjRef.substring(1);
        checkActivityArchivedState({
            activityId : this.recId,
            activityType : this.recId.slice(0, 3) === '00T' ? 'Task' : 'Event'
        })
        .then(res=>{
            if(res === 'true'){
                // Bug 00046880,00046927 fixed by Sudhanshu on 31-07-2024
                 const errorToast = new ShowToastEvent({title: 'Error:', message: 'You do not have permission to edit Archived records. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(errorToast);
            } else {
            var compDefinition = {
                componentDef: "navpeII_dev18:navatarNotesMobileLwc",  //Changed by anurag for resolving 00039172
                attributes: {
                propertyValue: "500",
                recordId:this.recId,
                objectName:['Event', 'Meeting'].includes(this.selectedData.type) ? 'Event' : 'Task',
                callFromNotification: false,
                openSuggestedTags: false,
                isCalledfromMobile: true,
                isRedirectToParentScreen: true,
                taskType:this.selectedData.type,
                isCalledfromView:true,
                redirectId:this.redirectId
                }};
                // Base64 encode the compDefinition JS object
                var encodedCompDef = btoa(JSON.stringify(compDefinition));
                this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                url: '/one/one.app#' + encodedCompDef
                }
                });
                }
            })
        .catch((err=>{
            this.showToast(this, 'Error!', err, 'error', 'sticky');
        }))

       
    }

     handleTagDataClick(ev){
        let dataId = ev.currentTarget.dataset.id;
        if(dataId != undefined){   //for smoke round testing critical bug 00035293
            window.open(dataId, "_blank");
        }  
     }

    handleNoteEdit(recordId, objectType, componentName){
        this.recId = recordId;
        this.objType = objectType;
        this.openEditModal = true;
        this.openSuggestedTag = componentName === 'addTag';
    }

    noteModalClosed(){
        this.openEditModal = false;
    }

    handleCloseModal() {
        this.noteModalClosed();
    }
    /*Manonit Attachment Change Start */
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
    fileId;
    handleAttachment(event){
        event.preventDefault();
        this.fileId = event.currentTarget.dataset.id; // Bug 00048153 fixed by Sudhanshu
        checkArchiveData({recordId : this.recId})
            .then(data => {
                if(data){
                    // this.isLoading = false;
                    // Bug 00047890 Fixed by Sudhanshu
                    // Bug 00047955 fixed by Sudhanshu on 13-11-2024
                    const errorToast = new ShowToastEvent({title: 'Error:', message: 'You do not have permission to delete file on Archived records. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
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

    closeAttachment(){
        this.isDeleteAttachment = false;
        this.isModalOpenview = true;
    }
    fileName = '';
    isLoading=false;
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
            // Bug 00046492,00046883 fixed by Sudhanshu on 24-07-2024
            const successToast = new ShowToastEvent({title: 'Success:', message: 'File was deleted.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(successToast);
            this.isLoading = false;
            this.setFileData(this.recId);
            this.isDeleteAttachment=false;
            this.closeAttachment();
        })
        .catch(err =>{
            this.isLoading = false;
           
                if(err.body.message.includes('INSUFFICIENT_ACCESS_OR_READONLY'))
                {
                    // Bug 00046886 fixed by Sudhanshu on 29-07-2024
                    const event = new ShowToastEvent({title: 'Error:',message: 'You do not have permission to delete this file. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }
                else
                {
                    const event = new ShowToastEvent({title: 'Error',message:err.body.message,variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }            
        })
    }
    /*Manonit Attachment change End */
    closeDelete(){
        // this.isModalOpenview = true;
        this.isDelete = false;//Phase 3 Critical Bug - 00045470, 00045461

        this.isModalOpenview = true;//Phase 3 Critical Bug - 00045816
    //   this.dispatchEvent(new RefreshEvent());
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: this.redirectId,
    //             actionName: 'view',
    //         },
    //         })
    //         return;
    }


    // Delete Functionality
    @track isLoading = false;
    isDelete = false
    handleClickDelete(){
        // this.isModalOpenview = false;
        // this.isDelete = true;
        this.isLoading = true;
        checkArchiveData({recordId : this.recId})
            .then(data => {
                if(data){
                    this.isLoading = false;
                    // Bug 00046881 fixed by Sudhanshu on 31-07-2024
                    const errorToast = new ShowToastEvent({title: 'Error:', message: 'You do not have permission to delete Archived records. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});// Bug Id 00046109 fixed by Deepak Text changes
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


    @track isDeleteAccess=true;
    @track isLoading=false;
    handleDeleteNote(){
        this.isLoading = true;
        deleteActivity({
            actId : this.recId
        })
        .then(res => {
            // bug 00046430,00046756 fixed by Sudhanshu on 11-07-2024
            const successToast = new ShowToastEvent({title: 'Success:', message: 'Record was deleted.',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(successToast);// 46430 Bug Fix by Deepak 
            this.isLoading = false;
            this.isDelete = false;
          
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.redirectId,
                actionName: 'view',
            },
            })
            return;
        })
        .catch(err =>{
            this.isLoading = false;
            if(err.body.message.includes('INSUFFICIENT_ACCESS_OR_READONLY'))
            {
                // this.isDelete = false;
                // this.isDeleteAccess = false;
                // this.isLoading = false;
                // bug 00046887 fixed by Sudhanshu on 11-07-2024
                // Bug 00046887 fixed by Sudhanshu on 03-10-2024
                // Bug 00048555 fixed by Sudhanshu on 23-12-2024
                const event = new ShowToastEvent({title: 'Error:',message:'You do not have permission to delete this record. Please contact your Navatar Administrator.',variant: 'error',mode: 'dismissable'});
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

}