/****************************************************************************************************

** Module Name : Activity Associations

** Description : Edit and New action of Event and Task.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur/YASH/ANMOL // Ownership
** 2.0        2022-03-20          Manonit          Flexible Mobile UI
****************************************************************************************************/

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
import adjustEventStartEndDate from '@salesforce/apex/NavatarNotesModalCtrl.adjustEventStartEndDate';
import saveSuggessionRecods from '@salesforce/apex/NavatarNotesModalCtrl.saveSuggessionRecods';
import getSubjectFieldLabel from '@salesforce/apex/NavatarNotesModalCtrl.getSubjectFieldLabel';
import getTodayDate from '@salesforce/apex/NavatarNotesModalCtrl.getTodayDate';
import getEventDateTime from '@salesforce/apex/NavatarNotesModalCtrl.getEventDateTime';
import checkEditAccess from '@salesforce/apex/NavatarNotesModalCtrl.checkEditAccess';
import currentUserId from '@salesforce/user/Id';
import userAvailableAccountRecType from '@salesforce/apex/NavatarNotesTaggingCtrl.getUserAvailableAccountRecordTypes';
import saveNewAccountContactRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.createAccountContactRecords';
import getContactInfo from '@salesforce/apex/NavatarNotesTaggingCtrl.getRelatedContactsDetails';
import createDealTeamRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.createDealTeamRecords';
import createFundTeamRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.createFundTeamRecords';
import createFileRecords from '@salesforce/apex/NavatarNotesTaggingCtrl.saveFilesData';
import getActivityData from '@salesforce/apex/NavatarNotesTaggingCtrl.getActivityData';
import checkSuggestedTag from '@salesforce/apex/NavatarNotesModalCtrl.checkSuggestedTag';
//Rich Textarea Requirement
import checkRichTextDesp from '@salesforce/apex/NavatarNotesModalCtrl.checkRichTextDesp';


