/****************************************************************************************************
** Module Name : Acuity 2.0 - Quick Deal Creation
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14       Virendra Kumar
****************************************************************************************************/
import { LightningElement, api } from 'lwc';
import cloneChildRecords from'@salesforce/apex/NavatarCreateMenuDealCtrl.cloneChildRecords';
import getCloneConfirmation from'@salesforce/apex/NavatarCreateMenuDealCtrl.getCloneConfirmation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarCreateMenuDealForm4Lwc extends LightningElement {
    interactionsExists = false;
    clipsExists = false;
    hideChildClone = true;
    showImport = false;
    itemCount;
    @api isCheckedInteraction = false;
    @api isCheckedClip = false;
    @api dealId;
    @api accId; 
    @api actionButton = 'Save';
    importLabel = '';

    Child_Clone_Confirmation = '{0} have been added to your Deal.';
    Length_More_Than_13 = 'Limit of 13 Related Associations Reached! List of untagged interactions are: {0}';

    columnsdeal = [
        { label: 'Select All',type:'text', fieldName: 'Selectall', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' }},
    ];

    datadeal = [];
    selectedRows=[];

    connectedCallback() { 
        
        if(!this.isCheckedInteraction && !this.isCheckedClip) {
            this.fetchCloneConfirmation();
        }else {
            if(this.actionButton === 'Import') {
                this.importLabel = this.actionButton;
                this.showImport = true;
            }
            if(this.isCheckedInteraction) {
                this.datadeal.push({id:1, Selectall:'All Interaction'});
                this.selectedRows.push(1);
            }
            if(this.isCheckedClip) {
                this.datadeal.push({id:2, Selectall:'All Clips'});
                this.selectedRows.push(2);
            }
            this.hideChildClone = false;
        }     
    }

    fetchCloneConfirmation() {
        getCloneConfirmation({accId : this.accId})
        .then(result =>{
            this.data = JSON.parse(result);
            //To handle clone confirmation
            if(this.data.isInteractionExist) {
                this.isCheckedInteraction = true;
                this.datadeal.push({id:1, Selectall:'All Interaction'});
                this.selectedRows.push(1);
            }
            if(this.data.isClipExist) {
                this.isCheckedClip = true;
                this.datadeal.push({id:2, Selectall:'All Clips'});
                this.selectedRows.push(2);
            }

            if(this.data.isInteractionExist || this.data.isClipExist) {
               this.hideChildClone = false;
            }else {
                const ev = new CustomEvent("nochild");
                this.dispatchEvent(ev);
            }
        })
        .catch(error =>{
            console.error(JSON.stringify(error)); 
        })
    }

    getSelectedRec() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.isCheckedInteraction = selectedRecords.filter(eachSelect => eachSelect.id == 1).length === 0 ? false: true;
        this.isCheckedClip = selectedRecords.filter(eachSelect => eachSelect.id == 2).length === 0 ? false: true;
        console.log('1 '+this.isCheckedInteraction + ' 2 '+this.isCheckedClip);
    }

    closeModal() {
        const ev = new CustomEvent("closemodalfromchildclone");
        this.dispatchEvent(ev);
    }

    handleCloneSave(){
        cloneChildRecords({dealId : this.dealId, accId : this.accId, isCheckedInteraction : this.isCheckedInteraction, isCheckedClip : this.isCheckedClip})
        .then(result =>{

                let clonedChilds = '';
                if(this.isCheckedInteraction && this.isCheckedClip) {
                    clonedChilds = 'Interactions and Clips';
                }else if(this.isCheckedClip) {
                    clonedChilds = 'Clips';
                }else if(this.isCheckedInteraction) {
                    clonedChilds = 'Interactions';
                }

                if(this.isCheckedInteraction || this.isCheckedClip) {
                    this.showToast('Success', this.Child_Clone_Confirmation.replace('{0}', clonedChilds), 'success', 'dismissable');
                } 

                if(result.length > 0) {
                    let names = '';
                    result.forEach((eachRec)=>{
                        names = names + eachRec + ',';
                    })
                    names = names.replace(/,\s*$/, "");
                    setTimeout(() => {
                        this.showToast('Error!',this.Length_More_Than_13.replace('{0}', names) , 'error', 'sticky');
                        const ev = new CustomEvent("handleclonechild");
                        this.dispatchEvent(ev);
                    }, 5000);
                    
                }else {
                    const ev = new CustomEvent("handleclonechild");
                    this.dispatchEvent(ev);
                }               
                
            }) 
            .catch(error =>{
                console.error('Handle Clone Save ' ,JSON.stringify(error));
                
            })
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

    renderedCallback(){
        console.log(this.isRendered);
        let popupSize = document.createElement('style');
        popupSize.innerText = ` .uiModal--horizontalForm .modal-container{
                                        width: 30rem !important;
                                }
                                .quick-actions-panel{
                                    overflow-y:hidden !important;
                                }
                                .tabcont .slds-button:active{
                                    border:none;
                                }
                                .tabcont .slds-scrollable_y{
                                    overflow-y: auto !important;
                                }
                                .tabcont .slds-button:active{
                                    border:none;
                                }
                                .tabcont .slds-scrollable_y{
                                    overflow-y: auto !important;
                                }
                                .tabcont .slds-th__action{
                                    background: #f3f3f3 !important;
                                    box-shadow: none;
                                }
                                .tabcont .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus),
                                .tabcont .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus),
                                .tabcont .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus),
                                .tabcont .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus),
                                .tabcont .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus),
                                .tabcont .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus),
                                .tabcont .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus),
                                .tabcont .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus) {
                                    box-shadow: none;
                                }
                                .tabcont .slds-table tbody tr.slds-is-selected>td,
                                .tabcont .slds-table tbody tr.slds-is-selected>th{
                                    background-color: #e9e8e83d !important;     
                                }
                                .seletedtag_datatable .slds-grid_vertical-align-center, .tabDataTable .slds-grid_vertical-align-center{
                                    display: flex; align-items: center; justify-content: center;
                                }
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .seletedtag_datatable  .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
                                    background: none !important;
                                }
                        
                                .seletedtag_datatable .slds-table td{
                                    height: 41px !important;
                                }
                                .seletedtag_datatable .slds-has-focus.slds-is-resizable .slds-th__action,
                                .seletedtag_datatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
                                .seletedtag_datatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
                                .seletedtag_datatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
                                .seletedtag_datatable .slds-is-resizable .slds-th__action:focus,
                                .seletedtag_datatable .slds-is-resizable .slds-th__action:focus:hover,
                                .seletedtag_datatable .slds-table th:focus,
                                .seletedtag_datatable .slds-table th.slds-has-focus,
                                .seletedtag_datatable .slds-table [role="gridcell"]:focus,
                                .seletedtag_datatable .slds-table [role="gridcell"].slds-has-focus,
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
                                .seletedtag_datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
                                  box-shadow: none !important;
                                } 
                                .seletedtag_datatable .slds-th__action:focus, .seletedtag_datatable .slds-th__action:hover,
                                .seletedtag_datatable .slds-table tr:hover, .seletedtag_datatable span.slds-th__action{
                                  box-shadow: none !important;
                                } 
                                th.slds-text-body_regular.textColor:focus, .slds-table th:focus, .slds-table th.slds-has-focus, .slds-table [role=gridcell]:focus, .slds-table [role=gridcell].slds-has-focus {
                                    box-shadow: none !important;
                                }
                                `;
            this.template.querySelector('.listdiv').appendChild(popupSize);              
    }

}