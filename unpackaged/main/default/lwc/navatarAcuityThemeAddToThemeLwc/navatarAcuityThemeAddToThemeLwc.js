//Added by Tejaswini - Naming Convention.
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//Added By Tejaswini - Naming Convention 
import saveThemeRelations from '@salesforce/apex/NavatarThemeAcuityCtrl.saveThemeRelations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//added by Hema w.r.t - 00040023
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
//end by Hema

export default class NavatarAcuityThemeAddToThemeLwc extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    headerText='';
    @track objIcon='standard:account';
    selectedRecord;
    @api recordId;
    placeHolderVal='Search...'; //Added by Tejaswini - 00035162

    //Added by Hema - 00040023
    options=[]; 

    //added by Hema -	00040023
@wire(getObjectInfos,{objectApiNames:['Account','Contact','navpeII_dev18__Pipeline__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c','navpeII_dev18__Theme__c','navpeII_dev18__Clip__c']})	
AllObjectsInfo({error,data}){	
    if(error){	
        this.showToast(this, 'Error!', error.body.message, 'error');	
    }else if(data){	
        
        console.log(JSON.stringify(data));	
        if(data!=null && data.results.length>0){	
            for(let i=0;i<data.results.length;i++){	
                //Added below if clause by LK on 2024-01-02 to fix the options visible multiple times issue
                if(data.results[i].statusCode === 200){
                let objOptions={};
                if(data.results[i].result.apiName == 'Account'){	
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'Account'
                    };
                }else if(data.results[i].result.apiName == 'Contact'){	
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'Contact'
                    };
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Pipeline__c' ){	
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'navpeII_dev18__Pipeline__c'
                    };
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Fund__c' ){
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'navpeII_dev18__Fund__c'
                    };
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Fundraising__c' ){	
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'navpeII_dev18__Fundraising__c'
                    };	
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Theme__c'  ){
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'navpeII_dev18__Theme__c'
                    };
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Clip__c'){	
                    this.objOptions = {
                        label:data.results[i].result.label,
                        value: 'navpeII_dev18__Clip__c'
                    };
                }
                this.options = [ ...this.options, this.objOptions ];
                }		
            }
            return this.options;  
            		
        }		
    }		
}//end by Hema - 00040023

    showToast(cmp, title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        cmp.dispatchEvent(event);
    }

    @api openModal(gridName) {
       this.value = gridName;
       if(this.value == 'Account'){
            this.objIcon = 'standard:account';
            //this.placeHolderVal = 'Search Firms here...'; Commented by Tejaswini - 00035162
        }
        else if(this.value == 'Contact'){
            this.objIcon = 'standard:contact';
            //this.placeHolderVal = 'Search Contacts here...'; Commented by Tejaswini - 00035162
        }
        else if(this.value == 'navpeII_dev18__Pipeline__c'){
            this.objIcon = 'custom:custom47';    
            //this.placeHolderVal = 'Search Deals here...'; Commented by Tejaswini - 00035162
        }
        else if(this.value == 'navpeII_dev18__Fundraising__c'){
            this.objIcon = 'custom:custom3'; 
            //this.placeHolderVal = 'Search Fundraisings here...'; Commented by Tejaswini - 00035162   
        }
        else if(this.value == 'navpeII_dev18__Fund__c'){
            this.objIcon = 'custom:custom34';  
            //this.placeHolderVal = 'Search Funds here...'; Commented by Tejaswini - 00035162  
        }
        else if(this.value == 'navpeII_dev18__Theme__c'){
            this.objIcon = 'custom:custom100'; //Added by Tejaswini BugFix - 00035018
            //this.placeHolderVal = 'Search Themes here...'; Commented by Tejaswini - 00035162   
        }
        else if(this.value == 'navpeII_dev18__Clip__c'){
            this.objIcon = 'utility:copy_to_clipboard';  
            //this.placeHolderVal = 'Search Clips here...'; Commented by Tejaswini - 00035162  
        }
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
     value = 'Account';

     //Commented by Hema - 00040023
   /* get options() {
        return [
            { label: 'Firm', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
            { label: 'Deal', value: 'navpeII_dev18__Pipeline__c' },
            { label: 'Fund', value: 'navpeII_dev18__Fund__c' },
            { label: 'Fundraising', value: 'navpeII_dev18__Fundraising__c' },
            { label: 'Themes', value: 'navpeII_dev18__Theme__c'},
            { label: 'Clips', value: 'navpeII_dev18__Clip__c'}
        ];
    }*/
    handleChange(event) {
        this.value = event.detail.value;
        if(this.value == 'Account'){
            this.objIcon = 'standard:account';
        }
        else if(this.value == 'Contact'){
            this.objIcon = 'standard:contact';
        }
        else if(this.value == 'navpeII_dev18__Pipeline__c'){
            this.objIcon = 'custom:custom47';    
        }
        else if(this.value == 'navpeII_dev18__Fundraising__c'){
            this.objIcon = 'custom:custom3';    
        }
        else if(this.value == 'navpeII_dev18__Fund__c'){
            this.objIcon = 'custom:custom34';    
        }
        else if(this.value == 'navpeII_dev18__Theme__c'){
            this.objIcon = 'custom:custom100';  //Added by Tejaswini BugFix - 00035018  
        }
        else if(this.value == 'navpeII_dev18__Clip__c'){
            this.objIcon = 'utility:copy_to_clipboard';    
        }
    }
    lookupRecord(event){
        this.selectedRecord = event.detail.selectedRecord['Id'];
    }

    saveThemeRelationRecord(){
        if(this.selectedRecord == this.recordId){
            this.showToast(this, 'Error!', 'Record is already associated.', 'error');
        }
        else{
            saveThemeRelations({fieldId : this.selectedRecord, themeId: this.recordId})
            .then(result => {
                if(result == 'true'){
                    this.showToast(this, 'Error!', 'Record is already associated.', 'error');
                }
                else if(result == 'Select atleast a record.'){
                    this.showToast(this, 'Error!', 'Select atleast a record.', 'error');
                }
                else{
                    this.showToast(this, 'Success', 'Theme ' + result + ' was created.', 'Success');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Theme__c',
                            actionName: 'view'
                        }
                    });
                }
                
                }).catch(error => {
                    this.showToast(this, 'Error!', error.body.message, 'error');
                });
        }
        
    }
    
   //Modified by Ehatsham for appending namespace
    handleRedirect(event){
        let mainSearchfromTheme;
        mainSearchfromTheme = event.currentTarget.dataset.boolcheck;
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarResearchSearchResultLwc",
            attributes: {
                callFromObject: 'navpeII_dev18__Theme__c',
                callFromRecId: this.recordId,
                callingFrom: 'ThemePage'
            }
        };

        var encodedCompDef = btoa(JSON.stringify(compDefinition));

        var url = '/one/one.app#' + encodedCompDef; //added for bug #00045233 fixes by Deepak
        window.open(url, '_blank');
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl,  "_blank");
        // });
        
    }
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.hidelabel label.slds-form-element__label{
          display: none;
        }`;
        try {
           this.template.querySelector('.main-Container').appendChild(style);
       } catch (err) {
           console.log(err)
       }
    }

    
    
}