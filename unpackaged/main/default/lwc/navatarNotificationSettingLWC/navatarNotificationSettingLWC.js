/****************************************************************************************************

** Module Name : Notification Setting

** Description : 

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : 

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        
** 2.0        2024-03-07          Sudhanshu       Added Enable Review Tag Notification 

****************************************************************************************************/

import { LightningElement, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchNotificationSettings from '@salesforce/apex/NavatarNotificationSettingCtrl.fetchNotificationSettings';
import deleteNotifications from '@salesforce/apex/NavatarNotificationSettingCtrl.deleteNotifications';
import NN_INFO_FIELD from '@salesforce/schema/Navatar_Setup__c.NN_Information__c';
import NN_ACTION_FIELD from '@salesforce/schema/Navatar_Setup__c.NN_Action__c';
import ID_FIELD from '@salesforce/schema/Navatar_Setup__c.Id';
import NN_ReviewTag_FIELD from '@salesforce/schema/Navatar_Setup__c.NN_Action_Review_Tag__c';


export default class NavatarNotificationSettingLWC extends LightningElement {
    @track setupRec = {};
    @track isLoading = false;
    @track isReviewTag =true;
    
    connectedCallback(){
        this.isLoading = true;
        fetchNotificationSettings()
        .then((result) => {
            this.setupRec = result;
            if(this.setupRec.actionNotification == false){
                this.isReviewTag = true;
                this.setupRec.reviewTag = false;        // bug 00044607 Fixed by sudhanshu on 10-04-2024 
            }
            else{
                this.isReviewTag = false;
            }
        })
        .catch((error) => {
            this.showNotification('Error', error.body.message, 'error');
        })
        .finally((f) => {
            this.isLoading = false;
        });
    }
   handleActionChange(event) {
        if(event!=undefined && event.target!=undefined){
            event.preventDefault();
            this.setupRec[event.target.name] = event.target.checked;
            const fields = {};
            var result;
            fields[ID_FIELD.fieldApiName] = this.setupRec.recordId;
            fields[NN_ACTION_FIELD.fieldApiName] = this.setupRec.actionNotification;
            const recordInput = {fields};
            if(!event.target.checked){
                result=confirm("It will delete all Action type of notification");
                if(result){
                    updateRecord(recordInput)
                    .then(() => {
                        this.showNotification('Success', 'Notification Setting was saved.', 'success');
                        deleteNotifications({type : 'actionNotification'})
                            .then((result) => {
                                this.setupRec = result;
                                this.connectedCallback(); 
                            })
                            .catch((error) => {

                                this.showNotification('Error', error.body.message, 'error');
                            });       
                    })
                    .catch(error => {
                        this.showNotification('Error creating record', error.body.message, 'error');
                    }); 
                }else{
                    this.connectedCallback(); 
                }         
                            
            }else if(event.target.checked){
                updateRecord(recordInput)
                .then(() => {
                    this.showNotification('Success', 'Notification Setting was saved.', 'success');
                    this.connectedCallback();
                })
                .catch(error => {
                    this.showNotification('Error creating record', error.body.message, 'error');
                }); 
                
            }          

        }
    }

    handleInfoChange(event) {
        if(event!=undefined && event.target!=undefined){
            event.preventDefault();
            this.setupRec[event.target.name] = event.target.checked;
            const fields = {};
            var result;
            fields[ID_FIELD.fieldApiName] = this.setupRec.recordId;
            fields[NN_INFO_FIELD.fieldApiName] = this.setupRec.infoNotification;
            const recordInput = {fields};
            if(!event.target.checked){
                result=confirm("It will delete all Info type of notification");
                console.log('***result***'+result);
                if(result){
                    updateRecord(recordInput)
                    .then(() => {
                        this.showNotification('Success', 'Notification Setting was saved.', 'success');
                        deleteNotifications({type : 'infoNotification'})
                            .then((result) => {
                                this.setupRec = result;
                                this.connectedCallback();
                            })
                            .catch((error) => {
                                this.showNotification('Error', error.body.message, 'error');
                            });                                            
                    })
                    .catch(error => {
                        this.showNotification('Error creating record', error.body.message, 'error');
                    });
                }else{ 
                    this.connectedCallback();
                }
            }else if(event.target.checked){
                updateRecord(recordInput)
                .then(() => {
                    this.showNotification('Success', 'Notification Setting was saved.', 'success');
                    this.connectedCallback();
                        
                })
                .catch(error => {
                    this.showNotification('Error creating record', error.body.message, 'error');
                }); 
                
            }          
               
        }
    }

    handleReviewTag(event){
        if(event!=undefined && event.target!=undefined){
            event.preventDefault();
            this.setupRec[event.target.name] = event.target.checked;
            const fields = {};
            var result;
            fields[ID_FIELD.fieldApiName] = this.setupRec.recordId;
            fields[NN_ReviewTag_FIELD.fieldApiName] = this.setupRec.reviewTag;
            const recordInput = {fields};
            if(!event.target.checked){
                result=confirm("It will delete all review tag notifications");
                console.log('***result***'+result);
                if(result){
                    updateRecord(recordInput)
                    .then(() => {
                        this.showNotification('Success', 'Notification Setting was saved.', 'success');
                        deleteNotifications({type : 'reviewTag'})
                            .then((result) => {
                                this.setupRec = result;
                                this.connectedCallback();
                            })
                            .catch((error) => {
                                this.showNotification('Error', error.body.message, 'error');
                            });                                            
                    })
                    .catch(error => {
                        this.showNotification('Error creating record', error.body.message, 'error');
                    });
                }else{ 
                    this.connectedCallback();
                }
            }else if(event.target.checked){
                updateRecord(recordInput)
                .then(() => {
                    this.showNotification('Success', 'Notification Setting was saved.', 'success');
                    this.connectedCallback();
                        
                })
                .catch(error => {
                    this.showNotification('Error creating record', error.body.message, 'error');
                }); 
                
            }          
               
        }
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
}