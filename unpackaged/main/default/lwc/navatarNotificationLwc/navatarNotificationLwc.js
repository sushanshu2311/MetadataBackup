/****************************************************************************************************
  
    ** Module Name : Connections 2.0 - Custom Notification
    ** Description : Used to handle notification popup to home page related funtionalities of Connections 2.0 Custom Notification.
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Connections 2.0
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2022-08-02          Priyank        fetch and update event's records
    ** 2.0        2022-08-30          Priyank        merge with UI 2
    ** 3.0        2022-09-26          Priyank        update as per new CR
    ** 4.0        2022-11-16          Adil           Phase 2 changes
    ** 5.0        2023-11-06          Anmol          Patch 3 CR (Bug # 00043018)
    ** 6.0        2024-04-11          Deepak         Phase 3 CR Fix for View Notes on Blank Screen
****************************************************************************************************/
import { LightningElement,track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchAllEventsRecords from '@salesforce/apex/NavatarNotificationCtrl.fetchEventData';/*bug fixed : 00031575*/
//Code removed for notification by Pavani as part of 00037883
//import checkNotificationVisibleForuser from '@salesforce/apex/NavatarNotificationCtrl.checkNotificationVisibleForuser';
import dismissNotification from '@salesforce/apex/NavatarNotificationCtrl.dismisNotification';
import { updateRecord } from 'lightning/uiRecordApi';
import NN_READ_FIELD from '@salesforce/schema/Navatar_Notification__c.Read__c';
import ID_FIELD from '@salesforce/schema/Navatar_Notification__c.Id';
import fetchOrgDomain from '@salesforce/apex/NavatarNotificationCtrl.fetchOrgDomain';
//added by pavani w.r.t security fix
import {  getObjectInfo } from 'lightning/uiObjectInfoApi';
import NAVATAR_NOTIFICATION from '@salesforce/schema/Navatar_Notification__c';
import checkAccessibility from '@salesforce/apex/NavatarNotificationCtrl.checkAccessibility';

export default class navatarNotificationLwc extends NavigationMixin(LightningElement) {
    @track isShowModal = false;
    @track notificationRecords;
    @track isNotificationCount = false;
    @track orgDomainURL;
    @track isLoading = false;
    @track notificationCount;
    @track eventRecordId;
    @api isRedirectToRecord = false;
    //added by pavani w.r.t security fix
    nnIsDeleteable = false;
    accessResult = false;
    ObjectApiNames = ['Event','Task'];

    //added by pavani w.r.t security fix
    @wire(getObjectInfo,{objectApiName:NAVATAR_NOTIFICATION})
    notificationObjInfo({error,data}){
        if(error){
            this.showNotification(this, 'Error!', error.body.message, 'error');
        }else if(data){
            console.log(JSON.stringify(data));
            this.nnIsDeleteable = data.deletable?true:false;
            }
        }

    
     /*for mobile conversion of popup to page */
     clickAddNoteMob(event){
        this.notificationRecords[event.currentTarget.dataset.index].read = true;
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('white');
        }   
        let notificationId = this.notificationRecords[event.currentTarget.dataset.index].id;
        let recordId = this.notificationRecords[event.currentTarget.dataset.index].recordId;
        //alert(recordId);
        this.markRead(notificationId);
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarNotesMobileLwc",
           
            attributes: { 
            propertyValue: "500", 
            callFromNotification:true,
            recordId:recordId,
            isCalledfromMobile:true,
            isRedirectToRecord:true,
            objectName:"Event"
            }};
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/one/one.app#' + encodedCompDef
            }
            });
    }

     // Bug 46156 fixed by Sudhanshu on 17-06-2024
    clickAddTagMob(event){
        this.notificationRecords[event.currentTarget.dataset.index].read = true;
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('white');
        }   
        let notificationId = this.notificationRecords[event.currentTarget.dataset.index].id;
        let recordId = this.notificationRecords[event.currentTarget.dataset.index].recordId;
        //alert(recordId);
        this.markRead(notificationId);
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarNotesMobileLwc",
           
            attributes: { 
            propertyValue: "500", 
            callFromNotification:true,
            recordId:recordId,
            isCalledfromMobile:true,
            isRedirectToRecord:true,
            objectName:"Task",
            openTag:true
            }};
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/one/one.app#' + encodedCompDef
            }
            });
    }
    
    viewNotificationClickMob(event){
        this.notificationRecords[event.currentTarget.dataset.index].read = true;
        let bgWhite = event.currentTarget.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('white');
        }   
        let notificationId = event.currentTarget.dataset.id;
        this.markRead(notificationId);
        let recType = this.notificationRecords[event.currentTarget.dataset.index].recObjType;
        let recordId = event.currentTarget.dataset.recordId;
        if(recType == 'Account' && recordId!= null){
            this.accountRedirect(recordId);
        }else if(recordId != null && recType === 'navpeII_dev18__Clip__c') {
            this.allClipsRedirect(recordId);
        }else if(recordId != null && ['Task', 'Event'].includes(recType)){
            var compDefinition = {
                componentDef: "navpeII_dev18:navatarAllInteractionsViewModalMobileLwc",
                attributes: {
                propertyValue: "100"
                },
                state:{
                    c__recordId : event.currentTarget.dataset.recordId,
                    c__componentName : "view",
                    c__objectType : "Event"
                }
                };
                var encodedCompDef = btoa(JSON.stringify(compDefinition));
                this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                url: '/one/one.app#' + encodedCompDef
                }
                });
        }
    }
    /* end mob */
    dismissNotification(event){
        this.isLoading = true;
        let notificationId = event.target.dataset.id;
        let dismissData = event.target.closest('.dismiss_notificationcss');
        dismissNotification({notificationId : notificationId})
        .then((result) => {
            if(result) {
                dismissData.classList.add('dynamicCSS');
                this.notificationRecords = this.notificationRecords.filter(val => val.id != notificationId);  
                console.log('notificationRecords----' + this.notificationRecords.length);
                if(this.notificationRecords.length == 0){
                    this.isShowModal = false;
                }
            } else{
                this.showNotification('Error','You do not have permission. Please contact your Navatar Administrator.', 'error');
            }  
        })
        .catch((error) => {
            this.showNotification('Error',error.body.message, 'error');
        })
        .finally(() =>{
            this.isLoading = false;
        }); 
    }

     //Fetches all Notification records
     connectedCallback(){
        //Code removed for notification by Pavani as part of 00037883
        //this.notificationVisibilityStatus();
        //added by pavani w.r.t security fix
        this.checkAccessibility();
        this.showCustomNotification();
        
    }
    //added by pavani w.r.t security fix
    checkAccessibility(){
        checkAccessibility({feildObj:this.ObjectApiNames})
        .then((result)=>{
            this.accessResult = result;
        })
        .catch((error)=>{
            this.showNotification('Error',error.body.message,'error');
        })
        
    }
    // click to bell icon for display all events records as a notifications
    showCustomNotification(){
        this.isLoading = true;
        fetchAllEventsRecords()
        .then((result) => {
            if(result!= null){
                if(result.length > 0){
                    //this.notificationCount = result.length; 
                    for(let i=0; i<result.length; i++){
                        //added by pavani w.r.t security fix
                         result[i].isAddNote = result[i].type == 'Add Note' && this.accessResult[0]=='eventIsUpdateable' ? true : false;
                        result[i].isAddTag =  result[i].type == 'Add Tag' && this.accessResult[1]=='taskIsUpdateable' ? true : false;
                        result[i].rowClass = !result[i].read
                                          ? 'slds-border_top noti_back_clr clrChange slds-p-horizontal_small dismiss_notificationcss'
                                          : 'slds-border_top clrChange slds-p-horizontal_small dismiss_notificationcss';
                        //00038097 added to disable click for Clip info Notification
                        result[i].isClipInfoRec = result[i].type=='Clip Info'?true:false;
                        if(result[i].isClipInfoRec){
                            result[i].rowClass= result[i].rowClass + ' clipInfoMob';
                        }//00038097 end
                    }
                    result.sort((n1, n2) => {
                        return n2.sortingOrder - n1.sortingOrder;
                    });
                    //Patch 3 CR (Bug # 00043018): start
                    let allNotifications = result;
                    // bug 00045836 fixed by Sudhanshu on 21-05-2024
                    this.notificationRecords = allNotifications;
                            this.notificationCount = allNotifications.length;
                            if(this.notificationCount > 0){// Code Review Feedback 
                                this.isShowModal= true; //Bug # 00043026
                            }
                    
                }
            }
        })
        .catch((error) => {
            this.showNotification('Error', error.body.message, 'error');
        })
        .finally((fn) => {
            this.isLoading = false;
        });

    }
    //redirect to other component to add notes
    clickAddNote(event){
        this.notificationRecords[event.target.dataset.index].read = true;
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('white');
        }   
        let notificationId = this.notificationRecords[event.target.dataset.index].id;
        let recordId = this.notificationRecords[event.target.dataset.index].recordId;
        this.markRead(notificationId);
        if(recordId != null) {
            this.allInteractionRedirect(recordId, 'Event', 'addNote');
        }
    }

    //redirect to other component to add tags
    clickAddTag(event){
        this.notificationRecords[event.target.dataset.index].read = true;
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('white');
        }   
        let notificationId = this.notificationRecords[event.target.dataset.index].id;
        let recordId = this.notificationRecords[event.target.dataset.index].recordId;
        this.markRead(notificationId);
        if(recordId != null) {
            this.allInteractionRedirect(recordId, 'Task', 'addTag');
        }
    }

    // hide modal pop up when click on "Cancel" or "X"
    hideModalBox() {  
        this.isShowModal = false;
    }
    //Displays toast notification as per the details provided
    showNotification(title, msg, variant){
        const evt = new ShowToastEvent({
            title : title,
            message : msg,
            variant : variant
        });
        this.dispatchEvent(evt);
    }

    // /* to fix the UI-bug - 00031629 - 23-09-22*/------------------------------	
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = ` lightning-layout.noti_back_clr.clrChange.slds-p-horizontal_small.slds-grid.slds-grid_vertical-align-center{
            justify-content: start !important;
        }
        .customBrandButton button.slds-button.slds-button_brand{
            white-space: nowrap;
        }
        .customButtonWidth button.slds-button {
            width: 89px;
            font-size:12px;
        }
        .customButtonWidthReviewdesk button.slds-button {
            width: 89px;
        }
        `;
        try {
         //  this.template.querySelector('.main-Container-noti').appendChild(style);
            this.template.querySelector('.slds-modal__content').appendChild(style);
           
       } catch (err) {
           console.log(err)
       }
    }

    viewNotificationClick(event){
        console.log(event.target.dataset.index);
        let recType = this.notificationRecords[event.target.dataset.index].recObjType;
        this.notificationRecords[event.target.dataset.index].read = true;
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('white');
        }   
        let notificationId = event.target.dataset.id;
        let recordId = event.target.dataset.recordId;
        this.markRead(notificationId);
        if(recordId != null && recType === 'Account') {
            this.accountRedirect(recordId);
        }
        else if(recordId != null && ['Task', 'Event'].includes(recType)) {
            this.allInteractionRedirect(recordId, recType, 'view');
        }
        else if(recordId != null && recType === 'navpeII_dev18__Clip__c') {
            this.allClipsRedirect(recordId);
        }

        //allClipsRedirect
    }

    markRead(nId){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = nId;
        fields[NN_READ_FIELD.fieldApiName] = true;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                console.log('---notification read---' + nId);
            })
            .catch(error => {
                this.showNotification('Error creating record', error.body.message, 'error');
            });
    }
    
    accountRedirect(recordId) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: "Account",
                actionName: 'view'
            },
        }).then(url => {
            console.log('Return page URL = ' + url);
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Account',
                    actionName: 'edit'
                },
                state: {
                    nooverride: 1,
                    navigationLocation: 'DETAIL',
                    backgroundContext: url
                }
            }).then(finalURL => {
                window.open(finalURL , "_blank");
            });
        });
        
    }

    refreshNotification(){
        this.connectedCallback();  
    }

    allInteractionRedirect(recordId, recType, mode){
        let params = {};
        params['recId'] = recordId;
        params['recType'] = recType;
        params['mode'] = mode;
        //Bug Id - 00045252 View_Interaction Fixed by Deepak Tab name change
        let url = '/lightning/n/navpeII_dev18__View_Interaction?c__params=' + JSON.stringify(params); //Changes for View Notes on blank screen Phase 3 CR
        window.open(url, '_blank');
    }

    allClipsRedirect(recordId){
        //let params = {};
        //params['recId'] = recordId;
        let url = '/lightning/n/navpeII_dev18__Clips?c__isModalOpen=' + recordId;
        window.open(url, '_blank');
    }

}