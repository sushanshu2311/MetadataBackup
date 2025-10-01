import { LightningElement , wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import getThemeRelatedFirms from '@salesforce/apex/NavatarThemeAddToFundCtrl.getThemeRelatedAccountRecords';
import getAccountsContactsSize from '@salesforce/apex/NavatarThemeAddToFundCtrl.getAccountsContacts';
import addToFundFdr from '@salesforce/apex/NavatarResearchAddToFundCtrl.addToFundFdr';
import createFdrCon from '@salesforce/apex/NavatarResearchAddToFundCtrl.createFdrCon';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FUND_OBJECT from '@salesforce/schema/Fund__c';
import FUNDRAISING_OBJECT from '@salesforce/schema/Fundraising__c';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import fetchAllowedAccRecTypeList from '@salesforce/apex/NavatarResearchAddToFundCtrl.fetchAllowedAccRecTypeList';
import FUNDRAISING_CONTACT_OBJECT from '@salesforce/schema/Fundraising_Contact__c';//Added by LK on 2024-05-17 to fix 00045864

export default class NavatarThemeAddToFundLwc extends NavigationMixin(LightningElement) {
    @track createdFundId;
    @track accountRecordTypeList = [];
    @track accountRecordTypeNameList = [];
    @track comingWholeMapData;
    @track fundSelectedAccRecType = [];
    @track accountIds;
    accRTInfos;
    accIdList = [];
    addtofund = true;
    isYesNoFund = false;
    createfund = false;
    isCreateNew = false;
    isAddNewFund = false;
    isCollapse = true;
    isExpand = false;
    isExpandCollapseBox = true;
    addtofundfirstscreen = true;//Updated value to true by LK on 2024-06-12 to fix 00045981
    selectedAccRecList =[];
    accIdListGlobal = [];
    accRecordsData;
    fundValue = false;
    categoryValue = false;
    disableSave = true;
    recId;
    accObjLabel;
    fundObjLabel='';
    contactPluralLabel = '';//Added initialization by LK on 2024-07-02 to fix 00046312
    accObjPluralLabel = '';//Added by LK on 2024-07-02 to fix 00046312
    fdrPluralLabel='';
    fdrLabel='';
    allContactsHeader ='';
    headerLabel;
    allContactsLabel;
    selectContactsLabel;
    categoryLabel='All Categories';//Updated by LK on 2024-05-21 to fix 00045857
    fundName = '';
    isFundAccessible = false;//Added by LK on 2024-03-18 for PE Phase 3.2
    fdrConPluralLabel;//Added by LK on 2024-05-17 to fix 00045864
    fdrConLabel;//Added by LK on 2024-05-17 to fix 00045864
    selectedRows = [];//Added by LK on 2024-05-21 to fix 00045856
    isObjAndAccRecTypeInfoFetched = false;//Added by LK on 2024-06-27 to fix 00046254
    themeRecId = '';//Added by LK on 2024-06-27 to fix 00046254
    showToast(cmp, title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        cmp.dispatchEvent(event);
    }
    //Added by LK on 2024-07-02 to fix 00046312
    get isYesNoFundMsg(){
        return `Do you want to add all ${this.contactPluralLabel.toLowerCase()} of the ${this.accObjPluralLabel.toLowerCase()} or select ${this.contactPluralLabel.toLowerCase()}?`;
    }

    isExpandadvance() {
        if (this.isCollapse === false) {
            this.isCollapse = true;
            this.isExpand = false;
            this.isExpandCollapseBox = false;
        }
        else {
            this.isCollapse = false;
            this.isExpand = true;
            this.isExpandCollapseBox = true;
            //Added below 2 lines by LK on 2024-10-08 to fix 00047535
            this.fundSelectedAccRecType = [...this.availableAccRecList];
            this.categoryValue = (this.fundSelectedAccRecType.length > 0 ) ? true : false;
        }
        //Replaced "true" with below condition by LK on 2024-10-08 to fix 00047535
        this.disableSave = this.fundValue && this.categoryValue ? false : true;
    }
    
    handleSelectedFundRecord(event) {
        //let selectedFundRecord = JSON.parse(event.detail);
        //this.createdFundId = selectedFundRecord.data.Id;
        //this.selectedRecord=this.createdFundId;
        let selectedFundRecord = JSON.parse(event.detail);
        this.createdFundId = selectedFundRecord.data.Id;
        this.fundName = selectedFundRecord.data.Name;
        this.fundValue = false;
        console.log('event.detail.data.Id---->>' + this.createdFundId);
        if(this.createdFundId){
            this.fundValue = true;
        }
        /*if(this.fundValue && this.categoryValue){
            this.disableSave = false;
        }*/
        //Replaced above code with below code by LK on 2024-05-21 to fix 00045853
        this.disableSave = this.fundValue && this.categoryValue ? false : true;
    }

    handleRemovedData(){
        this.disableSave = true;
        this.fundValue = false;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
             this.recId = currentPageReference.state.recordId;
              console.log('Record Id ', this.recId);
            }
    }
    //Added FUNDRAISING_CONTACT_OBJECT by LK on 2024-05-17 to fix 00045864
    @wire(getObjectInfos, { objectApiNames: [ACCOUNT_OBJECT,CONTACT_OBJECT,FUND_OBJECT,FUNDRAISING_OBJECT, FUNDRAISING_CONTACT_OBJECT]})
    handleObjectInfo({ error, data }) {
        if (data) {
            this.isFundAccessible = data.results[2].statusCode === 200;
            //Added above line, moved existing code inside if clause and added else clause by LK on 2024-03-18 for PE Phase 3.2
            if(this.isFundAccessible){
                console.log('Object Infos data'+ JSON.stringify(data));
                if(data != null && data.results.length > 0){
                    for(let i=0;i<data.results.length;i++){
                        if(data.results[i].result.apiName == 'Account'){
                            this.accObjLabel = data.results[i].result.label;
                            this.accObjPluralLabel = data.results[i].result.labelPlural;
                            const rtInfos = data.results[i].result.recordTypeInfos;
                            this.accRTInfos = rtInfos;
                        }
                        else if(data.results[i].result.apiName == 'Contact'){
                            this.contactPluralLabel = data.results[i].result.labelPlural;
                            this.contactLabel = data.results[i].result.label;
                            this.allContactsHeader = 'Add ' + this.contactPluralLabel;//Added for bug 00041650 by Harshwardhan Singh Karki
                            this.allContactsLabel = 'Add All '+ this.contactPluralLabel;
                            this.selectContactsLabel = 'Select '+ this.contactPluralLabel;
                        }
                        else if(data.results[i].result.apiName == 'navpeII_dev18__Fund__c'){
                            this.fundObjLabel = data.results[i].result.label;
                            this.headerLabel = 'Add To '+ this.fundObjLabel;
                        }
                        else if(data.results[i].result.apiName == 'navpeII_dev18__Fundraising__c'){
                            this.fdrPluralLabel = data.results[i].result.labelPlural;
                            this.fdrLabel = data.results[i].result.label;
                        }
                        //Added else if by LK on 2024-05-17 to fix 00045864
                        else if(data.results[i].result.apiName == 'navpeII_dev18__Fundraising_Contact__c'){
                            this.fdrConPluralLabel = data.results[i].result.labelPlural;
                            this.fdrConLabel = data.results[i].result.label;
                        }
                    }
                }
                if(this.fdrPluralLabel != null && this.fundObjLabel != null){
                    //Commented below line by LK on 2024-05-21 to fix 00045857
                    //this.categoryLabel = String('Select '+this.fdrPluralLabel+' for the '+this.fundObjLabel);//Changed Text for bug 00041605 by Harshwardhan Singh Karki
                    this.columnsCatogryFund = [
                        { label: this.categoryLabel, type: 'text', fieldName: 'allCategoriers', hideDefaultActions: true, cellAttributes: { class: 'slds-text-body_regular textColor' } },
                
                    ];
                }
                // if(this.accRTInfos != null){
                //     let optionsValues = [];
                //     let optionsNames = [];
                //     let rtValues = Object.values(this.accRTInfos);
                //     for (let i = 0; i < rtValues.length; i++) {
                //         if (!['Master', 'Advisor', 'Company', 'Intermediary', 'Lender', 'Portfolio_Company', 'Private_Equity', 'Property'].includes(rtValues[i].name)) {
                //         optionsNames.push(rtValues[i].name);
                //         optionsValues.push({
                //             allCategoriers: rtValues[i].name,
                //             id: rtValues[i].recordTypeId,
                //             object : 'Account'
                //             })
                //         }
                //     }
                //     this.accountRecordTypeList = optionsValues;
                //     this.accountRecordTypeNameList = optionsNames;
                // }
            } else {
                this.closeModal();
                //Updated toast msg by LK on 2024-05-14 to fix 00045529
                this.showToast(this, 'Error!', 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', 'error');
            }
        }
        else if(error){
            this.errorMessage = reduceErrors(this.error);
            console.log(this.errorMessage)
        }
    }

    //Added below code by LK on 2024-04-11 to fix 00044462, 00044460
    @wire(fetchAllowedAccRecTypeList)
    fetchAllowedAccRecTypeList({ error, data }) {
        if(data){
            if(data != null){
                let optionsValues = [];
                let optionsNames = [];
                //Commented below code by LK on 2024-07-01 to fix 00045856
                //this.selectedRows = [];
                const rtInfos = data;
                let rtValues = Object.values(rtInfos);
                for (let i = 0; i < rtValues.length; i++) {
                    optionsNames.push(rtValues[i].name);
                    optionsValues.push({
                        allCategoriers: rtValues[i].name,
                        id: rtValues[i].recTypeId,
                        object : 'Account'
                    })
                    //Commented below code by LK on 2024-07-01 to fix 00045856
                    //this.selectedRows.push(optionsValues[i].id);
                }
                this.accountRecordTypeList = optionsValues;
                this.accountRecordTypeNameList = optionsNames;

                //Added below 3 lines by LK on 2024-05-21 to fix 00045856
                this.fundSelectedAccRecType = [...this.accountRecordTypeList];
                this.itemCount = this.fundSelectedAccRecType.length;
                this.categoryValue = (this.fundSelectedAccRecType.length > 0 ) ? true : false;
            }
        } else if(error){
            this.showToast(this, 'Error!', error.body.message, 'error');
        }
    }
    //Replaced "recId" with "themeRecId" by LK on 2024-06-27 to fix 00046254
    @wire(getThemeRelatedFirms, {recId : '$themeRecId'})
    accountsData({error,data}){
        //Added this.isFundAccessible by LK on 2024-03-18 for PE Phase 3.2
        if(data && this.isFundAccessible){
            this.accRecordsData = JSON.parse(data);
            console.log('accRecordsData',this.accRecordsData);
            if(this.accRecordsData){
                this.filterAccRecList();
                this.isExpandCollapse = true;
                this.isExpand = true;
                this.isCollapse = false;
                this.addtofundfirstscreen = true;
            }
        }
        else if(error){
            this.addtofundfirstscreen = false;//Added by LK on 2024-06-12 to fix 00045981
            console.log('res.erro'+ error);
            this.showToast(this, 'Error!', error.body.message, 'sticky');
        }

    }


    filterAccRecList(){
        this.selectedRows = [];//Added by LK on 2024-07-01 to fix 00045856
        this.availableAccRecList = [];
        for (let i = 0; i < this.accountRecordTypeList.length; i++) {
            let access1;
            let access2;
                    if(this.accountRecordTypeList[i]['object'] == 'Account'){
                    access1 = this.accountRecordTypeList[i]["allCategoriers"];
                    let g = 0;
                    for (g = 0; g < this.accRecordsData.length; g++) {
                        access2 = this.accRecordsData[g]["accRecTypeName"];
                        if (access1 == access2) {
                            if(!this.availableAccRecList.includes(this.accountRecordTypeList[i])){
                                //Moved existing code inside {} & added selectedRows by LK on 2024-07-01 to fix 00045856
                                this.availableAccRecList.push(this.accountRecordTypeList[i]);
                                this.selectedRows.push(this.accountRecordTypeList[i].id);
                            }
                               
                        }
                    }
                    console.log('availableAccRecList--->' ,JSON.stringify(this.availableAccRecList));
                }
        }
    }

    itemCountFund = '16';
    @track columnsCatogryFund = [
        { label: this.categoryLabel, type: 'text', fieldName: 'allCategoriers', hideDefaultActions: true, cellAttributes: { class: 'slds-text-body_regular textColor' } },

    ];

    getSelectedRec() {
        this.fundSelectedAccRecType = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.itemCount = this.fundSelectedAccRecType.length;
        this.categoryValue = (this.fundSelectedAccRecType.length > 0 ) ? true : false;
        this.disableSave = (this.fundValue && this.categoryValue) ? false : true;
    }

    addToFundAndFdr() {
        if(this.createdFundId =='' || this.createdFundId == undefined){
            this.showToast(this, 'Required Field Missing', 'Please select '+this.fundObjLabel, 'error');
            return;
        }
        

        if (this.fundSelectedAccRecType.length > 0) {
            this.serverDataMaking();
            this.addToFundFdr(this.createdFundId, JSON.stringify(this.accIdListGlobal));
        }else{
            this.isYesNoFund = false;
            this.isAddNewFund = false;
            this.isAddTo = false;
            this.isCollapse = true;
            this.isExpand = false;
            this.isExpandCollapseBox = false;
        }
    }

    serverDataMaking() {
        let accIdList = [];
        for (let i = 0; i < this.fundSelectedAccRecType.length; i++) {
            let access1;
            let access2;
            if(this.fundSelectedAccRecType[i]['object'] == 'Account'){
                    access1 = this.fundSelectedAccRecType[i]["allCategoriers"];
                    let g = 0;
                    for (g = 0; g < this.accRecordsData.length; g++) {
                        access2 = this.accRecordsData[g]["accRecTypeName"];
                        if (access1 == access2) {
                           this.accIdList.push(this.accRecordsData[g]['accountId']);
                            this.selectedAccRecList.push(this.accRecordsData[g]["accRecTypeName"]);
                            console.log('accIdList',JSON.stringify(this.accIdList));
                        }
                    }
                    this.accountIds = this.accIdList;
                    console.log('accountIds',this.accountIds);
                    console.log('selReclist',this.selectedAccRecList);
            }
        }
        this.accIdListGlobal = this.accIdList;
        if(this.accIdListGlobal.length > 0){
            getAccountsContactsSize({accIds: this.accIdListGlobal}).then(result =>{
                if(result == true){
                    this.isYesNoFund = true;
                    this.addtofundfirstscreen = false;
                }
                else{
                    this.isYesNoFund = false;
                    this.closeModal();
                }
            }).catch(error =>{
                console.log('Error fetching Contacts from selected Accounts');
                console.log(error);
            })
        }
        console.log(this.accIdListGlobal,'acclist12342');
    }

    addToFundFdr(createdFundId, accIdListGlobal){
        addToFundFdr({ fundId: createdFundId, fundName: this.fundName, accList: accIdListGlobal}).then(data => {
            if(data === 'success'){
            console.log('data=', data);
            //Added toast event for bug 00041515 by Harshwardhan Singh Karki
            //this.fundObjLabel+' is associated with selected '+this.fdrPluralLabel
            //Updated toast msg by LK on 2024-05-17 to fix 00045861
            //Updated toast msg by LK on 2024-07-02 to fix 00046303 ; 2024-10-21 to fix 00047448
            this.showToast(this, 'Success', `Selected ${this.accObjLabel}(s) was associated as ${this.fdrLabel} with the ${this.fundObjLabel}.`, 'success');
            } else if(data === 'failure') {
                this.showToast(this, 'Error!', 'All records failed to insert', 'error');
            } else {
                this.showToast(this, 'Error!', data, 'error');
            }
            this.isAddNewFund = false;
            this.isAddTo = false;
            this.isCollapse = true;
            this.isExpand = false;
            this.isExpandCollapseBox = false;
        }).catch(error => {
            console.log(error);
        });
    }

    closeAddeNew() {
        this.isAddNew = false;
    }
    closeYesNo(event) {
        this.isYesNoFund = false;
        this.isCollapse = true;
        this.isExpand = false;
        this.isExpandCollapseBox = false;
        this.closeModal();
    }
    
    addAllContactsFund(){
        console.log('addAllContactsFund==');
        let optionsValues = [];
        for (let i = 0; i < this.fundSelectedAccRecType.length; i++) {
            optionsValues.push(this.fundSelectedAccRecType[i].allCategoriers);
        }
        console.log('optionsValues==', optionsValues);
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
        console.log('finalAccRecList==', JSON.stringify(finalAccRecList));
        console.log('accIdListGlobal==', this.accIdListGlobal);

        this.createFdrCon(this.createdFundId, JSON.stringify(this.accIdListGlobal));
    }
    
    createFdrCon(createdFundId, accIdListGlobal){
        createFdrCon({ fundId: createdFundId, accList: accIdListGlobal }).then(data => {
            if(data === 'success'){
            console.log('data=', data);
            //'All '+this.contactLabel+' was succesfully added to your '+this.fdrPluralLabel
            //Updated toast msg by LK on 2024-05-17 to fix 00045864 ; 2024-10-21 to fix 00046701 ; 00045910
            this.showToast(this, 'Success', `All ${this.contactPluralLabel} were associated with the ${this.fundObjLabel} as ${this.fdrConPluralLabel}.`, 'success');
            } else if(data === 'failure') {
                this.showToast(this, 'Error!', 'All records failed to insert', 'error');
            } else {
                this.showToast(this, 'Error!', data, 'error');
            }
            this.isYesNoFund = false;
            this.isAddNewFund = false;
            this.isAddTo = false;
            this.closeModal();
        }).catch(error => {
            console.log(error);
        });
    }

    yesContactFund() {
        this.isYesNoFund = false;
        if(this.accountIds.length > 0){
            let compDefinition = {
                componentDef : "navpeII_dev18:navatarAddContactsLwc",
                attributes: {
                    propertyValue: "100",
                    accountData: this.accountIds,
                    fundId : this.createdFundId,
                    themeId : this.recId,
                    source : 'fund',
                    callingFrom : 'Theme',
                }
            };

            let encodedCompdef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompdef
                }
            }).then(generatedUrl => {
                window.open(generatedUrl, "_blank");
            });
            this.closeModal();
        }


    }
    renderedCallback() {
        //Added below if clause code by LK on 2024-06-27 to fix 00046254
        if(this.isObjAndAccRecTypeInfoFetched == false && (this.isFundAccessible && this.accountRecordTypeList.length > 0)){
            this.themeRecId = this.recId;
            this.isObjAndAccRecTypeInfoFetched = true;
        }
        console.log(this.isRendered);
        let popupSize = document.createElement('style');
        popupSize.innerText = ` .uiModal--horizontalForm .modal-container.slds-modal__container {
                                        width: 30rem !important;
                                    }
                                    .uiModal--medium .modal-container.slds-modal__container {
                                        width: 30rem !important;
                                    }
                                    /*00046039 fixed by raju on dated 11-06-2024*/
                                    .clsRemoveXscroll .slds-scrollable_x {
                                        overflow-x:hidden !important;
                                    }
                                    .quick-actions-panel {
                                        overflow-y:hidden !important;
                                    }
                                    .listdiv .slds-modal__content {
                                        max-height: 275px !important;
                                        min-height: 138px !important;
                                    }
                                    .slds-table_header-fixed tbody tr th {
                                        height: 41px;
                                    }
                                    .addtofund_css .slds-scrollable_y{
                                        overflow-y: auto !important;
                                    }
                                    .addtofund_css .slds-th__action{
                                        background: #f3f3f3 !important;
                                        box-shadow: none;
                                    }
                                    .addtofund_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus),
                                    .addtofund_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus),
                                    .addtofund_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus),
                                    .addtofund_css .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus),
                                    .addtofund_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus),
                                    .addtofund_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus),
                                    .addtofund_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus),
                                    .addtofund_css .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus) {
                                        box-shadow: none;
                                    }
                                    .addtofund_css .slds-table tbody tr.slds-is-selected>td,
                                    .addtofund_css .slds-table tbody tr.slds-is-selected>th{
                                        background-color: #e9e8e83d !important;    
                                    }
                                    .modal-glass.slds-backdrop.fadein.slds-backdrop--open{
                                        height: 94.5vh;
                                        opacity: 1 !important;
                                    }
                                    @media only screen and (max-width : 1025px){
                                        .listdiv .slds-modal__content{
                                            min-height:120px !important;
                                    }}`;
        this.template.querySelector('.listdiv').appendChild(popupSize);
    }
    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}