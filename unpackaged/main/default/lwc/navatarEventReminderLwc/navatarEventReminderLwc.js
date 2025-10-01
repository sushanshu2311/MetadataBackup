import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavatarEventReminderLwc extends NavigationMixin(LightningElement) {
    @api eventData;

    yesModal() {
        let params = {};
        params['recId'] = this.eventData.evtId;
        params['recType'] = 'Event';
        params['mode'] = 'addNote';
        //Bug Id - 00045252 View_Interaction Fixed by Deepak Tab name change
        let url = '/lightning/n/navpeII_dev18__View_Interaction?c__params=' + JSON.stringify(params);
        window.open(url, '_blank');
        this.closeModal();//Added by Shivam as part of 00038720
    }
    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}