import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';


export default class NavatarEventSubscribeLwc extends LightningElement {

    subscription = {};
    @api channelName = '/event/navpeII_dev18__Event_Reminder__e';
    evtDataList = [];
    loggedInUserId = currentUserId;

    connectedCallback() {
        this.registerErrorListener();
        this.handleSubscribe();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function(response) {
            var evtData = {};
            evtData = JSON.parse(response.data.payload.navpeII_dev18__Event_Reminder_Data__c);
            console.log('New message received 1: ', JSON.stringify(evtData));
            const eventData = evtData;
            if(thisReference.checkIfLoggedInUserIsValidAttendee(evtData)) {
                const valueChangeEvent = new CustomEvent("evtdatareceived", {
                    detail: { eventData }
                    });
                    // Fire the custom event
                thisReference.dispatchEvent(valueChangeEvent);
            }
            
           // thisReference.toast('Event started '+evtData.evtId)

            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    /* In case you want to unsubscribe use this
    // Handles unsubscribe button click
    handleUnsubscribe() {

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
    */
   
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    checkIfLoggedInUserIsValidAttendee(receivedEventData) {
        var isValidAttendee = false;
        if(receivedEventData.ownerId == this.loggedInUserId) {
            return true;
        }
        if(receivedEventData.userData.length == 0 || receivedEventData.userData == undefined) {
            isValidAttendee = false;
        }
        else {
            for(var d in receivedEventData.userData) {
                if(receivedEventData.userData[d].userId == this.loggedInUserId) {
                    isValidAttendee = true;
                    break;
                }
            }
        }
        return isValidAttendee;
    }

    

}