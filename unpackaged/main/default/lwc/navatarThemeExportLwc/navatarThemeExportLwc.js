import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NavatarThemeExportLwc extends LightningElement {
    @api popupDataToDisplay;
    @api exportMapWholeData;
    @api globalFieldTypeCasting;
    selectedExportData = [];
    selectedRows=[];
    @api isModalOpen;
    componentReference = 'Export Theme Popup';
    fileName = 'ThemeExport.xlsx';
   
    columns = [
        { label: 'All Categories',type:'text', fieldName: 'allCategoriers', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' } },
    ];

    connectedCallback(){
        console.log('::::::::::::::: '+this.isModalOpen);
        console.log('___________________________________________________');
        for(var i =0;i<this.popupDataToDisplay.length;i++){
            this.selectedRows.push(i+1);
        }
       
    }
    // @api
    // openModal() {
    //     this.isModalOpen = true;
    // }
    closeModal(){
        console.log('____________________________________________________');
        // this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('closepopup'));
        console.log('+ ::::: '+this.isModalOpen);
    }
    //This method will call the export functionality button. If no records are found then it will show toast message 
    exportRecordsModal() {
        console.log('___________________________exportRecordsModal______________________________')
        //Check for user has selected records or not. If not than system will show the toast error message
        //Else it will call export functionality
        this.getSelectedRec();
        if(this.selectedExportData.length<=0){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select atleast a record',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }else{
            console.log('___________________________exportRecordsModal else______________________________')
            //this.isModalOpen = false;
            this.template.querySelector("c-navatar-export-lwc").serverDatamakingAsExportRecord(this.globalFieldTypeCasting, this.selectedExportData, this.exportMapWholeData, this.componentReference,this.fileName);
            this.dispatchEvent(new CustomEvent('closepopup'));
        }
    }

    //This method will call when user clicks on checkbox.
    //This also create json category list which we are going to pass to export functionality to generate excel sheet
    getSelectedRec() {
        this.selectedExportData = [];
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        for(var i =0;i<selectedRecords.length;i++){
            var selectedDataMap = {};
            selectedDataMap['allCategoriers'] = selectedRecords[i].allCategoriers;
            selectedDataMap['object'] = selectedRecords[i].object;
            this.selectedExportData.push(selectedDataMap);
        }
        console.log('Selected Records :::: '+JSON.stringify(this.selectedExportData));
        this.itemCount = selectedRecords.length;
    }
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.tabcont .slds-scrollable_y{
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
        .exporttheme .slds-grid_vertical-align-center, .tabDataTable .slds-grid_vertical-align-center{
            display: flex; align-items: center; justify-content: center;
        }
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, 
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .exporttheme  .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }

        .exporttheme .slds-table td{
            height: 41px !important;
        }
        .exporttheme .slds-has-focus.slds-is-resizable .slds-th__action,
        .exporttheme .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .exporttheme .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .exporttheme .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .exporttheme .slds-is-resizable .slds-th__action:focus,
        .exporttheme .slds-is-resizable .slds-th__action:focus:hover,
        .exporttheme .slds-table th:focus,
        .exporttheme .slds-table th.slds-has-focus,
        .exporttheme .slds-table [role="gridcell"]:focus,
        .exporttheme .slds-table [role="gridcell"].slds-has-focus,
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .exporttheme .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
          box-shadow: none !important;
        } 
        .exporttheme .slds-th__action:focus, .exporttheme .slds-th__action:hover,
        .exporttheme .slds-table tr:hover, .exporttheme span.slds-th__action{
          box-shadow: none !important;
        } 
        th.slds-text-body_regular.textColor:focus, .slds-table th:focus, .slds-table th.slds-has-focus, .slds-table [role=gridcell]:focus, .slds-table [role=gridcell].slds-has-focus {
            box-shadow: none !important;
        }`;
        this.template.querySelector('.mainContainer')?.appendChild(style);         
    }
}