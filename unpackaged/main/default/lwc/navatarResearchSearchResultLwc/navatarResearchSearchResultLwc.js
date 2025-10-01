import {LightningElement,track,api,wire} from 'lwc';
import getSearchResultListPro from '@salesforce/apex/NavatarResearchCtrl.getSearchResultListWithAdvance';
import setColumn from '@salesforce/apex/NavatarResearchCtrl.setColumnAndFields';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
export default class NavatarResearchSearchResultLwc extends NavigationMixin(LightningElement) {
    /* Added below code by LK for the Add to Fund functionality - START */
    pluralLabelMap; //for dynamic label change by salauddin sheikh 5th july 2023
    themeDesLabel; // changes for bug #00041614 fixes by salauddin sheikh
    /* Added above code by LK for the Add to Fund functionality - START */
    loading =true;
    exptGblFldTypeCast = {};
    //advance check Attribute
    @api advanceCheck;
    @api callingFrom;
    @api callFromObject;
    @api callFromRecId;
    themeProcess=false;
    filedFilterData=[];
    specificOptionList=[];
    @track accQryFld;
    @track conQryFld;
    @track dealQryFld;
    @track fundQryFld;
    @track fdrQryFld;
    @track taskQryFld;
    @track thmQryFld;
    @track clipQryFld;
    // Current Research variable 
    @api currentObj;
    @api currentId;
    //Phase 2 Advance search variables 
   @track themeList=[];
   @track clipList=[];
   @track themeSize=0;
   @track clipSize=0;
   @track sizeFileList=0;
   @track loadFirstComp=false;

  @track selectionTabelDataFull = [];
  @track wholeMapDataFull=[];

    // Phase 2 variables End
    checkModal = false; //for-window-scroller-get-hide-when-modal-popup-open//
    @track refreshCheck = false;
    @track accFieldTypeMap=[];
    @track conFieldTypeMap=[];
    @track dealFieldTypeMap=[];
    @track fundFieldTypeMap=[];
    @track fdrFieldTypeMap=[];

    @track themeFieldTypeMap=[];
    @track clipFieldTypeMap=[];

    @track lWCTblThmColList = [];
    @track lWCTblClipColList = [];
    
    @track themeColumnList ;
    @track clipColumnList ;
    // variable are used for 5 records only for every object
    @track fiveAccList;
    @track fiveConList;
    @track fiveDealList;
    @track fiveFundList;
    @track fiveFdrList;
    @track fiveInteractionList;

    @track fiveFileList;
    @track fiveThemeList;
    @track fiveClipList;
    iconListForObjects=[];
    labelListForObjects=[];
    @track dealIcon;
    @track fundIcon;
    @track fundraisingIcon;
    @track themeIcon;
    @track clipIcon;
    
    @track accountLabel;
    @track contactLabel;
    @track dealLabel;
    @track fundLabel;
    @track fdrLabel;
    @track themeLabel; 
    @track clipLabel;

    @track accPermission;
    @track conPermission;
    @track dealPermission;
    @track fundPermission;
    @track fdrPermission;
    @track themePermission;
    @track clipPermission;
    //---------------------
    @api propertyValue; 
    @api mechanishmValue
    @track outerNoRecordOBject; 
    @track searchRecord;
    noRecordTempDisplay = false;
    @track showWarningMessage = false;
    @track totalSearchRecord = 0;

    searchValue = ''; // after passing parameter in search method, value holder 
    leftVerticalHeader = false; // boolean variable for showing the left vertical layout 
    // here all varaibles present which are used for salesforce Object
    @track isPrsntAccRecTypeNamesLft = false;
    @track isPrsntConRecTypeNamesLft = false;
    @track isPrsntDealRecTypeNamesLft = false;
    @track isPrsntFundRecTypeNamesLft = false;
    @track isPrsntFdrRecTypeNamesLft = false;
    @track accList;
    @track repsntAccList;
    @track sizeAccountList;
    @track sizeFrontAccountList = 0;
    accRecTypeNames = [];
    @track isPrsntAccRecTypeNames = false;
    innerAccountListShow = false;
    accountListShow = false;
    showInnerAccRecTypeSec = false;
    @track accColList;
    @track accountTableName = "Firm";
    @track lWCTblAccColList = [];
    @track fullAccMngDataAtServerCall = [];
    @track conList;
    @track rprsntConList;
    @track sizeContactList;
    @track sizeFrontContactList = 0;
    conRecTypeNames = [];
    @track isPrsntConRecTypeNames = false;
    contactListShow = false;
    innerContactListShow = false;
    showInnerContactRecordTypeSection = false;
    @track conColList;
    @track contactTableName = "Contact";
    @track lWCTblConColList = [];
    @track fullConMngDataAtServerCall = [];
    @track fundList;
    @track representFundList;
    @track sizeFundList;
    @track sizeFrontFundList = 0;
    fundRecordTypeNames = [];
    @track isPresentFundtRecordTypeNames = false;
    fundListShow = false;
    innerFundListShow = false;
    showInnerFundRecordTypeSection = false;
    @track fundColumnList;
    @track fundTableName = 'Fund';
    @track lWCTabelFundColumnList = [];
    @track fullFundMngDataAtServerCall = [];
    @track dealList;
    @track representDealList;
    @track sizeDealList;
    @track sizeFrontDealList = 0;
    dealRecordTypeNames = [];
    @track isPresentDealRecordTypeNames = false;
    dealListShow = false;
    sizeFrontDealList = 0;
    innerDealListShow = false;
    @track dealTableName = 'Deal';
    showInnerDealRecordTypeSection = false;
    @track dealColumnList;
    @track lWCTabelDealColumnList = [];
    @track fullDealMngDataAtServerCall = [];
    @track fdrList;
    @track rprsntFdrList;
    fdrRecTypeNames = [];
    @track isPresentFdrRecTypeNames = false;
    @track sizeFdrList;
    @track sizeFrontFdrList = 0;
    fdrListShow = false;
    innerFdrListShow = false;
    showInnerFdrRecTypeSection = false;
    @track fdrColumnList;
    @track lWCTabelFdrColList = [];
    
    @track fdrTableName = 'Fundraising';
    @track fullFdrMngDataAtServerCallTime = [];
    @track taskList;
    @track representTaskList;
    taskRecordTypeNames = [];
    @track sizeTaskList;
    @track sizeFrontTaskList = 0;
    taskListShow = false;
    innerTaskListShow = false;
    showInnerTaskRecordTypeSection = false;
    @track taskColumnList;
    @track lWCTabelTaskColumnList = [];
    @track fullTaskManageDataAtServerCallingTime = [];

    fileListShow = false;
    innerFileListShow = false;

    themeListShow = false;
    innerThemeListShow = false;
    clipListShow = false;
    innerClipListShow = false;
     
    error;
    //-------------------------------------
    //controling the view more button visibility for every object
    viewMoreAccount = false;
    viewMoreContact = false;
    viewMoreDeal = false;
    viewMoreFund = false;
    viewMoreFundRaising = false;
    viewMoreTask = false;
    viewMoreEvent = false;

    viewMoreFile = false;
    viewMoreTheme = false;
    viewMoreClip = false;
    //------------------------------------------
    @track accRecTypeObjList = [];
    @track conRecTypeObjList = [];
    @track dealRecTypeObjList = [];
    @track fundRecTypeObjList = [];
    @track fdrRecTypeObjList = [];
    @track taskRecTypeObjList = [];
     
    @track filesColumn=[{label: 'Name',fieldName: 'recordId',type: 'button',cellAttributes: {alignment: 'left',class: 'slds-truncate text-blue slds-text-link'},hideDefaultActions: true,typeAttributes: {label: {fieldName: 'recordName'},variant: 'base',name: 'recordName',tooltip: {fieldName: 'recordName'},target: '_blank'},target: '_blank'},
    {label: "Description",  fieldName: "description",  type: "text",hideDefaultActions: true},
    {label: 'Linked To',fieldName: 'parentRecordId',type: 'button',cellAttributes: {alignment: 'left',class: 'slds-truncate'},hideDefaultActions: true,typeAttributes: {label: {fieldName: 'parentRecordName'},variant: 'base',name: 'parentRecordName',tooltip: {fieldName: 'parentRecordName'},target: '_blank'},target: '_blank'}
];
    
    @track interactionTableHeader = [{label: "Date",fieldName: "Date",type: "button",hideDefaultActions: true,tooltip: {fieldName: "Date"},cellAttributes: {alignment: 'left',class: 'text-black'},typeAttributes: {label: {fieldName: 'Date'},variant: 'base',name: 'Date',tooltip: {fieldName: 'Date'},}},
        {label: 'Subject',fieldName: 'NameFieldData',type: 'button',cellAttributes: {alignment: 'left',class: 'slds-truncate text-blue slds-text-link'},hideDefaultActions: true,typeAttributes: {label: {fieldName: 'Subject'},variant: 'base',name: 'Subject',tooltip: {fieldName: 'Subject'},target: '_blank'},target: '_blank'},
        {label: "Comments",fieldName: "Description",type: "button",hideDefaultActions: true,tooltip: {fieldName: "Description"},cellAttributes: {alignment: 'left',class: 'text-black'},typeAttributes: {label: {fieldName: 'Description'},variant: 'base',name: 'Description',tooltip: {fieldName: 'Description'},}}
    ];
    connectedCallback() {
        if(this.mechanishmValue != undefined && this.mechanishmValue == 'systemWide'){
           this.currentId =''; 
        }
        this.themeProcess=(this.callingFrom !='' && this.callingFrom == 'ThemePage' && this.callFromObject !='' && this.callFromObject == 'navpeII_dev18__Theme__c' && this.callFromRecId !='' && this.callFromRecId != undefined);
    }

