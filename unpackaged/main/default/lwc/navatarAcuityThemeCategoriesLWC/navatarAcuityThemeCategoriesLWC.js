/*
** Module Name : Acuity 2.0 - Acuity
** Description : Displays the Categories section on Themes Acuity Page.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Anshika Ahuja  Acuity Phase 2
** 2.1        2024-03-08          Manonit        Category Implementation on Theme Page for Contact ,Deal,Fund and Fundraising Object
** CR         2024-04-02          Manonit        CR Bug Fix ToolTip for Categories
*/
import { LightningElement, track, api,wire } from 'lwc';
//Added By Tejaswini - Naming Convention 
import handleOnLoadTheme from '@salesforce/apex/NavatarThemeAcuityCtrl.handleOnLoadTheme';
import handleColumnHeaders from '@salesforce/apex/NavatarThemeAcuityCtrl.handleColumnHeaders';
import deleteThemeRelations from '@salesforce/apex/NavatarThemeAcuityCtrl.deleteThemeRelations';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
//added by Pavani w.r.t Security model fix	
import THEME_RELATION from '@salesforce/schema/Theme_Relation__c';	
import ACCOUNT from '@salesforce/schema/Account';	
import CONTACT from '@salesforce/schema/Contact';	
import DEAL from '@salesforce/schema/Pipeline__c';	 
import FUND from '@salesforce/schema/Fund__c';	
import FUND_RAISING from '@salesforce/schema/Fundraising__c';	
import THEME from '@salesforce/schema/Theme__c';	
import CLIP from '@salesforce/schema/Clip__c'//end by Pavani

export default class NAVATARACUITYTHEMECATEGORIESLWC extends NavigationMixin(LightningElement) {

// Samiulla Pathan: 
//exportThemeRecord variable is used to open theme export when user clicks on Export button
exportThemeRecord = false;
//allExportDataList list holds the all records for which excel sheet need to generated
allExportDataList = [];
//allCategoryToDisplay list holds the category names to display on theme export popup
allCategoryToDisplay = [];
modelPopup = true;
fieldLabelArray = {};
//End

isDeafultGrid = true;

isDataTableFirmClick = false; 
isDataTableContactClick = false;
isDataTableDealClick = false;
isDataTableFundraisingClick = false;
addDisableinter = true;
isDataTableClipClick = false;
isDataTableThemeClick = false;
isDataTableFundClick  = false;
//Added by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
recordTypeCompCheck = false;
recordTypeAdvisorCheck = false;

//Added by Tejaswini
oldValueToSort;
sortOrder = 'DESC';
sortbyContact;
//Added by Tejaswini - 00033368/00035019
placeholderContact = 'Last Interaction Date';
placeholderDeal = 'Stage';
placeholderFund = 'Add To Theme';
placeholderfdr = 'Stage';
placeholderAcc = 'Last Interaction Date';

sorting = 'all'; //Added by Tejaswini - 00034976
idToSort = '';
currentIndex;
currentIndex;
accountRecordTypeListOld=[];
contactRecordTypeListOld=[];
dealRecordTypeListOld=[];
fundRecordTypeListOld=[];
fdrRecordTypeListOld=[];
//added by Pavani w.r.t Security model fix	
accIsAccessible = false;	
conIsAccessible = false;	
dealIsAccessible = false;	
fundIsAccessible= false;	
fundraisingAccess = false;	
themeIsAccessible = false;	
clipIsAccessible = false;	
otherThemeAccess = false;	
objectApiNames=[THEME_RELATION,ACCOUNT,CONTACT,DEAL,FUND,FUND_RAISING,THEME,CLIP]//end by Pavani

@track sortedBy;
@track sortedDirection;
contactRecordTypeList;
//Added by Hema - 00039992
contactobjLabel;
dealobjLabel;
fundObjLabel
fundraisingObjLabel;
themeObjLabel;
clipObjLabel;


//added by Pavani w.r.t Security model fix	
@wire(getObjectInfos,{objectApiNames:'$objectApiNames'})	
ThemeRelationObjectsInfo({error,data}){	
    if(error){	
        this.showToast(this, 'Error!', error.body.message, 'error');	
    }else if(data){
        // 00046351 Bug Fix by Manonit	
        console.log('@@Access'+JSON.stringify(data));	
        if(data!=null && data.results.length>0){	
            for(let i=0;i<data.results.length;i++){	
                if(data.results[i].result.apiName == 'Account' && data.results[i].result.queryable){	
                    this.accIsAccessible = (data.results[0].result.fields.navpeII_dev18__Account__c == undefined)?false:true;	
                   // this.accIsAccessible = (data.results[0].result.fields.Account__c && data.results[0].result.fields.Account__c.createable)?true:false;	
                }else if(data.results[i].result.apiName == 'Contact' && data.results[i].result.queryable){	
                    this.contactobjLabel = data.results[i].result.label;
                       this.conIsAccessible = data.results[0].result.fields.navpeII_dev18__Contact__c == undefined?false:true;	
                //this.conIsAccessible = (data.results[0].result.fields.Contact__c && data.results[0].result.fields.Contact__c.createable)?true:false;	
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Pipeline__c' && data.results[i].result.queryable ){	
                    this.dealobjLabel = data.results[i].result.label;
                     this.dealIsAccessible = data.results[0].result.fields.navpeII_dev18__Deal__c == undefined?false:true;	
                 //   this.dealIsAccessible = (data.results[0].result.fields.Deal__c && data.results[0].result.fields.Deal__c.createable)?true:false;	
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Fund__c' && data.results[i].result.queryable){	
                    this.fundObjLabel= data.results[i].result.label;
                     this.fundIsAccessible = data.results[0].result.fields.navpeII_dev18__Fund__c == undefined?false:true;	
                   // this.fundIsAccessible = (data.results[0].result.fields.Fund__c && data.results[0].result.fields.Fund__c.createable)?true:false;		
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Fundraising__c' && data.results[i].result.queryable){		
                    this.fundraisingObjLabel= data.results[i].result.label;
                    this.fundraisingAccess = data.results[0].result.fields.navpeII_dev18__Fundraising__c == undefined?false:true;		
                  //  this.fundraisingAccess = (data.results[0].result.fields.Fundraising__c && data.results[0].result.fields.Fundraising__c.createable)?true:false;		
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Theme__c' && data.results[i].result.queryable ){		
                    this.themeObjLabel= data.results[i].result.label;		
                     this.themeIsAccessible = data.results[0].result.fields.navpeII_dev18__Theme__c == undefined?false:true;		
                  //  this.themeIsAccessible = (data.results[0].result.fields.Theme__c && data.results[0].result.fields.Theme__c.createable)?true:false;		
                }else if(data.results[i].result.apiName == 'navpeII_dev18__Clip__c' && data.results[i].result.queryable){		
                    this.clipObjLabel= data.results[i].result.label;	
                      this.clipIsAccessible = data.results[0].result.fields.navpeII_dev18__Clip__c == undefined?false:true;		
                   // this.clipIsAccessible = (data.results[0].result.fields.Clip__c && data.results[0].result.fields.Clip__c.createable)?true:false;		
                }		
            }		
        }		
    }		
}//end by Pavani


addThemeRecordPop(event){
    //Added by Tejaswini - Naming Convention
    //const objChild = this.template.querySelector('c-add-Record-To-Theme');
    const objChild = this.template.querySelector('c-navatar-acuity-theme-add-to-theme-lwc');
    objChild.openModal(event.currentTarget.dataset.name);
}

onAllClick(){
    /*this.isDeafultGrid = true; 
    this.isDataTableFirmClick = false;
    this.isDataTableContactClick = false; 
    this.isDataTableDealClick = false;
    this.isDataTableFundraisingClick = false; 
    this.isDataTableThemeClick = false;
    this.isDataTableClipClick = false;
    this.isDataTableFundClick  = false;
    const scrollOptions = {top: 0}
    window.scrollTo(scrollOptions);*/
    //Modified by Anshika Ahuja W.R.To Critical_Bug #00035274
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            actionName: 'view'
        }
    });
}



isShowFundraisingObject = false;
isShowDealObject=false;
isShowfundObject=false;
isShowContactObject=false;
chckBoxAdvisor = true;
cancelSave = false;
backtoOrignaladv(){
    this.chckBoxAdvisor = true;
    this.cancelSave = false;
    this.addDisableinter = true;
    
}

chckBoxComp = true;

handleContactRow(event){
    if(event.detail.action.name ==='lognoteAccount'){
        this.recordDetail.push(event.detail.row.accId);
        this.isCallLogOpen = true;
    }
    if(event.detail.action.name ==='lognoteContact'){
        this.recordDetail.push(event.detail.row.conId);
        this.isCallLogOpen = true;
    }
    if(event.detail.action.name ==='lognoteDeal'){
        this.recordDetail.push(event.detail.row.dealId);
        this.isCallLogOpen = true;
    }
    if(event.detail.action.name ==='lognoteFund'){
        this.recordDetail.push(event.detail.row.fundId);
        this.isCallLogOpen = true;
    }
    if(event.detail.action.name ==='lognoteFDR'){
        this.recordDetail.push(event.detail.row.fdrId);
        this.isCallLogOpen = true;
    }
    if(event.detail.action.name ==='lognoteTheme'){
        this.recordDetail.push(event.detail.row.themeId);
        this.isCallLogOpen = true;
    }
    if(event.detail.action.name ==='interactionNotes' || event.detail.action.name ==='lastInteractionDate'){
        this.actId = event.detail.row.actId;
        if(this.actId.startsWith('00T')){
            this.actObjName = 'Task';
        }
        else{
            this.actObjName = 'Event';    
        }
        if(this.actId != 'undefined'){
            const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');
            modalPopup.openModalSingleComponent(event.detail.row.actId, this.actObjName, 'view');
        }
        else{
            const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');
            modalPopup.openModalSingleComponent('', this.actObjName, 'view');
        }
        
    }
    if(event.detail.action.name === 'subject'){
        let url = '/lightning/n/navpeII_dev18__Clips?c__clipParams=' + event.detail.row.clipId; // Added Namespace by Hema - 39200
        window.open(url, '_blank');
}
}

handleNoteClick(){
    this.isShowNote = true;
}
/* Closes the notes modal */
noteModalClosed() {
    this.isCallLogOpen = false;
}



limitedPartnerDataMain = [];

PortfolioCompaniesMain = [];

contactDataMain = [];

dealDataMain = [];

fundDataMain = [];

fundraisingDataMain = [];


data_themes = [];



expand = true;
showmoreless(){
    let popModal = this.template.querySelector('.desc_li_theme');
    if(popModal.classList.contains('description_li')){
        popModal.classList.remove("description_li")
        this.expand = true;
        console.log("con1")
    }else{
        popModal.classList.add("description_li")
        this.expand = false;
        console.log("con2")
    }
}  
//Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
@track valuesortingCompany = 'Last Interaction Date';
get optionsforsortingFirm() {
    return [
        { label: 'Last Interaction Date', value: 'Account__r.navpeII_dev18__Last_Touchpoint__c@Account' },
        { label: 'Add To Theme', value: 'createddate@Account'},
        { label: 'Last Modified Date', value: 'Account__r.Lastmodifieddate@Account'},  
        { label: 'Firm Name', value: 'Account__r.Name@Account' },
        { label: 'Tier', value: 'Account__r.navpeII_dev18__Tier__c@Account' }
    ];  
}

