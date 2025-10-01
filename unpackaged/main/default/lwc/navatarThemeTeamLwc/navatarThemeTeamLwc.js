import { LightningElement, api, wire,track } from 'lwc';
import getThemeTeams from'@salesforce/apex/NavatarThemeTeamCtrl.getThemeTeams';
import processConInfo from'@salesforce/apex/NavatarThemeTeamCtrl.processConInfo';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import deleteSelectedThemeTeam from'@salesforce/apex/NavatarThemeTeamCtrl.deleteSelectedThemeTeam';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import THEME_TEAM from '@salesforce/schema/Theme_Team__c';
import ROLE from "@salesforce/schema/Theme_Team__c.Role__c";

import { publish, MessageContext } from "lightning/messageService";
import ICON_CHANNEL from "@salesforce/messageChannel/navatarLwcChannel__c"; 

export default class navatarThemeTeamLwc extends LightningElement {
    //Store record Id
    @api recordId;
    //variable to show and hide details
    enableSpinner = false;
    isaddIconBtn = true;
    isBanIconBtn = false; 
    cancelSave = false;
    chckBoxAdvisor = true;
    showError = false;
    editFalse = false;

    noData = ''; 
   @track conCols = [];
    conData = [];
    selectedTeamMem = [];
    fldsItemValues = []; 
    roleOptions = [];
    
    //Handle Minus Click
    handleButtonBottom() { 
        this.isaddIconBtn = false;
        this.cancelSave = true;
        this.chckBoxAdvisor = true;
        this.editFalse = true;
        this.fldsItemValues = [];
        this.handleOnLoadInfo();
    }
    //Handle Remove Click 
    handleRemove() {
        let selectedTeamMemIds = [];
        this.selectedTeamMem.map(item=>{
            selectedTeamMemIds.push(item.Id);
        });
        if(selectedTeamMemIds.length > 0) {
            deleteSelectedThemeTeam({selectedTeamMemIds : selectedTeamMemIds})
                .then(result => {
                    if(selectedTeamMemIds.length === 1) {
                        this.showToast('Success!', 'User was removed.', 'success', 'dismissable');
                    }else {
                        this.showToast('Success!', 'Users were removed.', 'success', 'dismissable');
                    }
                   
                    this.handleCancel();
                    return this.refresh();
                }).catch(error => {
                    this.showToast('Error!', error.body.pageErrors[0].message, 'error', 'sticky');
            });
        }else {
            this.showError = true;
            this.noData = 'Select atleast a record.';
        }
        
    }
    //Handle freshd data load
    async refresh() {
        await this.handleOnLoadInfo();
    }

    handleRowSelection(event) {
        this.showError = false;
        this.selectedTeamMem = JSON.parse(JSON.stringify(event.detail.selectedRows));
    }

    handleCancelFromTable(event) {
        console.log(event);
        this.fldsItemValues = [];

    }

    //handle cancel button
    handleCancel() {
        this.showError = false;
        this.cancelSave = false;
        this.chckBoxAdvisor = false;
        this.editFalse = false;
        this.isaddIconBtn = true;
        this.handleOnLoadInfo();
        
    }
    handleNewTeamMember() {
        this.showError = false; 
        this.publishEvent('navpeII_dev18__Theme__c.navpeII_dev18__New_Team_Member');
    }