    @wire(setColumn)
    getWiredFunctions({data,error}) {
        if (data) {
            this.searchValue = this.propertyValue;
            if(this.mechanishmValue != undefined && this.mechanishmValue == 'systemWide'){
                this.currentId =''; 
             }
            if (data.errorMessage == '' || data.errorMessage == null || data.errorMessage == undefined) {
                this.accColList = [];
                this.conColList = [];
                this.dealColumnList = [];
                this.fundColumnList = [];
                this.fdrColumnList = [];
                this.taskColumnList = [];
                this.themeColumnList = [];
                this.clipColumnList = [];

                this.accQryFld=data.quearyFieldsForAccount;
                this.conQryFld=data.quearyFieldsForContact;
                this.dealQryFld=data.quearyFieldsForDeal;
                this.fundQryFld=data.quearyFieldsForFund;
                this.fdrQryFld=data.quearyFieldsForFundRaising;
                this.taskQryFld=data.quearyFieldsForTask;
                this.thmQryFld=data.quearyFieldsForTheme;
                this.clipQryFld=data.quearyFieldsForClip;
//---------------------export functionality column data ------
                this.exptGblFldTypeCast['Account'] = data.accountListColumns;
                this.exptGblFldTypeCast['Contact'] = data.contactListColumns;
                this.exptGblFldTypeCast['Pipeline__c'] = data.dealListColumns;
                this.exptGblFldTypeCast['Fund'] = data.fundListColumns;
                this.exptGblFldTypeCast['Fundraising'] = data.fundRaisListColumns;
                this.exptGblFldTypeCast['Theme'] = data.themeListColumns;
                this.exptGblFldTypeCast['Clip'] = data.clipListColumns;
                this.exptGblFldTypeCast['Intraction'] = [{"fieldLabel":"Date","fieldName":"ActivityDate"},{"fieldLabel":"Subject","fieldName":"Subject"},{"fieldLabel":"Description","fieldName":"Description"}];
                this.exptGblFldTypeCast['TaggedContact'] = [{"fieldLabel":"Subject","fieldName":"parentRecordName"},{"fieldLabel":"Comments","fieldName":"description"},{"fieldLabel":"Participants","fieldName":"commaSepRelativeObjectDataStringContacts"},{"fieldLabel":"Tags","fieldName":"commaSepRelativeObjectDataStringAssociate"}];
                this.exptGblFldTypeCast['TaggedFirms'] = [{"fieldLabel":"Subject","fieldName":"parentRecordName"},{"fieldLabel":"Comments","fieldName":"description"},{"fieldLabel":"Participants","fieldName":"commaSepRelativeObjectDataStringContacts"},{"fieldLabel":"Tags","fieldName":"commaSepRelativeObjectDataStringAssociate"}];
//-------------------------------------------------------------           
                this.accColList = data.accountListColumns;
                this.conColList = data.contactListColumns;
                this.dealColumnList = data.dealListColumns;
                this.fundColumnList = data.fundListColumns;
                this.fdrColumnList = data.fundRaisListColumns;
                this.taskColumnList = data.taskListColumns;
                this.themeColumnList = data.themeListColumns;
                this.clipColumnList = data.clipListColumns;

                var storeMapData=[];
                storeMapData=data.globalObjFieldTypeMap;
                this.accFieldTypeMap=storeMapData['Account'];
                this.conFieldTypeMap=storeMapData['Contact'];
                this.dealFieldTypeMap=storeMapData['Deal'];
                this.fundFieldTypeMap=storeMapData['Fund'];
                this.fdrFieldTypeMap=storeMapData['Fundraising'];
                this.themeFieldTypeMap=storeMapData['Theme'];
                this.clipFieldTypeMap=storeMapData['Clip'];

                this.iconListForObjects=data.iconMap;
                
                this.dealIcon=this.iconListForObjects['navpeII_dev18__Pipeline__c'];
                this.fundIcon=this.iconListForObjects['navpeII_dev18__Fund__c'];
                this.fundraisingIcon=this.iconListForObjects['navpeII_dev18__Fundraising__c']; 
                this.themeIcon=this.iconListForObjects['Themes']; 
                this.clipIcon=this.iconListForObjects['Clips'];
                this.pluralLabelMap = data.pluralLabelMap; //for dynamic label change by salauddin sheikh 5th july 2023
                this.labelListForObjects=data.labelMap;
                this.accountLabel=this.labelListForObjects['Account'];
                this.contactLabel=this.labelListForObjects['Contact'];
                this.dealLabel=this.labelListForObjects['navpeII_dev18__Pipeline__c'];
                this.fundLabel=this.labelListForObjects['navpeII_dev18__Fund__c'];
                this.fdrLabel=this.labelListForObjects['navpeII_dev18__Fundraising__c']; 
                this.themeLabel=this.labelListForObjects['navpeII_dev18__Theme__c'];
                this.clipLabel=this.labelListForObjects['navpeII_dev18__Clip__c'];
                this.accountTableName=this.accountLabel;
                this.contactTableName=this.contactLabel;
                this.fundTableName=this.fundLabel;
                this.dealTableName=this.dealLabel;
                this.fdrTableName=this.fdrLabel;

                this.accPermission = data.objectAccessList[0] == 'yes';
                if(data.objectAccessList[0] == 'yes'){this.specificOptionList.push({label: this.accountLabel, value: 'Account' });}
                this.conPermission = data.objectAccessList[1] == 'yes';
                if(data.objectAccessList[1] == 'yes'){this.specificOptionList.push({ label: this.contactLabel, value: 'Contact' });}
                this.dealPermission = data.objectAccessList[2] == 'yes';
                if(data.objectAccessList[2] == 'yes'){this.specificOptionList.push({ label: this.dealLabel, value: 'navpeII_dev18__Pipeline__c' });}
                this.fundPermission = data.objectAccessList[3] == 'yes';
                if(data.objectAccessList[3] == 'yes'){this.specificOptionList.push({ label: this.fundLabel, value: 'navpeII_dev18__Fund__c' });}
                this.fdrPermission = data.objectAccessList[4] == 'yes';
                if(data.objectAccessList[4] == 'yes'){this.specificOptionList.push({ label: this.fdrLabel, value: 'navpeII_dev18__Fundraising__c' });}
                this.themePermission = data.objectAccessList[5] == 'yes';
                if(data.objectAccessList[5] == 'yes'){
                    this.specificOptionList.push({ label: this.themeLabel, value: 'navpeII_dev18__Theme__c' });
                    this.themeDesLabel = this.themeColumnList[1].fieldLabel;    // changes for bug #00041614 fixes by salauddin sheikh
                } else {
                    this.themeDesLabel = 'Description';
                }
                this.clipPermission = data.objectAccessList[6] == 'yes';
               
                this.columnMaker('Firms', this.accColList);
                this.columnMaker('Contacts', this.conColList);
                this.columnMaker('Deals', this.dealColumnList);
                this.columnMaker('Funds', this.fundColumnList);
                this.columnMaker('FundRaising', this.fdrColumnList);
                this.columnMaker('Themes', this.themeColumnList);
                this.columnMaker('Clips', this.clipColumnList);
                this.loading=false;
                if(this.currentId != undefined && this.currentId != '' && this.currentId != null ){
                let newSSobj = {"Account":[],"Contact":[],"navpeII_dev18__Pipeline__c":[],"navpeII_dev18__Fund__c":[],"navpeII_dev18__Fundraising__c":[],"navpeII_dev18__Theme__c":[],"navpeII_dev18__Clip__c":[]};
                    let listVar=[];
                    listVar.push(this.currentId );
                newSSobj[this.currentObj]=listVar;
                this.handleSearch(newSSobj,null,'comingFromChild');
                }else{
                    this.handleSearch();
                }
                this.error = undefined;
            } else {
                const event = new ShowToastEvent({title: 'Error',variant: 'error',message: data.errorMessage,mode: 'sticky'});
                this.dispatchEvent(event);
            }
        } else if (error) {
            this.error = error;
            const event = new ShowToastEvent({title: 'Error',variant: 'error',message: this.error,mode: 'sticky'});
            this.dispatchEvent(event);
        }
    }