get optionsforsortingCompany() {
    return [ 
        {label: 'Last Interaction Date', value: 'Account__r.navpeII_dev18__Last_Touchpoint__c@Account' },
        { label: 'Add To Theme', value: 'createddate@Account'},
        { label: 'Last Modified Date', value: 'Account__r.Lastmodifieddate@Account'},  
        { label: 'Revenue', value: 'Account__r.AnnualRevenue@Account'},  
        { label: 'Firm Name', value: 'Account__r.Name@Account' },
        { label: 'Tier', value: 'Account__r.navpeII_dev18__Tier__c@Account' },
        { label: 'Employees', value: 'Account__r.NumberOfEmployees@Account' }

    ];
}  

get optionsforsortingIntermediary() {
    return [ 
        {label: 'Last Interaction Date', value: 'Account__r.navpeII_dev18__Last_Touchpoint__c@Account' },
        { label: 'Add To Theme', value: 'createddate@Account'},
        { label: 'Last Modified Date', value: 'Account__r.Lastmodifieddate@Account'},  
        { label: 'Firm Name', value: 'Account__r.Name@Account' },
        { label: 'Tier', value: 'Account__r.navpeII_dev18__Tier__c@Account' }
      //  { label: '# Deals Sourced', value: 'Account__r.navpeII_dev18__forTotalDealsShown__c@Account' }  40210 Bug fix By Manonit
    ];
} 
//End by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297 




get optionsforsortingContact() {
    return [
        { label: 'Last Interaction Date', value: 'Contact__r.navpeII_dev18__Last_Touch_Point__c@Contact' },
        { label: 'Add To Theme', value: 'createddate@Contact' },
        { label: 'Last Modified Date', value: 'navpeII_dev18__Contact__r.Lastmodifieddate@Contact' },
    ];
}


valuesortingDeals = 'Stage';
get optionsforsortingDeals() {
    return [
        { label: 'Stage', value: 'Deal__r.navpeII_dev18__Stage__c@Deal' },
        { label: 'Add To Theme', value: 'createddate@Deal' },
        { label: 'Date Received', value: 'Deal__r.navpeII_dev18__Log_In_Date__c@Deal' },
    ];
}

valuesortingFundraising = 'Stage';
get optionsforsortingFundraising(){
    return [
        { label: 'Stage', value: 'Fundraising__r.navpeII_dev18__Stage__c@Fundraising' },
        { label: 'Add To Theme', value: 'createdDate@Fundraising' },
    ];
}

valuesortingFund = 'Add To Theme';
get optionsforsortingFund(){
    return [
        { label: 'Add To Theme', value: 'createdDate@Fund' },
    ];
}
handleChangesorting(event) {
    //Added by Tejaswini - 00033368
    this.sortbyContact=null;
    if(this.currentIndex != null)
     this.accountRecordTypeList[this.currentIndex].sortbyContact = null;
        if(this.oldValueToSort == event.detail.value ) {
        if(this.sortOrder == 'DESC') {
            this.sortOrder = 'ASC';
        } else if (this.sortOrder == 'ASC') {
            this.sortOrder = 'DESC';
        }
    } else {
        this.sortOrder = 'DESC';
    }
    
    this.oldValueToSort = event.detail.value;
    this.oldRecordType=event.currentTarget.dataset.id
    this.sortbyContact = event.detail.value;
    
    
    this.objectName = this.sortbyContact.split('@')[1];
    var fieldName = this.sortbyContact.split('@')[0];
    var orderbyClauseFirm = '';
    var orderbyClauseDeal = '';
    var orderbyClauseFund = '';
    var orderbyClauseFundraising = '';
    var orderbyClauseContact = '';
    var idList = [];
    //Added by Tejaswini - 00033368
    if(this.objectName == 'Account'){
        for(var i=0; i< this.accountRecordTypeList.length; i++)
        {
            if(this.accountRecordTypeList[i].name == event.currentTarget.dataset.name){
                this.currentIndex=i;
                for(var j=0; j< this.accountRecordTypeList[i].count; j++){
                    idList.push(this.accountRecordTypeList[i].List[j].accId);
                }

            }
        }
        //Modified by Anshika Ahuja W.R.To Critical Bug #00038134
         if(this.currentIndex != null && this.currentIndex != 0) {
            this.accountRecordTypeList[this.currentIndex].sortbyContact = event.detail.value; 
        }
        this.sorting = 'account'; //added by Tejaswini - 00034976
        orderbyClauseFirm = ' order by ' + fieldName +' '+ this.sortOrder;
        //Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
        if(event.currentTarget.dataset.name == 'Intermediary'){
            this.accountRecordTypeList[this.currentIndex].placeholderContact = this.optionsforsortingIntermediary.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.accountRecordTypeList[this.currentIndex].placeholderContact = this.accountRecordTypeList[this.currentIndex].placeholderContact[0].label;
            this.placeholderAcc = this.optionsforsortingIntermediary.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.placeholderAcc = this.placeholderAcc[0].label;
            this.idToSort = idList.toString();
        }
        else if(event.currentTarget.dataset.name == 'Company'){
            this.accountRecordTypeList[this.currentIndex].placeholderContact = this.optionsforsortingCompany.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.accountRecordTypeList[this.currentIndex].placeholderContact = this.accountRecordTypeList[this.currentIndex].placeholderContact[0].label;
            this.placeholderAcc = this.optionsforsortingCompany.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.placeholderAcc = this.placeholderAcc[0].label;
            this.idToSort = idList.toString();
        }
        else if(event.currentTarget.dataset.name != 'Intermediary' && event.currentTarget.dataset.name != 'Company'){
            this.accountRecordTypeList[this.currentIndex].placeholderContact = this.optionsforsortingFirm.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.accountRecordTypeList[this.currentIndex].placeholderContact = this.accountRecordTypeList[this.currentIndex].placeholderContact[0].label;
            this.placeholderAcc = this.optionsforsortingFirm.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.placeholderAcc = this.placeholderAcc[0].label;
            this.idToSort = idList.toString();
        }
        //End by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
    
        
    }
    if(this.objectName == 'Deal' ){
          console.log('insde deal Sort');
        
        if(this.dealRecordTypeList.length == 0){
         this.sorting = 'deal'; //added by Tejaswini - 00034976
        orderbyClauseDeal = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderDeal = this.optionsforsortingDeals.filter(function(option) {
            return option.value == event.detail.value;
        })
        this.placeholderDeal = this.placeholderDeal[0].label;
            for(var j=0; j< this.dealSlicedData.count; j++){
                        idList.push(this.dealSlicedData[j].dealId);
                    }
                    this.idToSort = idList.toString();
            }  /* 00045074 Smoke Testing issue fix by Manonit  */
        else{  
        for(var i=0; i< this.dealRecordTypeList.length; i++)
        {
            if(this.dealRecordTypeList[i].name == event.currentTarget.dataset.name){
                this.currentIndex=i;
                for(var j=0; j< this.dealRecordTypeList[i].count; j++){
                    idList.push(this.dealRecordTypeList[i].List[j].dealId);
                }

            }
        }
         if(this.currentIndex != null && this.currentIndex != 0) {
            this.dealRecordTypeList[this.currentIndex].sortbyContact = event.detail.value; 
        }
        this.sorting = 'deal'; //added by Tejaswini - 00034976
        orderbyClauseDeal = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderContact = this.optionsforsortingDeals.filter(function(option) {
            return option.value == event.detail.value;
        })
        console.log('insde deal Sort 455');
         this.dealRecordTypeList[this.currentIndex].placeholderContact = this.placeholderContact[0].label;//this.dealRecordTypeList[this.currentIndex].placeholderContact[0].label;
            this.placeholderContact = this.optionsforsortingDeals.filter(function(option) {
                return option.value == event.detail.value;
            })
            console.log('@@Place'+this.placeholderContact)
            this.placeholderContact = this.placeholderContact[0].label;

            this.placeholderDeal = this.optionsforsortingDeals.filter(function(option) {
                return option.value == event.detail.value;
            })

            this.placeholderDeal = this.placeholderDeal[0].label;
            
            this.idToSort = idList.toString();
        }
    }
    if(this.objectName == 'Fund' ){
        
          console.log('insde fund Sort');
          console.log('@@Fund'+JSON.stringify(this.fundRecordTypeList));
        if(this.fundRecordTypeList.length == 0){
         this.sorting = 'fund'; //added by Tejaswini - 00034976
        orderbyClauseFund = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderFund = this.optionsforsortingFund.filter(function(option) {
            return option.value == event.detail.value;
        })
        this.placeholderFund = this.placeholderFund[0].label;
            for(var j=0; j< this.fundSlicedData.count; j++){
                        idList.push(this.fundSlicedData[j].fundId);
                }
                this.idToSort = idList.toString(); /* 00045074 Smoke Testing issue fix by Manonit  */
        }
        else{  
        for(var i=0; i< this.fundRecordTypeList.length; i++)
        {
            if(this.fundRecordTypeList[i].name == event.currentTarget.dataset.name){
                this.currentIndex=i;
                for(var j=0; j< this.fundRecordTypeList[i].count; j++){
                    idList.push(this.fundRecordTypeList[i].List[j].fundId);
                }

            }
        }
         if(this.currentIndex != null && this.currentIndex != 0) {
            this.fundRecordTypeList[this.currentIndex].sortbyContact = event.detail.value; 
        }
       this.sorting = 'fund'; //added by Tejaswini - 00034976
        orderbyClauseFund = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderContact = this.optionsforsortingFund.filter(function(option) {
            return option.value == event.detail.value;
        })
        
         this.fundRecordTypeList[this.currentIndex].placeholderContact = this.placeholderContact[0].label;//this.fundRecordTypeList[this.currentIndex].placeholderContact[0].label;
            this.placeholderContact = this.optionsforsortingFund.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.placeholderContact = this.placeholderContact[0].label;

            this.placeholderFund = this.optionsforsortingFund.filter(function(option) {
                return option.value == event.detail.value;
            })

            this.placeholderFund = this.placeholderFund[0].label;
            
            this.idToSort = idList.toString();


        }
        

        /*this.sorting = 'fund'; //added by Tejaswini - 00034976
        orderbyClauseFund = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderFund = this.optionsforsortingFund.filter(function(option) {
            return option.value == event.detail.value;
        })
        this.placeholderFund = this.placeholderFund[0].label;*/
    }
    if(this.objectName == 'Fundraising' ){
        console.log('inside fundraising')
        if(this.fundraisingRecordTypeList.length == 0){
        this.sorting = 'fdr'; //added by Tejaswini - 00034976
        orderbyClauseFundraising = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderfdr = this.optionsforsortingFundraising.filter(function(option) {
            return option.value == event.detail.value;
        })
        this.placeholderfdr = this.placeholderfdr[0].label;
        console.log('inside fundraising 2')
        
            for(var j=0; j< this.fdrSlicedData.count; j++){
                    idList.push(this.fdrSlicedData[j].fdrId);
                }
                this.idToSort = idList.toString();
                 console.log('inside fundraising 3')
        
        }
        else{
        for(var i=0; i< this.fundraisingRecordTypeList.length; i++)
            {
            if(this.fundraisingRecordTypeList[i].name == event.currentTarget.dataset.name){
                this.currentIndex=i;
                for(var j=0; j< this.fundraisingRecordTypeList[i].count; j++){
                    idList.push(this.fundraisingRecordTypeList[i].List[j].fdrId);
                }

            }
        }
         if(this.currentIndex != null && this.currentIndex != 0) {
            this.fundraisingRecordTypeList[this.currentIndex].sortbyContact = event.detail.value; 
        }
        this.sorting = 'fdr'; //added by Tejaswini - 00034976
        orderbyClauseFundraising = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderContact = this.optionsforsortingFundraising.filter(function(option) {
            return option.value == event.detail.value;
        })
         this.fundraisingRecordTypeList[this.currentIndex].placeholderContact = this.placeholderContact[0].label;//this.fundraisingRecordTypeList[this.currentIndex].placeholderContact[0].label;
            this.placeholderContact = this.optionsforsortingFundraising.filter(function(option) {
                return option.value == event.detail.value;
            })
            this.placeholderContact = this.placeholderContact[0].label;

            this.placeholderfdr = this.optionsforsortingFundraising.filter(function(option) {
                return option.value == event.detail.value;
            })

            this.placeholderfdr = this.placeholderfdr[0].label;
            
            this.idToSort = idList.toString();
        }

    }
    if(this.objectName == 'Contact' ){
        console.log('insde contact Sort');
        if(this.contactRecordTypeList.length == 0){
         this.sorting = 'contact'; //added by Tejaswini - 00034976
        orderbyClauseContact = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderContact = this.optionsforsortingContact.filter(function(option) {
            return option.value == event.detail.value;
        })
        this.placeholderContact = this.placeholderContact[0].label;
        for(var j=0; j< this.conSlicedData.count; j++){
                    idList.push(this.conSlicedData[j].conId);
                }
                this.idToSort = idList.toString();  /* 00045074 Smoke Testing issue fix by Manonit  */
        }
        else{  
        for(var i=0; i< this.contactRecordTypeList.length; i++)
        {
            if(this.contactRecordTypeList[i].name == event.currentTarget.dataset.name){
                this.currentIndex=i;
                for(var j=0; j< this.contactRecordTypeList[i].count; j++){
                    idList.push(this.contactRecordTypeList[i].List[j].conId);
                }

            }
        }
        console.log('@@event.detail.value--',event.detail.value,'@@@CURRINDEX',this.currentIndex);
        
         if(this.currentIndex != null && this.currentIndex != 0) {
            this.contactRecordTypeList[this.currentIndex].sortbyContact = event.detail.value; 
        }
        this.sorting = 'contact'; //added by Tejaswini - 00034976
        orderbyClauseContact = ' order by ' + fieldName +' '+ this.sortOrder;
        this.placeholderContact = this.optionsforsortingContact.filter(function(option) {
            return option.value == event.detail.value;
        })
        console.log('@@PlacehoderValue'+JSON.stringify(this.placeholderContact));
         this.contactRecordTypeList[this.currentIndex].placeholderContact = this.placeholderContact[0].label;//this.contactRecordTypeList[this.currentIndex].placeholderContact[0].label;
         console.log('555',JSON.stringify(this.contactRecordTypeList[this.currentIndex]));   
            this.placeholderContact = this.optionsforsortingContact.filter(function(option) {
                return option.value == event.detail.value;
            })

            this.placeholderContact = this.placeholderContact[0].label;
            this.placeholderAccGen = this.optionsforsortingContact.filter(function(option) {
                return option.value == event.detail.value;
            })

            this.placeholderAccGen = this.placeholderAccGen[0].label;
            
            this.idToSort = idList.toString();
        }  
    }
    console.log('@@@@ValCol'+this.idToSort+'@@@@'+this.sorting+'@@@@'+orderbyClauseFund);
    this.handleColumnHeaders(orderbyClauseFirm, orderbyClauseContact, orderbyClauseDeal, orderbyClauseFund, orderbyClauseFundraising, this.sorting, this.idToSort);
    this.sortbyContact=null; 
    if(this.currentIndex != null)
        this.accountRecordTypeList[this.currentIndex].sortbyContact = null;  
} 

