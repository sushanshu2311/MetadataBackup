/****************************************************************************************************

** Module Name : Clips

** Description : Used save add note and tag records for clip

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

**************************************************************************************************** */
import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClipsRelatedObjectInfo from '@salesforce/apex/NavatarClipsCtrl.getClipsRelatedObjectInfo';
import getCurrentUserInfo from '@salesforce/apex/NavatarClipsCtrl.getCurrentUserInfo';
import getClipData from '@salesforce/apex/NavatarClipsCtrl.getClipData';
import {createMessageContext, releaseMessageContext, APPLICATION_SCOPE, subscribe, unsubscribe} from 'lightning/messageService';
import clipId from "@salesforce/messageChannel/navatarClipLwcAuraChannel__c"; 
import clipIdmsg from "@salesforce/messageChannel/navatarClipAuraLwcChannel__c"; 
import { NavigationMixin } from 'lightning/navigation';

import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';

export default class NavatarClipsLWC extends NavigationMixin(LightningElement) {
    currentUserName;
    error;
    objectInfo;
    userId = Id;
    @track commentStr = '';
    @track allTaggedRecords = [];
    @track isTag = false;
    @track clipId = '';

    @track clipName = '';
    @track clipSummary = '';

    @track subscription = null;
    context = createMessageContext();
    @track currentUserList = [];
    @track isLoading = false;
 
    // get current user data
    @wire(getRecord, { recordId: Id, fields: [UserNameFld]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;  
        } else if (error) {
            
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
        }
        this.currentUserList = [];
        this.currentUserList.push({"objectName":"User","Name":this.currentUserName,"Id": this.userId,"iconName":"standard:user"});
       
    }

    // to Subscribe message channels
    handleSubscribe() { 
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();

        this.subscription = subscribe(this.context, clipId, (message) => {
            this.handleClipEdit(message);
        }, {scope: APPLICATION_SCOPE});

        this.subscription = subscribe(this.context, clipIdmsg, (message) => {
            this.handleSaveClip(message);
        }, {scope: APPLICATION_SCOPE});
    }
 
