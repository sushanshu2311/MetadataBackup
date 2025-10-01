/****************************************************************************************************

** Module Name : Activity Associations

** Description : Edit and New action of Event and Task.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur/Yash/Anmol
** 2.0        2024-02-02          Sudhanshu       Changes for Custom fields & import Note 
** 2.1        2024-02-02          Manonit         Changes for view Pop up 
** 2.2        2024-04-02          Deepak          Bug Fix Phase 3 CR - 00041270 


***********************************************************************************************/

import { api, LightningElement, track,wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedData from '@salesforce/apex/NavatarNotesModalCtrl.getRelatedData';
import getSearchableObjName from '@salesforce/apex/NavatarNotesModalCtrl.getSearchableObjName';
import getRecordData from '@salesforce/apex/NavatarNotesModalCtrl.getRecordData';
import getSuggestions from '@salesforce/apex/NavatarNotesModalCtrl.getSuggestions';
import saveRecord from '@salesforce/apex/NavatarNotesModalCtrl.saveRecord';
import getPickListValues from '@salesforce/apex/NavatarPicklistCtrl.getPickListValues';
import getDefaultTaggedRecords from '@salesforce/apex/NavatarNotesModalCtrl.getDefaultTaggedRecords';
import getDefaultTaggedRecordList from '@salesforce/apex/NavatarNotesModalCtrl.getDefaultTaggedRecordList';
import adjustEventStartEndDate from '@salesforce/apex/NavatarNotesModalCtrl.adjustEventStartEndDate';
import saveSuggessionRecods from '@salesforce/apex/NavatarNotesModalCtrl.saveSuggessionRecods';
import getSubjectFieldLabel from '@salesforce/apex/NavatarNotesModalCtrl.getSubjectFieldLabel';
import getTodayDate from '@salesforce/apex/NavatarNotesModalCtrl.getTodayDate';
import getEventDateTime from '@salesforce/apex/NavatarNotesModalCtrl.getEventDateTime';
import checkEditAccess from '@salesforce/apex/NavatarNotesModalCtrl.checkEditAccess';
import currentUserId from '@salesforce/user/Id';
import userAvailableAccountRecType from '@salesforce/apex/NavatarNotesTaggingCtrl.getUserAvailableAccountRecordTypes';
import saveNewAccountContactRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.createAccountContactRecords';
import getActivityData from '@salesforce/apex/NavatarNotesTaggingCtrl.getActivityData';
import getImportID from '@salesforce/apex/NavatarGetImportNotesModalCtrl.getImportID';
import checkSuggestedTag from '@salesforce/apex/NavatarNotesModalCtrl.checkSuggestedTag';
import handleInteractionsInfo from '@salesforce/apex/NavatarAcuityCtrl.handleInteractionsInfo'; //Notes view Pop up on new Note Added by Manonit

import getRecord from '@salesforce/apex/NavatarGetImportNotesModalCtrl.getRecord';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
//00046115 fixed by raju on 19-06-2024
import imgCheckboxMinus from '@salesforce/resourceUrl/checkboxMinus';

//Rich Textarea Requirement - Sudhanshu ; 47978
import checkRichTextDesp from '@salesforce/apex/NavatarNotesModalCtrl.checkRichTextDesp';
import getRtaToggleStatus from '@salesforce/apex/NavatarNotesModalCtrl.checkRtaToggleStatus';
import saveRtaToggleStatus from '@salesforce/apex/NavatarNotesModalCtrl.saveRtaToggleStatus';
import { exclusionWordList,renderCss} from "./navatarNotesModalLwcUtility";


const columns = [
    { label: 'Reference Found', fieldName: 'Name' },
    { label: 'Type', fieldName: 'objectName', cellAttributes: { iconName: { fieldName: 'iconName' } }},
];

class ReadOnlyArray extends Array {
    constructor(mutable) {
        return Object.freeze(mutable.slice()); 
    }
}

const columns1 = [
    { label: 'Name',type:'text', fieldName: 'Deals', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' } },
    { label: 'Type', fieldName: 'name', hideDefaultActions: true, type: 'text',  cellAttributes: { class: ' slds-text-body_regular ', iconName: { fieldName: 'dynamicIcon' } } },
];

const columns2 = [
     {
            label: '',
            type: 'button',
            fixedWidth: 32,
            typeAttributes: { label: { fieldName: 'showCross' }, iconName: 'utility:close', variant:'border', name: 'crossButton', title: 'Remove', disabled: false, value: 'showCross' },
    },
    { label: 'Name',type:'text', fieldName: 'Deals', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' } },
    { label: 'Type', fieldName: 'name', hideDefaultActions: true, type: 'text',  cellAttributes: { class: ' slds-text-body_regular ', iconName: { fieldName: 'dynamicIcon' } } },
   
];


export default class navatarNotesModalLwc extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if(currentPageReference && currentPageReference.state.c__isRedirectToRecord !==undefined){
            this.isRedirect=currentPageReference.state.c__isRedirectToRecord;
        }
    }
    @api recordId;
    @api objectName;
    @api redirectId = '';
    @api isRedirect = false;
    @api modalHeader = '';
    @api taskType = '';
    @api isUtilityBar=false;            // Added by Sudhanshu For Utility Bar popup
    @api isFollowup;
    @api openTag=false;

    @track data = [];
    @track columns = columns;
    isviewNotePopup=false;
    isNewNote=false;
    @track ownerIdLabel = '';

    @track subject = '';
    @track tagString = '';
    @track isStillAt = false;
    @track isLoading = false;
    @track showAdvance = false;
    @track isTask = false;
    @track lstResult = [];
    @track commentStr;
    @track searchObjects;
    @track allTaggedRecords = [];
    @track atTaggedRecords = [];
    @track extraTaggedRecords = [];
    @track otherFields = [];
    @track globalCheck = false;
    @track subjectOptions = [];
    @track subjectOptionsTemp = [];
    @track isShowModal = true;
    @track isSuggest = false;
    @track showFollowUp = false;
    @track isTagOpen = false;
    @track tagIconName = 'standard:quotes';
    @track eventLayoutFields = '';
    @track followTaskLayoutFields = '';
    @track taskLayoutFields = '';
    @track blurTimeout;
    savedFollowUpIds = '';

    userId = currentUserId;
    isDescriptionUsed = false;
    @track followupCount = 0;
    @track followUpTask = { subject : '', assignTo : '', status : '', date : ''};

    followUpLayoutFields = [];
    
    @track followUpList = [];
    subjectLabel = "Subject";
    @track isEditAccess = true;
    @track isError= false;
    @track errorMessage = [];
    @track errorHeader = '';
    @track isQuick = false;
    @track isaDealTeam = false;
    @track isDiscover = false;
    @api isFromSdg =false;

    isInfoMessage = false;

    @track newTaggList = [];
    @track actOptions = [];
    @track allTaggedRecordsInit = [];
    @track isInitRun = true;

    @api
    openSuggestedTags = false;
    @api additionalTaggedIds = [];
    @track headerIcon = '';
    // Bug 00047983 fixed by Sudhanshu
    expandIcon = false; 
    expandPopup(event){
        let popModal = this.template.querySelector('.customize');
        if(popModal.classList.contains('slds-modal_large')){
            popModal.classList.remove("slds-modal_large");
            popModal.classList.remove("slds-modal_small")
            this.expandIcon = true;
        }else{
            popModal.classList.add("slds-modal_large")
            this.expandIcon = false;
        }
    }

    @track activeSectionAdvance = 'A';  // Added by Sudhanshu for Advance section ; 47980
    //00046115 fixed by raju on 19-06-2024
    checkboxMinus = imgCheckboxMinus;

    @api importId='';
        
    pkgStr = exclusionWordList();  // Code split by Sudhanshu 

    handleImport(){
        this.isframe=true;
        this.isShowModal=false;
    }

    commentStr='';
    
    
//Rich Textarea Requirement - Deepak and Fixed 00047283 by Deepak
    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
    ];
    isRichTxtEnable = false;
    richTxtDescription ='';
    // method for check Rich Text Area Field enable or not
    checkRichTextDespEnable(recordID){
        checkRichTextDesp({
            "recordId":this.recordId
        })
            .then(data => {
                console.log('this.recordId'+this.recordId);
                this.isRichTxtEnable = data[0].isRichText === 'true' ? true : false;
                
                if(this.recordId != null && this.recordId != '' && this.isRichTxtEnable){
                    this.richTxtDescription = data[0].richDescription == '' ? this.commentStr.replaceAll('\n','<br>') : data[0].richDescription ;
                }
                
            })
            .catch(error => {
                console.log('richtext'+error);
            });
    }


    textareahight = 100;    
    handleScrollHeight(){

        this.textAreaField = this.template.querySelector('[data-id="textAreaId2"]'); 
        if(this.textAreaField != null){    
            this.textAreaField.style.height = "auto";
            this.textAreaField.style.height = this.textAreaField.scrollHeight + "px";
        }
    }
    
    isframe=false;
    isFocus=false;      // Added by Sudhanshu for bug bix 		00045105,00045784

    renderedCallback() {	
        // Bug 00047978 Fixed By Sudhanshu For CR Changes
        let richTextCmp = this.template.querySelector('.richTextCls');
        if(this.hasRtaLoaded && richTextCmp && this.rtaToggleStatus != undefined){
            this.hasRtaLoaded = false;
            this.handleRtaToggle();
        }

        if(this.showSuggestedTagsModal && !this.isFocus)             // Added by Sudhanshu for bug bix 		00045105,00045784
        {
                this.isFocus = true;
                const getSearchBox = this.template.querySelector('.clsSearchDefaultFocus');
                try{
                    getSearchBox.focus();
                }
                catch(ex){

                }
        }
        
            
        const style = document.createElement('style');
        // Code Split by Sudhanshu
        style.innerText = renderCss()+` 
        .detailsnoteareacss textarea.slds-textarea{
            border: none !important;
            padding: 0px 0px;
            box-shadow: none;
            resize: none;
            background-color: inherit;
            height: ${this.textareahight}px;
            min-height:50px;
        }
        `;
        this.template.querySelector('.main-Container')?.appendChild(style);	
    }
    heighttextarea(){
        
        setTimeout(() => {
            let textar = this.template.querySelector(".txtar");
            console.log(textar, "textarjag")
            if(textar){
                textar.innerHTML = this.commentStr;
                console.log(25+textar.scrollHeight,"scoll90909");
                if(25+textar.scrollHeight<50){
                    this.textareahight = 50;
                }
                else if(25+textar.scrollHeight>286){
                    this.textareahight = 286;
                }
                else{
                    this.textareahight = 25+textar.scrollHeight;
                }
            }
            else{
                this.textareahight = 50;
            }
            this.renderedCallback();
        }, 500);
       
    }
    tobottom(){
        window.setTimeout(()=>{
            this.template.querySelector('.slds-modal__content').scrollTop=10000;
        }, 100)       						 
    }

    get followupTaskList(){
        return this.followUpList.length > 1 ? true : false;
    }

    connectedCallback() {    
        this.registerErrorListener();  // added by sudhanshu
        this.handleSubscribe();  // added by sudhanshu
        this.handleImportID();

        this.tempOptions = this.options;
        this.finalOption =  [...this.tempOptions];
        if(this.objectName == 'Event' || this.objectName == 'Meeting'){
            this.modalHeader = 'Meeting'; // Critical Bug Fix Nikita S
            this.headerIcon = 'utility:event';
            this.objectName = 'Event';
        }
        if(this.objectName == 'Task' ){
            this.modalHeader = 'Task';
            this.headerIcon = 'utility:task';
        }
        if((this.objectName == 'Task' && this.taskType == "Call") || (this.objectName === 'Call')){
            this.modalHeader = 'Call Notes';
            this.headerIcon = 'utility:call';
            this.objectName = 'Task';
            this.taskType = 'Call'; //Critical Bug fix Nikita S
        }
       
        if((this.objectName == 'Task' && this.taskType == "Email") || (this.objectName === 'Email')){
            this.modalHeader = 'Email';
            this.headerIcon = 'utility:email';
            this.objectName = 'Task';
            this.taskType = 'Email'; //Critical Bug fix Nikita S
        }
       
        this.isLoading = true;

        this.isTask = this.objectName =='Task' ? true : false;

        if(typeof this.isRedirect == 'undefined'){
            this.isRedirect = true;
        }
        if(this.taskType == 'Call'){
            this.subject = 'Call'

        }
        if(this.recordId == null || typeof this.recordId === 'undefined' || this.recordId == ''){
            this.isShowModal = true;
            this.isEditAccess = true;
            this.fetchSearchableObjects();
            this.getRtaToggleStatus();//Added by Sudhanshu on 2024-10-25 for RTA toggle status ; 47978
            this.getSubjectValues();
            this.fatchSubjectFieldLabel();
            this.isNewNote=true
        }else{
            checkEditAccess({recordId : this.recordId})
            .then(data => {
                if(data){
                    this.isEditAccess = true;
                    this.fetchSearchableObjects();
                    this.getRtaToggleStatus();//Added by Sudhanshu on 2024-10-25 for RTA toggle status ; 47978
                    this.getSubjectValues();
                    this.fatchSubjectFieldLabel();
                }else{
                    this.isShowModal = false;
                    this.isEditAccess = false;
                }
            })
            .catch(error => {
                this.displayError(error);
            });
        }
        this.getActRecordType();
    }

    fatchSubjectFieldLabel(){
        getSubjectFieldLabel({})
        .then(data => {
            this.subjectLabel = data;
        })
        .catch(error => {
            this.displayError(error);
        });
    }

    getSubjectValues(){
        getPickListValues({
            objApiName: this.objectName,
            fieldName: 'Subject',
            selectedValue : '',
        })
        .then(data => {
            this.subjectOptionsTemp = this.subjectOptionsTemp.concat(data);
            this.subjectOptions = this.subjectOptionsTemp;
        })
        .catch(error => {
            this.displayError(error);
        });
    }
    
    get recordData(){
        return this.lstResult;
    }

    showSubjectOption(){
        if(this.subjectOptions.length > 0){
            let sldsIsOpenClass = this.template.querySelector(".slds-dropdown-trigger_click");
            sldsIsOpenClass.classList.add("slds-is-open");
        }
    }

    showSubjectOptionFollowUp(event){
        let cls = event.currentTarget.dataset.uid.trim().split(/\s+/);
        let sldsIsOpenClass = this.template.querySelector("."+cls[cls.length-1]);
        sldsIsOpenClass.classList.add("slds-is-open");
    }

    hideSubjectOption(){
         this.blurTimeout = setTimeout(() =>  {

            let sldsIsOpenClass = this.template.querySelector(".slds-dropdown-trigger_click");
            sldsIsOpenClass.classList.remove("slds-is-open");

            for(let followUp of this.followUpList){
                let cls = followUp.subjectClass.trim().split(/\s+/);
                let sldsIsOpenClass = this.template.querySelector("."+cls[cls.length-1]);
                sldsIsOpenClass.classList.remove("slds-is-open");
            }
        }, 300); 
    }

    selectSubject(event) {
        this.subject = event.currentTarget.dataset.id;
        //00031970 -- 
        for(let followUp of this.followUpList){
            for(let followUpField of followUp.data){
                if( (followUpField.fieldAPI == 'subject' || followUpField.fieldAPI == 'Subject')  && !this.showFollowUp){
                    followUpField.fieldValue = this.subject;
                }
            }
        }
    }

    selectFollowUpSubject(event) {
        this.followUpTask.subject = event.currentTarget.dataset.id;
        let temp = [];
        for(let followUp of this.followUpList){
            for(let fields of followUp.data){
                if(fields.lwcFieldClass == event.target.dataset.id){
                    fields.fieldValue = event.target.dataset.name;
                }
            }
           
            temp.push(followUp);
        }
        this.followUpList = [...temp];
        this.hideSubjectOption();

    }

    @track hiddenTaggedList =[];    // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
    fetchRecordData(){
        this.isLoading = true;


        getRecordData({"recordId" : this.recordId,
                        "searchObjects" : this.searchObjects,
                        "currentObject" : this.objectName,
                        "eventLayoutFields" : this.eventLayoutFields,
                        "taskLayoutFields" : this.taskLayoutFields,
                        "taskType" : this.taskType,
                        "followUpTaskFields" : this.followTaskLayoutFields
        }).then(data => {
            let recordData = JSON.parse(data);
            this.commentStr = recordData.description;
            //Rich Textarea Requirement - Deepak
            this.checkRichTextDespEnable(this.recordId);//Rich Textarea Requirement - Deepak
            this.heighttextarea();  
            if(this.recordId != null && this.recordId != ''){
                this.subject = recordData.subject;
            }
           
            this.allTaggedRecords = this.allTaggedRecords.concat(JSON.parse(recordData.allTaggedRecordsList)); 
            if(this.isInitRun) {
                this.allTaggedRecordsInit = [...this.allTaggedRecords];
            }

            this.otherFields = JSON.parse(recordData.allOtherFields);
            this.followUpLayoutFields =new ReadOnlyArray(JSON.parse(recordData.followupTaskFields));
            for(let advanceFields of this.otherFields){
                if(advanceFields.fieldAPI.toLowerCase() == 'ownerid' ){
                    this.ownerIdLabel = advanceFields.fieldLabel;
                }
            }
            let fields = JSON.stringify(this.followUpLayoutFields);
            let _fields = JSON.parse(fields);
            this.hiddenTaggedList = JSON.parse(recordData.hiddenTaggedList);    // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
            for(let followUpField of _fields){
                followUpField.lwcFieldClass = followUpField.lwcFieldClass + this.followupCount;
                if(followUpField.fieldAPI == 'subject' || followUpField.fieldAPI == 'Subject'){
                    followUpField.fieldValue = this.subject;
                }
            }
            this.followUpList.push({id :this.followupCount , data : _fields, subjectClass : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-dropdown-trigger_click_followup'+this.followupCount});
            this.isLoading = false;
            if(this.openSuggestedTags) {
                this.handleDealTeam();
            }
            if(this.openDealHelper) {
                this.openDealTeamModal();
            }
        }).catch(error => {
            this.isLoading = false;
            this.openDealTeamModal();  // Bug 00045344 fixed by sudhanshu  06-05-2024
        });
    }

    showmoreTask(){
        this.followupCount = this.followupCount +1;
        let fields = JSON.stringify(this.followUpLayoutFields);
        let _fields = JSON.parse(fields);
        for(let followUpField of _fields){
            followUpField.lwcFieldClass = followUpField.lwcFieldClass + this.followupCount;
            if(followUpField.fieldAPI == 'subject' || followUpField.fieldAPI == 'Subject'){
                followUpField.fieldValue = this.subject;
            }
        }
        this.followUpList.push({id :this.followupCount , data: _fields, subjectClass : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-dropdown-trigger_click_followup'+this.followupCount});
    }
    closeMoreTask(event){
        if(this.followUpList.length > 1){
            let temp = [];
            for(let followUp of this.followUpList){
                if(followUp.id != event.target.dataset.id){
                    temp.push(followUp);
                }
            }
            this.followUpList = [...temp];
        }
        
        
    }

    fetchSearchableObjects(){
        let recIdval = ((typeof this.recordId === 'undefined')||this.recordId==undefined)?'':this.recordId;
        getSearchableObjName({
            "recordIdval": recIdval
        }).then(data => {
            this.searchObjects = data[0];
            this.taskLayoutFields = data[1];
            this.eventLayoutFields = data[2];
            this.followTaskLayoutFields = data[3];
            this.isDescriptionUsed = data[4];
            this.isLoading = false;
            this.fetchRecordData();
            if(this.recordId == null || typeof this.recordId === 'undefined' || this.recordId == ''){
                this.handleTagged();
            }
        }).catch(error => {
            this.isLoading = false;
        });
    }

    crnttaggedrecord = [];
    handleTagged(){
        getDefaultTaggedRecords({recId : this.redirectId, searchObjects : this.searchObjects}).then(data => {
            this.allTaggedRecords = this.allTaggedRecords.concat(JSON.parse(data));
            this.crnttaggedrecord = JSON.parse(data);
            // Bug 00047561,00048364 fixed by Sudhanshu
            if(this.crnttaggedrecord[0].objectName == 'navpeII_dev18__Fundraising__c')
            {
                this.addNewFundRaising(this.crnttaggedrecord[0]);
            }
            // Bug 00047558,00048364 fixed by Sudhanshu
            if(this.crnttaggedrecord[0].objectName == 'navpeII_dev18__Pipeline__c')
            {
                this.addNewDeals(this.crnttaggedrecord[0]);
            }
            if(this.additionalTaggedIds.length) {
                this.handleContact();
            }
        }).catch(error => {
            this.isLoading = false;
        });
        
    }

    handleContact() {
        getDefaultTaggedRecordList({recIdList : this.additionalTaggedIds, searchObjects : this.searchObjects}).then(data => {
            this.allTaggedRecords = this.allTaggedRecords.concat(JSON.parse(data));
        }).catch(error => {
            this.isLoading = false;
        });
    }

    hideRecordModal(){
        this.dispatchEvent(new CustomEvent("cancelchanges" ) );
        if(this.isUtilityBar){
            let count = this.importCount;
            if(this.IsFileImported)             // Bug 00045530 Fixed By Sudhanshu on 24-05-2024
            {
                window.history.go(-(parseInt(this.importCount)+1));
                return;
            }
            else{
                window.history.back();
                return;
            }     
        }
        if(this.redirectId != null && this.redirectId != '' && this.isFromSdg != true){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.redirectId,
                    actionName: 'view',
                },
            })
            return;
        }
        if( !this.isRedirect){
            this.dispatchEvent(new CustomEvent('cancelchanges', { bubbles:true, composed:true }));
            this.isShowModal = false;
            this.isSuggest =false;
            this.isInfoMessage = true;//Bug 00045783 fixed by Deepak
        }else{
            this.navigatePage();
        }
       // this.meetingCallEmailViewpopup(); //Comment to fix reload isue
    }

    navigatePage(event) {
        this.isSuggest = false;
        this.isInfoMessage = true;
        if(this.isUtilityBar){
            window.history.back();
            return;
        }
        
        if(!this.isRedirect){
            this.isShowModal = false;
            this.isSuggest =false;
            this.dispatchEvent(new CustomEvent("closemodal", {detail: {'recId' : this.recordId}  } ) );
            return;
        }

        if(this.redirectId != null && this.redirectId != ''){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.redirectId,
                    actionName: 'view',
                },
            })
            return;
        }
            
        if(this.recordId != null && this.recordId != ''){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                },
            })
        }else{
            if(this.objectName == 'Event'){
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "Event",
                        actionName: 'home'
                    }
                })
            }else{
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "Task",
                        actionName: 'home'
                    }
                })
            }
        }
        
    }

   
    // handle selected record of quick tag lookup
    handleSelectLookup(event){
        let selectedRecord = JSON.parse(event.detail);
        this.handleAddTaggedRecord(selectedRecord);
    }
    // how and hide quick tag.
    handleClickTag(){
        this.isTagOpen = this.isTagOpen ? false : true;
    }
    // return current icon name of quick tag.
    get currentTagIcon(){
        return this.isTagOpen ? 'standard:first_non_empty' : 'standard:quotes';
    }
    // save record
    @track showSubjectError = false;

    createToastParams(recordId, recType, mode){
        let params = {};
        params['recId'] = recordId;
        params['recType'] = recType;
        params['mode'] = mode;
        return params;
    }

    handleFieldValue(fields,text){
        let fieldList=fields;
        let textLabel = text;
        for (let i = 0; i < fieldList.length; i++) {
            let fieldValue;
            if(textLabel =='Followup'){
                fieldValue = this.template.querySelector("."+fieldList[i].lwcFieldClass);
            }
            else
            {
                fieldValue = this.template.querySelector("."+fieldList[i].fieldAPI);
            }
            if(fieldValue != null){
                if( fieldList[i].fieldType == 'STRING'){
                    if(fieldList[i].isRequired == true && !fieldValue.value.trim()  )
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");   // Bug 00044242 Fixed by Sudhanshu on 07-05-2024
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    fieldList[i].fieldValue = fieldValue.value;
                }
                if( fieldList[i].fieldType == 'BOOLEAN'){
                    fieldList[i].booleanValue = fieldValue.checked;
                }
                if( fieldList[i].fieldType == 'DATETIME'){
                    if(fieldList[i].isRequired == true && !fieldValue.value.trim() )
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else if(fieldList[i].isRequired == true && fieldValue.value == null){
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    fieldList[i].dateTimeValue = fieldValue.value != '' && fieldValue.value != null ? fieldValue.value : null;
                }
                if( fieldList[i].fieldType == 'DATE'){
                    if(fieldList[i].isRequired == true && fieldValue.value == '' )
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else if(fieldList[i].isRequired == true && fieldValue.value == null){
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    fieldList[i].dateValue = fieldValue.value != '' && fieldValue.value != null ? fieldValue.value : null;
                }
                if( fieldList[i].fieldType == 'INTEGER' || fieldList[i].fieldType == 'DOUBLE'){
                    if(fieldList[i].isRequired == true && !fieldValue.value.trim() )
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    fieldList[i].numberValue = fieldValue.value != '' && fieldValue.value != null ? fieldValue.value : null;
                }
                if( fieldList[i].fieldType == 'TEXTAREA'){
                    if(fieldList[i].isRequired == true && !fieldValue.value.trim() )
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    fieldList[i].fieldValue = fieldValue.value;
                }
                if( fieldList[i].fieldType == 'EMAIL'){
                    if(fieldList[i].isRequired == true && !fieldValue.value.trim())
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    if(fieldValue.value.trim()){
                        var flag = true;
                        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                        if (!fieldValue.value.match(emailRegex)) {
                                    
                            fieldValue.setCustomValidity("Please enter valid email");
                            flag = false;
                            fieldValue.reportValidity();
                            this.requiredMissing.push(fieldList[i].fieldLabel);
                        }
                        else{
                             fieldValue.setCustomValidity("");
                             fieldValue.reportValidity();
                        }
                    }
                    fieldList[i].fieldValue = fieldValue.value;
                }
                if( fieldList[i].fieldType == 'PHONE'){
                    if(fieldList[i].isRequired == true && !fieldValue.value.trim() )
                    {
                        this.requiredMissing.push(fieldList[i].fieldLabel);
                        fieldValue.setCustomValidity("Complete this field.");
                        fieldValue.reportValidity();
                    }
                    else{
                        fieldValue.setCustomValidity("");
                        fieldValue.reportValidity();
                   }
                    fieldList[i].fieldValue = fieldValue.value;
                }
                
            }
            if( fieldList[i].fieldType == 'PICKLIST'){
                const childDisplayState = this.template.querySelectorAll('c-navatar-picklist-lwc');
                if(childDisplayState != null){
                    for(let eachPick of childDisplayState){
                        var statusAPI = 'Status';
                        var priorityAPI = 'Priority';
                        if(textLabel =='Followup'){
                             if( fieldList[i].lwcFieldClass == eachPick.currentInputClass){
                                fieldList[i].fieldValue = eachPick.currentSelectedOption;
                                    if( (fieldList[i].fieldAPI.toUpperCase() === statusAPI.toUpperCase() || fieldList[i].fieldAPI.toUpperCase() === priorityAPI.toUpperCase() ) && (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                        
                                    }
                                    else if(fieldList[i].isRequired == true &&  (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                        
                                    }
                                }
                        }
                        else{
                            if( fieldList[i].fieldAPI == eachPick.currentInputClass){
                                if( (fieldList[i].fieldAPI.toUpperCase() === statusAPI.toUpperCase() || fieldList[i].fieldAPI.toUpperCase() === priorityAPI.toUpperCase() ) && (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                    this.requiredMissing.push(fieldList[i].fieldLabel);
                                    
                                
                                }
                                else if(fieldList[i].isRequired == true &&  (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                    this.requiredMissing.push(fieldList[i].fieldLabel);
                                    
                                }
                                fieldList[i].fieldValue = eachPick.currentSelectedOption;
                            } 
                        }
                        
                    }
                }
                
            }
            try {
                if( fieldList[i].fieldType == 'REFERENCE'){
                    const childDisplayState = this.template.querySelectorAll('c-navatar-single-lookup-lwc');
                    if(childDisplayState != null){
                        for(let eachPick of childDisplayState){
                            if(textLabel =='Followup'){
                                if( fieldList[i].lwcFieldClass == eachPick.currentInputClass){
                                    fieldList[i].fieldValue = eachPick.currentSelectedRecord;
                                     if(eachPick.currentSelectedRecord == '' && eachPick.searchTerm != ''){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                                            eachPick.showerror();
                                    }
                                    if(eachPick.currentSelectedRecord == ''){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                                            eachPick.showerror();
                                    }
                                    if(fieldList[i].isRequired == true && eachPick.currentSelectedRecord == null)
                                     {
                                       this.requiredMissing.push(fieldList[i].fieldLabel);
                                                            eachPick.showerror();
                                    }
                                }
                            }
                            else {
                                if( fieldList[i].fieldAPI == eachPick.currentInputClass){
                                    fieldList[i].fieldValue = eachPick.currentSelectedRecord;
                                    if(eachPick.currentSelectedRecord == '' && eachPick.searchTerm != ''){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                        eachPick.showerror();
                                    }
                                    else if(eachPick.currentSelectedRecord == ''){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                        eachPick.showerror();
                                    }
                                    if(fieldList[i].isRequired == true && eachPick.currentSelectedRecord == null)
                                    {
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                        eachPick.showerror();
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
              }
              catch(err) {
              }
            
        }
        return fieldList;
    }

   @track requiredMissing = [];
   @track fieldList=[];

    handleSaveRecord(){
        // added by Sudhanshu
        if(this.isRichTxtEnable)
        {
            let txtNotes = this.richTxtDescription.replace(/<p\s*\/?>|<br\s*\/?>|<li\s*\/?>/gi, '\n');
            // bug 00047418,00047512,00047515,00047430,00047562,00047511,00047550,00047523,00047525,00047520,00047510,00047516,00047519,00047838 fixed by Sudhanshu
            this.commentStr = txtNotes.replace(/(<([^>]+)>)/gi, "").replace(/&nbsp;/g, ' '); // .replace(/<[^>]*(>|$)|&nbsp;|&zwnj;|&raquo;|&laquo;|&gt;|&amp;/g,"")
            this.convertToHyperlinks(); // Bug 	00047365 fixed by Sudhanshu
        }
        this.isError = false;
        this.isLoading = true;
        this.errorMessage = [];
        this.requiredMissing =[];

        // var this.requiredMissing = [];
        
        this.otherFields = this.handleFieldValue(this.otherFields,'OtherField');
 
        
        let isValidated = true;
        let fieldErrorMsg="Invalid data type.";
        if(this.objectName == 'Event'){
            this.template.querySelectorAll("lightning-input").forEach(item => {
                let fieldValue=item.value;
                let fieldLabel=item.label;            
                if(!fieldValue && (fieldLabel.includes('End') || fieldLabel.includes('Start') )){
                    item.setCustomValidity(fieldErrorMsg); 
                    isValidated = false;
                }
                else{
                    item.setCustomValidity("");
                }
                item.reportValidity();
            });
        }

        if(this.objectName == 'Task'){
            if(!this.isValidActivityDate){
                isValidated = false;
            }
        }

        
        if(!isValidated){
            this.errorMessage.push('The Record provided contains field(s) with invalid data.');
            this.errorHeader = 'Review the errors on this page';
            this.isError = true;
        }

        if(this.showFollowUp){
            for(let row of this.followUpList){
                let followUpLayoutFields = row.data;
                followUpLayoutFields = this.handleFieldValue(followUpLayoutFields,'Followup');
                
            }
        }
        let uniqueArray = Array.from(new Set(this.requiredMissing));
        if(this.requiredMissing.length > 0){
            this.errorMessage.push('These required fields must be completed: ' + uniqueArray.toString());
            this.errorHeader = 'Review the errors on this page';
            this.isError = true;
        }
        if(this.isClone){
            this.recordId = null;
        }
        let commentData = this.commentStr;
        let commentStringArray = [];
        commentStringArray = commentData.split(' ');
        let updatedString = '';
        for(var d in commentStringArray) {
            updatedString+=commentStringArray[d]+' ';
        }
        
        let taggedrecord = [];
        
        // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
        for (let i = 0; i < this.hiddenTaggedList.length; i++ ) {
            taggedrecord.push({Id:this.hiddenTaggedList[i]}); 
        }
        taggedrecord = taggedrecord.concat(this.allTaggedRecords);
        if(!this.isError){
            saveRecord({"commentStr" : updatedString, 
                    "allTaggedRecords" : JSON.stringify(taggedrecord),
                    "recordId" : this.recordId,
                    "atTaggedRecord" : JSON.stringify(this.atTaggedRecord),
                    "extraTaggedRecord" : JSON.stringify(this.extraTaggedRecords),
                    "objectName" : this.objectName,
                    "otherFielddData" : JSON.stringify(this.otherFields),
                    "currentObject" : this.objectName,
                    "subject" : this.subject,
                    "taskType" : this.taskType,
                    "isDescriptionUsed" : this.isDescriptionUsed,
                    "followUpTasksStr" : JSON.stringify(this.followUpList),
                    "isSaveFollowup" : this.showFollowUp,
                    "isRichTxtEnable" : this.isRichTxtEnable,
                    "richTxtDescription" : this.richTxtDescription
                }).then(dataList => {
                    let data=dataList[0];
                    if(!data.includes('Error')){
                        let followupDetailsMap=JSON.parse(dataList[1]);
                        this.commentStr = dataList[2];//Sudhanshu for 47995
                        console.log('Description ==> '+this.commentStr);
                        this.recordId = data.split('#')[0];
                        // this.saveFileData(this.recordId);
                        this.savedFollowUpIds = data.split('#')[1];
                        let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                        const event = new ShowToastEvent({title: 'Success',message: '"{0}{1}" was saved.',//this.objectName + -> Removed for Bug #00038075
                        variant: 'success',
                        mode: 'dismissable', 
                        messageData: [
                            '',
                            {
                                // Bug 00046852 fixed by Sudhanshu on 30-07-2024
                                url: '/lightning/n/navpeII_dev18__View_Interaction?c__params='+allIteractionsParams,
                                label: this.subject,
                            }
                        ]});
                        this.dispatchEvent(event);
                        for(let key in followupDetailsMap){
                            if (followupDetailsMap[key]!=null) {
                                let allIteractionsParams = JSON.stringify(this.createToastParams(key, 'Task', 'view'));
                                this.dispatchEvent(new ShowToastEvent({title: 'Success',message: '"{0}{1}" was saved.',//this.objectName + -> Removed for Bug #00038075
                                variant: 'success',
                                mode: 'dismissable', 
                                messageData: [
                                '',
                                {
                                    // Bug 00046852 fixed by Sudhanshu on 30-07-2024
                                    url: '/lightning/n/navpeII_dev18__View_Interaction?c__params='+allIteractionsParams,
                                    label: followupDetailsMap[key],
                                }
                                ]}));
                            }
                        }
                        this.isShowModal = false; 
                        this.handleSave();
                        
                    }else{
                        let msg = data.split(';');
                        if(msg.length>1){
                                let errorCode=msg[2].split('=')[1];
                                if(!data.includes('Review the errors on this page')){
                                    // Bug 00041221 Fixed by Sudhanshu on 26-04-2024 
                                    if(errorCode=='FIELD_CUSTOM_VALIDATION_EXCEPTION')
                                    {
                                        const event = new ShowToastEvent({title: 'Error',message: msg[1].split('=')[1],variant: 'error',mode: 'dismissable'});
                                        this.dispatchEvent(event);
                                    }
                                    else
                                    {
                                        const event = new ShowToastEvent({title: 'Error',message: 'Review the errors on this page',variant: 'error',mode: 'dismissable'});
                                        this.dispatchEvent(event);
                                    }  
                                }else{
                                    const event = new ShowToastEvent({title: 'Error',message: 'Review the errors on this page',variant: 'error',mode: 'dismissable'});
                                    this.dispatchEvent(event);
                                }
                            }
                        else{
                            if(!data.includes('Review the errors on this page')){
								// Fixed by Sudhanshu - 47142 Patch
                                if(!data.includes('Error:')){
                                    const event = new ShowToastEvent({title: 'Error',message: data,variant: 'error',mode: 'dismissable'});
                                    this.dispatchEvent(event);
                                }
                                else{
                                    let err = data.split(':');
                                    const event = new ShowToastEvent({title: 'Error',message: err[1],variant: 'error',mode: 'dismissable'});
                                    this.dispatchEvent(event);
                                }
                            }else{
                                const event = new ShowToastEvent({title: 'Error',message: 'Review the errors on this page',variant: 'error',mode: 'dismissable'});
                                this.dispatchEvent(event);
                            }
                        }
                    }
                    this.isLoading = false;
                    
            }).catch(error => {
                const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(event);
                this.isLoading = false;
            });
        }else{
            this.isLoading = false;
        }
        
    }

    // store changed notes in variable
    handleChangeNotes(event){
        
        if(this.isRichTxtEnable)
        {
            this.richTxtDescription = event.target.value;
        }
        else{
            this.commentStr = event.target.value;
        }
        
        this.heighttextarea(); 
    }
    // Bug 	00047365 Fixed By Sudhanshu
    convertToHyperlinks() {
        // Regular expression to find URLs in the plain text
        // const urlPattern = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
        // Bug 00047647 Fixed by Sudhanshu
        const urlPattern = /(?<!<(img|a)\s[^>]*(src|href)=["'])(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
        const hyperlinkedText = this.richTxtDescription.replace(urlPattern, '<a href="$3" target="_blank">$3</a>');
        this.richTxtDescription = hyperlinkedText;

    }

    //Added By Sudhanshu for CR Change ; 47978
    rtaToggleStatus = undefined;
    hasRtaLoaded = true;
    
    // Bug 00047978 Fixed By Sudhanshu For CR Changes
    handleNotes(event){
        const isChecked = event.target.checked;
        this.rtaToggleStatus = isChecked;
        saveRtaToggleStatus({
            rtaToggleStatus: this.rtaToggleStatus
        })
        .then(data => {
            this.handleRtaToggle();
        })
        .catch(error => {
            this.displayError(error);
        })
    }

    getRtaToggleStatus(){
        getRtaToggleStatus({})
        .then(data => {
            this.rtaToggleStatus = data;
        })
        .catch(error => {
            this.displayError(error);
        });
    }
    
   
    handleRtaToggle(){
        const eleToggleBtn = this.template.querySelector('.clsToggleIconPos');
        if (this.rtaToggleStatus)  {
            this.template.querySelector('.notetextareaEdit').classList.remove('hide-toolbar');
            eleToggleBtn.setAttribute('checked', true);
            eleToggleBtn.setAttribute('title', 'Disable Toolbar');
        } else {
            this.template.querySelector('.notetextareaEdit').classList.add('hide-toolbar');
            eleToggleBtn.setAttribute('checked', false);
            eleToggleBtn.setAttribute('title', 'Enable Toolbar');
        }
    }

    textIndex = 0;
    prevVal = '';
    // handle description field changes
    handleChange(event){
        
        this.commentStr = event.target.value;
        this.heighttextarea();  
        if(event.key == "@"){
            this.tagString = '';
        }
        if(event.key == "@" || this.isStillAt){
            
            this.tagString = typeof this.tagString === 'undefined' ? '' : this.tagString;
            this.isStillAt = true;

            // allow only char and number values
            if(event.keyCode >= 65 && event.keyCode <= 90 || event.keyCode >= 97 && event.keyCode <= 122 || event.keyCode == 32 || (event.keyCode >= 48 && event.keyCode <= 57 && event.key != "@")){  //|| event.keyCode >= 96 && event.keyCode <= 111 || event.keyCode >= 186 && event.keyCode <= 222
                this.tagString = this.tagString + event.key;
                this.handleSearchRecordAfterAt();
            }
            // remove char on press of backspace
            if(event.keyCode == 8){
                this.tagString = this.tagString.length > 0 ? this.tagString.substring(0, this.tagString.length - 1) : '';
                this.handleSearchRecordAfterAt();
            }

        }
        this.prevVal = event.target.value.replace(/<p><br><\/p>/g,"\n").replace(/<p>/g,"\n").replace(/<\/p>/g,"").replace(/<br>/g,"\n").replace(/<[^>]*>/g, '');
    }

    // seach records based on string after @
    handleSearchRecordAfterAt(){
        if(this.tagString.length > 2){
            getRelatedData({"searchString": this.tagString, 'searchObjects' : this.searchObjects, 'allTaggedRecords' : JSON.stringify(this.allTaggedRecords)}).then(data => {
                this.lstResult = [];
                this.lstResult = JSON.parse(data);
                if(this.lstResult.length > 0){
                    let hover = this.template.querySelector('.hover');
                    hover.style.display = 'block';
                }else{
                    let hover = this.template.querySelector('.hover');
                    hover.style.display = 'none';
                }
            }).catch(error => {
            });
        }else{
            this.lstResult = [];
        }
    }
    test(event){
      this.key = event.key;
      this.keyCode = event.keyCode;
      this.textIndex = 0;
      if(event.key == "@"){
            this.tagString = '';
        }
        // check pressed key.
        if(event.key == "@" || this.isStillAt){
            
            this.tagString = typeof this.tagString === 'undefined' ? '' : this.tagString;
            this.isStillAt = true;
            

            // allow only char and number values
            if(event.keyCode >= 65 && event.keyCode <= 90 || event.keyCode == 32 || event.keyCode >= 97 && event.keyCode <= 122  || (event.keyCode >= 48 && event.keyCode <= 57 && event.key != "@")){  //|| event.keyCode >= 96 && event.keyCode <= 111 || event.keyCode >= 186 && event.keyCode <= 222
                this.tagString = this.tagString + event.key;
                this.handleSearchRecordAfterAt();
                let val = event.target.value.replace(/<p><br><\/p>/g,"\n").replace(/<p>/g,"\n").replace(/<\/p>/g,"").replace(/<br>/g,"\n").replace(/<[^>]*>/g, '');
                for(let i = 0;i<val.length;i++)
                {
                    if(val[i] == '@')
                    {
                    if(this.prevVal.charAt(i) != '@')
                    {
                        this.textIndex = i
                        break
                    } 
                    }
                }
                
                this.update(event.target,this,this.textIndex);
            }
            // remove char on press of backspace
            if(event.keyCode == 8){
                this.tagString = this.tagString.length > 0 ? this.tagString.substring(0, this.tagString.length - 1) : '';
                this.handleSearchRecordAfterAt();
                if(this.tagString == '' && !this.commentStr.includes('@')){
                    this.isStillAt = false;
                    this.lstResult = [];
                    let hover = this.template.querySelector('.hover');
                    hover.style.display = 'none';
                }
            }
        }else{
            this.template.querySelector('.hover').style.display='none';
        }
      
      
        if(event.keyCode == 8 ){ //|| event.keyCode == 32
        this.template.querySelector('.hover').style.display='none'
        this.handleSearchRecordAfterAt();
        if(this.tagString == '' && !this.commentStr.includes('@')){
            this.isStillAt = false;
            this.lstResult = [];
            let hover = this.template.querySelector('.hover');
            hover.style.display = 'none';
        }
        }
        this.prevVal = event.target.value.replace(/<p><br><\/p>/g,"\n").replace(/<p>/g,"\n").replace(/<\/p>/g,"").replace(/<br>/g,"\n").replace(/<[^>]*>/g, '');
    }
    @track key;
    @track keyCode;
    test1(event){
      if(event.key == '@')
        {
          setTimeout(()=>{
            // this.update(event.target,this,this.textIndex)
          },100)
        }
        else
        {
          if(event.target.keyCode ){
            this.template.querySelector('.hover').style.display='none';
          }else{
            this.test2(event.target,this,this.textIndex);
          }
          
        }
    }
    test2(param1,param2,param3){
        setTimeout(()=>{
          if(this.key == 2 || this.keyCode == 50)
          {
            //this.update(param1,param2,param3);
            this.isStillAt = true;
          }
          
          this.key = '';
          this.keyCode = '' 
        },500)
      }
    update(element,parentThis,index) {
      (function () {
        var properties = [
          'direction',
          'boxSizing',
          'width',
          'height',
          'overflowX',
          'overflowY',
          'borderTopWidth',
          'borderRightWidth',
          'borderBottomWidth',
          'borderLeftWidth',
          'borderStyle',
          'paddingTop',
          'paddingRight',
          'paddingBottom',
          'paddingLeft',
          'fontStyle',
          'fontVariant',
          'fontWeight',
          'fontStretch',
          'fontSize',
          'fontSizeAdjust',
          'lineHeight',
          'fontFamily',
          'textAlign',
          'textTransform',
          'textIndent',
          'textDecoration',
          'letterSpacing',
          'wordSpacing',
          'tabSize',
          'MozTabSize'
        ];
      
        var isBrowser = (typeof window !== 'undefined');
        var isFirefox = (isBrowser && window.mozInnerScreenX != null);
      
        function getCaretCoordinates(element, position, options) {
          if (!isBrowser) {
            throw new Error('textarea-caret-position#getCaretCoordinates should only be called in a browser');
          }
      
          var debug = options && options.debug || false;
          if (debug) {
            var el = parentThis.template.querySelector('#input-textarea-caret-position-mirror-div');
            if (el) el.parentNode.removeChild(el);
          }
          var div = document.createElement('div');
          div.id = 'input-textarea-caret-position-mirror-div';
          document.body.appendChild(div);
      
          var style = div.style;
          var computed = window.getComputedStyle ? window.getComputedStyle(element) : element.currentStyle;
          var isInput = element.nodeName === 'INPUT';
          style.whiteSpace = 'pre-wrap';
          if (!isInput)
            style.wordWrap = 'break-word';
          style.position = 'absolute';
          if (!debug)
            style.visibility = 'hidden';
          properties.forEach(function (prop) {
            if (isInput && prop === 'lineHeight') {
              if (computed.boxSizing === "border-box") {
                var height = parseInt(computed.height);
                var outerHeight =
                  parseInt(computed.paddingTop) +
                  parseInt(computed.paddingBottom) +
                  parseInt(computed.borderTopWidth) +
                  parseInt(computed.borderBottomWidth);
                var targetHeight = outerHeight + parseInt(computed.lineHeight);
                if (height > targetHeight) {
                  style.lineHeight = height - outerHeight + "px";
                } else if (height === targetHeight) {
                  style.lineHeight = computed.lineHeight;
                } else {
                  style.lineHeight = 0;
                }
              } else {
                style.lineHeight = computed.height;
              }
            } else {
              style[prop] = computed[prop];
            }
          });
      
          if (isFirefox) {
            if (element.scrollHeight > parseInt(computed.height))
              style.overflowY = 'scroll';
          } else {
            style.overflow = 'hidden';
          }
          div.textContent = element.value.replace(/<p><br><\/p>/g,"\n").replace(/<p>/g,"\n").replace(/<\/p>/g,"").replace(/<br>/g,"\n").replace(/<[^>]*>/g, '').substring(0, position);
          if (isInput)
            div.textContent = div.textContent.replace(/\s/g, '\u00a0');
          var span = document.createElement('span');
          span.textContent = element.value.replace(/<p><br><\/p>/g,"\n").replace(/<p>/g,"\n").replace(/<\/p>/g,"").replace(/<br>/g,"\n").replace(/<[^>]*>/g, '').substring(position) || '.';
          div.appendChild(span);
      
          var coordinates = {
            top: span.offsetTop + parseInt(computed['borderTopWidth']),
            left: span.offsetLeft + parseInt(computed['borderLeftWidth']),
            height: parseInt(computed['lineHeight'])
          };
      
          if (debug) {
            span.style.backgroundColor = '#aaa';
          } else {
            document.body.removeChild(div);
          }
      
          return coordinates;
        }
      
        if (typeof module != 'undefined' && typeof module.exports != 'undefined') {
          module.exports = getCaretCoordinates;
        } else if (isBrowser) {
          window.getCaretCoordinates = getCaretCoordinates;
        }
      
      }());
      var coordinates = getCaretCoordinates(element, index != 0?index:undefined, { debug: false });
      let hover = parentThis.template.querySelector('.hover');
      //hover.style.display = 'block'
      if(Number(coordinates.top) > 240)
      {
        hover.style.top = "265px"
        hover.style.zIndex  = 1
      }
      else
        hover.style.top = Number(coordinates.top)+40+"px"
        hover.style.left = Number(coordinates.left)+46+"px"
        hover.style.zIndex  = 1
    }

    // handle select record from @ suggestion box.
    handelSelectedRecord(event){
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 

        // replace name with <a> tag
     //   this.commentStr = this.commentStr.replace(new RegExp('@'+this.tagString ,'i'), '<a href="https://' +window.location.host+'/'+this.selectedRecord.Id+'" rel="noopener noreferrer" target="_blank">'+this.selectedRecord.Name + '</a>');
        this.commentStr = this.commentStr.replace(new RegExp('@'+this.tagString ,'i'), this.selectedRecord.Name);
        this.handleAddTaggedRecord(this.selectedRecord);
        this.atTaggedRecords.push({Name:this.selectedRecord.Name, Id:objId, iconName:this.selectedRecord.iconName});
        if(!this.isRichTxtEnable){
        this.heighttextarea();  // UI fix critical 00038073, 1- march
        
        //empty suggestion list and string
        this.lstResult = [];
        // this.tagString = '';

        

        this.commentStr = this.commentStr + ' ';
        this.heighttextarea();  // UI fix critical 00038073, 1- march
        const inputBox = this.template.querySelector('.notetextareaEdit');//Bug #00038272
        inputBox.value = this.commentStr;
        
        inputBox.focus();
        const index = this.commentStr.indexOf(this.selectedRecord.Name) + this.selectedRecord.Name.length;
        }
        // inputBox.setSelectionRange(index, index);
        if(this.isRichTxtEnable)
        {
            try{
            // this.richTxtDescription = this.richTxtDescription.replace(new RegExp('@'+this.tagString ,'i'), this.selectedRecord.Name);
            this.richTxtDescription = this.richTxtDescription.replace(new RegExp('@'+this.tagString ,'i'), this.selectedRecord.Name);
            this.richTxtDescription = this.richTxtDescription + ' ';
            this.heighttextarea();  // UI fix critical 00038073, 1- march
            const inputBox = this.template.querySelector('.notetextareaEdit');//Bug #00038272
            inputBox.value = this.richTxtDescription;
            
            inputBox.focus();
            const index = this.richTxtDescription.indexOf(this.selectedRecord.Name) + this.selectedRecord.Name.length;
            inputBox.setSelectionRange(index, index);
            }
            catch(ex){
                console.log('Error');
            }
        }
        this.tagString = '';
        this.isStillAt = false;
        let hover = this.template.querySelector('.hover');
        hover.style.display = 'none';
    }

    // add selected record to tagged list
    handleAddTaggedRecord(selectedRecord){
        let idAdded = false;
        for(let i = 0; i < this.allTaggedRecords.length; i++){
            if(selectedRecord.Id == this.allTaggedRecords[i].Id){
                idAdded = true; break;
            }
        }
        if(!idAdded){
            this.allTaggedRecords.push({Name:selectedRecord.Name, Id:selectedRecord.Id, iconName:selectedRecord.iconName, objectName : selectedRecord.objectName});
            if(selectedRecord.objectName == 'navpeII_dev18__Pipeline__c') {
                this.addNewDeals(selectedRecord);
            }
            if(selectedRecord.objectName == 'navpeII_dev18__Fundraising__c') {
                this.addNewFundRaising(selectedRecord);
            }
        }
    }

  
    // remove record from tagged record list and if it is on comment then remove anchor tag
    removeRecord(event){
        let selectRecId = [];
        for(let i = 0; i < this.allTaggedRecords.length; i++){
            if(event.detail.name !== this.allTaggedRecords[i].Id)
                selectRecId.push(this.allTaggedRecords[i]);
        }
        this.allTaggedRecords = [...selectRecId];

        let selectRecIdAt = [];
        for(let i = 0; i < this.atTaggedRecords.length; i++){
            if(event.detail.name !== this.atTaggedRecords[i].Id)
            selectRecIdAt.push(this.atTaggedRecords[i]);
        }
        this.atTaggedRecords = [...selectRecIdAt];

        let removedName = event.target.dataset.id;
        if( this.commentStr.includes(removedName)){

            this.commentStr = this.commentStr.replaceAll('<a href="https://' +window.location.host+'/'+event.detail.name+'" rel="noopener noreferrer" target="_blank">'+removedName + '</a>', removedName);
            this.heighttextarea();  // UI fix critical 00038073, 1- march
        }

    }

    // show and hide advance section
    handleAdvance(){
        this.showAdvance = this.showAdvance ? false : true;
    }

    // handle change subject text
    handleChangeSubject(event){
        this.subject =  event.target.value;
        if(event.target.value == ''){
            this.subjectOptions = this.subjectOptionsTemp;
        }else{
            let temp = [];
            for(let opt of this.subjectOptionsTemp){
                if(opt.label.toLowerCase().startsWith(event.target.value.toLowerCase())){
                    temp.push(opt);
                }
            }
            this.subjectOptions = temp;
        }
        if(this.subjectOptions.length == 0){
            this.hideSubjectOption();
        }
        
        for(let followUp of this.followUpList){
            for(let followUpField of followUp.data){
                if( (followUpField.fieldAPI == 'subject' || followUpField.fieldAPI == 'Subject')  && !this.showFollowUp){ //&& followUpField.fieldValue != null && followUpField.fieldValue != ''
                    followUpField.fieldValue = this.subject;
                }
            }
        }
    }

    
    // handle change subject text
    handleChangeSubjectFollowUp(event){
        let temp = [];
        for(let followUp of this.followUpList){
            for(let fields of followUp.data){
                if(fields.lwcFieldClass == event.target.dataset.id){
                    fields.fieldValue = event.target.value;
                }
            }
            temp.push(followUp);
        }
        this.followUpList = [...temp];
        //this.followUpTask.subject =  event.target.value;

        if(event.target.value == ''){
            this.subjectOptions = this.subjectOptionsTemp;
        }else{
            let temp = [];
            for(let opt of this.subjectOptionsTemp){
                if(opt.label.toLowerCase().startsWith(event.target.value.toLowerCase())){
                    temp.push(opt);
                }
            }
            this.subjectOptions = temp;
        }
        if(this.subjectOptions.length == 0){
            this.hideSubjectOption();
        }
    }

    // handle if followUp task is open or close
    handleClickFollowupTask(){
        this.showFollowUp = !this.showFollowUp;
    }

    handleChangeDate(event){
        if(event.currentTarget.dataset.name == 'StartDateTime'){
            adjustEventStartEndDate({startDate: event.target.value,})
            .then(data => {
                for (let i = 0; i < this.otherFields.length; i++) {
                    if( this.otherFields[i].fieldType == 'DATETIME' && this.otherFields[i].fieldAPI == 'EndDateTime'){
                        this.otherFields[i].dateTimeValue = data;
                    }
                }
            })
            .catch(error => {});
        }
    }
   
 @track isValidActivityDate = true;
    handleChangeEventDate(event){
        if(event.currentTarget.dataset.name == 'ActivityDate'){
            if(event.target.value === null){
                this.isValidActivityDate = false;
            }else{
                this.isValidActivityDate = true;
            }
        }

        if(event.currentTarget.dataset.name == 'StartDateTime'){
            for (let i = 0; i < this.otherFields.length; i++) {
                if( this.otherFields[i].fieldType == 'DATE' && this.otherFields[i].fieldAPI == 'EndDateTime'){
                    this.otherFields[i].dateValue = event.target.value;
                }
            }
        }
    }

    handleAllDayEvent(event){
        this.isLoading = true;
        //IsAllDayEvent
        var allDayFieldAPI = 'IsAllDayEvent';
        var startFieldAPI = 'StartDateTime';
        var endFieldAPI = 'EndDateTime';
        if(event.currentTarget.dataset.name.toUpperCase() == allDayFieldAPI.toUpperCase()){
            if(event.target.checked){
                getTodayDate({})
                .then(data => {
                    for (let i = 0; i < this.otherFields.length; i++) {
                        if(this.otherFields[i].fieldAPI.toUpperCase() === startFieldAPI.toUpperCase() || this.otherFields[i].fieldAPI.toUpperCase() === endFieldAPI.toUpperCase()){
                            this.otherFields[i].fieldType = 'DATE';
                            this.otherFields[i].isDateTime = false;
                            this.otherFields[i].isDate = true;
                            this.otherFields[i].isRequired = true;
                            this.otherFields[i].dateValue = data;
                        } 
                        
                    }
                    this.isLoading = false;
                })
                .catch(error => {this.isLoading = false;});
            }else{
                getEventDateTime({})
                .then(data => {
                    for (let i = 0; i < this.otherFields.length; i++) {
                        if(this.otherFields[i].fieldAPI.toUpperCase() === startFieldAPI.toUpperCase() || this.otherFields[i].fieldAPI.toUpperCase() === endFieldAPI.toUpperCase()){
                            this.otherFields[i].fieldType = 'DATETIME';
                            this.otherFields[i].isDateTime = true;
                            this.otherFields[i].isDate = false;
                            this.otherFields[i].isRequired = true;
                            if(this.otherFields[i].fieldAPI.toUpperCase() === startFieldAPI.toUpperCase()){
                                this.otherFields[i].dateTimeValue = data[0];
                            }
                            if(this.otherFields[i].fieldAPI.toUpperCase() === endFieldAPI.toUpperCase()){
                                this.otherFields[i].dateTimeValue = data[1];
                            }
                           
                        } 
                        
                    }
                    this.isLoading = false;
                })
                .catch(error => {this.isLoading = false;});
            }
            
        }
        else{
            this.isLoading = false;
        }
        
    }
  

    /************ Phase 2 changes Quick Create functionality* *************/
    @track defaultRecordType = '';
    @track isRequired = true;
    handleSave() {
        if(this.getAllNewTaggedRecords()) {
            this.isShowModal = false;
            this.isQuick = true;
        }
        else {
            this.handleDealTeam();
        }
    }

    //Method to take all @strings and create  new Object with QUick Create Data

    getAllNewTaggedRecords() {
        this.newTaggList = [];
        let comments = this.commentStr.replace( /(\r\n|\n|\r)/gm, ' ');
        comments = comments.replace(/(<([^>]+)>)/gi, "");//00047294 - Fixed by Deepak Rich Text area
        let newCreateTaggedRecords = [];
        if(comments == '') {
            return false;
        }
        else{
            let commentStringArray = [];
            let indexLocal = 0;
            commentStringArray = comments.split(' ');
            for(var d in commentStringArray) {
                let commentVal = commentStringArray[d];
                if(commentVal.startsWith('@') && commentVal.substring(1) !='') {
                    newCreateTaggedRecords.push({
                        index : indexLocal,
                        name : commentVal.substring(1),
                        isToBeCreated : false,
                        objectType : '',//(indexLocal%2 == 0)? 'Account':'Contact',
                        accountRecType : this.defaultRecordType,
                        accountId : '',
                        searchAccountText : '',
                        showAccountRecType : false,//(indexLocal%2 == 0)?true:false,
                        showAccountSearch : false,//(indexLocal%2 != 0)?true:false
                        objectTypeOptions : this.getSelectedOptionsList()
                    })
                    indexLocal++;
                }
            }
            this.newTaggList = [...newCreateTaggedRecords];
            return (newCreateTaggedRecords.length>0);
        }
    }

    getSelectedOptionsList() {
        //alert(this.objectTypeOptions);
        return this.objectTypeOptions;
    }

    updateCommentsData(newRecords) {
        let commentData = this.commentStr;
        let commentStringArray = [];
        commentStringArray = commentData.split(' ');
        let updatedString = '';
        //Fixed for Bug #38082
        let successRecNameList=[];
        newRecords.forEach(newRec =>{
            successRecNameList.push(newRec.successRecordName);
        })
        for(var d in commentStringArray) {
            successRecNameList.forEach(sRecName =>{
                commentStringArray[d]=commentStringArray[d].replace('@'+sRecName,sRecName);
            })
            updatedString+=commentStringArray[d]+' ';
        }//Fixed for Bug #38082
        this.commentStr = '';
        this.commentStr = updatedString;
        
        if(this.isRichTxtEnable)
        {
            let richCommentData = this.richTxtDescription;
            let richCommentStringArray = [];
            richCommentStringArray = richCommentData.split(' ');
            let richTxtString = '';
            //Fixed for Bug #38082
            let successRecNameList1=[];
            newRecords.forEach(newRec =>{
                successRecNameList1.push(newRec.successRecordName);
            })
            for(var d in richCommentStringArray) {
                successRecNameList1.forEach(sRecName =>{
                    richCommentStringArray[d]=richCommentStringArray[d].replace('@'+sRecName,sRecName);
                })
                richTxtString+=richCommentStringArray[d]+' ';
            }//Fixed for Bug #38082
            this.richTxtDescription = '';
            this.richTxtDescription = richTxtString;
        }
        this.heighttextarea();  // UI fix critical 00038073, 1- march
    }

    // Method to handle the change in name of record
    handleChangeInRecordName(evt) {
        let currentId = evt.currentTarget.dataset.id;
        let selectedValue = evt.target.value;
        this.newTaggList[currentId].name = selectedValue;

    }

    // Method to get all the record types available for User and the default Id

    getActRecordType() {
        let actRecTypeLocal = [];  //critical Fix Nikita S
        userAvailableAccountRecType({

        })
        .then(res =>{
            if(res.length) {
                for(var d in res) {
                    actRecTypeLocal.push({
                        label:res[d].recTypeLabel,
                        value:res[d].recTypeId
                    })
                    if(res[d].isDefaultRecordType) {
                        this.defaultRecordType = res[d].recTypeId
                    }
                }
            }
        })
        .catch(err=>{
        })
        this.actOptions = actRecTypeLocal;
    }

    //Method to handle Record Type change of Account for Quick Create functionality
    handleRecTypeChange(evt){
        let currentId = evt.currentTarget.dataset.id;
        let selectedOption = evt.detail.value;
        this.newTaggList[currentId].accountRecType = selectedOption;
    }

    handleObjectSelection(evt) {
        let currentId = evt.currentTarget.dataset.id;
        let selectedOption = evt.detail.value;
        this.newTaggList[currentId].objectType = selectedOption;
         if(selectedOption == 'Account') {
            this.newTaggList[currentId].showAccountRecType = true;
            this.newTaggList[currentId].showAccountSearch = false;

        }
        else if(selectedOption == 'Contact') {
            this.newTaggList[currentId].showAccountRecType = false;
            this.newTaggList[currentId].showAccountSearch = true;
        }

    }

    // method to handle CheckBox selection of Quick Create functionality

    handleCHeckBoxSelect(evt) {
        let selectedRecordId = evt.currentTarget.dataset.id;
        this.newTaggList[selectedRecordId].isToBeCreated = evt.target.checked
    }

    // Method that looks into the LookUp Component event handler

    handleSelectedRecord(evt) {
       var receivedEventObj = {};
       receivedEventObj = JSON.parse(evt.detail);
       this.newTaggList.forEach(taggedRecord =>{
        if(taggedRecord.index == receivedEventObj.id) {
            let receivedDataObj = receivedEventObj.data;
            taggedRecord.accountId = (receivedDataObj.Id != undefined)?
                receivedDataObj.Id:'';
            taggedRecord.searchAccountText = receivedEventObj.searchKey
            
        }
       })
    }

    //Method to close the Quick Create Modal
    closeQuickAccountContact() {
        this.showQuickCreateModal = false;
        this.isShowModal = true;
    }


    // Method to create the selected Quick Create records
    quickCreateRecords() {
        const childDisplayState = this.template.querySelectorAll('c-navatar-single-lookup-lwc');
        this.isLoading = true;
        let selectedArrayList = [];
        let isRecordNameEmpty = false;
        let isobjectTypeEmpty = false;
        this.newTaggList.forEach(taggedRecord =>{
           if(taggedRecord.isToBeCreated) {
            if(taggedRecord.name == '' ||taggedRecord.name == null){
                isRecordNameEmpty = true;
                return;
            }
            if(taggedRecord.objectType == '' ||taggedRecord.objectType == null){
                isobjectTypeEmpty = true;
                return;
            }
            if(taggedRecord.searchAccountText=='' && taggedRecord.accountId==''){
                for(let eachPick of childDisplayState){
                    if (taggedRecord.index == eachPick.newCreatedRecordId){
                        taggedRecord.searchAccountText=eachPick.searchTerm;
                    }
                }
            }
            selectedArrayList.push(taggedRecord);
           }
        })

        if(isRecordNameEmpty){
            const errorToast = new ShowToastEvent({title: 'Error', message: 'Review the errors on this page',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
            return;
        }   
        
        if(isobjectTypeEmpty){
            // Bug 00047932 Fixed by Sudhanshu
            const errorToast = new ShowToastEvent({title: 'Error', message: 'Select atleast one object type.',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
            return;
        }
        

        if(selectedArrayList.length == 0) {
            const errorToast = new ShowToastEvent({title: 'Error', message: 'Select atleast a record.',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
            return;
        }
        if (selectedArrayList.length && !this.checkRecords()) {
            saveNewAccountContactRecords({
                jsonCreateString : JSON.stringify(selectedArrayList)
            }) 
            .then(res=>{
                if(res.successRecords.length) {
                    this.updateCommentsData(res.successRecords);
                    this.addCreatedRecords(res.successRecords);
                    const successToast = new ShowToastEvent({title: 'Success', message: 'Record was created.',variant: 'success',mode: 'dismissable'});
                    this.dispatchEvent(successToast);
                }
                if(res.errorObject.length) {
                    const errorToast = new ShowToastEvent({title: 'Error', message: 'Error in creating Records',variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(errorToast);
                }
            })
            .catch(err =>{
                this.isLoading = false;
                const errorToast = new ShowToastEvent({title: 'Error', message: 'Error in creating Records',variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(errorToast);
            })
        }
    }

    //Method to add the newly created records in the allTaggedList for references in Suggested tags and Deal and Fund Team functionality
    addCreatedRecords(newRecords) {
        newRecords.forEach(newRec =>{
            this.allTaggedRecords.push({
                objectName: newRec.objectType,
                Name: newRec.successRecordName,
                isUser: null,
                Id: newRec.successRecordId,
                iconName: (newRec.objectType == 'Account')?'standard:account':'standard:contact'
            })
        })
        console.log('tagged records '+JSON.stringify(this.allTaggedRecords));
        this.addandSaveToActivity();
        
    }
    // Method to re tag the newly created savered records.

    addandSaveToActivity() {
        let commentData = this.commentStr;
        let commentStringArray = [];
        commentStringArray = commentData.split(' ');
        //Fixed for Bug #38082 started 
        let updatedString = '';
        for(var d in commentStringArray) {
            updatedString+=commentStringArray[d]+' ';//.replace('@','')
        }
        //Fixed for Bug #38082 ended
        saveRecord({"commentStr" : updatedString, 
                    "allTaggedRecords" : JSON.stringify(this.allTaggedRecords),
                    "recordId" : this.recordId,
                    "atTaggedRecord" : JSON.stringify(this.atTaggedRecord),
                    "extraTaggedRecord" : JSON.stringify(this.extraTaggedRecords),
                    "objectName" : this.objectName,
                    "otherFielddData" : JSON.stringify(this.otherFields),
                    "currentObject" : this.objectName,
                    "subject" : this.subject,
                    "taskType" : this.taskType,
                    "isDescriptionUsed" : this.isDescriptionUsed,
                    "followUpTasksStr" : JSON.stringify(this.followUpList),
                    "isSaveFollowup" : false,
                    "isRichTxtEnable" : this.isRichTxtEnable,
                    "richTxtDescription" : this.richTxtDescription
        })
        .then(dataList => {
            let data=dataList[0];
            if(!data.includes('Error')){
                console.log('updated data '+JSON.stringify(this.allTaggedRecords));
                
                
            }else{
                let msg = data.split(':')[1];
                if(!data.includes('Review the errors on this page')){
                    const event = new ShowToastEvent({title: 'Error',message: data,variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }else{
                    const event = new ShowToastEvent({title: 'Error',message: msg.split('.')[1],variant: 'error',mode: 'dismissable'});
                    this.dispatchEvent(event);
                }
            }
//alert('saved');
            this.isLoading = false;
            this.handleDealTeam();

        })
        .catch(err=>{
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(event);
            this.isLoading = false;
            this.handleDealTeam();
        })

    }    

    // Method to check if the selected records does not have empty field
    checkRecords() {
        let fieldErrorMsg = 'Please Complete the field to continue';
        let isError = false;
        try {
            this.template.querySelectorAll("lightning-input").forEach(item => {
               let comboboxId = item.id.split('-')[0];
               if(this.newTaggList[comboboxId].isToBeCreated) {
                if(item.value == '' || item.value == undefined) {
                    item.setCustomValidity(fieldErrorMsg);
                    isError = true;
                }
                else {
                    item.setCustomValidity('');
                }
               }
               item.reportValidity();
               
            });
            return isError;
        }catch (e) {
            return false;
        }
        
    }
    //////// Phase 2 Quick Create

    /********************Deal Team  code******************* */
    @track newDealsTaggedList = [];
    @track contactTaggedRecords = [];
    @track isRedirectToParentScreen = true;
    //{label: 'None' , value :''},
    objectTypeOptions = [{label : 'Account', value : 'Account'}, {label : 'Contact', value : 'Contact'}];
    //Method to open Deal Team creation modal
    openDealTeamModal() {
        let contactTagged = [];
        this.allTaggedRecords.forEach(taggedRec =>{
            if(taggedRec.objectName == 'Contact') {
                contactTagged.push(taggedRec.Id);
            }
        })
        this.selectedSuggestedData.forEach(ssRec =>{
            if(ssRec.objectName == 'Contact') {
                contactTagged.push(ssRec.Id);
            }
        })
        this.atTaggedRecords.forEach(atRec =>{
            if(atRec.objectName == 'Contact') {
                contactTagged.push(atRec.Id);
            }
        })
        this.newTaggList.forEach(atRec =>{
            if(atRec.objectName == 'Contact') {
                contactTagged.push(atRec.Id);
            }
        })
        this.showSuggestedTagsModal = false;
        // alert(contactTagged.length);
        if(this.newDealsTaggedList.length && contactTagged.length) {
            //alert('Inside if open Deal Team');
            this.isaDealTeam = true;
            // this.getAllDealTeamContacts()
        }
        else if(this.newFundRaising.length && contactTagged.length) {
            this.openFundTeamModal();
        }
        else{
            if(!this.isRedirectToParentScreen) {
                window.location.reload();
            }
            else {
                 if(this.isNewNote==true)
                 {
                    this.meetingCallEmailViewpopup(); //Notes view Pop up on new Note Added by Manonit
                 }
                 else{
                    this.navigateScreen();// //Notes view Pop up for other functionality
                 }
                  
            }
        }
    }

    // Method to navigate to parent component screen without reload Bug Id - 44948
    navigateScreen() {
        if(this.isNewNote==true)
        {
            this.meetingCallEmailViewpopup(); //Manonit Change
            this.isaddContactToFundraising=false;
            this.isaddContactToFundraising=false
        }
        else{
            this.hideRecordModal(); //Notes view Pop up for other functionality
        }

                 
        //this.hideRecordModal();
    }
    closePopup(){
        this.hideRecordModal();
    }

    //method handles the next flow after dela team modal closes
    cancelDealTeamCreate() {
        this.isaDealTeam=false //45372 and 00045388 Bug fix By Manonit
        this.openFundTeamModal();
    }
    
    //method that takes in the deal records and pushes it into the list.
    addNewDeals(dealRecord) {
        
        let existingLength = (this.newDealsTaggedList.length)?this.newDealsTaggedList.length : 0;
        this.newDealsTaggedList.push({
            index : existingLength,
            recId : dealRecord.Id==undefined?dealRecord.recId:dealRecord.Id,//Fixed for Bug #00035103
            recName : dealRecord.Name
        })
    }

    /*****************Fund Team Create********************* */

    @track newFundRaising = [];
    
    // handle the fund team open modal mechanism
    openFundTeamModal() {  
        let contactTagged = []; 
        this.isaDealTeam = false;
        this.allTaggedRecords.forEach(taggedRec =>{
            if(taggedRec.objectName == 'Contact') {
                contactTagged.push(taggedRec.Id);
            }
        })
        this.selectedSuggestedData.forEach(ssRec =>{
            if(ssRec.objectName == 'Contact') {
                contactTagged.push(ssRec.Id);
            }
        })
        this.atTaggedRecords.forEach(atRec =>{
            if(atRec.objectName == 'Contact') {
                contactTagged.push(atRec.Id);
            }
        })
        if(this.newFundRaising.length && contactTagged.length) {
            this.isaddContactToFundraising = true;
            // this.getAllFundTeamContacts();
        }
        else{
            if(!this.isRedirectToParentScreen) {
                console.log('inside openFund Team if')
                
               window.location.reload();
           }
            else {
               // this.navigateScreen();
               if(this.isNewNote==true)
               {
                  this.meetingCallEmailViewpopup(); //Notes view Pop up on new Note Added by Manonit Bug Id - 44948
               }
               else{
                  this.navigateScreen();// //Notes view Pop up for other functionality
               }
               
            }
        }
        
    }
    // handle new funds added to tagged records

    addNewFundRaising(fundRecord) {
        let existingLength = (this.newFundRaising.length)?this.newFundRaising.length : 0;
        this.newFundRaising.push({
            index : existingLength,
            recId : fundRecord.Id==undefined?fundRecord.recId:fundRecord.Id,//Fixed for Bug #00038202
            recName : fundRecord.Name
        })
    }
   
   
    /**************************************Suggested Tags ****************************************** */
    @track showSuggestedTagsModal = false;
    @track suggestedRecords = [];
    @track selectedSuggestedData = [];
    @track openDealHelper = false;
    @track suggestedData = {};
    selectedRows=[];
    @track suggestedRecordsData = [];

    // Get the Detail Accordion data of Created By and Date
    getDetailScreenData() {
        getActivityData({
            activityId : this.recordId,
            objectName : this.objectName
        })
        .then(res=>{//changed for Bug # :00039740:started
            if(res[0]!=undefined){
            let createdDate = ((res[0].CreatedBy==undefined || res[0].CreatedBy==null)? '' :new Date(res[0].CreatedDate));//FIx for Bug #00040046
            this.suggestedData = res[0];
            this.suggestedData.createdDateString = res[0].ActivityDate;//Bug #00039983
            // Bug 00047559 Fixed by Sudhanshu
            this.suggestedData.CreatedByName = ((res[0].CreatedBy==undefined || res[0].CreatedBy==null)? '' :res[0].Owner.Name);//FIx for Bug #00040046
            if(this.suggestedData.createdDateString=='Invalid Date'){
                this.suggestedData.createdDateString='';
            }
            this.commentStr = res[0].Description;
        }
        else{
            this.suggestedData.createdDateString ='';
            this.suggestedData.CreatedByName ='';
        }//changed for Bug #: 00039740: ended
        })
        .catch(err=>{
            const errorToast = new ShowToastEvent({title: 'Error', message: err,variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
        })
    }

    
    handleGetSuggestions(){
        this.isLoading = true;
        this.extraTaggedRecords = [];
        var potentialObjects=this.searchObjects;
        if(this.openTag){
            // Bug 00042500, 00045901 fixed by Sudhanshu on 26-04-2024
            const jsonDataArray = JSON.parse(this.searchObjects);
            potentialObjects = JSON.stringify(jsonDataArray.filter(item => item.objectName === 'Account' || item.objectName === 'Contact'));
            
        }
     
        
        if(this.commentStr.length >2){
        let specialsChar =/[-#%_+=*,?/"|\":<>[\]{}!^~`\\(')\'.;@&$]/;
        let exclusionList = this.pkgStr.split(" ");
        const lowercasedList = exclusionList.map(name => name.toLowerCase());
        let commentSplit = this.commentStr.replaceAll('\n',' ').trim().split(" ");
        let comStrList = commentSplit.filter((n) => n.length > 3 && n.length < 255 && !specialsChar.test(n));
        //  specialsChar code
        let specComList = commentSplit.filter((n) => n.length > 3 && n.length < 255 && specialsChar.test(n));
        
        let webLinkExp = /[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?/gi;
        let webLinkregex = new RegExp(webLinkExp);
        let numSpec = /^[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~\d]*$/g;
        for(let i of specComList){
            let specC = i;
            if (specC.match(webLinkregex)) {
                continue;
            }
            if (numSpec.test(specC)) {
                continue;
            }

            if(specialsChar.test(specC)){
                specC = specC.replace(/[^a-zA-Z0-9 ]/g, "");
                console.log('2688',specC);
               if(specC.length>3){
                comStrList.push(specC);
            }
            }
            console.log('2689',specC);
            if(specialsChar.test(i)){
                specC = i.replace(/[(-)]/g, "\\$&");//Bug fixed - 00041270 Phase 3
            }
            console.log('2685',specC,specC.length);
            comStrList.push(i);
        }
        const output1 = comStrList.filter(element => !lowercasedList.includes(element.toLowerCase()));
        let finalComStr = output1.join(' ');
        getSuggestions({
            "commentStr": finalComStr, 
            'searchObjects' : potentialObjects, 
            'allTaggedRecords' : JSON.stringify(this.allTaggedRecords)
        }).then(data => {
            
            if(JSON.parse(data).length > 0){
                this.setSuggestedTableData(data);
                this.isLoading = false;
                this.isShowModal = false;
                this.isQuick = false;
                this.showSuggestedTagsModal = true;
                
            }else{
                this.isShowModal = false;
                this.isQuick = false;
                this.isLoading = false;
                this.openDealTeamModal();
            }
            
        }).catch(error => {
            this.isLoading = false;
        });
        }
        else{
            this.openDealTeamModal();
        }
    }

    // Sudhanshu Serach Suggested Tag functionality Start here

    // handle the Suggested Table Data
    setSuggestedTableData(suggestedData) {
        this.suggestedRecords = [];
        this.suggestedRecordsData = [];
        this.itemCount = 0;
        let suggestedDataList = [];
        suggestedDataList = JSON.parse(suggestedData);
        for(var d in suggestedDataList) {
            // bug 	00047558 fixed by Sudhanshu
            this.suggestedRecords.push({
                id : parseInt(d),
                Deals : suggestedDataList[d].Name,
                name : suggestedDataList[d].objectName,
                dynamicIcon: suggestedDataList[d].iconName,
                recId : suggestedDataList[d].Id,
                objectName : suggestedDataList[d].objectName,
                objectApiName : suggestedDataList[d].objectApiName,
                isUser : suggestedDataList[d].isUser,
                isSelect : false,
            })
        }
        // this.masterList = this.suggestedRecords;
        this.suggestedRecordsData = this.suggestedRecords;
        this.totalCount=this.suggestedRecords.length;
    }


    preSelectedRows = [];
    masterList = [];
    preSelectedRecIds = [];
    selectedRecs = [];
    @track suggestedFilteredData = [];
    searchValue = '';
    @track isBlur =false;
    @track errMsg=false;
    @track globalCheck = false;
    @track errSrch = false;

    handleBlurSearch(event){
        // alert('Blur called');
        this.searchValue = event.target.value.trim();
        console.log('SearchTerm',this.searchValue.length);
        this.isBlur=true;
        this.handleSearch(event);
    }

    handleTagGlobalCheck(evt){ 
        this.errMsg = false; 
        this.errSrch = false;
        // this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('dash-filter');
        this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.add('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('slds-hide');
        this.globalCheck = evt.target.checked;
        this.suggestedRecords.forEach(rec =>{
            rec.isSelect = evt.target.checked
        });
        this.selectedSuggestedData = this.suggestedRecords.filter(item => {
            return (item.isSelect==true);
        });
        this.suggestedRecordsData=this.suggestedRecords;
        this.itemCount=this.selectedSuggestedData.length;
        this.handleRowSelection();  //00044547 fixed by raju 24-05-2024
    }

    handleRowSelection(){
           //00044547 fixed by raju 24-05-2024
           try
           {
               setTimeout(() => {
               
               const element = this.template.querySelectorAll('.checkboxCls');
               const row = this.template.querySelectorAll('.rowCls');
               
                   for(let i = 0; i < element.length; i++){
                   
                   // element[i].addEventListener("click",()=>{
                       //alert("testing")
                       if(element[i].checked){
                           row[i].classList.add("selected");
                       }
                       else{
                           row[i].classList.remove("selected");
                       }
                   // })
                   }
               
               }, 200);
           }
           catch(ex){
               console.log(ex);
           }  
    }

    handleSearch(event)
    {
        this.searchValue = event.target.value.trim();
        if(this.suggestedFilteredData.length == 0)
        {
            this.suggestedFilteredData = this.suggestedRecords;
        }
        if(event.keyCode === 13 || this.isBlur == true)
        {
            this.errSrch = false;
            this.errMsg = false;
            this.isBlur=false;
            let searchTerm = this.searchValue;
            if(searchTerm.length > 1){
                console.log('suggestedFilteredData--->'+JSON.stringify(this.suggestedFilteredData));
                this.suggestedRecordsData = this.suggestedFilteredData.filter(result =>
                       result.Deals.toLowerCase().includes(searchTerm.toLowerCase())
                );
                if(this.suggestedRecordsData.length == 0)
                {
                    this.errMsg = true;
                }
            }
            else if(searchTerm.length == 0)
            {
                this.suggestedRecordsData = this.suggestedRecords;
            }
            else{
                this.suggestedRecordsData=[];
                this.errSrch = true;
            }
        }
        else if(event.target.value.length === 0) {
            this.errMsg = false;
            this.errSrch = false;
            this.suggestedRecordsData = this.suggestedRecords;
        }

          //00044547 fixed by raju 24-05-2024
        this.handleRowSelection();
          
        
    }

    // handle to get the suggested data
    getSelectedSuggestedRecords(evt) {
        let selectedTaggedRows = evt.currentTarget.dataset.id;
        this.suggestedRecords[selectedTaggedRows].isSelect = evt.target.checked;
        
        this.selectedSuggestedData = this.suggestedRecords.filter(item => {
            return (item.isSelect==true);
        });
        this.itemCount=this.selectedSuggestedData.length;
        if(!this.selectedSuggestedData.length){
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.add('slds-show');
            //alert("one");
        }
        else{
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.add('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.add('slds-hide');
            //alert("two");
        }
        if(this.suggestedRecords.length === this.itemCount){
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId1"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.add('slds-show');
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('slds-hide');
            //alert("three");
            this.globalCheck = true;
        }
        else{
            this.globalCheck = false;
        }

            //00044547 fixed by raju 24-05-2024
            this.handleRowSelection();

       
    }

    handleRowAction(event)
    {
        const action = event.detail.action;
        const row = event.detail.row;
           if (action.name === 'crossButton'){
               console.log('before suggestedRecords---->'+JSON.stringify(this.suggestedRecords));
               this.selectedRecs = this.selectedRecs.filter(item => {
                   return (item.recId != row.recId);
               });
                let recIds = [];
                this.selectedRecs.forEach(currentItem => {
                    recIds.push(currentItem.recId);
                });
                this.itemCount = this.selectedRecs.length;
                this.preSelectedRecIds = recIds;

                this.suggestedRecords = this.masterList.filter(item => {
                   return (!this.preSelectedRecIds.includes(item.recId));
                });
                this.suggestedRecordsData = this.suggestedRecords;
                console.log('after suggestedRecords---->'+JSON.stringify(this.suggestedRecords));
           }
    }

    // Sudhanshu Serach Suggested Tag functionality End here

    // handle the global checkbox to select or deselect of Deal team creation
    handleSuggestedRecordsSave() {
        this.isLoading = true;
        if(!this.selectedSuggestedData.length) {
            // Bug 00046455 fixed by Sudhanshu on 05-07-2024
            const event = new ShowToastEvent({title: 'Error',message: 'Select atleast a record.',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(event);
            return;
        }
        let suggestedIds =[];
        this.selectedSuggestedData.forEach(suggedtedRec =>{
            suggestedIds.push({
                Name : suggedtedRec.Deals,
                Id : suggedtedRec.recId,
                iconName : suggedtedRec.iconName,
                objectName : suggedtedRec.objectName,
                isUser : suggedtedRec.isUser
            })

        })
        saveSuggessionRecods({
            "commentStr" : this.commentStr, 
            "allTaggedRecords" : JSON.stringify(this.allTaggedRecords),
            "recId" : this.recordId,
            "extraTaggedRecord" : JSON.stringify(suggestedIds),
            "objectName" : this.objectName,
            "isDescriptionUsed" : this.isDescriptionUsed,
            "savedFollowUpIds" : this.savedFollowUpIds
         })
         .then(res =>{
            // Bug 00047565,00047754,00047756 Fix by Sudhanshu 
            if(!res.includes('Error')){
                //Bug # 35096:Started
                let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                            const event = new ShowToastEvent({title: 'Success',message: '"{0}{1}" was saved.',//this.objectName + -> Removed for Bug #00038075
                            variant: 'success',
                            mode: 'dismissable', 
                            messageData: [
                                '',
                                {
                                    // Bug 00046852 fixed by Sudhanshu on 30-07-2024
                                    url: '/lightning/n/navpeII_dev18__View_Interaction?c__params='+allIteractionsParams,
                                    label: this.subject,
                                }
                            ]});
                //Ended
                this.dispatchEvent(event);
                this.isLoading = false;
                this.openDealHelper = true;
                this.isInitRun = false;
                this.fetchRecordData();
                this.selectedSuggestedData.forEach(suggedtedRec => {
                    // Bug 00047558 fixed by Sudhanshu
                    if (suggedtedRec.objectApiName == 'navpeII_dev18__Pipeline__c') {
                        this.addNewDeals(suggedtedRec);
                    }
                    if (suggedtedRec.objectName == 'Fundraising') {
                        this.addNewFundRaising(suggedtedRec);
                    }
                })
                // this.openDealTeamModal();
            }
            else 
            {
                let err = res.split(':');
                const event = new ShowToastEvent({title: 'Error:',message: err[1],variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(event);
            }
         })
         .catch(err =>{
            const errorToast = new ShowToastEvent({title: 'Error',message: 'Error in Tagging Records',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
            this.isLoading = true;
         })
        
    }

    // method for check Suggested tag enable or not
    checkSuggestedEnable(){
        checkSuggestedTag()
            .then(data => {
                if(data == 'true'){
                    this.handleGetSuggestions();
                }else{
                    this.isShowModal = false;
                    this.isQuick = false;
                    this.isLoading = false;
                    this.openDealTeamModal();
                }
            })
            .catch(error => {
                // this.displayError(error);
            });
    }

    // handle the global checkbox to select or deselect of Deal team creation
    closeSuggestedModal() {
        this.openDealTeamModal();
    }

    @track islistvisible = false;
    @track isaDealTeam = false;
    value = 'deal';
   
    /*add deal*/
    selectedItems = [];
    value = '';
    finalOption = [];
    /* @ save*/
    @track Item = false;


    closeQuickAccountContact(){
        this.isQuick = false; 
    }

    value = 'Select Value';
   

    handleDealTeam(){
        if(this.commentStr !='') {
            //alert('in here')
            this.getDetailScreenData();
            if(!this.openTag)
            {
                this.checkSuggestedEnable();
            }
            else{
                this.handleGetSuggestions();
            }
            
        }
        else {
            //alert('out here')
            this.isShowModal = false;
            this.isQuick = false;
            this.openDealTeamModal();

        }
        
    }
    /*add Deal*/
    addDeal(){
        this.isQuick = false;
        this.isModalOpen = false;
        this.isDiscover = true;  
    }
   
    handleChange(event){
        setTimeout(()=>{
            this.islistvisible = false;
           this.value ="";
        },200)
    }



    @track isModalOpen = false;
    @track isDiscover = false;
    @track followuptaskremove = false;
    @track moreTask = false;
    @track isaddContactToFundraising = false;
    isFollowup=false;
    itemCount= 0;
    subject='';
    columns1 = columns1;
    columns2 = columns2;
    tempOptions = []
    
   
    @api
    openModal(recordsID) {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpenview = false;
        this.recordId=recordsID;
        this.isModalOpen = true;
        
    }
    closeModal() {
        this.isModalOpen = false;
        this.isDiscover = false;
        this.isaDealTeam = false;
        this.isaddContactToFundraising = false;
        
    }
    isTag = false;
    handleTag() {
        this.isTag = !this.isTag;
    }
   
    handleFollowup(){
        this.isFollowup = !this.isFollowup;
        this.followuptaskremove = true;
    }
    statusValue = 'Completed';
    priorityValue = 'Normal';

    get options() {
        return [
            { label: 'Completed', value: 'Completed' },
        ];
    }

    get priority() {
        return [
            { label: 'Normal', value: 'Normal' },
        ];
    }
   
    // Sudhanshu Changes Start Here

    get acceptedFormats() {
        return ['.pdf', '.png','.jpeg', '.jpg', '.ppt','.xlsx','.docx'];
    }
    @api filesList
    handleUploadFinished(event) {
        this.filesList = event.detail.files;
        console.log("No. of files uploaded : " + this.filesList.length);
    }
    /* ------Import Note Functionality Started Here------- */

 
    
    /* For Close import Popup */
    closeImportModal(event) {
        // this.importID=event.detail.importID;
        this.isShowModal = true;
        this.isframe = false;
        this.isLoading = true;
        this.handleRefresh();
        
        
        
    }
  /* For refresh notes input box value with imported file content */
    handleRefresh() {
        if (this.importId != '' || this.importId != undefined) {
            getRecord({
                ID: this.importId,
            })
                .then(result => {
                    if(this.isRichTxtEnable){
                        if (this.richTxtDescription == null || this.richTxtDescription == '') {
                            this.richTxtDescription = result;
                        }
                        else {
                            this.richTxtDescription = this.richTxtDescription + '<br>' + result;
                        }

                        if (this.commentStr == null || this.commentStr == '') {
                            this.commentStr = result.replace(/<br\s*\/?>/gi, '\n');
                        }
                        else {
                            this.commentStr = this.commentStr + '\n' + result.replace(/<br\s*\/?>/gi, '\n');
                        }
                    }
                    else{
                        if (this.commentStr == null || this.commentStr == '') {
                            this.commentStr = result.replace(/<br\s*\/?>/gi, '\n');
                        }
                        else {
                            this.commentStr = this.commentStr + '\n' + result.replace(/<br\s*\/?>/gi, '\n');
                        }
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    this.commentStr = '';
                    this.isLoading = false;
                });
        }
        this.hasRtaLoaded = true; // Bug 00048195 fixed in dev org.
    }

        /* For fetch the import ID */
    handleImportID() {
        getImportID()
            .then(result => {
                this.importId = result;
                // this.siteURL = '/apex/redirectVFtoAsp?importID=' + this.importID;
            })
            .catch(error => {
                this.importId = error;
            });
    }

    @track IsImport = true;        // for show hide import  note button
    @track status;
    @track message;
    @track recordId;
    subscription = {};
    @api channelName = '/event/navpeII_dev18__Navatar_ImportNotes_Event__e';

    IsFileImported = false;         // Bug 	00045530 fixed by Sudhanshu on 27-05-2024
    importCount = 0;

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
    
        const messageCallback = function (response) {
            var obj = JSON.parse(JSON.stringify(response));
            console.log(obj.data.payload);
            console.log(obj.data.payload.navpeII_dev18__ImportNotes_Message__c);
            console.log(self.channelName);
            let objData = obj.data.payload;
            self.message = objData.navpeII_dev18__ImportNotes_Message__c;
            self.navpeII_dev18__ImportNotes_ID__c = objData.navpeII_dev18__ImportNotes_ID__c;
            if(objData.navpeII_dev18__ImportNotes_ID__c == self.importId){

                if(self.message == 'Success')
                {
                    // Bug 	00045530 fixed by Sudhanshu on 27-05-2024
                    self.importCount+=1;
                    self.IsFileImported=true;
                    self.ShowToast(self.message,'File imported successfully.','success', 'dismissable');    // Bug 00047447 Fixed by Sudhanshu on 24-09-2024
                    self.closeImportModal();
                }
                else
                {
                    if(self.message != 'Spinner'){
                        // Bug 	00045530 fixed by Sudhanshu on 27-05-2024
                        self.importCount+=1;
                        self.IsFileImported=true;
                        self.ShowToast('Error', self.message, 'error', 'dismissable');
                    }
                }
            }
        };
 
        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
 
    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
 
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    /* ----------Import Note Functionality Ended Here------*/
    //Notes view Pop up on new Note Added by Manonit Start
    interactionsPartialInfoArray;
    
    meetingCallEmailViewpopup(){
        // Bug 00047632 Fixed by Sudhanshu on 30-05-2025
        handleInteractionsInfo({namespacePrefix : 'navpeII_dev18__', actIdList : this.recordId, isAcuity : false})
        .then((result) => {
            if(result && result.length > 0){
                //For handling Desktop Scenario
                this.interactionsPartialInfoArray = [];
                for(let recInfo of result){
                    this.interactionsPartialInfoArray.push({iconName: recInfo.iconName, type: recInfo.type, date: recInfo.actDate, buttonTitle: recInfo.buttonTitle, subject: recInfo.subject, id: recInfo.actId, detail: recInfo.detail, participantsInfo: recInfo.attendees, tagsInfo: recInfo.references, priority: recInfo.priority, actOwner: recInfo.actOwner, status: recInfo.status, classification: recInfo.classification,actInfo : recInfo.actInfo});
                }
                
            }
            const modalPopup =this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention
           let activityInfo = JSON.parse(JSON.stringify(this.interactionsPartialInfoArray[0]));
            if(!activityInfo.hasOwnProperty('actId')){
                 activityInfo.actId = this.recordId;
            }
            console.log('BeforePopup');
            modalPopup.openModalNew(activityInfo, [],this.redirectId);//Manonit 00045538 Bug fix
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
        });
       
    }
    //Notes view on new Note Added by Manonit End

}