/****************************************************************************************************
  
    ** Module Name : Connections 2.0 - Custom Notification
    ** Description : Used to handle notification bell icon related funtionalities of Connections 2.0 Custom Notification.
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Connections 2.0
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2022-08-02          Priyank        fetch and update event's records
    ** 2.0        2022-09-26          Priyank        update as per new CR
    ** 3.0        2022-11-14          Priyank        update as per phase 2 UI
    ** 4.0        2023-11-06          Anmol          Patch 3 CR (Bug # 00043018)

****************************************************************************************************/
import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchOrgDomain from '@salesforce/apex/NavatarNotificationCtrl.fetchOrgDomain';
import fetchAllEventsRecords from '@salesforce/apex/NavatarNotificationCtrl.fetchEventDataforRecord';/*bug fixed : 00031575*/
import dismissNotification from '@salesforce/apex/NavatarNotificationCtrl.dismisNotification';
import { updateRecord } from 'lightning/uiRecordApi';
import NN_READ_FIELD from '@salesforce/schema/Navatar_Notification__c.Read__c';
import ID_FIELD from '@salesforce/schema/Navatar_Notification__c.Id';
import isNavatarNotificationsAllowed from '@salesforce/apex/NavatarUtility.isNotificationAllowed';
//added by pavani w.r.t security fix
import {  getObjectInfo } from 'lightning/uiObjectInfoApi';
import NAVATAR_NOTIFICATION from '@salesforce/schema/Navatar_Notification__c';
import checkAccessibility from '@salesforce/apex/NavatarNotificationCtrl.checkAccessibility';

export default class navatarAcuityNotificationLwc extends NavigationMixin(LightningElement) {
    @track notificationRecords=[];
    @track isNotificationShow = false;
    @track isNotificationCount = false;
    @track isAddNoteClick = false;
    @track orgDomainURL;
    @track notificationUnreadCount = 0;
    @track eventRecordId;
    @track isLoaded = false;
    @track notifiy = ''; //------- for scroller behaviour according to screen height--bug-id-31180--UI----------- //
    @api isRedirectToRecord = false;
    isNotificationsAllowed;
    @api recordId;
    isShowNote = false;
    isLoading;
    actRecId = '';  //Stores ID of Event for which Add Note button is clicked
    actRecType = '';//Activity(Task/Event) object API name
    isReviewTag = false;
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
     
