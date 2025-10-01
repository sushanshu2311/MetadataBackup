/****************************************************************************************************

** Module Name : Connections 2.0

** Description : get the metadata records of report.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/

import { api, LightningElement, track } from 'lwc';
import getReportData from '@salesforce/apex/NavatarReportCtrl.getReportData';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class navatarExportReportLwc extends LightningElement {
    //@api recordId;

    @track data = [];
    @track isLoading = false;
    @track isReportFound = true;

    _recordId;

    // set recordid
    @api set recordId(value) {
        this._recordId = value;
        this.getReportDataHandler();
        // do your thing right here with this.recordId / value
    }

    // get record id
    get recordId() {
        return this._recordId;
    }


    // get report data
    getReportDataHandler(){
        console.log('getReportDataHandler 2=='+this.recordId);
        getReportData({
            recordId: this.recordId,
        })
        .then(data => {
            console.log('report data==',data);
            this.data = JSON.parse(data);
            this.isReportFound = this.data.length > 0 ? true : false;
        })
        .catch(error => {
            this.displayError(error);
        });
    }

    // UI - Styling---------------------------	
    renderedCallback(){	
        console.log(this.isRendered);	
        let popupSize = document.createElement('style');	
        popupSize.innerText = `.uiModal--medium .modal-container {	
            width: 40%;!important}	
            .quick-actions-panel{overflow-y:hidden !important}	
            @media only screen and (max-width : 1025px){	
                .listdiv .slds-modal__content{	
                    max-height:300px !important;	
                }`;	
        let card = this.template.querySelector('listdiv');		
        if(card){		
        card.appendChild(popupSize);
        } 	
    }

    // colse popup modal
    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}