    // to open "all clip" tab on save of clip and clear old clip data
    handleSaveClip(event){
        if (event) {
            let message = event.savemessage;
            this.commentStr = '';
            this.allTaggedRecords = this.currentUserList;
            localStorage.setItem("clipData", '');
            localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));
            this.commentStr = '';
            window.setTimeout(()=>{
                
                localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));
                localStorage.setItem("savedClipId", '');
            },  1000)

            if(message != 'close'){
                window.open( 'https://' +window.location.hostname + '/lightning/n/navpeII_dev18__Clips?c__isModalOpen='+message , '_self');
                
            }
            if(message == 'close'){
                location.reload();
            }
        }
    }

    // to get clip data on click of edit
    handleClipEdit(event) {
        if (event) {
            let message = event.messageBody;
            this.clipId = message;
            localStorage.setItem("savedClipId", this.clipId);
            this.handleGetClipData();
        }
    }
    // to get clip data on click of edit and set them into localStorage
    handleGetClipData(){
        this.isLoading = true;
        
        getClipData({
            clipId : this.clipId,
            ObjectInfo : this.objectInfo
        }).then(data => {
            this.allTaggedRecords = [];
            let clipData = JSON.parse(data);
            this.commentStr = clipData.clipNotes;
            this.allTaggedRecords = JSON.parse(clipData.clipTaggedRecords);
            this.clipName = clipData.clipName;
            this.clipSummary = clipData.clipSummary;
            this.isLoading = false;

            //set note and tagged record into localStorage
            localStorage.setItem("clipData", this.commentStr);
            localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));
            

        })
        .catch(error => {
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
            this.isLoading = false;
        });
    }
 
    // get note and tagged records from localStorage and add event listener on load of component
    connectedCallback(){
        this.handleSubscribe();
        try{
            localStorage.setItem("isClose", '');
            // check logged in user id in localStorage, if not found clear localStorage and set userid
            if(localStorage.getItem('userId') != this.userId ){
                localStorage.clear();
                localStorage.setItem("userId", this.userId);
            }

            // get note and tagged records from localStorage
            if(localStorage.getItem('clipData') != null && localStorage.getItem('clipData') != 'null'){
                this.commentStr = localStorage.getItem('clipData');
            }else{
                this.commentStr = '';
            }
           
            if(localStorage.getItem('taggedRec') != null && localStorage.getItem('taggedRec') != ''){
                this.allTaggedRecords = JSON.parse(localStorage.getItem('taggedRec'));
            }
            
            localStorage.setItem("clipData", this.commentStr);
            localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));

            this.handleGetClipsRelatedObjectInfo();
            this.handleGetCurrentUser();

            //add event listener on load of component on localStorage to get changed data from another tab
            window.addEventListener("storage", () => {
                if(localStorage.getItem('clipData') != null && localStorage.getItem('clipData') != 'null'){
                    this.commentStr = localStorage.getItem('clipData');
                }else{
                    this.commentStr = '';
                }
                this.allTaggedRecords = JSON.parse(localStorage.getItem('taggedRec'));
                
            });

        }catch(e){
            const event = new ShowToastEvent({title: 'Error1',message: e.message,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
            
        }
    }

    // to get default currentUser as tagged
    handleGetCurrentUser(){
        getCurrentUserInfo().then(data => {
            if(this.allTaggedRecords.length == 0){
                this.allTaggedRecords.push(data);
                localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));
            }
        })
        .catch(error => {
            const event = new ShowToastEvent({title: 'Error',message: error,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
        });
    }

    // to get metadata of clips setup object
    handleGetClipsRelatedObjectInfo(){
        getClipsRelatedObjectInfo().then(data => {
            this.objectInfo = data;
        })
        .catch(error => {
            const event = new ShowToastEvent({title: 'Error',message: error.message,variant: 'error',mode: 'sticky'});
            this.dispatchEvent(event);
        });
    }

    //Function is called once data is copied and pasted into the clipboard
    handleDataPaste(event){
        // check if record id found set id in localStorage
        if (window.location.origin) {
            var urlId = window.location.toString();
            var arr=[];
            arr=urlId.split("/");
            var dataId=arr[arr.length-2];

            if(dataId.length == 15 || dataId.length == 18){
                var recentIds = localStorage.getItem('clipRecords');
                localStorage.setItem("clipRecords", recentIds + ','+dataId);
            }
            
        }
        
        //assign latest in to variable and localStorage
        this.commentStr = event.target.value;
        localStorage.setItem("clipData", this.commentStr);
        
    }

    
    //Function is called once there is any change inside the clipboard 
    handleChange(event) {
        //assign latest in to variable and localStorage
        
        if(event.target.value.length == 0){
            localStorage.setItem('clipData', event.target.value);
        }
        var dataVal = event.target.value;
        localStorage.setItem("clipData", dataVal);

        // check if record id found set id in localStorage
        if (window.location.origin) {
            var urlId = window.location.toString();
            var arr=[];
            arr=urlId.split("/");
            var dataId=arr[arr.length-2];
            
            if(dataId.length == 15 || dataId.length == 18){
                var recentIds = localStorage.getItem('clipRecords');
                
                if(recentIds != null && !recentIds.includes(dataId)){
                    localStorage.setItem("clipRecords", recentIds + ','+dataId);
                }
            }
            
        }
        
    }

    //This is called once the data is dragged and dropped inside the clipboard.
    handleDataDrop(evt) {
        
        // check if record id found set id in localStorage
        if (window.location.origin) {
            var urlId = window.location.toString();
            var arr=[];
            arr=urlId.split("/");
            var dataId=arr[arr.length-2];

            if(dataId.length == 15 || dataId.length == 18){
                var recentIds = localStorage.getItem('clipRecords');
                localStorage.setItem("clipRecords", recentIds + ','+dataId);
            }
            
        }

        //assign latest in to variable and localStorage
        const editor = this.template.querySelector('lightning-textarea');
        let droppedVal = evt.dataTransfer.getData("Text");
        
       
        try{
            this.commentStr = editor.value;
            localStorage.setItem("clipData", this.commentStr);
            
            window.setTimeout(()=>{
                
                editor.setRangeText('',  this.commentStr.length + droppedVal.length , this.commentStr.length + droppedVal.length, 'end');
                editor.focus();
                if(!editor.value.endsWith("\n")){
                    this.commentStr = editor.value + '\n';
                }
                
            },  500)
            
        }
        catch(e){
        }
        
    }

    // to open and close record search component
    handleTag() {
        this.isTag = !this.isTag;
    }

    // add selected record to tagged record list from searched result
    handleSelectLookup(event){
        let selectedRecord = JSON.parse(event.detail);
        this.handleAddTaggedRecord(selectedRecord);
    }

    // add selected record to tagged record list from searched result and manage a sequence
    handleAddTaggedRecord(selectedRecord){
        let idAdded = false;
        let oldTaggedRecords = this.allTaggedRecords;
        for(let i = 0; i < this.allTaggedRecords.length; i++){
            if(selectedRecord.Id == this.allTaggedRecords[i].Id){
                idAdded = true; break;
            }
        }
        if(!idAdded){
           oldTaggedRecords.push({Name:selectedRecord.Name, Id:selectedRecord.Id, iconName:selectedRecord.iconName, objectName: selectedRecord.objectName});
        }
        

        let objArray = ['Account', 'Contact', 'navpeII_dev18__Pipeline__c', 'navpeII_dev18__Fund__c', 'navpeII_dev18__Fundraising__c', 'navpeII_dev18__Theme__c', 'User'];
        let tagSequence = new Map();

        for (let taggedRecord of oldTaggedRecords) {
            
            let temp = tagSequence.get(taggedRecord.objectName);
            
            if(typeof temp === 'undefined'){
                temp = [];
            }
            temp.push(taggedRecord);
            tagSequence.set(taggedRecord.objectName, temp);
        }
        oldTaggedRecords = [];
        for (let objName of objArray) {
            
            if(typeof tagSequence.get(objName) !== 'undefined'){
                oldTaggedRecords = oldTaggedRecords.concat(tagSequence.get(objName));
            }
            
        }
        this.allTaggedRecords = oldTaggedRecords;
        localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));
    }

    // remove record from tagged records
    removeRecord(event){
        let selectRecId = [];
        for(let i = 0; i < this.allTaggedRecords.length; i++){
            if(event.detail.name !== this.allTaggedRecords[i].Id)
                selectRecId.push(this.allTaggedRecords[i]);
        }
        this.allTaggedRecords = [...selectRecId];
        localStorage.setItem("taggedRec", JSON.stringify(this.allTaggedRecords));
    }

    // to open save popup on click of save button/
    openClipPop(){
        let objInfo = this.objectInfo;
        let clipName = this.clipName;
        let clipSummary = this.clipSummary;
        let clipId = this.clipId;
        const selectedEvent = new CustomEvent("opensaveclipmodal", {
            detail: {  objInfo, clipName, clipSummary, clipId  }
          });
      
        // Dispatches the event to aura and aura will open save modal.
        this.dispatchEvent(selectedEvent);
        this.clipId = '';
    }

    handleClearNotes(){
        [...this.template.querySelectorAll('lightning-textarea')].forEach((input) => { input.value = ''; });
        var comment = '';
        this.commentStr = comment;
        const editor = this.template.querySelector('lightning-textarea');
        editor.focus();
        localStorage.setItem("clipData", this.commentStr);
    }

    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.clip-section .slds-rich-text-editor__toolbar.slds-shrink-none{
            display:none;
        }
        .slds-pill__remove{
            display: block;
            position: relative;
            top: -4px;
         
        }
        .slds-form-element__label:empty{
            display: none !important;
        }
        `;  
        let popurl;
        popurl = window.location.search;
        if(popurl == "?0.windowed=true"){
            style.innerText = `
            .heightonpop .slds-textarea{
               
                min-height: 180px !important;
            }
            .fillgap_css{
                margin-left:0%;
            }
            .helptext_css{
                padding-right: 19px !important;
                padding-bottom: 0px;
            }
            @media (min-width: 64em){
                .heightonpop .slds-textarea{
                        min-height: 500px !important;
            }
            .fillgap_css{
                margin-left:-7.4%;
            }
            ul.drop_ul{
                margin-left: -5.4%;
                left: 0px !important;
                z-index: 15003 !important;
                width: 104.1% !important;
            }

        }`
        }
            

        this.template.querySelector('.main-Container').appendChild(style);
      
    }

    // Unsubscribe message channels
    disconnectedCallback(){
        this.handleUnsubscribe();
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }

}