    handleSave(event) {
        this.showError = false;
        const inputsItems = this.fldsItemValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        const promises = inputsItems.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'User was saved.', 'success', 'dismissible'); 
            this.fldsItemValues = [];
            return this.refresh();
            
        }).catch(error => {
            this.enableSpinner = false;
            console.error(JSON.stringify(error));
            this.showToast('Error!', error.body.message, 'error', 'sticky'); 
        }).finally(() => {
            this.fldsItemValues = [];
            this.enableSpinner = false;
        });
    }

     //listener handler to get the context and data
     picklistChanged(event) {
        this.showError = false;
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let fieldApiName = dataRecieved.fieldApiName;
        let updatedItem = {};
        updatedItem['Id'] = dataRecieved.context;
        updatedItem[fieldApiName] = dataRecieved.value;
        this.updateDraftValues(updatedItem);

    }

    updateDraftValues(updatedItem) {
		let draftValueChanged = false;
		let copyDraftValues = [...this.fldsItemValues];
		//store changed value to do operations
		//on save. This will enable inline editing &
		//show standard cancel & save button
		copyDraftValues.forEach(item => {
			if (item.Id === updatedItem.Id) {
				for (let field in updatedItem) {
					item[field] = updatedItem[field];
				}
				draftValueChanged = true;
			}

		}); 

		if (draftValueChanged) {
			this.fldsItemValues = [...copyDraftValues];
		} else {
			this.fldsItemValues = [...copyDraftValues, updatedItem];

		}
	}

    @wire(MessageContext)
    messageContext;
    publishEvent(actionName) {
        const messaage = {
            quickActionName: actionName
        };
        publish(this.messageContext, ICON_CHANNEL, messaage);

    } 

    @wire(getObjectInfo, { objectApiName: THEME_TEAM}) 
    TeamRecord;

    @wire(getPicklistValues, {recordTypeId: '$TeamRecord.data.defaultRecordTypeId', fieldApiName: ROLE})
    teamRolePicklist({ data, error }) {
        if(data) {
            this.roleOptions = data.values;
            this.handleOnLoadInfo();
        }
        else if (error) {
            this.showToast('Error!', error.body.message, 'error', 'dismissable');
            this.enableSpinner = false;
        }
    }
    
    handleOnLoadInfo(){
        this.enableSpinner = true;
        this.showError = false;
        getThemeTeams({recordId : this.recordId})
        .then((result) => {
            
            this.themeTeamMap = result.themeTeamMap;
            let metadataField1, metadataField2, metadataField3;
            metadataField1 = 'Acuity_ThemeTeam_Field1';
            metadataField2 = 'Acuity_ThemeTeam_Field2';
            metadataField3 = 'Acuity_ThemeTeam_Field3';
            //get the data from backend for Theme Team
            processConInfo({themeTeamMap:this.themeTeamMap, metadataField1 : metadataField1, metadataField2 : metadataField2, metadataField3 : metadataField3})
            .then((result) => {
                this.enableSpinner = false;
            
                this.conCols = [];
                if(result){
                    this.conData = [];
                    let ref1 = '';
                    let ref2 = '';
                    let ref3 = '';
                    ref1 = result.conFieldHeader1 === 'Full Name' ? 'Name': result.conFieldHeader1;
                    ref2 = result.conFieldHeader2 === 'Full Name' ? 'Name': result.conFieldHeader2;
                    ref3 = result.conFieldHeader3 === 'Full Name' ? 'Name': result.conFieldHeader3;
                        
                    if(result.conFieldHeader1){

                        this.conCols.splice(0, 0, { label: ref1, hideDefaultActions:true, fieldName: 'roleRef1', type: 'text'})
                    }
                    if(result.conFieldHeader2){
                        this.conCols.splice(1, 0, { label: ref2, hideDefaultActions:true, fieldName: 'roleRef2', type: 'text'})
                    }
                    
                    if(result.conFieldHeader3  && this.editFalse === false){
                        //Inital onload picklist will be editable
                        this.conCols.splice(2, 0, { label: result.conFieldHeader3, fieldName: 'roleRef3', type: 'picklist',wrapText: true, hideDefaultActions:true, typeAttributes: {
                            context: {fieldName: 'Id'},
                            editable: true,
                            fieldApiName: 'navpeII_dev18__Role__c',
                            options: {fieldName: 'picklistOption'} ,
                            placeholder: 'Choose Role',
                            value:   {fieldName: 'roleRef3'}
                        }})
                        this.chckBoxAdvisor = true;//Hide checkbox
                    }else if(result.conFieldHeader3 && this.editFalse === true){
                        //load on click of minus icon so that column should not be editable
                        this.conCols.splice(2, 0, { label: result.conFieldHeader3, fieldName: 'roleRef3', type: 'picklist', editable:false,wrapText: true, hideDefaultActions:true, typeAttributes: {
                            context: {fieldName: 'Id'},
                            editable: false,
                            fieldApiName: 'navpeII_dev18__Role__c',
                            options: {fieldName: 'picklistOption'} ,
                            placeholder: 'Choose Role', 
                        value:   {fieldName: 'roleRef3'}
                    }})
                    this.showError = false;
                    this.chckBoxAdvisor = false;//show checkbox
                }
                

                    if(result.conInfoWrapper.length > 0){
                        for(let recInfo of result.conInfoWrapper){
                            if(recInfo.fieldInfo1 !== null && recInfo.fieldInfo1 !== undefined && recInfo.fieldInfo1 !== '') {
                                this.isBanIconBtn = true;
                                this.conData.push({Id: recInfo.Id, name: recInfo.name, roleRef1: recInfo.fieldInfo1, 
                                    roleRef2: recInfo.fieldInfo2, roleRef3: recInfo.fieldInfo3});
                            }
                            
                        }
                        if(this.conData.length > 0) {
                            this.conData = this.conData.map(element=>{
                                return{
                                    ...element, 'picklistOption': this.roleOptions/*, 'Id':element.id*/
                                }
                            });
                        }else {
                            this.showError = true;
                            this.noDataToDisplay = 'No items to display.';  // Bug 00047834 fixed by Sudhanshu
                            this.isBanIconBtn = false;
                            this.enableSpinner = false;
                        }                      
                        
                        
                    } else if(result==null || result === undefined || result.length === 0 || result.conInfoWrapper.length === 0){
                        //this.noDataToDisplay = true;
                        this.noDataToDisplay = 'No items to display.';      // Bug 00047834 fixed by Sudhanshu
                        this.isBanIconBtn = false;
                        this.enableSpinner = false;
                        this.showError = true;
                    }
                }
        
            })
            .catch((error) => {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
                this.enableSpinner = false;
            });
        })
        .catch((error) => {
            this.showToast('Error!', error.body.message, 'error', 'sticky');
            this.enableSpinner = false;
        });
    }

    //Handle Generic Toast message
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = ` .themteamdatatable .slds-table td:last-child{
            height: 100px !important;
        } 
        .addMinus .slds-icon {

            fill: #0176d3 !important;

        }
        .text-black button.slds-button{
            color:#000 !important;  
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
            max-width: 100% !important;
            display: block !important;
            overflow: hidden !important; 
            cursor: text;   
        }
        .slds-th__action{
            background: #f3f3f3 !important;
            box-shadow: none;
        }
        .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus), .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus), .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus), .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus) {
            box-shadow: none;
        }
        .slds-table tbody tr.slds-is-selected>td, .slds-table tbody tr.slds-is-selected>th{
            background-color: #e9e8e83d !important;     
        }
        .themteamdatatable .slds-grid_vertical-align-center, .tabDataTable .slds-grid_vertical-align-center{
            display: flex; align-items: center; justify-content: center;
        }
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .themteamdatatable  .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }

        .themteamdatatable .slds-table td:last-child{
            height: 41px !important;
        }
        .themteamdatatable .slds-has-focus.slds-is-resizable .slds-th__action,
        .themteamdatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .themteamdatatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .themteamdatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .themteamdatatable .slds-is-resizable .slds-th__action:focus,
        .themteamdatatable .slds-is-resizable .slds-th__action:focus:hover,
        .themteamdatatable .slds-table th:focus,
        .themteamdatatable .slds-table th.slds-has-focus,
        .themteamdatatable .slds-table [role="gridcell"]:focus,
        .themteamdatatable .slds-table [role="gridcell"].slds-has-focus,
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .themteamdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
          box-shadow: none !important;
        } 
        .slds-th__action:focus, .slds-th__action:hover,
        .slds-table tr:hover,.slds-table th:focus, .slds-table th.slds-has-focus, .slds-table [role=gridcell]:focus, .slds-table [role=gridcell].slds-has-focus{
            -webkit-box-shadow: #dddbda 0 -1px 0 inset, #dddbda 0 1px 0 inset !important;
            box-shadow: #dddbda0d 0 -1px 0 inset, #dddbda08 0 1px 0 inset !important;
        }
         .themteamdatatable .button.slds-button:active, .themteamdatatable .button.slds-button{
            border: none;
        }
        .slds-has-focus,.slds-th__action{
            -webkit-box-shadow: #dddbda 0 -1px 0 inset, #dddbda 0 1px 0 inset !important;
            box-shadow: #dddbda0d 0 -1px 0 inset, #dddbda08 0 1px 0 inset !important;
        }
        .slds-table .slds-cell-edit.slds-is-edited, .slds-table .slds-cell-edit.slds-is-edited:hover{
            background: none;
        }`;
            
        this.template.querySelector('.main-Container-themeteam')?.appendChild(style);

        let tableBckNone = document.createElement('style');
        tableBckNone.innerText = `.themteamdatatable span.slds-th__action{
            -webkit-box-shadow: #dddbda 0 -1px 0 inset, #dddbda 0 1px 0 inset !important;
            box-shadow: #dddbda0d 0 -1px 0 inset, #dddbda08 0 1px 0 inset !important;
        }`;
    
        this.template.querySelector('lightning-datatable')?.appendChild(tableBckNone);  
    }
}