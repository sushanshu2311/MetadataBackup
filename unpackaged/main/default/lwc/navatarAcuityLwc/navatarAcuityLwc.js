import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import handleOnLoadInfo from '@salesforce/apex/NavatarAcuityCtrl.handleOnLoadInfo';
import processConInfo from '@salesforce/apex/NavatarAcuityCtrl.processConInfo';
import handleInteractionsInfo from '@salesforce/apex/NavatarAcuityCtrl.handleInteractionsInfo';
import processDealSecInfo from '@salesforce/apex/NavatarAcuityCtrl.processDealSecInfo';
import handlePeopleRefInfo from '@salesforce/apex/NavatarAcuityCtrl.handlePeopleRefInfo';
import handleDealsRefInfo from '@salesforce/apex/NavatarAcuityCtrl.handleDealsRefInfo';
import handleThemesRefInfo from '@salesforce/apex/NavatarAcuityCtrl.handleThemesRefInfo';
import handleClipsRefInfo from '@salesforce/apex/NavatarAcuityCtrl.handleClipsRefInfo';
import deleteFundraisingRecord from '@salesforce/apex/NavatarAcuityCtrl.deleteFundraisingRecord';
import { publish, MessageContext } from "lightning/messageService";
import ICON_CHANNEL from "@salesforce/messageChannel/navatarLwcChannel__c";
import { getObjectInfo, getObjectInfos } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import FUNDRAISINGCONTACT_INFO from '@salesforce/schema/Fundraising_Contact__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ROLE_FIELD from "@salesforce/schema/Fundraising_Contact__c.Role__c";
import processDealTeamEXTInfo from '@salesforce/apex/NavatarAcuityCtrl.processDealTeamEXTInfo';
import processDealInfo from '@salesforce/apex/NavatarAcuityCtrl.processDealInfo';
import processDealTeamInfo from '@salesforce/apex/NavatarAcuityCtrl.processDealTeamInfo';
import deleteDealTeamRecord from '@salesforce/apex/NavatarAcuityCtrl.deleteDealTeamRecord';
import DEALTEAM_INFO from '@salesforce/schema/Deal_Team__c';
import DT_ROLE_FIELD from "@salesforce/schema/Deal_Team__c.Team_Member_Role__c";
import processFdrInfo from '@salesforce/apex/NavatarAcuityCtrl.processFdrInfo';
import FUNDRAISING_INFO from '@salesforce/schema/Fundraising__c';
import STAGE_FIELD from "@salesforce/schema/Fundraising__c.Stage__c";
import deleteFundraisingContactRecord from '@salesforce/apex/NavatarAcuityCtrl.deleteFundraisingContactRecord';
import DEAL_INFO from '@salesforce/schema/Pipeline__c';
import FUND_INFO from '@salesforce/schema/Fund__c';
import THEME_INFO from '@salesforce/schema/Theme__c';
import CLIP_INFO from '@salesforce/schema/Clip__c';
import FUNDRAISING_CONTACT_INFO from '@salesforce/schema/Fundraising_Contact__c';
import FINANCING_INFO from '@salesforce/schema/Financing__c';
import fetchFlowNames from '@salesforce/apex/NavatarAcuityCtrl.fetchFlowNames';


import { showContactSectionDetails, referencedCol ,renderText,dealHelptext , handleHelpText, infoHelpText, createErrMsg,
    delErrMsg, infoHelpTextFDR, infoHelpTextInst, infoHelpTextAct, conColsMobValue, internalColsMob, conColsMob2, dealsColsMob1,
    fundColsMob, coInvColsMob, helpTextForDealSections, dealsColsValue, conCols1, conColsMob1,conCols2
 } from "./navatarAcuityLwcUtility";

