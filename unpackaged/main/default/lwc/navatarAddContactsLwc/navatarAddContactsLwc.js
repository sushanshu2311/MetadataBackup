import { LightningElement, api, track, wire } from 'lwc';
import { helper } from './navatarAddContactsHelperLwc.js';
import fetchQueryResults from "@salesforce/apex/NavatarAddContactsCtrl.getInitQuery";
import fetchNavatarSetup from "@salesforce/apex/NavatarAddContactsCtrl.getNavatarSetupData";
import executeQuery1 from "@salesforce/apex/NavatarAddContactsCtrl.executeQuery1";
import addToThemeRecord from '@salesforce/apex/NavatarAddContactsCtrl.addToThemeRecord';
import createSelectedFdrCon from '@salesforce/apex/NavatarResearchAddToFundCtrl.createSelectedFdrCon';
import getDefaultRole from '@salesforce/apex/NavatarResearchAddToFundCtrl.getDefaultRole';
import getFundName from '@salesforce/apex/NavatarResearchAddToFundCtrl.getFundName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';//Added by LK on 2024-05-30 to fix 00045980
import FUNDRAISING_CONTACT_INFO from '@salesforce/schema/Fundraising_Contact__c';//Added by LK on 2024-05-30 to fix 00045980

export default class NavatarAddContactsLwc extends NavigationMixin(LightningElement) {
    @api accountData;       //for getting selected categories account ids 
    @api themeName;     // getting theme name for header
    @api themeId;   // getting selected or created theme id for add to theme 
    @api fundId;    //for fundId
    @api researchSearchStr; // for research key word
    @api fdrIds; //getting targets
    @api objectLabelMap1; //for label handling 
    @api objectPluMap; // for plural label handling
    @api source; //for check coming from deal or theme
    objApiNamesListTab;
    //for dynamic label change by salauddin sheikh 5th july 2023
    @track contactLabel; 
    @track accountLabel; 
    @track fdrLabel;
    @track fundLabel;
    @track themeLabel;
    @track pcontactLabel = '';//Added initialization by LK on 2024-07-02 to fix 00046314
    @track paccountLabel;
    @track pfdrLabel;
    @track pfundLabel;
    @track pthemeLabel;
    @track filterClk = false;   //added this for bug #00041372 fix by salauddin sheikh
    @track isModalOpen = false;
    advanceSearch = true;
    @track contactData = [];
    isLoading=true;   //added changes for bug #00041367 fixes by salauddin sheikh
    @track nameSpacePrefix;
    showFilterCmp = false; //added for bug -00043322 by Harshwardhan
    defaultFieldList = true;
    showAllOption;
    enableLoadMore;
    allDataList = [];
    fieldStruct = [];
    selectedRows = [];
    sel_SelectedData = [];
    sel_allDataList = [];
    existingIdSet = [];
    selectedIdSet = [];
    selectAll = false;
    selectedrowcount = 0;
    sel_ConColumns;     //selected contact column for theme
    sel_ConColumns1;
    sel_SortedBy = 'Name_Contact';
    nonsortable=[];
    pageName;
    isEligible;
    @track columnsToShow = [];  //for search table column
    @track columnsToShow1 = []; //fro review table column
    allfieldsProcessed;
    onLoad = true;
    @track whereClause = '';
    whereCon_Contact = '';
    testQuery;
    @track isFundSource = false;  
    @track selectedPicklistOptions= '';
    conColumns = [];    //select contact table column
    mandateFilter = true;    //for navatar search contact lwc
    filterObj = {}; //filter data store 
    @track conVsInteraction;    //for meeting count map
    @track fundName;    //for store deal Name
    dealTeamRoleOption = [];
    /* add new rows for Search for specific records and Search by field parameters*/
    @track listOfAccounts;
    @track listOfAccountsPara;
    @track headerName;
    filterdiv = false;
    @track isSearchSecVisible = true; // added for bug #00041340, #00041419 fixes by salauddin sheikh
    
    fdrConLabel = 'Fundraising Contact';//Added by LK on 2024-05-30 to fix 00045980
    fdrConPluralLabel = 'Fundraising Contacts';//Added by LK on 2024-05-30 to fix 00045980
    //Added below method by LK on 2024-05-30 to fix 00045980
    @wire(getObjectInfo, { objectApiName: FUNDRAISING_CONTACT_INFO}) 
    objectsInfo({error, data}){
        if(data){
            this.fdrConLabel = data['label'];
            this.fdrConPluralLabel = data['labelPlural'];
        }
    }

    openModal(text) {
        this.isModalOpen = true;

    }
    closeModal() {
        this.isModalOpen = false;
    }

    isExpandCollapseLink() {
        this.advanceSearch = false;
    }
    closefiltershow() {
        this.advanceSearch = true;
    }
  