const columns = [
    { label: 'Name', fieldName: 'Name' },
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

export default class navatarNotesMobileLwc extends NavigationMixin(LightningElement) {
    @track isCallFromGlobal = false;
	@api isCalledfromView=false;
    
    @api isRedirectToParentScreen = false;
    @api isCalledfromMobile = false;
    @api callFromNotification = false;
    @api recordId;
    @api objectName;
    @api redirectId = '';
    @api isRedirectToRecord = false;
    @api modalHeader = '';
    @api taskType = '';
    //@api associatedRecordId;
    //@api isUtilityBar=false;            // Added by Sudhanshu For Utility Bar popup
    //00031341 -- if it is followup task open advance and followup section
    @api isFollowup;
    @track ownerIdLabel = '';
    @track data = [];
    @track columns = columns;

    @track subject = '';
    @track currentTagString = '';
    @track isStillAt = false;
    @track isLoading = false;
    @track showAdvance = false;
    @track isTask = false;
    @track lstResult = [];
    @track commentStr;
    @track searchableObjectStr;
    @track allTaggedRecords = [];
    @track atTaggedRecords = [];
    @track extraTaggedRecords = [];
    @track otherPAgeLAyoutFields = [];
    
    @track subjectOptions = [];
    @track subjectOptionsTemp = [];
    @track isSuggestShowModal = false;
    @track showFollowUp = false;
    @track isTagOpen = false;
    @track tagIconName = 'standard:quotes';
    @track eventLayoutFields = '';
    @track followTaskLayoutFields = '';
    @track taskLayoutFields = '';
    @track blurTimeout;
    savedFollowUpIds = '';

    //00031341 -- if it is followup task open advance and followup section
    @track activeSectionAdvance = 'A';      //Added By Sudhanshu for CR Change ; 47980 
    @track activeSectionFolllowUp = [];
    //00031341 end

    leftFields = [];
    rightFields = [];
    userId = currentUserId;
    isDescriptionUsed = false;
    @track followupCount = 0;
    @track followUpTask = { subject : '', assignTo : '', status : '', date : ''};

    followUpLayoutFields = [];
    
    @track followUpList = [];
    subjectLabel = "Subject";
    @track isDoHaveEditAccess = true;
    @track isError= false;
    @track errorMessage = [];
    @track errorHeader = '';
    @track isQuickAccountContact = false;
    @track isaddContactToDealTeam = false;
    @track isDiscoverOpen = false;

    //Phase 2 variables
    @track newTaggedRecordsList = [];
    @track accountRecTypeOptions = [];
    @track allTaggedRecordsInit = [];
    @track isInitRun = true;

    @api defaultContactTaggedId = '';
    @track headerIcon = '';
    @track isShowModal = true;
    @track globalCheck = false;

        
//Rich Textarea Requirement 
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
        this.richTxtDescription = '';  // Bug 00047742 fixed by Sudhanshu
        checkRichTextDesp({
            recordId:this.recordId
        })
            .then(data => {
                this.isRichTxtEnable = data[0].isRichText === 'true' ? true : false;
                
                if(this.recordId != null && this.recordId != '' && this.isRichTxtEnable){
                    this.richTxtDescription = data[0].richDescription == '' ? this.commentStr.replaceAll('\n','<br>') : data[0].richDescription ;
                }
                
            })
            .catch(error => {
                // this.displayError(error);
            });
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

    textareahight = 100; 

    renderedCallback() {	
        const style = document.createElement('style');
        style.innerText = ` 
        .forceChatterPublisherPresentationMobile .cuf-scroller-inside {
            padding: 0px !important;
        }
        .task-box .slds-accordion__section{
            padding: 10px 5px 0px !important;}
       // .slds-rich-text-editor__toolbar.slds-shrink-none{display:none !important;}
        }
        .advance-font span.slds-accordion__summary-content {
            font-size: 17px !important;
        }

        /*Added by raju on 23-10-2024 for @function ; 47979 ; 47978*/
        .clsSldsMedia.slds-media{
            align-items: center !important;
        }

        .hide-toolbar  .slds-rich-text-editor__toolbar {
            display: none !important;
        } 

        .detailsnoteareacss textarea.slds-textarea{
            border: 0 !important;
            outline: none !important;
            padding: 0px 0px;
            box-shadow: none;
            resize: none;
            background-color: transparent;
            height: ${this.textareahight}px;
            min-height:50px;
        }
        .detailsnoteareacss .slds-form-element__label:empty{
            display: none;
        }

        .dash-filter{
            z-index: 1 !important;        
        }
        .dash-filter:before{               
            content: '';
            display: block;
            width: var(--lwc-squareIconXSmallContent,0.5rem);
            height: 2px;
            border: 0;
            transform: translate3d(-50%, -50%, 0);
            background: var(--slds-c-checkbox-mark-color-foreground, var(--sds-c-checkbox-mark-color-foreground, var(--lwc-brandAccessible,rgb(1, 118, 211))));
            position: absolute;
            top: 52%;
            left: 12px;
            z-index: 1 !important;                          
        }

        @media only screen and (max-width : 1280px){
                                    .listdiv .slds-modal__content{
                                        max-height: 340px !important;
                                    }
                                }
        

        .slds-theme--success a:not(.slds-button--neutral):link{
            color: #fff !important;
        }
        .suggest-css .slds-icon_small{
            width: 20px !important;
            height: 20px !important;
        }
        .suggest-css span.slds-media__figure.slds-listbox__option-icon{
            margin-right: 4px !important;
        }
        .pillsHide .slds-pill__remove{
            display: none !important;
        }
       // .slds-rich-text-editor__toolbar.slds-shrink-none{
       //     display:none;
       // }
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
        }
        .slds-file-selector__button{
           padding-left:10px;
        }
        
       // .slds-rich-text-editor__toolbar.slds-shrink-none{
       //     display:none !important;
    
      //  }
       // .slds-rich-text-editor__toolbar.slds-shrink-none {
       //     display: none;
       // }
        .advance-font span.slds-accordion__summary-content {
            font-size: 12px;
            padding-top: 5px;
        }
        .advance-font svg.slds-accordion__summary-action-icon.slds-button__icon.slds-button__icon_left.slds-icon.slds-icon-text-default.slds-icon_x-small{
            width: 11px;
            height: 11px;
        }
       
        .detailsAccor .slds-accordion__summary-action{
            padding-left:0px;
        }
        .detailsAccor .slds-accordion__section.slds-is-open{
            background:#f3f3f3;
        }
        .detailsAccor .slds-accordion__summary{
            background:#fff;
            padding-left: 1.5rem !important;
        }
        .detailsAccor .slds-pill{
            background: #f3f3f3;
        }
        .seletedtag-datatable .slds-table_bordered tbody td, .slds-table_bordered tbody th, .slds-table--bordered tbody td, .slds-table--bordered tbody th{
            height: 41px !important;
        }
        .seletedtag-datatable .slds-table tbody tr.slds-is-selected>td, .slds-table tbody tr.slds-is-selected>th{
            box-shadow: none !important;   
        }
        .seletedtag-datatable td.slds-text-body_regular:hover, .seletedtag-datatable td.slds-text-body_regular:focus, .seletedtag-datatable .slds-table tbody tr.slds-is-selected>td:hover, .slds-table tbody tr.slds-is-selected>th:hover{
            box-shadow: none !important;
        }
        .seletedtag-datatable .slds-table th:focus, .seletedtag-datatable .slds-table th.slds-has-focus, .seletedtag-datatable .slds-table [role=gridcell]:focus, .seletedtag-datatable .slds-table [role=gridcell].slds-has-focus, .seletedtag-datatable .slds-has-focus .slds-th__action{
            box-shadow:none !important;
        }
        .seletedtag-datatable span.slds-th__action, .seletedtag-datatable span.slds-th__action:hover,.seletedtag-datatable span.slds-th__action:focus ,.seletedtag-datatable slds-th__action:focus, .seletedtag-datatable .slds-th__action:hover{
            background-color:#f3f3f3;
        }
        @media only screen and (min-width: 91em) and (max-width: 120em) { 
            .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
                max-height: 228px !important;
                overflow-y: auto;
        }}
        .picklist-ht:last-child .slds-dropdown-trigger_click.slds-is-open:last-child .slds-dropdown:last-child, .slds-dropdown-trigger--click.slds-is-open:last-child .slds-dropdown:last-child{
            max-height: 152px;
            overflow-y: auto;
        }
        .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            max-height: 152px;
            overflow-y: auto;
        }
       // .slds-rich-text-editor__toolbar.slds-shrink-none{
       //     display:none;
       // }
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
        }
        .slds-file-selector__button{
           padding-left:10px;
        }
       // .slds-rich-text-editor__toolbar{
        //    display:none !important;
       // }
        .advance-font span.slds-accordion__summary-content {
            font-size: 12px;
            padding-top: 5px;
        }
        .advance-font svg.slds-accordion__summary-action-icon.slds-button__icon.slds-button__icon_left.slds-icon.slds-icon-text-default.slds-icon_x-small{
            width: 11px;
            height: 11px;
        }
        .detailsAccor .slds-accordion__summary-action{
            padding-left:0px;
        }
        .detailsAccor .slds-accordion__section.slds-is-open{
            background:#f3f3f3;
        }
        .detailsAccor .slds-accordion__summary{
            background:#fff;
        }
        .detailsAccor .slds-pill{
            background: #f3f3f3;
        }
        .seletedtag-datatable .slds-th__action {
            background: #f3f3f3 !important;
            box-shadow: none;
        }
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action,
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .seletedtag-datatable .slds-is-resizable .slds-th__action:focus,
        .seletedtag-datatable .slds-is-resizable .slds-th__action:focus:hover,
        .seletedtag-datatable .slds-table th:focus,
        .seletedtag-datatable .slds-table th.slds-has-focus,
        .seletedtag-datatable .slds-table [role="gridcell"]:focus,
        .seletedtag-datatable .slds-table [role="gridcell"].slds-has-focus,
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th,
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            box-shadow: none !important;
        }
        .seletedtag-datatable .slds-th__action:focus,
        .slds-th__action:hover,
        .seletedtag-datatable .slds-table tr:hover {
            box-shadow: none !important;
        }
        .seletedtag-datatable .slds-th__action {
            background: #f3f3f3 !important;
        }
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th {
            background: none !important;
        }
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            background: none !important;
        }
        .seletedtag-datatable .slds-button:focus {
            box-shadow: none;
        }
        .seletedtag-datatable .slds-button:active {
            border: none;
        }
        .slds-table tbody tr {
            height: 40px !important;
        }
        @media only screen and (min-width: 91em) and (max-width: 120em) { 
            .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
                max-height: 228px !important;
                overflow-y: auto;
        }}
        .picklist-ht:last-child .slds-dropdown-trigger_click.slds-is-open:last-child .slds-dropdown:last-child, .slds-dropdown-trigger--click.slds-is-open:last-child .slds-dropdown:last-child{
            max-height: 152px;
            overflow-y: auto;
        }
        .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            max-height: 152px;
            overflow-y: auto;
        }
        .creatrecord_css .slds-radio .slds-form-element__label{
            display: none !important;
        }
        .creatrecord_css .radio_grp .slds-form-element__control{
            display: flex !important;
            justify-content: center;
            gap: 60px;
            padding-left: 1rem;
        }
        .creatrecord_css .slds-dropdown-trigger .slds-dropdown{
            max-height: 192px;
        }
        .creatrecord_css .slds-form-element__label:empty{
            display:none;
        }
        .lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
            position: absolute;
            right: 2px;
            top: 0px;
        }`;

        this.template.querySelector('.main-Container')?.appendChild(style);
        	
    }

    // UI-fix for calendar drop down get hide ---- 26 oct-!!!!!!!!!!!!!!!!!`````````--//
    tobottom(){
        window.setTimeout(()=>{
            this.template.querySelector('.slds-modal__content').scrollTop=10000;
        }, 100)       						 
    }

    //00031214 hide close button if there is only one task
    get followupTaskList(){
        return this.followUpList.length > 1 ? true : false;
    }

    // @api
    // openModal(recordId){
    //     this.activeSectionAdvance = [];
    //     this.activeSectionFolllowUp = [];
    //     this.commentStr='';
    //     this.followUpList=[];
    //     this.otherPAgeLAyoutFields = [];
    //     this.followUpLayoutFields =[];
    //     this.allTaggedRecords=[];
    //     if(recordId == null || typeof recordId === 'undefined' || recordId == ''){
    //         this.isDoHaveEditAccess = true;
    //         this.fetchSearchableObjects();
    //         this.getSubjectValues();
    //         this.fatchSubjectFieldLabel();
    //     }else{
    //         checkEditAccess({recordId : recordId})
    //         .then(data => {
    //             if(data){
    //                 this.isDoHaveEditAccess = true;
    //                 this.fetchSearchableObjects();
    //                 this.getSubjectValues();
    //                 this.fatchSubjectFieldLabel();
    //             }else{
    //                 this.isDoHaveEditAccess = false;
    //             }
    //         })
    //         .catch(error => {
    //             this.displayError(error);
    //         });
    //     }
    // }

    connectedCallback(){
        this.tempOptions = this.options;
        this.finalOption =  [...this.tempOptions];
        //00031509 -- added as we are keeping static modal header - "Note"
        if(this.objectName == 'Event' || this.objectName == 'Meeting'){
            this.modalHeader = 'Meeting';
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
        }
        if((this.objectName == 'Task' && this.taskType == "Email") || (this.objectName === 'Email')){
            this.modalHeader = 'Email';
            this.headerIcon = 'utility:email';
            this.objectName = 'Task';
            this.taskType = 'Email'; //Critical Bug fix Nikita S
        }
        this.isLoading = true;

        this.isTask = this.objectName =='Task' ? true : false;

        if(typeof this.isRedirectToRecord == 'undefined'){
            this.isRedirectToRecord = true;
        }
        if(this.taskType == 'Call'){
            this.subject = 'Call'
        }
        // if(!this.callFromNotification){
        //     this.openModal(this.recordId);
        //         }
        if((this.recordId == null || typeof this.recordId === 'undefined' || this.recordId == '') ){//&& this.callFromNotification
            // this.openModal(this.recordId);
            this.isDoHaveEditAccess = true;
            this.fetchSearchableObjects();
            this.getSubjectValues();
            this.fatchSubjectFieldLabel();
        }else{
            checkEditAccess({recordId : this.recordId})
            .then(data => {
                if(data){
                    // this.openModal(this.recordId);
                    this.isDoHaveEditAccess = true;
                    this.fetchSearchableObjects();
                    this.getSubjectValues();
                    this.fatchSubjectFieldLabel();
                }else{
                    this.isDoHaveEditAccess = false;
                }
            })
            .catch(error => {
                this.displayError(error);
            });
        }
        

        //00031341 -- if it is followup task open advance and followup section
        //if(this.isFollowup){ changed for CR to open both advanced and Tasks
            //this.activeSectionAdvance = [];
            //this.activeSectionFolllowUp = ['B'];
        //}
        //00031341 end

        // this.getAvailableAccountRecordType();
        

    }

    //get subject field picklist values
    fatchSubjectFieldLabel(){
        getSubjectFieldLabel({})
        .then(data => {
            this.subjectLabel = data;
        })
        .catch(error => {
            this.displayError(error);
        });
    }

    //get subject field picklist values
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

    get isSubjectOptionAvailable() {
        return this.subjectOptions.length > 0 ? true : false;
    }
    
    // return match data on press of @
    get recordData(){
        return this.lstResult;
    }

    //show suggestion box if found any record on press of @
    get showSuggBox(){
        return this.lstResult.length > 0 ? true : false;
    }

    //show subject option
    showSubjectOption(){
        if(this.subjectOptions.length > 0){
            let sldsIsOpenClass = this.template.querySelector(".slds-dropdown-trigger_click");
            sldsIsOpenClass.classList.add("slds-is-open");
        }
    }

    //show subject option followup
    showSubjectOptionFollowUp(event){
        let cls = event.currentTarget.dataset.uid.trim().split(/\s+/);
        let sldsIsOpenClass = this.template.querySelector("."+cls[cls.length-1]);
        sldsIsOpenClass.classList.add("slds-is-open");
    }

    //show subject option
    hideSubjectOption(){
         this.blurTimeout = setTimeout(() =>  {

            let sldsIsOpenClass = this.template.querySelector(".slds-dropdown-trigger_click");
            sldsIsOpenClass.classList.remove("slds-is-open");

            for(let followUp of this.followUpList){
                let cls = followUp.subjectClass.trim().split(/\s+/);
                let sldsIsOpenClass = this.template.querySelector("."+cls[cls.length-1]);
                sldsIsOpenClass.classList.remove("slds-is-open");
            }

            //let sldsIsOpenClass1 = this.template.querySelector(".slds-dropdown-trigger_click_followup");
        }, 300); 
    }

    // on select from subject list
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

    // on select from subject list
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

    @track hiddenTaggedList =[];    // Bug 00047475 fixed by Sudhanshu on 03-10-2024
    // get record and pagelayout data
    fetchRecordData(){
        this.isLoading = true;

        getRecordData({"recordId" : this.recordId,
                        "searchObjects" : this.searchableObjectStr,
                        "currentObject" : this.objectName,
                        "eventLayoutFields" : this.eventLayoutFields,
                        "taskLayoutFields" : this.taskLayoutFields,
                        "taskType" : this.taskType,
                        "followUpTaskFields" : this.followTaskLayoutFields
        }).then(data => {
            let recordData = JSON.parse(data);
            //console.log('test data '+JSON.stringify(JSON.parse(data)));
            //Rich Textarea Requirement
            this.commentStr = recordData.description;
            
            //Rich Textarea Requirement - Deepak
            this.checkRichTextDespEnable(this.recordId);//Rich Textarea Requirement - Deepak
            if(this.recordId != null && this.recordId != ''){
                this.subject = recordData.subject;
            }
           // this.allTaggedRecords = [];
            this.allTaggedRecords = this.allTaggedRecords.concat(JSON.parse(recordData.allTaggedRecordsList)); 
            if(this.isInitRun) {
                this.allTaggedRecordsInit = [...this.allTaggedRecords];
            }
            // for newly added deals and fund raising

            this.otherPAgeLAyoutFields = JSON.parse(recordData.allOtherFields);
            this.followUpLayoutFields =new ReadOnlyArray(JSON.parse(recordData.followupTaskFields));
            
            for(let advanceFields of this.otherPAgeLAyoutFields){
                if(advanceFields.fieldAPI.toLowerCase() == 'ownerid' ){
                    this.ownerIdLabel = advanceFields.fieldLabel;
                }
            }

            let fields = JSON.stringify(this.followUpLayoutFields);
            let _fields = JSON.parse(fields);
            this.hiddenTaggedList = JSON.parse(recordData.hiddenTaggedList);    // Bug 00047475 fixed by Sudhanshu on 03-10-2024
            for(let followUpField of _fields){
                followUpField.lwcFieldClass = followUpField.lwcFieldClass + this.followupCount;
                if(followUpField.fieldAPI == 'subject' || followUpField.fieldAPI == 'Subject'){
                    followUpField.fieldValue = this.subject;
                }
            }
            this.followUpList.push({id :this.followupCount , data : _fields, subjectClass : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-dropdown-trigger_click_followup'+this.followupCount});

            if(this.openTag)     // Bug 46156 fixed by Sudhanshu on 17-06-2024
            {
                this.handleGetSuggestions();
            }
            else{
                this.isLoading = false;
            }
            
        }).catch(error => {
            this.isLoading = false;
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

    // get set-up object and layout fields from navatar setup object
    fetchSearchableObjects(){
        let recIdval = ((typeof this.recordId === 'undefined')||this.recordId==undefined)?'':this.recordId;
        getSearchableObjName({
            "recordIdval": recIdval
        }).then(data => {
            this.searchableObjectStr = data[0];
            this.taskLayoutFields = data[1];
            this.eventLayoutFields = data[2];
            this.followTaskLayoutFields = data[3];
            this.isDescriptionUsed = data[4];
            this.isLoading = false;
            this.fetchRecordData();
            if(this.recordId == null || typeof this.recordId === 'undefined' || this.recordId == ''){
                this.handleDefaultTaggedRecords();
            }
        }).catch(error => {
            this.isLoading = false;
        });
    }

    handleDefaultTaggedRecords(){
        getDefaultTaggedRecords({recId : this.redirectId, searchObjects : this.searchableObjectStr}).then(data => {
            this.allTaggedRecords = this.allTaggedRecords.concat(JSON.parse(data));
            if(this.defaultContactTaggedId!='') {
                this.handleDefaultContactTagged();
            }
        }).catch(error => {
            this.isLoading = false;
        });
        
    }

    handleDefaultContactTagged() {
        getDefaultTaggedRecords({recId : this.defaultContactTaggedId, searchObjects : this.searchableObjectStr}).then(data => {
            this.allTaggedRecords = this.allTaggedRecords.concat(JSON.parse(data));
        }).catch(error => {
            this.isLoading = false;
        });
    }

    // <!-- UI changes - 04-10-2022 -->
    hideRecordModal(){
        this.dispatchEvent(new CustomEvent("cancelchanges" ) );
        // if(this.isUtilityBar){
        //     window.history.back();
        //     return;
        // }
        if((this.callFromNotification ||(!this.callFromNotification && this.isRedirectToParentScreen))&& !this.isCalledfromView){
                            this[NavigationMixin.Navigate]({
                                type: 'standard__webPage',
                                attributes: {
                                    url: '/lightning/n/Home_Mobile',// fixed for redirection issue after packaging Bug # 39276
                                }
                                });
                        }
                        
                        else if(this.redirectId != null && this.redirectId != ''){
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.redirectId,
                                    actionName: 'view',
                                },
                            })
                            return;
                        }  
                        else if(this.recordId != null && this.recordId != '' && !this.isCalledfromView){
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordId,
                                    actionName: 'view',
                                },
                            })
                        }
                        
                        else{
                            this[NavigationMixin.Navigate]({
                                type: 'standard__webPage',
                                attributes: {
                                    url: '/lightning/n/Home_Mobile',// fixed for redirection issue after packaging Bug # 00045116, 00045115
                                }
                                });  
                        }

        if( !this.isRedirectToRecord){
            //.dispatchEvent(new CustomEvent("closemodal", {detail: '' } ) );
            this.dispatchEvent(new CustomEvent('cancelchanges', { bubbles:true, composed:true }));
        }else{
            this.navigateToRecordPage();
        }
        
    }
    // navigate to record page after save
    navigateToRecordPage(event) {
        // if(this.isUtilityBar){
        //     alert('this.isUtilityBar'+this.isUtilityBar);
        //     window.history.back();
        //     return;
        // }
        
        if(!this.isRedirectToRecord){
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
            //window.history.back();
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
        //this.allTaggedRecords.push({Name:selectedRecord.Name, Id:selectedRecord.Id, icon:selectedRecord.iconName, objectName:selectedRecord.objectName});
    }
    // how and hide quick tag.
    handleClickTag(){
        this.isTagOpen = this.isTagOpen ? false : true;
        //this.navigateToRecordPage();
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

    // bug 00047131 fixed By Sudhanshu
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
                                        // fieldValue.setCustomValidity("Complete this field.");
                                        // fieldValue.reportValidity();
                                        // eachPick.showError('Complete this field.');
                                    }
                                    else if(fieldList[i].isRequired == true &&  (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                        this.requiredMissing.push(fieldList[i].fieldLabel);
                                        // fieldValue.setCustomValidity("Complete this field.");
                                        // fieldValue.reportValidity();
                                        // eachPick.showError('Complete this field.');
                                    }
                                }
                        }
                        else{
                            if( fieldList[i].fieldAPI == eachPick.currentInputClass){
                                if( (fieldList[i].fieldAPI.toUpperCase() === statusAPI.toUpperCase() || fieldList[i].fieldAPI.toUpperCase() === priorityAPI.toUpperCase() ) && (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                    this.requiredMissing.push(fieldList[i].fieldLabel);
                                    // fieldValue.setCustomValidity("Complete this field.");
                                    //     fieldValue.reportValidity();
                                    // eachPick.showError('Complete this field.');
                                
                                }
                                else if(fieldList[i].isRequired == true &&  (eachPick.currentSelectedOption == null || eachPick.currentSelectedOption == '')){
                                    this.requiredMissing.push(fieldList[i].fieldLabel);
                                    // fieldValue.checkValidity("Complete this field.");
                                    //     fieldValue.reportValidity();
                                    // eachPick.showError('Complete this field.');
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
    // bug 00047131 fixed By Sudhanshu
    @track requiredMissing = [];
    @track fieldList=[];
 
    

    handleSaveRecord(){
    	// added by Sudhanshu
        if(this.isRichTxtEnable)
        {
            let txtNotes = this.richTxtDescription.replace(/<p\s*\/?>|<br\s*\/?>|<li\s*\/?>/gi, '\n');
            this.commentStr = txtNotes.replace(/(<([^>]+)>)/gi, "").replace(/&nbsp;/g, ' ');    // Bug 00047642,00047552,00047646 fixed by Sudhanshu
            this.convertToHyperlinks(); // Bug 	00047365 fixed by Sudhanshu
        }
        this.isError = false;
        this.isLoading = true;
        this.errorMessage = [];

        this.requiredMissing = [];
        // bug 00047131 fixed By Sudhanshu
        this.otherPAgeLAyoutFields = this.handleFieldValue(this.otherPAgeLAyoutFields,'OtherField');

     
        let isValidated = true;
        let fieldErrorMsg="Invalid data type.";
        if(this.objectName == 'Event'){
            this.template.querySelectorAll("lightning-input").forEach(item => {
                let fieldValue=item.value;
                let fieldLabel=item.label;            
                if(!fieldValue && (fieldLabel.includes('End') || fieldLabel.includes('Start') )){
                    item.setCustomValidity(fieldErrorMsg); //+' '+fieldLabel
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
                // bug 00047131 fixed By Sudhanshu
                followUpLayoutFields = this.handleFieldValue(followUpLayoutFields,'Followup');
                
            }
        }
        let uniqueArray = Array.from(new Set(this.requiredMissing));
        // alert("length "+this.requiredMissing.length);
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
        //Fixed for Bug #38082 started 
        let updatedString = '';
        for(var d in commentStringArray) {
            updatedString+=commentStringArray[d]+' ';//.replace('@','')
        }

        let taggedrecord = [];
        // Bug 00047475 fixed by Sudhanshu on 03-10-2024
        for (let i = 0; i < this.hiddenTaggedList.length; i++ ) {
            taggedrecord.push({Id:this.hiddenTaggedList[i]}); 
        }
        taggedrecord = taggedrecord.concat(this.allTaggedRecords);
        //Fixed for Bug #38082 ended
        if(!this.isError){
             saveRecord({"commentStr" : updatedString, 
                    "allTaggedRecords" : JSON.stringify(taggedrecord),
                    "recordId" : this.recordId,
                    "atTaggedRecord" : JSON.stringify(this.atTaggedRecord),
                    "extraTaggedRecord" : JSON.stringify(this.extraTaggedRecords),
                    "objectName" : this.objectName,
                    "otherFielddData" : JSON.stringify(this.otherPAgeLAyoutFields),
                    "currentObject" : this.objectName,
                    "subject" : this.subject,
                    "taskType" : this.taskType,
                    "isDescriptionUsed" : this.isDescriptionUsed,
                    "followUpTasksStr" : JSON.stringify(this.followUpList),
                    "isSaveFollowup" : this.showFollowUp,
                    "isRichTxtEnable" : this.isRichTxtEnable,
                    "richTxtDescription" : this.richTxtDescription                }).then(dataList => {
                    var data=dataList[0];//Anmol change -> merge team comment "data structure fault" temorary fixed 
                    if(!data.includes('Error')){
                        let followupDetailsMap=JSON.parse(dataList[1]);//changed for Bug # 00037939 by Anmol
                        this.recordId = data.split('#')[0];
                        this.saveFileData(this.recordId);
                        this.savedFollowUpIds = data.split('#')[1];
                        let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                        // Bug 00046741 fixed by Sudhanshu 
                        const event = new ShowToastEvent({title: 'Success:',message:'Record was saved.',//this.objectName + -> Removed for Bug #00038075 Bug fix By Manonit 00045645
                        variant: 'success',
                        mode: 'dismissable', 
                        messageData: [
                            '',
                            {
                                url: '/lightning/n/navpeII_dev18__Interactions?c__params='+allIteractionsParams,
                                label: this.subject,
                            }
                        ]});
                        this.dispatchEvent(event);
                        //changed for Bug # 00037939 by Anmol started
                        //followupDetailsMap.hasOwnProperty(key) && 
                        for(let key in followupDetailsMap){
                            // alert(key);
                            // alert(followupDetailsMap[key]);
                            if (followupDetailsMap[key]!=null) {
                                let allIteractionsParams = JSON.stringify(this.createToastParams(key, 'Task', 'view'));
                                // Bug 00046741 fixed by Sudhanshu
                                this.dispatchEvent(new ShowToastEvent({title: 'Success:',message: 'Record was saved.',//this.objectName + -> Removed for Bug #00038075 & Bug fix By Manonit 00045645
                                variant: 'success',
                                mode: 'dismissable', 
                                messageData: [
                                '',
                                {
                                    url: '/lightning/n/navpeII_dev18__Interactions?c__params='+allIteractionsParams,
                                    label: followupDetailsMap[key],
                                }
                                ]}));
                            }
                        }
                        //changed for Bug # 00037939 by Anmol ended
                        // this.handleGetSuggestions();
                        this.checkSuggestedEnable();
                        // this.isShowModal = false; 
                        // this.handleSave();
                        
                        //this.navigateToRecordPage();
                        //this.navigateBackToParentScreen();
                    }else{  //00045554 Bug Fix By Manonit
                        let msg = data.split(';');
                        console.log('Error :'+ msg);
                        if(msg.length>1){
                                let errorCode=msg[2].split('=')[1];
                                console.log('Error code :'+errorCode);
                                if(!data.includes('Review the errors on this page')){
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
                                // Bug 00046746,00046747,00046885 fixed by Sudhanshu on 25-07-2024
                                if(!data.includes('Error:')){
                                    const event = new ShowToastEvent({title: 'Error:',message: data,variant: 'error',mode: 'dismissable'});
                                    this.dispatchEvent(event);
                                }
                                else{
                                    let err = data.split(':');
                                    const event = new ShowToastEvent({title: 'Error:',message: err[1],variant: 'error',mode: 'dismissable'});
                                    this.dispatchEvent(event);
                                }
                                // const event = new ShowToastEvent({title: 'Error',message: data,variant: 'error',mode: 'dismissable'});
                                // this.dispatchEvent(event);
                                
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

    pkgStr = `Capital Project Group Partner Partners Next Work America Systems Credit Active First Business company services Service companies products consulting growth water direct food sales Health corp healthcare finance management enterprises marketing will care family brokers Adam Allan Alex Andrew Anna Anne Anthony Barry Bill Brad Brenda Brian Carl Caroline Cathy Charles Chris Christopher Cook Craig Cynthia Daniel Dave David Donald Doug Elizabeth Eric Frank Fred Gary George Greg Gregory Harry Henry Jack Jackie James Jason Jeff Jeffrey Jennifer Jeremy Jill John Jonathan Jones Joseph Josh Julie Julia Karen Kevin Mark Michael Michelle Mike Nancy Nick Nicholas Paul Peter Phil Philip Richard Robert Ronald Roger Scott Smith Stephen Steve Steven Susan Thomas Todd William corporation International solutions manufacturing technologies chemicals equity technology american packaging industrial industrials speciality energy software office manufacturer corporate investments securities supply polymers GmbH Boston research distributor commercial data California Alliance consumer Spectrum Canada Europe Berlin access Acquisition Advisors advisory asset Associates bank banking Board building case center Chicago Clinical Dental Development devices Diagnostic diagnostics diversified doctor endowment engineering European financial focus foundation France Fund funds German Germany glass high home hospital income industry information innovation insurance invest investing investment investor investors labs level Life Limited London managed Market markets Medical medicine Miami Morgan national network Opportunities opportunity Part pension people performance pharma plan Private process product provider quality real reinsurance School science Sciences source SPAC Special state strategic strategies strategy Summit system team three time total transaction trust University value venture ventures well with world Aaron Alexander Bell Berg best Brown Clark Tests 
     Frederik Harris Howard Kelly Marc Martin Marvin Matt Miller Murphy Patel Patrick Ryan Simon Taylor Tony west Williams holding Frankfurt young Ernst instruments Media general biopharma Vision future implants Legal clinics design centre Scientific small Dutch Belgium cell computer electronic training plus brothers innovative MedTech control Austria online productions travel Roland integrated partnership materials video biotechnologies clinic Labor early retail test price point Stefan Christian Philippe Dirk global Firm Biotech tech surgical drug digital consultants consultancy line dynamics trading discovery imaging managers Institute executive human pharmaceutical info therapy link factory white exchange automotive agency trade heart applied resources micro wave brain distribution deal Industries college Street pipeline security great City transportation power branded platform infrastructure flow Park logistics contractor chain chemical Rental public auto Hill parts heavy electrical brand brands holdings contract fire meat employees below record assets specialty division steel electronics call acquisitions advanced segment long facility United River house facilities stores Post customer environmental businesses operations cash place waste Asia space paper hotel natural premium hotels storage light union risk maintenance transport production super double fuel base wood technical professional core defense wireless staffing country label legacy estate gold Retirement institutional County founders South education proprietary delivery press event delta action Restaurant Party material communication practice communications dealer Pizza restaurants unit franchise franchisee units king fitness forward Wealth Arthur Stein Michel Markus Stephan Erik Sean Andy Bryan Justin Derek Matthew Bruce Lewis Jamie Stanley Edward Kyle Jordan Rich Johnson Rick Dennis Graham Larry Arnold page ball Jose list Andreas Philipp Oliver Nicole Amanda Davis Stephens Clay Jake Timothy Douglas Tests
     construction equipment mezzanine Planning portfolio support radio adhesives north safety pipe fruit alternative Butler Coast Cohen Compensation fixed from Gilde Merck metal molecular Novartis Plastics preferred Purpose sense Therapeutics Arnoud Hans Schoot vliet Vries Warren willem Wright this Utrecht Oncology Benelux Hamburg Nordic cancer Gruppe open Kapital chance York Have Grery close interim spin gene search voor PortCo payment machine benefit Impact Road master based floor Cable mail personal color mobile related full coffee rock kitchen guys client profile Pieter Hugo Frans Lars Wolfgang Tobias Rene Francois Christoph Florian does here`;

    // method for check Suggested tag enable or not
    checkSuggestedEnable(){
        checkSuggestedTag()
            .then(data => {
                if(data == 'true'){
                    this.handleGetSuggestions();
                }else{
                    this.hideRecordModal();// Bug Id 00045827 & 00045752 fixed by Manonit
                }
            })
            .catch(error => {
        });
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
    }

    // Bug 	00047365 Fixed By Sudhanshu
    convertToHyperlinks() {
        // Regular expression to find URLs in the plain text
        // const urlPattern = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
        // Bug 00048171 fixed by Sudhanshu on 13-11-2024
        const urlPattern = /(?<!<(img|a)\s[^>]*(src|href)=["'])(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
        const hyperlinkedText = this.richTxtDescription.replace(urlPattern, '<a href="$3" target="_blank">$3</a>');
        this.richTxtDescription = hyperlinkedText;
    
    }

    textIndex = 0;
    prevVal = '';
    // handle description field changes
    handleChange(event){
        this.commentStr = event.target.value;
        if(event.key == "@"){
            this.currentTagString = '';
        }
        // check pressed key.
        if(event.key == "@" || this.isStillAt){
            
            this.currentTagString = typeof this.currentTagString === 'undefined' ? '' : this.currentTagString;
            this.isStillAt = true;

            // allow only char and number values
            if(event.keyCode >= 65 && event.keyCode <= 90 || event.keyCode >= 97 && event.keyCode <= 122 || event.keyCode == 32 || (event.keyCode >= 48 && event.keyCode <= 57 && event.key != "@")){  //|| event.keyCode >= 96 && event.keyCode <= 111 || event.keyCode >= 186 && event.keyCode <= 222
                this.currentTagString = this.currentTagString + event.key;
                this.handleSearchRecordAfterAt();
            }
            // remove char on press of backspace
            if(event.keyCode == 8){
                this.currentTagString = this.currentTagString.length > 0 ? this.currentTagString.substring(0, this.currentTagString.length - 1) : '';
                this.handleSearchRecordAfterAt();
            }

        }
        this.prevVal = event.target.value.replace(/<p><br><\/p>/g,"\n").replace(/<p>/g,"\n").replace(/<\/p>/g,"").replace(/<br>/g,"\n").replace(/<[^>]*>/g, '');
    }

    // seach records based on string after @
    handleSearchRecordAfterAt(){
        if(this.currentTagString.length > 2){
            getRelatedData({"searchString": this.currentTagString, 'searchObjects' : this.searchableObjectStr, 'allTaggedRecords' : JSON.stringify(this.allTaggedRecords)}).then(data => {
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
            this.currentTagString = '';
        }
        
        // check pressed key.
        if(event.key == "@" || this.isStillAt){
            
            this.currentTagString = typeof this.currentTagString === 'undefined' ? '' : this.currentTagString;
            this.isStillAt = true;
            

            // allow only char and number values
            if(event.keyCode >= 65 && event.keyCode <= 90 || event.keyCode == 32|| event.keyCode >= 97 && event.keyCode <= 122  || (event.keyCode >= 48 && event.keyCode <= 57 && event.key != "@")){  //|| event.keyCode >= 96 && event.keyCode <= 111 || event.keyCode >= 186 && event.keyCode <= 222
                this.currentTagString = this.currentTagString + event.key;
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
                this.currentTagString = this.currentTagString.length > 0 ? this.currentTagString.substring(0, this.currentTagString.length - 1) : '';
                this.handleSearchRecordAfterAt();
                if(this.currentTagString == '' && !this.commentStr.includes('@')){
                    this.isStillAt = false;
                    this.lstResult = [];
                    let hover = this.template.querySelector('.hover');
                    hover.style.display = 'none';
                }
            }
        }else{
            this.template.querySelector('.hover').style.display='none';
        }
      
      
        if(event.keyCode == 8){
          this.template.querySelector('.hover').style.display='none'
            this.handleSearchRecordAfterAt();
            if(this.currentTagString == '' && !this.commentStr.includes('@')){
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

    getCaretTopPoint () {
        const sel = document.getSelection()
        const r = sel.getRangeAt(0)
        let rect
        let r2
        // supposed to be textNode in most cases
        // but div[contenteditable] when empty
        const node = r.startContainer
        const offset = r.startOffset
        if (offset > 0) {
          // new range, don't influence DOM state
          r2 = document.createRange()
          r2.setStart(node, (offset - 1))
          r2.setEnd(node, offset)
          // https://developer.mozilla.org/en-US/docs/Web/API/range.getBoundingClientRect
          // IE9, Safari?(but look good in Safari 8)
          rect = r2.getBoundingClientRect()
          return { left: rect.right, top: rect.top }
        } else if (offset < node.length) {
          r2 = document.createRange()
          // similar but select next on letter
          r2.setStart(node, offset)
          r2.setEnd(node, (offset + 1))
          rect = r2.getBoundingClientRect()
          return { left: rect.left, top: rect.top }
        } else { // textNode has length
          // https://developer.mozilla.org/en-US/docs/Web/API/Element.getBoundingClientRect
          rect = node.getBoundingClientRect()
          const styles = getComputedStyle(node)
          const lineHeight = parseInt(styles.lineHeight)
          const fontSize = parseInt(styles.fontSize)
          // roughly half the whitespace... but not exactly
          const delta = (lineHeight - fontSize) / 2
          return { left: rect.left, top: (rect.top + delta) }
        }
      }
      
    // handle select record from @ suggestion box.
    // handle select record from @ suggestion box.
    handelSelectedRecord(event){
        try {
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 

        // replace name with <a> tag
     //   this.commentStr = this.commentStr.replace(new RegExp('@'+this.currentTagString ,'i'), '<a href="https://' +window.location.host+'/'+this.selectedRecord.Id+'" rel="noopener noreferrer" target="_blank">'+this.selectedRecord.Name + '</a>');
        this.commentStr = this.commentStr.replace(new RegExp('@'+this.currentTagString ,'i'), this.selectedRecord.Name);
        
        //empty suggestion list and string
        this.lstResult = [];
        

        this.handleAddTaggedRecord(this.selectedRecord);
        this.atTaggedRecords.push({Name:this.selectedRecord.Name, Id:objId, iconName:this.selectedRecord.iconName});
        
        this.commentStr = this.commentStr + ' ';
        if(!this.isRichTxtEnable){
        const inputBox = this.template.querySelector('.notetextareaEdit');//00047293 Bug Fix By Manonit
        inputBox.value = this.commentStr;
        
        inputBox.focus();
        const index = this.commentStr.indexOf(this.selectedRecord.Name) + this.selectedRecord.Name.length;
        inputBox.setSelectionRange(index, index);
        }
        if(this.isRichTxtEnable){
            try{
                this.richTxtDescription = this.richTxtDescription.replace(new RegExp('@'+this.currentTagString ,'i'), this.selectedRecord.Name);
                this.richTxtDescription = this.richTxtDescription + ' ';
                const inputBox = this.template.querySelector('.notetextareaEdit');//00047293 Bug Fix By Manonit
                inputBox.value = this.richTxtDescription;
            
                inputBox.focus();
                const index = this.richTxtDescription.indexOf(this.selectedRecord.Name) + this.selectedRecord.Name.length;
                // inputBox.setSelectionRange(index, index);
            }
            catch(ex){

            }
        }
        this.currentTagString = '';
        this.isStillAt = false;
        let hover = this.template.querySelector('.hover');
        hover.style.display = 'none';

        }
        catch(err) {
            console.log('Error.')
        }
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
            // if(selectedRecord.objectName == 'navpeII_dev18__Pipeline__c') {
            //     this.addNewDeals(selectedRecord);
            // }
            // if(selectedRecord.objectName == 'navpeII_dev18__Fundraising__c') {
            //     this.addNewFundRaising(selectedRecord);
            // }
        }
    }

    // get selected records size
    get selectedRecordSize(){
        return this.extraTaggedRecords.length;
    }

    // get selected records from suggestion popup
    getSelectedName(event) {
        this.extraTaggedRecords = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++) {
            this.extraTaggedRecords.push(selectedRows[i])
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
                for (let i = 0; i < this.otherPAgeLAyoutFields.length; i++) {
                    if( this.otherPAgeLAyoutFields[i].fieldType == 'DATETIME' && this.otherPAgeLAyoutFields[i].fieldAPI == 'EndDateTime'){
                        this.otherPAgeLAyoutFields[i].dateTimeValue = data;
                    }
                }
            })
            .catch(error => {});
        }
    }
   
 @track isValidActivityDate = true;
    handleChangeEventDate(event){
        if(event.currentTarget.dataset.name == 'ActivityDate'){
            // Bug 00046977 fixed by Sudhanshu
            if(event.target.value === null || event.target.value === ''){
                this.isValidActivityDate = false;
            }else{
                this.isValidActivityDate = true;
            }
        }

        if(event.currentTarget.dataset.name == 'StartDateTime'){
            for (let i = 0; i < this.otherPAgeLAyoutFields.length; i++) {
                if( this.otherPAgeLAyoutFields[i].fieldType == 'DATE' && this.otherPAgeLAyoutFields[i].fieldAPI == 'EndDateTime'){
                    this.otherPAgeLAyoutFields[i].dateValue = event.target.value;
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
                    for (let i = 0; i < this.otherPAgeLAyoutFields.length; i++) {
                        if(this.otherPAgeLAyoutFields[i].fieldAPI.toUpperCase() === startFieldAPI.toUpperCase() || this.otherPAgeLAyoutFields[i].fieldAPI.toUpperCase() === endFieldAPI.toUpperCase()){
                            this.otherPAgeLAyoutFields[i].fieldType = 'DATE';
                            this.otherPAgeLAyoutFields[i].isDateTime = false;
                            this.otherPAgeLAyoutFields[i].isDate = true;
                            this.otherPAgeLAyoutFields[i].isRequired = true;
                            this.otherPAgeLAyoutFields[i].dateValue = data;
                        } 
                        
                    }
                    this.isLoading = false;
                })
                .catch(error => {this.isLoading = false;});
            }else{
                getEventDateTime({})
                .then(data => {
                    for (let i = 0; i < this.otherPAgeLAyoutFields.length; i++) {
                        if(this.otherPAgeLAyoutFields[i].fieldAPI.toUpperCase() === startFieldAPI.toUpperCase() || this.otherPAgeLAyoutFields[i].fieldAPI.toUpperCase() === endFieldAPI.toUpperCase()){
                            this.otherPAgeLAyoutFields[i].fieldType = 'DATETIME';
                            this.otherPAgeLAyoutFields[i].isDateTime = true;
                            this.otherPAgeLAyoutFields[i].isDate = false;
                            this.otherPAgeLAyoutFields[i].isRequired = true;
                            if(this.otherPAgeLAyoutFields[i].fieldAPI.toUpperCase() === startFieldAPI.toUpperCase()){
                                this.otherPAgeLAyoutFields[i].dateTimeValue = data[0];
                            }
                            if(this.otherPAgeLAyoutFields[i].fieldAPI.toUpperCase() === endFieldAPI.toUpperCase()){
                                this.otherPAgeLAyoutFields[i].dateTimeValue = data[1];
                            }
                           
                        } 
                        
                    }
                    this.isLoading = false;
                })
                .catch(error => {this.isLoading = false;});
            }
            
        }else{
            this.isLoading = false;  
        }
        
    }
    /***************//****************** Phase 2 changes File Attach functionality* *********************************************/
    @track fileDataList = [];
    openfileUpload(event) {
        let index = (this.fileDataList!=undefined) ? this.fileDataList.length : 0;
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileDataList.push( {
                'filename': file.name,
                'base64': base64,
                'index' : index
            })
            console.log('total files data '+JSON.stringify(this.fileDataList.length));
            
        }
        reader.readAsDataURL(file)
        
    }

    saveFileData(activityId) {
        if(this.fileDataList == undefined || this.fileDataList == []) {
            return;
        }
        this.fileDataList.forEach(file =>{
            file.recordId = activityId;
        })
        createFileRecords({
            fileJsonString : JSON.stringify(this.fileDataList),
            activityId : activityId
        })
        .then(res=>{
            
        })
        .catch(err=>{
            const errorToast = new ShowToastEvent({title: 'Error', message: err,variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
        })
    
    }
    /***************//****************** Phase 2 changes File Attach functionality* *********************************************/
    /***************//****************** Phase 2 changes Quick Create functionality* *********************************************/
    @track defaultRecordType = '';
    @track isRequired = true;
   

    // Method to navigate to parent component screen without reload
    navigateBackToParentScreen() {
        //this.hideRecordModal();
        if(this.isCalledfromMobile){
            if(!this.callFromNotification){
                this.navigateToRecordPage();
            }
            //window.history.back();
            else if(this.callFromNotification){
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Home',
                    }
                  });
            }
        }
        else{
            this.hideRecordModal();
        }
    }

    //method handles the next flow after dela team modal closes
    // cancelDealTeamCreate() {
    //     this.openFundTeamModal();
    // }
    
    //method that takes in the deal records and pushes it into the list.
    // addNewDeals(dealRecord) {
        
    //     let existingLength = (this.newDealsTaggedList.length)?this.newDealsTaggedList.length : 0;
    //     this.newDealsTaggedList.push({
    //         index : existingLength,
    //         recId : dealRecord.Id,
    //         recName : dealRecord.Name
    //     })
    // }

// Method that retrieves all the tagged contact information for name and account
//     getAllDealTeamContacts() {
//         let contactTaggedRecordsLocal = [];
//         this.taggedContactsList = [];
//         this.contactTaggedRecords = [];
//         this.allTaggedRecords.forEach(taggedRec =>{
//             if(taggedRec.objectName == 'Contact') {
//                 contactTaggedRecordsLocal.push(taggedRec.Id);
//             }
//         })
//         if(contactTaggedRecordsLocal.length) {
//             getContactInfo({
//                 contactIds : contactTaggedRecordsLocal
//             })
//             .then(res=>{
//                 if(res.length) {
//                     this.contactTaggedRecords = res;
//                 }
//             })
//             .catch(err=>{
//             })
//         }
//     }
//     // handle the global checkbox to select or deselect of Deal team creation

//     handleDealGlobalCheck(evt){
//         this.contactTaggedRecords.forEach(contactRec =>{
//             contactRec.isSelected = evt.target.checked
//         })
//     }

//     // handle the Deal Team single checkbox select

//     handleDealContactCheckBox(evt) {
//         let selectedIndex = evt.currentTarget.dataset.id;
//         this.contactTaggedRecords[selectedIndex].isSelected = evt.target.checked
//     }

//     // handle Deatl team contact Role change
//     handleDealRoleChange(evt) {
//         let currentId = evt.currentTarget.dataset.id;
//         let selectedOption = evt.detail.value;
//         this.contactTaggedRecords[currentId].role = selectedOption;
//     }

//     // handle deal team creation
//     handleDealTeamCreate() {
//         let selectedRecords = [];
//         let selectedDealsId = [];
//         this.contactTaggedRecords.forEach(taggedRec=>{
//             if(taggedRec.isSelected) {
//                 selectedRecords.push(taggedRec)
//             }
//         })
//         this.newDealsTaggedList.forEach(deal=>{
//             selectedDealsId.push(deal.recId)
//         })
//         if(selectedRecords.length) {
//             createDealTeamRecords({
//                 dealJSONString : JSON.stringify(selectedRecords),
//                 dealRecordsId : selectedDealsId
//             })
//             .then(res=>{
//                 const successToast = new ShowToastEvent({title: 'Success', message: 'Deal Team Added Successfully',variant: 'success',mode: 'dismissable'});
//                 this.dispatchEvent(successToast);
//                 this.openFundTeamModal();
//             })
//             .catch(err=>{
//                 const errorToast = new ShowToastEvent({title: 'Error', message: 'Error in creating Deal Team',variant: 'error',mode: 'dismissable'});
//                 this.dispatchEvent(errorToast);
//                 this.openFundTeamModal();
//             })
//         }
        
//     }

//     /******************************************************************************************** */

//     /*************************Fund Team Create****************************************************** */

//     @track newFundRaisingRecords = [];
//     @track fundRaisingContacts = [];
//     get optionsFund() {
//         return [
//             { label: 'Advisor', value: 'Advisor' },
//             { label: 'Business User', value: 'Business User' },
//             { label: 'Decision Maker', value: 'Decision Maker' },
//             { label: 'Evaluator', value: 'Evaluator' },
//             { label: 'Executive Sponsor', value: 'Executive Sponsor' },
//             { label: 'Gatekeeper', value: 'Gatekeeper' },
//             { label: 'Influencer', value: 'Influencer' },
//             { label: 'Other', value: 'Other' },
//         ];
//     }
//     // handle the fund team open modal mechanism
//     openFundTeamModal() {   
//         this.isaddContactToDealTeam = false;
//         if(this.newFundRaisingRecords.length) {
//             this.isaddContactToFundraising = true;
//             this.getAllFundTeamContacts();
//         }
//         else{
//             //alert(this.isRedirectToParentScreen);
//             if(!this.isRedirectToParentScreen) {
//                 // if(this.isCalledfromMobile){
//                 //     window.history.back();
//                 // }
//                 // else{
//                     window.location.reload();
//                 // }
//             }
//             else {
//                 this.navigateBackToParentScreen();
//             }
//         }
        
//     }
//     // handle new funds added to tagged records

//     addNewFundRaising(fundRecord) {
//         let existingLength = (this.newFundRaisingRecords.length)?this.newFundRaisingRecords.length : 0;
//         this.newFundRaisingRecords.push({
//             index : existingLength,
//             recId : fundRecord.Id,
//             recName : fundRecord.Name
//         })
//     }
//     // method to handle the fund team contacts information
//     getAllFundTeamContacts() {
//         let contactTaggedRecordsLocal = [];
//         this.fundRaisingContacts = [];
//         this.allTaggedRecords.forEach(taggedRec =>{
//             if(taggedRec.objectName == 'Contact') {
//                 contactTaggedRecordsLocal.push(taggedRec.Id);
//             }
//         })
//         if(contactTaggedRecordsLocal.length) {
//             getContactInfo({
//                 contactIds : contactTaggedRecordsLocal
//             })
//             .then(res=>{
//                 if(res.length) {
//                     this.fundRaisingContacts = res;
//                 }
//             })
//             .catch(err=>{
//             })
//         }
//     }
//     // hhandle individual fund check box creating fund team

//     handleFundContactCheckBox(evt) {
//         let selectedIndex = evt.currentTarget.dataset.id;
//         this.fundRaisingContacts[selectedIndex].isSelected = evt.target.checked;
//     }
//     // handle the global checkbox to select or deselect of Fund team creation

//     handleFundGlobalCheck(evt){
//         this.fundRaisingContacts.forEach(contactRec =>{
//             contactRec.isSelected = evt.target.checked
//         })
//     }
//     // handle the gfund role check

//     handlefundRoleChange(evt) {
//         let currentId = evt.currentTarget.dataset.id;
//         let selectedOption = evt.detail.value;
//         this.fundRaisingContacts[currentId].role = selectedOption;
//     }
//     // handle the gfund team create

//     handleFundTeamCreate() {
//         let selectedFundContacts = [];
//         let fundIds = [];
//         this.fundRaisingContacts.forEach(fundRec =>{
//             if(fundRec.isSelected) {
//                 selectedFundContacts.push(fundRec)
//             }
//         })
//         this.newFundRaisingRecords.forEach(fund=>{
//             fundIds.push(fund.recId);
//         })
//         if(selectedFundContacts.length) {
//             createFundTeamRecords({
//                 fundJSONString : JSON.stringify(selectedFundContacts),
//                 fundRecordIds : fundIds
//             })
//             .then(res=>{
//                 const successToast = new ShowToastEvent({title: 'Success', message: 'Fund Team Added Successfully',variant: 'success',mode: 'dismissable'});
//                 this.dispatchEvent(successToast);
//                 if(!this.isRedirectToParentScreen) {
//                     // if(this.isCalledfromMobile){
//                     //     window.history.back();
//                     // }
//                     // else{
//                         window.location.reload();
//                     // }
//                 }
//                 else {
//                     this.navigateBackToParentScreen();
//                 }
//             })
//             .catch(err=>{
//                 const errorToast = new ShowToastEvent({title: 'Error', message: 'Error in creating Fund Team',variant: 'error',mode: 'dismissable'});
//                 this.dispatchEvent(errorToast);
//                 if(!this.isRedirectToParentScreen) {
//                     // if(this.isCalledfromMobile){
//                     //     window.history.back();
//                     // }
//                     // else{
//                         window.location.reload();
//                     // }
//                 }
//                 else {
//                     this.navigateBackToParentScreen();
//                 }
//             })
            
//         }

//     }


@track showSuggestedTagsModal = false;
@track suggestedRecords = [];
@track selectedSuggestedData = [];
@track openDealTeamModalFromFetchHelper = false;
@track suggestedFuntionalityDetailScreenData = {};
@track suggestedRecordsData = [];
@track suggestedFilteredData = [];
searchValue = '';
@track isBlur =false;
@track errMsg=false;
@track itemCount =0;
@track errSrch = false;
//selectedRows=[];

// Get the Detail Accordion data of Created By and Date
getDetailScreenData() {
    getActivityData({
        activityId : this.recordId,
        objectName : this.objectName
    })
    .then(res=>{
        if(res[0]!=undefined){
        let createdDate = ((res[0].CreatedBy==undefined || res[0].CreatedBy==null)? '' :new Date(res[0].CreatedDate));//FIx for Bug #00040046
        this.suggestedFuntionalityDetailScreenData = res[0];
        this.suggestedFuntionalityDetailScreenData.createdDateString = res[0].ActivityDate;//Bug #00039983
        // Bug 00047559 Fixed by Sudhanshu
        this.suggestedFuntionalityDetailScreenData.CreatedByName = ((res[0].CreatedBy==undefined || res[0].CreatedBy==null)? '' :res[0].Owner.Name);//FIx for Bug #00040046
        if(this.suggestedFuntionalityDetailScreenData.createdDateString=='Invalid Date'){
            this.suggestedFuntionalityDetailScreenData.createdDateString='';
        }
        this.commentStr = res[0].Description;
    }
    else{
        this.suggestedFuntionalityDetailScreenData.createdDateString ='';
        this.suggestedFuntionalityDetailScreenData.CreatedByName ='';
    }//changed for Bug #: 00039740: ended
    })
    .catch(err=>{
        const errorToast = new ShowToastEvent({title: 'Error', message: err,variant: 'error',mode: 'dismissable'});
        this.dispatchEvent(errorToast);
    })
}


handleSaveSuggessionRecords(){
    this.isLoading = true;
    if(!this.selectedSuggestedData.length) {
        // Bug 00046455 fixed by Sudhanshu on 05-07-2024
        const event = new ShowToastEvent({title: 'Error:',message: 'Select atleast a record.',variant: 'error',mode: 'dismissable'});
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
                        // Bug 00047565,00047564 Fix by Sudhanshu 
            if(!res.includes('Error')){
                        this.isLoading = false;
                        if((this.callFromNotification ||(!this.callFromNotification && this.isRedirectToParentScreen)) && !this.isCalledfromView){
                            
                            let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                            // Bug 00046114 fixed by sudhanshu on 18-06-2024
                            // Bug 00046749 fixed by sudhanshu on 24-07-2024
                            const event = new ShowToastEvent({title: 'Success:',message:'Record was saved.',//this.objectName + -> Removed for Bug #00038075
                            variant: 'success',
                            mode: 'dismissable', 
                            messageData: [
                                '',
                                {
                                    url: '/lightning/n/navpeII_dev18__Interactions?c__params='+allIteractionsParams,
                                    label: this.subject,
                                }
                            ]});
                            this.dispatchEvent(event);

                            this[NavigationMixin.Navigate]({
                                type: 'standard__webPage',
                                attributes: {
                                    url: '/lightning/n/Home_Mobile',//<!-- Bug 00045111 fixed by Sudhanshu on 22-04-2022 -->
                                }
                                });
                        }
                        
                        else if(this.redirectId != null && this.redirectId != ''){

                            let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                            // Bug 00046114 fixed by sudhanshu on 18-06-2024
                            // Bug 00046749 fixed by sudhanshu on 24-07-2024
                            const event = new ShowToastEvent({title: 'Success:',message:'Record was saved.',//this.objectName + -> Removed for Bug #00038075
                            variant: 'success',
                            mode: 'dismissable', 
                            messageData: [
                                '',
                                {
                                    url: '/lightning/n/navpeII_dev18__Interactions?c__params='+allIteractionsParams,
                                    label: this.subject,
                                }
                            ]});
                            this.dispatchEvent(event);

                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.redirectId,
                                    actionName: 'view',
                                },
                            })
                            return;
                        }    
                        else if((this.recordId != null && this.recordId != '')&& !this.isCalledfromView){
                            let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                            // Bug 00046114 fixed by sudhanshu on 18-06-2024
                            // Bug 00046749 fixed by sudhanshu on 24-07-2024
                            const event = new ShowToastEvent({title: 'Success:',message:'Record was saved.',//this.objectName + -> Removed for Bug #00038075
                            variant: 'success',
                            mode: 'dismissable', 
                            messageData: [
                                '',
                                {
                                    url: '/lightning/n/navpeII_dev18__Interactions?c__params='+allIteractionsParams,
                                    label: this.subject,
                                }
                            ]});
                            this.dispatchEvent(event);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordId,
                                    actionName: 'view',
                                },
                            })
                        }
                        
                        else{
                            let allIteractionsParams = JSON.stringify(this.createToastParams(this.recordId, this.objectName, 'view'));
                            // Bug 00046114 fixed by sudhanshu on 18-06-2024
                            // Bug 00046749 fixed by sudhanshu on 24-07-2024
                            const event = new ShowToastEvent({title: 'Success:',message:'Record was saved.',//this.objectName + -> Removed for Bug #00038075
                            variant: 'success',
                            mode: 'dismissable', 
                            messageData: [
                                '',
                                {
                                    url: '/lightning/n/navpeII_dev18__Interactions?c__params='+allIteractionsParams,
                                    label: this.subject,
                                }
                            ]});
                            this.dispatchEvent(event);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__webPage',
                                attributes: {
                                    url: '/lightning/n/Home_Mobile',//<!-- Bug 00045115 fixed by Sudhanshu on 22-04-2022 -->
                                }
                                });
                        }
                    }
                    else 
                    {
                        let err = res.split(':');
                        const event = new ShowToastEvent({title: 'Error:',message: err[1],variant: 'error',mode: 'dismissable'});
                        this.dispatchEvent(event);
                    }
                        
            }).catch(error => {
                const event = new ShowToastEvent({title: 'Error',message: 'Error in Tagging Records',variant: 'error',mode: 'dismissable'});
                this.dispatchEvent(event);
                this.isLoading = false;
            });
    }

    @api openTag=false;     // Bug 46156 fixed by Sudhanshu on 17-06-2024
//     // get Suggestions based on description field and get data from all the layout fields
     handleGetSuggestions(){
        //Fixed for Bug #38082 started
         this.isLoading = true;
         var potentialObjects=this.searchableObjectStr;

         if(this.openTag){       // Bug 46156 fixed by Sudhanshu on 17-06-2024
            // Bug 00042500, 00045901 fixed by Sudhanshu on 26-04-2024
            const jsonDataArray = JSON.parse(this.searchableObjectStr);
            potentialObjects = JSON.stringify(jsonDataArray.filter(item => item.objectName === 'Account' || item.objectName === 'Contact'));
            
        }
         //Fixed for Bug #38082
         this.extraTaggedRecords = [];
         // get Suggestions based on description field
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
                    specC = i.replace(/[-]/g, "\\$&");
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
                //  this.data = JSON.parse(data);
                 this.setSuggestedTableData(data);
                 this.isLoading = false;
                 this.isShowModal = false;
                 this.isSuggestShowModal = true;
                 this.getDetailScreenData();
                
             }else{
                 //this.handleSaveRecord();
                 this.isShowModal = false;
                 this.isLoading = false;
                if((this.callFromNotification ||(!this.callFromNotification && this.isRedirectToParentScreen))&& !this.isCalledfromView){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: '/lightning/n/Home_Mobile',// fixed for redirection issue after packaging Bug # 00045116
                        }
                        });
                }
                
                else if(this.redirectId != null && this.redirectId != ''){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.redirectId,
                            actionName: 'view',
                        },
                    })
                    return;
                }    
                else if(this.recordId != null && this.recordId != '' && !this.isCalledfromView){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view',
                        },
                    })
                }
                
                else{
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: '/lightning/n/Home_Mobile',// fixed for redirection issue after packaging Bug # 39277
                        }
                        });
                }
                
             } //Commented for removing Suggested Tags
            //Fixed for Bug #38082 started
         }).catch(error => {
             this.isLoading = false;
         });
        //Fixed for Bug #38082 ended
         }
         else{
            this.hideRecordModal();     // Bug 00045245 fixed by sudhanshu on 26-04-2024
         }
     }
