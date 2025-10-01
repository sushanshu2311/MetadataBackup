import { LightningElement, track, wire, api } from 'lwc';

import GetThemeCallListData from '@salesforce/apex/NavatarThemeCallListCtrl.getThemeCallListData';
import GetFirmListData from '@salesforce/apex/NavatarThemeCallListCtrl.getFirmListData';
import importContactsToTheme from '@salesforce/apex/NavatarThemeCallListCtrl.importContactsToTheme';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Theme__c.Name";

const fields = [NAME_FIELD];

export default class NavatarThemeCallListLwc extends LightningElement {
    @api recordId;
    @track themeCallList = [];
    @track firmDataList = [];
    @track columnHeaderList = [];
    @track selectedRecord = [];
    @track selectedFirmId = [];
    @track SelectedFirmContacts = [];
    @track firmContactsIds = [];
    @track callListContactIds = [];
    @track columns = [];// columns;

    @track accColumns = [];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    error;
    selectedContactId = [];
    isRedirectToRecord = false;
    isShowModal = false;
    enableSpinner = false;
    callListEmpty = false;
    isCallLogOpen = false;
    @wire(getRecord, {
        recordId: "$recordId",
        fields
      })
    themeRec;

    get name() {
        return getFieldValue(this.account.data, NAME_FIELD);
      }