    objLabelHandling(){ //for dynamic label change by salauddin sheikh 5th july 2023
                if(this.objectLabelMap1 != undefined){
                    this.contactLabel = this.objectLabelMap1['Contact'];
                    this.accountLabel = this.objectLabelMap1['Account'];
                    this.fundLabel = this.objectLabelMap1['navpeII_dev18__Fund__c'];
                    this.fdrLabel = this.objectLabelMap1['navpeII_dev18__Fundraising__c'];
                    this.themeLabel = this.objectLabelMap1['navpeII_dev18__Theme__c'];
                }
                else{   //bug #00040835 fixes by salauddin sheikh
                    this.contactLabel = 'Contact';
                    this.accountLabel = 'Account';
                    this.fundLabel = 'Fund';
                    this.fdrLabel = 'Fundraising';
                    this.themeLabel = 'Theme';
                }
                if(this.objectPluMap != undefined){ 
                    this.pcontactLabel = this.objectPluMap['Contact'];
                    this.paccountLabel = this.objectPluMap['Account'];
                    this.pfundLabel = this.objectPluMap['navpeII_dev18__Fund__c'];
                    this.pfdrLabel = this.objectPluMap['navpeII_dev18__Fundraising__c'];
                    this.pthemeLabel = this.objectPluMap['navpeII_dev18__Theme__c'];
                }
                else{   //bug #00040835 fixes by salauddin sheikh
                    this.pcontactLabel = 'Contacts';
                    this.pthemeLabel = 'Themes';
                    this.paccountLabel = 'Accounts';
                    this.pfdrLabel = 'Fundraisings';
                    this.pfundLabel = 'Funds';
                }
            
          if(this.source == 'fund'){
                //Replaced "this.fdrLabel+' '+this.pcontactLabel" with "this.fdrConPluralLabel" by LK on 2024-05-30 to fix 00045980
                this.headerName = 'Select '+this.fdrConPluralLabel+ ' for ' +this.fundName;  //changes for bug #00040430, #00040567 fixes by Salauddin Sheikh
            }
            else{
                //Added toLowerCase() by LK on 2024-07-02 to fix 00046314
                this.headerName = 'Select '+this.pcontactLabel.toLowerCase()+' for '+ this.themeName; //changes for bug #00040425, #00040568,#00041197 fixes by Salauddin Sheikh
            }
    }
    objectApiName2 = 'navpeII_dev18__Deal_Team__c';
    @wire(getObjectInfo, { objectApiName: '$objectApiName2'}) 
    dealTeamRecord;

    objectApiName1 = 'navpeII_dev18__Fundraising_Contact__c.navpeII_dev18__Role__c';
    @wire(getPicklistValues, {recordTypeId: '$dealTeamRecord.data.defaultRecordTypeId', fieldApiName: '$objectApiName1'})
    dealteamRolePicklist({ data, error }) {
        if(data) {
            this.dealTeamRoleOption = data.values;
        }
        else if (error) {
            this.showToast(this, 'Error!', error.body.message, 'error');
        }
    }

    columnsReviewContactNew = [];

    connectedCallback() {
        if(this.source == "fund"){
            this.isFundSource = true;
            this.getFundNameHelper();
        }else{
            this.isFundSource = false;
        }
        this.objLabelHandling(); //for dynamic label change by salauddin sheikh 5th july 2023
        this.initData();
        this.isEligible = true;
        // if(this.themeId != null){ //for bug #00040426 fixes by Salauddin sheikh
        //     this.getAccountFromTheme();
        // }
        if (this.propertyValue == '300') {
            this.advanceSearch = true;
            this.mainSearchfromTheme = true;
            this.mainSearch = false;
        }
        helper.setDefaults(this);
        this.getNavatarSetupData();
        getDefaultRole().then(data => {
            this.selectedPicklistOptions = data;
        }).catch(error => {
            console.log(error);
        });


    }
    getFundNameHelper(){
        getFundName({ "fundId": this.fundId }).then(data => {
            //Added toLowerCase() to fdrLabel & pcontactLabel by LK on 2024-05-11 to fix 00045702
            //Replaced "this.fdrLabel.toLowerCase()+' '+this.pcontactLabel.toLowerCase()" with "this.fdrConPluralLabel" by LK on 2024-05-30 to fix 00045980
             this.headerName = 'Select '+this.fdrConPluralLabel.toLowerCase()+ ' for '+data;   //changes for bug #00040430, #00040567 fixes by Salauddin Sheikh
            this.fundName = data;
        }).catch(error => {
            //Added toLowerCase() by LK on 2024-07-02 to fix 00046314
            this.headerName = 'Select '+this.pcontactLabel.toLowerCase()+ ' for '+this.themeName;  //changes for bug #00040430, #00040567 ,00040568, #00041197fixes by Salauddin Sheikh
            console.log(error);
        });
    }
    initData() {
        let listOfAccounts = [];
        let listOfAccountsPara = [];
        this.createRow(listOfAccounts);
        this.createRowpara(listOfAccountsPara);
        this.listOfAccounts = listOfAccounts;
        this.listOfAccountsPara = listOfAccountsPara;
    }
    createRow(listOfAccounts) {
        let accountObject = {};
        if (listOfAccounts.length > 0) {
            accountObject.index = listOfAccounts[listOfAccounts.length - 1].index + 1;
        } else {
            accountObject.index = 1;
        }
        if (accountObject.index == 1) {
            accountObject.hideBtn = false;
        } else {
            accountObject.hideBtn = true;
        }
        listOfAccounts.push(accountObject);
    }
    createRowpara(listOfAccountsPara) {
        let accountObjectp = {};
        if (listOfAccountsPara.length > 0) {
            accountObjectp.index = listOfAccountsPara[listOfAccountsPara.length - 1].index + 1;
        } else {
            accountObjectp.index = 1;
        }
        if (accountObjectp.index == 1) {
            accountObjectp.hideBtnpara = false;
        } else {
            accountObjectp.hideBtnpara = true;
        }
        listOfAccountsPara.push(accountObjectp);
    }
    addNewRow() {
        this.createRow(this.listOfAccounts);
    }
    addNewRowpara() {
        this.createRowpara(this.listOfAccountsPara);
    }
    removeRow(event) {
        let bgWhite = event.target.closest('.dnone')
        bgWhite.classList.add('d_none');
    }
    handleChange(event) {
        this.value = event.detail.value;
    }
    handleChangeOperator(event) {
        this.value = event.detail.value;
    }

