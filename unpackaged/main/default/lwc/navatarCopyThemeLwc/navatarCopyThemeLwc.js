import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import saveThemeRecord from '@salesforce/apex/NavatarAllThemesCtrl.saveThemeRecord';
import getThemeFields from '@salesforce/apex/NavatarAllThemesCtrl.getThemeFields';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import THEME_OBJ from "@salesforce/schema/Theme__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarCopyThemeLwc extends NavigationMixin(LightningElement) {
    @api themeTitle;
    @api showFields = false;
    themeName;
    themeDesc;
     existingRecId;
    @api recordId;
    @api showCopyScreen=false;
    @api enableSpinner =false;
    @api isThemePage = false;
    @track themeRecordId;
    @track checkBoxFieldValue= false;
    @track untaggedInteractions;
    @track isInserted;
     @api openModal= false;
     @api isEventCompleted = false;
     @api modalTitle ='Copy Theme';
     @api showListView = false;
     @api isAllThemes=false;
     field1;
     field2;
     @api isEditScreen = false;
     isError=false;
     errorMessage=[];
     isThemeAccess;


    connectedCallback(){
        getThemeFields({
        }).then(result=>{
            this.isThemeAccess = result.isThemeAccess;
            if(result.ThemeFieldsList.length>0){
                this.field1=result.ThemeFieldsList[1];
                this.field2=result.ThemeFieldsList[2];
             }
        })
        this.dispatchEvent(new CloseActionScreenEvent());      
        setTimeout(() => {
            if(this.recordId != undefined){
            this.existingRecId = this.recordId;
            this.enableSpinner=true;
            this.showCopyScreen = true;
            this.isThemePage = true;
            this.openModal= true;
            }
        }, 3000);
       // this.enableSpinner= true;
    }
    renderedCallback(){
        
        let popupSize = document.createElement('style');

        popupSize.innerText = `.uiModal--medium .modal-container {
                                width: 30rem;!important}
                                .quick-actions-panel{overflow-y:hidden !important}
                                .listdiv .slds-modal__content{
                                    min-height:200px !important;
                                }
                                .slds-spinner_container {	
                                    position: fixed;
                                    left: -100%;
                                    right: -100%;	
                                }
                                .lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
                                    position: absolute;
                                    right: 2px;
                                    top: 3px;
                                }
                                .spinner_css.slds-spinner_container {
                                    right: -90vh !important;
                                    left: -90vh !important;
                                }
                                .lookup_css_h .slds-form-element__label:empty{
                                    display:none;
                                }
                                @media only screen and (max-width : 1025px){
                                    .listdiv .slds-modal__content{
                                        min-height:200px !important;
                                    }}
                                    `;
            this.template.querySelector('.listdiv').appendChild(popupSize);              
    }
    closeCopyModal() {
        this.themeName='';
        this.themeDesc='';
        this.existingRecId='';
        this.openModal= false;
        this.checkBoxFieldValue= false;
        this.dispatchEvent(new CloseActionScreenEvent()); 
        if(this.modalTitle=='New Theme' && this.isAllThemes){ 
        this.dispatchEvent(new CustomEvent('childsuccess', { }));
        }
       else if(this.showListView){
            this.showListView = false;
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

   
      // handle selected record of quick tag lookup
      handleSelectedRecord(event){
        let selectedRecord = JSON.parse(event.detail);
        this.existingRecId = selectedRecord.data.Id;
    
    }
   

    handleChange(event){
        if (event.target.dataset.id === "Name") {
            this.themeName = event.target.value;
          } else if (event.target.dataset.id === "Description") {
            this.themeDesc = event.target.value;
          }
    }
    

    handleSave(event){
        if(this.existingRecId == undefined){
            this.errorMessage="These required fields must be completed: Existing Theme Name";
            this.isError=true;
            const objData = this.template.querySelector('c-navatar-Single-Lookup-Lwc');
            objData.showerror();

            //this.showToast(this, 'Error!', 'Please provide existing theme name to copy', 'error','sticky');
            
        }
        else  if(this.themeName == undefined || this.themeName ==  ''){
            this.errorMessage="These required fields must be completed: Theme Name";
            this.isError=true;
            this.template.querySelectorAll("lightning-input-field").forEach(item => {
                let fieldValue=item.value;
                if(!fieldValue){
               item.setCustomValidity("Complete this field");
               }
                else{
               item.setCustomValidity("");
               }
              item.reportValidity();
        });
           
        }

        else{
        this.enableSpinner=false;
        const fields = {};

        fields[this.field1] = this.themeName;
        fields[this.field2] = this.themeDesc;
            
            //4. Prepare config object with object and field API names 
        const recordInput = {
          apiName: THEME_OBJ.objectApiName,
          fields: fields
        };
            
        createRecord(recordInput).then((record) => {
           this.themeRecordId = record.id;
           if(this.themeRecordId != undefined   && this.existingRecId != undefined){
            saveThemeRecord({
                existingThemeId : this.existingRecId,
                newThemeId : this.themeRecordId ,
                themeName :'',
                themeDescription:'',
                isDetailPage :'',
                isInteraction : this.checkBoxFieldValue 
            }).then(result=>{

                 if(result){
                    this.untaggedInteractions= result.activityList;
                    this.isInserted = result.isInserted;
                    if(result.activityList.length>0 && result.activityList != undefined){
                    
                        const event = new ShowToastEvent({
                            title:'Error!',
                            variant: 'Error',
                            message: 'Error in Saving Some Interactions, limit of 13 Related Associations Reached for the following: interactions: ' + result.activityList,
                            mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                    }
                    // Bug 	00048157 fixed by Sudhanshu
                    const event = new ShowToastEvent({
                        title : 'Success',
                        variant: 'Success',
                        message: 'Theme "' + result.themeRecName + '" was created.',
                    });//46389 Bug Fix by Manonit
                    this.dispatchEvent(event);
                    this.existingRecId='';
                    this.closeCopyModal();
                    if(this.showCopyScreen){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.themeRecordId,
                            actionName: 'view',
                        },
                    })
                }
                else{
                    this.dispatchEvent(new CustomEvent('childsuccess', { detail: this.themeRecordId}));
                }
                }
            }).catch(error=>{
                this.closeCopyModal();
                this.enableSpinner=false;
                this.showToast(this, 'Error!', error.body.message, 'error','sticky');
            })
           }
        }).catch(error=>{
            this.closeCopyModal();
            this.enableSpinner=false;
            this.showToast(this, 'Error!', error.body.message, 'error','sticky');

          
        })         
    }

this.enableSpinner=true;
}  
handleInteractions(event){
    this.checkBoxFieldValue = event.target.checked;
}

showToast(cmp, title, message, variant,mode){
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode:mode
    });
    cmp.dispatchEvent(event);
}
   
}