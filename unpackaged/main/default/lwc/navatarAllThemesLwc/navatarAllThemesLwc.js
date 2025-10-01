import { LightningElement,track,wire,api } from 'lwc';
import getAllThemes from '@salesforce/apex/NavatarAllThemesCtrl.getAllThemes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getSearchedThemes from '@salesforce/apex/NavatarAllThemesCtrl.getSearchedThemes';
import saveThemeRecord from '@salesforce/apex/NavatarAllThemesCtrl.saveThemeRecord';
import getThemeFields from '@salesforce/apex/NavatarAllThemesCtrl.getThemeFields';
import { createRecord } from 'lightning/uiRecordApi';
import THEME_OBJ from "@salesforce/schema/Theme__c";
import NAME_FIELD from "@salesforce/schema/Theme__c.Name";

export default class NavatarAllThemesLwc extends NavigationMixin(LightningElement) { 
    @track error;
    themeList ;
    searchValue='';
    newThemePop = false;
    newThemeNoPop = false;
    newThemeYesPop = false;
    isExistData ;
    data;
    @track  enableSpinner = true;
    themeName;
    themeDesc;
    @track objectData;
    @track allTaggedRecords = [];
    @api isThemePage = false;
     existingRecId;
    @track themeRecordId ;
    @track isShowCopy= false;
    @track checkBoxFieldValue= false;
    @track untaggedInteractions;
    @track isInserted;
    showCopyScreen = false;
    spinnerVar = true;
    @track showEvent = false;
    @api title='New Theme';
    field1;
    field2;
    fields;
    showNewScreen= true;
    themeData;
    themeCol=[];
    errorMessage;

    renderedCallback() {
        console.log(this.isRendered);
        const style = document.createElement('style');
        style.innerText = `
        .tab-ht .slds-button:active{
            border:none;
        }
        .text-black button.slds-button{
            color:#000 !important;
            white-space: nowrap;
            text-overflow: ellipsis;
            max-width: 100%;
            display: block;
            overflow: hidden;
            cursor : text;
            border: none;
        }
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .viewallScreen .slds-is-resizable .slds-th__action:focus,
        .viewallScreen .slds-is-resizable .slds-th__action:focus:hover,
        .viewallScreen .slds-table th:focus,
        .viewallScreen .slds-table th.slds-has-focus,
        .viewallScreen .slds-table [role="gridcell"]:focus,
        .viewallScreen .slds-table [role="gridcell"].slds-has-focus,
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
          box-shadow: none !important;
        } 
        .viewallScreen .slds-th__action:focus, .slds-th__action:hover,
        .viewallScreen .slds-table tr:hover{
          box-shadow: none !important;
        } 
        .viewallScreen .slds-th__action{
            background: #f3f3f3 !important;
        }
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>th{
            background: none !important;
        }
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }
        .viewallScreen .slds-button:focus{
            box-shadow: none;
        }
        .viewallScreen .button.slds-button:active, .viewallScreen .button.slds-button{
            border: none;
        }
        .text_underline button.slds-button:hover{
            text-decoration : underline;
        }
        td.text-black{
            height: 41px;
        }
        .power-btn button.slds-button{
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
            max-width: 100% !important;
            display: block !important;
            overflow: hidden !important;
        }
        .spinner_css.slds-spinner_container {
            right: -90vh !important;
            left: -90vh !important;
        }`;
        // let SubjectlineClamp = document.createElement('style');
        // SubjectlineClamp.innerText = '.slds-truncate {display: -webkit-box;-webkit-box-orient: vertical;overflow: hidden;text-overflow: ellipsis;-webkit-line-clamp: 2;white-space: pre-line;word-wrap: break-word;hyphens: auto; max-width: 100%;}';

        let butnText = document.createElement('style');     
        butnText.innerText = `.viewallScreen .slds-button {
             text-align: left;
             line-height: 18px;
        }
        .flexipageHeader {
            display: none !important;
        }`;
        this.template.querySelector('lightning-datatable').appendChild(butnText);
        // this.template.querySelector('lightning-datatable').appendChild(SubjectlineClamp);
        this.template.querySelector('.main-Container-alltheme')?.appendChild(style);
    }