    get optionsOperator() {
        return [
            { label: 'Equal', value: 'Equal' },
            { label: 'Not Equal', value: 'Not Equal' },
            { label: 'Greater', value: 'Greater' },
            { label: 'Smaller', value: 'Smaller' },
        ];
    }

    // *********************************************************************************************************************************************//
    // new code date 12 may
    /******* Page 1 :- Filter Prospects Page : Common Methods *******/
    get headerIconName() {
        return this.isSearchSecVisible ? 'utility:chevronright' : 'utility:chevrondown';
    }
    get showNoRecord() {   //added changes for bug #00041367 fixes by salauddin sheikh
        return !this.isLoading && (this.contactData == undefined || this.contactData.length == 0);
    }
    get showNoRecord1() {  //added changes for bug #00041367 fixes by salauddin sheikh
        return !this.isLoading && (this.sel_SelectedData == undefined || this.sel_SelectedData.length == 0);
    }
    /*control visiblity of fitler*/
    handleSectionToggle(event) {
        this.isSearchSecVisible = !this.isSearchSecVisible;

        //this.filterdiv = false;
        if (this.isSearchSecVisible) {
            this.filterdiv = false;
            this.template.querySelector('.inner-custom-mechanish').classList.remove('displaydiv');  //added for bug #00041581 fixes by salauddin sheikh
            this.template.querySelector('.inner-custom-mechanish').classList.add('hidediv');        //added for bug #00041581 fixes by salauddin sheikh
        }
        else {
            this.filterdiv = true;
            this.template.querySelector('.inner-custom-mechanish').classList.remove('hidediv'); //added for bug #00041581 fixes by salauddin sheikh
            this.template.querySelector('.inner-custom-mechanish').classList.add('displaydiv');    //added for bug #00041581 fixes by salauddin sheikh
        }
    }
    get selectedCounts() {
        let selText;
        let counts = this.template.querySelector('[data-id="searchResults"]') ? this.template.querySelector('[data-id="searchResults"]').selectedRows.length : 0;
        counts += (this.selectAll == true ? this.contactData.length - this.contactData.length : 0);
        selText = counts > 0 ? (counts == 1 ? '1 item selected' : counts + ' items selected') : selText;
        return selText;
    
    }
    handleRowSelect(event) {
        this.selectedRows = this.template.querySelector('[data-id="searchResults"]').selectedRows;
        var row = event.detail.selectedRows;
        try {
            if (this.selectedRows.length == 0) {
                this.selectAll = false;
            } else if (this.selectedrowcount < row.length && this.selectedRows.length == this.contactData.length) {
                let newSelectedRows = [];
                this.selectAll = true;
                newSelectedRows = this.allDataList.map(val => { return val.Id });
                this.selectedRows = newSelectedRows;

            } else if (this.selectedrowcount < row.length && this.selectedRows.length < this.contactData.length) {
                let newSelectedRows = this.selectedRows;
                let postSelRows = this.allDataList.slice(this.contactData.length, this.allDataList.length).map(val => { return val.Id });
                newSelectedRows = [...newSelectedRows, ...postSelRows];
                this.selectedRows = newSelectedRows;
            }
            else {
                this.selectedrowcount = this.selectedRows.length + 1;
            }
        }
        catch (error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }
    }
    // remove any row from selected table
    handledeleteRow(event) {
        this.toggleSpinner();
        const row = event.detail.row;
 
        
        this.sel_allDataList = this.sel_allDataList.filter(item => item.Id != row.Id);
        this.sel_SelectedData = this.sel_allDataList.slice(0, this.sel_SelectedData.length - 1);
        this.selectedIdSet = this.sel_allDataList.map(val => { return val.Id });

        //append it back to the table shown.
        const allDataList = this.allDataList;
        let isExistingIndice = allDataList.findIndex(val => val.Id == row.Id);
        if (isExistingIndice == -1) {
            const newAllDataList = allDataList.concat(row);
            this.allDataList = helper.sortByKey(newAllDataList, this.sortedBy, this.sortedDirection);
            if (this.allDataList.length > 20) {
                const conData = [].concat(newAllDataList.slice(0, this.contactData.length + 1));
                this.contactData = conData;
            } else {
                const conData = [].concat(newAllDataList);
                this.contactData = conData;
            }
        }
        this.toggleSpinner();
    }

