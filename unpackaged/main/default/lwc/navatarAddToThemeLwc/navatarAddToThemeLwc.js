/*
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 2.0        2024-02-22          Manonit        Enhanced add to theme Functionality 
*/
import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import addToTheme from  '@salesforce/apex/NavatarAllThemesCtrl.addToTheme';
import getRelatedObjectRecords from '@salesforce/apex/NavatarAllThemesCtrl.getRelatedObjectRecords';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class navatarAddToThemeLwc extends LightningElement {
  @track  existingRecId ;
  @api recordId;
  @api objectApiName;
  @api isThemePage = false;
  relatedObjects =[];
  @track selectedCheckboxes=[];
  selectedRows;
  relatedRecords;
  isError=false;
  errorMessage=[];
  displayModal = false;
   isCollapse = false;
    isExpand = true;
    isExpandCollapseBox = true;   
    isExpandadvance(){
        if(this.isCollapse === false){
            this.isCollapse = true;
            this.isExpand = false;
            this.isExpandCollapseBox = false;
        }
        else{
            this.isCollapse = false;
            this.isExpand = true;
            this.isExpandCollapseBox = true;
        }
        }

        columnsCatogry = [
        { label: 'All Categories',type:'text', fieldName: 'label', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' } },
        
    ];
   //00045104 Bug Fix By Manonit
   
   

  @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
             this.recordId = currentPageReference.state.recordId;
              console.log('Record Id ', this.recordId);
            }
    }

  connectedCallback(){
    this.isThemePage = true;
    this.getRelatedObjectRecords(this.recordId);
    
  }
    //To fetch the related objects List
    getRelatedObjectRecords(recordId){
    getRelatedObjectRecords({
        recId : recordId
    }).then(result => {
        if(result){
            this.displayModal = true;
            this.relatedObjects = Object.entries(result).map(([label,value]) => ({
                label,
                value
            }));
            this.selectedCheckboxes = this.relatedObjects.map(obj => obj.value);
            this.selectedRows=this.relatedObjects.map(obj => obj.label);
        }

    }).catch(error => {
        console.log('Error is: '+error);
    })
   }

  //UI Css changes
    renderedCallback(){
        console.log(this.isRendered);
        //00045714 Bug Fix By Raju
        let popupSize = document.createElement('style');
        popupSize.innerText = `.DESKTOP .modal-container {
                                max-width: 35% !important}
                                .quick-actions-panel{overflow-y:hidden !important}
                                /*.listdiv .slds-modal__content{
                                    min-height:120px !important;
                                }*/
                                /*00045936 fixed by raju 29-05-2024*/
                                .lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
                                    position: absolute;
                                    right: 2px;
                                    top: 0px; /*make it 0px from 3px*/
                                }
                                /*@media only screen and (max-width : 1025px){
                                .listdiv .slds-modal__content{
                                    min-height:120px !important;
                                }}
                                @media only screen and (max-width : 1280px){
                                    .listdiv .slds-modal__content{
                                        min-height:120px !important;
                                        max-height: 340px !important;
                                    }}*/

                                    /* 00045715 ,45714 fiexd by raju 20-05-2024*/
                                    /*.clsThemeTable {
                                        max-height: 158px !important;
                                        overflow: auto !important;
                                    }*/
                                    .clsThemeTable {
                                        overflow-x: hidden !important;
                                    }
                                    .clsThemeTable .slds-table_bordered tbody th {
                                        height: 41px !important;
                                    }
                                      .listdiv .slds-modal__content {
                                        height: 310px !important;
                                        overflow-y: auto;
                                    }//Bug Fix By Raju 46725 Merged By Manonit
                                `;
            this.template.querySelector('.listdiv').appendChild(popupSize);              
    }
    /* To close the modal */
    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());        
    }

    // handle selected record of quick tag lookup
 handleSelectedRecord(event){
    try{
    let selectedRecord = JSON.parse(event.detail);
    this.existingRecId = selectedRecord.data.Id;
    if( this.existingRecId != undefined){
        this.errorMessage='';
        this.isError=false;
    }
}catch(err){
    alert(err);
}
}

handleChange(event){
    let selectedValues=event.detail.selectedRows.map((row) => row.value);
    this.selectedCheckboxes = selectedValues;
}

handleRemove(){
    this.showRelatedObjects = false;
}
/* To add the selected theme to resp obj */
handleAdd(event){
    try{
    if(this.existingRecId == undefined){
        this.errorMessage="These required fields must be completed: Theme Name";
        this.isError=true;
        const objData = this.template.querySelector('c-navatar-Single-Lookup-Lwc');
        objData.showerror();
    }
    else if( this.existingRecId == this.recordId){
        this.errorMessage="Selected Theme record cannot be associated to itself";
        this.isError=true;
    }
    else {
        let checkboxesCopy = [...this.selectedCheckboxes];
        let interactionsArray = [];
        if(checkboxesCopy.includes('Activities')){
            interactionsArray = checkboxesCopy.filter(item => item != 'Activities');
            if(interactionsArray && interactionsArray.length > 0){
                this.callAddToTheme(interactionsArray).then(() => {
                    this.callAddToTheme('Activities');
                }).catch(error => {
                    console.log('Error is: '+error);
                });
            }
            else {
                this.callAddToTheme('Activities');
            }
        }  
        else{
            this.callAddToTheme(this.selectedCheckboxes);
        }     
   }
}catch(err){
     console.log(err);
}
}

callAddToTheme(selectedCheckboxes){
    return new Promise((resolve, reject) => {
        try{
            addToTheme({
                themeId : this.existingRecId,
                recId : this.recordId,
                ObjName : this.objectApiName,
                relatedObjectsList : selectedCheckboxes
            }).then(result=>{
                if(result){
                    this.showToastMsg('Success','Record(s) was associated with the Theme.'); //00045539,46635 Fix By Manonit
                    this.closeModal();
                    resolve(result);
                }
                else{
                    this.errorMessage="Record(s) already associated with this Theme. Please select different theme or related records to proceed.";
                    this.isError=true;
                    reject(new Error("Record(s) already associated with this Theme. Please select different theme or related records to proceed."));
                   
                }                
            }).catch(error => {
                this.closeModal();
                reject(error);
            });
        } catch (error) {
            this.closeModal();
            reject(error);
        }
    });   
}

/* To show toast message */
 showToastMsg(variant , message){
    const event = new ShowToastEvent({
        variant: variant,
        message: message,
        title: variant,
        label: ' '
    });
    this.dispatchEvent(event);//45974 Manonit
 }
}