    connectedCallback(){
        getThemeFields({
        }).then(result=>{
           this.themeCol=[
            {
                label: 'Date Created',
                fieldName: 'CreatedDate',
                type: 'text',
                hideDefaultActions: true, sortable: false,
                typeAttributes: { label: { fieldName: 'CreatedDate' },variant: 'base',  title: { fieldName: 'CreatedDate' } },
                cellAttributes:{ class: 'text-black'}
            },
            {
                label: 'Created By',
                fieldName: 'CreatedByName',
                type: 'button',
                typeAttributes: { label: { fieldName: 'CreatedByName' }, variant: 'base', tooltip: { fieldName: 'CreatedByName' }, title: { fieldName: 'CreatedByName' }},
                hideDefaultActions: true, sortable: false,cellAttributes:{ class: 'text-black'}
            },
            {
                label: 'Team',
                fieldName: 'userNames',
                type: 'button',
                typeAttributes: {label: {fieldName: 'Team', }, variant: 'base', tooltip: {fieldName: 'Team'}},cellAttributes:{ class: 'text-decor-tags text-truncate text-decor text-black'}
                 , hideDefaultActions: true, sortable: false
            }
           ];

           if(result.ThemeHeader1){
            this.themeCol.splice(0,0, { label: result.ThemeHeader1,
                fieldName: 'ref', initialWidth: 350, 
                type: 'url', 
                hideDefaultActions: true,  sortable: false, typeAttributes: {label: {fieldName: 'name' }, variant: 'base', target: '_blank', tooltip: {fieldName: 'name'}},
                cellAttributes:{ class: 'text-black'}
                })
           } 
           if(result.ThemeHeader2){
            this.themeCol.splice(1,0,{label: result.ThemeHeader2,
                fieldName: 'Description',
            type: 'button',
             typeAttributes: { label: { fieldName: 'Description' },variant: 'base', tooltip: { fieldName: 'Description' }, title: { fieldName: 'Description' }},
            hideDefaultActions: true, sortable: false,cellAttributes:{ class: 'text-black'}
            })
           }

            if(result.ThemeFieldsList.length>0){
                this.field1=result.ThemeFieldsList[1];
                this.field2=result.ThemeFieldsList[2];
             }
           
        })
       this.getAllThemesList();

    }

   
   @api getAllThemesList(){
    getAllThemes({
        themeIdList : []
    }).then(result=>{

        if(result.length>0){
        this.data = result;
        this.themeData= result;
        this.handleTableData();
        }
        else{
            this.isExistData = false;
            this.themeList =[];
            this.enableSpinner = false;
        }
    }).catch(error=>{
    })
}

addNewTheme(){
    this.newThemePop = true;
    this.enableSpinner = false;
}

handleKeyUp(event) {
    
    const isEnterKey = event.keyCode === 13;
    if(isEnterKey){
        this.enableSpinner = true;
        this.searchValue = event.target.value;
    if (this.searchValue !== '' && this.searchValue.length >1) {
        this.template.querySelectorAll("lightning-input").forEach(item => {
            item.setCustomValidity("");
            item.reportValidity();
            });
       getSearchedThemes({
        searchTerm :  this.searchValue.trim()
       }).then(result=>{
        this.data = result;
        this.handleTableData();
          
       }).catch(error=>{})
     } 
    else {
        this.template.querySelectorAll("lightning-input").forEach(item => {
            let fieldValue=item.value;
            if(fieldValue.length <=1){  
                this.errorMessage = "Your search term must have 2 or more characters";
                item.setCustomValidity(this.errorMessage); 
            } 
            else{
                item.setCustomValidity("");
                }
            item.reportValidity();
            });
            this.enableSpinner = false;
    }
} 
else if( event.target.value.length ===0){
    this.data= this.themeData != undefined ?  this.themeData : [];
    this.handleTableData();
}
}

    handleTableData(){
       if( this.data.length>0){
        let tempRecords = JSON.parse( JSON.stringify( this.data ) );
             tempRecords = tempRecords.map( row => {
                 return { ...row, Id: row.Id, name : row.Name , ref : row.recordReference, Description :  row.Description, CreatedDate :  row.CreatedDate,CreatedByName: row.CreatedBy,Team : row.ThemeRelationUser
                       };
             })
             this.themeList = tempRecords;
             this.isExistData = true;
             this.enableSpinner = false;
            }
            else{
                this.isExistData = false;
                this.themeList =[];
                this.enableSpinner = false;
            }
    }
    


handleChildComplete(event){
    this.newThemeNoPop = false;
    this.newThemeYesPop = false;
    this.newThemePop = false;
    this.enableSpinner = false;
    let searchInputshowhide = this.template.querySelector('.modalbackdrop');
    searchInputshowhide.classList.toggle('hidebackdrop');
    this.getAllThemesList();
}

showErrorMsg(){
    this.template.querySelectorAll("lightning-input").forEach(item => {
        let fieldValue=item.value;
        if(fieldValue.length <=1){  
            this.errorMessage = "Your search term must have 2 or more characters";
            item.setCustomValidity(this.errorMessage); 
             return;
        } 
        else{
            item.setCustomValidity("");
            }
        item.reportValidity();
        });
    }
   
}