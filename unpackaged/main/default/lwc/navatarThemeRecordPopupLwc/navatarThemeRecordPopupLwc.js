import { LightningElement,api,track } from 'lwc';
import saveThemeRecord from '@salesforce/apex/NavatarAllThemesCtrl.saveThemeRecord';
import getThemeFields from '@salesforce/apex/NavatarAllThemesCtrl.getThemeFields';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'
import THEME_OBJ from "@salesforce/schema/Theme__c";
import getThemeName from '@salesforce/apex/NavatarAllThemesCtrl.getThemeName';

export default class NavatarThemeRecordPopupLwc extends NavigationMixin(LightningElement)  {
  
   @api showModal = false;
   newThemePop = false;
    newThemeNoPop = false;
    newThemeYesPop = false;
    @track  enableSpinner = true;
    showCopyScreen = false;
    spinnerVar = true;
    @track showEvent = false;
    @api title='New Theme';
    themeName;
    themeDesc;
    @track objectData;
    @api isThemePage = false;
    existingRecId;
    field1;
    field2;
    fields;
    @api showNewScreen;
    showCopyScreen = false;
    spinnerVar = true;
    @track showEvent = false;
    @api isAllThemes=false;
    @api isEditScreen = false;  
    isError = false; 
    errorMessage=[];
    isThemeAccess;

    connectedCallback(){
      this.showModal= true;
    
      getThemeFields({
      }).then(result=>{
        this.isThemeAccess = result.isThemeAccess;
           if(result.ThemeFieldsList.length>0){
              this.field1=result.ThemeFieldsList[1];
              this.field2=result.ThemeFieldsList[2];
           }
      })
    

  }

  handleChange(event){

   if (event.target.dataset.id === "Name") {
       this.themeName = event.target.value;
       console.log(this.name);
     } else if (event.target.dataset.id === "Description") {
       this.themeDesc = event.target.value;
       console.log(this.industry);
     }
}

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
      }
      .descrp textarea{
         min-height: 100px !important;
      }`;
      this.template.querySelector('.main-Container-alltheme')?.appendChild(style);
      let butnText = document.createElement('style');     
      butnText.innerText = `.viewallScreen .slds-button {
           text-align: left;
           line-height: 18px;
      }
      .flexipageHeader {
          display: none !important;
      }`;
      
  }

   newThemeNoPopclick(){
      this.showModal=false;
      this.newThemeNoPop = true;
      this.newThemePop = false;
      this.enableSpinner = false;
  }
  newThemeYesPopclick(){
   this.showModal=false;
   this.newThemeYesPop = true;
   this.newThemePop = false;
   this.enableSpinner = false;
   this.isThemePage= true;
}
handleNewTheme(event){
   this.enableSpinner = true;
   this.handleCreate();

   
}

handleCreate(){
   if(this.themeName == undefined || this.themeName ==  ''){
    this.errorMessage="These required fields must be completed: Theme Name";
    this.isError=true;

   }
   else{
          
           const fields = {};
          

           fields[this.field1] = this.themeName;
           fields[this.field2] = this.themeDesc;
               
               //4. Prepare config object with object and field API names 
           const recordInput = {
             apiName: THEME_OBJ.objectApiName,
             fields: fields
           };
               
           createRecord(recordInput).then((record) => {
            getThemeName({
                themeId : record.id
            }).then(result=>{
               this.themeDesc='';
               this.themeName='';
              
               this.showToastMsg(result);
               this.closeNewtheme();
               this.newThemeNoPop = false;
               this.showModal=false;
               this.newThemeYesPop = false;
               if(!this.showNewScreen){
               this[NavigationMixin.Navigate]({
                  type: 'standard__recordPage',
                  attributes: {
                      recordId: record.id,
                      actionName: 'view',
                  },
              })
            }
            else{
               this.dispatchEvent(new CustomEvent('childsuccess', { }));
            }
           })
        })
   }
   this.enableSpinner = false;
}

showToastMsg(name){
   const event = new ShowToastEvent({
       title:'Success',
       variant: 'Success',
       message: 'Theme "'+ name + '" was created.', // Bug 00048157 Fixed by Sudhanshu on 13-11-2024
   });//46389 Bug Fix By Manonit
   this.dispatchEvent(event);
}
handleChildComplete(event){
   this.newThemeNoPop = false;
   this.newThemeYesPop = false;
   this.newThemePop = false;
   this.enableSpinner = false;
   this.showModal=false;
  
 
   if(!this.showNewScreen){
   let selectedRecord = (event.detail);
   if(selectedRecord != undefined && selectedRecord != null){
   this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: selectedRecord,
          actionName: 'view',
      },
  })
}
   }
   else{
      this.dispatchEvent(new CustomEvent('childsuccess', { }));
   }
}
   

handleSelectedRecord(event){
   let selectedRecord = JSON.parse(event.detail);
   this.existingRecId = selectedRecord.data.Id;

}
closeNewtheme(){
   this.newThemeNoPop = false;
   this.newThemeYesPop = false;
   this.newThemePop = false;
   this.enableSpinner = false;
   this.showModal=false;
   if(this.showNewScreen){
      this.dispatchEvent(new CustomEvent('childsuccess', { }));
      }
      else if(!this.showNewScreen){
         this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'navpeII_dev18__Theme__c',
                actionName: 'list'
            },
            state: {
                
                filterName: 'Recent' 
            }
        });
    }

}
}