// // handle the Suggested Table Data
    setSuggestedTableData(suggestedData) {
        this.suggestedRecords = [];
        this.suggestedRecordsData = [];
        this.itemCount = 0;
        let suggestedDataList = [];
        
        suggestedDataList = JSON.parse(suggestedData);
        for(var d in suggestedDataList) {
            this.suggestedRecords.push({
                id : parseInt(d),
                Deals : suggestedDataList[d].Name,
                name : suggestedDataList[d].objectName,
                dynamicIcon: suggestedDataList[d].iconName,
                recId : suggestedDataList[d].Id,
                objectName : suggestedDataList[d].objectName,
                isUser : suggestedDataList[d].isUser,
                isSelect : false
            });
        }

        this.suggestedRecordsData = this.suggestedRecords;
        this.totalCount=this.suggestedRecords.length;
    }

    totalCount=0;

    getSelectedSuggestedRecords(evt) {
        let selectedTaggedRows = evt.currentTarget.dataset.id;
        this.suggestedRecords[selectedTaggedRows].isSelect = evt.target.checked;

        this.selectedSuggestedData = this.suggestedRecords.filter(item => {
            return (item.isSelect==true);
        });
        this.itemCount=this.selectedSuggestedData.length;
        if(!this.selectedSuggestedData.length){
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('dash-filter');
        }
        else{
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.add('dash-filter');
        }
        if(this.suggestedRecords.length === this.itemCount){
            this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('dash-filter');
            this.globalCheck = true;
        }
        else{
            this.globalCheck = false;
        }
    }

    handleTagGlobalCheck(evt){  
        this.errMsg = false; 
        this.errSrch = false;
        this.template.querySelector('[data-id="TagGlobalCheckId"]').classList.remove('dash-filter');
        this.globalCheck = evt.target.checked;
        this.suggestedRecords.forEach(rec =>{
            rec.isSelect = evt.target.checked
        });
        this.selectedSuggestedData = this.suggestedRecords.filter(item => {
            return (item.isSelect==true);
        });
        this.suggestedRecordsData=this.suggestedRecords;
        this.itemCount=this.selectedSuggestedData.length;
    }

    // method added by sudhanshu on 20/03/2023
    handleBlurSearch(event){
        this.isBlur=true;
        this.handleSearch(event);
    }

    // method added by sudhanshu on 20/03/2023
    handleSearch(event)
    {
        this.searchValue = event.target.value.trim();
        if(this.suggestedFilteredData.length == 0)
        {
            this.suggestedFilteredData = this.suggestedRecords;
        }
        if(event.keyCode === 13 || this.isBlur == true)
        {
            this.errMsg = false;
            this.errSrch = false;
            this.isBlur=false;
            let searchTerm = this.searchValue;
            // let allData = this.suggestedFilteredData.filteKr(item => !this.selectedRecs.includes(item));
            if(searchTerm.length > 1){
                console.log('suggestedFilteredData--->'+JSON.stringify(this.suggestedFilteredData));
                this.suggestedRecordsData = this.suggestedFilteredData.filter(result =>
                       result.Deals.toLowerCase().includes(searchTerm.toLowerCase())
                );
                // this.suggestedRecordsData = this.suggestedRecords;
                if(this.suggestedRecordsData.length == 0)
                {
                    this.errMsg = true;
                }
            }
            else if(searchTerm.length == 0)
            {
                // this.suggestedRecords =  this.suggestedFilteredData.filter(item => !this.selectedRecs.includes(item));
                this.suggestedRecordsData = this.suggestedRecords;
            }
            else{
                this.suggestedRecordsData=[];
                // this.errMsg = true;
                // const errorToast = new ShowToastEvent({title: 'Error', message: 'Your search term must have 2 or more characters.',variant: 'error',mode: 'dismissable'});
                // this.dispatchEvent(errorToast);
                this.errSrch = true;
            }
        }
        else if(event.target.value.length === 0) {
            this.errMsg = false;
            this.errSrch = false;
            this.suggestedRecordsData = this.suggestedRecords;
        }
    }

