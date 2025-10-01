/****************************************************************************************************

** Module Name : Import Note

** Description : 

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity 3.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2024-02-02          Sudhanshu       Handle Import note

****************************************************************************************************/

import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class NavatarImportNotesModalLwc extends LightningElement {
    
    @api siteURL;
    @api recordId;
    @api importId;
    @track isLoading = false;
    connectedCallback(){
        this.isLoading = true;
        // setTimeout(() => {
        //     this.isLoading = false;
        // }, 6000);
        this.handleImportID();
        this.registerErrorListener();  // added by sudhanshu
        this.handleSubscribe();  // added by sudhanshu
    }

    /* For fetch the import ID */
    handleImportID() {
        this.siteURL = '/apex/navpeII_dev18__NavatarImportNotesModalRedirectVFtoAsp?importID=' + this.importId;
    }

    closeImportModal(){
        this.dispatchEvent(new CustomEvent('closeimportmodal', {
            detail: {
                importID: this.importId
            }
        }));
    }
    @track status;
    @track message;
    @track recordId;
    subscription = {};
    @api channelName = '/event/navpeII_dev18__Navatar_ImportNotes_Event__e';

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
    
        const messageCallback = function (response) {
            console.log('New message received 1: ', JSON.stringify(response));
            console.log('New message received 2: ', response);
            var obj = JSON.parse(JSON.stringify(response));
            console.log(obj.data.payload);
            console.log(obj.data.payload.navpeII_dev18__ImportNotes_Message__c);
            console.log(self.channelName);
            let objData = obj.data.payload;
            self.message = objData.navpeII_dev18__ImportNotes_Message__c;
            self.navpeII_dev18__ImportNotes_ID__c = objData.navpeII_dev18__ImportNotes_ID__c;
            if(objData.navpeII_dev18__ImportNotes_ID__c == self.importId){

                if(self.message == 'Spinner')
                {
                    self.isLoading = false;
                    // self.ShowToast('File imported successfully.', self.message, 'success', 'dismissable');
                }
            }
        };
 
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
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
            title: 'File imported successfully.',
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    
}