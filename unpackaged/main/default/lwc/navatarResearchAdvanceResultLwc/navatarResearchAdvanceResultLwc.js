import { LightningElement,wire,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

import addToThemeRecord from '@salesforce/apex/NavatarResearchAdvanceResultCtrl.addToThemeRecord';
import createThemeRecord from '@salesforce/apex/NavatarResearchAdvanceResultCtrl.createThemeRecord';

import TickerSymbol from '@salesforce/schema/Account.TickerSymbol'; 
import FUND_INFO from '@salesforce/schema/Fund__c';
import FUND_TYPE_FIELD from "@salesforce/schema/Fund__c.Fund_Type__c";
import INVESTMENT_CATEGORY_FIELD from "@salesforce/schema/Fund__c.Investment_Category__c";
import ACCOUNT_INFO from '@salesforce/schema/Account';
import createFund from '@salesforce/apex/NavatarResearchAddToFundCtrl.createFund';
import createFdr from '@salesforce/apex/NavatarResearchAddToFundCtrl.createFdr';
import addToFundFdr from '@salesforce/apex/NavatarResearchAddToFundCtrl.addToFundFdr';
import conFromAcc from '@salesforce/apex/NavatarResearchAddToFundCtrl.getConFromAcc';
import createFdrCon from '@salesforce/apex/NavatarResearchAddToFundCtrl.createFdrCon';
import THEME_INFO from '@salesforce/schema/Theme__c';
import fetchAllowedAccRecTypeList from '@salesforce/apex/NavatarResearchAddToFundCtrl.fetchAllowedAccRecTypeList';
import FUNDRAISING_CONTACT_OBJECT from '@salesforce/schema/Fundraising_Contact__c';//Added by LK on 2024-08-22 to fix 00045910

export default class NavatarResearchAdvanceResultLwc extends LightningElement {
    /* Added below code by LK for the Add to Fund functionality - START */
    @api pluralLabelMap; // for plural label of object handling
    @api objectLabelMap; // for singular label of object handling
    @api themeDesLabel;
    isCreateNew = false;
    saveCheck = true; //for save button enable/disable
    createCheck = true;
    valueCreateNew = 'theme';
    createFund = false;
    isAddNewFund = false;
    @track accountRecordTypeList = [];
    @track accountRecordTypeNameList = [];
    availableAccRecList = [];
    accountLabel; // for dynamic label of account object
    contactLabel; //for dynamic label of contact object
    fundLabel; // for dynamic label of fund
    fdrLabel;
    themeLabel; // for dynamic label of theme
    paccountLabel;
    pcontactLabel;
    pfundLabel;
    pfdrLabel;
    pthemeLabel;
    columnsCatogryFund = [];
    @track fundName;
    @track createdFundId;
    @track selectedRecordTypeID;
    defaultFundRcType; //for bug #00041477 fixes by salauddin sheikh
    addFund = false;
    @api mainSearchfromFund;    //search from fund page
    valueAddNew = 'theme';
    isAddNew = false;
    //fundRecord;
    fundTypeLabel = '';
    selectedFundType = '';
    fundTypeOptns = [];
    invCategoryLabel = '';
    selectedInvCategory = '';
    invCategoryOptns = [];
    invCategoryOptnsComplete = [];
    isfundTypeVsInvCategoryMapped = false;
    fundTypeVsInvCategoryMapping = new Map();
    fundRecTypeExists = false;
    fundRecTypeList = [];
    @track fundSelectedAccRecType = [];
    @track isYesNoFund = false;
    addAllConforTheme = false;  //added fixes of bug #00040888 by salauddin sheikh
    @track accountIds;
    isYesNo = false;
    get optionsCreateNew(){
        return [
            { label: this.themeLabel, value: 'theme' },
            { label: this.fundLabel, value: 'fund' },
        ];
    }
    get optionsAddNew(){
        return [
            { label: this.themeLabel, value: 'theme' },
            { label: this.fundLabel, value: 'fund' },
        ];
    }
    buttonClickedName = '';//Added by LK on 2024-05-11 to fix 00045609
    get addConMsg(){//Added by LK on 2024-05-11 to fix 00045699 ; 00045697
        return `Do you want to add all ${this.pcontactLabel.toLowerCase()} of the ${this.paccountLabel.toLowerCase()} or select ${this.pcontactLabel.toLowerCase()}?`;
    }
    noAccessToastMsg = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';//Added by LK on 2024-05-14 to fix 00045529
    /* Added above code by LK for the Add to Fund functionality - END */

    showCheckBoxForAllContactsForEachFirm=false;
    themeName;
    themeDescription;
    advanceParameterShow=false;

//------Export functionality variable -----------------------------------------------------------------------------
@api globalFieldTypeCasting;
notificationFlag=false;
// new var for export
componentReference='NavatarAdvanceResearchComponent';
fileName = 'NavatarResearchPageData.xlsx';

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//export xlsx method variables 

//------------------------------------------------------------------------------------------------------------------

   @api themeProcessCheck;
   @api themeIdComingFromThemePageFunctionality;
   @api currId;
   @api currObj;
   @track valueSpecefic ;
   @track objApiNamesListTab1=['Account','Contact','navpeII_dev18__Fundraising__c','navpeII_dev18__Fund__c','navpeII_dev18__Pipeline__c'];
   @api advancePop;
   // --------------------------------------------------------------------------------------
    @api iconObjectList;
    @track comingSelectionTabelData; 
    @track  comingWholeMapData;
    @api comingSelectionTabelDataFirstCmp; 
    @api  comingWholeMapDataFirstCmp;
    selectedRecord; // to store selected lookup record in object formate 
    SelectedData=[];
    @track dataCatogry=[];
    //dataCatogry=comingSelectionTabelData;
    @track dataCatogryForInternalPart=[];//for add to theme and create to theme 

    @api searchKeyword;
    @api objOptionList;
    @track AddAllPop=false;
    @track mainSearch = true;
    @api mainSearchfromTheme;
    @track advanceSearch;
    
    @track listOfAccountsPara=[];
    isSelected = false;
    isAddTo = false;
    isCreateRecord = false;
    isExport = false;
    isRange = false;
    saveButtonDisable=false;
    dataHandel = true;

//-----------------------------------------------------------------

    @track sendObj='';
    @track objIconName='';
    @track defRecId='';
    @track indexOflist;

//--------------------------------------------------------------------
accIdListGlobal=[];
conIdListGlobal=[];
dealIdListGlobal=[];
fundIdListGlobal=[];
fundRaisingIdListGlobal=[];
clipIdListGlobal=[];
themeIdListGlobal=[];
interactionIdListGlobal=[];

serverMessage='';
itemCount;
//--------------------------------------------------------------------

    @track createTeamIncludeAllContactsForEachFirm = false;
    @track addToTeamIncludeAllContactsForEachFirm = false;
//--------------------------------------------------------------------
    //Added below code by LK on 2024-03-18 for PE Phase 3.2 - START
    get isFundAccessible(){
        return (this.fundRecord['data'] && this.fundRecord['data'] !== undefined);
    }
    get isThemeAccessible(){
        return (this.themeRecord['data'] && this.themeRecord['data'] !== undefined);
    }
    @wire(getObjectInfo, { objectApiName: THEME_INFO}) 
    themeRecord;

    //Added by LK on 2024-08-22 to fix 00045910
    @wire(getObjectInfo, { objectApiName: FUNDRAISING_CONTACT_OBJECT}) 
    fdrConRecord;
    //Added above code by LK on 2024-03-18 for PE Phase 3.2 - END

CreateTeamBooleanForAllContactsForEachFirm(){
    
    if(!this.createTeamIncludeAllContactsForEachFirm){
        this.createTeamIncludeAllContactsForEachFirm=true;
    }else{
        this.createTeamIncludeAllContactsForEachFirm=false;
    }
    
    return 1;
}

AddToTeamBooleanForAllContactsForEachFirm(){
    
    if(!this.addToTeamIncludeAllContactsForEachFirm){
        this.addToTeamIncludeAllContactsForEachFirm=true;
    }else{
        this.addToTeamIncludeAllContactsForEachFirm=false;
    }
    
    return 1;
}
//-----------------------------------------------------------------------

async createThemeApex(){
    this.addAllConforTheme = false;  //added fixes of bug #00040888 by salauddin sheikh
    this.itemCount=0;
    if(this.themeName != undefined && this.themeName != null && this.themeName != ''){

    await this.serverDataMaking(); 
   
     createThemeRecord({addAllContactForEachFirm: this.createTeamIncludeAllContactsForEachFirm,themeNameValue: this.themeName,themedes: this.themeDescription, accountList : this.accIdListGlobal, contactList : this.conIdListGlobal, dealList : this.dealIdListGlobal, fundList : this.fundIdListGlobal, fundraisingList : this.fundRaisingIdListGlobal, themeList : this.themeIdListGlobal, clipList : this.clipIdListGlobal,interactionList : this.interactionIdListGlobal})
        .then((result) => {
            if(result != null && result != undefined){
                this.selectedRecord = result.themeId;   //added for bug #00041348, #00041295 fixes by salauddin sheikh
                //this.SelectedData=[];
                //this.themeName='';//Commented by LK on 2024-05-11 to fix 00045622 ; 00045698
                this.serverMessage = result.message; 
                console.log('server response ->'+this.serverMessage);
                if(this.serverMessage.indexOf("Error") != -1 ){
                    if(this.serverMessage.indexOf("Error") > 1){
                        
                        const evtErrss = new ShowToastEvent({
                            //Updated below title by LK on 2024-07-24 to fix 00046676
                            title: 'Success',//Removed "Toast Success" by LK on 2024-07-03 to fix 00046145
                            message: this.serverMessage.substring(0, this.serverMessage.indexOf("Error")),
                            variant: 'success',
                            mode: 'dismissable'
            
                        });
                        this.dispatchEvent(evtErrss);
                    }
                    const evtErr = new ShowToastEvent({
                        title: 'Toast Error',
                        message: this.serverMessage.substring(this.serverMessage.indexOf("Error")),
                        variant: 'error',
                        mode: 'sticky'
        
                    });
                    this.dispatchEvent(evtErr);
                }else{
                const evtSS = new ShowToastEvent({
                    //Updated below title by LK on 2024-07-24 to fix 00046676
                    title: 'Success',//Removed "Toast Success" by LK on 2024-07-03 to fix 00046145
                    message: this.serverMessage,
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evtSS);
                this.openAddContact();//Added by LK on 2024-07-02 to fix 00046360
            }
                
            }
            this.closeCreateRecord();// medium
        })
        .catch((error) => {
            this.SelectedData=[];
            this.themeName='';
            this.error = error;
            console.log( this.error);
            this.serverMessage = 'conflict occure at the server side-'+ this.error.message;
            const evt = new ShowToastEvent({
                title: 'Toast Error',
                message: this.serverMessage,
                variant: 'error',
                mode: 'sticky'

            });
            this.dispatchEvent(evt);
            this.closeCreateRecord(); //medium 
        });

}else{
    const evt = new ShowToastEvent({
      
        title: 'Toast Error',
        message: 'These required fields must be completed: Theme Name',
        
        variant: 'error',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
}
}
//------------------------------------------------------------------------------------------------------------------------------------------
async serverDataMaking(){
    var  wholeMapData=this.comingWholeMapData;
   
   // var relatedContactToAllAccount=this.createTeamIncludeAllContactsForEachFirm;
    var chooseData= this.SelectedData;
   
   /* if(chooseData.length < 1 || chooseData == undefined){
        const evt = new ShowToastEvent({
            title: 'Warning',
            message: 'Please Select any category',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        return 1;
    }*/
    var accIdList=[];
    var conIdList=[];
    var dealIdList=[];
    var fundIdList=[];
    var fundRaisingIdList=[];
    var clipIdList=[];
    var themeIdList=[];
    var interactionIdList=[];
    for(var i=0;i < chooseData.length; i++){
      var access1;
      var access2;
        switch (chooseData[i]['object']) {
            case 'Account': 
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
                access2 =wholeMapData[g]["allCategoriers"];
                console.log(access2);
                if(access1 == access2){
            
                      var listData=[];
                      listData=wholeMapData[g]['List'];
                        console.log(JSON.stringify(listData));
                      for(var j in listData){
               
                       let id=listData[j].Id;
                
                       accIdList.push(id);
                       }
            
                       g=wholeMapData.length;
                }
            }       
            this.accountIds = accIdList;
            console.log('accIdList--->'+accIdList);
            break;
            
            case 'Contact': 
            console.log('con');
           
            access1=chooseData[i]["allCategoriers"];
           console.log(access1);
          
           var g=0;
           for( g=0;g<wholeMapData.length;g++){
            access2 =wholeMapData[g]["allCategoriers"];
           console.log(access2);
           if(access1 == access2){
           
       var listData=[];
       listData=wholeMapData[g]['List'];
           console.log(JSON.stringify(listData));
           for(var j in listData){
              
               let id=listData[j].Id;
               
               conIdList.push(id);
           }
           
           g=wholeMapData.length;
           }
           }       
           console.log('conIdList --->'+conIdList);
          
          /*  for(j=0;j<wholeMapData[chooseData.allCategoriers]['List'].length;j++){
                let id=wholeMapData[chooseData.allCategoriers]['List'][j];
                conIdList.push(id);
            }*/
            break;
        
            case 'Pipeline__c' : 
            console.log('deal');
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
             access2 =wholeMapData[g]["allCategoriers"];
            console.log(access2);
            if(access1 == access2){
            
        var listData=[];
        listData=wholeMapData[g]['List'];
            console.log(JSON.stringify(listData));
            for(var j in listData){
               
                let id=listData[j].Id;
                
                dealIdList.push(id);
            }
            
            g=wholeMapData.length;
            }
            }       
            console.log('deal --->'+dealIdList);
            
            break;
            
            case 'Fund' : 
            console.log('fund');
            
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
             access2 =wholeMapData[g]["allCategoriers"];
            console.log(access2);
            if(access1 == access2){
            
        var listData=[];
        listData=wholeMapData[g]['List'];
            console.log(JSON.stringify(listData));
            for(var j in listData){
               
                let id=listData[j].Id;
                
                fundIdList.push(id);
            }
            
            g=wholeMapData.length;
            }
            }       
            console.log('fundIdList --->'+fundIdList);
            
            
            break;

            case 'Theme' : 
            console.log('theme');
          
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
             access2 =wholeMapData[g]["allCategoriers"];
            console.log(access2);
            if(access1 == access2){
            
        var listData=[];
        listData=wholeMapData[g]['List'];
            console.log(JSON.stringify(listData));
            for(var j in listData){
               
                let id=listData[j].Id;
                
                themeIdList.push(id);
            }
            
            g=wholeMapData.length;
            }
            }       
            console.log('themeIdList --->'+themeIdList);
            
            break;

            case 'Intraction' : 
            console.log('Intraction');
          
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
             access2 =wholeMapData[g]["allCategoriers"];
            console.log(access2);
            if(access1 == access2){
            
        var listData=[];
        listData=wholeMapData[g]['List'];
            console.log(JSON.stringify(listData));
            for(var j in listData){
               
                let id=listData[j].Id;
                
                interactionIdList.push(id);
            }
            
            g=wholeMapData.length;
            }
            }       
            console.log('interactionIdList --->'+interactionIdList);
            
            break;

            case 'Clip' : 
            console.log('clip');
            
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
             access2 =wholeMapData[g]["allCategoriers"];
            console.log(access2);
            if(access1 == access2){
            
        var listData=[];
        listData=wholeMapData[g]['List'];
            console.log(JSON.stringify(listData));
            for(var j in listData){
               
                let id=listData[j].Id;
                
                clipIdList.push(id);
            }
            
            g=wholeMapData.length;
            }
            }       
            console.log('clipIdList --->'+clipIdList);
            
            
            break;
            
            case 'FundRaising' : 
            console.log('FundRaising');
            
             access1=chooseData[i]["allCategoriers"];
            console.log(access1);
           
            var g=0;
            for( g=0;g<wholeMapData.length;g++){
             access2 =wholeMapData[g]["allCategoriers"];
            console.log(access2);
            if(access1 == access2){
            
        var listData=[];
        listData=wholeMapData[g]['List'];
            console.log(JSON.stringify(listData));
            for(var j in listData){
               
                let id=listData[j].Id;
                
                fundRaisingIdList.push(id);
            }
            
            g=wholeMapData.length;
            }
            }       
            console.log('fundRaisingIdList --->'+fundRaisingIdList);
            
            break;

            
         }

    }
    console.log('accId->'+accIdList);
    console.log('conIdList->'+conIdList);
    console.log('dealIdList->'+dealIdList);
    console.log('fundIdList->'+fundIdList);
    console.log('fundRaisingIdList->'+fundRaisingIdList);
    console.log('clipIdList->'+clipIdList);
    console.log('themeIdList->'+themeIdList);
    console.log('interactionIdList->'+interactionIdList);
     this.accIdListGlobal=accIdList;
     this.conIdListGlobal=conIdList;
     this.dealIdListGlobal=dealIdList;
     this.fundIdListGlobal=fundIdList;
     this.fundRaisingIdListGlobal=fundRaisingIdList;
     this.clipIdListGlobal=clipIdList;
     this.themeIdListGlobal=themeIdList;
     this.interactionIdListGlobal=interactionIdList;
     if (this.accIdListGlobal.length < 1 && this.conIdListGlobal.length < 1 && this.dealIdListGlobal.length < 1 && this.fundIdListGlobal.length < 1 && this.fundRaisingIdListGlobal.length < 1 && this.clipIdListGlobal.length < 1 && this.themeIdListGlobal.length < 1 && this.interactionIdListGlobal.length < 1){
        this.saveCheck = true;
    }
    else{
        this.saveCheck = false;
    }
    //Commented below code by LK on 2024-07-02 to fix 00046360
    /* Added below code by LK for the Add to Fund functionality - START */
    //start changes for account record have related contact then show new functionality by salauddin sheikh 6th july 2023
    // if(this.accIdListGlobal.length > 0){
    //     conFromAcc({accIdList:this.accIdListGlobal}).then(result =>{ 
    //         if(result == 'proceed' && (this.addFund || this.createFund)){
    //             this.isYesNoFund = true;
    //         }
    //         else if(result == 'proceed' && !this.addAllConforTheme){ //added fixes of bug #00040888 by salauddin sheikh
    //             this.isYesNo = true;
    //         }
    //         else{
    //             this.isYesNo = false;
    //             this.isYesNoFund = false;
    //         }
    //     }).catch(error =>{
    //         console.log(error);
    //     })
    // }
    //end changes for account record have related contact then show new functionality by salauddin sheikh 6th july 2023
    /* Added above code by LK for the Add to Fund functionality - END */
}
//----------------------------------------------------------------------------------------------------------------------------------------
AddtoThemeRecordApex(){
    this.itemCount=0;
    
    this.serverDataMaking();
   
    if( this.selectedRecord == undefined || this.selectedRecord == null || this.selectedRecord == ''){
    
       
        const evt = new ShowToastEvent({
           
            title: 'Error',
            message: 'These required fields must be completed: Theme Name',
            
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }else{
        
   
    if(this.accIdListGlobal.length < 1 && this.conIdListGlobal.length < 1 && this.dealIdListGlobal.length < 1 && this.fundIdListGlobal.length < 1 && this.fundRaisingIdListGlobal.length < 1 && this.clipIdListGlobal.length < 1 && this.themeIdListGlobal.length < 1 &&  this.interactionIdListGlobal.length < 1){
    
       
        const evt = new ShowToastEvent({
            
            title: 'Error',
            message: 'Select atleast a record',
            
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }else{
        
    addToThemeRecord({addAllContactForEachFirm: this.addToTeamIncludeAllContactsForEachFirm,themeIdValue: this.selectedRecord, accountList : this.accIdListGlobal, contactList : this.conIdListGlobal, dealList : this.dealIdListGlobal, fundList : this.fundIdListGlobal, fundraisingList : this.fundRaisingIdListGlobal, themeList : this.themeIdListGlobal, clipList : this.clipIdListGlobal,interactionList : this.interactionIdListGlobal})
        .then((result) => {
            if(result != null && result != undefined){
                //this.SelectedData=[];
                //this.selectedRecord ='';
                this.serverMessage = result; 
                if(this.serverMessage.indexOf("Error") != -1){
                    if(this.serverMessage.indexOf("Error") > 1){
                        
                        const evtErrss = new ShowToastEvent({
                            //Updated title by LK on 2024-07-24 to fix 00046683 ; 00046707
                            title: 'Success',//Removed "Toast Success" by LK on 2024-07-03 to fix 00046145
                            message: this.serverMessage.substring(this.serverMessage.indexOf("Error")),
                            variant: 'success',
                            mode: 'dismissable'
            
                        });
                        this.dispatchEvent(evtErrss);
                    }
                    
                    const evtErr = new ShowToastEvent({
                        title: 'Toast Error',
                        message: this.serverMessage.substring(this.serverMessage.indexOf("Error")),
                        variant: 'error',
                        mode: 'sticky'
        
                    });
                    this.dispatchEvent(evtErr);
                }else{
                    //Added if clause and moved existing code inside else clause by LK on 2024-05-11 to fix 00045631
                    if(this.serverMessage === 'Record(s) already associated with this Theme. Please select different theme or related records to proceed.'){
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: (this.serverMessage === 'Record(s) was associated with the Theme.' && this.buttonClickedName === 'Add All Contacts') ? 'All Contacts were associated with the Theme.' : this.serverMessage,//Updated by LK on 2024-05-11 to fix 00045609
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(evt);
                    } else {
                        const evtSS = new ShowToastEvent({
                            //Updated title by LK on 2024-07-24 to fix 00046683 ; 00046707
                            title: 'Success',//Removed "Toast Success" by LK on 2024-07-03 to fix 00046145
                            message: (this.serverMessage === 'Record(s) was associated with the Theme.' && this.buttonClickedName === 'Add All Contacts') ? 'All Contacts were associated with the Theme.' : this.serverMessage,//Updated by LK on 2024-05-11 to fix 00045609
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evtSS);
                        this.openAddContact();//Added by LK on 2024-07-02 to fix 00046360
                    }
                }
            }
            this.closeAddTo(); // medium
        })
        .catch((error) => {
            this.SelectedData=[];
            this.selectedRecord ='';
            this.error = error;
            this.serverMessage = 'Conflict occurred at the server side: '+this.error.message;
            console.log('error -> '+JSON.stringify(error));
            const evt = new ShowToastEvent({
                title: 'Toast Error',
                message: this.serverMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.closeAddTo(); //medium
        });
    }
}

}
//----------------------------------------------------------------------------------------------------------------------------------------
setThemeName(event){
    this.themeName =  event.detail.value;
    this.btnDisableCheck();//Added by LK on 2024-05-20 to fix 00045915
    console.log(this.themeName);
}
setThemeDescription(event){
    this.themeDescription =  event.detail.value;
    console.log(this.themeDescription);
}

//---------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------- 
handleClick() {
        this.isSelected = !this.isSelected;
    }
    navigateToThemespop(){
        this.isAddTo = true; // updated ui 15 nov
    }
    closealladdpop(){
        this.AddAllPop = false;
    }
    closeExport(){
        this.AddAllPop = false;
    }
   
    connectedCallback() {
        // ui fix for lookup 10feb
        if(this.mainSearchfromFund){ //bug #00040887 fixes by salauddin sheikh
            this.mainSearch = false;
        }
        /* Added below code by LK for the Add to Fund functionality - START */
        this.paccountLabel = this.pluralLabelMap['Account'];
        //for dynamic label change by salauddin sheikh 5th july 2023
        this.pcontactLabel = this.pluralLabelMap['Contact'];
        this.pthemeLabel = this.pluralLabelMap['navpeII_dev18__Theme__c'];
        this.pfundLabel = this.pluralLabelMap['navpeII_dev18__Fund__c'];
        this.pfdrLabel = this.pluralLabelMap['navpeII_dev18__Fundraising__c'];
        this.contactLabel = this.objectLabelMap['Contact'];
        this.accountLabel = this.objectLabelMap['Account'];
        this.themeLabel = this.objectLabelMap['navpeII_dev18__Theme__c'];
        this.fundLabel = this.objectLabelMap['navpeII_dev18__Fund__c'];
        this.fdrLabel = this.objectLabelMap['navpeII_dev18__Fundraising__c']
        //Replaced "'Select ' +this.paccountLabel + ' for ' + this.pfdrLabel + ' with this ' + this.fundLabel" with 'All Categories' by LK on 2024-05-11 to fix 00045696 ; 00045694 ; 00045690
        this.columnsCatogryFund.push({ label: 'All Categories', type: 'text', fieldName: 'allCategoriers', hideDefaultActions: true, cellAttributes: { class: 'slds-text-body_regular textColor' } },);
        /* Added above code by LK for the Add to Fund functionality - END */

        // ui fix for lookup 10feb
        this.template.addEventListener("click",event=>{
            console.log(event.target.className,"jtext");
            if(!event.target.closest('.addtothemelookup')){
                console.log("lookupmethod")
                this.template.querySelector('c-navatar-research-single-lookup-lwc').lookupmethod()

            }
        });
// ui fix 10 feb
this.objApiNamesListTab1=[];
this.objOptionList.filter((currentValue) => { if(currentValue.value != 'navpeII_dev18__Theme__c'){this.objApiNamesListTab1.push(currentValue.value)}});
       // alert(this.objApiNamesListTab1 );
        this.saveButtonDisable=false;
        this.advanceSearch=true;
        if(this.themeProcessCheck){
            this.advanceSearch = true;
            this.isCreateRecord=false;
            this.isExport=false;
            this.mainSearchfromTheme=true;
            this.mainSearch=false;
            this.selectedRecord=this.themeIdComingFromThemePageFunctionality;
            this.themeIdComingFromThemePage=this.themeIdComingFromThemePageFunctionality;
            
            

        }
        this.comingSelectionTabelData=this.comingSelectionTabelDataFirstCmp;
    this.comingWholeMapData=this.comingWholeMapDataFirstCmp;
        if(this.currObj == 'navpeII_dev18__Theme__c'){
            this.themeIdComingFromThemePage = this.currId;
            this.selectedRecord=this.currId;
        }
        console.log("XXXX1");
        this.initData();
        console.log("XXXX2");
        console.log("propertyValue", this.searchKeyword);
        console.log("advanceSearch", this.advanceSearch);
        
        //alert(this.advancePop);
       if(this.advancePop == true || this.themeProcessCheck == true){
        this.advanceSearch = true;
        //alert('KING & QUEEN');
            console.log('KING & QUEEN');
            this.timeoutId = setTimeout(this.delayFunction.bind(this), 1000);
            console.log('SUPER & HARD');
            
        }else{
           
            this.advanceSearch = this.advancePop;
        }
      
        if(this.propertyValue != undefined && this.propertyValue != null){
            
            this.mainSearchfromTheme = true;
            this.mainSearch = true;
        } 
        console.log("tab data ", JSON.stringify(this.comingSelectionTabelData));

    this.dataCatogry=this.comingSelectionTabelData;
    console.log('data catogry-->'+JSON.stringify(this.dataCatogry));
    //Uncommented the below for loop by LK on 2024-05-08 to fix 00045451
    for(var i=0;i<this.dataCatogry.length;i++){
        this.selectedRows.push(this.dataCatogry[i].id);
       }
       this.SelectedData=[...this.dataCatogry];
    /*this.dataCatogryForInternalPart = this.comingSelectionTabelData.filter((Data) => {
        let storeValueInString=Data.object.toString();
        return (Data.object != 'Intraction' && storeValueInString.indexOf("Tagged") == -1)});*/
    this.dataCatogryForInternalPart = this.comingSelectionTabelData.filter((Data) => {
        let storeValueInString=Data.object.toString();
            return (storeValueInString.indexOf("Tagged") == -1)});
    } 
    delayFunction(){
        this.template.querySelector('.inner-custom-mechanish').classList.remove('hidediv');
        this.template.querySelector('.inner-custom-mechanish').classList.add('displaydiv');
        //this.timeoutId3 = setTimeout(this.delayFunctionThemeBind.bind(this), 4000); 
        //this.advanceSearch = this.advancePop;
    }
    
   
    
    initData() {
       
        let listOfAccountsPara = [];
       
        this.createRowpara(listOfAccountsPara);
        this.listOfAccountsPara = listOfAccountsPara;
        //this.listOfAccountsPara = listOfAccountsPara;
    }

   
    
    createRowpara(listOfAccountsPara) {
        let accountObjectp = {};
        if(listOfAccountsPara.length > 0) {
            accountObjectp.index = listOfAccountsPara[listOfAccountsPara.length - 1].index + 1;
        } else {
            accountObjectp.index = 1;
        }
        if( accountObjectp.index == 1){
            accountObjectp.hideBtnpara = false;
        }else{
            accountObjectp.hideBtnpara = true;
        }
        listOfAccountsPara.push(accountObjectp);
    }
    
    addNewRowpara() {
        this.createRowpara(this.listOfAccountsPara);
    }
    removeRow(event) {
        let bgWhite = event.target.closest('.dnone')
        bgWhite.classList.add('d_none');
        console.log(this.listOfLookupRecGlobal.length );
        if(this.listOfLookupRecGlobal.length > 1){
           console.log(event.currentTarget.dataset.index);
            for(var i=0;i<this.listOfLookupRecGlobal.length-1;i++){
                this.listOfLookupRecGlobal[event.currentTarget.dataset.index]=this.listOfLookupRecGlobal[event.currentTarget.dataset.index + 1 + i];
            }
        this.listOfLookupRecGlobal.pop();
        }
        
        if(this.listOfLookupRecPara.length > 1){
            this.listOfLookupRecPara.pop();
            }
    }




    closeAdvance(){
        this.advanceSearch = false;
        this.template.querySelector('.inner-custom-mechanish').classList.remove('displaydiv');
        this.template.querySelector('.inner-custom-mechanish').classList.add('hidediv');
        
    }
    isExpandCollapseLink(){
        this.advanceSearch = true;
        this.template.querySelector('.inner-custom-mechanish').classList.remove('hidediv');
        this.template.querySelector('.inner-custom-mechanish').classList.add('displaydiv');
        
  
        }




    
        value = 'deal';
    
        get options1() {
            return [
                { label: 'Firm', value: 'Firm' },
                { label: 'Contact', value: 'Contact' },
                { label: 'Deal', value: 'Deal' },
                { label: 'Theme', value: 'Theme' },
            ];
        }
        get optionsOperator() {
            return [
                { label: 'Equal', value: 'Equal' },
                { label: 'Not Equal', value: 'Not Equal' },
                { label: 'Greater', value: 'Greater' },
                { label: 'Smaller', value: 'Smaller' },
            ];
        }
        
    
        myDropDownMethod(){
            const element = this.template.querySelector('[data-id="myDropDownBoxId"]');
            element.classList.add("slds-is-open");
        }
    
        onListClick(){
            const element = this.template.querySelector('[data-id="myDropDownBoxId"]'); 
            element.classList.remove("slds-is-open");
        }
    
        isAddTo = false;
        isCreateRecord = false;
        isExport = false;
        isRange = false;
        openRangePop(){
            this.isRange = true;
        }
        closeRange(){
            this.isRange = false;
        }
        onHandleAddTo(){
            this.showCheckBoxForAllContactsForEachFirm=false;
            console.log(JSON.stringify(this.comingWholeMapData));
            var comingData=this.comingWholeMapData;
            var filterObj = comingData.filter((Data) => Data.object == 'Account');
            console.log('@@->'+JSON.stringify(filterObj));
            if(filterObj != '' && filterObj.length > 0){
            
             this.showCheckBoxForAllContactsForEachFirm=true;
            }
            this.isAddTo = true;
            this.isCollapse = true;
            this.isExpand = false;
            this.isExpandCollapseBox = false;
            //Added below code by LK on 2024-05-08 to fix 00045348
            this.itemCount = this.dataCatogryForInternalPart.length;
            this.btnDisableCheck2();
              // to open modal set isModalOpen tarck value as true
              /*setTimeout(() => {
     
                let sectmodal = this.template.querySelector(".slds-modal");
                let bodyClose = sectmodal.closest('body');
                bodyClose.style.overflow = "hidden";
                console.log(bodyClose,'bodyClose');
    
            }, 0);*/
            
        }
    
        closeAddTo(){
            this.buttonClickedName = '';//Added by LK on 2024-05-11 to fix 00045609
            this.isAddTo = false;
            /*let sectmodal = this.template.querySelector(".slds-modal");
            let bodyClose = sectmodal.closest('body');
            bodyClose.style.overflow = "auto";
            console.log(bodyClose,'bodyClose');*/
            //this.SelectedData=[];
            /* Added below code by LK for the Add to Fund functionality - START */
            //this.accountIds = []; //for bug #00040426 fixes by Salauddin Sheikh
            this.saveCheck = true;
            this.createCheck = true;
            this.itemCount = 0; //bug #00041191 , #00041189 fixes by salauddin sheikh
            //this.themeName = ""; //Commented by LK on 2024-05-11 to fix 00045622 ; 00045698
            /* Added above code by LK for the Add to Fund functionality - END */
        }
    
        onHnadleCreate(){
            //Added below code by LK on 2024-03-18 for PE Phase 3.2 - START
            if(this.isFundAccessible && this.isThemeAccessible){
                this.isCreateNew = true;
            } else if(this.isThemeAccessible){
                this.isCreateRecord = true;
                this.isCreateNew = false;
                this.itemCount = this.SelectedData.length;//Added by LK on 2024-05-15 to fix 00045601
            } else if(this.isFundAccessible){
                this.createFund = true;
                this.isAddNewFund = true;
                this.addFund = false;
                this.isCreateNew = false;
                this.filterAccRecList();
            } else {
                //Updated toast msg by LK on 2024-05-14 to fix 00045529
                this.showToast(this, 'Error!', this.noAccessToastMsg, 'error');
            }
            //Added above code by LK on 2024-03-18 for PE Phase 3.2 - END
            this.themeName = "";    //added fixes for bug #00042303 by salauddin sheikh
            //bug #00041194 fixes by salauddin sheikh
            this.isExpand =  true;
            this.isCollapse = false;
            this.isExpandCollapseBox = true;

            this.showCheckBoxForAllContactsForEachFirm=false;
            console.log(JSON.stringify(this.comingWholeMapData));
            var comingData=this.comingWholeMapData;
            var filterObj = comingData.filter((Data) => Data.object == 'Account');
            console.log('@@->'+JSON.stringify(filterObj));
            if(filterObj != '' && filterObj.length > 0){
           
             this.showCheckBoxForAllContactsForEachFirm=true;
            }
            //this.isCollapse = true;
            //this.isExpand = false;
            //this.isExpandCollapseBox = false;
            //this.isCreateRecord = true;
             // to open modal set isModalOpen tarck value as true
             /*setTimeout(() => {
     
                let sectmodal = this.template.querySelector(".slds-modal");
                let bodyClose = sectmodal.closest('body');
                bodyClose.style.overflow = "hidden";
                console.log(bodyClose,'bodyClose');
    
            }, 0);*/
        }
        /* Added below code by LK for the Add to Fund functionality - START */
        closeCreateNew() {
            this.isCreateNew = false;
            this.saveCheck = true;
            this.createCheck = true;
        }
        handleChangeCreate(event) {
            const selectedOption = event.detail.value;
        }
        createNext() {
            let createoptionValues = this.template.querySelector('.createOption').value;
    
            if (createoptionValues === "theme") {
                this.isCreateRecord = true;
                this.isCreateNew = false;
                this.itemCount = this.SelectedData.length;//Added by LK on 2024-05-15 to fix 00045601
                //Added below 2 lines by LK on 2024-05-13 to fix 00045610
                this.createFund = false;
                this.addFund = false;
            } else if (createoptionValues === "fund") {
                this.createFund = true;
                this.addFund = false;
                this.isAddNewFund = true;
                this.isCreateNew = false;
                this.filterAccRecList();
            }
        }
        filterAccRecList(){
            var wholeMapData = this.comingWholeMapData;
            var chooseData = this.accountRecordTypeList; 
            this.availableAccRecList = [];
            for (var i = 0; i < chooseData.length; i++) {
                var access1;
                var access2;
                switch (chooseData[i]['object']) {
                    case 'Account':
                        access1 = chooseData[i]["allCategoriers"];
                        var g = 0;
                        for (g = 0; g < wholeMapData.length; g++) {
                            access2 = wholeMapData[g]["allCategoriers"];
                            if (access1 == access2) {
                                this.availableAccRecList.push(chooseData[i]);
                            }
                        }
                        break;
                }
            }
            this.availableAccRecList.sort((a, b) => a.allCategoriers.localeCompare(b.allCategoriers));   // added for bug #00041422 fixes by salauddin sheikhs
            //Added for loop, SelectedData, itemCount & fundSelectedAccRecType by LK on 2024-05-17 to fix 00045908
            for(let i=0; i<this.availableAccRecList.length; i++){
                this.selectedRows.push(this.availableAccRecList[i].id);
            }
            this.SelectedData = [...this.availableAccRecList];
            this.itemCount = this.selectedRows.length;
            this.fundSelectedAccRecType = [...this.availableAccRecList];
        }
        btnDisableCheck(){  //for Ui fixes by salauddin sheikh
            //console.log('in btnDisableCheck--->'+this.itemCount+'==='+this.themeName);
            if(this.itemCount > 0 && (this.themeName != null && this.themeName != undefined && this.themeName != '')){
                this.saveCheck = false;
            }
            else{
                this.saveCheck = true;
            }
        }
        closeAddNewFund() {
            this.isAddNewFund = false;
            this.isCollapse = false;
            this.isExpand = false;
            //this.isExpandCollapseBox = false;     //commented for bug #40429 fixes by Salauddin Sheikh
            this.fundName = ''; // for bug #40428 fixes by Salauddin Sheikh
            this.saveCheck = true;
            this.createCheck = true;
            this.createdFundId = '';
            this.itemCount = 0;
            this.selectedRecordTypeID = this.defaultFundRcType;
        }
        
        onHandleAdd() {
            //Added below code by LK on 2024-03-18 for PE Phase 3.2 - START
            if(this.isFundAccessible && this.isThemeAccessible){
                this.isAddNew = true;
            } else if(this.isThemeAccessible){
                this.isAddTo = true;
                this.isAddNew = false;
                this.itemCount = this.SelectedData.length;//Added by LK on 2024-05-15 to fix 00045600
            } else if(this.isFundAccessible){
                this.addFund = true;
                this.isAddNewFund = true;
                this.createFund = false;
                this.isCreateNew = false;
                this.isAddNew = false;
                this.filterAccRecList();
            } else {
                //Updated toast msg by LK on 2024-05-14 to fix 00045529
                this.showToast(this, 'Error!', this.noAccessToastMsg, 'error');
            }
            //Added above code by LK on 2024-03-18 for PE Phase 3.2 - END
            this.themeName = ""; //added fixes for bug #00042303 by salauddin sheikh
            //bug #00041194 fixes by salauddi sheikh
            this.isExpand = true;
            this.isCollapse = false;
            this.isExpandCollapseBox = true;
        }
        closeAddeNew() {
            this.isAddNew = false;
            this.saveCheck = true;
            this.createCheck = true;
        }
        handleChangeAdd(event) {
            const selectedOption = event.detail.value;
        }
        addNext() {
            let addoptionValues = this.template.querySelector('.addOption').value;
            
            if (addoptionValues === "theme") {
                this.isAddTo = true;
                this.isAddNew = false;
                //Added below 2 lines by LK on 2024-05-13 to fix 00045610
                this.createFund = false;
                this.addFund = false;
                this.itemCount = this.SelectedData.length;//Added by LK on 2024-05-15 to fix 00045600
            } else if (addoptionValues === "fund") {
                this.addFund = true;
                this.createFund = false;
                this.isAddNewFund = true;
                this.isAddNew = false;
                this.filterAccRecList();
            }
        }
        handleChangeFundName(event) {
            this.fundName = event.detail.value;
            this.btnDisableCheck1();    //for Ui fixes by salauddin sheikh
        }
        getSelectedRec() {
            var selectedRecords = this.template.querySelector("lightning-datatable")?.getSelectedRows();//Added by LK on 2024-10-01 to fix 00047535
            this.fundSelectedAccRecType = selectedRecords;
            this.itemCount = selectedRecords.length;
            if (selectedRecords.length > 0) {
                let optionsValues = [];
                for (let i = 0; i < selectedRecords.length; i++) {
                    optionsValues.push(selectedRecords[i].allCategoriers);
                }
                if (optionsValues.includes('Firms')) {
                    this.SelectedData = this.accountRecordTypeList;
                } else {
                    this.SelectedData = selectedRecords;
                }
            }
            this.btnDisableCheck1();    //for Ui fixes by salauddin sheikh
        }
        btnDisableCheck1(){     //for Ui fixes by salauddin sheikh
            if (this.createFund== true && this.itemCount > 0 && (this.fundName != null && this.fundName != undefined && this.fundName != '' && this.selectedFundType !== '' && this.selectedInvCategory !== '')) {
                this.createCheck = false;
            }
            else if(this.itemCount > 0 && (this.createdFundId != null && this.createdFundId != undefined && this.createdFundId != '')){
                this.saveCheck = false;
            }
            else{
                this.saveCheck = true;
                this.createCheck = true;
            }
        }
        @wire(getObjectInfo, { objectApiName: FUND_INFO}) 
        fundRecord;
        @wire(getPicklistValues, {recordTypeId: '$fundRecord.data.defaultRecordTypeId', fieldApiName: FUND_TYPE_FIELD})
        fundTypePicklist({ data, error }) {
            if(data){
                this.fundTypeOptns = data.values;
                this.fundTypeLabel = this.fundRecord['data']['fields']['navpeII_dev18__Fund_Type__c']['label'];
            } else if(error){
                this.showToast(this, 'Error!', error.body.message, 'error');
            }
        }
        @wire(getPicklistValues, {recordTypeId: '$fundRecord.data.defaultRecordTypeId', fieldApiName: INVESTMENT_CATEGORY_FIELD})
        invCategoryPicklist({ data, error }) {
            if(data){
                this.invCategoryOptnsComplete = data.values;
                this.invCategoryLabel = this.fundRecord['data']['fields']['navpeII_dev18__Investment_Category__c']['label'];
            } else if(error){
                this.showToast(this, 'Error!', error.body.message, 'error');
            }
        }

        //Added below code by LK on 2024-04-11 to fix 00044462, 00044460
        @wire(fetchAllowedAccRecTypeList)
        fetchAllowedAccRecTypeList({ error, data }) {
            if(data){
                if(data != null){
                    let optionsValues = [];
                    let optionsNames = [];
                    
                    const rtInfos = data;
                    let rtValues = Object.values(rtInfos);
                    for (let i = 0; i < rtValues.length; i++) {
                        optionsNames.push(rtValues[i].name);
                        optionsValues.push({
                            allCategoriers: rtValues[i].name,
                            id: rtValues[i].recTypeId,
                            object : 'Account'
                        })
                    }
                    this.accountRecordTypeList = optionsValues;
                    this.accountRecordTypeNameList = optionsNames;
                }
            } else if(error){
                this.showToast(this, 'Error!', error.body.message, 'error');
            }
        }

        handleChangeFundType(event){
            this.selectedFundType = event.detail.value;
            this.invCategoryOptns = this.fundTypeVsInvCategoryMapping.get(this.selectedFundType);
            this.btnDisableCheck1();//Added by LK on 2024-05-17 to fix 00045908
        }
        handleChangeInvCategory(event){
            this.selectedInvCategory = event.detail.value;
            this.btnDisableCheck1();//Added by LK on 2024-05-17 to fix 00045908 ; 00045914
        }
        handleChangeRecordTypeID(event) {
            this.selectedRecordTypeID = event.detail.value;
        }

        createFundAndFdr(event) {
            if(this.fundName =='' || this.fundName == undefined){
                const evt = new ShowToastEvent({
                    title: 'Required Field Missing',
                    message: 'Please enter Fund Name',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.saveCheck = true;
                return;
            }
       
            if(this.selectedFundType === '' ){ // for bug #00041944 fixes by salauddin sheikh
                const evt = new ShowToastEvent({
                    title: '', 
                    message: 'These required fields must be completed: '+ this.fundTypeLabel, // change message for bug #00042364 fixes by salauddin sheikh
                    variant: 'error',
        
                });
                this.dispatchEvent(evt);
                this.saveCheck = true;
                return
            }

            if(this.selectedInvCategory === '' ){ // for bug #00041944 fixes by salauddin sheikh
                const evt = new ShowToastEvent({
                    title: '', 
                    message: 'These required fields must be completed: '+ this.invCategoryLabel, // change message for bug #00042364 fixes by salauddin sheikh
                    variant: 'error',
        
                });
                this.dispatchEvent(evt);
                this.saveCheck = true;
                return
            }
            this.createFundRecord();
        }
        addToFundAndFdr() {
            if(this.createdFundId =='' || this.createdFundId == undefined){
                const evt = new ShowToastEvent({
                    title: 'Required Field Missing',
                    message: 'Please select Fund',
                    variant: 'error',
        
                });
                this.dispatchEvent(evt);
                this.saveCheck = true;
                return;
            }
            
    
            if (this.fundSelectedAccRecType.length > 0) {
                this.serverDataMaking();
                let optionsValues = [];
                for (let i = 0; i < this.fundSelectedAccRecType.length; i++) {
                    optionsValues.push(this.fundSelectedAccRecType[i].allCategoriers);
                }
                let finalAccRecList = [];
                let accRecordTypeList = this.accountRecordTypeNameList;
                if (optionsValues.includes('Firms')) {
                    const index = accRecordTypeList.indexOf('Firms');
                    if (index > -1) {
                        accRecordTypeList.splice(index, 1);
                    }
                    finalAccRecList = accRecordTypeList;
                } else {
                    finalAccRecList = optionsValues;
                }
                addToFundFdr({ "fundId": this.createdFundId, "fundName": this.fundName, "accList": JSON.stringify(this.accIdListGlobal)}).then(data => {
                    if(data === 'success'){
                        const evt = new ShowToastEvent({     //bug #00041338 fixes by salauddin sheikh
                            title: 'Success', //Added by LK on 2024-09-25 to fix 00047448
                            //'Fund ' + this.fundName + ' was created & selected Firm(s) was associated as Fundraising(s) with the Fund'
                            //Updated 'message' by LK on 2024-05-17 to fix 00045909 ; 2024-10-21 to fix 00047448
                            //Removed "(s)" by LK on 2024-07-03 to fix 00046303
                            message: `Selected ${this.accountLabel}(s) was associated as ${this.fdrLabel} with the ${this.fundLabel}.`,
                            variant : 'success',
                        });
                        this.dispatchEvent(evt);
                       // this.isExpandCollapseBox = false; //commented for bug #40429 fixes by Salauddin Sheikh
                    } else if(data === 'failure') {
                        this.showToast(this, 'Error!', 'All records failed to insert', 'error');
                    } else {
                        this.showToast(this, 'Error!', data, 'error');
                    }
                    this.isAddNewFund = false;
                    this.isCreateRecord = false;
                    this.isAddTo = false;
                    this.isCollapse = true;
                    this.isExpand = false;
                    this.openAddContact();//Added by LK on 2024-07-02 to fix 00046360
                }).catch(error => {
                    console.log(error);
                });
            }else{
                this.isYesNoFund = false;
                this.isAddNewFund = false;
                this.isCreateRecord = false;
                this.isAddTo = false;
                this.isCollapse = true;
                this.isExpand = false;
               // this.isExpandCollapseBox = false; //commented for bug #40429 fixes by Salauddin Sheikh
            }
        }

        createFundRecord(){
            let fundRec = {Name: this.fundName, navpeII_dev18__Fund_Type__c: this.selectedFundType, navpeII_dev18__Investment_Category__c: this.selectedInvCategory};
            if(this.fundRecTypeExists){
                fundRec.RecordTypeId = this.selectedRecordTypeID;
            }
            createFund({ "fundRec": JSON.stringify(fundRec) }).then(data => {
                this.createdFundId = data;
                //Commented below ccode by LK on 2024-05-20 to fix 00045917
                /*const evt = new ShowToastEvent({
                // title: 'Fund Created',
                    message: 'Fund '+this.fundName+' was created',
                    variant: 'success',
        
                });
                this.dispatchEvent(evt);*/
                this.handleSuccess();
            }).catch(error => {
                this.showToast(this, 'Error!', error.body.message, 'error');
            });
        }

        handleSuccess(event) {
            if (this.fundSelectedAccRecType.length > 0) {
                this.serverDataMaking();
                let optionsValues = [];
                for (let i = 0; i < this.fundSelectedAccRecType.length; i++) {
                    optionsValues.push(this.fundSelectedAccRecType[i].allCategoriers);
                }
                let finalAccRecList = [];
                let accRecordTypeList = this.accountRecordTypeNameList;
                if (optionsValues.includes('Firms')) {
                    const index = accRecordTypeList.indexOf('Firms');
                    if (index > -1) {
                        accRecordTypeList.splice(index, 1);
                    }
                    finalAccRecList = accRecordTypeList;
                } else {
                    finalAccRecList = optionsValues;
                }
                createFdr({ "fundId": this.createdFundId, "fundName": this.fundName, "accList": JSON.stringify(this.accIdListGlobal)}).then(data => {
                    if(data === 'success'){
                        const evt = new ShowToastEvent({
                            title: 'Success', //Added by LK on 2024-09-25 to fix 00047449
                            //Added double quotes & updated text t oinclude dynamic label of objects by LK on 2024-06-11 to fix 00046044
                            //Removed "(s)" from msg by LK on 2024-07-03 to fix 00046303
                            //Msg updated by LK on 2024-10-21 to fix 00047448 ; 00047449
                            message: `${this.fundLabel} "${this.fundName}" was created & selected ${this.accountLabel}(s) was associated as ${this.fdrLabel} with the ${this.fundLabel}.`,
                            variant: 'success',
                
                        });
                        this.dispatchEvent(evt);
                        this.isAddNewFund = false;
                        this.isCreateRecord = false;
                        this.isAddTo = false;
                        this.isCollapse = true;
                        this.isExpand = false;
                        //this.isExpandCollapseBox = false; //commented for bug #40429 fixes by Salauddin Sheikh
                        this.saveCheck = true;
                        this.fundName = ''; //for bug #00041951 fixes by salauddin sheikh
                        this.selectedRecordTypeID = this.defaultFundRcType;//for bug #00041951 fixes by salauddin sheikh
                        this.createCheck = true;//Added by LK on 2024-05-20 to fix 00045915
                        this.itemCount = 0;//Added by LK on 2024-05-20 to fix 00045915
                        this.openAddContact();//Added by LK on 2024-07-02 to fix 00046360
                    } else if(data === 'failure') {
                        this.showToast(this, 'Error!', 'All records failed to insert', 'error');
                    } else {
                        this.showToast(this, 'Error!', data, 'error');
                    }
                }).catch(error => {
                    console.log(error);
                    this.dispatchEvent(evt1);
                });
            }else{
                this.isYesNoFund = false;
                this.isAddNewFund = false;
                this.isCreateRecord = false;
                this.isAddTo = false;
                this.isCollapse = true;
                this.isExpand = false;
              //  this.isExpandCollapseBox = false; //commented for bug #40429 fixes by Salauddin Sheikh
                this.saveCheck = true;
            }
        }
        //Added below method by LK on 2024-07-02 to fix 00046360
        openAddContact(){
            if(this.accIdListGlobal.length > 0){
                conFromAcc({accIdList:this.accIdListGlobal}).then(result =>{ 
                    if(result == 'proceed' && (this.addFund || this.createFund)){
                        this.isYesNoFund = true;
                    }
                    else if(result == 'proceed' && !this.addAllConforTheme){ //added fixes of bug #00040888 by salauddin sheikh
                        this.isYesNo = true;
                    }
                    else{
                        this.isYesNo = false;
                        this.isYesNoFund = false;
                    }
                }).catch(error =>{
                    console.log(error);
                })
            }
        }

        /* Displays toast message */
        showToast(cmp, title, message, variant){
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: variant === 'error' ? 'sticky' : 'dismissible'
            });
            cmp.dispatchEvent(event);
        }
        handleSelectedFundRecord(event) {
            //this.selectedRecord=event.detail.data.Id;
            let selectedFundRecord = JSON.parse(event.detail);
            this.createdFundId = selectedFundRecord.data.Id;
            this.selectedRecord=this.createdFundId;
            this.fundName = selectedFundRecord.data.Name;
            this.btnDisableCheck1();    //for Ui fixes by salauddin sheikh
        }

        closeYesNo(event) {
 
            this.isYesNo = false;
            this.isYesNoFund = false;
            this.isCollapse = true;
            this.isExpand = false;
            this.accountIds = [];  //for bug #00040426 fixes by Salauddin Sheikh
            //this.isExpandCollapseBox = false; //commented for bug #40429 , #40424 fixes by Salauddin Sheikh
            this.saveCheck = true;
            this.createCheck = true;
            this.fundName = '';
            this.selectedRecordTypeID = this.defaultFundRcType;
            this.createdFundId = '';//Added by LK on 2024-05-20 to fix 00045915
        }

        addAllContactsFund(){
            let optionsValues = [];
            for (let i = 0; i < this.fundSelectedAccRecType.length; i++) {
                optionsValues.push(this.fundSelectedAccRecType[i].allCategoriers);
            }
            let finalAccRecList = [];
            let accRecordTypeList = this.accountRecordTypeNameList;
            if (optionsValues.includes('Firms')) {
                const index = accRecordTypeList.indexOf('Firms');
                if (index > -1) {
                    accRecordTypeList.splice(index, 1);
                }
                finalAccRecList = accRecordTypeList;
            } else {
                finalAccRecList = optionsValues;
            }
            
            createFdrCon({ "fundId": this.createdFundId, "accList": JSON.stringify(this.accIdListGlobal)}).then(data => {       
                if(data === 'success'){
                    const evt = new ShowToastEvent({
                        //Added title by LK on 2024-07-24 to fix 00046701
                        title: 'Success',
                        //'All contacts were successfully added to your Fundraising.'
                        //Updated 'message' by LK on 2024-05-17 ; 2024-08-22 to fix 00045910 ; 2024-10-21 to fix 00046701 ; 00045910
                        message: `All ${this.pcontactLabel} were associated with the ${this.fundLabel} as ${this.fdrConRecord['data']['labelPlural']}.`,    //bug #00042083 modified message by salauddin
                        variant: 'success',
            
                    });
                    this.dispatchEvent(evt);
                    this.isAddNewFund = false;
                    this.isCreateRecord = false;
                    this.isAddTo = false;
                    this.saveCheck = true;
                    this.closeYesNo();
                } else if(data === 'failure') {
                    this.showToast(this, 'Error!', 'All records failed to insert', 'error');
                } else {
                    this.showToast(this, 'Error!', data, 'error');
                }
            }).catch(error => {
                console.log(error);
            });
        }

        yesContact() {
            this.isYesNo = false;
            if (this.accountIds.length > 0) {
                var compDefinition = {
                    componentDef: "navpeII_dev18:navatarAddContactsLwc",
                    attributes: {
                        propertyValue: "100",
                        accountData: this.accountIds,
                        themeId: this.selectedRecord,   //change for bug #00041970 fixes by salauddin sheikh
                        themeName: this.themeName,
                        addToTeamIncludeAllContactsForEachFirm: this.addToTeamIncludeAllContactsForEachFirm,
                        isThemeCreating: this.createThemeFlag,
                        fundId : this.createdFundId,
                        source : 'theme',
                        objectPluMap: this.pluralLabelMap,
                        objectLabelMap1: this.objectLabelMap,
                    }
                };
    
                var encodedCompDef = btoa(JSON.stringify(compDefinition));
                // this[NavigationMixin.GenerateUrl]({  //commenting for bug #00042085 fixes by salauddin sheikh
                //     type: 'standard__webPage',
                //     attributes: {
                //         url: '/one/one.app#' + encodedCompDef
                //     }
                // }).then(generatedUrl => {
                //     window.open(generatedUrl, "_blank");
                // });
                var url = '/one/one.app#' + encodedCompDef; //added for bug #00042085 fixes by salauddin sheikh
                window.open(url, '_blank');
            }
            else {
                this.AddtoThemeRecordApex()
            }
        }

        yesContactFund() {
            this.isYesNoFund = false;
         
            if (this.accountIds.length > 0) {
                var compDefinition = {
                    componentDef: "navpeII_dev18:navatarAddContactsLwc",
                    attributes: {
                        propertyValue: "100",
                        accountData: this.accountIds,
                        themeId: this.selectedRecord,
                        themeName: this.themeName,
                        addToTeamIncludeAllContactsForEachFirm: this.addToTeamIncludeAllContactsForEachFirm,
                        isThemeCreating: this.createThemeFlag,
                        fundId : this.createdFundId,
                        source : 'fund',
                        researchSearchStr : this.searchKeyword,
                        objectPluMap: this.pluralLabelMap,
                        objectLabelMap1: this.objectLabelMap,
                    }
                };
    
                var encodedCompDef = btoa(JSON.stringify(compDefinition));
                // this[NavigationMixin.GenerateUrl]({  //added for bug #00042086 fixes by salauddin sheikh
                //     type: 'standard__webPage',
                //     attributes: {
                //         url: '/one/one.app#' + encodedCompDef
                //     }
                // }).then(generatedUrl => {
                //     window.open(generatedUrl, "_blank");
                // });
                var url = '/one/one.app#' + encodedCompDef; //added for bug #00042086 fixes by salauddin sheikh
                window.open(url, '_blank');
            }
            else {
                this.AddtoThemeRecordApex()
            }
            this.closeAddNewFund(); // added for bug #00041951 fixes by salauddin sheikh
        }

        addAllContacts() {
            this.buttonClickedName = 'Add All Contacts';//Added by LK on 2024-05-11 to fix 00045609
            this.addToTeamIncludeAllContactsForEachFirm = true;
            this.AddtoThemeRecordApex();
        this.isYesNo = false;
        this.addAllConforTheme = true;  //added fixes of bug #00040888 by salauddin sheikh
        this.saveCheck = true;
        this.createCheck = true;
        this.closeCreateRecord();   //for bug #00042087 fixes by salauddin sheikh
    }
        /* Added above code by LK for the Add to Fund functionality - END */

        closeCreateRecord(){
            this.isCreateRecord = false;
            this.createCheck = true;
            this.itemCount = 0; //bug #00041191 #00041189,fixes by salauddin sheikh
            //this.themeName =""; //Commented by LK on 2024-05-11 to fix 00045622 ; 00045698
            this.saveCheck = true;
            /*let sectmodal = this.template.querySelector(".slds-modal");
            if(sectmodal != null){
                let bodyClose = sectmodal.closest('body');
                bodyClose.style.overflow = "auto";
                console.log(bodyClose,'bodyClose');
            }*/
            //this.SelectedData=[];
        }
    
        onHandleExport(){
            this.isCollapse = true;
            this.isExpand = false;
            this.isExpandCollapseBox = false;
            this.isExport = true;

             // to open modal set isModalOpen tarck value as true
             setTimeout(() => {
     
                let sectmodal = this.template.querySelector(".slds-modal");
                let bodyClose = sectmodal.closest('body');
                bodyClose.style.overflow = "hidden";
                console.log(bodyClose,'bodyClose');
    
            }, 0);
        }
        closeExport(){
            this.isExport = false;
            let sectmodal = this.template.querySelector(".slds-modal");
            let bodyClose = sectmodal.closest('body');
            bodyClose.style.overflow = "auto";
            console.log(bodyClose,'bodyClose');
            //this.SelectedData=[];
        }
    
    
        isCollapse = true;
        isExpand = false;
        isExpandCollapseBox = false;   
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
        //Added else clause and some code in if clause & moved existing code inside if clause by LK on 2024-10-01 to fix 00047535
        if((this.isCreateRecord || this.isAddTo) && this.isExpand){
            for(var i=0;i<this.dataCatogryForInternalPart.length;i++){
                this.selectedRows.push(this.dataCatogryForInternalPart[i].id);
            }    
            this.SelectedData=[...this.dataCatogryForInternalPart];
            this.itemCount = this.SelectedData.length;
            this.btnDisableCheck();
       } else if((this.createFund || this.addFund) && this.isExpand){
            for(let i=0; i<this.availableAccRecList.length; i++){
                this.selectedRows.push(this.availableAccRecList[i].id);
            }
            this.SelectedData = [...this.availableAccRecList];
            this.fundSelectedAccRecType = [...this.availableAccRecList];
            this.itemCount = this.SelectedData.length;
            this.btnDisableCheck1();
        }
       
       //selectedRows=['Id_Firms','Id_Contacts','Id_Deals','Id_Funds','Id_Fundraisings','Id_Themes,Id_Clips','Id_Intractions','Id_TaggedAcc','Id_TaggedCon'];
         }
         @track selectedRows=[];
    
         columnsCatogry = [
            { label: 'All Categories',type:'text', fieldName: 'allCategoriers', hideDefaultActions: true,  cellAttributes: { class: 'slds-text-body_regular textColor' } },
            
        ];
         
    
        //selectedRows=[1,2,3,4,5,6];
        //selectedRows=['Id_Firms','Id_Contacts','Id_Deals','Id_Funds','Id_Fundraisings','Id_Themes,Id_Clips','Id_Intractions','Id_TaggedAcc','Id_TaggedCon'];
        getSelectedRec1() {
            var selectedRecords = this.template.querySelector('[data-id="SelectedThemeCreateTable_id"]').getSelectedRows();
            this.itemCount = selectedRecords.length;
            this.SelectedData = selectedRecords;
            this.btnDisableCheck(); //for Ui fixes by salauddin sheikh
        }
        getSelectedRec2() {
            var selectedRecords = this.template.querySelector('[data-id="SelectedThemeAddToTable_id"]').getSelectedRows();
            this.itemCount = selectedRecords.length;
            this.SelectedData = selectedRecords;
            this.btnDisableCheck2(); //for Ui fixes by salauddin sheikh
        }
        getSelectedRec3() {
            console.log('king--> getSelectedRec2');
            //This is giving error. Need cofirmation from Ehtesham
            var selectedRecords = this.template.querySelector('[data-id="SelectedToExportTable_id"]').getSelectedRows();
           // var selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
            console.log('king-->'+JSON.stringify(selectedRecords));
            this.itemCount = selectedRecords.length;
            this.SelectedData = selectedRecords;
        }

        exportvalue = 'Excel';
        get exportoptions() {
            return [
                { label: 'Excel', value: 'Excel' },
                { label: 'PDF', value: 'PDF' },
            ];
        }
    
        handleChange(event) {
            this.value = event.detail.value;
        }
        
        get rangeoptions() {
            return [
                { label: 'Account', value: 'Account' },
                { label: 'Contact', value: 'Contact' },
                { label: 'Deal', value: 'Deal' },
                { label: 'Fund', value: 'Fund' },
                { label: 'Fundraising', value: 'Fundraising' },
            ];
        }
    
        handleChangerange(event) {
            this.value = event.detail.value;
        }
        /* for dual list box */ 
        _selected = [];
    
        get optionsdualSelect() {
            return [
                { label: 'Account Number', value: 'a' },
                { label: 'Account Site', value: 'b' },
                { label: 'Active', value: 'c' },
                { label: 'Annual Revenue', value: 'd' },
                { label: 'Account Phone', value: 'e' },
                { label: 'Account Source', value: 'f' },
                { label: 'Company Keywords', value: 'g' },
                { label: 'Data.com Key', value: 'h' },
                { label: 'Deal Size(in mn)', value: 'i' },
            ];
        }
    
        get selected() {
            return this._selected.length ? this._selected : 'none';
        }
        /* for dual list box up to */ 
        handleChangedualSelect(e) {
            this._selected = e.detail.value;
            console.log('Ehatsham');
        }
        
        searchKeywordChange(event){
            this.searchKeyword = event.target.value;
        }
      


     /*   resetHeaderFromChilCmp(event){
            this.listOfLookupRecGlobal[]
        }*/


//-- custom lookup things --------------------------------------------------------------------------------------------------
// public properties with initial default values 
@api label = 'Theme';
@api placeholder = 'Search'; 
@api iconName = 'standard:account';
@api sobjectApiName = 'navpeII_dev18__Theme__c';
@api defaultRecordId = '';
@api themeIdComingFromThemePage='';

// private properties 
lstResult = []; // to store list of returned records   
hasRecords = true; 
searchKey=''; // to store input field value    
isSearchLoading = false; // to control loading spinner  
delayTimeout;

// initial function to populate default selected lookup record if defaultRecordId provided  







//------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------
 /* Fetches saved data from config object */

//------------------------------------------------------------------------------------------------------------------
handleSelectedThemeRecord(event){
    this.selectedRecord=event.detail.data.Id;
    this.themeName=event.detail.data.Name;//Added by LK on 2024-05-11 to fix 00045622 ; 00045698
    this.btnDisableCheck2();
    console.log('handleSelectedThemeRecord---->>'+this.selectedRecord);
}
//Added below method by LK on 2024-05-20 to fix 00045915 for Add To Theme
handleThemeRemove(ev){
    this.selectedRecord=null;
    this.themeName='';
    this.btnDisableCheck2();
}

btnDisableCheck2(){     //for Ui fixes by salauddin sheikh
    this.saveCheck = !(this.itemCount > 0 && this.selectedRecord != null);
}


@track fetchRecordByCustomLookup=[];
currentRecordSelectedByCustomLookup;
itteratorLookupChildcallinghandler(event){
    //alert('itterator');
    try{
    this.fetchRecordByCustomLookup=[];
    this.fetchRecordByCustomLookup=event.detail.recordList;
    console.log('Data value->'+this.fetchRecordByCustomLookup);
    
console.log('king->'+JSON.stringify(this.fetchRecordByCustomLookup));
    }catch(e){
console.log('error-->'+e.message +'----'+JSON.stringify(e));
    }
    console.log('777%%'+JSON.stringify(this.fetchRecordByCustomLookup));
}



@api clickAdvanceResearch(){
    if((this.searchKeyword != undefined && this.searchKeyword.length == 1 )){

        const evt = new ShowToastEvent({
           
            title: 'Error',
            message: 'Your search term must have 2 or more characters.',
            
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
        return 1;
    }
    this.dataCatogry = [];
    this.dataCatogryForInternalPart = [];
    this.selectedRows = [];
    this.comingSelectionTabelData = [];
    this.comingWholeMapData = [];
    this.comingSelectionTabelDataFirstCmp = [];
    this.comingWholeMapDataFirstCmp = [];
    
    this.saveButtonDisable=true;
    this.timeoutId = setTimeout(()=>this.delayFunctionForSaveButton(), 2000);

    


    this.template.querySelector('c-navatar-Research-Polymorphic-Combobox-Lwc').saveButtonHandling();
    this.template.querySelector('c-navatar-Research-Filter-Fields-Lwc').saveSearchButtonComponentHandler();
   
    const passResearchKeyword = new CustomEvent('passkeyword', { 
        detail:this.searchKeyword
    
    });
    this.dispatchEvent(passResearchKeyword);
    
var firmIdList=[];
var contactList=[];
var dealList=[];
var fundList=[];
var fundRaisingList=[];
var clipList=[];
var ThemeList=[];
var checkCurrentFunctionalityDisabled=false;
console.log('this.currentRecordSelectedByCustomLookup-->'+JSON.stringify(this.currentRecordSelectedByCustomLookup));
console.log('whole data -->'+JSON.stringify(this.fetchRecordByCustomLookup));
//this.fetchRecordByCustomLookup[this.fetchRecordByCustomLookup.length]=this.currentRecordSelectedByCustomLookup;
for(var index=0;index < this.fetchRecordByCustomLookup.length;index++){
    if(this.fetchRecordByCustomLookup[index].currentFunCheck){ 
        checkCurrentFunctionalityDisabled =true;
    }
    if(this.fetchRecordByCustomLookup[index].Id != undefined && this.fetchRecordByCustomLookup[index].Id != ''){
    switch (this.fetchRecordByCustomLookup[index].ObjName)
    {
        case 'Account':
          
            firmIdList.push(this.fetchRecordByCustomLookup[index].Id);
            
            continue;
        case 'Contact':
            
            contactList.push(this.fetchRecordByCustomLookup[index].Id);
            
            continue;
        case 'navpeII_dev18__Theme__c':
            ThemeList.push(this.fetchRecordByCustomLookup[index].Id);
            continue;
        case 'navpeII_dev18__Clip__c':
            clipList.push(this.fetchRecordByCustomLookup[index].Id);
            continue;
        case 'navpeII_dev18__Pipeline__c':
            dealList.push(this.fetchRecordByCustomLookup[index].Id);
            continue;
        case 'navpeII_dev18__Fund__c':
            fundList.push(this.fetchRecordByCustomLookup[index].Id);
            continue;
        case 'navpeII_dev18__Fundraising__c':
            fundRaisingList.push(this.fetchRecordByCustomLookup[index].Id);
            continue;
}

}
}
var wrapperLwcToApex={Account:"",Contact:"",navpeII_dev18__Pipeline__c:"",navpeII_dev18__Fund__c:"",navpeII_dev18__Fundraising__c:"",navpeII_dev18__Theme__c:"",navpeII_dev18__Clip__c:""};
wrapperLwcToApex.Account=firmIdList;
wrapperLwcToApex.Contact=contactList;
wrapperLwcToApex.navpeII_dev18__Pipeline__c=dealList;
wrapperLwcToApex.navpeII_dev18__Fund__c=fundList;
wrapperLwcToApex.navpeII_dev18__Fundraising__c=fundRaisingList;
wrapperLwcToApex.navpeII_dev18__Theme__c=ThemeList;
wrapperLwcToApex.Clip__c=clipList;
if(firmIdList.length < 1 && contactList.length < 1 && dealList.length < 1 && fundList.length < 1 && fundRaisingList.length < 1 && ThemeList.length < 1 && clipList.length < 1){
   

    if(this.currId != undefined && this.currId != null && this.currId != '' && checkCurrentFunctionalityDisabled == true){
        var list=[];
        list.push(this.currId);
        wrapperLwcToApex[this.currObj]=list;
   
        this.advanceParameterShow=true;
    }else{
        if(!this.notificationFlag){
            this.advanceParameterShow=false;
        }
        
       
    }

}else{
    this.advanceParameterShow=true;
}
//-----------------------------------------------------------------------------------------------------------
if((this.searchKeyword != undefined && this.searchKeyword.length < 2 && this.searchKeyword != '') && (!this.advanceParameterShow)){

    const evt = new ShowToastEvent({
       
        title: 'Error',
        message: 'Your search term must have 2 or more characters.',
        
        variant: 'error',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
    return 1;
}else if((this.searchKeyword == undefined || this.searchKeyword.length < 1 || this.searchKeyword == '') && (!this.advanceParameterShow)){
    
    const passResearchKeyword = new CustomEvent('callnosearch', { 
        detail:{name:'Search KeyWord Is Absent'}
    });
    this.dispatchEvent(passResearchKeyword);
   
}else{
//----------------------------------------------------------------------------------------------------------
console.log('wrapperLwcToApex--->'+JSON.stringify(wrapperLwcToApex));

const passEventData = new CustomEvent('navatarresearchadvance', {
    detail:wrapperLwcToApex

});
this.dispatchEvent(passEventData);

}

}

delayFunctionForSaveButton(){
    this.saveButtonDisable=false;
}

handleFieldFilter(event){
this.notificationFlag=false;
this.advanceParameterShow =false;
console.log('Finally I am In the main method')
console.log(JSON.stringify(event.detail));
console.log('finally I am in the main method');
var wrapperLwcToApexForFiledFilter={Account:"",Contact:"",navpeII_dev18__Pipeline__c:"",navpeII_dev18__Fund__c:"",navpeII_dev18__Fundraising__c:"",navpeII_dev18__Theme__c:"",navpeII_dev18__Clip__c:""};

var comingData=[];
comingData=event.detail;
var midStageWrapper=[];
var finalWrapper={Account:"",Contact:""};
console.log('coming data->'+JSON.stringify(comingData));
if(comingData.length < 1){
    this.advanceParameterShow =false;
}else{
    
    this.advanceParameterShow =true;
}
for(var k=0;k<comingData.length;k++){
console.log('comingdata '+k );
var dataString='';
if((comingData[k].filterData.curVal != '' && comingData[k].filterData.curVal != null && comingData[k].filterData.curVal != undefined) || ((comingData[k].filterData.filter == 'IN:' || comingData[k].filterData.filter == 'NOT IN:' ) && (comingData[k].filterData.fDataType == 'MULTIPICKLIST' || comingData[k].filterData.fDataType == 'PICKLIST'))){
if(comingData[k].filterData.filter == 'like contain'){
    var boolFlag=false;
    let stringContainer=comingData[k].filterData.curVal.toString();
    let innerVarOfLikeValue='';
    if(stringContainer.indexOf(',' != -1)){
     let localArr=[];
     localArr=stringContainer.split(',');
     for(var i=0;i<localArr.length;i++){
        if(i == 0){
            innerVarOfLikeValue=comingData[k].filterData.fieldName+' Like \'%'+localArr[i]+'%\' ';
        }else{
            innerVarOfLikeValue=innerVarOfLikeValue+'OR '+comingData[k].filterData.fieldName+' Like \'%'+localArr[i]+'%\' ';
        }
     }
     stringContainer=innerVarOfLikeValue.toString();
     boolFlag=true;
    }
    console.log('## '+stringContainer);
    if(!boolFlag){
        dataString=comingData[k].filterData.fieldName+' Like \'%'+comingData[k].filterData.curVal+'%\' ';
    }else{
        dataString=innerVarOfLikeValue+'';
    }
    //dataString=comingData[k].filterData.fieldName+' Like \'%'+comingData[k].filterData.curVal+'%\' ';
}else if(comingData[k].filterData.filter == 'not like'){
    var boolFlag=false;
    let stringContainer=comingData[k].filterData.curVal.toString();
    let innerVarOfLikeValue='';
    if(stringContainer.indexOf(',' != -1)){
     let localArr=[];
     localArr=stringContainer.split(',');
     for(var i=0;i<localArr.length;i++){
        if(i == 0){
            innerVarOfLikeValue='(NOT '+comingData[k].filterData.fieldName+' Like \'%'+localArr[i]+'%\') ';
        }else{
            innerVarOfLikeValue=innerVarOfLikeValue+'AND (NOT '+comingData[k].filterData.fieldName+' Like \'%'+localArr[i]+'%\') ';
        }
     }
     stringContainer=innerVarOfLikeValue.toString();
     boolFlag=true;
    }
    console.log('## '+stringContainer);
    if(!boolFlag){
        dataString='NOT '+comingData[k].filterData.fieldName+' Like \'%'+comingData[k].filterData.curVal+'%\' ';
    }else{
        dataString=innerVarOfLikeValue+'';
    }
   // dataString='NOT '+comingData[k].filterData.fieldName+' Like \'%'+comingData[k].filterData.curVal+'%\' ';
}else if((comingData[k].filterData.filter == 'like start' || comingData[k].filterData.filter == '<' || comingData[k].filterData.filter == '>' || comingData[k].filterData.filter == '<=' || comingData[k].filterData.filter == '>=') && comingData[k].filterData.fDataType == 'REFERENCE'){
    //alert(JSON.stringify(comingData[k].filterData));
    dataString=comingData[k].filterData.childRelationShipName+'.Name'+' Like \'%'+comingData[k].filterData.curVal+'%\' ';
   //alert(dataString);
}else if(comingData[k].filterData.filter == 'like start'){
    var boolFlag=false;
    let stringContainer=comingData[k].filterData.curVal.toString();
    let innerVarOfLikeValue='';
    if(stringContainer.indexOf(',' != -1)){
     let localArr=[];
     localArr=stringContainer.split(',');
     for(var i=0;i<localArr.length;i++){
        if(i == 0){
            innerVarOfLikeValue=comingData[k].filterData.fieldName+' Like \'%'+localArr[i]+'%\' ';
        }else{
            innerVarOfLikeValue=innerVarOfLikeValue+'OR '+comingData[k].filterData.fieldName+' Like \'%'+localArr[i]+'%\' ';
        }
     }
     stringContainer=innerVarOfLikeValue.toString();
     boolFlag=true;
    }
    console.log('## '+stringContainer);
    if(!boolFlag){
        dataString=comingData[k].filterData.fieldName+' Like \'%'+comingData[k].filterData.curVal+'%\' ';
    }else{
        dataString=innerVarOfLikeValue+'';
    }
    
    
    console.log('## '+dataString);
}else if(comingData[k].filterData.filter == 'like end'){
    dataString=comingData[k].filterData.fieldName+' Like \''+comingData[k].filterData.curVal+'%\' ';
}else if((comingData[k].filterData.filter == '=' || comingData[k].filterData.filter == '!=') && comingData[k].filterData.fDataType == 'REFERENCE'){
    //alert(comingData[k].filterData.filter);
    dataString=comingData[k].filterData.childRelationShipName+'.Name'+' '+comingData[k].filterData.filter+' \''+comingData[k].filterData.curVal+'\' ';
}else if((comingData[k].filterData.filter == 'like==' || comingData[k].filterData.filter == 'not like!==') && comingData[k].filterData.fDataType == 'REFERENCE'){
    if(comingData[k].filterData.filter == 'like=='){
        dataString=comingData[k].filterData.childRelationShipName+'.Name'+' Like  \'%'+comingData[k].filterData.curVal+'%\' ';

    }else{
        dataString='NOT '+comingData[k].filterData.childRelationShipName+'.Name'+' Like \'%'+comingData[k].filterData.curVal+'%\' ';

    }
    }else if(comingData[k].filterData.filter == 'IN:' || comingData[k].filterData.filter == 'NOT IN:' || comingData[k].filterData.filter == 'IN: ' || comingData[k].filterData.filter == 'NOT IN: ' ){
    console.log('$$##->'+JSON.stringify(comingData[k].filterData.curVal));
    let splitData=comingData[k].filterData.curVal.toString();
    let splitDataList=[];
    splitDataList=splitData.split(",");
    console.log('$$##->'+JSON.stringify(splitDataList));
    let newForString='';
    for(let i=0;i<splitDataList.length;i++){
        if(newForString == ''){
            newForString='(\''+splitDataList[i]+'\'';
        }else{
            newForString=newForString+','+'\''+splitDataList[i]+'\'';
        }
      
    }
    newForString=newForString+')';
    console.log('$$##->'+newForString);
    if(comingData[k].filterData.filter == 'IN:' || comingData[k].filterData.filter == 'IN: '){
        dataString=comingData[k].filterData.fieldName + ' IN '+newForString+' ';
    }else if(comingData[k].filterData.filter == 'NOT IN:' || comingData[k].filterData.filter == 'NOT IN: '){
        dataString=comingData[k].filterData.fieldName + ' NOT IN '+newForString+' ';
    }
   
    console.log('$$##->'+dataString);

}else if(comingData[k].filterData.fDataType == 'STRING' || comingData[k].filterData.fDataType == 'EMAIL' || comingData[k].filterData.fDataType == 'URL' || comingData[k].filterData.fDataType == 'TEXTAREA'){
    dataString=comingData[k].filterData.fieldName +' '+comingData[k].filterData.filter+' \''+comingData[k].filterData.curVal+'\' ';
}else if(comingData[k].filterData.fDataType == 'DATETIME'){
    var str=(comingData[k].filterData.curVal).toString().replace(' ', 'T');
    str=str+'Z';
    dataString=' '+comingData[k].filterData.fieldName+' '+comingData[k].filterData.filter+str+' ';
}else if(comingData[k].filterData.fDataType == 'MULTIPICKLIST' && (comingData[k].filterData.filter == 'includes' || comingData[k].filterData.filter == 'excludes')){
    var myArray = [];
    let cvt='';
    cvt=(comingData[k].filterData.curVal).toString();
    //alert(comingData[k].filterData.curVal + '   ' + cvt.indexOf(','));
    if(cvt.indexOf(',') != -1){
      myArray =cvt.split(",");
    }else{
        myArray[0]=comingData[k].filterData.curVal;
    }
    
    let localString='';
    for(let i=0;i<myArray.length ;i++){
        if(i == 0){
            localString='\''+myArray[i]+'\'';
        }else{
            localString=localString+',\''+myArray[i]+'\'';
        }
        
    }

    dataString=' '+comingData[k].filterData.fieldName+' '+comingData[k].filterData.filter+' ('+localString+') ';
  console.log('##'+dataString);
}else if((comingData[k].filterData.fDataType == 'PHONE'  && comingData[k].filterData.filter != 'like contain' && comingData[k].filterData.filter != 'not like' && comingData[k].filterData.filter != 'like start') || ( (comingData[k].filterData.fDataType == 'PICKLIST' || comingData[k].filterData.fDataType == 'REFERENCE' ) && (comingData[k].filterData.filter == '<' || comingData[k].filterData.filter == '>' || comingData[k].filterData.filter == '<=' || comingData[k].filterData.filter == '>='))){
    let localString='';
    if(comingData[k].filterData.curVal.indexOf(',') != -1){
        localString=comingData[k].filterData.curVal.replace(',','');
    }else{
        localString=comingData[k].filterData.curVal;
    }
   // alert(localString);
    dataString=' '+comingData[k].filterData.fieldName+' '+comingData[k].filterData.filter+' \''+localString+'\' ';
}else{
    dataString=' '+comingData[k].filterData.fieldName+' '+comingData[k].filterData.filter+comingData[k].filterData.curVal+' ';
}
 
 
console.log('line-925 '+JSON.stringify(comingData[k]));
console.log('Boolean'+dataString);

switch (comingData[k].filterData.objApiName)
    {
        
        case 'Account':
            console.log('line-930');
            if(wrapperLwcToApexForFiledFilter['Account'] != undefined && wrapperLwcToApexForFiledFilter['Account'] != ''){
                console.log('line-932');
                wrapperLwcToApexForFiledFilter['Account']+='OR '+ dataString;
                console.log('line-934');
            }else{
                console.log('line-936');
                wrapperLwcToApexForFiledFilter['Account']=dataString;
                console.log('line-938');
            }
            console.log('line-940');
            this.notificationFlag=true;
            continue;
        case 'Contact':
            console.log('line-943');
            if(wrapperLwcToApexForFiledFilter['Contact'] != undefined && wrapperLwcToApexForFiledFilter['Contact'] != ''){
                console.log('line-945');
                wrapperLwcToApexForFiledFilter['Contact']+='OR '+ dataString;
                console.log('line-947');
            }else{
                console.log('line-949');
                wrapperLwcToApexForFiledFilter['Contact']=dataString;
                console.log('line-951');
            }
            this.notificationFlag=true;
            continue;
        case 'navpeII_dev18__Theme__c':
            if(wrapperLwcToApexForFiledFilter['navpeII_dev18__Theme__c'] != undefined && wrapperLwcToApexForFiledFilter['navpeII_dev18__Theme__c'] != ''){
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Theme__c']+='OR '+ dataString;
            }else{
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Theme__c']=dataString;
            }
            this.notificationFlag=true;
            continue;
        case 'navpeII_dev18__Clip__c':
            if(wrapperLwcToApexForFiledFilter['navpeII_dev18__Clip__c'] != undefined && wrapperLwcToApexForFiledFilter['navpeII_dev18__Clip__c'] != ''){
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Clip__c']+='OR '+ dataString;
            }else{
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Clip__c']=dataString;
            }
            this.notificationFlag=true;
            continue;
        case 'navpeII_dev18__Pipeline__c':
            if(wrapperLwcToApexForFiledFilter['navpeII_dev18__Pipeline__c'] != undefined && wrapperLwcToApexForFiledFilter['navpeII_dev18__Pipeline__c'] != ''){
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Pipeline__c']+='OR '+ dataString;
            }else{
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Pipeline__c']=dataString;
            }
            this.notificationFlag=true;
            continue;
        case 'navpeII_dev18__Fund__c':
            if(wrapperLwcToApexForFiledFilter['navpeII_dev18__Fund__c'] != undefined && wrapperLwcToApexForFiledFilter['navpeII_dev18__Fund__c'] != ''){
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Fund__c']+='OR '+ dataString;
            }else{
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Fund__c']=dataString;
            }
            this.notificationFlag=true;
            continue;
        case 'navpeII_dev18__Fundraising__c':
            if(wrapperLwcToApexForFiledFilter['navpeII_dev18__Fundraising__c'] != undefined && wrapperLwcToApexForFiledFilter['navpeII_dev18__Fundraising__c'] != ''){
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Fundraising__c']+='OR '+ dataString;
            }else{
                wrapperLwcToApexForFiledFilter['navpeII_dev18__Fundraising__c']=dataString;
            }
            this.notificationFlag=true;
            continue;
            

}
console.log('line-992'+ JSON.stringify(wrapperLwcToApexForFiledFilter));
//
}

}

console.log('wrapperLwcToApexForFiledFilter>>'+JSON.stringify(wrapperLwcToApexForFiledFilter));
console.log('~~~~wrapperLwcToApexForFiledFilter>>'+JSON.stringify(wrapperLwcToApexForFiledFilter));
const passEventData = new CustomEvent('comingfielddata', {
    detail:wrapperLwcToApexForFiledFilter

});
this.dispatchEvent(passEventData);


}

//for maintaining the add to theme & create theme & export  Advance Section
@api
setAdvanceDataTableData(STDF,CMDF){
    
this.comingSelectionTabelData=STDF; 
this.comingWholeMapData=CMDF;
console.log(JSON.stringify(this.comingSelectionTabelData));
console.log(JSON.stringify(this.comingWholeMapData));
this.dataCatogry=this.comingSelectionTabelData;
/*this.dataCatogryForInternalPart = this.comingSelectionTabelData.filter((Data) => Data.object != 'Intraction');
this.dataCatogryForInternalPart = this.dataCatogryForInternalPart.filter((Data) => {
                                   let storeValueInString=Data.object.toString();
                                   return (Data.object != 'Intraction' && storeValueInString.indexOf("Tagged") == -1)});*/
this.dataCatogryForInternalPart = this.comingSelectionTabelData;
this.dataCatogryForInternalPart = this.dataCatogryForInternalPart.filter((Data) => {
                                    let storeValueInString=Data.object.toString();
                                    return (storeValueInString.indexOf("Tagged") == -1)});
    for(var i=0;i<this.dataCatogry.length;i++){
        this.selectedRows.push(this.dataCatogry[i].id);
    }
    this.SelectedData = [...this.dataCatogry];
this.saveButtonDisable=false;
}



//---------Export functionality Methods ----------------------------------------------------------------

//Samiulla Pathan: Export ExcelSheet
serverDatamakingAsExport(){
    try{
        var selectedRecords = this.template.querySelector('[data-id="SelectedToExportTable_id"]').getSelectedRows();        
        this.SelectedData = selectedRecords;
        var arrayRec = [];
        if(this.SelectedData.length>0){
            for(var i =0;i<this.comingWholeMapData.length; i++){
                if(this.comingWholeMapData[i]['object'] == 'Contact'){
                    arrayRec.push(this.formatWholeData(this.comingWholeMapData[i],'Contact', this.comingWholeMapData[i]['allCategoriers']));
                }else if(this.comingWholeMapData[i]['object'] == 'FundRaising'){
                    arrayRec.push(this.formatWholeData(this.comingWholeMapData[i],'FundRaising', this.comingWholeMapData[i]['allCategoriers']));
                }else{
                    arrayRec.push(this.comingWholeMapData[i])
                }
               
               // if()
            }
            this.template.querySelector("c-navatar-Export-Lwc").serverDatamakingAsExportRecord(this.globalFieldTypeCasting, this.SelectedData, arrayRec, this.componentReference,this.fileName);
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select atleast a record',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }catch(error){
        console.log(error);
    }
    
}
//End

formatWholeData(recordList, objectName, category){
    try{
        var wiredContact = Object.assign({}, recordList);
        var finalRecords = {};
        var recordObjectMap = {};
        //for(var i = 0;i<recordList['List'])
        if(wiredContact['object'] == 'Contact'){
            console.log('_________><><<<<<<<<<<<<<<<<<<<<<<<>---------'+JSON.stringify(wiredContact['object']));
            for(var key in wiredContact['List']){
                var parseJSON = {};
                if(wiredContact['List'][key]['Account']){
                    var convertString = JSON.stringify( wiredContact['List'][key]);
                    convertString = convertString.replace(wiredContact['List'][key]['AccountId'],wiredContact['List'][key]['Account']['Name']);
                    parseJSON = JSON.parse(convertString);
                    //wiredContact['List'][key]['AccountId']=wiredContact['List'][key]['Account']['Name'];
                }
                recordObjectMap[key] = parseJSON;
            }
            finalRecords['allCategoriers'] = category;
            finalRecords['List'] = recordObjectMap;
            finalRecords['object'] = objectName;
        }else if(wiredContact['object'] == 'FundRaising'){
            for(var key in wiredContact['List']){
                var parseJSON = {};
                if(wiredContact['List'][key]['navpeII_dev18__Legal_Name__c']){
                    var convertString = JSON.stringify( wiredContact['List'][key]);
                    convertString = convertString.replace(wiredContact['List'][key]['navpeII_dev18__Legal_Name__c'],wiredContact['List'][key]['navpeII_dev18__Legal_Name__r']['Name']);
                    parseJSON = JSON.parse(convertString);
                    //wiredContact['List'][key]['AccountId']=wiredContact['List'][key]['Account']['Name'];
                }
                recordObjectMap[key] = parseJSON;
            }
            finalRecords['allCategoriers'] = category;
            finalRecords['List'] = recordObjectMap;
            finalRecords['object'] = objectName;
        }
        console.log('finalRecords :::: '+JSON.stringify(finalRecords));
        return finalRecords;
    }catch(err){
        console.log('Error :::: '+err);
    }
}







//-------------------------------------------------------------------------------------------------------
 //This fuction used for styling
 renderedCallback(){
    /* Added below code by LK for the Add to Fund functionality - START */
    if(!this.isfundTypeVsInvCategoryMapped && (this.fundTypeOptns.length > 0) && (this.invCategoryOptnsComplete.length > 0)){
        //Mapping the dependent picklist values
        let counter = 0;
        for(let fundOptn of this.fundTypeOptns){
            let validInvCategoryOptnsList = [];
            for(let invCategory of this.invCategoryOptnsComplete){
                if(invCategory['validFor'].includes(counter)){
                    validInvCategoryOptnsList.push(invCategory);
                }
            }
            counter++;
            this.fundTypeVsInvCategoryMapping.set(fundOptn['value'], validInvCategoryOptnsList);
        }
        this.isfundTypeVsInvCategoryMapped = true;
        //Checking existence of record types
        let recTypeInfoValueArray = (Object.values(this.fundRecord.data.recordTypeInfos)).filter(recType => recType['available']);
        this.fundRecTypeExists = !(recTypeInfoValueArray.length === 1 && recTypeInfoValueArray[0]['name'] === 'Master');
        if(this.fundRecTypeExists){
            let recTypeoptnValues = [];
            const rtInfos = this.fundRecord.data.recordTypeInfos;
            let rtValues = Object.values(rtInfos);
            for (let i = 0; i < rtValues.length; i++) {
                if (rtValues[i].name !== 'Master' && rtValues[i].available == true) { // added condition for bug #00041806 fixes by salauddin sheikh
                    recTypeoptnValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }
            this.fundRecTypeList = recTypeoptnValues;
            this.selectedRecordTypeID = this.fundRecTypeList[0].value;
            this.defaultFundRcType = this.fundRecTypeList[0].value; // for bug #00041477 fixes by salauddin sheikh
        }
    }
    /* Added above code by LK for the Add to Fund functionality - END */
    console.log(this.isRendered);
            this.isRendered = true;
            const style = document.createElement('style');
            style.innerText =`.addMinus .slds-button{
                height:30px;
                width:30px;
                border: none;
            }
            .addMinus .slds-icon {
                fill: #0176d3;
                width: 16px;
                height: 16px;
            }
        .datatable_theme .slds-has-focus.slds-is-resizable .slds-th__action,
        .datatable_theme .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .datatable_theme .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .datatable_theme .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .datatable_theme .slds-is-resizable .slds-th__action:focus,
        .datatable_theme .slds-is-resizable .slds-th__action:focus:hover,
        .datatable_theme .slds-table th:focus,
        .datatable_theme .slds-table th.slds-has-focus,
        .datatable_theme .slds-table [role="gridcell"]:focus,
        .datatable_theme .slds-table [role="gridcell"].slds-has-focus,
        .datatable_theme .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .datatable_theme .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
              box-shadow: none !important;
            }            
        
        .datatable_theme .slds-th__action:focus, .datatable_theme .slds-th__action:hover,
        .datatable_theme .slds-table tr:hover{
            box-shadow: none !important;
        } 
    
        .datatable_theme .slds-th__action{
            background: #f3f3f3 !important;
        }
        .datatable_theme .slds-table:not(.slds-no-row-hover) tbody tr:hover>th{
            background: none !important;
        }
        .datatable_theme .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }
        .datatable_theme .slds-table_header-fixed_container.slds-scrollable_x {
            overflow-x: hidden;
        }
        .export_name .slds-input[readonly]:focus{

            box-shadow:none;

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
            box-shadow: none;
        }

        .theme_css .slds-table tbody tr.slds-is-selected>td,
        .theme_css .slds-table tbody tr.slds-is-selected>th{
            background-color: #e9e8e83d !important;    
        }
        .lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
            position: absolute;
            right: 2px;
            top: 0px;
             }
             .addtothemelookup ul.drop_ul{box-shadow: 0px 2px 2px rgb(0 0 0 / 10%);
             border: 1px solid #ddd;
             border-radius: 4px;
             z-index: 15003 !important;
             height: fit-content;
             background: #fff;
             position: fixed;
             width: 91%;
             margin-top: 32px;
             max-height: 150px;
             overflow-y: auto;}
        .slds-popover.slds-popover_tooltip.slds-nubbin_bottom-left{background-color: #16325c !important;}
            .slds-table_header-fixed tbody tr th {
                height: 41px;
            }
            .addto_radio .slds-form-element__control{
                padding: 0px 5px 0px 40%;
            }
            .addto_radio span.slds-radio{
                padding: 4px 4px;
            }
            @media only screen and (min-device-width: 1480px) and (max-device-width: 1550px) {
            .slds-table_header-fixed_container.slds-scrollable_x{
                overflow-x: hidden;
            }}
            @media (max-width: 79em) {
                .slds-table_header-fixed_container.slds-scrollable_x {
                    overflow-x: hidden;
                }
            }
            @media only screen and (min-width: 40.063em) and (max-width: 60em) {
                .slds-table_header-fixed_container.slds-scrollable_x {
                    overflow-x: auto;
                }
            }`;
    
                try {
                    this.template.querySelector('.main-Container-search').appendChild(style);
                } catch (err) {
                    console.log(err)
                }
            }

            
}