//     // handle to get the suggested data
//     getSelectedSuggestedRecords(evt) {
//         let selectedTaggedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
//         this.itemCount = selectedTaggedRows.length;
//         this.selectedSuggestedData = selectedTaggedRows;
//     }

//     // handle the global checkbox to select or deselect of Deal team creation
    handleSuggestedRecordsSave() {
        this.isLoading = true;
        if(!this.selectedSuggestedData.length) {
            const event = new ShowToastEvent({title: 'Error',message: 'Please select at least one record',variant: 'error',mode: 'dismissable'});
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
            const successToast = new ShowToastEvent({title: 'Success',message: 'Records Tagged Successfully',variant: 'success',mode: 'dismissable'});
            this.dispatchEvent(successToast);
            this.isLoading = false;
            this.openDealTeamModalFromFetchHelper = true;
            this.isInitRun = false;
            this.fetchRecordData();
            this.navigateToRecordPage();
            //this.openDealTeamModal();
         })
         .catch(err =>{
            const errorToast = new ShowToastEvent({title: 'Error',message: 'Error in Tagging Records',variant: 'error',mode: 'dismissable'});
            this.dispatchEvent(errorToast);
            this.isLoading = true;
            this.navigateToRecordPage();
            //this.openDealTeamModal();
         })
        
    }