export default class NavatarAcuityLwc extends NavigationMixin(LightningElement) {
/* Common : START */
@api recordId;
@api objectApiName;
isRgApiError = false;
errMsg = 'No items to display.';
enableSpinner = true;
conMap = new Map();
conIdList = [];
namespacePrefix = '';
actIdList = [];
completeActIdList = [];
currRecName = '';
recTypeDevName = '';
contactEmail = '';
taggedSecOptions = [];
taggedSecOptionsMob = [];
noData; //No data
displayAccConAcuityConDealSec = false;
showPopoverErrorMsg = true;
isEmailDrillDownEnabled = false;

hideDealSection=false;
recordTypearray = ['Company','Portfolio_Company','Institution','Advisor','Intermediary','Lender','Private_Equity'];
/* Common : END */

/* Tagged Section : START */
accId = '';
refTabValue = 'Firms';
companyData = true;
peopleData = false;
dealData = false;
fundData = false;
themeData = false;
clipData = false;
queryPeopleData = true;
queryDealsData = true;
queryThemesData = true;
queryClipsData = true;
compRefData;
peopleRefData;
dealsRefData;
themesRefData;
clipsRefData;
clipsDataList; //For Clips view popup
infoHelpText;
/* Tagged Section : END */

/* Interactions Section : START */
interactionsPartialInfoArray;
displayViewAll = false;
isCallLogOpen = false;  //For Log Call Notes popup
displayInteractionsMob = false;
interactionsMobHeader = '';
interactionsMobActIdList = [];
interactionsMobEmptyModalKeyword = '';
/* Interactions Section : END */

/* Contacts/Connections Section : START */
conCols = [];
conColsMob = [];
conData;
conTitle = 'Contacts';
apiData;

internalDataDealTeam =[];
externalDataDealTeam =[];
/* Contacts/Connections Section : END */

/* Contact Section Toggle : Start */
conSecTabValue = 'Internal';
internalData;
externalData;
/* Contact Section Toggle : End */

/* Deals Section : START */
helpTextForDealSection = dealHelptext();
dealTitle = '';
dealsCols = [];
dealsColsMob = [];
dealsData;
displayDealSecSort = false;
displayDealPlusIcon = false;
dealPlusIconText = '';
eventName = '';
get displayAddDealTeamMember(){
    return this.objectApiName === 'Contact';
}
get displayNewFdrCon(){
    return this.objectApiName === 'Contact';
}
//Added below getter by LK on 2024-06-21 to fix 00046176
get displayNewFdrPlusIcon(){
    return this.objectApiName === 'Account';
}
/* Deals Section : END */

/*Deals Section Toggle : Start */
dealSecTabValue = 'Fund';
isFund = true;
isCoInv = false;
fundTableCols = [];
coInvTableCols = [];
displayDealSecToggle = false;
fundsData;
coInvsData;
queryCoInvData = true;
isInstitution = false;
contactTableLable;
fndRngCntTableLabel;
dealTeamTableLabel;
/*Deals Section Toggle : End*/

/* Deals Section Sort : Start */
dealSecSortValue = 'Date Received';
prevDealSecSortValue = 'Date Received';
get dealSecSortOptns(){
    //Modified by LK on 2024-05-06 to fix 00045297
    return this.displayDealSecToggle ? [{ label: 'Stage', value: 'Stage' }, { label: 'Target Close Date', value: 'Target Close Date' }] : [{ label: 'Date Received', value: 'Date Received' }, { label: 'Stage', value: 'Stage' }];
}

get dealSecSortOptnsForFundraising(){
    return [{ label: 'Target Close Date', value: 'Target Close Date' },
            { label: 'Stage', value: 'Stage' }];
}
dealSecSortDir = 'DESC';
/* Deals Section Sort : End */

/* Fdr Acuity > Fdr Contact Section : Start */
parentConIdList = [];   //For Fdr Acuity > Fdr Contact Section
displayFdrConSec = false;
dealTeamRole = [];
chckBoxAdvisor = true;
@wire(getObjectInfo, { objectApiName: FUNDRAISINGCONTACT_INFO}) 
fdrRecord;

dealPermissions = {};
fundPermissions = {};
themePermissions = {};
clipPermissions = {};
fdrConPermissions = {};
dealTeamPermissions = {};
financingPermissions = {};
isDealAccessible = true;//Modified by LK on 2024-04-11 to fix 00044459
get displayFdrSection(){
    return this.fundPermissions['isAccessible'] && this.fdrPermissions['isAccessible'];
}
noCreateAccessErrMsg = createErrMsg();
noDelAccessErrMsg = delErrMsg();
@wire(getObjectInfos, { objectApiNames: [ DEAL_INFO, FUND_INFO, THEME_INFO, CLIP_INFO, FUNDRAISING_CONTACT_INFO, DEALTEAM_INFO, FINANCING_INFO ] })
objectsInfo({error, data}){
    if(data){
        for(let key in data){
            this.dealPermissions = {isAccessible: data[key][0].statusCode === 200};
            this.isDealAccessible = this.dealPermissions['isAccessible'];//Modified by LK on 2024-04-11 to fix 00044459
            if(this.dealPermissions['isAccessible']){
                this.dealPermissions = {...this.dealPermissions, isCreateable: data[key][0]['result']['createable'], isEditable: data[key][0]['result']['updateable'], isDeletable: data[key][0]['result']['deletable']};
            }
            this.fundPermissions = {isAccessible: data[key][1].statusCode === 200};
            if(this.fundPermissions['isAccessible']){
                this.fundPermissions = {...this.fundPermissions, isCreateable: data[key][1]['result']['createable'], isEditable: data[key][1]['result']['updateable'], isDeletable: data[key][1]['result']['deletable']};
            }
            this.themePermissions = {isAccessible: data[key][2].statusCode === 200};
            if(this.themePermissions['isAccessible']){
                this.themePermissions = {...this.themePermissions, isCreateable: data[key][2]['result']['createable'], isEditable: data[key][2]['result']['updateable'], isDeletable: data[key][2]['result']['deletable']};
            }
            this.clipPermissions = {isAccessible: data[key][3].statusCode === 200};
            if(this.clipPermissions['isAccessible']){
                this.clipPermissions = {...this.clipPermissions, isCreateable: data[key][3]['result']['createable'], isEditable: data[key][3]['result']['updateable'], isDeletable: data[key][3]['result']['deletable']};
            }
            this.fdrConPermissions = {isAccessible: data[key][4].statusCode === 200};
            if(this.fdrConPermissions['isAccessible']){
                this.fdrConPermissions = {...this.clipPermissions, isCreateable: data[key][4]['result']['createable'], isEditable: data[key][4]['result']['updateable'], isDeletable: data[key][4]['result']['deletable']};
            }
            this.dealTeamPermissions = {isAccessible: data[key][5].statusCode === 200};
            if(this.dealTeamPermissions['isAccessible']){
                this.dealTeamPermissions = {...this.dealTeamPermissions, isCreateable: data[key][5]['result']['createable'], isEditable: data[key][5]['result']['updateable'], isDeletable: data[key][5]['result']['deletable']};
            }
            this.financingPermissions = {isAccessible: data[key][6].statusCode === 200};
            if(this.financingPermissions['isAccessible']){
                this.financingPermissions = {...this.financingPermissions, isCreateable: data[key][6]['result']['createable'], isEditable: data[key][6]['result']['updateable'], isDeletable: data[key][6]['result']['deletable']};
            }
        }
        //Added below code by LK on 2023-03-08 to fix 00044275
        if(this.recordId != null){
            this.handleOnLoadInfo();
        }
    }
}

@wire(getPicklistValues, {recordTypeId: '$fdrRecord.data.defaultRecordTypeId', fieldApiName: ROLE_FIELD})
frcRolePicklist({ data, error }) {
    if(data) {
        this.dealTeamRole = data.values;
    }
    else if (error) {
        this.showToast(this, 'Error!', error.body.message, 'error');
    }
}

handleFundraisingContactCreate(){
    if(this.fdrConPermissions['isCreateable']){
        this.publishEvent((this.objectApiName === 'Contact' ? 'Contact' : 'navpeII_dev18__Fundraising__c') + '.New_Fundraising_Contact');
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');    
        }
}
/* Fdr Acuity > Fdr Contact Section : End */

/* Firm (PE) Acuity > Deal Section : Start */
isFirmPE = false;
peTabValue = 'Funds';
displayPEDealSecToggle = false;
valueSorting = 'DESC';
fieldNameForSortPe = 'date';   
placeholderValue = 'Date Received';
isFundTabPopup = true;
isSourcedTabPopup = false;
peLoadFirstTimeForFunds = true;
peLoadFirstTimeForSourced = true;

get optionsforsortingPE() {
    return [
        { label: 'Date Received', value: 'date' },
        { label: 'Stage', value: 'stage' }
    ];
}
get optionPEDeals(){
    return [
        { label: 'Funds', value: 'Funds'},
        { label: 'Sourced', value: 'Sourced'},
    ];
}
/* Firm (Private Equity) Acuity > Deal Section : End */

/* Deal Acuity > Deal Team Section : Start */
addDisableexter = true;
chckBoxAdvisorexter = true;
internalAdd = false;
interexterbtn = true;
externalAdd = true;
interTable = false;
exterTable = true;
chckBoxAdvisorinter = true;
cancelRemove = false;
cancelRemoveinter = false;
addDisableinter = true;
displayDealAcuityDTSec = false;
dealTeamTabValue = 'Internal';
fldsItemValues = [];
dealTeamRoleOption = [];
    IsAccount = false; 
    IsContact = false;
@wire(getObjectInfo, { objectApiName: DEALTEAM_INFO}) 
dealTeamRecord;

@wire(getPicklistValues, {recordTypeId: '$dealTeamRecord.data.defaultRecordTypeId', fieldApiName: DT_ROLE_FIELD})
dealteamRolePicklist({ data, error }) {
    if(data) {
        this.dealTeamRoleOption = data.values;
    }
    else if (error) {
        this.showToast(this, 'Error!', error.body.message, 'error');
    }
}
get optionsInterExter() {
    return [
        { label: 'Internal', value: 'Internal'},
        { label: 'External', value: 'External'},
    ];
}
/* Deal Acuity > Deal Team Section : End */

/* Fund Acuity > Fdr Section : Start */
displayFundAcuityFdrSec = false;
addfundraisingpop = false;
chckBoxdel = true;
cancelFdrRemove = false;
addFdrDisableexter = true;
filterValue = '';
valueSortingFdr = 'DESC';
fieldNameForSort = 'stage';   
placeholderValueFdr = 'Stage';
fundraisingStage = [];
showHideRemoveIcon = false;
get optionsforsorting() {
    return [
        { label: 'Stage  ', value: 'stage' },
        { label: 'Date  ', value: 'date' }
    ];
}
get optionsforsortingFundraising() {
    return [
        { label: 'Stage  ', value: 'stage' },
        { label: 'Target Close Date  ', value: 'date' }
    ];
}
fdrPermissions = {};
@wire(getObjectInfo, { objectApiName: FUNDRAISING_INFO}) 
fundRaisingRecord;
//Added below getter by LK on 2024-05-23 to fix 00045422
get fdrPluralLabel(){
    return Object.keys(this.fundRaisingRecord).length !== 0 ? this.fundRaisingRecord["data"]["labelPlural"] : 'Fundraisings';
}
fdrNameFieldLabel = 'Fundraising Name';//Added by LK on 2024-05-29 to fix 00045422
@wire(getPicklistValues, {recordTypeId: '$fundRaisingRecord.data.defaultRecordTypeId', fieldApiName: STAGE_FIELD})
fundraisingStagePicklist({ data, error }) {
    if(data) {
        this.fundraisingStage = data.values;
        this.fdrPermissions = {isAccessible: Object.keys(this.fundRaisingRecord).length !== 0, isCreateable: this.fundRaisingRecord['data']['createable'], isEditable: this.fundRaisingRecord['data']['updateable'], isDeletable: this.fundRaisingRecord['data']['deletable']};
        this.fdrNameFieldLabel = this.fundRaisingRecord['data']['fields']['Name']['label'];//Added by LK on 2024-05-29 to fix 00045422
    } else if(error) {
    }
}
/* Fund Acuity > Fdr Section : End */

/* Plus Icon NSD : Start */
displayAddCmp = false;
plusIconObjApiName = '';
/* Plus Icon NSD : End */

/* Referenced Section table columns */
get referencedCols(){
    return referencedCol(this);
}

/* Deals Section tab switching */
get optnsFundCoInv(){
    return [
        { label: 'Funds', value: 'Fund' },
        { label: 'Co-Investments', value: 'Co-investment' },
    ];
}

/* For modifying the Interactions section tile CSS based on the count of the tiles */
get interactionSecCls(){
    return 'slds-grid ' + (this.displayViewAll ? 'allcardheight' : 'less_cards');
}

//#00038817 - AA
get contactSecCls(){
    return 'slds-large-size_' + (this.hideDealSection == true ? '12-of-12' : '6-of-12');
}

/****************************** Page Load Methods : Start ******************************/

/* Page load operations handling */
connectedCallback(){
    this.isMobile = window.innerWidth <= 768;//Added by LK on 2024-10-15 to fix 00047628
    if(this.recordId === undefined){
        this.processInteractionSecInfo();        
    }
}

/* Processes the info to be displayed on page load */
handleOnLoadInfo(){
    handleOnLoadInfo({recordId : this.recordId, objApiName : this.objectApiName})
    .then((result) => {
        this.isMobile = window.innerWidth <= 768;        // Bug 00045453,00045633 fixed by Sudhanshu 06-06-2024
        this.conIdList = result.conIdList;
        this.contactTableLable = result.contactPluralLabel;
        this.fndRngCntTableLabel = result.fndrgCntPluralLabel;
        this.dealTeamTableLabel = result.dealTeamPluralLabel;
        this.namespacePrefix = result.namespacePrefix;
        this.currRecName = result.recName;
        this.recTypeDevName = result.recType;
        this.isInstitution = this.recTypeDevName === 'Institution' ? true : false; 
        this.handleFlowName(); // added by Sudhanshu for Citadel CR
        //#00038817 - Added by AA To handle custom RTs
        this.hideDealSection = (((!this.recordTypearray.includes(this.recTypeDevName) && this.objectApiName === 'Account') 
                                || (this.objectApiName === 'Account' && !this.isInstitution && !this.dealPermissions['isAccessible'])
                                || (this.objectApiName === 'Account' && this.isInstitution && !this.displayFdrSection)
                                || (this.objectApiName === 'Contact' && !this.dealPermissions['isAccessible'] && !this.displayFdrSection))
                                ? true : false); //Modified by AA to show Deal section on Contact Acuity Page
        //Condition for Account (Institution) Acuity > Default sort by Stage here
        //Updated Date Received as part of 00035324 by Virendra
        this.dealSecSortValue = (this.recTypeDevName === 'Institution' || (this.objectApiName === 'Contact' && !this.dealPermissions['isAccessible'] && this.displayFdrSection))
                                ? 'Stage'
                                : 'Date Received';
        this.accId = result.accId != null ? result.accId : '';
        this.contactEmail = result.contactEmail;
        this.conMap = result.conMap;
        this.actIdList = result.actIdList;
        this.completeActIdList = result.completeActIdList;
        this.parentConIdList = result.parentConIdList;  //For Fdr Acuity > Fdr Con Section
        this.filterValue = result.filterValue;
        this.taggedSecOptions = [{ label: result.acclabel, value: 'Firms' },
            { label: result.conlabel, value: 'People' },
        ];
        if(this.isMobile)        // Bug 00045453,00045633 fixed by Sudhanshu 06-06-2024
        {
            /**********Modified by Anshika Ahuja W.R.To UI Bug Fixing */
            this.interactionsMobHeader = 'All Interactions';
            this.interactionsMobActIdList = this.completeActIdList;
            this.interactionsMobEmptyModalKeyword = 'Interactions';
            this.displayInteractionsMob = true;
        }
        if(this.objectApiName !== (this.namespacePrefix + 'Fundraising__c')){
            if((this.isInstitution == true && this.fundPermissions['isAccessible']) || (this.objectApiName === 'Contact' && this.fundPermissions['isAccessible'] && !this.dealPermissions['isAccessible'])){
                this.taggedSecOptions.push({ label: result.fundlabel, value: 'Funds' });
            } else if(this.isInstitution == false && this.dealPermissions['isAccessible'] && !this.hideDealSection){
                this.taggedSecOptions.push({ label: result.dellabel, value: 'Deals' });
            }
        }
        if(this.themePermissions['isAccessible']) {this.taggedSecOptions.push({ label: result.themelabel, value: 'Themes' })};
        if(this.clipPermissions['isAccessible']) {this.taggedSecOptions.push({ label: result.cliplabel, value: 'Clips' })};
        if(result.compsRefInfo && result.compsRefInfo.length > 0){
            this.compRefData = [];
            for(let recInfo of result.compsRefInfo){
                this.compRefData.push({ref: recInfo.nameRef, name: recInfo.name, timesRef: recInfo.count, actIdsList: recInfo.actIdList, refColClass: 'slds-text-link slds-text-body_regular' + (recInfo.isAssociatedToDeal && this.dealPermissions['isAccessible'] ? ' refCellHighlightCls' : '')});
            }
            this.compRefData.sort(this.sortBy('timesRef', -1));
        }
        /* Deal Section Icon Processing : Start */
        this.handleDealSecPlusIcon();
        /* Deal Section Icon Processing : End */
        //Fetching Contacts/Connections Section Info
        let recordId, metadataField1, metadataField2, conEmail;
        if(this.objectApiName === 'Account'){
            if(this.recTypeDevName === 'Institution'){
                    this.infoHelpText = infoHelpTextInst();
                }
                else{
                    this.infoHelpText = infoHelpTextAct();
                }
            recordId = null;
            metadataField1 = 'Acuity_Connection_Field1';
            metadataField2 = 'Acuity_Connection_Field2';
            conEmail = null;
            this.displayAccConAcuityConDealSec = true;
        } else if(this.objectApiName === 'Contact') {
            recordId = this.recordId;
            metadataField1 = 'Acuity_Connection_IntTab_Field1';
            metadataField2 = 'Acuity_Connection_IntTab_Field2';
            conEmail = this.contactEmail;
            this.displayAccConAcuityConDealSec = true;
                this.infoHelpText = infoHelpText();
        } else if(this.objectApiName === this.namespacePrefix + 'Fundraising__c') {
            recordId = this.recordId;
            //Added by Tejaswini - Naming Convention           
             metadataField1 = 'Acuity_FDRC_Connection_Field1';
             metadataField2 = 'Acuity_FDRC_Connection_Field2,Acuity_FDRC_Connection_Field3,Acuity_FDRC_Connection_Field4';
            //Added if clause by LK on 2024-06-11 to fix 00045505
            if(this.fdrConPermissions['isAccessible']){
                this.displayFdrConSec = true;
            }
            this.infoHelpText = infoHelpTextFDR();
        } else if(this.objectApiName === this.namespacePrefix + 'Pipeline__c'){
            //Added if clause by LK on 2024-06-11 to fix 00045505
            if(this.dealTeamPermissions['isAccessible']){
                this.displayDealAcuityDTSec = true;
            }
            this.infoHelpText = infoHelpText();
            this.getDealTeamRecords();
            this.processInteractionSecInfo();
        } else if(this.objectApiName === this.namespacePrefix + 'Fund__c'){
                this.infoHelpText = infoHelpText();
            //Added if clause by LK on 2024-06-11 to fix 00045505
            if(this.fdrPermissions['isAccessible']){
                this.displayFundAcuityFdrSec = true;
            }
            this.createFundraisingUiInFund();
            this.processInteractionSecInfo();
        }
        if(['Account', 'Contact', this.namespacePrefix + 'Fundraising__c'].includes(this.objectApiName)){
            processConInfo({conMap : this.conMap, recordId : recordId, metadataField1 : metadataField1, otherMetadataFields : metadataField2, namespacePrefix : this.namespacePrefix, conEmail : conEmail, actIdList : this.actIdList, objApiName : this.objectApiName, calledFrom : 'PageLoad', parentConIdList : this.parentConIdList})
            .then((result) => {
                let cols = showContactSectionDetails();
                this.isEmailDrillDownEnabled = result.isEmailDrillDownEnabled;
                if(result.isEmailDrillDownEnabled){
                    cols.push({ label: 'Emails', iconName:'utility:email', initialWidth: 60, fieldName: 'emailRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'emailRef' }, variant: 'base', name:'emailRef', tooltip: {fieldName: 'emailRef'}}});
                } else {
                    cols.push({ label: 'Emails', iconName:'utility:email', initialWidth: 60, fieldName: 'emailRef', type: 'text', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, tooltip: {fieldName: 'emailRef'}});
                }
                if(['Account', 'Contact'].includes(this.objectApiName)){
                    if(this.objectApiName === 'Account'){
                        this.conCols = cols;
                        this.conCols.splice(2, 0, { label: 'Name', fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}});
                    } else {
                        this.internalTableCols = cols;
                        this.internalTableCols.splice(2, 0, { label: 'Name', fieldName: 'name', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', variant: 'base', name:'name', tooltip: { fieldName: 'name' }, title: { fieldName: 'name' }}, cellAttributes:{ class: 'text-black'}});
                    }
                    this.conColsMob = conColsMobValue();
                    this.internalTableColsMob = internalColsMob();
                    if(result){
                        if(result.conSecDynFieldHeader){
                            let col = { label: result.conSecDynFieldHeader, fieldName: 'roleRef', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'roleRef' }, target: '_blank', variant: 'base', name:'roleRef', tooltip: { fieldName: 'roleRef' }, title: { fieldName: 'roleRef' }}, cellAttributes:{ class: 'text-black'}};
                            if(this.objectApiName === 'Account'){
                                this.conCols.splice(3, 0, col);
                            } else {
                                this.internalTableCols.splice(3, 0, col);
                                this.internalTableCols.splice(0, 2);
                            }
                        }
                        if(result.conInfoWrapper.length > 0){
                            let conData = [];
                            for(let recInfo of result.conInfoWrapper){
                                // Bug 00046470 fixed by Sudhanshu on 16-07-2024
                                if(this.isMobile)
                                {
                                    if(!recInfo.downloadIcon)
                                    {
                                        conData.push({downloadIcon: recInfo.downloadIcon, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                                    }
                                }
                                else
                                {
                                    conData.push({downloadIcon: recInfo.downloadIcon, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                                }

                                // conData.push({downloadIcon: recInfo.downloadIcon, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                            }
                            conData.sort(this.sortBy('totalActCount', -1));
                            if(this.objectApiName === 'Account'){
                                this.conData = conData.slice();
                            } else {
                                this.internalData = conData.slice();
                            }
                        }

                        //Added by Shivam to resolve RG API error
                        this.isRgApiError = result.apiError;
                        this.enableSpinner = false;
                    }
                } else if(this.objectApiName === this.namespacePrefix + 'Fundraising__c'){
                    this.enableSpinner = false;
                    this.conCols = cols;
                    this.conCols.splice(2, 0, { label: 'Name', fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}});
                    this.conColsMob = conColsMob2();
                    if(result){
                        if(result.conSecDynFieldHeader2){
                            this.conCols.splice(3, 0, { label: result.conSecDynFieldHeader2, fieldName: 'roleRef2', type: 'text', hideDefaultActions: true})
                        }
                        if(result.conSecDynFieldHeader){
                            this.conCols.splice(4, 0, { label: result.conSecDynFieldHeader, fieldName: 'conRef2', type: 'url', cellAttributes: { class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name2' }, target: '_blank', tooltip: {fieldName: 'name2'}}})
                        }                            
                        if(result.conSecDynFieldHeader3){
                            this.conCols.splice(5, 0, { label: result.conSecDynFieldHeader3, fieldName: 'roleRef3', type: 'picklist', hideDefaultActions: true, editable: this.fdrConPermissions['isEditable'], typeAttributes: { context: {fieldName: 'Id'}, editable: this.fdrConPermissions['isEditable'], fieldApiName: this.namespacePrefix + 'Role__c', options: {fieldName: 'picklistOptions'}, placeholder: 'Choose Role', value: {fieldName: 'roleRef3'}}});
                        }
                        this.conData = [];
                        if(result.conInfoWrapper.length > 0){
                            this.showHideRemoveIcon = true;
                            for(let recInfo of result.conInfoWrapper){
                                this.conData.push({Id: recInfo.frcId, id2: recInfo.recId2, conRef2: recInfo.nameRef2, name2: recInfo.name2, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, roleRef2: recInfo.fieldInfo2, roleRef3: recInfo.fieldInfo3, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, actIdList : recInfo.actIdList, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                            }
                            this.conData.sort(this.sortBy('totalActCount', -1));
                            this.conData = this.conData.map(element=>{
                                return {
                                    ...element, 'picklistOptions': this.dealTeamRole
                                }
                            });
                        }
                        this.enableSpinner = false;
                        this.isRgApiError = result.apiError;
                    }
                }
                //Fetching Interactions Section Info
                this.processInteractionSecInfo();
            })
            .catch((error) => {
                //Added by Mitul to display error if API is not working
                this.showToast(this, 'Error!', error.body.message, 'error');
                this.enableSpinner = false;
            });
        }
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

/****************************** Page Load Methods : End ******************************/

/****************************** Tagged Section Methods : Start ******************************/

/* Handles tab switching : Tagged Section */
handleReferenced(event){
    this.refTabValue = event.detail.value;
    if(this.refTabValue=='Firms'){
        this.companyData = true;
        this.peopleData = false;
        this.dealData = false;
        this.fundData = false;
        this.themeData = false;
        this.clipData = false;
    } else if(this.refTabValue=='People'){
        this.companyData = false;
        this.peopleData = true;
        this.dealData = false;
        this.fundData = false;
        this.themeData = false;
        this.clipData = false;
        if(this.queryPeopleData){
            this.handlePeopleRefInfo();
            this.queryPeopleData = false;
        }
    } else if(['Deals', 'Funds'].includes(this.refTabValue)){
        this.companyData = false;
        this.peopleData = false;
        if(this.refTabValue === 'Deals'){
            this.dealData = true;
        } else {
            this.fundData = true;
        }
        this.themeData = false;
        this.clipData = false;
        if(this.queryDealsData){
            this.handleDealsRefInfo();
            this.queryDealsData = false;
        }
    } else if(this.refTabValue=='Themes'){
        this.companyData = false;
        this.peopleData = false;
        this.dealData = false;
        this.fundData = false;
        this.themeData = true;
        this.clipData = false;
        if(this.queryThemesData){
            this.handleThemesRefInfo();
            this.queryThemesData = false;
        }
    } else if(this.refTabValue=='Clips'){
        this.companyData = false;
        this.peopleData = false;
        this.dealData = false;
        this.fundData = false;
        this.themeData = false;
        this.clipData = true;
        if(this.queryClipsData){
            this.handleClipsRefInfo();
            this.queryClipsData = false;
        }
    }
}

/* Processes the people referenced info */
handlePeopleRefInfo(){
    this.enableSpinner = true;
    handlePeopleRefInfo({conIdList : this.conIdList, actIdList : ['Account', `${this.namespacePrefix}Pipeline__c`, `${this.namespacePrefix}Fund__c`].includes(this.objectApiName) ? this.completeActIdList : this.actIdList})
    .then((result) => {
        if(result && result.length > 0){
            this.peopleRefData = [];
            for(let recInfo of result){
                this.peopleRefData.push({ref: recInfo.nameRef, name: recInfo.name, timesRef: recInfo.count, actIdsList: recInfo.actIdList, refColClass: 'slds-text-link slds-text-body_regular'});
            }
            this.peopleRefData.sort(this.sortBy('timesRef', -1));
        }
        this.enableSpinner = false;
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

/* Processes the deal referenced info */
handleDealsRefInfo(){
    this.enableSpinner = true;
    handleDealsRefInfo({actIdList : this.completeActIdList, namespacePrefix : this.namespacePrefix, objApiName : this.objectApiName, recId : this.recordId, relObjIdList : this.conIdList, recType : this.recTypeDevName, isDealAccessible: this.dealPermissions['isAccessible'], displayFdrSection: this.fundPermissions['isAccessible']})
    .then((result) => {
        if(result && result.length > 0){
            this.dealsRefData = [];
            for(let recInfo of result){
                this.dealsRefData.push({ref: recInfo.nameRef, name: recInfo.name, timesRef: recInfo.count, actIdsList: recInfo.actIdList, refColClass: 'slds-text-link slds-text-body_regular'});
            }
            this.dealsRefData.sort(this.sortBy('timesRef', -1));
        }
        this.enableSpinner = false;
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

/* Processes the themes referenced info */
handleThemesRefInfo(){
    this.enableSpinner = true;
    handleThemesRefInfo({recordId : this.recordId, objApiName : this.objectApiName, namespacePrefix : this.namespacePrefix})
    .then((result) => {
        if(result && result.length > 0){
            this.themesRefData = [];
            for(let recInfo of result){
                this.themesRefData.push({ref: recInfo.nameRef, name: recInfo.name});
            }
            this.themesRefData.sort(this.sortBy('name', 1));
        }
        this.enableSpinner = false;
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

/* Processes the clips referenced info */
handleClipsRefInfo(){
    this.enableSpinner = true;
    handleClipsRefInfo({recordId : this.recordId, objApiName : this.objectApiName, namespacePrefix : this.namespacePrefix})
    .then((result) => {
        if(result.length > 0){
            this.clipsRefData = [];
            for(let recInfo of result){
                this.clipsRefData.push({ref: recInfo.refWrapper.nameRef, clipName: recInfo.refWrapper.name, summary: recInfo.secFieldInfo, notes: recInfo.notes, createdDate: recInfo.createdDate, tags: recInfo.tags.sort(this.sortBy('sortValue', 1))});
            }
            this.clipsRefData.sort(this.sortBy('name', 1));
        }
        this.enableSpinner = false;
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

/****************************** Tagged Section Methods : End ******************************/

/****************************** Interactions Section Methods : Start ******************************/
isMobile = false;       // added by sudhanshu 00045453,00045633
/* Processes the Interaction Section Info */
processInteractionSecInfo(){
    let conIdList, recordId;
    if(this.objectApiName === 'Account'){
        conIdList = this.conIdList;
        recordId = null;
    } else {
        conIdList = null;
        recordId = this.recordId;
    }
    if(this.completeActIdList.length > 0 || this.recordId == undefined){
        if(!this.isMobile)      // Bug 00045453,00045633 fixed by Sudhanshu 06-06-2024
        {
            // Bug 00047632 Fixed by Sudhanshu on 30-05-2025
            handleInteractionsInfo({namespacePrefix : this.namespacePrefix, actIdList : this.completeActIdList, objApiName : this.objectApiName, isAcuity : true})
            .then((result) => {
                if(result && result.length > 0){
                    //For handling Desktop Scenario
                    this.interactionsPartialInfoArray = [];
                    result.sort(this.sortBy('actDateAsLong', -1));
                    this.displayViewAll = result.length > 4;
                    for(let recInfo of result.slice(0, 4)){
                        this.interactionsPartialInfoArray.push({iconName: recInfo.iconName, type: recInfo.type, date: recInfo.actDate, buttonTitle: recInfo.buttonTitle, subject: recInfo.subject, id: recInfo.actId, detail: recInfo.detail, participantsInfo: recInfo.attendees, tagsInfo: recInfo.references, priority: recInfo.priority, actOwner: recInfo.actOwner, status: recInfo.status, classification: recInfo.classification,actInfo : recInfo.actInfo});
                    }
                    //For handling Mobile Scenario
                    this.interactionsMobHeader = 'All Interactions';
                    this.interactionsMobActIdList = this.completeActIdList;
                    this.interactionsMobEmptyModalKeyword = 'Interactions';
                    // this.displayInteractionsMob = true; // Bug 00047632 Fix by Sudhanshu on 30-05-2025
                }
                if(['Account', 'Contact'].includes(this.objectApiName)){
                    //Fetching Deals Section Info
                    if(this.recTypeDevName === 'Private_Equity'){
                        this.processPEDealSecInfo();
                    } else {
                        //#00038817 - AA
                        if(!this.hideDealSection && (this.objectApiName === 'Contact' || this.recTypeDevName === 'Company' || this.recTypeDevName === 'Portfolio_Company' || this.recTypeDevName === 'Institution' || this.recTypeDevName === 'Advisor' || this.recTypeDevName === 'Intermediary' || this.recTypeDevName === 'Lender')){
                            this.processDealSecInfo();
                        }
                        else if(this.hideDealSection === true){
                            this.enableSpinner = false;
                        }
                    }
                } else {
                    this.enableSpinner = false;
                }
            })
            .catch((error) => {
                this.showToast(this, 'Error!', error.body.message, 'error');
                this.enableSpinner = false;
            });
        }
        else
        {
            //For handling Mobile Scenario
            // this.interactionsMobHeader = 'All Interactions';
            // this.interactionsMobActIdList = this.completeActIdList;
            // this.interactionsMobEmptyModalKeyword = 'Interactions';
            // this.displayInteractionsMob = true;
 
            if(['Account', 'Contact'].includes(this.objectApiName)){
                //Fetching Deals Section Info
                if(this.recTypeDevName === 'Private_Equity'){
                    this.processPEDealSecInfo();
                } else {
                    //#00038817 - AA
                    if(!this.hideDealSection && (this.objectApiName === 'Contact' || this.recTypeDevName === 'Company' || this.recTypeDevName === 'Portfolio_Company' || this.recTypeDevName === 'Institution' || this.recTypeDevName === 'Advisor' || this.recTypeDevName === 'Intermediary' || this.recTypeDevName === 'Lender')){
                        this.processDealSecInfo();
                    }
                    else if(this.hideDealSection === true){
                        this.enableSpinner = false;
                    }
                }
            } else {
                this.enableSpinner = false;
            }
        }
    } 
    else {
        // /**********Modified by Anshika Ahuja W.R.To UI Bug Fixing */
        // this.interactionsMobHeader = 'All Interactions';
        // this.interactionsMobActIdList = this.completeActIdList;
        // this.interactionsMobEmptyModalKeyword = 'Interactions';
        // this.displayInteractionsMob = true;
        if(['Account', 'Contact'].includes(this.objectApiName)){
            //Fetching Deals Section Info
            if(this.recTypeDevName === 'Private_Equity'){
                this.processPEDealSecInfo();
            }
            else if(!this.hideDealSection && (this.objectApiName === 'Contact' || this.recTypeDevName === 'Company' || this.recTypeDevName === 'Portfolio_Company' || this.recTypeDevName === 'Institution' || this.recTypeDevName === 'Advisor' || this.recTypeDevName === 'Intermediary' || this.recTypeDevName === 'Lender')){
                this.processDealSecInfo();
            }
            if(!this.recordTypearray.includes(this.recTypeDevName)){
                this.enableSpinner = false;
            }
        }
    }
}

/* Processes the modal/Interactions section info */
//Modified by AA for Redirection
fetchActInfo(event){
    if(['timesRef', 'meetCallRef'].includes(event.detail.action.name)){
        let header, emptyModalKeyword;
        header = (event.detail.action.name === 'timesRef' ? 'All Interactions With ' : 'Meetings & Calls With ') + event.detail.row.name;
        emptyModalKeyword = event.detail.action.name === 'timesRef' ? 'Interactions' : 'Meetings';
        this[NavigationMixin.GenerateUrl]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "navpeII_dev18__Interactions",
            },
            state: {
                c__header: header,
                c__namespacePrefix: this.namespacePrefix,
                c__actIdList: event.detail.row.actIdsList != undefined ? event.detail.row.actIdsList : [],
                c__emptyModalKeyword: emptyModalKeyword
            },
        }).then(generatedUrl => {
            window.open(generatedUrl,  "_blank");
        });
    } 
    //Modified by Anshika Ahuja W.R.TO Redirection
    else if(event.detail.action.name === 'Connections'){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "navpeII_dev18__Interactions",
            },
            state: {
                c__email: event.detail.row.email,
                c__recordId: event.detail.row.id,
                c__objApiName: this.objectApiName,
                c__actIdList: event.detail.row.actIdsList,
                c__namespacePrefix: this.namespacePrefix,
                c__emptyModalKeyword: 'Connections',
                c__dealList: event.detail.row.dealIdsList,
                c__isDealAccessible: this.dealPermissions['isAccessible'],//00044459 by LK on 20240410
                c__header: `Connections of ${event.detail.row.name}`
            },
        }).then(generatedUrl => {
            window.open(generatedUrl,  "_blank");
        });
    } 
    //Modified by Anshika Ahuja W.R.TO Redirection
    else if(['timesRefMob', 'meetCallRefMob'].includes(event.detail.action.name)){
        let header, emptyModalKeyword;
        header = (event.detail.action.name === 'timesRefMob' ? 'All Interactions With ' : 'Meetings & Calls With ') + event.detail.row.name;
        emptyModalKeyword = event.detail.action.name === 'timesRefMob' ? 'Interactions' : 'Meetings';
        let compDef = {
            componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
            attributes: {
                header: header,
                actIdList: event.detail.row.actIdsList != undefined ? event.detail.row.actIdsList : [],
                namespacePrefix: this.namespacePrefix,
                emptyModalKeyword: emptyModalKeyword
            }
        };
        this.navigateToLwcCompMob(compDef);
    } //Modified by Anshika Ahuja W.R.TO Redirection
    else if(event.detail.action.name === 'dealRefMob'){
        if(this.dealPermissions['isAccessible']){
            let compDef = {
                componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
                attributes: {
                    header: `Deals With ${event.detail.row.name}`,
                    namespacePrefix: this.namespacePrefix,
                    emptyModalKeyword: 'Deals',
                    dealList: event.detail.row.dealIdsList
                }
            };
            this.navigateToLwcCompMob(compDef);
        } else {
            //Updated toast title from "Error!" to "Error:" by LK on 2024-07-05 to fix 00046466
            this.showToast(this, 'Error:', 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', 'error');
        }
    } 
    //Modified by Anshika Ahuja W.R.TO Redirection
    else if(event.detail.action.name === 'dealRef'){
        if(this.dealPermissions['isAccessible']){
            // let compDef = {
            //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
            //     attributes: {
            //         header: `Deals With ${event.detail.row.name}`,
            //         namespacePrefix: this.namespacePrefix,
            //         emptyModalKeyword: 'Deals',
            //         dealList: event.detail.row.dealIdsList
            //     }
            // };
            // this.navigateToLwcComp(compDef);

            this[NavigationMixin.GenerateUrl]({
                type: "standard__navItemPage",
                attributes: {
                    apiName: "navpeII_dev18__Interactions",
                },
                state: {
                    c__header: `Deals With ${event.detail.row.name}`,
                    c__namespacePrefix: this.namespacePrefix,
                    c__emptyModalKeyword: 'Deals',
                    c__dealList: event.detail.row.dealIdsList
                },
            }).then(generatedUrl => {
                window.open(generatedUrl,  "_blank");
            });
        } else {
            this.showToast(this, 'Error!', 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', 'error');
        }
    } //Modified by Anshika Ahuja W.R.TO Redirection
    else if(event.detail.action.name === 'emailRef'){
        // let compDef = {
        //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
        //     attributes: {
        //         header: `Emails With ${event.detail.row.name}`,
        //         namespacePrefix: this.namespacePrefix,
        //         emptyModalKeyword: 'Emails',
        //         emailCallerParam: this.objectApiName === 'Contact' ? this.conSecTabValue === 'Internal' ? "childIcEmail" : "childEcEmail" : '',
        //         mailboxId: event.detail.row.mailboxId,
        //         email: event.detail.row.email,
        //         parentEmailId :this.contactEmail
        //     }
        // };
        // this.navigateToLwcComp(compDef);

        this[NavigationMixin.GenerateUrl]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "navpeII_dev18__Interactions",
            },
            state: {
                c__header: `Emails With ${event.detail.row.name}`,
                c__namespacePrefix: this.namespacePrefix,
                c__emptyModalKeyword: 'Emails',
                c__emailCallerParam: this.objectApiName === 'Contact' ? this.conSecTabValue === 'Internal' ? "childIcEmail" : "childEcEmail" : '',
                c__mailboxId: event.detail.row.mailboxId,
                c__email: event.detail.row.email,
                c__parentEmailId :this.contactEmail
            },
        }).then(generatedUrl => {
            window.open(generatedUrl,  "_blank");
        });
    } else if(event.detail.action.name === 'clipName'){
        let selRecId = event.detail.row.ref.substring(1);
        this.setClipsData();
        const filtered = this.clipsDataList.find((obj) => {
            return (obj.id === selRecId); 
        });
        let selectedData={
            index: filtered.index,
            id: selRecId,
            nameName: event.detail.row.clipName,
            Summary: event.detail.row.summary,
            Notes: event.detail.row.notes,
            tagName: event.detail.row.tags,
            date: event.detail.row.createdDate
        };
        const modalPopup = this.template.querySelector('c-navatar-all-clips-view-modal-lwc'); //Modified by Anshika Ahuja W.R.TO Redirection
        modalPopup.clipIcon = 'standard:groups';
        modalPopup.openModalNew(selectedData, this.clipsDataList);
    } else if(event.detail.action.name === 'downloadIcon'){
        const myName = event.detail.row.name.split(" ");//added by shivam
        let lastName = '';
        if(myName.length >1){
            lastName = myName[1];
        }
        if(this.objectApiName === 'Account'){
            const modalPopup = this.template.querySelector('c-navatar-acuity-ext-connection-add-popup-lwc');  //Modified by Anshika Ahuja W.R.TO Redirection
            modalPopup.lastNameValue = lastName;//added by shivam
            modalPopup.email = event.detail.row.email;
            modalPopup.objectApiName = "Account";
            modalPopup.accountRecordId = this.recordId;
            modalPopup.accountRecordName = this.currRecName;
            modalPopup.openModal();
            
        } else if(this.objectApiName === 'Contact'){
            const modalPopup = this.template.querySelector('c-navatar-acuity-ext-connection-add-popup-lwc'); //Modified by Anshika Ahuja W.R.TO Redirection
            modalPopup.lastNameValue = lastName;//added by shivam
            modalPopup.email = event.detail.row.email;
            modalPopup.openModal();
        }
    }
}

setClipsData() {
    let tempRecords = JSON.parse( JSON.stringify( this.clipsRefData ) );
    var tempList=[];
    for(let i=0; i<tempRecords.length; i++){
        let arr={
            index:i,
            id: tempRecords[i].Id,
            nameName: tempRecords[i].clipName,
            Summary: tempRecords[i].summary,
            Notes:tempRecords[i].notes,
            tagName: tempRecords[i].tags,
            date: tempRecords[i].createdDate,
            id: tempRecords[i].ref.substring(1),
            nameName: tempRecords[i].clipName,
            Summary: tempRecords[i].summary,
            Notes: tempRecords[i].notes,
            date: tempRecords[i].createdDate,
            tagName: tempRecords[i].tags
        };
        tempList.push(arr);
    }
    this.clipsDataList = tempList;
}

/* Processes activities info on View All click */
//Modified by Anshika Ahuja W.R.TO Redirection
handleViewAllClick(){
    //this.navigateToLwcComp(compDef);
    //Phase 3 Critical Bug - 00045332,00045334
    let compDef = {
        componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
        attributes: {
            //header: 'All Interactions With ' + this.currRecName,
            //Replaced above line with below 2 lines by LK on 2024-10-11 to fix 00047757
            currRecId: this.recordId,
            currRecApiName: this.objectApiName,
            actIdList: this.completeActIdList,
            namespacePrefix: this.namespacePrefix,
            emptyModalKeyword: 'Interactions'
        }
    };
    let encodedCompDef = btoa(JSON.stringify(compDef));
    this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: '/one/one.app#' + encodedCompDef
        }
    });
}

/* For opening the Log a Call notes popup */
callViewpopup(){
    this.isCallLogOpen = true;
}

/****************************** Interactions Section Methods : End ******************************/

/****************************** Deals Section Methods : Start ******************************/

/* Processes the Deals section info */
    //Help text changes by Virendra Kumar as part of 00035170,00035201,00035120,00035119,00035121,00035141
    handleHelpText() {
        this.helpTextForDealSection = handleHelpText(this.recTypeDevName);
        //Added below code by LK on 2024-05-16 to fix 00045701
        if((this.objectApiName === 'Contact' && !this.dealPermissions['isAccessible'] && this.displayFdrSection)){
            this.helpTextForDealSection = "View fundraising where the contact is a fundraising contact. Click the fundraising to view or edit details. Click the plus icon to create new fundraising.";
        }
    }

processDealSecInfo(){
    //Help text changes by Virendra Kumar
    this.handleHelpText();
    this.enableSpinner = true;
    processDealSecInfo({recordId : this.recordId, objApiName : this.objectApiName, recTypeDevName : this.recTypeDevName, namespacePrefix : this.namespacePrefix, conIdList : this.conIdList, dealSecTabValue : this.dealSecTabValue, dealSecSortValue : this.dealSecSortValue, dealSecSortDir : this.dealSecSortDir, isDealAccessible: this.dealPermissions['isAccessible'], displayFdrSection: this.displayFdrSection })
    .then((result) => {
        if((this.objectApiName === 'Contact' && !this.dealPermissions['isAccessible'] && this.displayFdrSection) || (this.objectApiName === 'Account' && this.isInstitution)){
            this.displayDealPlusIcon = false;
        }
        this.prevDealSecSortValue = this.dealSecSortValue;
        this.dealSecSortValue = '';
        this.dealTitle = result.title;
        this.displayDealSecToggle = result.displayToggle;
        let cols = [{label: result.fieldHeader1, fieldName: 'fieldRef1', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank'}, variant: 'base' }];
        this.dealsColsMob = dealsColsMob1(result);
        
        if(result.fieldHeader2){
            cols.push({ label: result.fieldHeader2, fieldName: 'field2', initialWidth: 100, type: 'text', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'field2' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'field2' }, title: { fieldName: 'field2' }}, cellAttributes:{ class: 'text-black'}});
        }
        if(result.fieldHeader3){
            cols.push({ label: result.fieldHeader3, fieldName: 'field3', initialWidth: 120, type: 'text', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'field3' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'field3' }, title: { fieldName: 'field3' }}, cellAttributes:{ class: 'text-black'}});
        }
        if(result.fieldHeader4){
            cols.push({ label: result.fieldHeader4, fieldName: 'field4', initialWidth: 120, type: 'text', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'field4' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'field4' }, title: { fieldName: 'field4' }}, cellAttributes:{ class: 'text-black'}});
        }
        if(this.displayDealSecToggle){
            switch(this.dealSecTabValue){
                case 'Fund': this.fundTableCols = cols;
                this.fundTableColsMob = fundColsMob(result);
                                break;
                case 'Co-investment': this.coInvTableCols = cols;
                this.coInvTableColsMob = coInvColsMob(result);
            }
        } else {
            this.dealsCols = cols;
        }

        this.displayDealSecSort = result.displaySorting;
        if(result.dealsDataList.length > 0){
            let tableData = [];
            for(let recInfo of result.dealsDataList){
                tableData.push({field1: recInfo.fieldInfo1.name, fieldRef1: recInfo.fieldInfo1.nameRef, field2: recInfo.fieldInfo2.name, field3: recInfo.fieldInfo3.name, field4: recInfo.fieldInfo4.name});
            }
            if(this.displayDealSecToggle){
                switch(this.dealSecTabValue){
                    case 'Fund': this.fundsData = tableData;
                                    break;
                    case 'Co-investment': this.coInvsData = tableData;
                }
            } else {
                this.dealsData = [...tableData];
            }
        }
        this.enableSpinner = false;
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

/* Handles tab switching : Deals Section */
handleDealSecTabSwitch(event) {
    this.dealSecTabValue = event.detail.value;
    if (this.dealSecTabValue === 'Fund') {
        this.isFund = true;
        this.isCoInv = false;
        this.dealSecSortDir = 'DESC';
    } else if(this.dealSecTabValue === 'Co-investment') {
        this.isFund = false;
        this.isCoInv = true;
        this.dealSecSortValue = 'Stage';
        this.dealSecSortDir = 'DESC';
        if(this.queryCoInvData){
            this.processDealSecInfo();
            this.queryCoInvData = false;
        }
    }
}

/* Handles the Deal section sort value change */
handleDealSecValueChange(event){
    this.dealSecSortValue = event.detail.value;
    //For handling the sort direction when the same option is clicked
    if(this.dealSecSortValue === this.prevDealSecSortValue){
        if(this.dealSecSortDir === 'ASC'){
            this.dealSecSortDir = 'DESC';
        } else if(this.dealSecSortDir === 'DESC'){
            this.dealSecSortDir = 'ASC';
        }
    } else {
        this.dealSecSortDir = 'DESC';
    }
    this.processDealSecInfo();
}

/* Handles the Deal section plus icon */
handleDealSecPlusIcon(){
    if(this.objectApiName === 'Contact' && !this.displayDealSecToggle){
        this.displayDealPlusIcon = true;
        this.dealPlusIconText = 'New Sourced Deal'
        this.eventName = 'Contact.New_Sourced_Deal';
    } else if(['Company', 'Portfolio_Company'].includes(this.recTypeDevName)){
        this.displayDealPlusIcon = true;
        this.dealPlusIconText = 'New Deal'
        this.eventName = 'Account.New_Deal';
    } else if(this.recTypeDevName === 'Lender'){
        this.displayDealPlusIcon = true;
        this.dealPlusIconText = 'New Financing'
        this.eventName = 'Account.New_Financing';
    } else if(this.recTypeDevName === 'Intermediary'){
        this.displayDealPlusIcon = true;
        this.dealPlusIconText = 'New Sourced Deal';
        this.eventName = 'Account.New_Sourced_Deal';
    }
}

handleNewDealAction(){
    if((this.objectApiName ==='Contact' && this.dealPermissions['isCreateable']) || (this.objectApiName === 'Account' && ['Company', 'Portfolio_Company', 'Intermediary'].includes(this.recTypeDevName) && this.dealPermissions['isCreateable']) || (this.objectApiName === 'Account' && this.recTypeDevName === 'Lender' && this.financingPermissions['isCreateable'])){
        this.publishEvent(this.eventName);
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
}

handleNewDealTeamMemberAction(){
    if(this.dealTeamPermissions['isCreateable']){
        this.publishEvent('Contact.New_Deal_Contact');
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
}

/****************************** Deals Section Methods : End ******************************/

/****************************** Common Methods : Start ******************************/

/* Handles navigation to the specified component */
navigateToLwcComp(compDef){
    let encodedCompDef = btoa(JSON.stringify(compDef));
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__webPage',
        attributes: {
            url: '/one/one.app#' + encodedCompDef
        }
    }).then(generatedUrl => {
        window.open(generatedUrl,  "_blank");
    });
}

navigateToLwcCompMob(compDef){
    let encodedCompDef = btoa(JSON.stringify(compDef));
    this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: '/one/one.app#' + encodedCompDef
        }
    });
}

/* Creates the comma separated string using the record name list */
createStrWithComma(recList){
    let strWithComma = '';
    for(let rec of recList){
        strWithComma += rec.name + ',';
    }
    strWithComma = strWithComma.slice(0, strWithComma.length - 1);
    return strWithComma;
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

/* Used for sorting the data in the datatable */
sortBy(field, reverse, primer){
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

showErrorMsgPopover(){
    let showDiv = this.template.querySelector('.errorMsgPopoverFullWidthTable');
    showDiv.classList.remove("slds-hide");
    showDiv.classList.add("slds-show");
}

hideErrorMsgPopover(){
    let showDiv = this.template.querySelector('.errorMsgPopoverFullWidthTable');
    showDiv.classList.remove("slds-show");
    showDiv.classList.add("slds-hide");
}

//Added by LK on 2024-08-30 to fix 00047233
showErrorMsgPopoverDT(){
    let showDiv = this.template.querySelector('.errorMsgPopoverFullWidthTableDT');
    showDiv.classList.remove("slds-hide");
    showDiv.classList.add("slds-show");
}
//Added by LK on 2024-08-30 to fix 00047233
hideErrorMsgPopoverDT(){
    let showDiv = this.template.querySelector('.errorMsgPopoverFullWidthTableDT');
    showDiv.classList.remove("slds-show");
    showDiv.classList.add("slds-hide");
}



/****************************** Common Methods : End ******************************/

/* This function is used for styling */
renderedCallback() {
    const style = document.createElement('style');
    //Added table height for 600px by LK on 20240423 to fix 00044996 ; 00045452 ; 00045510 ; 00045757 ; 00045125
    style.innerText = renderText();
    this.template.querySelector('.main-Container')?.appendChild(style);
    let datatableHeader = document.createElement('style');
    let iconColor = document.createElement('style');
    let cardHeadingColor = document.createElement('style');
    let DealDataTableBox = document.createElement('style');
    let tableHeaderColumnCenterReference = document.createElement('style');
    let buttonGroup = document.createElement('style');
    let tableBckNone = document.createElement('style');
    let rowBackgrounHover = document.createElement('style');
    let removeFocusCell = document.createElement('style');
    let showUnderlineTableCell = document.createElement('style');
    let highlight_back_td = document.createElement('style');
    highlight_back_td.innerText = `.refCellHighlightCls a{background: #d8d8d8;
        border-radius: 3px;}`;
    let showTootil_hide_slds_truncate = document.createElement('style');
    showUnderlineTableCell.innerText = '.dealDataTable table tr th .slds-button:hover {text-decoration: underline !important}';
    tableBckNone.innerText = `.contactDataTable .slds-th__action:hover, .dealDataTable .slds-th__action:hover, .companyTable .slds-th__action:hover, .dealTable .slds-th__action:hover, .peopleTable .slds-th__action:hover, .viewallScreen .slds-th__action:hover, .tableHeader .slds-th__action:hover{
        background:none !important;
        box-shadow:none;
    }`
    /* Commented below code by LK on 2024-06-20 to fix 00046471 ; 00046121 */
    /*+ (this.isEmailDrillDownEnabled
    ? ``
    : `.connectionTableEmailFdr .slds-table tr td:nth-child(10) .slds-truncate{
        cursor: default !important;
        color: #0176D3;
    }
    `)
    + (this.isEmailDrillDownEnabled
    ? ``
    : `.connectionTableEmailAcc .slds-table tr td:nth-child(7) .slds-truncate{
        cursor: default !important;
        color: #0176D3;
    }
    `)
    + (this.isEmailDrillDownEnabled
    ? ``
    : `.connectionTableEmail .slds-table tr td:nth-child(5) .slds-truncate{
        cursor: default !important;
        color: #0176D3;
    }`)*/
    +
    `.companyTable .slds-table, .clipTable .slds-table, .dealTable .slds-table, .dealTable1 .slds-table, .peopleTable .slds-table{
        background: #f3f3f3;
    }
    .slds-table_header-fixed_container{
        background:#fff !important;
    }
    .slds-table tbody tr{
        height:40px !important;
    }    
    @media only screen and (max-width:1550px) and (min-width:1480){
        .slds-scrollable_x{
            overflow-x:hidden !important;
        }
    }
    @media (max-width:600px){
        .slds-table_header-fixed_container{
            margin-bottom: 0px !important;
            
        }
        .slds-scrollable_x{
            overflow-x:auto !important;
        }

        .radioBtns .slds-radio_button-group, .radioBtnsInterExter .slds-radio_button-group, .radioBtnsInterExterFund .slds-radio_button-group{
            width:100%;
            border:none !important;
            display:flex !important;
            gap:1px;
            justify-content: end;
            font-size:12px;
        }
        /*Raju for table row spacing or show 10 record on 04-07-2024 ; 00046388*/
         .contactDataTable .slds-table tr td .slds-button {
            line-height: inherit !important;
            padding-top: 0 !important;
            padding-bottom: 0 !important
        }
        /*Raju for table row spacing or show 10 record on 04-07-2024 ; 00046390*/
        .text-black button.slds-button {
            display: inline !important;
            line-height: inherit !important;
            padding-top: 0 !important;
            padding-bottom: 0 !important;
        }
    }`;
    rowBackgrounHover.innerText = `.contactDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .contactDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .dealDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .dealDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .companyTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .companyTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .dealTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .dealTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .peopleTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .peopleTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>td, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>th, .tableHeader .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
        background: none !important;
    }`;
    
    let taggedTabSize = (this.taggedSecOptions && this.taggedSecOptions.length > 0) ? (JSON.stringify(100 / this.taggedSecOptions.length) + '%') : '20%';
    buttonGroup.innerText = `.radioBtns .slds-button.slds-radio_button{
        width:` + taggedTabSize + `;
        display:inline-flex;
        }
        .radioBtns .slds-radio_faux{
           padding:0 !important;
           width:100%;
           display:inline-block;
           overflow:hidden;
           text-wrap: nowrap;
        }
        .radioBtns .slds-radio_button-group{
            width:100%;
            border:none !important;
            display:block;
        }
        .radioBtns .slds-radio_button__label{
            display: inline-block;
            width: 100%;
            background: #787878;
            color: #fff;
            padding: 0 2px !important; /*Bug Id 00045709 fixed bu Raju*/
        }
        @media (max-width: 72em) {
            .radioBtns .slds-button.slds-radio_button{
                width: initial;
                display: grid;
                grid-auto-columns: auto;
            }
            .radioBtns .slds-radio_faux{
                padding: 0px 0.51em 0px 0.51em !important;
                font-size: 12px;
            }
            .radioBtnsInterExter .slds-radio_faux{
                padding: 0px 14px !important;
            }
        }
        
        .radioBtns_fourbtn .slds-button.slds-radio_button{
            width:25%;
            display:inline-flex;
            }
        .radioBtns_fourbtn .slds-radio_faux{
            padding:0 !important;
            width:100%;
            display:inline-block;
            overflow:hidden;
            text-wrap: nowrap;
        }
        .radioBtns_fourbtn .slds-radio_button-group{
            width:100%;
            border:none !important;
            display:block;
        }
        .radioBtns_fourbtn .slds-radio_button__label{
            display: inline-block;
            width: 100%;
            background: #787878;
            color: #fff;
            padding: 0 5px !important;
        }
        @media (max-width: 72em) {
            .radioBtns_fourbtn .slds-button.slds-radio_button{
                width: initial;
                display: grid;
                grid-auto-columns: auto;
            }
            .radioBtns_fourbtn .slds-radio_faux{
                padding: 0px 0.51em 0px 0.51em !important;
                font-size: 12px;
            }
        }`;
    removeFocusCell.innerText = `.slds-table .slds-button:active{
        box-shadow:none !important;
        background:none !important;
    }`;
    showTootil_hide_slds_truncate.innerText = `.companyTable table tr th:nth-child(2) .slds-th__action .slds-truncate, .peopleTable table tr th:nth-child(2) .slds-th__action .slds-truncate, .dealTable table tr th:nth-child(2) .slds-th__action .slds-truncate, .contactDataTable table tr th:nth-last-child(-n+3) .slds-th__action .slds-truncate{display: none;}
    @media (max-width:600px){
        .dealTable table tr th:nth-child(2) .slds-th__action .slds-truncate, .contactDataTable table tr th:nth-last-child(-n+3) .slds-th__action .slds-truncate{display: block;}
        .contactDataTable .slds-button{
            font-size:12px !important;
        }
        }`;
    datatableHeader.innerText = `.slds-th__action{font-size: 12px; color: #3E3E3C; font-weight: 700}
        ds-has-focus.slds-is-resizable .slds-th__action, .slds-has-focus.slds-is-resizable .slds-th__action:focus, .slds-has-focus.slds-is-resizable .slds-th__action:hover, .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover, .slds-is-resizable .slds-th__action:focus, .slds-is-resizable .slds-th__action:focus:hover{box-shadow:none !important;background:none !important}
        .slds-button:focus {box-shadow:none !important;}`;
    iconColor.innerText = '.contactDataTable td .slds-icon, .tabDataTable .slds-icon{fill: #0070D2}';   
    cardHeadingColor.innerText = '.slds-card__body .slds-text-align_left{fill: #0070D2}';
    DealDataTableBox.innerText = `.dealDataTable .slds-table td:last-child{ height:41px;}
    @media (max-width:600px;){
        .dealDataTable .slds-table td{
            font-size:12px !important;
        }
    }`;
    tableHeaderColumnCenterReference.innerText = `.slds-grid_vertical-align-center{display: flex;justify-content: center;}`;
    let datatable = this.template.querySelector('lightning-datatable');
    if(datatable){
        datatable.appendChild(highlight_back_td);
        datatable.appendChild(showUnderlineTableCell);
        datatable.appendChild(tableBckNone);
        datatable.appendChild(datatableHeader);
        datatable.appendChild(iconColor);
        datatable.appendChild(cardHeadingColor);
        datatable.appendChild(DealDataTableBox);
        datatable.appendChild(rowBackgrounHover);
        datatable.appendChild(removeFocusCell);
        datatable.appendChild(showTootil_hide_slds_truncate);
    }
    let radioGroup = this.template.querySelector('lightning-radio-group');
    if(radioGroup && this.taggedSecOptions && this.taggedSecOptions.length > 0){
        radioGroup.appendChild(buttonGroup);
    }
    let iconC = this.template.querySelector('.iconC');
    if(iconC){
        iconC.appendChild(tableHeaderColumnCenterReference);
    }
}

/******************** Fdr Acuity > Fdr Contact Section Methods : Start ********************/

//Handles On Save when Role inline edit is performed.
handleSave(event) {
    const inputsItems = this.fldsItemValues.slice().map(draft => {
        const fields = Object.assign({}, draft);
        return { fields };
    });

    const promises = inputsItems.map(recordInput =>{
        updateRecord(recordInput)
    });
    Promise.all(promises).then(res => {
        this.fldsItemValues = [];
        if(this.interTable) {
            this.dealTeamRecordList.map(element=>{
                element.isEdited =  " ";
            });
        }
        //return this.refreshFDR(); //commented by Tejaswini - 00036037
    }).catch(error => {
        this.showToast(this, 'Error!', JSON.stringify(error.body.message), 'error');
    }).finally(() => {
        this.fldsItemValues = [];
        window.location.reload();//bug-00045524 By Harshwardhan
    });
}
//listener handler to get the context and data
picklistChanged(event) {
    event.stopPropagation();
    let dataRecieved = event.detail.data;
    let fieldApiName = dataRecieved.fieldApiName;
    let updatedItem = {};
    updatedItem['Id'] = dataRecieved.context;
    updatedItem[fieldApiName] = dataRecieved.value;
    this.updateDraftValues(updatedItem);
    this.updateDataValues(updatedItem, '');
}

async refreshFDR() {
    await this.handleOnLoadInfo();
}

handleFundraisingContactSelection(event) {
    this.selectedFundraisingContact = JSON.parse(JSON.stringify(event.detail.selectedRows));
}

handleFRCDelete(){
    let frcIdsDelete = [];
    if(this.selectedFundraisingContact != undefined)
    {
        this.selectedFundraisingContact.map(item=>{
            frcIdsDelete.push(item.Id);
        });
    }
    if(frcIdsDelete.length == 0){
        this.showToast(this, 'Info!', 'Select atleast a record.', 'info');    
    } else {
        deleteFundraisingContactRecord({frcIdsList : frcIdsDelete})
        .then(result => {
            this.showToast(this, 'Success', 'Record was removed.', 'Success'); //Tejaswini-00037889.
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.hidechecketr();
            return this.refreshFDR();
        }).catch(error => {
            //Added err msg check and updated err msg body in toast by LK on 2024-05-24 to fix 00044998
            let errMsg = error.body.message;
            this.showToast(this, 'Error!', (errMsg.includes('INSUFFICIENT_ACCESS_OR_READONLY') ? this.noDelAccessErrMsg : errMsg), 'error');
        });
    }
}

handleCellChangeFdr(event) {
    let draftValues = event.detail.draftValues;
    draftValues.forEach(ele=>{
        this.updateDraftValues(ele);
    })
}

updateDraftValues(updatedItem) {
    let draftValueChanged = false;
    let copyDraftValues = [...this.fldsItemValues];//Added by LK on 2024-05-26 to fix 00045954
    //show standard cancel & save button
    copyDraftValues.forEach(item => {
        if (item.Id === updatedItem.Id) {
            for (let field in updatedItem) {
                item[field] = updatedItem[field];
            }
            draftValueChanged = true;
        }
    });
    if (draftValueChanged) {
        this.fldsItemValues = [...copyDraftValues];
    } else {
        this.fldsItemValues = [...copyDraftValues, updatedItem];
    }

    if(this.interTable) {
        if(this.dealTeamRecordList != undefined){ //Modified by Anshika Ahuja W.R.To Error while performing Inline Editing.
        this.dealTeamRecordList.map(element=>{
            if(element.Id == updatedItem.Id) {
                element.isEdited =  "slds-is-edited";
            }
        });
    }
}
}
//updates datatable
updateDataValues(updatedItem, updatedValue){
    let copyData = JSON.parse(JSON.stringify(this.conData));
    copyData.forEach(item => {
        if (item.Id === updatedItem.Id) {
            for (let field in updatedItem) {
                item[field] = updatedItem[field];
                if(updatedValue) {
                    item[updatedValue] = updatedItem[field];
                }
            }
        }
    });
    this.conData = [...copyData];
}

showCheck(){
    if(this.fdrConPermissions['isDeletable']){
        this.chckBoxAdvisor = false;
        this.cancelRemove = true;
        this.addDisableexter = false;
        this.selectedColumnextr = this.columnsexternonedit;
        this.conCols.map(element=>{
            if(element.type == 'picklist') {
                element.typeAttributes.editable = false;
            }
        });
        this.template.querySelector('.remove_height').classList.add('extra_height'); 
        this.template.querySelector('.remove_height').classList.remove('heightC');
    } else {
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        //'You do not have permission to delete this record!'
        //Replaced this.noCreateAccessErrMsg with above error msg by LK on 2024-07-04 to fix 00046399
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error'); 
    }
}

/******************** Fdr Acuity > Fdr Contact Section Methods : End ********************/

/******************** Firm (PE) Acuity > Deal Section Methods : Start ********************/

processPEDealSecInfo(){
    this.isFirmPE = true;
    this.displayPEDealSecToggle = true;
    this.oldValueToSort = this.fieldNameForSortPe;
    if(this.peTabValue == 'Funds'){
        this.isFundTabPopup = true;
        this.isSourcedTabPopup = false;
            //Virendra Kumar-00035170,00035201,00035120,00035119,00035121,00035141
            this.helpTextForDealSection = helpTextForDealSections();
    }
    else{
        this.isFundTabPopup = false;
        this.isSourcedTabPopup = true;
            //Virendra Kumar-00035170,00035201,00035120,00035119,00035121,00035141
            this.helpTextForDealSection = helpTextForDealSections();
    }
    processDealInfo({ recordId : this.recordId, metadataField1 : 'Acuity_Firm_Contact_Deal_Field1', metadataField2 : 'Acuity_Firm_Contact_Deal_Field2', metadataField3 : 'Acuity_Firm_Contact_Deal_Field3', metadataField4 : 'Acuity_Firm_Contact_Deal_Field4', namespacePrefix : this.namespacePrefix, valueSorting: this.valueSorting, fieldNameForSort: this.fieldNameForSortPe, criteriaField: this.peTabValue})
    .then((result) => {
        this.enableSpinner = false;
        this.dealTitle = result.title;
        this.dealsCols = dealsColsValue();
        this.dealsColsMob = dealsColsValue();
        if(result){
            if(result.conSecDynFieldHeader){
                this.dealsCols.push(
                    { label: result.conSecDynFieldHeader.split(';')[0], fieldName: 'fieldInfo', fieldApiName:result.conSecDynFieldHeader.split(';')[0], type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'fieldInfo' }, target: '_blank',variant: 'base', tooltip: { fieldName: 'fieldInfo' }, title: { fieldName: 'fieldInfo' }},cellAttributes:{ class: 'text-black'}
            });
            }
            if(result.conSecDynFieldHeader2){ 
                this.dealsCols.push(
                    { label: result.conSecDynFieldHeader2.split(';')[0], fieldName: 'fieldInfo2', fieldApiName:result.conSecDynFieldHeader2.split(';')[0], type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'fieldInfo2' }, target: '_blank',variant: 'base', tooltip: { fieldName: 'fieldInfo2' }, title: { fieldName: 'fieldInfo2' }},cellAttributes:{ class: 'text-black'}
                });
            }
            if(result.conSecDynFieldHeader3){
                this.dealsCols.push(this.passColumnHeader(result.conSecDynFieldHeader3.split(';')[0],result.conSecDynFieldHeader3.split(';')[1],result.conSecDynFieldHeader3.split(';')[2], 'fieldInfo3', '',false));
                this.dealsColsMob.push(this.passColumnHeader(result.conSecDynFieldHeader3.split(';')[0],result.conSecDynFieldHeader3.split(';')[1],result.conSecDynFieldHeader3.split(';')[2], 'fieldInfo3', '',false));
            }
            this.dealsData = [];
            if(result.dealInfoWrapper.length > 0){
                this.showHideRemoveIcon = true;
                for(let recInfo of result.dealInfoWrapper){
                    this.dealsData.push({ Id: recInfo.recId, nameRef: recInfo.nameRef, name: recInfo.name, id2: recInfo.recId2, nameRef2: recInfo.nameRef2, name2: recInfo.name2, id3: recInfo.recId3, nameRef3: recInfo.nameRef3, name3: recInfo.name3, fieldInfo: recInfo.fieldInfo, fieldInfo2: recInfo.fieldInfo2, fieldInfo3: recInfo.fieldInfo3, fieldInfo4:recInfo.fieldInfo4, fieldInfo5: recInfo.fieldInfo5, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                }
            } else {
                this.showHideRemoveIcon = false;
                this.enableSpinner = false;
            }
            this.enableSpinner = false;
        }
        this.fieldNameForSortPe = '';
    })
    .catch((error) => {
        this.showToast(this, 'Error!', JSON.stringify(error.body.message), 'error');
        this.enableSpinner = false;
    });
}

passColumnHeader(headerName,fieldApiName, fieldType, fieldName, typeAttributesFieldName, isEditable) {
    if(fieldType === 'DATE'){
            //Kushal-34616
            return { label: headerName, fieldName: fieldName,fieldApiName:fieldApiName, type: 'date-local', hideDefaultActions: true, editable: isEditable, typeAttributes: { day: "numeric",
            month: "numeric",
            year: "numeric"}};
    } else if(fieldType === 'REFERENCE'){
        return { label: headerName, fieldName: fieldName,fieldApiName: fieldApiName, type: 'url', hideDefaultActions: true, cellAttributes: { class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: typeAttributesFieldName }, target: '_blank', tooltip: {fieldName: typeAttributesFieldName}}};
    } else if(fieldType === 'TEXTAREA'){
        return { label: headerName, fieldName: fieldName, fieldApiName: fieldApiName, type: 'text', hideDefaultActions: true, editable: isEditable};
    } else if(fieldType == 'STRING'){
        return { label: headerName, fieldName: fieldName, fieldApiName: fieldApiName, type: 'text', hideDefaultActions: true, editable: isEditable};
    } else if(fieldType == 'PICKLIST'){
        return { label: headerName, fieldName: fieldName,fieldApiName:fieldApiName, type: 'picklist', hideDefaultActions: true, editable:isEditable, cellAttributes: { class: {fieldName: 'isEdited'}},typeAttributes: { context: {fieldName: 'Id'}, editable: isEditable, options: {fieldName: 'picklistOptions'}, value: {fieldName: fieldName},fieldApiName: fieldApiName}};
    } else if(fieldType == 'CURRENCY'){//Bug fix - 00045524 by Harshwardhan
        return { label: headerName, fieldName: fieldName, fieldApiName: fieldApiName, type: 'text', hideDefaultActions: true, editable: true};
    } else if(fieldType == 'DOUBLE'){
        return { label: headerName, fieldName: fieldName, fieldApiName: fieldApiName, type: 'number', hideDefaultActions: true, editable: isEditable};
    }
}

handleChangeSorting(event) {
    let fieldNameToSort = '';
    if(this.oldValueToSort == event.detail.value) {
        if(this.valueSorting == 'DESC') {
            this.valueSorting = 'ASC';
        } else if (this.valueSorting == 'ASC') {
            this.valueSorting = 'DESC';
        }
    } else {
        this.valueSorting = 'DESC';
    }
    this.fieldNameForSortPe = event.detail.value;
    if(this.fieldNameForSortPe == 'stage') {
        this.processPEDealSecInfo();
        this.placeholderValue = 'Stage';
    } else if(this.fieldNameForSortPe == 'date') {
        fieldNameToSort = 'fieldInfo3';
        this.placeholderValue = 'Date Received';
    }
    this.dealsData = this.sortDataTable(fieldNameToSort,this.valueSorting, this.dealsData);
    this.oldValueToSort = this.fieldNameForSortPe;
    this.fieldNameForSortPe = null;
    this.template.querySelectorAll('lightning-combobox').forEach(each => {
        each.value = undefined;
    });
}

sortDataTable(fieldname, direction, sortTableData) {
    let parseData = JSON.parse(JSON.stringify(sortTableData));
    let keyValue = (a) => {
            return a[fieldname];
        };
    let isReverse = direction === 'ASC' ? 1: -1;
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : null; 
        y = keyValue(y) ? keyValue(y) : null;
        return (x===null)-(y===null) || isReverse * ((x > y) - (y > x));
    });
    return parseData;
}

handleReferencedinterexter(event){
    this.enableSpinner = true;
    this.peTabValue = event.detail.value;
    this.valueSorting = 'DESC';
    this.fieldNameForSortPe = 'date';
    this.placeholderValue = 'Date Received';
    this.processPEDealSecInfo();
    if(this.peTabValue == 'External'){
        this.dealTeamTabValue = 'External';
        this.getDealTeamRecords();
    }
    if(this.peTabValue == 'Internal'){
        this.dealTeamTabValue = 'Internal';
        this.getDealTeamRecords();           
    }
}
//Tejaswini- 00035104
handleToggleinterexterDT(event){
    this.enableSpinner = true;
    this.peTabValue = event.detail.value;
    this.valueSorting = 'DESC';
    this.fieldNameForSortPe = 'date';
    this.placeholderValue = 'Date Received';
    if(this.peTabValue == 'External'){
        this.dealTeamTabValue = 'External';
        if(this.externalDataDealTeam.length==0){
            this.getDealTeamRecords();
        } 
        else{
            this.showHideRemoveIcon = true;//Added by LK on 2024-10-23 to fix 00046419
            this.exterTable = true;
            this.interTable = false;
            this.externalAdd = true;
            this.internalAdd = false;
            this.enableSpinner = false; 
             
        }  
    }
    if(this.peTabValue == 'Internal'){
        this.dealTeamTabValue = 'Internal';
        if(this.internalDataDealTeam.length==0){
            this.getDealTeamRecords();
        }
        else{
            this.showHideRemoveIcon = true;//Added by LK on 2024-10-23 to fix 00046419
            this.exterTable = false;
            this.interTable = true;
            this.externalAdd = false;
            this.internalAdd = true;
            this.enableSpinner = false;  
        }        
    }
}

handleNewDeal_PrivateEquity(){
    if(this.dealPermissions['isCreateable']){
        this.publishEvent('Account.New_Deal');
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
}

handleNewDeal_PrivateEquity_SourcedFirm(){
    if(this.dealPermissions['isCreateable']){
        this.publishEvent('Account.New_Sourced_Deal');
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
}

/******************** Firm (PE) Acuity > Deal Section Methods : End ********************/

/******************** Deal Acuity > Deal Team (Internal) Section Methods : Start ********************/

getDealTeamRecords() {
    let metadataField1, metadataField2, metadataField3, metadataField4;
    if(this.dealTeamTabValue == 'Internal'){
        metadataField1 = 'Acuity_DealTeam_IntConnection_Field1';
        metadataField2 = 'Acuity_DealTeam_IntConnection_Field2';
        metadataField3 = 'Acuity_DealTeam_IntConnection_Field3';
        processDealTeamInfo({ recordId : this.recordId, metadataField1 : metadataField1, metadataField2 : metadataField2, metadataField3 : metadataField3,
            namespacePrefix : this.namespacePrefix, criteriaField: this.dealTeamTabValue})
        .then((result) => {
            this.internalDataDealTeam = [];//Added by LK on 2024-06-27 to fix 00046130
            this.exterTable = false;
            this.interTable = true;
            this.externalAdd = false;
            this.internalAdd = true;
            this.dealTeamColumnList = [];
            this.dealTeamColumnListMob = [];
            if(result){
                if(result.conSecDynFieldHeader){
                    this.dealTeamColumnList.push({ label: 'Name', fieldName: 'name', fieldApiName: result.conSecDynFieldHeader.split(';')[1], type: 'button', hideDefaultActions: true, editable: false, typeAttributes: { 
                        label: { fieldName: 'name' }, 
                        variant: 'base', 
                        tooltip: { fieldName: 'name' }},
                        cellAttributes:{ class: 'text-black'}
                    });
                    this.dealTeamColumnListMob.push({ label: 'Name', fieldName: 'name', fieldApiName: result.conSecDynFieldHeader.split(';')[1], type: 'text', hideDefaultActions: true, editable: false});
                }
                if(result.conSecDynFieldHeader2){
                    this.dealTeamColumnList.push({ label: 'Title', fieldName: 'fieldInfo', fieldApiName: result.conSecDynFieldHeader2.split(';')[1], type: 'text', hideDefaultActions: true, editable: false});
                    this.dealTeamColumnListMob.push({ label: 'Title', fieldName: 'fieldInfo', fieldApiName: result.conSecDynFieldHeader2.split(';')[1], type: 'text', hideDefaultActions: true, editable: false});
                }
                if(result.conSecDynFieldHeader3){
                    this.dealTeamColumnList.push(this.passColumnHeader(result.conSecDynFieldHeader3.split(';')[0],result.conSecDynFieldHeader3.split(';')[1],result.conSecDynFieldHeader3.split(';')[2], 'fieldInfo2', '', this.dealTeamPermissions['isEditable']));
                }
                if(result.dealInfoWrapper.length > 0){
                    this.showHideRemoveIcon = true;
                    for(let recInfo of result.dealInfoWrapper){
                        this.internalDataDealTeam.push({ Id: recInfo.Id, name: recInfo.name, 
                            fieldInfo: recInfo.fieldInfo, fieldInfo2: recInfo.fieldInfo2, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                    }
                    this.internalDataDealTeam = this.internalDataDealTeam.map(element=>{
                        return{
                            ...element, 'picklistOptions': this.dealTeamRoleOption
                        }
                    });                      
                } else if(result.dealInfoWrapper.length == 0){
                    this.showHideRemoveIcon = false;
                    this.enableSpinner = false;
                }
                this.enableSpinner = false;
            }
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
            this.enableSpinner = false;
        });
    } else { 
        metadataField1 = 'Acuity_DealTeam_Connection_Field1';
        metadataField2 = 'Acuity_DealTeam_Connection_Field2';
        metadataField3 = 'Acuity_DealTeam_Connection_Field3';
        metadataField4 = 'Acuity_DealTeam_Connection_Field4';
        processDealTeamEXTInfo({ recordId : this.recordId, metadataField1 : metadataField1, metadataField2 : metadataField2, metadataField3 : metadataField3, metadataField4 : metadataField4, 
            namespacePrefix : this.namespacePrefix})
        .then((result) => {
            this.externalDataDealTeam = [];//Added by LK on 2024-06-27 to fix 00046130
            this.enableSpinner = false;
            this.exterTable = true;
            this.interTable = false;
            this.externalAdd = true;
            this.internalAdd = false;
            this.conCols = conCols1();
            this.isEmailDrillDownEnabled = result.isEmailDrillDownEnabled;
            if(result.isEmailDrillDownEnabled){
                this.conCols.push({ label: 'Emails', iconName:'utility:email', initialWidth: 60, fieldName: 'emailRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'emailRef' }, variant: 'base', name:'emailRef', tooltip: {fieldName: 'emailRef'}}});
            } else {
                this.conCols.push({ label: 'Emails', iconName:'utility:email', initialWidth: 60, fieldName: 'emailRef', type: 'text', cellAttributes: { alignment: 'center' }, hideDefaultActions: true});
            }
            this.conColsMob = conColsMob1();
            if(result){
                if(result.conSecDynFieldHeader2){
                    this.conCols.splice(2, 0, { label: result.conSecDynFieldHeader2, fieldName: 'roleRef2', type: 'text', hideDefaultActions: true})
                }
                if(result.conSecDynFieldHeader){
                    this.conCols.splice(3, 0, { label: result.conSecDynFieldHeader, fieldName: 'conRef2', type: 'url', cellAttributes: { class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name2' }, target: '_blank', tooltip: {fieldName: 'name2'}}})
                }
                if(result.conSecDynFieldHeader3){
                    this.conCols.splice(4, 0, { label: result.conSecDynFieldHeader3, fieldName: 'roleRef3', type: 'picklist', hideDefaultActions: true, editable: this.dealTeamPermissions['isEditable'], typeAttributes: {
                        context: {fieldName: 'Id'},
                        editable: this.dealTeamPermissions['isEditable'],
                        fieldApiName: 'navpeII_dev18__Team_Member_Role__c',
                        options: {fieldName: 'picklistOptions'} ,
                        placeholder: 'Choose Role',
                        value:   {fieldName: 'roleRef3'}}})
                }
                if(result.conInfoWrapper.length > 0){
                    this.showHideRemoveIcon = true;
                    for(let recInfo of result.conInfoWrapper){
                        this.externalDataDealTeam.push({Id: recInfo.frcId, id2: recInfo.recId2, conRef2: recInfo.nameRef2, name2: recInfo.name2, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, roleRef2: recInfo.fieldInfo2, roleRef3: recInfo.fieldInfo3, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, actIdList : recInfo.actIdList, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                    }
                    this.externalDataDealTeam.sort(this.sortBy('totalActCount', -1));
                    this.externalDataDealTeam = this.externalDataDealTeam.map(element=>{
                        return{
                            ...element, 'picklistOptions': this.dealTeamRoleOption
                        }
                    });
                    this.enableSpinner = false;   
                }
                else if(result.conInfoWrapper.length == 0){
                    this.showHideRemoveIcon = false;
                    this.enableSpinner = false;
                }
            }
            //Added condition for "isMobile" by LK on 2024-08-09 to fix 00046350
            // if(result.apiError && !this.isMobile){
            //     this.showToast(this, 'Error!','An Error occurred in API', 'error');
            //     this.enableSpinner = false;
            // }
            //Commented above code and added below line by LK on 2024-10-21 to fix 00047544
            this.isRgApiError = result.apiError;
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
            this.enableSpinner = false;
        });
    }
}
//listener handler to get the context and data
dtPicklistChanged(event) {
    event.stopPropagation();
    let dataRecieved = event.detail.data;
    let fieldApiName = dataRecieved.fieldApiName;
    let updatedItem = {};
    updatedItem['Id'] = dataRecieved.context;
    updatedItem[fieldApiName] = dataRecieved.value;
    this.updateDraftValues(updatedItem);
}

//updates datatable
updateDTDataValues(updatedItem) {
    let copyData = JSON.parse(JSON.stringify(this.dealTeamRecordList));

    copyData.forEach(item => {
        if (item.Id === updatedItem.Id) {
            for (let field in updatedItem) {
                item[field] = updatedItem[field];
            }
        }
    });
    this.dealTeamRecordList = [...copyData];
}

/* Get selected record for UI */
selectedDealTeam = [];
getSelectedDealTeam(event) {
    this.selectedDealTeam = JSON.parse(JSON.stringify(event.detail.selectedRows));
}

/** Remove deal team record from deal on the click on remove button */
removeDealTeam() {
    let idsToDelete = [];
    this.selectedDealTeam.map(item=>{
        idsToDelete.push(item.Id);
    });
    if(idsToDelete.length == 0) {
        this.showToast(this, 'Error!','Select atleast a record.', 'error');
    } else {
        deleteDealTeamRecord({namespacePrefix : this.namespacePrefix, idsToDelete : idsToDelete})
        .then(result => {
            this.showToast(this, 'Success', 'Record was removed.', 'Success');
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.hidecheckintr();
            this.hidechecketr();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'navpeII_dev18__Pipeline__c',
                    actionName: 'view'
                }
            });
        }).catch(error => {
            //Added err msg check and updated err msg body in toast by LK on 2024-05-24 to fix 00044998
            let errMsg = error.body.message;
            this.showToast(this, 'Error!', (errMsg.includes('INSUFFICIENT_ACCESS_OR_READONLY') ? this.noDelAccessErrMsg : errMsg), 'error');
        });
    }
}

async refresh() {
    await this.getDealTeamRecords();
}

showCheckexter(){
    if(this.dealTeamPermissions['isDeletable']){
        this.chckBoxAdvisorexter = false;
        this.cancelRemove = true;
        this.interexterbtn = false;
        this.addDisableexter = false;

        this.template.querySelector('.remove_height').classList.add('extra_height'); 
        this.template.querySelector('.remove_height').classList.remove('heightC');

        this.conCols.map(element=>{
            if(element.type == 'picklist') {
                element.typeAttributes.editable = false;
            }
        });
    } else {
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        //Replaced this.noCreateAccessErrMsg with above error msg by LK on 2024-07-04 to fix 00046399
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error'); 
    }
}
showCheckinter(){
    if(this.dealTeamPermissions['isDeletable']){
        this.chckBoxAdvisorinter = false;
        this.cancelRemoveinter = true;
        this.addDisableinter = false;
        this.interexterbtn = false;
        this.template.querySelector('.remove_height').classList.add('extra_height'); 
        this.template.querySelector('.remove_height').classList.remove('heightC');
        this.dealTeamColumnList.map(element=>{
            if(element.type == 'picklist') {
                element.typeAttributes.editable = false;
            }
        });
    } else {
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        //Replaced this.noCreateAccessErrMsg with above error msg by LK on 2024-07-04 to fix 00046399
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
}
hidechecketr(){
    this.chckBoxAdvisor = true;
    this.chckBoxAdvisorexter = true;
    this.addDisableexter = true;
    this.cancelRemove = false;
    this.interexterbtn = true;
    this.template.querySelector('.remove_height').classList.add('heightC'); 
    this.template.querySelector('.remove_height').classList.remove('extra_height');
    //Replaced "dealTeamColumnList" with "conCols" by LK on 2024-06-11 to fix 00045321
    this.conCols.map(element=>{
        if(element.type == 'picklist') {
            element.typeAttributes.editable = true;
        }
    });
}
hidecheckintr(){ 
    this.addDisableinter = true;
    this.chckBoxAdvisorinter = true;
    this.cancelRemoveinter = false;
    this.interexterbtn = true;
    this.template.querySelector('.remove_height').classList.add('heightC'); 
    this.template.querySelector('.remove_height').classList.remove('extra_height');
    this.dealTeamColumnList.map(element=>{
        if(element.type == 'picklist') {
            element.typeAttributes.editable = true;
        }
    });
}

handleNewDealTeamMember(){
    if(this.dealTeamPermissions['isCreateable']){
        if(this.dealTeamTabValue === 'Internal'){
            this.publishEvent('navpeII_dev18__Pipeline__c.New_Team_Member');
        } else {
            this.publishEvent('navpeII_dev18__Pipeline__c.New_Deal_Contact');
        }
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
    
}

/******************** Deal Acuity > Deal Team (Internal) Section Methods : End ********************/

/******************** Fund Acuity > Fdr Section Methods : Start ********************/

selectItem(event) {
    console.log(event);
}

handleChangesSorting(event) {
    let fieldNameToSort = '';
    if(this.oldValueToSort == event.detail.value) {
        if(this.valueSortingFdr == 'DESC') {
            this.valueSortingFdr = 'ASC';
        } else if (this.valueSortingFdr == 'ASC') {
            this.valueSortingFdr = 'DESC';
        }
    } else {
        this.valueSortingFdr = 'DESC';
    }
    this.fieldNameForSort = event.detail.value;
    
    if(this.fieldNameForSort == 'stage') {
        this.createFundraisingUiInFund();
        this.placeholderValueFdr = 'Stage';
    } else if(this.fieldNameForSort == 'date') {// kushal 35329
        fieldNameToSort = 'fieldInfo3';
        this.placeholderValueFdr = 'Target Close Date';
    }
    this.conData = this.sortDataTable(fieldNameToSort,this.valueSortingFdr,this.conData);
    this.oldValueToSort = this.fieldNameForSort;
    this.fieldNameForSort = '';
    this.template.querySelectorAll('lightning-combobox').forEach(each => {
        each.value = undefined;
    });
}
oldTableData = []; 
createFundraisingUiInFund(){
    this.oldValueToSort = this.fieldNameForSort;
    processFdrInfo({ recordId : this.recordId, namespacePrefix : this.namespacePrefix, filterValue: this.filterValue, valueSorting: this.valueSortingFdr, fieldNameForSort: this.fieldNameForSort })
    .then((result) => {
        //Updated label by LK on 2024-05-29 to fix 00045422
        this.conCols = [{ label: this.fdrNameFieldLabel , fieldName: 'nameRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}}];
        this.conColsMob = [{ label: this.fdrNameFieldLabel , fieldName: 'nameRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}}];
        if(result){
            if(result.conSecDynFieldHeader){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader.split(';')[0], result.conSecDynFieldHeader.split(';')[1], result.conSecDynFieldHeader.split(';')[2], 'nameRef2', 'name2',false));
            }
            if(result.conSecDynFieldHeader7){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader7.split(';')[0],result.conSecDynFieldHeader7.split(';')[1],result.conSecDynFieldHeader7.split(';')[2], 'nameRef3', 'name3',false));
            }
            if(result.conSecDynFieldHeader2){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader2.split(';')[0],result.conSecDynFieldHeader2.split(';')[1],result.conSecDynFieldHeader2.split(';')[2], 'fieldInfo', '', this.fdrPermissions['isEditable']));
                this.conColsMob.push({ label: result.conSecDynFieldHeader2.split(';')[0], fieldName: 'fieldInfo',fieldApiName:result.conSecDynFieldHeader2.split(';')[1], type: 'picklist', hideDefaultActions: true, editable:false, typeAttributes: { context: {fieldName: 'Id'}, editable: false, options: {fieldName: 'picklistOptions'} , value: {fieldName: 'fieldInfo'}}});
            }
            if(result.conSecDynFieldHeader3){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader3.split(';')[0],result.conSecDynFieldHeader3.split(';')[1],result.conSecDynFieldHeader3.split(';')[2], 'fieldInfo2', '', true));
            }
            if(result.conSecDynFieldHeader4){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader4.split(';')[0],result.conSecDynFieldHeader4.split(';')[1],result.conSecDynFieldHeader4.split(';')[2], 'fieldInfo3', '', true));
            }
            if(result.conSecDynFieldHeader5){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader5.split(';')[0],result.conSecDynFieldHeader5.split(';')[1],result.conSecDynFieldHeader5.split(';')[2], 'fieldInfo4', '', true));
            }
            if(result.conSecDynFieldHeader6){
                this.conCols.push(this.passColumnHeader(result.conSecDynFieldHeader6.split(';')[0],result.conSecDynFieldHeader6.split(';')[1],result.conSecDynFieldHeader6.split(';')[2], 'fieldInfo5', '', true));
            }
            this.conData = [];
            if(result.funInfoWrapper.length > 0){
                this.showHideRemoveIcon = true;
                let i = 0;
                for(let recInfo of result.funInfoWrapper){
                    this.conData.push({ Id: recInfo.recId, nameRef: recInfo.nameRef, name: recInfo.name, id2: recInfo.recId2, nameRef2: recInfo.nameRef2, name2: recInfo.name2,
                        id3: recInfo.recId3, nameRef3: recInfo.nameRef3, name3: recInfo.name3, 
                        fieldInfo: recInfo.fieldInfo, fieldInfo2: recInfo.fieldInfo2, fieldInfo3: recInfo.fieldInfo3,  fieldInfo4:recInfo.fieldInfo4, fieldInfo5: recInfo.fieldInfo5, conColCls: 'slds-text-body_regular' + (recInfo.downloadIcon ? ' refCellHighlightCls' : '')});
                        this.passConvertedValue(result.conSecDynFieldHeader2.split(';')[2], 'fieldInfo', recInfo.fieldInfo, i);        
                        this.passConvertedValue(result.conSecDynFieldHeader3.split(';')[2], 'fieldInfo2', recInfo.fieldInfo2, i);        
                        this.passConvertedValue(result.conSecDynFieldHeader4.split(';')[2], 'fieldInfo3', recInfo.fieldInfo3, i);    
                        this.passConvertedValue(result.conSecDynFieldHeader5.split(';')[2], 'fieldInfo4', recInfo.fieldInfo4, i);    
                        this.passConvertedValue(result.conSecDynFieldHeader6.split(';')[2], 'fieldInfo5', recInfo.fieldInfo5, i);    
                i++;
                }
                this.conData = this.conData.map(element=>{
                    return{
                        ...element, 'picklistOptions': this.fundraisingStage
                    }
                });
                this.enableSpinner = false;
                this.fieldNameForSort = '';
            } else {
                this.showHideRemoveIcon = false;
                this.enableSpinner = false;
            }
        }
        this.enableSpinner = false;
        this.oldTableData = [...this.conData];
    })
    .catch((error) => {
        this.showToast(this, 'Error!', error.body.message, 'error');
        this.enableSpinner = false;
    });
}

passConvertedValue(fieldType, fieldName ,fieldValue, indexValue) {
    if(fieldType == 'DATE') {
            //Kushal 34616
            let dateValue = new Date(fieldValue);
            return this.conData[indexValue][fieldName] = isNaN(Date.parse(fieldValue)) == true ?  '' : dateValue.toISOString().substring(0,10);
    }//Removed Currency Code - Bug fix 00045524 harshwardhan
    if(fieldType == 'DOUBLE') {
        if(fieldValue == undefined) {
            return null;
        } else {
            return this.conData[indexValue][fieldName] =  parseFloat(fieldValue.replace(",", "").replace("$", "")); 
        }
    }
}

chckBoxshow(){
    if(this.fdrPermissions['isDeletable']){
        this.chckBoxdel = false;
        this.cancelRemove = true;
        this.addDisableexter = false;
        this.template.querySelector('.remove_height').classList.add('extra_height'); 
        this.template.querySelector('.remove_height').classList.remove('heightC');
        this.conCols.map(element=>{
            element.editable = false;
            if(element.type == 'picklist') {
                element.typeAttributes.editable = false; 
            }
        });
    } else {
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        //Replaced this.noCreateAccessErrMsg with above error msg by LK on 2024-07-04 to fix 00046399
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
    
}

hideCheckBoxFdr(){
    this.chckBoxdel = true;
    this.cancelRemove = false;
    this.addDisableexter = true;
    this.template.querySelector('.remove_height').classList.add('heightC'); 
    this.template.querySelector('.remove_height').classList.remove('extra_height');
    this.conCols.map(element=>{
        if(element.type != 'url') {
            element.editable = true;  
            if(element.type == 'picklist') {
                element.typeAttributes.editable = true; 
            }
        }
    });
}

selectedFundraising = [];
getSelectedFundraising(event) {
    this.selectedFundraising = JSON.parse(JSON.stringify(event.detail.selectedRows));
}

removeFundraising() {
    let idsToDelete = [];
    let deletedRecordName = [];
    this.selectedFundraising.map(item=>{
        idsToDelete.push(item.Id);
        deletedRecordName.push(item.name);
    });
    if(idsToDelete.length == 0) {
        this.showToast(this, 'Error!','Select atleast a record.', 'error');
    } else {

        deleteFundraisingRecord({idsToDelete : idsToDelete, namespacePrefix : this.namespacePrefix})
        .then(result => {   
            this.showToast(this, 'Success', 'Record was removed.', 'Success');
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.hideCheckBoxFdr();
            return this.refreshFdr();
        }).catch(error => {
            //Added err msg check and updated err msg body in toast by LK on 2024-05-24 to fix 00044998
            let errMsg = error.body.message;
            this.showToast(this, 'Error!', (errMsg.includes('INSUFFICIENT_ACCESS_OR_READONLY') ? this.noDelAccessErrMsg : errMsg), 'error');
        });
    }
}

async refreshFdr() {
    await this.createFundraisingUiInFund();
}

handleCellChange(event) {
    //Added else condition and moved existing code inside if condition by LK on 2023-03-21 to revert the Sharing Model
    if(this.objectApiName === (this.namespacePrefix + 'Fund__c') && this.fdrPermissions['isEditable']){
        let updateItem = event.detail.draftValues[0];
        let updatedValue;
        let copyData = JSON.parse(JSON.stringify(this.conCols));
        copyData.forEach(item => {
            if (updateItem.hasOwnProperty(item.fieldName)) {
                updateItem[item.fieldApiName] = (item.fieldApiName == 'navpeII_dev18__Investment_Likely_Amount_USD_mn__c') ? updateItem[item.fieldName].substring(updateItem[item.fieldName].indexOf(updateItem[item.fieldName].match(/\d+/)[0])) : updateItem[item.fieldName];//Bug45961 Fix By Harshwardhan
                updatedValue = item.fieldName;
                delete updateItem[item.fieldName];
            }
        });
        this.updateDraftValues(updateItem);
        this.updateDataValues(updateItem, updatedValue);
    } else {
        this.handleCancel();
        this.showToast(this, 'Error!', 'You do not have permission to edit this record!', 'error');
    }
}

handleCancel(event) {
    this.fldsItemValues = [];
    this.conData = [...this.oldTableData];
}

/******************** Fund Acuity > Fdr Section Methods : End ********************/

@wire(MessageContext)
messageContext;
publishEvent(actionName) {
    const messaage = {
        quickActionName: actionName
    };
    publish(this.messageContext, ICON_CHANNEL, messaage);
}

/* Fund Acuity : Plus Icon : NSD : Start */
handleNewFdrCon(){
    if(this.fdrPermissions['isCreateable']){
        this.displayAddCmp = true;
        this.plusIconObjApiName = 'Fund';
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
    
}
handleNewFdr(){
    if(this.fdrPermissions['isCreateable']){
        this.displayAddCmp = true;
        this.plusIconObjApiName = 'Account';
    } else {
        //Msg updated by LK on 2024-05-13 to fix 00045572
        //Removed "Error!" by LK on 2024-07-04 to fix 00046365 - Code Reverted
        this.showToast(this, 'Error!', this.noCreateAccessErrMsg, 'error');
    }
    
}
/* Fund Acuity : Plus Icon : NSD : End */
/* Plus Icon : NSD : Start */
checkSelected(event){
    this.displayAddCmp = event.detail;
}
/* Plus Icon : NSD : End */
noteModalClosed() {
    this.isCallLogOpen = false;
}

// added by Sudhanshu for Citadel CR
flowList = [];
handleFlowName(){
    // this.flowList = getFlowName(this.objectApiName);
    const objectList = [this.namespacePrefix+"Pipeline__c", this.namespacePrefix+"Fund__c", this.namespacePrefix+"Fundraising__c"];
    if(objectList.includes(this.objectApiName))
    {
        fetchFlowNames({objectName : this.objectApiName})
        .then(res => {
            this.flowList = res;
            console.log('Flow Names'+res);
            
            
        })
        .catch(err =>{
                
        })
    }
}


}