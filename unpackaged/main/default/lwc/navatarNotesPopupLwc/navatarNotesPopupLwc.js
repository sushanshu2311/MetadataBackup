/****************************************************************************************************

** Module Name : New Note from SDG

** Description : Call Notes modal from SDG.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity phase 3.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2024-04-09          Sudhanshu       Call the Notes modal and pass parameters value 

****************************************************************************************************/

import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class NavatarNotesPopupLwc extends NavigationMixin(LightningElement) {
    @api redirectId;
    @api tag1;  
    @api tag2;
    @api tag3;
    @api tag4;
    @api taskSubType;
    @api taggedIdList=[];
    completeActIdList = [];
    fromSDG = true;
    isModalOpen = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if(currentPageReference && currentPageReference.state != undefined && JSON.stringify(currentPageReference.state) !== '{}'){
            let stateParams = currentPageReference.state;
            let params = JSON.parse(stateParams.c__params);
            this.taskSubType = params.taskSubType;
            this.redirectId = params.redirectId;
            this.tag1 = params.tag1;
            this.tag2 = params.tag2;
            this.tag3 = params.tag3;
            this.tag4 = params.tag4;
        }
    }

    /* Processes the info to be displayed on page load */
    connectedCallback(){
        if(this.redirectId != null){
            if(this.tag1){
                this.taggedIdList.push(this.tag1);
            }
            if(this.tag2){
                this.taggedIdList.push(this.tag2);
            }
            if(this.tag3){
                this.taggedIdList.push(this.tag3);
            }
            if(this.tag4){
                this.taggedIdList.push(this.tag4);
            }
            this.handleViewAllClick();
        }
       
    }

    /* Method for call Notes modal and pass the parameters */
    handleViewAllClick(){
        let compDef = {
            componentDef: "navpeII_dev18:navatarNotesModalLwc",
            attributes: {
                objectName: 'Task',
                redirectId: this.redirectId,
                taskType: this.taskSubType,
                isFromSdg: this.fromSDG,
                isModalOpen: this.isModalOpen,
                additionalTaggedIds: this.taggedIdList                
            }
        };
        let encodedCompDef = btoa(JSON.stringify(compDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
}