//     // handle the global checkbox to select or deselect of Deal team creation
//     closeSuggestedModal() {
//         this.openDealTeamModal();
//     }

//     // Open Pill from Suggested Tags Detail sreen
//     openTaggedRecord(evt) {
//         let recordId = evt.currentTarget.dataset.id;
//         let redirectUrl = '/'+recordId;
//         window.open(redirectUrl, "_blank");
//     }



    

   

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
   
    showDropDown(){
        let sldsIsOpenClass = this.template.querySelector(".slds-dropdown-trigger_click");
       // sldsIsOpenClass.classList.add("slds-is-open");
        
        const dropDown = this.template.querySelector('[data-id="listbox-id-1"]');
        const inputField = this.template.querySelector('[data-id="combobox-id-1"]');
        document.getElementById('combobox-id-1-730').onclick = function() {
        };

    }
    hideDropDown(){
        let sldsIsOpenClass = this.template.querySelector(".slds-dropdown-trigger_click");
        sldsIsOpenClass.classList.remove("slds-is-open");
        
    }
    /* add contact to deal */
    clrChange(event){
        let bgWhite = event.target.closest('.clrChange')
        bgWhite.classList.toggle('red');
        
    }
//     handleQuickCreateAccountContact(){
//         // const objChild = this.template.querySelector('c-quic-Create-Account-Contact');
//         // objChild.openModal();
//         this.isModalOpen = false;
//         this.isaddContactToDealTeam = true;
//         this.isDiscoverOpen = false;
//     }

}