    hitMainQuery() {
        this.toggleSpinner();
        this.contactData = [];  // added for bug #00041583 fixes by salauddin sheikh
        //00029526 by vishesh 20210412
        if (this.sel_SelectedData.length > 0) {
            this.existingIdSet = this.sel_SelectedData.map(val => { return val.Id });
        }
        let whereIndex = this.mainQuery.indexOf('where');
        let orderIndex = this.mainQuery.indexOf('order by');    //changes for bug #00041504 fixes by salauddin sheikh
        let mainQuery;
        if (whereIndex > -1) {
            if(!this.filterClk){       //changes for bug #00041504 fixes by salauddin sheikh
                this.testQuery = this.mainQuery.substring(0, whereIndex + 5) + ' AccountId IN : accountData order by Contact.Name asc';
                mainQuery = this.mainQuery.substring(0, whereIndex + 5) + ' AccountId IN : accountData '+ this.mainQuery.substring(orderIndex, this.mainQuery.length);
            }
            else{      //changes for bug #00041504 fixes by salauddin sheikh
                mainQuery = this.mainQuery.substring(0, whereIndex + 5) + ' AccountId IN : accountData AND (' + this.mainQuery.substring(whereIndex + 5, this.mainQuery.length);
            }
        }
        mainQuery = mainQuery + ' LIMIT 2000';
        //Added filterString by Lakshya on 2021-12-16 to resolve 00030338
        fetchQueryResults({ mainQuery: mainQuery, existingIdSet: this.existingIdSet, accountData: this.accountData, filterString: (this.filterObj['filterString'] || '') })
            .then(result => {
                if (result.status == 'success') {
                    try {
                        this.conVsInteraction = result.ConInteraction; //interaction column fixes by salauddin sheikh
                        helper.processResults(this, result.response);
                        if (this.enableLoadMore == true) {
                            this.hitMainQuery();
                        }
                    } catch (err) {
                        helper.showToast(this, 'Error!', err.message, 'error');
                    }
                    this.toggleSpinner();
                } else {
                    helper.showToast(this, 'Error!', result.status, 'error');
                }
            }).catch(error => {
                helper.showToast(this, 'Error!', error.body.message, 'error');
                this.toggleSpinner();
            });
    }
    createThemeRelation() {
        this.toggleSpinner();
        if(this.source == "fund"){
            let contactIds = [];
            let accountIds = [];
            let contactList = [];
            for (let i = 0; i < this.sel_SelectedData.length; i++) {
                if(this.sel_SelectedData[i].selectedRole == '' || this.sel_SelectedData[i].selectedRole == undefined){ // bug #40433 fixes by Salauddin Sheikh
                    this.sel_SelectedData[i].selectedRole = this.selectedPicklistOptions;
                }
                contactIds.push(this.sel_SelectedData[i].Id);
                accountIds.push(this.sel_SelectedData[i].AccountId);
                contactList.push({conId : this.sel_SelectedData[i].Id, accId : this.sel_SelectedData[i].AccountId, roleName : this.sel_SelectedData[i].selectedRole})
            }
            createSelectedFdrCon({  "accountIds": JSON.stringify(accountIds), "fundId": this.fundId, "wrapperStr": JSON.stringify(contactList) }).then(data => {
                const evt = new ShowToastEvent({
                       title: 'Success', //Added by LK on 2024-08-30 to fix 00046307
                       //'Contacts have been added to the fundraising'
                       //Updated toast msg by LK on 2024-05-17 to fix 00045912
                       //Replaced "${this.fdrLabel} ${this.contactLabel}(s)" with "this.fdrConPluralLabel" by LK on 2024-05-30 to fix 00045980
                       //Replaced "${this.fdrConPluralLabel}" with "${this.fdrConLabel}" by LK on 2024-07-22 to fix 00046306
                       message: `${this.contactLabel}(s) was associated with the ${this.fundLabel} as ${this.fdrConLabel}(s)`, //message modified for bug #00042084 fixes by salauddin sheikh
                        variant: 'success'
                    })
                    this.dispatchEvent(evt);
                    setTimeout(() => {
                       this.clickBack();
                    }, 3000);
                let result = JSON.parse(data);
                for (let i = 0; i < this.sel_SelectedData.length; i++) {
                    for(let j = 0; j < result.length; j++){
                        if(this.sel_SelectedData[i].Id == result[j].conId){
                            this.sel_SelectedData[i].RoleId = result[j].roleId;
                        }
                    }
                    
                }
                
            }).catch(error => {
                helper.showToast(this, 'Error!', error.body.message, 'error');
            });
        }else{
            const accountContactIds = [];
            for (const it of this.sel_SelectedData) {
                accountContactIds.push(it.Id);
            }
            let accIdListGlobal = [];
            let dealIdListGlobal = [];
            let fundIdListGlobal = [];
            let fundRaisingIdListGlobal = [];
            let themeIdListGlobal = [];
            let clipIdListGlobal = [];
            let interactionList = [];
                addToThemeRecord({ addAllContactForEachFirm: false, themeIdValue: this.themeId, accountList: accIdListGlobal, contactList: accountContactIds, dealList: dealIdListGlobal, fundList: fundIdListGlobal, fundraisingList: fundRaisingIdListGlobal, themeList: themeIdListGlobal, clipList: clipIdListGlobal, interactionList : interactionList })
                .then((result) => {
                    if (result != null && result != undefined) {
                       // this.serverMessage = this.themeLabel+' is related to selected catagories';
                       console.log(result);
                        const evt = new ShowToastEvent({
                            //Added below title by LK on 2024-07-24 to fix 00046679
                            title: 'Success',
                            message: result,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        setTimeout(() => {
                            this.clickBack();
                        }, 3000);
                    }
                   
                   
                })
                .catch((error) => {
                    this.error = error;
                    this.serverMessage = 'conflict occure at the server side' + this.error.message;
        
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });
        }
        
    }
    navigateToThemes() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.themeId,
                objectApiName: this.nameSpacePrefix+'Theme__c', // objectApiName is optional
                actionName: 'view'
            },
    
        });
    }
    get resultLoaded() {
        return this.allDataList.length > 1999 && this.showAllOption ? '1999+' : this.allDataList.length;
    }
    get sel_resultLoaded() {
        let selText;
        selText = this.sel_allDataList.length > 0 ? (this.sel_allDataList.length == 1 ? 'Total Records: 1' : ' Total Records: ' + this.sel_allDataList.length ) : selText;
        return selText;
    }
   // selectedCounts ="2 Item Selected"
    /* add new rows for Search for specific records and Search by field parameters*/
    renderedCallback() {
        this.isRendered = true;
        const style = document.createElement('style');  //added Ui fixes by salauddin sheikh 
        style.innerText = `.slds-table td{
            height: 40px;
        }
        .heightDataTable button.slds-button.slds-button_icon.slds-cell-edit__button.slds-m-left_x-small{
            padding-right: 18px;
        }
        .quick-actions-panel .add_pos{
            margin: 0 0 0 12px;
        }
        .shadowremovedatatable .slds-th__action {
            background: #f3f3f3 !important;
            box-shadow: none;
        }
        .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action,
        .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .shadowremovedatatable .slds-is-resizable .slds-th__action:focus,
        .shadowremovedatatable .slds-is-resizable .slds-th__action:focus:hover,
        .shadowremovedatatable .slds-table th:focus,
        .shadowremovedatatable .slds-table th.slds-has-focus,
        .shadowremovedatatable .slds-table [role="gridcell"]:focus,
        .shadowremovedatatable .slds-table [role="gridcell"].slds-has-focus,
        .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th,
        .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            box-shadow: none !important;
        }
        .shadowremovedatatable .slds-th__action:focus,
        .slds-th__action:hover,
        .shadowremovedatatable .slds-table tr:hover {
            box-shadow: none !important;
        }
        .shadowremovedatatable .slds-th__action {
            background: #f3f3f3 !important;
        }
        .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th {
            background: none !important;
        }
        .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            background: none !important;
        }
        .shadowremovedatatable .slds-button:focus {
            box-shadow: none;
        }
        .shadowremovedatatable .slds-button:active {
            border: none;
        }
        .shadowremovedatatable .slds-text-link:hover button.slds-button:hover,
        .shadowremovedatatable .slds-text-link:focus button.slds-button:focus {
            text-decoration: none !important;
        }
        .DataTablecontact table tr th:nth-child(6) .slds-th__action .slds-truncate, .DataTablecontact table tr th:nth-last-child(-n) .slds-th__action .slds-truncate{
            display:none;
        }
        .DataTablecontact .slds-grid_vertical-align-center {
            display: flex;
            justify-content: center;
        }
        @media only screen and (max-width:1550px) and (min-width:1480){
            .slds-scrollable_x{
                overflow-x:hidden !important;
            }
        }
        @media only screen and (min-device-width: 1240px) and (max-device-width: 1550px) {
            .slds-table_header-fixed_container.slds-scrollable_x{
                overflow-x: hidden !important;
            }
        }
       `;
       //Commented below CSS by LK on 2024-07-15 to fix 00046306
       /*let showTootil_hide_slds_truncate = document.createElement('style'); //added changes for bug #00041603 fixes by salauddin sheikh
       showTootil_hide_slds_truncate.innerText = `.contactDataTable table tr th:nth-last-child(2) .slds-th__action .slds-truncate{display: none;}
           }`;
           let datatable = this.template.querySelector('lightning-datatable');
           if(datatable){
            datatable.appendChild(showTootil_hide_slds_truncate);
           }*/
        try {
            this.template.querySelector('.main-Container').appendChild(style);
        } catch (err) {
            console.log(err)
        }
    }
    handleApplyFilterInMain() {
        this.filterClk = true;
            const filterComp = this.template.querySelector("c-navatar-add-contacts-filter-fields-lwc");
            if (filterComp) {
                this.filterObj = filterComp.handleApplyFilter();
                if (this.filterObj.filterErrMsg == undefined) {
                    this.fetchWhereClause();
                    this.isSearchSecVisible = true;
                    this.filterdiv = false;
                    this.template.querySelector('.inner-custom-mechanish').classList.remove('displaydiv');  //added for bug #00041581 fixes by salauddin sheikh
                    this.template.querySelector('.inner-custom-mechanish').classList.add('hidediv');        //added for bug #00041581 fixes by salauddin sheikh
                }
            }
       // }
    }
    getConFromAcc(){
        fetchQueryResults({ mainQuery: this.testQuery, existingIdSet: this.existingIdSet, accountData : this.accountData,filterString:  (this.filterObj['filterString'] || '') })
                .then(result => {
                    if (result.status == 'success') {
                        try {
                            this.conVsInteraction = result.ConInteraction; // map for interaction column fixes by salauddin sheikh
                            helper.processResults(this, result.response);
                            if (this.enableLoadMore == true) {
                                this.hitMainQuery();
                            }
                            this.testQuery = '';
                        } catch (err) {
                            helper.showToast(this, 'Error!', err.message, 'error');
                        }
    
                    } else {
                        helper.showToast(this, 'Error!', result.status, 'error');
                    }
                    this.toggleSpinner();
                }).catch(error => {
                    helper.showToast(this, 'Error!', error.body.message, 'error');
                    this.toggleSpinner();
                });
                this.testQuery = '';

    }
    processPostNav() {
        helper.fieldAccessCheck(this);
        helper.prepareQuery(this);
        
        if (this.onLoad) {
            this.onLoad = false;
        }
        this.existingIdSet = [];
        this.hitMainQuery();
        
            if(!this.filterClk){
            this.getConFromAcc();
        }
        
    }
    getNavatarSetupData() {
        this.toggleSpinner();
        fetchNavatarSetup()
            .then(result => {
                if (result.status == 'success') {
                    try {
                        let wrenchFieldVal = result.defaultStringSearch;
                        this.nameSpacePrefix = result.nameSpacePrefix; //for theme redirect fixes by Salauddin Sheikh
                        let val2 = result.defaultStringReview;
                        let defaultFieldstring = wrenchFieldVal.replace('AddInviteTarget:', '');
                        this.columnsToShow = defaultFieldstring.split(',');
                        let defaultFieldstring1 = val2.replace('AddInviteTarget:', '');
                        this.columnsToShow1 = defaultFieldstring1.split(',');
                        let val3 = result.defaultStringDeal;
                        let defaultFieldstring3 = val3.replace('AddInviteTarget:', '');
                        this.columnsReviewContactNew = defaultFieldstring3.split(',');
                       // if (this.allfieldsProcessed) {
                            this.processPostNav();
                     //   }
                    } catch (err) {
                        helper.showToast(this, 'Error!', err.message, 'error');
                    }
                } else {
                    helper.showToast(this, 'Error!', result.status, 'error');
                }
                this.toggleSpinner();
            }).catch(error => {
                helper.showToast(this, 'Error!', error.body.message, 'error');
                this.toggleSpinner();
            });
    }
    fetchWhereClause() {
        this.whereClause = '';
        this.whereCon_Contact = '';
        if (this.filterObj.filterData != undefined) {
            this.toggleSpinner();
            executeQuery1({
                getqueryjson: JSON.stringify(this.filterObj.filterData),
                pageName: 'DAIT',
                FilterString: (this.filterObj.filterString || '')
            })
            .then(result => {
                console.log('where cause-->'+JSON.stringify(result));
                if (result.status == 'success') {
                    if (result.whereClause) {
                        // helper.prepareWhereClause(this, result.whereClause);
                        //start changes for bug #00042408,00042365,00042367 fixes by salauddin sheikh
                           for (let index = 0; index < this.filterObj.filterData.length; index++) { 
                            const filter = this.filterObj.filterData[index];
                            const filterParts = filter.field.split(':');
                            const field = (filterParts[0] != 'Contact') ? 'Contact.'+filterParts[0] :filterParts[0] ;
                            // console.log(filter.Operator + '<------>'+ filter.Value);
                            // console.log((filter.Operator != '') + '=='+(filter.Value != ''));
                            //if(result.whereClause.split(' ')[0] != field+'.'+filterParts[1]){
                              if(filter.Operator != '' || filter.Value != ''){
                                if((filterParts[3] != 'REFERENCE') && (filter.Operator == 'like contain' || filter.Operator == 'not like' || filter.Operator == 'like start' || filter.Operator == 'like end' || (filter.field.split(':')[3] == 'BOOLEAN' && (filter.Value != 'TRUE' || filter.Value != 'FALSE')))){
                                    console.log('inside iff->');
                                    if(filter.Operator == 'like contain'){
                                        this.whereClause = result.whereClause.split(' ')[0]+' Like \'%'+filter.Value+'%\' ';
                                    }
                                    else if(filter.Operator == 'not like'){
                                        this.whereClause = '(NOT '+result.whereClause.split(' ')[0]+' Like \'%'+filter.Value+'%\' )';
                                    }
                                    else if(filter.Operator == 'like start'){
                                        this.whereClause = result.whereClause.split(' ')[0]+' Like \'%'+filter.Value+'%\' ';
                                }
                                    else if(filter.Operator == 'like end'){
                                        this.whereClause = result.whereClause.split(' ')[0]+' Like \'%'+filter.Value+'%\' ';
                                        }
                                    else if(filter.field.split(':')[3] == 'BOOLEAN'){// Bug Fix-00042839 By Harshwardhan 
                                        this.whereClause = (filter.Value.length  != 0) ? result.whereClause.split(' ')[0]+filter.Operator+filter.Value : result.whereClause.split(' ')[0]+filter.Operator+'False';
                                    }
                                }
                                    //start fixes for bug #00041589 fixes by salauddin sheikh
                                else if((filterParts[3] == 'REFERENCE') && (filter.Operator == 'like==' || filter.Operator == '=' || filter.Operator == '!=' || filter.Operator == '>' || filter.Operator == '<' || filter.Operator == '>=' || filter.Operator == '<=' || filter.Operator  == 'like start' || filter.Operator  == 'not like!==' || filter.Operator  == 'IN: ' || filter.Operator  == 'NOT IN: ') ){ // added more condition for bug #00042599 fixes by salauddin sheikh
                                    let updateWhere = '';  //result.whereClause.split(' ')[0];
                                    console.log('check--->'+filterParts[1]);
                                    console.log(result.whereClause.split(' ')[0]);
                                    if(filterParts[1].endsWith('Id')){
                                        updateWhere = field+'.'+filterParts[1].replace(/Id$/, '')+'.Name';
                                        }
                                    else {  
                                        const has__c = filterParts[1].endsWith('__c');
                                        updateWhere = field+'.'+filterParts[1].replace(/__c/g, match => has__c ? '__r' : match)+'.Name';
                                        }
                                    console.log('updated====>'+updateWhere);    
                                    if(filter.Operator == 'like=='){
                                        this.whereClause = updateWhere+' Like \'%'+filter.Value+'%\' ';
                                        }
                                    else if(filter.Operator == '=' || filter.Operator == '!=' || filter.Operator == '>' || filter.Operator == '<' || filter.Operator == '>=' || filter.Operator == '<=' ) {
                                        this.whereClause = updateWhere+' '+filter.Operator+' '+'\''+filter.Value+'\' ';      //change added for bug #00042365 fixes by salauddin sheikh
                                        }
                                    else if(filter.Operator  == 'like start'){
                                        this.whereClause = updateWhere+' Like \'%'+filter.Value+'%\' ';
                                        }
                                    else if(filter.Operator  == 'not like!=='){
                                        this.whereClause = '(NOT '+updateWhere+' Like \'%'+filter.Value+'%\' )';
                                        }
                                        else if(filter.Operator  == 'IN: '){    //condition for bug #00042599 fixes by salauddin sheikh
                                            this.whereClause = updateWhere+' IN '+'('+'\''+filter.Value+'\' '+')';
                                        }
                                        else if(filter.Operator  == 'NOT IN: '){    //condition for bug #00042599 fixes by salauddin sheikh
                                            this.whereClause = updateWhere+' NOT IN '+'('+'\''+filter.Value+'\' '+')';
                                        }
                                    }
                                    //end fixes for bug #00041589 fixes by salauddin sheikh
                                else{
                                    helper.prepareWhereClause(this, result.whereClause);
                                }
                                    }
                            else{
                                const evt = new ShowToastEvent({
                                title: 'Error',
                                variant: 'Error',
                                message: 'Please enter valid field and operator values',
                                mode: 'sticky'
                                });
                                this.dispatchEvent(evt);
                        }
                        }
                        //end changes for bug #00040894 fixes by salauddin sheikh
                    }
                    console.log('where-------->'+this.whereClause);
                    if(this.whereClause != ''){
                        this.getNavatarSetupData();
                    }
                    //   this.getNavatarSetupData();
                    } else {
                        helper.showToast(this, 'Error!', result.status, 'error')
                    }
                        this.toggleSpinner();
                    })
                    .catch(error => {
                        helper.showToast(this, 'Error!', error.body.message, 'error');
                        this.toggleSpinner();
                    });
        } else {
            this.getNavatarSetupData();
        }
    }
    toggleSpinner() {
       this.isLoading = this.isLoading ? false : true;
    }

    dtPicklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data
        if(dataRecieved != null && dataRecieved != undefined){
        for (let i = 0; i < this.sel_SelectedData.length; i++) {
            if(this.sel_SelectedData[i].Id == dataRecieved.context){
                this.sel_SelectedData[i].selectedRole  = dataRecieved.value;
            }
        }
    }
    }

    handleAddToTargetList(event) {
        let sel_allDataList = this.sel_allDataList;
        let selectedIdSet = this.selectedIdSet;
        let allDataList = this.allDataList;
        let contactData = this.contactData; 
        if (this.selectAll) {
            var el = this.selectedRows;
            sel_allDataList = [...sel_allDataList, ...allDataList.filter(val => el.includes(val.Id) && !selectedIdSet.includes(val.Id))];
            selectedIdSet = sel_allDataList.map(val => { return val.Id });
            allDataList = allDataList.filter(val => !el.includes(val.Id));
            contactData = allDataList;  //changes for bug #00041481, #00041485 fixes by salauddin sheikh
        }else {
            var el = this.template.querySelector('[data-id="searchResults"]').selectedRows;
            sel_allDataList = [...sel_allDataList, ...allDataList.filter(val => el.includes(val.Id) && !selectedIdSet.includes(val.Id))];
            selectedIdSet = sel_allDataList.map(val => { return val.Id });
            allDataList = allDataList.filter(val => !el.includes(val.Id));
            contactData = allDataList;  //changes for bug #00041481, #00041485 fixes by salauddin sheikh

        }
            this.selectedIdSet = selectedIdSet;
            this.allDataList = allDataList;
            this.contactData = contactData;
            if(this.sel_SortedBy == 'Name_Contact'){
                this.sel_SortedBy = 'Name';    
            }
             this.sel_allDataList = helper.sortByKey(sel_allDataList, this.sel_SortedBy, this.sel_SortedDirection);
            this.selectAll = false;
            this.selectedRows = [];
            this.sel_SelectedData = this.sel_allDataList;   //changes for bug #00041481, #00041485 fixes by salauddin sheikh

            for (let i = 0; i < this.sel_SelectedData.length; i++) {
                this.sel_SelectedData[i].picklistOptions = this.dealTeamRoleOption;
                this.sel_SelectedData[i].selectedPicklistOptions = this.selectedPicklistOptions;
                this.sel_SelectedData[i].selectedRole= this.selectedPicklistOptions;    //added methos for bug #00041504 fixes by salauddin sheikh
            }

        //}
    }
    fetchAllRecords(e) {
        this.selectedRows = [];
        this.showAllOption = false;
        this.enableLoadMore = true;
        this.selectAll = false;
        this.hitMainQuery();
        e.preventDefault();
        e.stopPropagation();
    }
    get disableAddToTarget() {
        return this.selectedRows.length == 0;
    }
    get disableAddAsTarget() {
        return (this.sel_SelectedData.length == 0 || !this.isEligible);
    }
    get disableButton() {
        return !this.isEligible;
    }
    handleClearFilterInMain() {
        const filterComp = this.template.querySelector("c-navatar-add-contacts-filter-fields-lwc");
        if (filterComp) {
            this.filterObj = filterComp.handleClearFilter();
        } else {
           // this.filterObj = {};
        }
    }
    clickBack(){
        window.close();
    }
    fetchActInfo(event){
        let m = event.detail.action.label.fieldName;  // for bug #00041883 by salauddin sheikh
        console.log(JSON.stringify(event.detail.action));
        if(m == 'Meetings_Custom_label'){
            let header, emptyModalKeyword;
            header = (m === 'timesRef' ? 'All Interactions With ' : 'Meetings & Calls With ') + event.detail.row.Name;
            emptyModalKeyword = m === 'timesRef' ? 'Interactions' : 'Meetings';
            const map = new Map(Object.entries(this.conVsInteraction));  //interaction column fixes by salauddin sheikh
            let convertAcList = map.get(event.detail.row.Id);
            // let compDef = {
            //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
            //     attributes: {
            //         header: header,
            //         actIdList: convertAcList,
            //         namespacePrefix: this.namespacePrefix,
            //         emptyModalKeyword: emptyModalKeyword
            //     }
            // };
            // this.navigateToLwcComp(compDef);

            //Bug Fixed 00045623 by Deepak PE Phase 3
            this[NavigationMixin.GenerateUrl]({
                type: "standard__navItemPage",
                attributes: {
                    apiName: "navpeII_dev18__Interactions",
                },
                state: {
                    c__header: header,
                    c__namespacePrefix: this.namespacePrefix,
                    c__actIdList: convertAcList != undefined ? convertAcList : [],
                    c__emptyModalKeyword: emptyModalKeyword
                },
            }).then(generatedUrl => {
                window.open(generatedUrl,  "_blank");
            });
        }
    }
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
}