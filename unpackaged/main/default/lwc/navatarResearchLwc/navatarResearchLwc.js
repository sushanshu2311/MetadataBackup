import { LightningElement,track,wire} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

// import standard toast event 
import {ShowToastEvent} from 'lightning/platformShowToastEvent'


//
export default class NavatarResearchLwc extends NavigationMixin(LightningElement) {

    advanceClick=false;
@track searchRecord;
@track currentRecordId;
@track currentObjectName;
handlingChangeValueCondition=false;
error;





searchValue = ''; 


// update searchValue var when input field value change
searchKeyword(event) {
    if(!this.handlingChangeValueCondition){
        this.showcombo();
    }
    this.handlingChangeValueCondition=true;
  
this.searchValue = event.target.value;

}

handleEnter(event){
    

if(event.keyCode === 13){
//this.handleSearch();
this.handleNavigate();
}


}

handleSearch(){
    this.handleNavigate();
    
}

handleNavigate() {
    if(this.searchValue.indexOf('’') != -1){
    this.searchValue = this.searchValue.replace('’','\'');
    }
    this.handlingChangeValueCondition=false; 
    var data='close';
    const closeUtility = new CustomEvent('closeutilitybar', {
        detail: {data}
    });
    this.dispatchEvent(closeUtility);
    var trimString=this.searchValue.trim();
    this.searchValue=trimString;
    var compDefinition = {
        componentDef: "navpeII_dev18:navatarResearchSearchResultLwc",
        attributes: {
            propertyValue: this.searchValue,
            mechanishmValue: this.value,
            currentObj:this.currentObjectName,
            currentId: this.currentRecordId,
            advanceCheck:this.advanceClick
        }
    };
    // Base64 encode the compDefinition JS object
    var encodedCompDef = btoa(JSON.stringify(compDefinition));
    this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes:{
            url:'/one/one.app#' + encodedCompDef
        }
    });
    this.advanceClick =false;
}







    @wire(CurrentPageReference)
    currentPageReference; 

    get recordIdFromState(){
        return this.currentPageReference;
    }
    

combo = false;
    showcombo(){
        this.urlData=this.recordIdFromState;
         
          if(this.urlData.attributes.recordId != undefined){
            this.combo = true;
            this.currentRecordId=this.urlData.attributes.recordId;
            this.currentObjectName=this.urlData.attributes.objectApiName;            
          }else{
            this.combo = false;
            this.currentRecordId='';
            this.currentObjectName=this.urlData.attributes.objectApiName;
          }
        
    }
    value="systemWide";
    get options() {
        return [
            { label: 'System Wide', value: 'systemWide' },
            { label: 'Current Record', value: 'currentRecord' },
            
        ];
    }
    handleChange(event) {
        this.value = event.detail.value;
        this.showcombo();
      //  this.cheackRecordPage();
    }

    renderedCallback(){

        

        const style = document.createElement('style');

        style.innerText = `.label_hidden .slds-form-element__label{

          display: none;

        }

        `;

        try {

           this.template.querySelector('.main-Container').appendChild(style);

       } catch (err) {
       }

    }

    //code
    
handleAdvanceClick(){
    this.advanceClick =true;
    this.handleNavigate();
}
    
}