//This fuction used for styling
renderedCallback() {
    console.log(this.isRendered);
    this.isRendered = true;
    const style = document.createElement('style');
    style.innerText = `.tabhead span.slds-truncate {
        display:block !important;
        }
/*Bug Id 00045746 fixed by Raju Release Bug*/
        .removeLeftBlueBorder .slds-nav-vertical__item.slds-is-active .slds-nav-vertical__action, .removeLeftBlueBorder .slds-nav-vertical__action:hover{
            box-shadow: none !important;
        }

        .text_des button.slds-button{
            color: #181818;
            cursor: text;
            text-decoration: none;
        }
        .power-btn button.slds-button{
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
            max-width: 150px !important;
            display: block !important;
            overflow: hidden !important;
        }
        .slds-button:active,
        .slds-button:focus {
            border: none !important;
            box-shadow: none !important;
        }
        .sortedbycss .slds-listbox__option-icon{
            display:none;
        }
        .sortedbycss .slds-listbox__option {
            padding: 10px 10px;
        }
        .sortedbycss .slds-listbox{
            z-index: 9;
        }
        @media only screen and (min-device-width: 1480px) and (max-device-width: 1550px) {
        .slds-table_header-fixed_container.slds-scrollable_x{
            overflow-x: hidden;
        }}
        
        .addMinus .slds-button{
            height:30px;
            width:30px;
            border: none;
        }
            
        .slds-grid_vertical-align-center{
            justify-content:center;
        }
        .addMinus .slds-icon{
            fill: #0176d3 !important;
        }
        .heightDataTable .slds-th__action{
            background: #f3f3f3 !important;
            box-shadow: none;
        }
        .heightDataTable .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus), .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus), .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus), .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus), .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus) {
            box-shadow: none;
        }
        .heightDataTable .slds-has-focus.slds-is-resizable .slds-th__action,
        .heightDataTable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .heightDataTable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .heightDataTable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .heightDataTable .slds-is-resizable .slds-th__action:focus,
        .heightDataTable .slds-is-resizable .slds-th__action:focus:hover,
        .heightDataTable .slds-table th:focus,
        .heightDataTable .slds-table th.slds-has-focus,
        .heightDataTable .slds-table [role="gridcell"]:focus,
        .heightDataTable .slds-table [role="gridcell"].slds-has-focus,
        .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover > td,
        .heightDataTable .slds-button:focus{
            box-shadow: none !important;
        } 
        .heightDataTable .slds-th__action:focus, .slds-th__action:hover,
        .heightDataTable .slds-table tr:hover{
            box-shadow: none !important;
        } 
        .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .heightDataTable  .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }
        .sortedbycss .slds-combobox__input{
            border: none;
            background: none;
            padding-top: 1px;
            padding-left: 5px;
        }
        .sortedbycss .slds-dropdown_fluid{
            min-width: 7rem !important;
            max-width: 100% !important;
            width: 100% !important;
            z-index:9;
        }
        .sortedbycss .slds-combobox__input:focus, .slds-combobox__input.slds-has-focus{
            box-shadow: none;
        }
        @media (max-width: 1512px) {
            .sortedbycss .slds-combobox__input{
                border: none;
                background: none;
                padding-top: 1px;
                color:#0176d3;
                padding-left: 3px;
                padding-right: 25px;
            }
        }
        .sortedbycss label.slds-form-element__label{
            display: none;
        }
        .sortedbycss .slds-icon-utility-down .slds-icon{
            fill:#0176d3;
        }
        .sortedbycss .slds-combobox__input-value{
            color:#0176d3;
            padding-left: 5px;
            padding-right: 25px;

        }
        .descriptiontext button.slds-button{ 

            color:#000 !important;

            white-space: nowrap;

            text-overflow: ellipsis;

            max-width: 100%;

            display: block;

            overflow: hidden;

            cursor : text;

            border: none;

        }`;
        this.template.querySelector('.main-Container')?.appendChild(style);
    
        let navigation = document.createElement('style'); 
        navigation.innerText='.removeHyperlink .slds-nav-vertical__action{text-decoration: none;padding: 10px 24px;}';
        this.template.querySelector('lightning-vertical-navigation-item-badge').appendChild(navigation);
        this.isDataTable = false;
        let DealDataTableBox = document.createElement('style');
        DealDataTableBox.innerText = '.heightDataTable .slds-table td:last-child{color: #585858; height:40px;}';
        //this.template.querySelector('lightning-datatable').appendChild(DealDataTableBox); 

}

showToast(cmp, title, message, variant){
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    cmp.dispatchEvent(event);
}
@track accountRecordTypeObjectList = [];
@track contactRecordTypeObjectList = [];
@track dealRecordTypeObjectList = [];
@track fundRecordTypeObjectList = [];
@track fundraisingRecordTypeObjectList = [];
accCols = [];
conCols = []; 
dealCols = []; 
fundCols = []; 
fdrCols = [];
themeCols = [];
clipCols = [];
fundraisingCols = [];
recordTypeCols = [];
optionsforsortingG=[];
placeholderAccGen=[];
@api recordId; 
accData=[]; 
conData=[];
dealData=[]; 
fundData=[];
fdrData=[];
themeData=[];
clipData=[];
accSlicedData=[]; 
conSlicedData=[];
dealSlicedData=[]; 
fundSlicedData=[];
fdrSlicedData=[];
themeSlicedData=[];
clipSlicedData=[];
accDataSize= 0;
conDataSize= 0;
dealDataSize= 0;
fundDataSize= 0;
fdrDataSize= 0;
themeDataSize= 0;
clipDataSize= 0;
accDataShow = false;
conDataShow=false;
dealDataShow=false;
fundDataShow=false;
fdrDataShow=false;
themeDataShow=false;
clipDataShow=false;
totalRecLength=0;
selectedContacts = [];
selectedDeals = [];
selectedFunds = [];
selectedFDRs = [];
selectedThemes = [];
selectedClips = [];
contactChecbox=true;
firmChecbox=true;
dealChecbox=true;
fundChecbox=true;
fdrChecbox=true;
themeChecbox=true;
clipChecbox=true;
addDisable = true;
enableSpinner = false;

isCallLogOpen = false;  //For opening/closing of the Log Call Notes popup
recordDetail=[];
isShowNote = false;
actId;
actObjName;
@track representAccountList;
innerAccountListShow = false;
accountRTName;
accountRTCount;
viewAllAcc=false;
viewAllCon=false;
viewAllDeal=false;
viewAllFund=false;
viewAllFDR=false;
viewAllTheme=false;
viewAllClip=false;
fundRemoveIcon=false;
contactRemoveIcon=false;
dealRemoveIcon=false;
fdrRemoveIcon=false;
themeRemoveIcon=false;
clipRemoveIcon=false;
objectName=''; //Added by Anshika Ahuja W.R.To Sorting Functionality

//placeholderContact='Last Interaction Date';
/**** Theme Page Code Starts */
connectedCallback(){
this.handleOnLoadTheme();
//this.placeholderContact=this.sortbyContact;
this.sortbyContact=null;
}

@track accountRecordTypeList=[];
@track contactRecordTypeList=[];
@track dealRecordTypeList=[];
@track fundRecordTypeList=[];
@track fundraisingRecordTypeList=[];
@track clipRecordTypeList=[];
@track themeRecordTypeList=[];