    connectedCallback(){
        //added by pavani w.r.t security fix
        this.checkAccessibility();
       // fetch org domain
        fetchOrgDomain()
        .then((result) => {
                this.orgDomainURL = result;
        })
        .catch((error) => {
            this.showNotification('Error', error.body.message, 'error');
        });
        this.checkNofticationsAllowed();
        console.log('objectApiName'+this.objectApiName);
        this.fetchNotificationData(); // resolve redirection issue
        // UI change----------12-10-22-----for-notication-outside-click--------------------//
        let parentThis = this;
        this.template.addEventListener('click',function(e){ 
            console.log("@@@@@@@@check",e.target)            
            console.log(parentThis.isNotificationShow)
            if(!e.target.closest(".sec-notify") && parentThis.isNotificationShow){
                parentThis.closeDialog()  
                parentThis.check_n = true;
            } 
            else if(e.target.closest(".sec-notify")){
                parentThis.check_n = true;
            }  
            else{
                parentThis.check_n = false;
            }       
        });  
        document.addEventListener('click',function(e){ 
            setTimeout(() => {
                if(!parentThis.check_n){
                    console.log("@@@@@@@@check",e.target)            
                    console.log(parentThis.isNotificationShow)
                    if(parentThis.isNotificationShow){
                        parentThis.closeDialog()   
                    }   
                }
                else{
                    parentThis.check_n = false;
                }        
            });  
        } ); 
        // UI change--------12-10-22---------end----------------------------------//
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
    checkNofticationsAllowed(){
        
        isNavatarNotificationsAllowed()     
        .then(result=>{
        
            
        this.isNotificationsAllowed = (result.action ||result.info );
        })
        .catch(error=>{
            this.showNotification('Error', error.body.message, 'error');
        });
    }
        
    dismissNotification(event){
        this.isLoading = true;
        let notificationId = event.target.dataset.id;
        let dismissData = event.target.closest('.dismiss_notificationcss');
        dismissNotification({notificationId : notificationId})
        .then((result) => {
            if(result) {
                dismissData.classList.add('dynamicCSS');
                this.notificationRecords = this.notificationRecords.filter(val => val.recordId != notificationId);  
                if(this.notificationRecords.length == 0){
                    this.isNotificationCount = false;
                }
            }  
        })
        .catch((error) => {
            this.showNotification('Error', error.body.message, 'error');
        })
        .finally(() =>{
            this.isLoading = false;
        }); 
    }
    //added by pavani for refresh on acuity pages
    refreshAcuityNotification(){
        this.isLoading = true;
        this.fetchNotificationData();
        
    }
    //fetch all related event's records 
    fetchNotificationData(){
        let unreadNotifications = [];
        console.log('====recordId===' + this.recordId);
        fetchAllEventsRecords({recordId : this.recordId})
        .then((result) => {
            console.log('====recordId===' + JSON.stringify(result));
            if(result!= null){
                if(result.length > 0){
                    //this.isNotificationCount = true;
                    for(let i=0; i<result.length; i++){
                        result[i].isAddNote = result[i].type == 'Add Note' && this.accessResult[0]=='eventIsUpdateable'? true : false;
                        result[i].isAddTag =  result[i].type == 'Add Tag' && this.accessResult[1]=='taskIsUpdateable'? true : false;
                        result[i].rowClass = !result[i].read
                                            ? 'slds-grid slds-wrap slds-border_top dismiss_notificationcss noti_back_clr clrChange'
                                            : 'slds-grid slds-wrap slds-border_top dismiss_notificationcss pd_tb_mob';
                        if(!result[i].read){
                            //added by pavani to show correct notification count
                            unreadNotifications.push(result.filter(val=> val.id==result[i].id)); 
                        }                    
                    }
                    //added by pavani to show correct notification count
                    //this.notificationUnreadCount = unreadNotifications.length; //Bug # 00043028
                    result.sort((n1, n2) => {
                        return n2.sortingOrder - n1.sortingOrder;
                    });
                    //Patch 3 CR (Bug # 00043018): Start
                    let allNotifications = result;
                    // bug 00045836 fixed by Sudhanshu on 21-05-2024
                    let notificationCount = 0;
                    this.notificationRecords = allNotifications;
                    notificationCount = unreadNotifications.length;
                    if(this.notificationRecords.length > 0){// Bug # 43053 
                        this.notificationUnreadCount = notificationCount; //Bug # 00043028
                        this.isNotificationCount= true;
                    }
                   
                }else{
                    //this.notificationRecords = result;
                    this.notificationUnreadCount = unreadNotifications.length;
                    this.isNotificationCount=false;
                }
            }
        })
        .catch((error) => {
            this.showNotification('Error', error.message, 'error');
        })
        .finally((fn) => {
            this.isLoading = false;
        });
    }
    // click to bell icon for display notification
    showCustomNotification(){
        this.isLoading=true
        this.isLoaded = true;
        this.isAddNoteClick = false;
        this.fetchNotificationData();
        //this.isNotificationShow = !this.isNotificationShow;
        //----------------- for scroller behaviour according to screen height-20-09-22---bug-id-31180---UI--20-09-22------- //	
        console.log(((window.innerHeight)-(this.template.querySelector('.nofy-icon').getBoundingClientRect().bottom)));	
        this.notifiy = ((window.innerHeight)-(this.template.querySelector('.nofy-icon').getBoundingClientRect().bottom) -100);	
        const style = document.createElement('style');	
            style.innerText = `.notification-scroll{	
                max-height: ${this.notifiy}px !important;	
                overflow-y:auto !important;	
            }`	
         this.template.querySelector('.main-cont').appendChild(style);	    
        //-------------- for scroller behaviour according to screen height end---UI------------------------------------- //
        setTimeout(() => {
            this.isNotificationShow = true;
        },100);
    }
    //close notification dailog
    closeDialog(){
        this.isNotificationShow = !this.isNotificationShow;
        setTimeout(() => {
           this.check_n = false;
        },500 );
    }
    //redirect to other component to add notes
    clickAddNote(event){
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('red');
        }   
        //this.eventRecordId = event.target.value;
        let notificationId = event.target.value;
        this.markRead(notificationId);  
        (this.notificationUnreadCount>0)?this.notificationUnreadCount--:0;
        this.isNotificationShow = false;
        this.isAddNoteClick = true;
        this.actRecId = event.target.dataset.recordId;
        this.actRecType = event.target.dataset.type;
        this.isShowNote = true;
    }
    //redirect to other component to add tags
    clickAddTag(event){
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('red');
        }   
        let notificationId = event.target.value;
        this.markRead(notificationId);        
        (this.notificationUnreadCount>0)?this.notificationUnreadCount--:0;
        this.actRecId = event.target.dataset.recordId;
        this.actRecType = event.target.dataset.type;
        this.isReviewTag = true;
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

    /*phase 2 */
    clrChange(event){
        let bgWhite = event.target.closest('.clrChange')
        bgWhite.classList.add('red');
    }

    /*phase 2 */
    showHideNotification(event){
        const element = this.template.querySelector('[data-id="showHideToggle_Id"]');
        element.classList.toggle('slds-hide');
    }

    handleCloseModal(){
        if(this.isShowNote){
            this.isShowNote = false;
        }
        if(this.isReviewTag){
            this.isReviewTag=false;
        }
    }
    noteModalClosed(){
        if(this.isShowNote){
            this.isShowNote = false;
        }
        if(this.isReviewTag){
            this.isReviewTag=false;
        }
    }
    viewNotificationClick(event){
        //this.notificationUnreadCount--;
        (this.notificationUnreadCount>0)?this.notificationUnreadCount--:0;
        let recType = this.notificationRecords[event.target.dataset.index].recObjType;
        this.notificationRecords[event.target.dataset.index].read = true;
        console.log(event.target.dataset.index);
        let bgWhite = event.target.closest('.clrChange');
        if(bgWhite != null) {
            bgWhite.classList.add('red');
        }   
        let notificationId = event.target.dataset.id;
        let recordId = event.target.dataset.recordId;
        this.markRead(notificationId);
        if(recordId != null && recType === 'Account') {
            this.accountRedirect(recordId);
        }
         if(recordId != null && ['Task', 'Event'].includes(recType)) {
            const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');
            modalPopup.openModalSingleComponent(recordId, recType, 'view');
        }
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

    allInteractionRedirect(recordId, recType, mode){
        let params = {};
        params['recId'] = recordId;
        params['recType'] = recType;
        params['mode'] = mode;
        let url = '/lightning/n/Interactions?c__params=' + JSON.stringify(params);
        window.open(url, '_blank');
    }
}