    columnMaker(object, columnList) {
        var copyColumnListData = [...columnList];
        for (var i = 0; i < copyColumnListData.length; i++) {
            var normalFields = {label: "",fieldName: "",type: "",hideDefaultActions: true,tooltip: {fieldName: ""},typeAttributes: {label: {fieldName: ""},tooltip: { fieldName: ""}},cellAttributes:{class:"",alignment:""},initialWidth:""};
            var referenceFields = {label: "",fieldName: "",type: "",typeAttributes: {label: {fieldName: ""},tooltip: {fieldName: ""},target: '_blank'},hideDefaultActions: true,initialWidth:"",cellAttributes:{class:{	fieldName:'referenceColumnClass'}}};
            if (copyColumnListData[i].fieldType == 'REFERENCE' || copyColumnListData[i].fieldName == 'Name' || copyColumnListData[i].fieldName == 'Subject') {
                referenceFields.label = (copyColumnListData[i].fieldLabel == 'Legal Name') ? 'Firm' : copyColumnListData[i].fieldLabel;
                referenceFields.type = (object == 'Clips') ? "button" : "url";
                
                if (copyColumnListData[i].fieldName == 'Name' || copyColumnListData[i].fieldName == 'Subject') {
                    referenceFields.fieldName = "NameFieldData";
                    referenceFields.initialWidth=(object == 'Funds') ? "" : 280;
                    
                    let phase = (copyColumnListData[i].fieldName == 'Name') ? "Name" : "Subject";
                    referenceFields.typeAttributes.label = {fieldName: phase};
                    referenceFields.typeAttributes.tooltip.fieldName=phase;
                    if(object == 'Clips'){
                        referenceFields.cellAttributes= {alignment: 'left',class: 'slds-truncate text-blue slds-text-link'};
                        referenceFields.typeAttributes.target='_blank';
                        referenceFields.hideDefaultActions= true;
                        referenceFields.typeAttributes.variant= 'base';
                    }
                } else {
                    referenceFields.initialWidth=250;
                    referenceFields.fieldName = copyColumnListData[i].fieldName;
                    let refFieldData= copyColumnListData[i].fieldName + 'refName';
                    referenceFields.typeAttributes.label = {fieldName: refFieldData};
                    referenceFields.typeAttributes.tooltip.fieldName = refFieldData;
                }
                if (object == 'Firms') {this.lWCTblAccColList.push(referenceFields);}
                if (object == 'Contacts') {this.lWCTblConColList.push(referenceFields);}
                if (object == 'Deals') {this.lWCTabelDealColumnList.push(referenceFields);}
                if (object == 'Funds') {this.lWCTabelFundColumnList.push(referenceFields);}
                if (object == 'FundRaising') {this.lWCTabelFdrColList.push(referenceFields);}
                if (object == 'Themes') {this.lWCTblThmColList.push(referenceFields);}
                if (object == 'Clips') {this.lWCTblClipColList.push(referenceFields);}
                if (object == 'Tasks') {this.lWCTabelTaskColumnList.push(referenceFields);}
                if (object == 'Events') {this.lWCTabelEventColumnList.push(referenceFields);}
            } else {
                if (copyColumnListData[i].fieldType == 'PHONE' || (copyColumnListData[i].fieldType == 'EMAIL' || (copyColumnListData[i].fieldType == 'CURRENCY' || copyColumnListData[i].fieldType == 'URL'))) {
                    normalFields.label = copyColumnListData[i].fieldLabel;
                    normalFields.fieldName = copyColumnListData[i].fieldName;
                    normalFields.type = copyColumnListData[i].fieldType;
                    normalFields.typeAttributes.tooltip.label=copyColumnListData[i].fieldName;
                    normalFields.typeAttributes.tooltip.fieldName=copyColumnListData[i].fieldName;
                } else {
                    normalFields.label = copyColumnListData[i].fieldLabel;
                    normalFields.fieldName = copyColumnListData[i].fieldName;
                    normalFields.type = 'button';
                    normalFields.tooltip.fieldName=copyColumnListData[i].fieldLabel;
                    normalFields.typeAttributes.tooltip.label=copyColumnListData[i].fieldName;
                    normalFields.typeAttributes.tooltip.fieldName=copyColumnListData[i].fieldName;
                    normalFields.typeAttributes.label.fieldName=copyColumnListData[i].fieldName;
                    
                    normalFields.cellAttributes.alignment='left';
                    normalFields.cellAttributes.class='text-black';
                    normalFields.typeAttributes.variant= 'base';
                }
               
                if (object == 'Firms') {
                    normalFields.fixedWidth = 1400;
                    this.lWCTblAccColList.push(normalFields);
                }
                if (object == 'Contacts') {
                    normalFields.fixedWidth = 1100;
                    this.lWCTblConColList.push(normalFields);
                }
                if (object == 'Deals') {this.lWCTabelDealColumnList.push(normalFields);}
                if (object == 'Funds') {this.lWCTabelFundColumnList.push(normalFields);}
                if (object == 'FundRaising') {
                    normalFields.fixedWidth=1100;
                    this.lWCTabelFdrColList.push(normalFields);
                }
                if (object == 'Themes') {this.lWCTblThmColList.push(normalFields);}
                if (object == 'Clips') {this.lWCTblClipColList.push(normalFields);}
                if (object == 'Tasks') {this.lWCTabelTaskColumnList.push(normalFields);}
                if (object == 'Events') {this.lWCTabelEventColumnList.push(normalFields);}
            }
        }
    }
    showAndHideLeftGridSection='';
    norecordFound(){
        this.noRecordTempDisplay = true;
        this.accRecTypeNames = this.searchRecord.accountRecordTypeList;
        this.conRecTypeNames = this.searchRecord.contactRecordTypeList;
        this.dealRecordTypeNames = this.searchRecord.dealRecordTypeList;
        this.fundRecordTypeNames = this.searchRecord.fundRecordTypeList;
        this.fdrRecTypeNames = this.searchRecord.fundraisingRecordTypeList;
        if (this.accRecTypeNames.length >= 1) {
            this.isPrsntAccRecTypeNames = true;
            this.isPrsntAccRecTypeNamesLft = true;
            this.sortRecordTypeWise(this.accRecTypeNames, this.searchRecord.accList, 'Firms');
        }
        if (this.conRecTypeNames.length >= 1) {
            this.isPrsntConRecTypeNames = true;
            this.isPrsntConRecTypeNamesLft = true;
            this.sortRecordTypeWise(this.conRecTypeNames, this.searchRecord.conList, 'Contacts');
        }
        if (this.dealRecordTypeNames.length >= 1) {
            this.isPresentDealRecordTypeNames = true;
            this.isPrsntDealRecTypeNamesLft = true;
            this.sortRecordTypeWise(this.dealRecordTypeNames, this.searchRecord.dealList, 'Deals');
        }
        if (this.fundRecordTypeNames.length >= 1) {
            this.isPresentFundRecordTypeNames = true;
            this.isPrsntFundRecTypeNamesLft = true;
            this.sortRecordTypeWise(this.fundRecordTypeNames, this.searchRecord.fundList, 'Funds');
        }
        if (this.fdrRecTypeNames.length >= 1) {
            this.isPresentFdrRecTypeNames = true;
            this.isPrsntFdrRecTypeNamesLft = true;
            this.sortRecordTypeWise(this.fdrRecTypeNames, this.searchRecord.fundRaisList, 'Fundraising');
        }
        this.allCatogaries('noSearchProcessFromAdvCmp');
    }
    // Main function for searching for search key and it is called from getWiredFunctions() method
    handleSearch(advanceParameter,fieldFilterData,checkValueRegardingCmp) {
        if(this.mechanishmValue != undefined && this.mechanishmValue == 'systemWide'){
            this.currentId =''; 
        }
        this.viewMoreAccount = false;
        this.viewMoreContact = false;
        this.viewMoreDeal = false;
        this.viewMoreFund = false;
        this.viewMoreFundRaising = false;
        this.viewMoreTask = false;
        this.viewMoreEvent = false;

        this.viewMoreFile = false;
        this.viewMoreTheme = false;
        this.viewMoreClip = false;
    this.noRecordTempDisplay=false;
    this.showWarningMessage = false;
    this.totalSearchRecord=0;
    this.accList=[];
    this.repsntAccList=[];
    this.conList=[];
    this.rprsntConList=[];
    this.fundList=[];
    this.representFundList=[];
    this.dealList=[];
    this.representDealList=[];
    this.fdrList=[];
    this.rprsntFdrList=[];

    this.accRecTypeObjList = [];
    this.conRecTypeObjList = [];
    this.dealRecTypeObjList = [];
    this.fundRecTypeObjList = [];
    this.fdrRecTypeObjList = [];
    this.taskRecTypeObjList = [];
       
    this.refreshCheck = true;
    this.accRecTypeNames = [];
    this.conRecTypeNames = [];
    this.dealRecordTypeNames = [];
    this.fundRecordTypeNames = [];
    this.fdrRecTypeNames = [];
    this.fullFdrMngDataAtServerCallTime=[];
    this.fullConMngDataAtServerCall=[];
    this.fullDealMngDataAtServerCall=[];
    this.fullFundMngDataAtServerCall=[];
    this.fullAccMngDataAtServerCall=[];
        const element1 = this.template.querySelector('[data-id="all_id"]');
        if (element1) {
            if (!element1.classList.contains("slds-is-active")) {
                element1.classList.add("slds-is-active");
            }
        }
        if(this.showAndHideLeftGridSection != ''){
        const elementArt = this.template.querySelector(this.showAndHideLeftGridSection);	
        if (elementArt) {
            if (elementArt.classList.contains("slds-is-active")) {
                elementArt.classList.remove("slds-is-active");
            }
        }
    }
        this.accountListShow = false;
        this.contactListShow = false;
        this.dealListShow = false;
        this.fundListShow = false;
        this.fdrListShow = false;
        this.taskListShow = false;
        this.fileListShow =false;
        this.themeListShow = false;
        this.clipListShow = false;
        this.showInnerAccRecTypeSec = false;
        this.sizeAccountList = 0;
        this.sizeContactList = 0;
        this.sizeDealList = 0;
        this.sizeFundList = 0;
        this.sizeFdrList = 0;
        this.sizeTaskList = 0;
        this.sizeEventList = 0;
        this.themeSize=0;
        this.clipSize=0;
        this.sizeFileList=0;
       if(this.searchValue == undefined){ // Critical Fix
          this.searchValue='';
       } 
       if(checkValueRegardingCmp == 'noSearchProcessFromAdvCmp'){
        if(this.searchRecord != undefined){
        if(this.searchRecord.dealList != undefined){this.searchRecord.dealList=[];}
        if(this.searchRecord.fundList != undefined){this.searchRecord.fundList=[];}
        if(this.searchRecord.taskList != undefined){this.searchRecord.taskList=[];}
        if(this.searchRecord.accList != undefined){this.searchRecord.accList=[];}
        if(this.searchRecord.conList != undefined){this.searchRecord.conList=[];}
        if(this.searchRecord.eventList != undefined){this.searchRecord.eventList=[];}
        if(this.searchRecord.fundRaisList != undefined){this.searchRecord.fundRaisList=[];}
       }
    this.innerDealListShow=false;this.innerContactListShow=false;this.innerAccountListShow=false;
    this.innerFundListShow=false;this.innerFdrListShow=false;this.innerClipListShow=false;
    this.innerThemeListShow=false;this.innerFileListShow=false;
    this.noRecordTempDisplay=true;
    this.norecordFound();
        return 1;
       }
        if ((this.searchValue !== '' && this.searchValue.length > 1) || (checkValueRegardingCmp == 'comingFromChild')) {
            getSearchResultListPro({
                quearyFieldsForClip:this.clipQryFld,
                quearyFieldsForTheme:this.thmQryFld,
                quearyFieldsForFundRaising:this.fdrQryFld,
                quearyFieldsForFund:this.fundQryFld,
                quearyFieldsForAccount: this.accQryFld,
                quearyFieldsForContact:this.conQryFld,
                quearyFieldsForDeals:this.dealQryFld,
                objectRecord:JSON.stringify(advanceParameter),
                fieldFilterData:JSON.stringify(fieldFilterData),
                    searchKey: this.searchValue,
                    checkComingSource: checkValueRegardingCmp
                })
                .then(result => {
                    this.searchRecord = [];
                    // set @track search data  variable with return global search  list from server  
                    this.searchRecord = result;
                    this.leftVerticalHeader = true;
                    if (this.searchRecord.errorMessage == '' || this.searchRecord.errorMessage == null || this.searchRecord.errorMessage == undefined) {
                        if (this.searchRecord.refWrapFileList.length < 1 && this.searchRecord.themeList.length < 1 && this.searchRecord.clipList.length < 1 && this.searchRecord.accList.length < 1 && this.searchRecord.conList.length < 1 && this.searchRecord.dealList.length < 1 && this.searchRecord.fundList.length < 1 && this.searchRecord.fundRaisList.length < 1 && this.searchRecord.taskList.length < 1 && this.searchRecord.eventList.length < 1){// && this.searchRecord.refWrapTaskEventList.length < 1) {
                            this.norecordFound();
                        } else {
                            this.totalSearchRecord = parseInt(this.searchRecord.refWrapFileList.length) + parseInt(this.searchRecord.themeList.length) + parseInt(this.searchRecord.clipList.length) + parseInt(this.searchRecord.accList.length) + parseInt(this.searchRecord.conList.length) + parseInt(this.searchRecord.dealList.length) + parseInt(this.searchRecord.fundList.length) + parseInt(this.searchRecord.fundRaisList.length) + parseInt(this.searchRecord.taskList.length) + parseInt(this.searchRecord.eventList.length);// + parseInt(this.searchRecord.refWrapTaskEventList.length);// + parseInt(this.searchRecord.refAccTaskEventList.length);
                            this.themeSize=parseInt(this.searchRecord.themeList.length);
                            this.clipSize=parseInt(this.searchRecord.clipList.length);
                            this.contactManage('server'); 
                            this.dealManage('server'); 
                            this.fundManage('server'); 
                            this.fundRiasingManage('server'); 
                            this.fileManage('server');
                            this.themeManage('server');
                            this.clipManage('server');
                            this.accountManage('server');
                            if(this.searchRecord.taskList != undefined ){
                            this.taskList=[];
                            this.taskList = this.searchRecord.taskList;
                            for (var i = 0; i < this.taskList.length; i++) {
                                if(this.taskList[i].IsAllDayEvent != undefined && this.taskList[i].IsAllDayEvent){
                                    if(this.taskList[i].StartDateTime != undefined && this.taskList[i].ActivityDate != undefined ){
                                        this.taskList[i].StartDateTime=this.taskList[i].ActivityDate ;
                                    }
                                }
                            }
                            this.searchRecord.taskList=this.taskList;
                            }
                            this.taskManage('server'); // for arrenging the Task search data
                            this.allCatogaries(checkValueRegardingCmp);
                        }
                    } else {
                        const event = new ShowToastEvent({title: 'Error',variant: 'error',message: this.searchRecord.errorMessage,mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                    }
                    this.loadFirstComp=true;
                })
                .catch(error => {
                    const event = new ShowToastEvent({title: 'Error',variant: 'error',message: error.body.message,mode: 'sticky'});
                    this.dispatchEvent(event);
                    this.searchRecord = null;
                });
        } else {
            this.showWarningMessage = true;
            this.noRecordTempDisplay=false;
            this.loadFirstComp=true;
        }
    }
    //Variables for sorting the data of the table
    defaultSortDirection = 'asc'; 
    sortDirection = 'asc';
    sortedBy;
    
    @track valueOfSection; // holding the web page data on the onclick function, variable is used in OpenRelatedPage() method
    OpenRelatedPage(event) {
        this.noRecordTempDisplay=false;
        this.valueOfSection = event.currentTarget.dataset.name;
        this.outerNoRecordOBject = event.currentTarget.dataset.name;
        this.accountListShow = false;
        this.contactListShow = false;
        this.dealListShow = false;
        this.fundListShow = false;
        this.fdrListShow = false;
        this.taskListShow = false; 
        this.fileListShow=false;
        this.themeListShow=false;this.clipListShow=false;
        this.viewMoreFile = false;this.viewMoreTheme = false;this.viewMoreClip = false;
        this.viewMoreDeal = false;this.viewMoreFund = false;this.viewMoreFundRaising = false;
        this.viewMoreTask = false;this.viewMoreEvent = false;
        if (this.valueOfSection == 'Firms') {
            this.showAndHideLeftGridSection='[data-id="firm_id"]';
            const element = this.template.querySelector('[data-id="firm_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.accountManage('client');
            this.accountListShow = true;
        }
        if (this.valueOfSection == 'Contacts') {
            this.showAndHideLeftGridSection='[data-id="contact_id"]';
            const element = this.template.querySelector('[data-id="contact_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.contactManage('client');
            this.contactListShow = true;
        }
        if (this.valueOfSection == 'Deals') {
            this.showAndHideLeftGridSection='[data-id="deal_id"]';
            const element = this.template.querySelector('[data-id="deal_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerDealListShow = false;
            this.dealManage('client');
            this.dealListShow = true;
            if (this.representDealList.length >= 1) {this.innerDealListShow = true;}
        }
        if (this.valueOfSection == 'Funds') {
            this.showAndHideLeftGridSection='[data-id="fund_id"]';
            const element = this.template.querySelector('[data-id="fund_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerFundListShow = false;
            this.fundManage('client');
            this.fundListShow = true;
            if (this.representFundList.length >= 1) {this.innerFundListShow = true;}
        }
        if (this.valueOfSection == 'FundRaising') {
            this.showAndHideLeftGridSection='[data-id="FundRaising_id"]';
            const element = this.template.querySelector('[data-id="FundRaising_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerFdrListShow = false;
            this.fundRiasingManage('client');
            this.fdrListShow = true;
            if (this.rprsntFdrList.length >= 1) {this.innerFdrListShow = true;}
        }
        if (this.valueOfSection == 'Tasks') {
            this.showAndHideLeftGridSection='[data-id="interaction_id"]';
            const element = this.template.querySelector('[data-id="interaction_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerTaskListShow = false;
            this.taskManage('client');
            this.taskListShow = true;
            if (this.representTaskList.length >= 1) {this.innerTaskListShow = true;}
        }
        if (this.valueOfSection == 'Files') {
            this.showAndHideLeftGridSection='[data-id="files_id"]';
            const element = this.template.querySelector('[data-id="files_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerFileListShow = false;
            this.fileManage('client');
            this.fileListShow = true;
            if (this.representFileList.length >= 1) {this.innerFileListShow = true;}
        }
        if (this.valueOfSection == 'Themes') {
            this.showAndHideLeftGridSection='[data-id="themes_id"]';
            const element = this.template.querySelector('[data-id="themes_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerThemeListShow = false;
            this.themeManage('client');
            this.themeListShow = true;
            if (this.representThemeList.length >= 1) {this.innerThemeListShow = true;}
        }
        if (this.valueOfSection == 'Clips') {
            this.showAndHideLeftGridSection='[data-id="clips_id"]';
            const element = this.template.querySelector('[data-id="clips_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerClipListShow = false;
            this.clipManage('client');
            this.clipListShow = true;
            if (this.representClipList.length >= 1) {this.innerClipListShow = true;}
        } 
        const scrollOptions = {top: 0}
      window.scrollTo(scrollOptions);
    }
    // Manage the record type functionality of Sobject on LWC according to Recordtype of particular Object
    sortRecordTypeWise(recordTypeNamesList, data, object) {
        if (recordTypeNamesList.length >= 1) {
            var copyArray = [...data];
            if(copyArray.length < 1){
              for (var i = 0; i < recordTypeNamesList.length; i++) {
                  var obj = {name: "",count: "",List: [],hasList: false,veiwMore: false,outerList: [],outerCount: ""};
                  var countValue = 0;
                  obj.name = recordTypeNamesList[i];
                  obj.count = 0;
                  if(object == 'Firms') {this.accRecTypeObjList.push(obj);}
                  if(object == 'Contacts') {this.conRecTypeObjList.push(obj);}
                  if(object == 'Deals') {this.dealRecTypeObjList.push(obj);}
                  if(object == 'Funds') {this.fundRecTypeObjList.push(obj);}
                  if(object == 'Fundraising') {this.fdrRecTypeObjList.push(obj);}
              }
            }else{
            for (var i = 0; i < recordTypeNamesList.length; i++) {
                var obj = {name: "",count: "",List: [],hasList: false,veiwMore: false,outerList: [],outerCount: ""};
                var countValue = 0;
                for (var j = 0; j < copyArray.length; j++) {
                    if (object == 'Firms') {
                        if (copyArray[j].RecordType != undefined && copyArray[j].RecordType != null) {
                            if (recordTypeNamesList[i] == copyArray[j].RecordType.Name) {
                                obj.hasList = true;
                                countValue++;
                                if (obj.List.length < 5) { obj.outerList.push(copyArray[j]); }
                                obj.List.push(copyArray[j]);
                            }
                            obj.name = recordTypeNamesList[i];
                            obj.count = countValue;
                        }
                        if (j == copyArray.length - 1) {
                            if (obj.List.length > 5) {
                                obj.veiwMore = true;
                                obj.outerCount = 5 + '+';
                            } else {
                                obj.veiwMore = false;
                                obj.outerCount = obj.List.length;
                            }
                            if(i == 0){
                                this.totalSearchRecord=this.totalSearchRecord - parseInt(this.searchRecord.accList.length);
                            }
                            this.totalSearchRecord=this.totalSearchRecord + parseInt(obj.List.length);
                            this.accRecTypeObjList.push(obj);
                        }
                    }
                    if (object == 'Contacts') {
                        if (JSON.stringify(copyArray[j].RecordType) != undefined) {
                            if (recordTypeNamesList[i] == copyArray[j].RecordType.Name) {
                                obj.hasList = true;
                                countValue++;
                                if (obj.List.length < 5) { obj.outerList.push(copyArray[j]); }
                                obj.List.push(copyArray[j]);
                            }
                        }
                        obj.name = recordTypeNamesList[i];
                        obj.count = countValue;
                        if (j == copyArray.length - 1) {
                            if (obj.List.length > 5) {
                                obj.veiwMore = true;
                                obj.outerCount = 5 + '+';
                            } else {
                                obj.veiwMore = false;
                                obj.outerCount = obj.List.length;
                            }
                            if(i == 0){
                            this.totalSearchRecord=this.totalSearchRecord - parseInt(this.searchRecord.conList.length);
                            }
                            this.totalSearchRecord=this.totalSearchRecord + parseInt(obj.List.length);
                            this.conRecTypeObjList.push(obj);
                        }
                    }
                    if (object == 'Deals') {
                        if (JSON.stringify(copyArray[j].RecordType) != undefined) {
                            if (recordTypeNamesList[i] == copyArray[j].RecordType.Name) {
                                obj.hasList = true;
                                countValue++;
                                if (obj.List.length < 5) {obj.outerList.push(copyArray[j]);}
                                obj.List.push(copyArray[j]);
                            }
                        }
                        obj.name = recordTypeNamesList[i];
                        obj.count = countValue;
                        if (j == copyArray.length - 1) {
                            if (obj.List.length > 5) {
                                obj.veiwMore = true;
                                obj.outerCount = 5 + '+';
                            } else {
                                obj.veiwMore = false;
                                obj.outerCount = obj.List.length;
                            }
                            if(i == 0){
                            this.totalSearchRecord=this.totalSearchRecord - parseInt(this.searchRecord.dealList.length);
                            }
                            this.totalSearchRecord=this.totalSearchRecord + parseInt(obj.List.length);
                            this.dealRecTypeObjList.push(obj);
                        }
                    }
                    if (object == 'Funds') {
                        if (JSON.stringify(copyArray[j].RecordType) != undefined) {
                            if (recordTypeNamesList[i] == copyArray[j].RecordType.Name) {
                                obj.hasList = true;
                                countValue++;
                                if (obj.List.length < 5) { obj.outerList.push(copyArray[j]); }
                                obj.List.push(copyArray[j]);
                            }
                        }
                        obj.name = recordTypeNamesList[i];
                        obj.count = countValue;
                        if (j == copyArray.length - 1) {
                            if (obj.List.length > 5) {
                                obj.veiwMore = true;
                                obj.outerCount = 5 + '+';
                            } else {
                                obj.veiwMore = false;
                                obj.outerCount = obj.List.length;
                            }
                            if(i == 0){
                            this.totalSearchRecord=this.totalSearchRecord - parseInt(this.searchRecord.fundList.length);
                            }
                            this.totalSearchRecord=this.totalSearchRecord + parseInt(obj.List.length);
                            this.fundRecTypeObjList.push(obj);
                        }
                    }
                    if (object == 'Fundraising') {
                        if (JSON.stringify(copyArray[j].RecordType) != undefined) {
                            if (recordTypeNamesList[i] == copyArray[j].RecordType.Name) {
                                obj.hasList = true;
                                countValue++;
                                if (obj.List.length < 5) { obj.outerList.push(copyArray[j]); }
                                obj.List.push(copyArray[j]);
                            }
                        }
                        obj.name = recordTypeNamesList[i];
                        obj.count = countValue;
                        if (j == copyArray.length - 1) {
                            if (obj.List.length > 5) {
                                obj.veiwMore = true;
                                obj.outerCount = 5 + '+';
                            } else {
                                obj.veiwMore = false;
                                obj.outerCount = obj.List.length;
                            }
                            if(i == 0){
                            this.totalSearchRecord=this.totalSearchRecord - parseInt(this.searchRecord.fundRaisList.length);
                            }
                            this.totalSearchRecord=this.totalSearchRecord + parseInt(obj.List.length);
                            this.fdrRecTypeObjList.push(obj);
                        }
                    }
                }
            }
          }
        }
    }
    //SObject Table change on Onclick  Respect to RecordType
    onClickFirmTableChange(event) {
      this.noRecordTempDisplay=false;
        this.accountListShow = false;
        this.contactListShow = false;
        this.dealListShow = false;
        this.fundListShow = false;
        this.fdrListShow = false;
        this.taskListShow = false;
        this.fileListShow=false;
        this.themeListShow=false;
        this.clipListShow=false;
        this.isPrsntAccRecTypeNames = false;
        this.isPrsntConRecTypeNames = false;
        this.isPresentDealRecordTypeNames = false;
        this.isPresentFundRecordTypeNames = false;
        this.isPresentFdrRecTypeNames = false;
        this.viewMoreFile = false;
        this.viewMoreTheme = false;
        this.viewMoreClip = false;
        this.viewMoreAccount = false;
        this.viewMoreContact = false;
        this.viewMoreDeal = false;
        this.viewMoreFund = false;
        this.viewMoreFundRaising = false;
        var data = event.currentTarget.dataset.name;
        this.outerNoRecordOBject = data;
        var objName = event.currentTarget.dataset.value;
        var copyRecordTypeObjectListData;
        if (objName == 'Firms') {
            let strMaking='[data-id="'+data+'"]';
            const element = this.template.querySelector(strMaking);		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerAccountListShow = false;
            this.repsntAccList = [];
            copyRecordTypeObjectListData = [...this.accRecTypeObjList];
            this.accountListShow = true;
            this.accountTableName = data;
            for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
                if (data == copyRecordTypeObjectListData[i].name) {
                    this.repsntAccList = [...copyRecordTypeObjectListData[i].List];
                    this.sizeAccountList = this.repsntAccList.length;
                    if (this.sizeAccountList >= 1) { this.innerAccountListShow = true; }
                    break;
                }
            }
        }
        if (objName == 'Contacts') {
            let strMaking='[data-id="'+data+'"]';		
	const element = this.template.querySelector(strMaking);		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerContactListShow = false;
            this.rprsntConList = [];
            copyRecordTypeObjectListData = [...this.conRecTypeObjList];
            this.contactListShow = true;
            this.contactTableName = data;
            for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
                if (data == copyRecordTypeObjectListData[i].name) {
                    this.rprsntConList = [...copyRecordTypeObjectListData[i].List];
                    this.sizeContactList = this.rprsntConList.length;
                    if (this.sizeContactList >= 1) { this.innerContactListShow = true; }
                    break;
                }
            }
        }
        if (objName == 'Deals') {
            let strMaking='[data-id="'+data+'"]';		
	const element = this.template.querySelector(strMaking);		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerDealListShow = false;
            this.representDealList = [];
            copyRecordTypeObjectListData = [...this.dealRecTypeObjList];
            this.dealListShow = true;
            this.dealTableName = data;
            for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
                if (data == copyRecordTypeObjectListData[i].name) {
                    this.representDealList = [...copyRecordTypeObjectListData[i].List];
                    this.sizeDealList = this.representDealList.length;
                    if (this.sizeDealList >= 1) { this.innerDealListShow = true; }
                    break;
                }
            }
        }
        if (objName == 'Funds') {
            let strMaking='[data-id="'+data+'"]';		
	const element = this.template.querySelector(strMaking);		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerFundListShow = false;
            this.representFundList = [];
            copyRecordTypeObjectListData = [...this.fundRecTypeObjList];
            this.fundListShow = true;
            this.fundTableName = data;
            for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
                if (data == copyRecordTypeObjectListData[i].name) {
                    this.representFundList = [...copyRecordTypeObjectListData[i].List];
                    this.sizeFundList = this.representFundList.length;
                    if (this.sizeFundList >= 1) { this.innerFundListShow = true; }
                    break;
                }
            }
        }
        if (objName == 'FundRaising') {
            let strMaking='[data-id="'+data+'"]';		
	const element = this.template.querySelector(strMaking);		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerFdrListShow = false;
            this.rprsntFdrList = [];
            copyRecordTypeObjectListData = [...this.fdrRecTypeObjList];
            this.fdrListShow = true;
            this.fdrTableName = data;
            for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
                if (data == copyRecordTypeObjectListData[i].name) {
                    this.rprsntFdrList = [...copyRecordTypeObjectListData[i].List];
                    this.sizeFdrList = this.rprsntFdrList.length;
                    if (this.sizeFdrList >= 1) { this.innerFdrListShow = true; }
                    break;
                }
            }
        }
        if (objName == 'Tasks') {
            const element = this.template.querySelector('[data-id="interaction_id"]');		
	const element1 = this.template.querySelector('[data-id="all_id"]');		
	element1.classList.remove("slds-is-active");		
	element.classList.add("slds-is-active");
            this.innerTaskListShow = false;
            this.representTaskList = [];
            copyRecordTypeObjectListData = [...this.taskRecTypeObjList];
            this.taskListShow = true;
            for (var i = 0; i < copyRecordTypeObjectListData.length; i++) {
                if (data == copyRecordTypeObjectListData[i].name) {
                    this.representTaskList = [...copyRecordTypeObjectListData[i].List];
                    this.sizeFundList = this.representTaskList.length;
                    if (this.representTaskList.length >= 1) { this.innerTaskListShow = true; }
                    break;
                }
            }
        }
        const scrollOptions = {top: 0}
      window.scrollTo(scrollOptions);
    }
    // Managing the data of Account(Firm) basis of Searching and Recordtype 
    accountManage(activity) {
        this.innerAccountListShow = false;
        this.accList = [];
        this.accRecTypeNames = [];
        this.repsntAccList = [];
        this.accList = this.searchRecord.accList;
        this.accRecTypeNames = this.searchRecord.accountRecordTypeList;
        var tempDataList = [];
        var forRecordtypeData = [];
        
        if (this.accList.length >= 1) {
            if (activity == 'server') {
                let size = parseInt((this.accList.length > 5) ? 5 : this.accList.length);
                if (this.accList.length > 5) {
                    this.viewMoreAccount = true;
                    this.sizeFrontAccountList = 5 + '+';
                } else {
                    this.sizeFrontAccountList = this.accList.length;
                }
                for (var i = 0; i < size; i++) {
                    let tempRecord = Object.assign({}, this.accList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.accFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempRecord.RecordTypeId = tempRecord.RecordType.Name;
                    tempDataList.push(tempRecord);
                }
                this.fiveAccList = tempDataList;
                for (var i = 0; i < this.accList.length; i++) {
                    let tempRecord = Object.assign({}, this.accList[i]); //cloning object  
                    if(tempRecord.RecordTypeId != undefined ){
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.accFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempRecord.RecordTypeId = tempRecord.RecordType.Name;
                    }
                    forRecordtypeData.push(tempRecord);
                }
                this.fullAccMngDataAtServerCall = forRecordtypeData;
                if (this.accRecTypeNames.length >= 1) {
                    this.isPrsntAccRecTypeNames = true;
                    this.isPrsntAccRecTypeNamesLft = true;
                    this.sortRecordTypeWise(this.accRecTypeNames, this.fullAccMngDataAtServerCall, 'Firms');
                }
            } else {
                this.viewMoreAccount = false;
                for (var i = 0; i < this.accList.length; i++) {
                    let tempRecord = Object.assign({}, this.accList[i]); //cloning object 
                    if(tempRecord.RecordTypeId != undefined ){ 
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.accFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempRecord.RecordTypeId = tempRecord.RecordType.Name;
                    }
                    tempDataList.push(tempRecord);
                }
            }
            this.sizeAccountList = parseInt(this.accList.length);
            this.repsntAccList = tempDataList;
            this.accountListShow = true;
            this.innerAccountListShow = true;
        }else{
          if (this.accRecTypeNames.length >= 1) {
              this.isPrsntAccRecTypeNames = true;
              this.isPrsntAccRecTypeNamesLft = true;
              this.sortRecordTypeWise(this.accRecTypeNames, this.accList, 'Firms');
            }
        }
    }
    contactManage(activity) {
        this.innerContactListShow = false;
        this.conList = []; 
        this.rprsntConList = [];
        this.conList = this.searchRecord.conList;
        this.conRecTypeNames = this.searchRecord.contactRecordTypeList;
        if (this.conList.length >= 1) {
            var tempDataList = [];
            var forRecordtypeData = [];
            if (activity == 'server') {
                let size = parseInt((this.conList.length > 5) ? 5 : this.conList.length);
                if (this.conList.length > 5) {
                    this.viewMoreContact = true;
                    this.sizeFrontContactList = 5 + '+';
                } else {
                    this.sizeFrontContactList = this.conList.length;
                }
                for (var i = 0; i < size; i++) {
                   
                    let tempRecord = Object.assign({}, this.conList[i]); //cloning object 
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.conFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
                this.fiveConList = tempDataList;
                for (var i = 0; i < this.conList.length; i++) {
                    let tempRecord = Object.assign({}, this.conList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.conFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    forRecordtypeData.push(tempRecord);
                }
                this.fullConMngDataAtServerCall = forRecordtypeData;
                if (this.conRecTypeNames.length >= 1) {
                    this.isPrsntConRecTypeNames = true;
                    this.isPrsntConRecTypeNamesLft = true;
                    this.sortRecordTypeWise(this.conRecTypeNames, this.fullConMngDataAtServerCall, 'Contacts');
                }
            } else {
                this.viewMoreContact = false;
                for (var i = 0; i < this.conList.length; i++) {
                    let tempRecord = Object.assign({}, this.conList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.conFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
            }
            this.rprsntConList = tempDataList;
            this.sizeContactList = this.conList.length;
            this.contactListShow = true;
            this.innerContactListShow = true;
        }else{
          if (this.conRecTypeNames.length >= 1) {
              this.isPrsntConRecTypeNames = true;
              this.isPrsntConRecTypeNamesLft = true;
              this.sortRecordTypeWise(this.conRecTypeNames, this.conList, 'Contacts');
          }
        }
    }
    // Managing the data of Deal basis of Searching and Recordtype 
    dealManage(activity) {
        this.innerDealListShow = false;
        this.dealList = []; 
        this.representDealList = [];
        this.dealList = this.searchRecord.dealList;
        this.dealRecordTypeNames = this.searchRecord.dealRecordTypeList;
        if (this.dealList.length >= 1) {
            var tempDataList = [];
            var forRecordtypeData = [];
            if (activity == 'server') {
                let size = parseInt((this.dealList.length > 5) ? 5 : this.dealList.length);
                if (this.dealList.length > 5) {
                    this.viewMoreDeal = true;
                    this.sizeFrontDealList = 5 + '+';
                } else {
                    this.sizeFrontDealList = this.dealList.length;
                }
                for (var i = 0; i < size; i++) {
                    let tempRecord = Object.assign({}, this.dealList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.dealFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
                this.fiveDealList = tempDataList;
                for (var i = 0; i < this.dealList.length; i++) {
                    let tempRecord = Object.assign({}, this.dealList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.dealFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    forRecordtypeData.push(tempRecord);
                }
                this.fullDealMngDataAtServerCall = forRecordtypeData;
                if (this.dealRecordTypeNames.length >= 1) {
                    this.isPresentDealRecordTypeNames = true;
                    this.isPrsntDealRecTypeNamesLft = true;
                    this.sortRecordTypeWise(this.dealRecordTypeNames, this.fullDealMngDataAtServerCall, 'Deals');
                }
            } else {
                this.viewMoreDeal = false;
                for (var i = 0; i < this.dealList.length; i++) {
                    let tempRecord = Object.assign({}, this.dealList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.dealFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
            }
            this.representDealList = tempDataList;
            this.sizeDealList = this.dealList.length;
            this.dealListShow = true;
            this.innerDealListShow = true;
        }else{
          if (this.dealRecordTypeNames.length >= 1) {
              this.isPresentDealRecordTypeNames = true;
              this.isPrsntDealRecTypeNamesLft = true;
              this.sortRecordTypeWise(this.dealRecordTypeNames, this.dealList, 'Deals');
          }
        }
    }
    // Managing the data of Fund basis of Searching and Recordtype 
    fundManage(activity) {
        this.innerFundListShow = false;
        this.fundList = []; 
        this.representFundList = [];
        this.fundList = this.searchRecord.fundList;
        this.fundRecordTypeNames = this.searchRecord.fundRecordTypeList;
        if (this.fundList.length >= 1) {
            var tempDataList = [];
            var forRecordtypeData = [];
            if (activity == 'server') {
                let size = parseInt((this.fundList.length > 5) ? 5 : this.fundList.length);
                if (this.fundList.length > 5) {
                    this.viewMoreFund = true;
                    this.sizeFrontFundList = 5 + '+';
                } else {
                    this.sizeFrontFundList = this.fundList.length;
                }
                for (var i = 0; i < size; i++) {
                    let tempRecord = Object.assign({}, this.fundList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.fundFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
                this.fiveFundList = tempDataList;
                for (var i = 0; i < this.fundList.length; i++) {
                    let tempRecord = Object.assign({}, this.fundList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.fundFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    forRecordtypeData.push(tempRecord);
                }
                this.fullFundMngDataAtServerCall = forRecordtypeData;
                if (this.fundRecordTypeNames.length >= 1) {
                    this.isPresentFundRecordTypeNames = true;
                    this.isPrsntFundRecTypeNamesLft = true;
                    this.sortRecordTypeWise(this.fundRecordTypeNames, this.fullFundMngDataAtServerCall, 'Funds');
                }
            } else {
                this.viewMoreFund = false;
                for (var i = 0; i < this.fundList.length; i++) {
                    let tempRecord = Object.assign({}, this.fundList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.fundFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
            }
            this.representFundList = tempDataList;
            this.sizeFundList = this.fundList.length;
            this.fundListShow = true;
            this.innerFundListShow = true;
        }else{
          if (this.fundRecordTypeNames.length >= 1) {
              this.isPresentFundRecordTypeNames = true;
              this.isPrsntFundRecTypeNamesLft = true;
              this.sortRecordTypeWise(this.fundRecordTypeNames, this.fundList, 'Funds');
          }
        }
    }
    // Managing the data of FundRaising basis of Searching and Recordtype 
    fundRiasingManage(activity) {
        this.innerFdrListShow = false;
        this.fdrList = []; 
        this.rprsntFdrList = [];
        this.fdrList = this.searchRecord.fundRaisList;
        this.fdrRecTypeNames = this.searchRecord.fundraisingRecordTypeList;
        if (this.fdrList.length >= 1) {
            var tempDataList = [];
            var forRecordtypeData = [];
            if (activity == 'server') {
                let size = parseInt((this.fdrList.length > 5) ? 5 : this.fdrList.length);
                if (this.fdrList.length > 5) {
                    this.viewMoreFundRaising = true;
                    this.sizeFrontFdrList = 5 + '+';
                } else {
                    this.sizeFrontFdrList = this.fdrList.length;
                }
                for (var i = 0; i < size; i++) {
                    let tempRecord = Object.assign({}, this.fdrList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.fdrFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
                this.fiveFdrList = tempDataList;
                for (var i = 0; i < this.fdrList.length; i++) {
                    let tempRecord = Object.assign({}, this.fdrList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.fdrFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    forRecordtypeData.push(tempRecord);
                }
                this.fullFdrMngDataAtServerCallTime = forRecordtypeData;
                if (this.fdrRecTypeNames.length >= 1) {
                    this.isPresentFdrRecTypeNames = true;
                    this.isPrsntFdrRecTypeNamesLft = true;
                    this.sortRecordTypeWise(this.fdrRecTypeNames, this.fullFdrMngDataAtServerCallTime, 'Fundraising');
                }
            } else {
                this.viewMoreFundRaising = false;
                for (var i = 0; i < this.fdrList.length; i++) {
                    let tempRecord = Object.assign({}, this.fdrList[i]); //cloning object  
                    tempRecord=this.lookupFieldHandeling(tempRecord,this.fdrFieldTypeMap);
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
            }
            this.rprsntFdrList = tempDataList;
            this.sizeFdrList = this.fdrList.length;
            this.fdrListShow = true;
            this.innerFdrListShow = true;
        }else{
          if (this.fdrRecTypeNames.length >= 1) {
              this.isPresentFdrRecTypeNames = true;
              this.isPrsntFdrRecTypeNamesLft = true;
              this.sortRecordTypeWise(this.fdrRecTypeNames, this.fdrList, 'Fundraising');
          }
        }
    }
    // Managing the data of Task basis of Searching and Recordtype 
    taskManage(activity) {
        this.innerTaskListShow = false;
        this.taskList = []; 
        this.representTaskList = [];
        this.taskList = this.searchRecord.taskList;
        if (this.taskList.length >= 1) {
            var tempDataList = [];
            if (activity == 'server') {
                let size = parseInt((this.taskList.length > 5) ? 5 : this.taskList.length);
                if (this.taskList.length > 5) {
                    this.viewMoreTask = true;
                    this.sizeFrontTaskList = 5 + '+';
                } else {
                    this.sizeFrontTaskList = this.taskList.length;
                }
                for (var i = 0; i < size; i++) {
                    let tempRecord = Object.assign({}, this.taskList[i]); //cloning object  
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
            } else {
                this.viewMoreTask = false;
                for (var i = 0; i < this.taskList.length; i++) {
                    let tempRecord = Object.assign({}, this.taskList[i]); //cloning object  
                    tempRecord.NameFieldData = "/" + tempRecord.Id;
                    tempDataList.push(tempRecord);
                }
            }
            this.representTaskList = tempDataList;
            var interactionData = [];
            for (var i = 0; i < tempDataList.length; i++) {
                var obj = {Date: "",Subject: "",NameFieldData: "",Description: ""};
                obj.Date = (tempDataList[i].IsAllDayEvent == undefined) ? tempDataList[i].ActivityDate : tempDataList[i].StartDateTime;
                obj.Description = tempDataList[i].Description;
                obj.Subject = tempDataList[i].Subject;
                obj.NameFieldData = tempDataList[i].NameFieldData;
                interactionData.push(obj);
            }
            this.representTaskList = interactionData;
            if (activity == 'server') { this.fiveInteractionList = interactionData; }
            this.sizeTaskList = this.taskList.length;
            this.taskListShow = true;
            this.innerTaskListShow = true;
        }
    }
  //-----------------manage file ----------------------------------
  fileManage(activity) {
    this.innerFileListShow = false;
    this.fileList = [];
    this.representFileList = [];
    this.fileList = this.searchRecord.refWrapFileList;
    if (this.fileList.length >= 1) {
        var tempDataList = [];
        this.fileListShow=true;
        if (activity == 'server') {
            let size = parseInt((this.fileList.length > 5) ? 5 : this.fileList.length);
            if (this.fileList.length > 5) {
                this.viewMoreFile = true;
                this.sizeFrontFileList = 5 + '+';
            } else {
                this.sizeFrontFileList = this.fileList.length;
            }
            for (var i = 0; i < size; i++) {
                let tempRecord = Object.assign({}, this.fileList[i]); //cloning object  
                tempDataList.push(tempRecord);
            }
            this.representFileList = tempDataList;
            this.fiveFileList = tempDataList;
        } else {
            this.viewMoreFile = false;
            this.representFileList = this.fileList;
        }
        this.sizeFileList = this.fileList.length;
        this.fileListShow = true;
        this.innerFileListShow = true;
    }
}
//---------theme manage -----------
themeManage(activity) {
    this.innerThemeListShow = false;
    this.themeList = []; 
    this.representThemeList = [];
    this.themeList = this.searchRecord.themeList;
    if (this.themeList.length >= 1) {
        var tempDataList = [];
        if (activity == 'server') {
            let size = parseInt((this.themeList.length > 5) ? 5 : this.themeList.length);
            if (this.themeList.length > 5) {
                this.viewMoreTheme = true;
                this.sizeFrontTheme = 5 + '+';
            } else {
                this.sizeFrontThemeList = this.themeList.length;
            }
            for (var i = 0; i < size; i++) {
                let tempRecord = Object.assign({}, this.themeList[i]); //cloning object  
                tempRecord=this.lookupFieldHandeling(tempRecord,this.themeFieldTypeMap);
                tempRecord.NameFieldData = "/" + tempRecord.Id;
                tempDataList.push(tempRecord);
            }
            this.fiveThemeList = tempDataList;
        } else {
            this.viewMoreTheme = false;
            for (var i = 0; i < this.themeList.length; i++) {
                let tempRecord = Object.assign({}, this.themeList[i]); //cloning object  
                tempRecord=this.lookupFieldHandeling(tempRecord,this.themeFieldTypeMap);
                tempRecord.NameFieldData = "/" + tempRecord.Id;
                tempDataList.push(tempRecord);
            }
        }
        this.representThemeList = tempDataList;
        this.sizeThemeList = this.themeList.length;
        this.themeListShow = true;
        this.innerThemeListShow = true;
    }else{}
}
//-------Clip Mechanishm Start ----------
clipManage(activity) {
    this.innerClipListShow = false;
    this.clipList = []; 
    this.representClipList = [];
    this.clipList = this.searchRecord.clipList;
    if (this.clipList.length >= 1) {
        var tempDataList = [];
        if (activity == 'server') {
            let size = parseInt((this.clipList.length > 5) ? 5 : this.clipList.length);
            if (this.clipList.length > 5) {
                this.viewMoreClip = true;
                this.sizeFrontClip = 5 + '+';
            } else {
                this.sizeFrontClipList = this.clipList.length;
            }
            for (var i = 0; i < size; i++) {
                let tempRecord = Object.assign({}, this.clipList[i]); //cloning object  
                tempRecord=this.lookupFieldHandeling(tempRecord,this.clipFieldTypeMap);
                tempRecord.NameFieldData = "/" + tempRecord.Id;
                tempDataList.push(tempRecord);
            }
            this.fiveClipList = tempDataList;
        } else {
            this.viewMoreClip = false;
            for (var i = 0; i < this.clipList.length; i++) {
                let tempRecord = Object.assign({}, this.clipList[i]); //cloning object  
                tempRecord=this.lookupFieldHandeling(tempRecord,this.clipFieldTypeMap);
                tempRecord.NameFieldData = "/" + tempRecord.Id;
                tempDataList.push(tempRecord);
            }
        }
        this.representClipList = tempDataList;
        this.sizeClipList = this.clipList.length;
        this.clipListShow = true;
        this.innerClipListShow = true;
    }else{}
}
//------------------------------------------------------
    onClickAll() {
        if (this.searchRecord.accList.length < 1 && this.searchRecord.conList.length < 1 && this.searchRecord.dealList.length < 1 && this.searchRecord.fundList.length < 1 && this.searchRecord.fundRaisList.length < 1 && this.searchRecord.taskList.length < 1 && this.searchRecord.eventList.length < 1){
            this.noRecordTempDisplay = true;
        }
        var countTest=0;
        if (this.isPrsntAccRecTypeNamesLft) {
            if (this.accRecTypeObjList.length >= 1) {
                this.isPrsntAccRecTypeNames = true;
                this.accountListShow = true;
                this.innerAccountListShow = true;
                countTest++;
            }
        } else {
            this.accountListShow = false;
            if (this.repsntAccList.length >= 1) {
              countTest++;
                this.isPrsntAccRecTypeNames = false;
                this.accountListShow = true;
                this.innerAccountListShow = true;
                if (this.accList.length > 5) {this.viewMoreAccount = true;}
                this.repsntAccList = this.fiveAccList;
            }
        }
        if (this.isPrsntConRecTypeNamesLft) {
            if (this.conRecTypeObjList.length >= 1) {
              countTest++;
                this.isPrsntConRecTypeNames = true;
                this.contactListShow = true;
                this.innerContactListShow = true;
            }
        } else {
            this.contactListShow = false;
            if (this.rprsntConList.length >= 1) {
              countTest++;
                this.isPrsntConRecTypeNames = false;
                this.contactListShow = true;
                this.innerContactListShow = true;
                if (this.conList.length > 5) {this.viewMoreContact = true;}
                this.rprsntConList = this.fiveConList;
            }
        }
        if (this.isPrsntDealRecTypeNamesLft) {
            if (this.dealRecTypeObjList.length >= 1) {
              countTest++;
                this.isPresentDealRecordTypeNames = true;
                this.dealListShow = true;
                this.innerDealListShow = true;
            }
        } else {
          this.dealListShow = false;
            if (this.representDealList.length >= 1) {
              countTest++;
                this.isPresentDealRecordTypeNames = false;
                this.dealListShow = true;
                this.innerDealListShow = true;
                if (this.dealList.length > 5) {this.viewMoreDeal = true;}
                this.representDealList = this.fiveDealList;
            }
        }
        if (this.isPrsntFundRecTypeNamesLft) {
            if (this.fundRecTypeObjList.length >= 1) {
              countTest++;
                this.isPresentFundRecordTypeNames = true;
                this.fundListShow = true;
                this.innerFundListShow = true;
            }
        } else {
            this.fundListShow = false;
            if (this.representFundList.length >= 1) {
              countTest++;
                this.isPresentFundRecordTypeNames = false;
                this.fundListShow = true;
                this.innerFundListShow = true;
                if (this.fundList.length > 5) {this.viewMoreFund = true;}
                this.representFundList = this.fiveFundList;
            }
        }
        if (this.isPrsntFdrRecTypeNamesLft) {
            if (this.fdrRecTypeObjList.length >= 1) {
              countTest++;
                this.isPresentFdrRecTypeNames = true;
                this.fdrListShow = true;
                this.innerFdrListShow = true;
            }
        } else {
            this.fdrListShow = false;
            if (this.rprsntFdrList.length >= 1) {
              countTest++;
                this.isPresentFdrRecTypeNames = false;
                this.fdrListShow = true;
                this.innerFdrListShow = true;
                if (this.fdrList.length > 5) {this.viewMoreFundRaising = true;}
                this.rprsntFdrList = this.fiveFdrList;
            }
        }
        this.taskListShow = false;
        if (this.representTaskList.length >= 1) {
          countTest++;
            this.taskListShow = true;
            this.innerTaskListShow = true;
            if (this.taskList.length > 5) {this.viewMoreTask = true;}
            this.representTaskList = this.fiveInteractionList;
        }
        //-------file------------------
        this.fileListShow = false;
        if (this.fileList.length >= 1) {
          countTest++;
            this.fileListShow = true;
            this.innerFileListShow = true;
            if (this.fileList.length > 5) {this.viewMoreFile = true;}
            this.representFileList = this.fiveFileList;
        }
        //-------------------------------
        this.themeListShow = false;
        if (this.themeList.length >= 1) {
          countTest++;
            this.themeListShow = true;
            this.innerThemeListShow = true;
            if (this.themeList.length > 5) {this.viewMoreTheme = true;}
            this.representThemeList = this.fiveThemeList;
        }
        this.clipListShow = false;
        if (this.clipList.length >= 1) {
          countTest++;
            this.clipListShow = true;
            this.innerClipListShow = true;
            if (this.clipList.length > 5) {
                this.viewMoreClip = true;
            }
            this.representClipList = this.fiveClipList;
        }
        //-----------------------------------
        if(countTest == 0){
            this.noRecordTempDisplay=(this.searchValue !== '' && this.searchValue.length > 1);
        
          this.taskListShow = false;
          this.fdrListShow = false;
          this.fundListShow = false;
          this.dealListShow = false;
          this.contactListShow = false;
          this.accountListShow = false;
          this.fileListShow = false;
          this.themeListShow = false;
          this.clipListShow = false;
        }
    }
    onIntractionTableClick(event){
    if(event.detail.action.name == 'Subject'){
        let activityId=event.detail.row.NameFieldData;
        activityId=activityId.replace('/','');
        var objData={};
        objData.recId=activityId;
        objData.recType=(activityId.toString().includes('00T')) ? 'Task' : 'Event';
        objData.mode='view';
        let sfdcBaseURLvalue = window.location.origin;
        // this[NavigationMixin.GenerateUrl]({type: 'standard__webPage',attributes: {url: sfdcBaseURLvalue+'/lightning/n/nav3Dev06__View_Activity?c__params='+JSON.stringify(objData)}
        // }).then(generatedUrl => {window.open(generatedUrl);});
        let url = '/lightning/n/navpeII_dev18__View_Interaction?c__params=' + JSON.stringify(objData);// Bug Id - 44949 Phase 3
        window.open(url, '_blank');
        }
    }
    onClipRowClick(event){
    if(event.detail.action.label.fieldName == 'Name') 
        {
           let url = '/lightning/n/navpeII_dev18__Clips?c__clipParams=' + event.detail.row.Id;
            window.open(url, '_blank');
        }
    }
    goTORecordPage(event) {
        var rowId = event.currentTarget.dataset.recordid; 
        var objectName = event.currentTarget.dataset.name;
        this[NavigationMixin.GenerateUrl]({type: 'standard__recordPage',attributes: {recordId: rowId,objectApiName: objectName,actionName: 'view'}
        }).then((url) => {window.open(url, "_blank");});
    }

    // phase 2 mechanishm start  
    onFileRowClick(event){
     if(event.detail.action.name == 'recordName'){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {pageName: 'filePreview',recordId: event.detail.row.recordId,objectApiName: 'ContentVersion',actionName: 'view',},
            state : {selectedRecordId: event.detail.row.recordId}
        });
     }else if(event.detail.action.name == 'parentRecordName'){
        let sfdcBaseURLvalue = window.location.origin;
        let activityId=event.detail.row.parentRecordId;
        activityId=activityId.replace('/','');
        let checkFlag=true;
        var objData={};
        if(activityId.toString().includes('00T')){
            objData.recType='Task';
        }else if(activityId.toString().includes('00U')){
            objData.recType='Event';
        }else{
            checkFlag=false;
            this[NavigationMixin.GenerateUrl]({type: 'standard__recordPage',attributes: {recordId: activityId,objectApiName: '',actionName: 'view'}
            }).then((url) => {window.open(url, "_blank");});
        }
        if(checkFlag){
        objData.recId=activityId;
        objData.mode='view';
        this[NavigationMixin.GenerateUrl]({type: 'standard__webPage',attributes: {url: sfdcBaseURLvalue+'/lightning/n/navpeII_dev18__View_Interaction?c__params='+JSON.stringify(objData)}
        }).then(generatedUrl => {window.open(generatedUrl);});
    }
    }
    }

    renderedCallback() {
        if(this.refreshCheck){
            const element1 = this.template.querySelector('[data-id="all_id"]');
            if (element1) {
                if (!element1.classList.contains("slds-is-active")) {
                    element1.classList.add("slds-is-active");
                }           
            }
            this.refreshCheck = false;
        }
      
        if(this.checkModal){     
            let sectmodal = this.template.querySelector(".slds-modal");
            let bodyClose = sectmodal.closest('body');
            bodyClose.style.overflow = "hidden";
            this.checkModal = false;
        }
        //UI-change-for-window-scroller-get-hide-when-modal-popup-open--end //
        
        this.isRendered = true;
        let cardStyle = document.createElement('style');
        let cardHeaderRemove = document.createElement('style');
        let cardBody = document.createElement('style');
        let dataTableRow = document.createElement('style');
        let navigation = document.createElement('style');
        cardStyle.innerText = '.clsCard .slds-card{border-top-left-radius: 0px; border-top-right-radius: 0px; border-top-width: 2px}';
        cardHeaderRemove.innerText = '.slds-card__header{display: none}';
        cardBody.innerText = '.slds-card__body{margin-top: 0; margin-bottom: 0}';
        dataTableRow.innerText = '.slds-table_bordered tbody tr {background: rgb(255, 255, 255)}';
        navigation.innerText = '.removeHyperlink .slds-nav-vertical__action{text-decoration: none;}';
        let navBadge = this.template.querySelector('lightning-vertical-navigation-item-badge');
        if (navBadge) { navBadge.appendChild(navigation); }
        this.isDataTable = false;
        let DealDataTableBox = document.createElement('style');
        DealDataTableBox.innerText = '.heightDataTable .slds-table td:last-child{color: #585858; height:41px;}';
        let dataTable = this.template.querySelector('lightning-datatable');
        if (dataTable) { dataTable.appendChild(DealDataTableBox); }
          const style = document.createElement('style');
          style.innerText = `.tabhead span.slds-truncate {
            display: block !important;
        }
        
        /*00045746 fixed by raju on dated 11-06-2024*/
        .removeLeftBlueBorder .slds-nav-vertical__item.slds-is-active .slds-nav-vertical__action, .removeLeftBlueBorder .slds-nav-vertical__action:hover{
            box-shadow: none !important;
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
        .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th,
        .heightDataTable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            box-shadow: none !important;
        }
        .slds-th__action:focus,
        .slds-th__action:hover,
        .slds-table tr:hover {
            box-shadow: none !important;
        }
        .heightDataTable .slds-th__action {
            background: #f3f3f3 !important;
            box-shadow: none !important;
        }
        .slds-table:not(.slds-no-row-hover) tbody tr:hover>th {
            background: none !important;
        }
        .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            background: none !important;
        }
        td.slds-truncate button {
            white-space: nowrap;
            text-overflow: ellipsis;
            max-width: 180px;
            display: block;
            overflow: hidden;
        }
        .text-black button.slds-button{
            color: inherit !important;white-space: nowrap;
            text-overflow: ellipsis;max-width: 100%;
            display: block;overflow: hidden;border: none;
            cursor: default;
        }
        .text-blue button.slds-button{
            white-space: nowrap;
            text-overflow: ellipsis;max-width: 100%;
            display: block;overflow: hidden;border: none;
        }
        .slds-popover.slds-popover_tooltip.slds-nubbin_bottom-left{ background-color: #16325c !important;}
        .trucate-des .slds-truncate {
            display: block;
            max-width: 62%;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .slds-button:active,
        .slds-button:focus {
            border: none !important;
            box-shadow: none !important;
        }
        .slds-table_header-fixed_container.slds-scrollable_x {
            overflow-x: hidden;
        }
        .slds-table_header-fixed tbody tr th {
            height: 41px;
        }
        .slds-table_header-fixed_container,
        .dt-outer-container {margin-bottom: 0px;}
        @media only screen and (min-width: 100em) {
            .trucate-des .slds-truncate {
                max-width: 75%;
            }
        }
        @media only screen and (min-device-width: 1300px) and (max-device-width: 1550px) {
            .slds-table_header-fixed_container.slds-scrollable_x {
                overflow-x: hidden;
            }
        }
        @media only screen and (min-width: 80em) and (max-width: 90em) {
            .slds-table_header-fixed_container.slds-scrollable_x {
                overflow-x: hidden;
            }
            .trucate-des .slds-truncate {
                max-width: 48%;
            }
            .nav-brk-word a.slds-nav-vertical__action{
                padding-top: 0.5em !important;
                padding-bottom: 0.5em !important;
                padding-left: 1.4em !important;
            }
            h2.slds-nav-vertical__title{
                padding-left: 12px;
            }
            a.slds-nav-vertical__action{
                white-space: nowrap;
                text-overflow: ellipsis;
                max-width: 100%;
                display: block;
                overflow: hidden;
                position: relative;
                padding-right: 64px !important;
            }
            span.slds-badge.slds-col_bump-left{
                position: absolute;
                right: 5px;
                top: 5px;
            }
        }
        @media (max-width: 79em) {
            .slds-table_header-fixed_container.slds-scrollable_x {
                overflow-x: hidden;
            }
            .trucate-des .slds-truncate {
                max-width: 40%;
            }
            h2.slds-nav-vertical__title{
                padding-left: 12px;
            }
            a.slds-nav-vertical__action{
                white-space: nowrap;
                text-overflow: ellipsis;
                max-width: 100%;
                display: block;
                overflow: hidden;
                position: relative;
                padding-right: 56px;
                padding-left: 16px;
            }
            span.slds-badge.slds-col_bump-left{
                position: absolute;
                right: 5px;
                top: 5px;
            }
        }
        @media only screen and (min-width: 61em) and (max-width: 75em) {
            .trucate-des .slds-truncate {
                max-width: 35%;
            }
        }
        @media only screen and (min-width: 40.063em) and (max-width: 60em) {
            .slds-table_header-fixed_container.slds-scrollable_x {
                overflow-x: auto;
            }
            .trucate-des .slds-truncate {
                max-width: 25%;
            }
        }`;
  
        try {
            this.template.querySelector('.main-Container-search').appendChild(style);
        } catch (err) {
            console.log(err)
        }
    }

    lookupFieldHandeling(tempRecordValue,objFieldTypeMap){
        let objKey=[];
        var count = 0;
        objKey=Object.keys(tempRecordValue).sort();
        for (let x of objKey) {
            if(objFieldTypeMap[x] != undefined && objFieldTypeMap[x] == 'REFERENCE'){
            if(x == "AccountId"){
                if(tempRecordValue[x] != undefined){
                    tempRecordValue[x]='/'+ tempRecordValue[x];
                    let refStr=x + 'refName';
                    tempRecordValue[refStr]=tempRecordValue[objKey[count-1]]["Name"];
                }
            }else{
                if(tempRecordValue[x] != undefined){
                    tempRecordValue[x]='/'+ tempRecordValue[x];
                    let refStr=x + 'refName';
                    tempRecordValue[refStr]=tempRecordValue[objKey[count+1]]["Name"];
                }
            }
            }
            count++;
          }
return tempRecordValue;
    }

allCatogaries(checkValueRegardingCmp){
    this.selectionTabelDataFull=[];
    this.wholeMapDataFull=[];
    this.loadFirstComp=true;
 
var selectionTabelData = [];
var wholeMapData=[];
      // for Account Section
      if( this.accRecTypeObjList.length < 1 ){
        if(this.accList.length > 0){
        var obj ={allCategoriers: "", checked: false, id: "",object:"Account"};
        obj.allCategoriers=this.accountLabel;
        obj.id='Id_Firms';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Account"};
            wrp_Data.allCategoriers=this.accountLabel;
            wrp_Data.List = Object.assign({}, this.accList);
            wholeMapData.push(wrp_Data);
        }
      }else{
        for(var i=0;i < this.accRecTypeObjList.length;i++){
            if(this.accRecTypeObjList[i]["List"].length > 0){
            var obj ={allCategoriers: "", checked: false, id: "",object:"Account"};
            obj.allCategoriers=''+this.accRecTypeObjList[i]["name"];
            obj.id='Id_'+this.accRecTypeObjList[i]["name"];
            selectionTabelData.push(obj);
            var wrp_Data={allCategoriers:"",List:[],object:"Account"};
            wrp_Data.allCategoriers=''+this.accRecTypeObjList[i]["name"];
            wrp_Data.List = Object.assign({}, this.accRecTypeObjList[i]["List"]);
            wholeMapData.push(wrp_Data);
            }
        }
      }
       // for Contact Section
       if( this.conRecTypeObjList.length < 1 ){
        if(this.conList.length > 0){
          
        var obj ={allCategoriers: "", checked: false, id: "",object:"Contact"};
        obj.allCategoriers=this.contactLabel;
        obj.id='Id_Contacts';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Contact"};
            wrp_Data.allCategoriers=this.contactLabel;
            wrp_Data.List = Object.assign({}, this.conList);
            wholeMapData.push(wrp_Data);
        }
      }else{
        for(var i=0;i < this.conRecTypeObjList.length;i++){
            if(this.conRecTypeObjList[i]["List"].length > 0){
            var obj ={allCategoriers: "", checked: false, id: "",object:"Contact"};
            obj.allCategoriers=''+this.conRecTypeObjList[i]["name"];
            obj.id='Id_'+this.conRecTypeObjList[i]["name"];
            selectionTabelData.push(obj);
            var wrp_Data={allCategoriers:"",List:[],object:"Contact"};
            wrp_Data.allCategoriers=''+this.conRecTypeObjList[i]["name"];
            wrp_Data.List = Object.assign({}, this.conRecTypeObjList[i]["List"]);
            wholeMapData.push(wrp_Data);
            }
        }
      }
      
       // for Deal Section
       if( this.dealRecTypeObjList.length < 1 ){
        if(this.dealList.length > 0){
        var obj ={allCategoriers: "", checked: false, id: "",object:"Pipeline__c"};
        obj.allCategoriers=this.dealLabel;
        obj.id='Id_Deals';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Pipeline__c"};
            wrp_Data.allCategoriers=this.dealLabel;
            wrp_Data.List = Object.assign({}, this.dealList);
            wholeMapData.push(wrp_Data);
        }
      }else{
        for(var i=0;i < this.dealRecTypeObjList.length;i++){
            if(this.dealRecTypeObjList[i]["List"].length > 0){
            var obj ={allCategoriers: "", checked: false, id: "",object:"Pipeline__c"};
            obj.allCategoriers=''+this.dealRecTypeObjList[i]["name"];
            obj.id='Id_'+this.dealRecTypeObjList[i]["name"];
            selectionTabelData.push(obj);
            var wrp_Data={allCategoriers:"",List:[],object:"Pipeline__c"};
            wrp_Data.allCategoriers=''+this.dealRecTypeObjList[i]["name"];
            wrp_Data.List = Object.assign({}, this.dealRecTypeObjList[i]["List"]);
            wholeMapData.push(wrp_Data);
            }
        }
      }
      
      // for Fund Section
      if( this.fundRecTypeObjList.length < 1 ){
        if(this.fundList.length > 0){
        var obj ={allCategoriers: "", checked: false, id: "",object:"Fund"};
        obj.allCategoriers=this.fundLabel;
        obj.id='Id_Funds';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Fund"};
            wrp_Data.allCategoriers=this.fundLabel;
            wrp_Data.List = Object.assign({}, this.fundList);
            wholeMapData.push(wrp_Data);
        }
      }else{
        for(var i=0;i < this.fundRecTypeObjList.length;i++){
            if(this.fundRecTypeObjList[i]["List"].length > 0){
            var obj ={allCategoriers: "", checked: false, id: "",object:"Fund"};
            obj.allCategoriers=''+this.fundRecTypeObjList[i]["name"];
            obj.id='Id_'+this.fundRecTypeObjList[i]["name"];
            selectionTabelData.push(obj);
            var wrp_Data={allCategoriers:"",List:[],object:"Fund"};
            wrp_Data.allCategoriers=''+this.fundRecTypeObjList[i]["name"];
            wrp_Data.List = Object.assign({}, this.fundRecTypeObjList[i]["List"]);
            wholeMapData.push(wrp_Data);
        }
      }
    }
    
      // for Fundraising Section
      if( this.fdrRecTypeObjList.length < 1 ){
        if(this.fdrList.length > 0){
        var obj ={allCategoriers: "", checked: false, id: "",object:"FundRaising"};
        obj.allCategoriers=this.fdrLabel;//Replaced "'Fundraising'" with "this.fdrLabel" by LK on 2024-05-21 to fix 00045482
        obj.id='Id_Fundraisings';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"FundRaising"};
            wrp_Data.allCategoriers=this.fdrLabel;//Replaced "'Fundraising'" with "this.fdrLabel" by LK on 2024-05-23 to fix 00044548 ; 00044503;00046058
            wrp_Data.List = Object.assign({}, this.fdrList);
            wholeMapData.push(wrp_Data);
        }
      }else{
        for(var i=0;i < this.fdrRecTypeObjList.length;i++){
            if(this.fdrRecTypeObjList[i]["List"].length > 0){
            var obj ={allCategoriers: "", checked: false, id: "",object:"FundRaising"};
            obj.allCategoriers=''+this.fdrRecTypeObjList[i]["name"];
            obj.id='Id_'+this.fdrRecTypeObjList[i]["name"];
            selectionTabelData.push(obj);
            var wrp_Data={allCategoriers:"",List:[],object:"FundRaising"};
            wrp_Data.allCategoriers=''+this.fdrRecTypeObjList[i]["name"];
            wrp_Data.List = Object.assign({}, this.fdrRecTypeObjList[i]["List"]);
            wholeMapData.push(wrp_Data);
            }
        }
      }
     
      // for Theme Section
      if( this.themeList.length >= 1 ){
        var obj ={allCategoriers: "", checked: false, id: "",object:"Theme"};
        obj.allCategoriers=this.themeLabel;
        obj.id='Id_Themes';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Theme"};
        wrp_Data.allCategoriers=this.themeLabel;
        wrp_Data.List = Object.assign({}, this.themeList);
        wholeMapData.push(wrp_Data);
      }
      
      // for Clip Section
      if( this.clipList.length >= 1 ){
        var obj ={allCategoriers: "", checked: false, id: "",object:"Clip"};
        obj.allCategoriers=this.clipLabel;
        obj.id='Id_Clips';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Clip"};
        wrp_Data.allCategoriers=this.clipLabel;
        wrp_Data.List = Object.assign({}, this.clipList);
        wholeMapData.push(wrp_Data);
      }
      // for Intraction Section
      if( this.taskList.length >= 1 ){
        var obj ={allCategoriers: "", checked: false, id: "",object:"Intraction"};
        obj.allCategoriers='Interaction';
        obj.id='Id_Intractions';
        selectionTabelData.push(obj);
        var wrp_Data={allCategoriers:"",List:[],object:"Intraction"};
        wrp_Data.allCategoriers='Interaction';
        wrp_Data.List = Object.assign({}, this.taskList);
        wholeMapData.push(wrp_Data);
      }
      this.selectionTabelDataFull=selectionTabelData;
      this.wholeMapDataFull=wholeMapData;
      this.loadFirstComp=true;
      
      if(checkValueRegardingCmp != undefined && checkValueRegardingCmp == 'comingFromChild'){
        this.template.querySelector('c-navatar-Research-Advance-Result-Lwc').setAdvanceDataTableData(this.selectionTabelDataFull,this.wholeMapDataFull);
      }    
}

// manage the lookup record or current record mechanishm including fields condition handle 
selectedLookupRecordHandler(event){
var advanceAttribute={Account:"",Contact:"",navpeII_dev18__Pipeline__c:"",navpeII_dev18__Fund__c:"",navpeII_dev18__Fundraising__c:"",navpeII_dev18__Theme__c:"",navpeII_dev18__Clip__c:""};
 
advanceAttribute.Account=event.detail.Account;
advanceAttribute.Contact=event.detail.Contact;
advanceAttribute.navpeII_dev18__Pipeline__c=event.detail.navpeII_dev18__Pipeline__c;
advanceAttribute.navpeII_dev18__Fund__c=event.detail.navpeII_dev18__Fund__c;
advanceAttribute.navpeII_dev18__Fundraising__c=event.detail.navpeII_dev18__Fundraising__c;
advanceAttribute.navpeII_dev18__Theme__c=event.detail.navpeII_dev18__Theme__c;
advanceAttribute.navpeII_dev18__Clip__c=event.detail.navpeII_dev18__Clip__c;
this.handleSearch(advanceAttribute,this.filedFilterData,'comingFromChild');
}

comingFieldData(event){
    this.filedFilterData=event.detail;
}
assignKeyWordMethod(event){
this.searchValue=event.detail;
}
noSearchTermExecution(event){
    var advanceAttribute=event.detail;
    this.handleSearch(advanceAttribute,this.filedFilterData,'noSearchProcessFromAdvCmp');
}
}