    connectedCallback() {
        this.fetchDataMethod();
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.tabhead span.slds-truncate {
            display:block !important;
        }
        .tabcont .slds-cell-fixed,
        .tabcont .slds-cell-fixed:active,
        .tabcont .slds-cell-fixed:hover,
        .tabcont .slds-cell-fixed:focus{
            box-shadow: none !important;
        }
        .slds-button:active{
            border:none;
        }
        .tabcont .slds-scrollable_y{
            overflow-y: auto !important;
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
        .calllistdatatable .slds-grid_vertical-align-center, .tabDataTable .slds-grid_vertical-align-center{
            display: flex; align-items: center; justify-content: center;
        }
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .calllistdatatable  .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }
        .calllistdatatable .slds-table td:last-child{
            height: 41px !important;
        }
        .calllistdatatable .slds-has-focus.slds-is-resizable .slds-th__action,
        .calllistdatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .calllistdatatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .calllistdatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .calllistdatatable .slds-is-resizable .slds-th__action:focus,
        .calllistdatatable .slds-is-resizable .slds-th__action:focus:hover,
        .calllistdatatable .slds-table th:focus,
        .calllistdatatable .slds-table th.slds-has-focus,
        .calllistdatatable .slds-table [role="gridcell"]:focus,
        .calllistdatatable .slds-table [role="gridcell"].slds-has-focus,
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .calllistdatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
          box-shadow: none !important;
        } 
        .slds-th__action:focus, .slds-th__action:hover,
        .slds-table tr:hover{
          box-shadow: none !important;
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
        .theme_css .slds-scrollable_y{
            overflow-y: auto !important;
        }
        .theme_css .slds-th__action{
            background: #f3f3f3 !important;
            box-shadow: none;
        }
         .theme_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus),
         .theme_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus),
         .theme_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus),
         .theme_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus),
         .theme_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus),
         .theme_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus),
         .theme_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus),
         .theme_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus) {
            box-shadow: none !important;
         }
         .theme_css .slds-table tbody tr.slds-is-selected>td,
         .theme_css .slds-table tbody tr.slds-is-selected>th{
            background-color: #e9e8e83d !important;
         }
        @media only screen and (min-device-width: 1480px) and (max-device-width: 1550px) {
            .slds-table_header-fixed_container.slds-scrollable_x{
                overflow-x: hidden;
            }
        }`;
        this.template.querySelector('.main-Container-calllist')?.appendChild(style);
    }

    fetchDataMethod() {
        this.enableSpinner = true;
        this.callListContactIds = [];
        this.themeCallList = [];
        GetThemeCallListData({ recordId: this.recordId })
            .then(result => {
                console.log('---result>>  ' + JSON.stringify(result));
                this.columns = [];
                if (result.fieldHeader1 != null) {
                     this.columns.push({ label: result.fieldHeader1, fieldName: 'field1Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank' }, variant: 'base' });
                }
                //this.columns = [{ label: result.fieldHeader1, fieldName: 'field1Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank' }, variant: 'base' }];
                if (result.fieldHeader2 != null) {
                    if (result.isFieldTypeURL2) {
                        this.columns.push({ label: result.fieldHeader2, fieldName: 'field2Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field2' }, label: { fieldName: 'field2' }, target: '_blank' }, variant: 'base' });
                    } else {
                        this.columns.push({ label: result.fieldHeader2, fieldName: 'field2', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { label: { fieldName: result.fieldHeader2 }, variant: 'base', tooltip: { fieldName: result.fieldHeader2 } } });
                    }
                }
                if (result.fieldHeader3 != null) {
                    if (result.isFieldTypeURL3) {
                        this.columns.push({ label: result.fieldHeader3, fieldName: 'field3Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field3' }, label: { fieldName: 'field3' }, target: '_blank' }, variant: 'base' });
                    } else {
                        this.columns.push({ label: result.fieldHeader3, fieldName: 'field3', hideDefaultActions: true });
                    }
                }

                if (result.fieldHeader4 != null) {
                    if (result.isFieldTypeURL4) {
                        this.columns.push({ label: result.fieldHeader4, fieldName: 'field4Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field4' }, label: { fieldName: 'field4' }, target: '_blank' }, variant: 'base' });
                    } else {
                        this.columns.push({ label: result.fieldHeader4, fieldName: 'field4', hideDefaultActions: true });
                    }
                }

                if (result.fieldHeader5 != null) {
                    if (result.isFieldTypeURL5) {
                        this.columns.push({ label: result.fieldHeader5, fieldName: 'field5Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field5' }, label: { fieldName: 'field5' }, target: '_blank' }, variant: 'base' });
                    } else {
                        this.columns.push({ label: result.fieldHeader5, fieldName: 'field5', hideDefaultActions: true });
                    }
                }

                if (result.fieldHeader6 != null) {
                    this.columns.push({ label: result.fieldHeader6, type: 'button', hideDefaultActions: true, fixedWidth: 100, cellAttributes: { alignment: 'center' }, typeAttributes: { iconName: { fieldName: 'field6Icon' }, variant: 'base', name: 'lognote', title: 'Log Note' } });
                }

                console.log('this.columns++' + JSON.stringify(this.columns));
                //this.dealTitle = result.title;
                if (result.themeDataList) {
                    this.themeCallList = [];
                    var contactIds= [];
                    for (let recInfo of result.themeDataList) {
                        contactIds.push(recInfo.fieldInfo1.nameRef.replace('/',''));
                        this.themeCallList.push({
                            field1: recInfo.fieldInfo1.name, field1Ref: (recInfo.fieldInfo1.name != null) ? recInfo.fieldInfo1.nameRef : '',
                            field2: recInfo.fieldInfo2.name, field2Ref: (recInfo.fieldInfo2.name != null) ? recInfo.fieldInfo2.nameRef : '',
                            field3: recInfo.fieldInfo3.name, field3Ref: (recInfo.fieldInfo3.name != null) ? recInfo.fieldInfo3.nameRef : '',
                            field4: recInfo.fieldInfo4.name, field4Ref: (recInfo.fieldInfo4.name != null) ? recInfo.fieldInfo4.nameRef : '',
                            field5: recInfo.fieldInfo5.name, field5Ref: (recInfo.fieldInfo5.name != null) ? recInfo.fieldInfo5.nameRef : '',
                            field6: recInfo.fieldInfo6.name, field6Ref: (recInfo.fieldInfo6.name != null) ? recInfo.fieldInfo6.nameRef : '', field6Icon: recInfo.fieldInfo6.iconName

                        });
                    }

                    this.callListContactIds = contactIds;
                    console.log('this.themeCallList++' + JSON.stringify(this.themeCallList));
                    if(this.themeCallList.length == 0){
                        this.callListEmpty = true;
                    }else{
                        this.callListEmpty = false;
                    }
                }
                this.enableSpinner = false;
            })
            .catch(error => {
                //this.error =error;
                this.themeCallList = undefined;
                this.enableSpinner = false;
                this.showToast(this, 'Error!', error.body.message, 'error');
            })
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.themeCallList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.themeCallList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    showImportContactsModal() {
        this.enableSpinner = true;
        this.isShowModal = true;
        GetFirmListData({ recordId: this.recordId })
            .then((result) => {
                //let firmData = JSON.parse(JSON.stringify(data));
                // this.firmDataList = data;
                /*firmData.forEach((rec) => {
                    rec.RecordName = rec.RecordType.Name;
                })*/
                //this.firmDataList = firmData;
                console.log('-------1099999-----' + JSON.stringify(result));
                this.accColumns = [];

                //this.accColumns = [{ label: result.fieldHeader1, fieldName: 'field1Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank' }, variant: 'base' }];
                if (result.fieldHeader1 != null) {
                    this.accColumns.push({ label: result.fieldHeader1, fieldName: 'field1Ref', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank' }, variant: 'base' });
                }

                this.accColumns.push({ label: result.fieldHeader2, fieldName: 'field2', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { label: { fieldName: result.fieldHeader2 }, variant: 'base', tooltip: { fieldName: result.fieldHeader2 } } });

                console.log('this.accColumns++' + JSON.stringify(this.accColumns));
                //this.dealTitle = result.title;
                if (result.themeDataList) {
                    console.log('result.themeDataList++' + JSON.stringify(result.themeDataList));
                    this.firmDataList = [];
                    for (let recInfo of result.themeDataList) {
                        console.log('recInfo++' + JSON.stringify(recInfo));
                        console.log('1 recInfo++' + recInfo.fieldInfo1.name);
                        console.log('2 recInfo++' + recInfo.fieldInfo2.name);
                        this.firmDataList.push({
                            field1: recInfo.fieldInfo1.name, field1Ref: (recInfo.fieldInfo1.name != null) ? recInfo.fieldInfo1.nameRef : '', recId : recInfo.fieldInfo1.nameRef.replace('/',''),
                            field2: recInfo.fieldInfo2.name, field2Ref: (recInfo.fieldInfo2.name != null) ? recInfo.fieldInfo2.nameRef : ''
                        });
                    }
                    console.log('this.firmDataList++' + JSON.stringify(this.firmDataList));
                }
                console.log('2 this.firmDataList++' + JSON.stringify(this.firmDataList));
                this.enableSpinner = false;
                //this.error = undefined;
            })
            .catch((error) => {
                this.firmDataList = undefined;
                this.enableSpinner = false;
                //this.error = error;
                this.showToast(this, 'Error!', error.body.message, 'error');
            })
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    handleRowSelection(event) {
        /* this.selectedRecord = event.detail.selectedRows; 
         console.log('----CHECKEDDDD---'+JSON.stringify(event.detail.checked)); 
        this.selectedRecord.forEach((rec) =>{
         if(!this.selectedFirmId.includes(rec.Id)){
             this.selectedFirmId.push(rec.Id);
         }
         })*/
        this.selectedFirmId = [];
        let currentRows = event.detail.selectedRows;
        if (this.selectedRecord.length > 0) {
            let selectedIds = currentRows.map(row => row.id);
            let unselectedRows = this.selectedRecord.filter(row => !selectedIds.includes(row.id));
            console.log(unselectedRows);
        }
        this.selectedRecord = currentRows;
        console.log('Selected FIRMSSS  IDSSSS', JSON.stringify(this.selectedRecord));
        this.selectedRecord.forEach((rec) => {
            this.selectedFirmId.push(rec.recId);
        })
        console.log('-----1155444----' + JSON.stringify(this.selectedFirmId));
    }

    handleThemeRowSelection(event) {
        console.log('Event Name++' + event.detail.action.name);
        if (event.detail.action.name === 'lognote') {           
            this.isCallLogOpen = true;
            this.selectedContactId.push(event.detail.row.field1Ref.replace("/",""));
        }
    }

    noteModalClosed(){
        this.isCallLogOpen = false;
    }

    importContacts(){
        this.enableSpinner = true;
        console.log('selectedFirm++'+this.selectedFirmId);
        if(this.selectedFirmId.length > 0){
            importContactsToTheme({ recordId: this.recordId, selectedFirm: this.selectedFirmId })
                .then((result) => {
                    if(result){//coming boolean value from apex class.
                        this.fetchDataMethod();
                        this.showToast(this, 'Success!', 'The Contacts has been successfully imported.', 'success');
                        this.isShowModal = false;
                        this.enableSpinner = false;
                        this.selectedFirmId = [];
                    }else{
                        this.isShowModal = false;
                        this.enableSpinner = false;
                        this.selectedFirmId = [];
                    }
                })
                .catch((error) => {
                    
                    this.enableSpinner = false;
                    this.showToast(this, 'Error!', error.body.message, 'error');
                })
        }else{
            this.showToast(this, 'Error!', 'Select atleast a record.', 'error');
            this.enableSpinner = false;
        }
    }

    showToast(cmp, title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        cmp.dispatchEvent(event);
    }
}