handleOnLoadTheme(){
this.sortbyContact = '';
        //Added by Tejaswini as part of 00033368
if(this.currentIndex != null)
    this.accountRecordTypeList[this.currentIndex].sortbyContact = '';
this.enableSpinner = true;
var orderbyClauseFirm = ' order by Account__r.navpeII_dev18__Last_Touchpoint__c desc';
// Added by Hema - Sorting based on navpeII_dev18__Last_Touch_Point__c field for Contact - 00038724
var orderbyClauseContact = ' order by Contact__r.navpeII_dev18__Last_Touch_Point__c desc';
var orderbyClauseDeal = ' order by Deal__r.navpeII_dev18__Stage__c desc';
var orderbyClauseFund = ' order by createddate desc';
// Added by Hema - Sorting based on Stage field for Fundraising - 00038724
var orderbyClauseFundraising = ' order by Fundraising__r.navpeII_dev18__Stage__c desc';

handleOnLoadTheme()
.then((result) => {
    this.enableSpinner = false;
    this.accountRecordTypeObjectList = (result.accountRecordTypeIdList != ''?result.accountRecordTypeIdList:'');
    this.contactRecordTypeObjectList = (result.contactRecordTypeIdList != ''? result.contactRecordTypeIdList: '');
    this.dealRecordTypeObjectList = (result.dealRecordTypeIdList !=''?result.dealRecordTypeIdList:'');
    this.fundRecordTypeObjectList = (result.fundRecordTypeIdList != ''?result.fundRecordTypeIdList:'');
    this.fundraisingRecordTypeObjectList = (result.fundraisingRecordTypeIdList !=''?result.fundraisingRecordTypeIdList:'');
    this.handleColumnHeaders(orderbyClauseFirm, orderbyClauseContact, orderbyClauseDeal, orderbyClauseFund, orderbyClauseFundraising, this.sorting,null); //added by Tejaswini - 00034976
    })
.catch((error) => {
    this.showToast(this, 'Error!', error.body.message, 'error');
    });
}
handleColumnHeaders(orderbyClauseFirm, orderbyClauseContact, orderbyClauseDeal, orderbyClauseFund, orderbyClauseFundraising, sorting, idToSort){ //added by Tejaswini - 00034976
this.enableSpinner = true;
this.accountRecordTypeListOld=this.accountRecordTypeList;
this.contactRecordTypeListOld=this.contactRecordTypeList;
this.dealRecordTypeListOld=this.dealRecordTypeList;
this.fundRecordTypeListOld=this.fundRecordTypeList;
this.fdrRecordTypeListOld=this.fundraisingRecordTypeList;
//console.log('@@880'+this.orderbyClauseFund);
let accFlag,conFlag,dealFlag,fundFlag,fdrFlag = false;

//Modified by Anshika Ahuja W.R.To Sorting functionality to use sortin and idToSort locally
handleColumnHeaders({recordId:this.recordId, orderbyClauseFirm:orderbyClauseFirm,orderbyClauseContact:orderbyClauseContact, orderbyClauseDeal:orderbyClauseDeal, orderbyClauseFund:orderbyClauseFund, orderbyClauseFundraising:orderbyClauseFundraising, sorting:sorting, idToSort:idToSort})  //added by Tejaswini - 00034976
    .then((result) => {
        this.enableSpinner = false;
        if(result){
            this.accCols =  [{ label: 'Last Interaction Date' , fieldName: 'lastInteractionDate', type: 'button', hideDefaultActions: true, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' },typeAttributes: {label: {fieldName: 'lastInteractionDate',},variant:'base' ,name:'lastInteractionDate', tooltip: {fieldName: 'lastInteractionDate'}}},
            { label: 'Interaction Notes', fieldName: 'interactionNotes', type: 'button',hideDefaultActions: true,  cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' },typeAttributes: {label: {fieldName: 'interactionNotes',},variant:'base' ,name:'interactionNotes', tooltip: {fieldName: 'interactionNotes'}}}, 
            { label: 'Log Notes', type: 'button', hideDefaultActions: true, fixedWidth: 85, cellAttributes: { alignment: 'center' }, typeAttributes: {iconName: { fieldName: 'lognoteIcon'}, variant: 'base', name:'lognoteAccount', title: 'Log Note'}}];
            if(result.accColumnHeader1){
                this.accCols.splice(0, 0, { label: result.accColumnHeader1, fieldName: 'accRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}})
            }
            if(result.accColumnHeader2){
                //this.accCols.splice(1, 0, { label: result.accColumnHeader2, fieldName: 'description', type: 'text', hideDefaultActions: true })
                this.accCols.splice(1, 0, { label: result.accColumnHeader2, fieldName: 'description', type: 'button', hideDefaultActions: true,cellAttributes: { class: 'descriptiontext' },typeAttributes: { label: { fieldName: 'description' },variant: 'base', tooltip: { fieldName: 'description' }, title: { fieldName: 'description' }}})
            
            }
            if(result.accColumnHeader3){
                this.accCols.splice(2, 0, { label: result.accColumnHeader3, fieldName: 'entityType', type: 'text', hideDefaultActions: true })
            }
            if(result.accColumnHeader4){
                //this.accCols.splice(5, 0, { label: result.accColumnHeader4, fieldName: 'themeDate', type: 'text', hideDefaultActions: true })
                this.accCols.splice(5, 0, { label: 'Added to Theme on', fieldName: 'themeDate', type: 'text', hideDefaultActions: true }) //Added by Tejaswini 00034445
            }
            this.conCols =  [{ label: 'Last Interaction Date' , fieldName: 'lastInteractionDate', type: 'button', hideDefaultActions: true, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' },typeAttributes: {label: {fieldName: 'lastInteractionDate',},variant:'base' ,name:'lastInteractionDate', tooltip: {fieldName: 'lastInteractionDate'}}},
            { label: 'Interaction Notes' , fieldName: 'interactionNotes', type: 'button',hideDefaultActions: true,  cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' },typeAttributes: {label: {fieldName: 'interactionNotes',},variant:'base' ,name:'interactionNotes', tooltip: {fieldName: 'interactionNotes'}}}, 
            { label: 'Log Notes', type: 'button', hideDefaultActions: true, fixedWidth: 85, cellAttributes: { alignment: 'center' }, typeAttributes: {iconName: { fieldName: 'lognoteIcon'}, variant: 'base', name:'lognoteContact', title: 'Log Note'}}];
            if(result.conColumnHeader1){
                this.conCols.splice(0, 0, { label: result.conColumnHeader1, fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}})    
            }
            if(result.conColumnHeader2){
                this.conCols.splice(1, 0, { label: result.conColumnHeader2, fieldName: 'accRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'accName' }, target: '_blank', tooltip: {fieldName: 'accName'}}})    
            }
            if(result.conColumnHeader3){
                //this.conCols.splice(2, 0, { label: result.conColumnHeader3, fieldName: 'description', type: 'text', hideDefaultActions: true })        
                this.conCols.splice(2, 0, { label: result.conColumnHeader3, fieldName: 'description', type: 'button', hideDefaultActions: true,  cellAttributes: { class: 'descriptiontext' },

                typeAttributes: { label: { fieldName: 'description' },variant: 'base', tooltip: { fieldName: 'description' }, title: { fieldName: 'description' }}})
            }
            if(result.conColumnHeader4){
                //this.conCols.splice(5, 0, { label: result.conColumnHeader4, fieldName: 'themeDate', type: 'text', hideDefaultActions: true })        
                this.conCols.splice(5, 0, { label: 'Added to Theme on', fieldName: 'themeDate', type: 'text', hideDefaultActions: true })  ////Added by Tejaswini 00034445      
            }
            this.dealCols =  [{ label: 'Log Notes', type: 'button', hideDefaultActions: true, fixedWidth: 85, cellAttributes: { alignment: 'center' }, typeAttributes: {iconName: { fieldName: 'lognoteIcon'}, variant: 'base', name:'lognoteDeal', title: 'Log Note'}}];
            if(result.dealColumnHeader1){
                this.dealCols.splice(0, 0, { label: result.dealColumnHeader1, fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}})    
            }
            if(result.dealColumnHeader2){
                this.dealCols.splice(1, 0, { label: result.dealColumnHeader2, fieldName: 'accRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'accName' }, target: '_blank', tooltip: {fieldName: 'accName'}}})    
            }
            if(result.dealColumnHeader3){
                this.dealCols.splice(2, 0, { label: result.dealColumnHeader3, fieldName: 'dealStage', type: 'text', hideDefaultActions: true })        
            }
            if(result.dealColumnHeader4){
               // this.dealCols.splice(3, 0, { label: result.dealColumnHeader4, fieldName: 'dealComments', type: 'text', hideDefaultActions: true })        
               this.dealCols.splice(3, 0, { label: result.dealColumnHeader4, fieldName: 'dealComments', type: 'button', hideDefaultActions: true ,cellAttributes: { class: 'descriptiontext' },

               typeAttributes: { label: { fieldName: 'dealComments' },variant: 'base', tooltip: { fieldName: 'dealComments' }, title: { fieldName: 'dealComments' }}})        
            }
            if(result.dealColumnHeader5){
                this.dealCols.splice(4, 0, { label: result.dealColumnHeader5, fieldName: 'dealDateRec', type: 'text', hideDefaultActions: true })        
            }
            if(result.dealColumnHeader6){                    
                this.dealCols.splice(5, 0, { label: 'Added to Theme on', fieldName: 'themeDate', type: 'text', hideDefaultActions: true }) //Added by Tejaswini 00034445
                //this.dealCols.splice(5, 0, { label: result.dealColumnHeader6, fieldName: 'themeDate', type: 'text', hideDefaultActions: true })        
            }
            this.fundCols =  [{ label: 'Log Notes', type: 'button', hideDefaultActions: true, fixedWidth: 85, cellAttributes: { alignment: 'center' }, typeAttributes: {iconName: { fieldName: 'lognoteIcon'}, variant: 'base', name:'lognoteFund', title: 'Log Note'}}];
            if(result.fundColumnHeader1){
                this.fundCols.splice(0, 0, { label: result.fundColumnHeader1, fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}})    
            }
            if(result.fundColumnHeader2){
                this.fundCols.splice(1, 0, { label: result.fundColumnHeader2, fieldName: 'fundVintage', type: 'text', hideDefaultActions: true})    
            }
            if(result.fundColumnHeader3){
                this.fundCols.splice(2, 0, { label: result.fundColumnHeader3, fieldName: 'fundClosingDate', type: 'text', hideDefaultActions: true })        
            }
            if(result.fundColumnHeader4){
                this.fundCols.splice(3, 0, { label: 'Added to Theme on', fieldName: 'themeDate', type: 'text', hideDefaultActions: true })  //Added by Tejaswini 00034445      
                //this.fundCols.splice(3, 0, { label: result.fundColumnHeader4, fieldName: 'themeDate', type: 'text', hideDefaultActions: true })        
            }

            this.fdrCols =  [{ label: 'Log Notes', type: 'button', hideDefaultActions: true, fixedWidth: 85, cellAttributes: { alignment: 'center' }, typeAttributes: {iconName: { fieldName: 'lognoteIcon'}, variant: 'base', name:'lognoteFDR', title: 'Log Note'}}];
            if(result.fdrColumnHeader1){
                this.fdrCols.splice(0, 0, { label: result.fdrColumnHeader1, fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}})    
            }
            if(result.fdrColumnHeader2){
                this.fdrCols.splice(1, 0, { label: result.fdrColumnHeader2, fieldName: 'accRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'accName' }, target: '_blank', tooltip: {fieldName: 'accName'}}})    
            }
            if(result.fdrColumnHeader3){
                this.fdrCols.splice(2, 0, { label: result.fdrColumnHeader3, fieldName: 'fundNameRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'fundName' }, target: '_blank', tooltip: {fieldName: 'fundName'}}})        
            }
            if(result.fdrColumnHeader4){
                this.fdrCols.splice(3, 0, { label: result.fdrColumnHeader4, fieldName: 'frdStage', type: 'text', hideDefaultActions: true })        
            }
            if(result.fdrColumnHeader5){
               // this.fdrCols.splice(4, 0, { label: result.fdrColumnHeader5, fieldName: 'frdStatusNote', type: 'text', hideDefaultActions: true })        
               this.fdrCols.splice(4, 0, { label: result.fdrColumnHeader5, fieldName: 'frdStatusNote', type: 'button', hideDefaultActions: true ,cellAttributes: { class: 'descriptiontext' },

                typeAttributes: { label: { fieldName: 'frdStatusNote' },variant: 'base', tooltip: { fieldName: 'frdStatusNote' }, title: { fieldName: 'frdStatusNote' }}})    
            }
            if(result.fdrColumnHeader6){
                this.fdrCols.splice(5, 0, { label: 'Added to Theme on', fieldName: 'themeDate', type: 'text', hideDefaultActions: true })     //Added by Tejaswini 00034445   
                //this.fdrCols.splice(5, 0, { label: result.fdrColumnHeader6, fieldName: 'themeDate', type: 'text', hideDefaultActions: true })        
            }
            
            this.themeCols =  [{ label: 'Log Notes', type: 'button', hideDefaultActions: true, fixedWidth: 85, cellAttributes: { alignment: 'center' }, typeAttributes: {iconName: { fieldName: 'lognoteIcon'}, variant: 'base', name:'lognoteTheme', title: 'Log Note'}}];
            if(result.themeColumnHeader1){
                this.themeCols.splice(0, 0, { label: result.themeColumnHeader1, fieldName: 'subjectRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'subject' }, target: '_blank', tooltip: {fieldName: 'subject'}}})    
            }
            if(result.themeColumnHeader2){
                //this.themeCols.splice(1, 0, { label: result.themeColumnHeader2, fieldName: 'description', type: 'text', hideDefaultActions: true })        
                this.themeCols.splice(1, 0, { label: result.themeColumnHeader2, fieldName: 'description', type: 'button', hideDefaultActions: true,cellAttributes: { class: 'descriptiontext' },

                typeAttributes: { label: { fieldName: 'description' },variant: 'base', tooltip: { fieldName: 'description' }, title: { fieldName: 'description' }}})  
            }
            if(result.clipColumnHeader1){
                this.clipCols.splice(0, 0, { label: result.clipColumnHeader1, fieldName: 'subjectRef', type: 'button', hideDefaultActions: true, cellAttributes: {class: 'slds-text-link slds-text-body_regular textColor'}, typeAttributes: {label: {fieldName: 'subject' }, variant:'base' ,name:'subject', tooltip: {fieldName: 'subject'}}})    
            }
            if(result.clipColumnHeader2){
                this.clipCols.splice(1, 0, { label: result.clipColumnHeader2, fieldName: 'description', type: 'button', hideDefaultActions: true, cellAttributes: { class: 'descriptiontext' },

                typeAttributes: { label: { fieldName: 'description' },variant: 'base', tooltip: { fieldName: 'description' }, title: { fieldName: 'description' }} })        
            }
			//added this.accIsAccessible check by Pavani w.r.t Security model fix
            if(result.conInfoWrapper.length > 0 &&  this.accIsAccessible){
                this.accData=[];
                let accTemp = [];
                if(orderbyClauseFirm == ' order by Account__r.navpeII_dev18__Last_Touchpoint__c desc' || orderbyClauseFirm == ' order by Account__r.navpeII_dev18__Last_Touchpoint__c DESC' || orderbyClauseFirm == ' order by Account__r.navpeII_dev18__Last_Touchpoint__c ASC' ){
                 
                    for (let recInfo of result.conInfoWrapper) {
                            if (recInfo.lastInteractionDate != '') {
                                this.accData.push({
                                    Id: recInfo.themeRecId,accId: recInfo.accId,name: recInfo.accName,accRef: recInfo.accNameRef,lastInteractionDate: recInfo.lastInteractionDate,interactionNotes: recInfo.actSubject,actId: recInfo.actId,description: recInfo.accDesc,entityType: recInfo.accEntityType,themeDate: recInfo.themeDate,lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2
                                });
                                
                            }
                            else if (recInfo.lastInteractionDate == null || recInfo.lastInteractionDate == '') {
                            accTemp.push({
                                Id: recInfo.themeRecId,accId: recInfo.accId,name: recInfo.accName,accRef: recInfo.accNameRef,lastInteractionDate: recInfo.lastInteractionDate,interactionNotes: recInfo.actSubject,actId: recInfo.actId,description: recInfo.accDesc,entityType: recInfo.accEntityType,themeDate: recInfo.themeDate,lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2
                            });
                            
                    
                        }
                    }
                    this.accData = this.accData.concat(accTemp); 
                    
            }
            else{    
                for(let recInfo of result.conInfoWrapper){
                        this.accData.push({Id: recInfo.themeRecId, accId: recInfo.accId, name: recInfo.accName, accRef: recInfo.accNameRef,lastInteractionDate: recInfo.lastInteractionDate, interactionNotes: recInfo.actSubject, actId: recInfo.actId, description: recInfo.accDesc, entityType: recInfo.accEntityType, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon, recId2: recInfo.recId2});
                    }
            }  
                //Added by Anshika Ahuja W.R.To Sorting Functionality
                if(this.objectName == "Account"){
                    this.representAccountList = this.accData;
                }
                this.accDataSize = this.accData.length;
                this.accDataShow = (this.accData.length >0)?true:false;
                this.viewAllAcc = (this.accData.length >5)?true:false;
                accFlag = true;
            }
			 //added this.conIsAccessible check by Pavani w.r.t Security model fix
            if(result.contactInfoWrapper.length > 0 && this.conIsAccessible){
                this.conData = [];
                let conTemp = [];
                this.conSlicedData=[];
                this.contactRemoveIcon=true;
                if(orderbyClauseContact == ' order by Contact__r.navpeII_dev18__Last_Touch_Point__c desc' || orderbyClauseContact == ' order by Contact__r.navpeII_dev18__Last_Touch_Point__c DESC' || orderbyClauseContact == ' order by Contact__r.navpeII_dev18__Last_Touch_Point__c ASC' ){
                    for (let recInfo of result.contactInfoWrapper) {
                            if (recInfo.lastInteractionDate != '') {
                                this.conData.push({Id: recInfo.themeRecId, conId: recInfo.conId, name: recInfo.conName, conRef: recInfo.conNameRef,accId: recInfo.accId, accName: recInfo.accName, accRef: recInfo.accNameRef, lastInteractionDate: recInfo.lastInteractionDate, interactionNotes: recInfo.actSubject, actId: recInfo.actId, description: recInfo.accDesc, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2});
                            }
                            else if (recInfo.lastInteractionDate == null || recInfo.lastInteractionDate == '') {
                                conTemp.push({Id: recInfo.themeRecId, conId: recInfo.conId, name: recInfo.conName, conRef: recInfo.conNameRef,accId: recInfo.accId, accName: recInfo.accName, accRef: recInfo.accNameRef, lastInteractionDate: recInfo.lastInteractionDate, interactionNotes: recInfo.actSubject, actId: recInfo.actId, description: recInfo.accDesc, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2});
                
                            }
                        }
                    this.conData=this.conData.concat(conTemp);   
            }
            else{    

                for(let recInfo of result.contactInfoWrapper){
                    this.conData.push({Id: recInfo.themeRecId, conId: recInfo.conId, name: recInfo.conName, conRef: recInfo.conNameRef,accId: recInfo.accId, accName: recInfo.accName, accRef: recInfo.accNameRef, lastInteractionDate: recInfo.lastInteractionDate, interactionNotes: recInfo.actSubject, actId: recInfo.actId, description: recInfo.accDesc, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2});
                }
            }
                this.conDataSize = this.conData.length;
                this.representContactList = this.conData;
                this.conDataShow = (this.conData.length >0)?true:false;
                if(this.conDataSize > 5){
                    this.conSlicedData.push(...this.conData.slice(0,5));
                    this.viewAllCon = true;
                }
                else{
                    this.conSlicedData.push(...this.conData);    
                }
                conFlag = true;
            }
			//added this.dealIsAccessible check by Pavani w.r.t Security model fix
            if(result.dealInfoWrapper.length > 0 && this.dealIsAccessible){
                this.dealData = [];
                this.dealSlicedData=[];
                this.dealRemoveIcon=true;
                for(let recInfo of result.dealInfoWrapper){
                    this.dealData.push({Id: recInfo.themeRecId, dealId: recInfo.dealId, name: recInfo.dealName, conRef: recInfo.dealNameRef,accId: recInfo.accId, accName: recInfo.accName, accRef: recInfo.accNameRef, dealStage: recInfo.dealStage, dealComments: recInfo.dealComments, dealDateRec: recInfo.dealDateRec, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2});
                }
                this.dealDataSize = this.dealData.length;
                this.representdealList = this.dealData;
                
                this.dealDataShow = (this.dealData.length >0)?true:false;
                if(this.dealDataSize > 5){
                    this.dealSlicedData.push(...this.dealData.slice(0,5));
                    this.viewAllDeal=true;
                }
                else{
                    this.dealSlicedData.push(...this.dealData);
                }
                dealFlag = true;
                
            }
			//added this.fundIsAccessible check by Pavani w.r.t Security model fix
            if(result.fundInfoWrapper.length > 0&& this.fundIsAccessible){
                this.fundData = [];
                this.fundSlicedData=[];
                this.fundRemoveIcon=true;
                for(let recInfo of result.fundInfoWrapper){
                    this.fundData.push({Id: recInfo.themeRecId, fundId: recInfo.fundId, name: recInfo.fundName, conRef: recInfo.fundNameRef,fundVintage: recInfo.fundVintage, fundClosingDate: recInfo.fundClosingDate, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2});
                }
                this.representFundList = this.fundData;
                console.log('@@representFundList',JSON.stringify(this.representFundList));
                this.fundDataSize = this.fundData.length;
                this.fundDataShow = (this.fundData.length >0)?true:false;
                if(this.fundDataSize > 5){
                    this.fundSlicedData.push(...this.fundData.slice(0,5));
                    this.viewAllFund=true;
                }
                else{
                    this.fundSlicedData.push(...this.fundData);   
                }
                fundFlag = true;
            }
			 //added this.fundraisingAccess check by Pavani w.r.t Security model fix
            if(result.fdrInfoWrapper.length > 0 && this.fundraisingAccess){
                this.fdrData = [];
                this.fdrSlicedData=[];
                this.fdrRemoveIcon=true;
                for(let recInfo of result.fdrInfoWrapper){
                    this.fdrData.push({Id: recInfo.themeRecId, fdrId: recInfo.frdId, name: recInfo.frdName, conRef: recInfo.frdNameRef,fundId: recInfo.fundId, fundName:recInfo.fundName, fundNameRef:recInfo.fundNameRef, accId: recInfo.accId, accName: recInfo.accName, accRef: recInfo.accNameRef, frdStage: recInfo.frdStage, frdStatusNote: recInfo.frdStatusNote, themeDate: recInfo.themeDate, lognoteIcon: recInfo.logNoteIcon,recId2: recInfo.recId2});
                }
                this.representFdrList = this.fdrData;
                this.fdrDataSize = this.fdrData.length;
                this.fdrDataShow = (this.fdrData.length >0)?true:false;
                if(this.fdrDataSize > 5){
                    this.fdrSlicedData.push(...this.fdrData.slice(0,5));
                    this.viewAllFDR=true;
                }
                else{
                    this.fdrSlicedData.push(...this.fdrData);
                }
                //console.log('@@@@1086')
                fdrFlag = true;
                
            }
			 //added this.themeIsAccessible check by Pavani w.r.t Security model fix
            if(result.themeInfoWrapper.length > 0 && this.themeIsAccessible){
                this.themeData = [];
                this.themeSlicedData=[];
                this.themeRemoveIcon=true;
                for(let recInfo of result.themeInfoWrapper){
                    this.themeData.push({Id: recInfo.themeRecId, themeId: recInfo.themeId, subject: recInfo.subject, subjectRef: recInfo.subjectRef, description: recInfo.description, lognoteIcon: recInfo.logNoteIcon});
                }
                this.themeDataSize = this.themeData.length;
                this.themeDataShow = (this.themeData.length >0)?true:false;
                if(this.themeDataSize > 5){
                    this.themeSlicedData.push(...this.themeData.slice(0,5));
                    this.viewAllTheme=true;
                }
                else{
                    this.themeSlicedData.push(...this.themeData);
                }
            }
			//added this.clipIsAccessible check by Pavani w.r.t Security model fix
            if(result.clipInfoWrapper.length > 0 && this.clipIsAccessible){
                this.clipData = [];
                this.clipSlicedData=[];
                this.clipRemoveIcon=true;
                for(let recInfo of result.clipInfoWrapper){
                    this.clipData.push({Id: recInfo.themeRecId, clipId: recInfo.clipId, subject: recInfo.subject, subjectRef: recInfo.subjectRef, description: recInfo.description, lognoteIcon: recInfo.logNoteIcon});
                }
                this.clipDataSize = this.clipData.length;
                this.clipDataShow = (this.clipData.length >0)?true:false;
                if(this.clipDataSize > 5){
                    this.clipSlicedData.push(...this.clipData.slice(0,5));
                    this.viewAllClip=true;
                }
                else{
                    this.clipSlicedData.push(...this.clipData);
                }
            }
            if(this.totalRecLength==0){
            this.totalRecLength =this.conData.length + this.accData.length + this.dealData.length + this.fundData.length + this.fdrData.length + this.themeData.length + this.clipData.length;
            }
            /****** Section for Account Record Type Mapping Start */
            var copyArray = [...this.accData];
            if(copyArray.length == 0){
                //Added by Tejaswini as part of 00033368        
                for (var i = 0; i < this.accountRecordTypeObjectList.length; i++) {
                    var obj = {
                        name: "",
                        count: "",
                        List: [],
                        hasList: false,
                        veiwMore: false,
                        outerList: [],
                        outerCount: "",
                        sortbyContact: "",
                        placeholderContact:"Last Interaction Date"
                    };
                    var countValue = 0;
                    obj.name = this.accountRecordTypeObjectList[i];
                    obj.count = 0;
                    this.accountRecordTypeList.push(obj);
                }

            }
            
            else{
            //Added by Tejaswini as part of 00033368
            let accountRecordTypeListTemp=[];
            for (var i = 0; i < this.accountRecordTypeObjectList.length; i++) {
                var obj = {
                    name: "",
                    count: "",
                    List: [],
                    outerList: [],
                    veiwMore: false,
                    showTable: false,
                    showRemoveIcon: false,
                    sortbyContact: "",
                    placeholderContact: "Last Interaction Date",
                    recordTypeCompCheck: false,   //Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
                    recordTypeAdvisorCheck: false  //Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
                };
                //Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
                if(this.accountRecordTypeObjectList[i] == 'Company'){
                    obj.recordTypeCompCheck = true;
                    obj.recordTypeAdvisorCheck = false;
                }
                else if(this.accountRecordTypeObjectList[i] == 'Intermediary'){
                    obj.recordTypeAdvisorCheck = true;
                    obj.recordTypeCompCheck = false;
                }
                else if(this.accountRecordTypeObjectList[i] != 'Intermediary' && this.accountRecordTypeObjectList[i] != 'Company'){
                    obj.recordTypeAdvisorCheck = false;
                    obj.recordTypeCompCheck = false;
                }
                //End by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
                var countValue = 0;
                for (var j = 0; j < copyArray.length; j++) {
                    if (JSON.stringify(copyArray[j].recId2) != undefined) {
                            if (this.accountRecordTypeObjectList[i] == copyArray[j].recId2) {
                                countValue++;
                                if (obj.List.length < 5) {
                                    //obj.veiwMore = false;
                                    obj.outerList.push(copyArray[j]);
                                }
                                /*else if(obj.List.length > 5){
                                    obj.veiwMore = true;
                                }*/
                                obj.List.push(copyArray[j]);
                                
                            }
                            obj.name = this.accountRecordTypeObjectList[i];
                            obj.count = countValue;
                        }
                        if (j == copyArray.length - 1) {
                            if(obj.List.length > 0 ){
                                obj.veiwMore = false;
                                if(obj.List.length > 5 ){
                                    obj.veiwMore = true;
                                }
                                obj.showTable = true;
                                obj.showRemoveIcon = true;
                            }
                            else{
                                obj.showTable = false;
                                obj.showRemoveIcon = false;
                            }
                            accountRecordTypeListTemp.push(obj);
                            this.accountRecordTypeList = accountRecordTypeListTemp;
                        }                            
                    
                }
            }
            }
           // }
        /****** Section for Account Mapping End dealRecordTypeList */
        
        this.contactRecordTypeList = this.objectRecTypeMapping(this.contactRecordTypeObjectList,this.conData,'Contact');
        if(conFlag && this.contactRecordTypeObjectList.length > 0 ){
        //this.contactRecordTypeList = this.objectRecTypeMapping(this.contactRecordTypeObjectList,this.conData,'Contact');
        
        if(this.currentIndex!=null){
        let contactRecordTypeListTemp2=[];
        for(var i=0; i< this.currentIndex; i++)
        {
            contactRecordTypeListTemp2.push(this.contactRecordTypeListOld[i]);
        }
        contactRecordTypeListTemp2.push(this.contactRecordTypeList[this.currentIndex]);
        for(var j=this.currentIndex+1; j< this.contactRecordTypeList.length; j++)
        {
            contactRecordTypeListTemp2.push(this.contactRecordTypeListOld[j]);
        }
        this.contactRecordTypeList=contactRecordTypeListTemp2;
        if(this.contactRecordTypeList){
            console.log('1206')
            this.contactRecordTypeList[this.currentIndex].placeholderContact =  this.contactRecordTypeListOld[this.currentIndex].placeholderContact;
        }
        
        }
        }
       /* else if(this.contactRecordTypeObjectList.length == 0){
           this.contactRecordTypeList = null; 
        }*/
        
        
        //Added by Tejaswini - 00033368

        /* Adding for Deal Start*/
        console.log('1238',JSON.stringify(this.dealRecordTypeList));
        this.dealRecordTypeList = this.objectRecTypeMapping(this.dealRecordTypeObjectList,this.dealData,'Deal');
        
        if(dealFlag && this.dealRecordTypeObjectList.length > 0){
        //this.dealRecordTypeList = this.objectRecTypeMapping(this.dealRecordTypeObjectList,this.dealData,'Deal');
            
        if(this.currentIndex!=null){
        var dealRecordTypeListTemp2=[];
        for(var i=0; i< this.currentIndex; i++)
        {
            dealRecordTypeListTemp2.push(this.dealRecordTypeListOld[i]);
        }
        dealRecordTypeListTemp2.push(this.dealRecordTypeList[this.currentIndex]);
        for(var j=this.currentIndex+1; j< this.dealRecordTypeList.length; j++)
        {
            dealRecordTypeListTemp2.push(this.dealRecordTypeListOld[j]);
        }
        this.dealRecordTypeList=dealRecordTypeListTemp2;
        if(this.dealRecordTypeList){
            this.dealRecordTypeList[this.currentIndex].placeholderContact =  this.dealRecordTypeListOld[this.currentIndex].placeholderContact;
        }
        
        //this.contactRecordTypeList=this.valueMapping(this.contactRecordTypeList,this.currentIndex);

        }
        }
       /* else if(this.dealRecordTypeObjectList.length == 0){
           this.dealRecordTypeList = null; 
        }*/

        /* Adding for Deal End*/

        /* Adding for Fund Start*/
        console.log('!!1314size',this.fundRecordTypeList.length)
        this.fundRecordTypeList = this.objectRecTypeMapping(this.fundRecordTypeObjectList,this.fundData,'Fund');
        
        if(fundFlag && this.fundRecordTypeObjectList.length > 0){
        if(this.currentIndex!=null){
        var fundRecordTypeListTemp2=[];
        for(var i=0; i< this.currentIndex; i++)
        {
            fundRecordTypeListTemp2.push(this.fundRecordTypeListOld[i]);
        }
        fundRecordTypeListTemp2.push(this.fundRecordTypeList[this.currentIndex]);
        for(var j=this.currentIndex+1; j< this.fundRecordTypeList.length; j++)
        {
            fundRecordTypeListTemp2.push(this.fundRecordTypeListOld[j]);
        }
        this.fundRecordTypeList=fundRecordTypeListTemp2;
        if(this.fundRecordTypeList){
            this.fundRecordTypeList[this.currentIndex].placeholderContact =  this.fundRecordTypeListOld[this.currentIndex].placeholderContact;
        }
        
        //this.contactRecordTypeList=this.valueMapping(this.contactRecordTypeList,this.currentIndex);

        }
        }
      /*  else if(this.fundRecordTypeObjectList.length == 0){
           this.fundraisingRecordTypeList = null; 
        }*/
        
        console.log('!!1339'+this.fundRecordTypeList)
        /* Adding for Fund End*/
        
        /* Adding for FundRaising Start*/
        console.log('!!1350'+this.fundraisingRecordTypeList)
        this.fundraisingRecordTypeList = this.objectRecTypeMapping(this.fundraisingRecordTypeObjectList,this.fdrData,'Fundraising');
        
        if(fdrFlag && this.fundraisingRecordTypeObjectList.length > 0 ){

        //this.fundraisingRecordTypeList = this.objectRecTypeMapping(this.fundraisingRecordTypeObjectList,this.fdrData,'Fundraising');
            
        if(this.currentIndex!=null){
        var fdrRecordTypeListTemp2=[];
        for(var i=0; i< this.currentIndex; i++)
        {
            fdrRecordTypeListTemp2.push(this.fdrRecordTypeListOld[i]);
        }
        fdrRecordTypeListTemp2.push(this.fundraisingRecordTypeList[this.currentIndex]);
        for(var j=this.currentIndex+1; j< this.fundRecordTypeList.length; j++)
        {
            fdrRecordTypeListTemp2.push(this.fdrRecordTypeListOld[j]);
        }
        this.fundraisingRecordTypeList=fdrRecordTypeListTemp2;
        if(this.fundraisingRecordTypeList){
            this.fundraisingRecordTypeList[this.currentIndex].placeholderContact =  this.fdrRecordTypeListOld[this.currentIndex].placeholderContact;
        }
        //this.contactRecordTypeList=this.valueMapping(this.contactRecordTypeList,this.currentIndex);

        }
        }
      /*  else if(this.fundraisingRecordTypeObjectList.length == 0){
           this.fundraisingRecordTypeList = null; 
        }*/
        
        /* Adding for FundRaising  End*/
        if(this.currentIndex!=null && accFlag){
         //   console.log('1288',this.currentIndex);
        let accountRecordTypeListTemp2=[];
      //  console.log('1290',JSON.stringify(this.accountRecordTypeListOld));
        
        for(var i=0; i< this.currentIndex; i++)
        {
            accountRecordTypeListTemp2.push(this.accountRecordTypeListOld[i]);
        }
        accountRecordTypeListTemp2.push(this.accountRecordTypeList[this.currentIndex]);
        for(var j=this.currentIndex+1; j< this.accountRecordTypeList.length; j++)
        {
            accountRecordTypeListTemp2.push(this.accountRecordTypeListOld[j]);
        }
        this.accountRecordTypeList=accountRecordTypeListTemp2;
        this.accountRecordTypeList[this.currentIndex].placeholderContact =  this.accountRecordTypeListOld[this.currentIndex].placeholderContact;
        }
        this.sortbyContact='';
        
       if(this.contactRecordTypeList.length==0)
         this.isShowContactObject=true;

       if(this.dealRecordTypeList.length==0)
         this.isShowDealObject=true;

       if(this.fundRecordTypeList.length==0)
         this.isShowfundObject=true;

        if(this.fundraisingRecordTypeList.length==0)
         this.isShowFundraisingObject=true;  
        
        }
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        });
    }

onClickFirmTableChange(event){
this.isDeafultGrid = false;
this.isDataTableFirmClick = true;
this.isDataTableContactClick = false;
this.isDataTableDealClick = false;
this.isDataTableFundraisingClick = false;
this.isDataTableClipClick  = false;  
this.isDataTableThemeClick = false;
this.isDataTableFundClick  = false;
var data = event.currentTarget.dataset.name;
this.accountRTName = data;
//Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
this.placeholderAcc = 'Last Interaction Date';
if(this.accountRTName == 'Company'){
    this.recordTypeCompCheck = true;
    this.recordTypeAdvisorCheck = false;
}
else if(this.accountRTName == 'Intermediary'){
    this.recordTypeAdvisorCheck = true;
    this.recordTypeCompCheck = false;
}
else if(this.accountRTName != 'Intermediary' && this.accountRTName != 'Company'){
    this.recordTypeCompCheck = false;
    this.recordTypeAdvisorCheck = false;    
}
//End by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active");
this.representAccountList = [];
this.innerAccountListShow = false;
var copyRecordTypeObjectListData = [...this.accountRecordTypeList];
for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
    if (data == copyRecordTypeObjectListData[i].name) {
        this.representAccountList = copyRecordTypeObjectListData[i].List;
        this.accountRTCount = copyRecordTypeObjectListData[i].count;
        if (this.representAccountList.length >= 1) {
            this.innerAccountListShow = true;
        }
    }
}
}
representContactList;
innerContactListShow=false;
contactRTCount;
contactRTName;

onClickContactTableChange(event){
this.isDataTableContactClick = true;
this.addDisable = true;
this.isDeafultGrid = false;
//this.isDataTableContactClick = true;
this.isDataTableFirmClick = false;
this.isDataTableDealClick = false;
this.isDataTableFundraisingClick = false;
this.isDataTableClipClick  = false;  
this.isDataTableThemeClick = false;
this.isDataTableFundClick  = false;
var data = event.currentTarget.dataset.name;
this.contactRTName=data;
this.placeholderContact = 'Last Interaction Date';
let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active"); 
this.representContactList = [];
this.innerContactListShow = false;
var copyRecordTypeObjectListData = [...this.contactRecordTypeList];
for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
    if (data == copyRecordTypeObjectListData[i].name) {
        this.representContactList = copyRecordTypeObjectListData[i].List;
        this.contactRTCount = copyRecordTypeObjectListData[i].count;
        if (this.representContactList.length >= 1) {
            this.innerContactListShow = true;
        }
    }
}

}

representdealList;
innerDealListShow=false;
dealRTCount;
dealRTName;
onClickDealtableChange(event){
this.addDisable = true;
this.isDeafultGrid = false;
this.isDataTableFirmClick = false;
this.isDataTableContactClick = false;
this.isDataTableDealClick = true;
this.isDataTableFundraisingClick = false;
this.isDataTableClipClick  = false;  
this.isDataTableThemeClick = false;
this.isDataTableFundClick  = false;
var data = event.currentTarget.dataset.name;
this.dealRTName=data;
this.placeholderdeal = 'Stage';

let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active");
this.representdealList = [];
this.innerDealListShow = false;
var copyRecordTypeObjectListData = [...this.dealRecordTypeList];
for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
    if (data == copyRecordTypeObjectListData[i].name) {
        this.representdealList = copyRecordTypeObjectListData[i].List;
        this.dealRTCount = copyRecordTypeObjectListData[i].count;
        if (this.representdealList.length >= 1) {
            this.innerDealListShow = true;
        }
    }
}    
}
representFundList;
innerFundListShow=false;
fundRTCount;
fundRTName;
onClickFundTableChange(event){
this.isDeafultGrid = false;
this.isDataTableFirmClick = false;
this.isDataTableContactClick = false;
this.isDataTableDealClick = false;
this.isDataTableFundraisingClick = false;   
this.isDataTableThemeClick = false; 
this.isDataTableClipClick  = false;
this.isDataTableFundClick  = true;
var data = event.currentTarget.dataset.name;
this.fundRTName=data;
this.placeholderFund = 'Add to Theme';
let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active");
this.representfundList = [];
this.innerFundListShow = false;
var copyRecordTypeObjectListData = [...this.fundRecordTypeList];
for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
    if (data == copyRecordTypeObjectListData[i].name) {
        this.representFundList = copyRecordTypeObjectListData[i].List;
        this.fundRTCount = copyRecordTypeObjectListData[i].count;
        if (this.representFundList.length >= 1) {
            this.innerFundListShow = true;
        }
    }
}    
}
representFdrList;
innerFdrListShow=false;
fdrRTCount;
fdrRTName;
onClickFundraisingTableChange(event){
this.isDeafultGrid = false;
this.isDataTableFirmClick = false;
this.isDataTableContactClick = false;
this.isDataTableDealClick = false;
this.isDataTableThemeClick = false;
this.isDataTableClipClick  = false;  
this.isDataTableFundraisingClick = true;
this.isDataTableFundClick  = false;
var data = event.currentTarget.dataset.name;
this.fdrRTName=data;
this.placeholderfdr = 'Stage';
let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active");
this.representFdrList = [];
this.innerFdrListShow = false;
var copyRecordTypeObjectListData = [...this.fundraisingRecordTypeList];
for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
    if (data == copyRecordTypeObjectListData[i].name) {
        this.representFdrList = copyRecordTypeObjectListData[i].List;
        this.fdrRTCount = copyRecordTypeObjectListData[i].count;
        if (this.representFdrList.length >= 1) {
            this.innerFdrListShow = true;
        }
    }
}  
}

onClickThemeTableChange(event){
this.isDeafultGrid = false;
this.isDataTableFirmClick = false;
this.isDataTableContactClick = false;
this.isDataTableDealClick = false;
this.isDataTableFundraisingClick = false; 
this.isDataTableClipClick  = false;    
this.isDataTableThemeClick = true;
this.isDataTableFundClick  = false; 
var data = event.currentTarget.dataset.name;
let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active");
}

onClickClipTableChange(event){
this.isDeafultGrid = false;
this.isDataTableFirmClick = false;
this.isDataTableContactClick = false;
this.isDataTableDealClick = false;
this.isDataTableFundraisingClick = false;   
this.isDataTableThemeClick = false; 
this.isDataTableClipClick  = true;
this.isDataTableFundClick  = false; 
var data = event.currentTarget.dataset.name;
let strMaking='[data-id="'+data+'"]';
const element = this.template.querySelector(strMaking);		
const element1 = this.template.querySelector('[data-id="all_id"]');		
element1.classList.remove("slds-is-active");		
element.classList.add("slds-is-active"); 
}



delFirms(event) {
this.onClickFirmTableChange(event);
this.cancelSave = true;
this.firmChecbox = false;
this.contactChecbox = false;
this.fdrChecbox = false;
this.fundChecbox = false;
this.dealChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.addDisable = false;
}

delContacts(event) {
this.onClickContactTableChange(event);
this.cancelSave = true;
this.contactChecbox = false;
this.firmChecbox = false;
this.fdrChecbox = false;
this.fundChecbox = false;
this.dealChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.addDisable = false;
}

delDeals(event) {
this.onClickDealtableChange(event);
this.fundChecbox = false;
this.firmChecbox = false;
this.dealChecbox = false;
this.cancelSave = true;
this.addDisable = false;
this.fdrChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.contactChecbox = false;
}

delFund(event) {
this.onClickFundTableChange(event);
this.fundChecbox = false;
this.firmChecbox = false;
this.dealChecbox = false;
this.cancelSave = true;
this.addDisable = false;
this.fdrChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.contactChecbox = false;
}

delFdr(event) {
this.onClickFundraisingTableChange(event);
this.fundChecbox = false;
this.firmChecbox = false;
this.dealChecbox = false;
this.cancelSave = true;
this.addDisable = false;
this.fdrChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.contactChecbox = false;
}

delTheme(event) {
this.onClickThemeTableChange(event);
this.fundChecbox = false;
this.dealChecbox = false;
this.firmChecbox = false;
this.cancelSave = true;
this.addDisable = false;
this.fdrChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.contactChecbox = false;
}

delClip(event) {
this.onClickClipTableChange(event);
this.fundChecbox = false;
this.firmChecbox = false;
this.dealChecbox = false;
this.cancelSave = true;
this.addDisable = false;
this.fdrChecbox = false;
this.clipChecbox = false;
this.themeChecbox = false;
this.contactChecbox = false;
}

removeContacts(){
let themeRelToDelete = [];
    this.selectedContacts.map(item=>{
        themeRelToDelete.push(item.Id);
    });
    if(themeRelToDelete.length == 0){
        this.showToast(this, 'Info!', 'Please select atleast 1 Record to delete!', 'info');    
    }
    else{
        deleteThemeRelations({themeRelToDelete : themeRelToDelete})
        .then(result => {
                this.showToast(this, 'Success', 'Record was removed.', 'Success');
                this.template.querySelector('lightning-datatable').selectedRows = [];
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        actionName: 'view'
                    }
                });
            }).catch(error => {
                this.showToast(this, 'Error!', error.body.pageErrors[0].message, 'error');
            });
    }
}

cancelSelection(){
this.clipChecbox = true;
this.contactChecbox = true;
this.firmChecbox = true;
this.fdrChecbox = true;
this.fundChecbox = true;
this.dealChecbox = true;
this.themeChecbox = true;
this.cancelSave = false;
this.addDisable = true;
this[NavigationMixin.Navigate]({
    type: 'standard__recordPage',
    attributes: {
        recordId: this.recordId,
        actionName: 'view'
    }
});
}


handleContactSelection(event){
this.selectedContacts = JSON.parse(JSON.stringify(event.detail.selectedRows));
}

//Samiulla Pathan:
//Below method will create List of export record, that we are going to pass to export functionality
@api createExportRecords(){
    this.exportThemeRecord = false;
    this.allExportDataList = [];
    this.allCategoryToDisplay = [];
    this.fieldLabelArray = {};
    var listOfFields = this.createListOfLabels(this.accCols, 'Account');
    if(listOfFields.length > 0){
        this.fieldLabelArray['Account']=listOfFields;
    }
    
    listOfFields = this.createListOfLabels(this.conCols, 'Contact');
    
    if(listOfFields.length > 0){
        this.fieldLabelArray['Contact']=listOfFields;
    }
    listOfFields =  this.createListOfLabels(this.dealCols, 'Deal');
    if(listOfFields.length > 0){
        this.fieldLabelArray['Deal']=listOfFields;
    }
    listOfFields = this.createListOfLabels(this.fundCols, 'Fund');
    if(listOfFields.length > 0){
        this.fieldLabelArray['Fund']=listOfFields;
    }

    listOfFields = this.createListOfLabels(this.fdrCols, 'Fundraising');
    if(listOfFields.length > 0){
        this.fieldLabelArray['Fundraising']=listOfFields;
    }

    listOfFields = this.createListOfLabels(this.themeCols, 'Theme');
    if(listOfFields.length > 0){
        this.fieldLabelArray['Theme']=listOfFields;
    }

    listOfFields = this.createListOfLabels(this.clipCols, 'Clip');
    if(listOfFields.length > 0){
        this.fieldLabelArray['Clip']=listOfFields;
    }

    
    try{
    //Create map record for Account Object based on Record type
    // Start --- Updated by Kushal on 27-05-23 for 00039995
    var mainMap = this.processAccountRecord(this.accData);
    mainMap.sort(function(a, b) {
        var textA = a.key.toUpperCase();
        var textB = b.key.toUpperCase();
        return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
    });
    if(mainMap.length > 0){
        for(var j=0;j<mainMap.length;j++){
            let recordTypeMap = {};
            recordTypeMap['allCategoriers'] = mainMap[j].key;
            recordTypeMap['List'] = mainMap[j].value;
            recordTypeMap['object'] = 'Account';
            this.allExportDataList.push(recordTypeMap);
        }
    }
    // End --- Updated by Kushal on 27-05-23 for 00039995
    //End
    console.log('Data ::: ')
    //Create map record for Contact Object
    if(this.conData.length > 0){
        this.allExportDataList.push(this.createMapRecords('Contact',this.conData, {'name':'Name','description':'description','lastInteractionDate':'lastInteractionDate','interactionNotes':'interactionNotes','themeDate':'themeDate'}, 'Contact')); 
    }
    //Create map record for Deal/Pipeline__c Object
    if(this.dealData.length > 0){
        this.allExportDataList.push(this.createMapRecords('Deal',this.dealData, {'name':'Name','accName':'Company','dealStage':'Stage','dealComments':'dealComments','dealDateRec':'dealDateRec', 'themeDate':'themeDate'}, 'Deal')); 
    }
    //Create map record for Fund Object
    if(this.fundData.length > 0){
        this.allExportDataList.push(this.createMapRecords('Fund',this.fundData, {'name':'Name','fundVintage':'navpeII_dev18__Vintage_Year__c','fundClosingDate':'closingData','themeDate':'createdData'}, 'Fund'));
    }
    //Create map record for Fundraisings Object
    if(this.fdrData.length > 0){
        this.allExportDataList.push(this.createMapRecords('Fundraising',this.fdrData, {'name':'Name','accName':'navpeII_dev18__Legal_Name__c','fundName':'FundName','frdStage':'Stage','frdStatusNote':'navpeII_dev18__Status_Notes__c','themeDate':'createdDate'}, 'Fundraising'));
    }
    //Create map record for Theme Object
    if(this.themeData.length > 0){
        this.allExportDataList.push(this.createMapRecords('Theme',this.themeData, {'subject':'Subject', 'description':'Comments'}, 'Theme'));
    }
    //Create map record for Clip Object
    if(this.clipData.length > 0){
        this.allExportDataList.push(this.createMapRecords('Clip',this.clipData,{'subject':'Subject', 'description':'Comments'}, 'Clip'));
    }
    this.createAllCategoryRecordToDisplayToPopup(this.allExportDataList);
    // const objChild = this.template.querySelector('c-export-Theme-Pop');
    // objChild.openModal();
    this.exportThemeRecord = true;
    }catch(err){
    }
}

// Start --- Added by Kushal on 27-05-23 for 00039995
processAccountRecord(records){    
    var keyRecordValue = [];
    const mainMap = [];
    
    for(var i=0;i<records.length;i++){
        var accRecordData = [];
        if(records[i].recId2 != ''){
            if(keyRecordValue.includes(records[i].recId2)){
                for(var j=0;j<mainMap.length;j++){
                    if(mainMap[j].key == records[i].recId2){
                        accRecordData = mainMap[j].value;
                        accRecordData.push(records[i]);
                        mainMap[j].value = accRecordData;
                    }
                }            
            }else{
                accRecordData.push(records[i]);
                mainMap.push({key:records[i].recId2, value:accRecordData});
            }        
            keyRecordValue.push(records[i].recId2);
        }        
    }
    return mainMap;    
}
// End --- Added by Kushal on 27-05-23 for 00039995
//Create json structure for accound object followed by record type
//If there is no records found this will return null
//Parameter to be pass here is : 
//record : holds the data that need to be process
//category : Category Name prefix with All
//object : Name of the Object (For this method this will be Account)
//recordType: Name of the Account object record type
//compareKeyMap : Holds the all key and value in json format and data will be generated as per this value
accountRecords(record, category, object, recordType, compareKeyMap){
    var recordCount = 0;
    var recordTypeMap = {};
    var listRecordData = {};
    var accountRecords = [];
    try{
        for(var i=0;i<record.length;i++){
            var accRecordData = {};
            if(record[i].recId2 === recordType){
                accountRecords.push(record[i]);
                listRecordData[''+recordCount]=accRecordData;
                recordCount = recordCount + 1;
            }
        }
        if(recordCount > 0){
            recordTypeMap['allCategoriers'] = category;
            recordTypeMap['List'] = accountRecords;
            recordTypeMap['object'] = object;
            return recordTypeMap;
        }
    }catch(error){
        console.log('error :: '+error);
    }  
}
//Below method will create json structure for Contact, Deal, fund, Fundraisings, Themes and Clip object
//Parameter to be pass here is : 
//allCategoried : Category Name prefix with All
//records : holds the data that need to be process
//compareKeyMap : Holds the all key and value in json format and data will be generated as per this value
//objectName : This is object name such as Contact, Deal, fund, Fundraisings etc
createMapRecords(allCategoried, records, compareKeyMap, objectName){
    var dataCount = 0;
    var typeMap = {};
    var listData = {};
    try{
        typeMap['allCategoriers'] = allCategoried;
        for(var i=0;i<records.length;i++){
            var clipRecordDataMap = {};
            for(var key in records[i]){
                if(compareKeyMap[key]){
                    if(records[i][key]){
                        clipRecordDataMap[compareKeyMap[key]]=records[i][key];
                    }else{
                        clipRecordDataMap[compareKeyMap[key]]=' ';
                    }
                }
            } 
            listData[''+dataCount]=clipRecordDataMap;
            dataCount = dataCount + 1;
        }
        typeMap['List'] = records;
        typeMap['object'] = objectName;
        return typeMap;
    }catch(error){
        console.log('error :: '+error);
    }
}
//This method will create json records which we are going to display on theme export popup
//Parameter to be pass here is : 
//exportRecords : JSON records which is generated by createMapRecords() and accountRecords() Method
createAllCategoryRecordToDisplayToPopup(exportRecords){
    for(var i = 0;i<exportRecords.length;i++){
        var categoryMap = {}
        categoryMap['id'] = i + 1;
        categoryMap['allCategoriers'] = exportRecords[i].allCategoriers;
        categoryMap['object'] = exportRecords[i].object;
        this.allCategoryToDisplay.push(categoryMap);
    }
}

createListOfLabels(objectFieldLabelArr, ObjectName){
    try{
        var objectFieldsArr = [];
        for(var i =0;i<objectFieldLabelArr.length;i++){
            var objectFieldMap = {};
            if(objectFieldLabelArr[i]['label'] != 'Log Notes'){
                objectFieldMap['fieldLabel'] = objectFieldLabelArr[i]['label'];
                if(objectFieldLabelArr[i]['typeAttributes']){
                    objectFieldMap['fieldName'] = objectFieldLabelArr[i]['typeAttributes']['label']['fieldName'];
                
                }else{
                    objectFieldMap['fieldName'] = objectFieldLabelArr[i]['fieldName'];
                }
            }
            
            objectFieldsArr.push(objectFieldMap);
        }
        return objectFieldsArr;
    }catch(err){
        console.error('Error ::: '+JSON.stringify(err));
    }
}

//This method called by event dispatcher of exportThemePop component to close export theme popup 
closePopup(){
    this.exportThemeRecord = false;
}
/**** Theme Page Code Ends */
/* Category on Contact Object */

objectRecTypeMapping(objRecTypeObjList, copyArray,objName){
    let accountRecordTypeListTemp=[];
       for (let i = 0; i < objRecTypeObjList.length; i++) {
                  var obj = {
                      name: "",
                      count: "",
                      List: [],
                      outerList: [],
                      veiwMore: false,
                      showTable: false,
                      showRemoveIcon: false,
                      sortbyContact: "",
                      placeholderContact: objName === 'Fund' ? "Add To Theme": objName !== 'Contact'? "Stage" :  "Last Interaction Date",
                      recordTypeCompCheck: false,   //Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
                      recordTypeAdvisorCheck: false  //Modified by Anshika Ahuja W.R.To Critical_Bug# 00035298,00035297
                  };
                  let countValue = 0;
                  if(copyArray.length == 0){
                      obj.name = objRecTypeObjList[i];
                      obj.count = countValue; 
                      accountRecordTypeListTemp.push(obj);       
                  }
                  for (let j = 0; j < copyArray.length; j++) {
                     if (JSON.stringify(copyArray[j].recId2) != undefined) {
                              if (objRecTypeObjList[i] == copyArray[j].recId2) {
                                  countValue++;
                                  if (obj.List.length < 5) {
                                      //obj.veiwMore = false;
                                      obj.outerList.push(copyArray[j]);
                                  }
                                  /*else if(obj.List.length > 5){
                                      obj.veiwMore = true;
                                  }*/
                                  obj.List.push(copyArray[j]);
                                  
                              }
                              obj.name = objRecTypeObjList[i];
                              obj.count = countValue;
                          }
                          if (j == copyArray.length - 1) {
                              if(obj.List.length > 0 ){
                                  obj.veiwMore = false;
                                  if(obj.List.length > 5 ){
                                      obj.veiwMore = true;
                                  }
                                  obj.showTable = true;
                                  obj.showRemoveIcon = true;
                              }
                              else{
                                  obj.showTable = false;
                                  obj.showRemoveIcon = false;
                              }
                              accountRecordTypeListTemp.push(obj);
                             // this.accountRecordTypeList = accountRecordTypeListTemp;
                          }  
                         // accountRecordTypeListTemp.push(obj);                          
                      
                  }
              }
              console.log('1918',JSON.stringify(accountRecordTypeListTemp));
              return accountRecordTypeListTemp;
  }
 

}