import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import init from '@salesforce/apex/NavatarSendEmailContactsCtrl.init';
import fetchNavatarSetupData from '@salesforce/apex/NavatarSendEmailContactsCtrl.fetchNavatarSetupData';
import fetchMainQueryData from '@salesforce/apex/NavatarSendEmailContactsCtrl.fetchMainQueryData';
import getEmailLimit from "@salesforce/apex/NavatarSendEmailContactsCtrl.getEmailLimit";
import sendMassMail from "@salesforce/apex/NavatarSendEmailContactsCtrl.sendMassMail";
import executeQuery1 from "@salesforce/apex/NavatarSendEmailContactsCtrl.executeQuery1";

export default class NavatarEmailContactsLwc extends NavigationMixin(LightningElement){
    
    /******* Common Attributes *******/
    @api recordId;                       // Stores record ID of calling Marketing Initiative record page
    isLoading = false;               // Stores visibility status of spinner
    miName = '';                         // Stores Marketing Initiative name
    namespacePrefix = '';                // Stores namespace prefix
    objName = 'Marketing_Initiative__c'; // Stores object name, to fetch objects's icon info
    currentPage = 'filter';                // Stores the page name for the respective step
    
    /******* Page 1 :- Filter Prospects Page [Filter Prospects Section] Attributes *******/
    bodyIconName = 'utility:chevrondown';// Stores icon name displayed against Filter Prospects
    filterObj = {};                      // Stores the filter data
    isSearchSecVisible = true;           // Stores visibility status of Search for Prospects section
    objApiNamesList;       // Stores api names of objects used in filter component
    recordSelMsg='';

    /******* Page 1 :- Filter Prospects Page [Wrench] Attributes *******/
    defaultFieldList = [];                  // Stores default field's list
    fixedSelFieldsApiName = [];             // Stores fixed selected field's list
    wrenchObjects = [];                     // Stores object's list used in wrench
    recordSelected = false;

    /******* Page 1 :- Filter Prospects Page [Prospects Table Section] Attributes *******/
    allDataList = [];               // Stores complete queried data
    conData = [];                   // Stores queried prospects's data
    fieldList;                              // Stores fields list to be displayed in datatable
    fpErrMsg = 'No items to display';           // Stores error msg to be displayed in datatable
    fpDataTableCols = [];             // Stores datatable's columns info
    fpNonSortableCols = [];           // Stores non sortable columns list
    // fpSortBy = 'Name<@>Contact';        // Stores sort by field name
    // fpSortDirection = 'asc';          // Stores sort direction of field
    showAllOption;                  //to show more than 2k records
    enableLoadMore;                 //to load more data in case of more than 2k records
    @track selectedRows=[];                //selected contacts to send email
    sortBy = '';	
    sortDirection = '';

    /******* Page 2 :- Email Templates Page Attributes ***********/
    selectedTemplate = [];          //stroes selected template
    tempIds=[];                     
    emailPreviewRecipient;

    /******* Page 3 :- Send Email Page Attributes *********/
    bCCMeOnOne = false;             //stores BCC address
    useMySignature = false;         //stores my signature if checked
    storeAsAnActivity = false;       //stores an activity on selected contacts

    /******* Query Attributes *******/
    existingIdSet = new Set();  // Stores IDs of existing prospects in4 Prospects datatable
    ignoreTheseApiNames = ['INDIVIDUALID', 'JIGSAW', 'JIGSAWCOMPANYID', 'JIGSAWCONTACTID', 'MASTERRECORDID']; // Stores api names of fields to be ignored
    ignoreTheseTypes = ['ENCRYPTEDSTRING', 'SYSTEMMODSTAMP', 'JIGSAW'] // Stores field types of fields to be ignored
    mainQuery = '';              // Stores query executed to fetch data for Prospects datatable
    whereClause = '';           // Stores where clause of query

    /******* Search Attributes in datatable*******/
    consearchparam; //entered string
    previousSearch; //previous search string when removing string

    /********* Error Attributes ***********/
    errorInfo;
    filterdiv = false;


    /******* Getters *******/
    get currentpagemsg() {
        //To get page heading when redirecting
        if (this.currentPage == 'filter') {
            return '1. Specify the recipients to include';
        } else if (this.currentPage == 'Email Template') {
            return '2. Select an email template';
        } else {
            return '3. Review and confirm';
        }
    }

    /*Purpose:  Shows Previous Button*/
    get enablePrevious() {
        return this.currentPage == 'filter' ? false : true;
    }
    /*Purpose: Disables the Next Button*/
    get disableNextbutton() {
        if (this.currentPage == 'filter' && this.selectedRows.length==0) {
            return true;
        } else if (this.currentPage == 'Email Template' && this.selectedTemplate == '') {
            return true;
        }
        else return false;
    }

    /* Manages visibility of error message for Prospects datatable */
    get displayRecords(){
        return this.conData.length > 0;
    }

    /* Manages Show All link visibility status */
    get enableShowAll(){
        return this.conData.length > 1999 && this.showAllOption;
        
    }

    get isfilterPage() {
        return this.currentPage == 'filter';
    }
    get istemplatePage() {
        return this.currentPage == 'Email Template';
    }
    get isreviewPage() {
        return this.currentPage == 'Review Page';
    
    }

    get nextbuttonTitle() {
        if (this.currentPage == 'filter' || this.currentPage == 'Email Template')
            return 'Next';
        else
            return 'Send';
    }
    /* Displays record count for Filter Prospects datatable */
    get recCount(){
        return this.conData.length > 1999 && this.showAllOption ? '1999+' : this.conData.length;
    
    }

    /******* Common Methods *******/
   
    connectedCallback(){
        this.isLoading = true;
        if(this.recordId != '' && this.recordId != undefined){
            this.getNamespacePrefix();
        } else {
            this.showToast(this, 'Error', 'Theme ID is required to Email Contacts.', 'error');
        }
        this.recordSelMsg= this.selectedRows.length+' items selected';
        //this.isLoading = false;
    }

    /* Fetches namespaceprefix */
    getNamespacePrefix(){
        init({themeId : this.recordId})
        .then(result => {
            if(result.errMsg == null){
                this.namespacePrefix = result.namespacePrefix;
                this.objName = this.namespacePrefix + this.objName;
                this.miName = result.miName;
                this.objApiNamesList = [`Account`, `Contact`, `${this.namespacePrefix}Theme_Relation__c`];
                this.fixedSelFieldsApiName = [`Contact:Name:Full Name:String`,`${this.namespacePrefix}Theme__c:${this.namespacePrefix}Account_Name__c:Account Name:String`];                
                this.prepareQuery();
                this.hitMainQuery();
            } else {
                this.errorInfo = {
                    'infoTitle': 'Insufficient Permission',
                    'infoMessage': 'You do not have permission to edit this information. Please contact your Navatar Administrator.'
                };
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.showToast(this, 'Error!', error.message, 'error');
        });
    }

    /*Close the popup when the error info popup comes*/ 
    handlePopupClose(){
        const selectedEvent = new CustomEvent("popupclose", {});
        this.dispatchEvent(selectedEvent);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objName,
                actionName: 'view'
            },
        });
    }

    /* Navigates the user to current marketing initiative's record page */
    handleCancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objName,
                actionName: 'view'
            },
        });
    }


    /*set data for all three checkboxs on the review page*/
    handleFormInputChange(event) {
        if (event.target.name == 'BCC') {
            this.bCCMeOnOne = event.target.checked;
        }
        else if (event.target.name == 'Signature') {
            this.useMySignature = event.target.checked;
        }
        else if (event.target.name == 'StoreAct') {
            this.storeAsAnActivity = event.target.checked;
        }
    }
    
    nextSetup() {
        if(this.currentPage == 'Review Page'){
            this.isLoading = true;
            this.sendMail();
        }
        else if(this.selectedRows.length>500){
                const event = new ShowToastEvent({
                    "title": "Error",
                    "message": "Please select less than 500 contacts",
                    "variant": "error",
                    "mode": "sticky"
                });
                this.dispatchEvent(event);
        }
        else{
            this.currentPage = this.currentPage == 'filter' ? 'Email Template' : 'Review Page';
            if(this.currentPage=='Email Template'){
                this.template.querySelector('[data-id="filterpg"]').style.display='none';
            }
        }
    }
    sendMail(){
        var RemainingEmailLimit = 0;
        getEmailLimit()
            .then(result => {
                var limtresult = "";
                limtresult = result.replace(/\&lt\;/g, '<').replace(/\&lt\;/g, '<').replace(/\&gt\;/g, '>').replace(/\&amp\;/g, '&').replace(/&#39;/g, "'").replace(/\&quot\;/g, '"');

                var Maildata = JSON.parse(limtresult);
                RemainingEmailLimit = Maildata['SingleEmail'].Remaining;
                if (RemainingEmailLimit == 0) {
                    const event = new ShowToastEvent({
                        "title": "Error",
                        "message": "Your org has reached the daily limit for sending emails. Please contact your System Administrator.",
                        "variant": "error",
                        "mode": "sticky"
                    });
                    this.dispatchEvent(event);
                    this.isLoading = false;
                }
                else {
                    if (RemainingEmailLimit >= this.selectedRows.length) {
                        sendMassMail({
                            contactList: this.selectedRows,
                            templateId: this.selectedTemplate[0].templateId,
                            bCC_Me_On_One: this.bCCMeOnOne,
                            use_My_Signature: this.useMySignature,
                            Store_as_an_activity: this.storeAsAnActivity
                        })
                            .then(result => {
                                const event = new ShowToastEvent({
                                    "title": "Emails sent successfully",
                                    "message": "The emails have been scheduled in the queue. You will receive an email notification once all the emails have been sent.",
                                    "variant": "success"
                                });
                                this.dispatchEvent(event);
                                
                                this[NavigationMixin.Navigate]({
                                    type: "standard__recordPage",
                                    attributes: {
                                        recordId: this.recordId,
                                        actionName: "view"
                                    }
                                });

                            })
                            .catch(error => {
                                helper.showToast(this, 'Error!', error.message, 'error');
                                this.isLoading  = false;
                            });
                    }
                    else {
                        if (RemainingEmailLimit > 0) {
                            const event = new ShowToastEvent({
                                "title": "Error",
                                "message": "This mass email cannot be sent today as your daily limit has only " + RemainingEmailLimit + " emails remaining. If you are going to send today go back and select " + RemainingEmailLimit + " or fewer recipients.",
                                "variant": "error",
                                "mode": "sticky"
                            });
                            this.dispatchEvent(event);
                            this.isLoading  = false;
                        }
                        else {
                            const event = new ShowToastEvent({
                                "title": "Error",
                                "message": "Your org has reached the daily limit for sending emails. Please contact your System Administrator.",
                                "variant": "error",
                                "mode": "sticky"
                            });
                            this.dispatchEvent(event);
                            this.isLoading = false;
                        }
                    }
                }
            })
            .catch(error => {
                helper.showToast(this, 'Error!', error.message, 'error');
                this.isLoading = false;
            });
    }


    /*function is responsible for handling checkbox Selection for Values against specific field */
    handleRowSelection(event) {
        this.selectedRows = this.template.querySelector('lightning-datatable').selectedRows;        
        this.emailPreviewRecipient = this.selectedRows[0];
        this.recordSelMsg= ''+this.selectedRows.length+' items selected';    
    }
    
    /* Displays toast message */
    showToast(cmp, title, message, variant){
        if(message && message.includes('permission')){
            title = 'Insufficient Permission'
        }
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        cmp.dispatchEvent(event);
    }

    /******* Page 1 :- Filter Prospects Page : Common Methods *******/
    get headerIconName() {
        return this.isSearchSecVisible ? 'utility:chevronright' : 'utility:chevrondown';
    }
    /*control visiblity of fitler*/
    handleSectionToggle(event) {
        this.isSearchSecVisible = !this.isSearchSecVisible;
        this.filterdiv = false; 
        if(this.isSearchSecVisible){
            this.filterdiv = false; 
        }
        else{
            this.filterdiv = true;
        }
    }
    /* this function will be applied whenever user clear any applied or selected filters */
    handleClearFilter(){
        const filterComp = this.template.querySelector("c-navatar-filter-fields-lwc");
        if (filterComp) {
            this.filterObj = filterComp.handleClearFilter();
        }else {
            this.filterObj = {};
        }
    }

    /* this function will be applied whenever user has any filters/Advance filter logic to be applied
        and the logic verification will also be handled within */
    handleApplyFilter() {
        this.isLoading = true;
        const filterComp = this.template.querySelector("c-navatar-filter-fields-lwc");
        if (filterComp) {
            this.filterObj = filterComp.handleApplyFilter();
            if (this.filterObj.filterErrMsg == undefined) {
                this.fetchWhereClause('MEP');                
            }
        }
        this.isLoading = false;
    }
    

    fetchWhereClause(pageName) {
        console.log("Fetch Where Clause");
        this.whereClause = '';
        if (this.filterObj.filterData != undefined) {
            executeQuery1({
                getqueryjson: JSON.stringify(this.filterObj.filterData),
                pageName: pageName,
                FilterString: (this.filterObj.filterString || '')
            })
                .then(result => {
                    if (result.errMsg == null) {
                        if (result.whereClause) {
                            console.log("Fetch Where Clause", result.whereClause);
                            this.whereClause = result.whereClause;
                            //this.getNavatarSetupData();
                            this.prepareQuery();
                            this.hitMainQuery();
                            this.handleSectionToggle();
                        }
                    } /*else {
                        helper.showToast(this, 'Error!', result.status, 'error')
                    }
                    this.toggleSpinner();*/
                    this.isLoading = false;
                })
                .catch(error => {
                    helper.showToast(this, 'Error!', error.body.message, 'error');
                    // this.toggleSpinner();
                    this.isLoading = false;
                });
        } else {
            //this.getNavatarSetupData();
            this.isLoading = false;
        }
    }

    /******* Query Methods *******/

    /* Fetches saved data from config object */
    getNavatarSetupData(){
        fetchNavatarSetupData({namespacePrefix : this.namespacePrefix})
        .then(result => {
            if(result.errMsg == null){
                this.fieldList = result.fieldStr.startsWith('EmailMEP:') ? result.fieldStr.substr(9).split(',') : result.fieldStr.split(',');
                this.defaultFieldList = result.defaultFieldStr.split(',');
                this.prepareQuery();
                this.hitMainQuery();
            } else {
                this.showToast(this, 'Error!', result.errMsg, 'error');    
            }
        })
        .catch(error => {
            this.showToast(this, 'Error!', error.message, 'error');
        });
    }

    /* Prepares main query based on object to be queried */
    prepareQuery(){
        let query = 'SELECT ';
        let whereClause = this.whereClause != undefined ? this.whereClause : '';

        query += (`${this.namespacePrefix}Contact__r.Name, ${this.namespacePrefix}Contact__r.Id, Id , ${this.namespacePrefix}Contact__r.Title,  ${this.namespacePrefix}Contact__r.Email, ${this.namespacePrefix}Contact__r.AccountId, ${this.namespacePrefix}Contact__r.Account.Name, ${this.namespacePrefix}Contact__r.Account.RecordType.Name ` +
                 `FROM ${this.namespacePrefix}Theme_Relation__c ` +
                 `WHERE ` +
                 ` ${this.namespacePrefix}Theme__c='${this.recordId}' ` +
                 ` AND ${this.namespacePrefix}Contact__r.Email !='' ` +
                 (this.whereClause.length > 0 ? `AND (${this.whereClause})` : '') +
                 `ORDER BY ${this.namespacePrefix}Contact__r.Name ASC ` +
                 `LIMIT 2000`);
        this.mainQuery = query;
    }

    /* Hits main query for prospects to filter */
    hitMainQuery(){
        console.log("Query > ", this.mainQuery);
        this.isLoading = true;
        fetchMainQueryData({ 
            mainQuery : this.mainQuery,
            existingIdSet : Array.from(this.existingIdSet)
        })
        .then(result => {
            if(result.errMsg == null){
                this.createTableStruct();
                //if(result.queryResult.length > 0){
                    this.processQueriedRes(result.queryResult);
                //}
                this.isLoading = false;
            } else {
                this.showToast(this, 'Error!', result.errMsg, 'error');
            }
        })
        .catch(error => {
            this.showToast(this, 'Error!', error.message, 'error');
        });
    }

    /* Creates the column structure to be displayed in the Filter Prospects datatable */
    createTableStruct(){
        //this.isPageLoad = false;
        this.fpDataTableCols = [];
        let colsInfo = [
            {label : 'Name', fieldName:'name', type: 'text', sortable: true, objName:'Contact',actualType : 'STRING',fieldApiName:'Name'},
            {label : 'Title', fieldName:'role', type: 'text', sortable: true, objName:'Contact',actualType : 'STRING',fieldApiName:'Title'},
            {label : 'Firm', fieldName:'firm', type: 'text', sortable: true, objName:'Account',actualType : 'STRING',fieldApiName:'Name'},
            {label : 'Firm Type', fieldName:'firm_Type', type: 'text', sortable: true, objName:'Account',actualType : 'STRING',fieldApiName:'RecordType.Name'},
            {label : 'Email', fieldName:'email',type: 'email', sortable: true, objName:'Contact',actualType : 'STRING',fieldApiName:'Email'},

        ];
        let datatableAttributes = new Object();
        datatableAttributes.alignment = 'left';
        this.fpDataTableCols = colsInfo;
    }

    /* Processes the queried data to be displayed in Filter Prospects datatable */
    processQueriedRes(queryRes){
        let existingIdSet = new Set();
        this.isLoading = true;
        let dataList;
        if (this.enableLoadMore) {
            dataList = this.allDataList;
        } else {
            dataList = [];
        }
        var data=[];
        if(queryRes != null){
            queryRes.forEach(rec => {
                var obj = {};
                if(rec[this.namespacePrefix + 'Contact__r'] != undefined){
                    obj.id = rec[this.namespacePrefix + 'Contact__c'];
                    obj.name = rec[this.namespacePrefix + 'Contact__r']['Name'];
                    obj.role = rec[this.namespacePrefix + 'Contact__r']['Title'];                    
                    obj.email = rec[this.namespacePrefix + 'Contact__r']['Email'];

                    if(rec[this.namespacePrefix + 'Contact__r']['AccountId'] != undefined){                        
                        obj.firm = rec[this.namespacePrefix + 'Contact__r']['Account']['Name'];
                        obj.firm_Type = rec[this.namespacePrefix + 'Contact__r']['Account']['RecordType']['Name'];
                    }
                }
                data.push(obj);
            });
        }

        //IMPLEMENT LAZY LOADING
        dataList = [...dataList, ...data];
        this.allDataList = dataList;
        //this.existingIdSet = [...this.existingIdSet, ...existingIdSet];
        this.conData = dataList;
        this.showAllOption = true;
        this.isLoading = false;
    }

    /* Fetches all records on Show All click */
    getAllRecords(event){
        this.showAllOption = false;
    }

    /******* Page 1 :- Filter Prospects Page [Prospects Table Section] Methods *******/

    refreshDataTable(){
        //this.getNavatarSetupData();
    }

    key_Code_Checker(component, event, helper){
        if (component.which == 13){
            var a_Name = this.consearchparam;
            this.handleConSearch();
        }
    }

    /*sets search param on seach box when input value changes */
    setSearchParam(evt) {
        this.consearchparam = evt.detail.value;
        if (this.consearchparam == '') {
            this.resetconSearch();
        }
    }


    /*Purpose: whenever a search contact keyword is reset then need to populate original list*/
    resetconSearch() {
        this.previousSearch='';
        this.consearchparam = '';
        let whereindex = this.mainQuery.indexOf('WHERE');

        let mainQuery = this.mainQuery.substring(0, whereindex) + `WHERE ` +
                 ` ${this.namespacePrefix}Theme__c='${this.recordId}' ` +
                 ` AND ${this.namespacePrefix}Contact__r.Email !='' ` +
                 (this.whereClause.length > 0 ? `AND (${this.whereClause})` : '') +
                 `ORDER BY ${this.namespacePrefix}Contact__r.Name ASC ` +
                 `LIMIT 2000`;
        this.mainQuery = query;
        this.mainQuery = mainQuery;
        this.hitMainQuery();
    }

    handleConSearch(){
        let currentquery = this.mainQuery;
        let whereindex = currentquery.indexOf('WHERE');
        let whereclause = this.gridSearchfilter();
        let finquery = currentquery.substring(0, whereindex + 5) + whereclause +/* ' Id = \'' + this.consearchparam + '\'*/' AND ' + currentquery.substring(whereindex + 5, currentquery.length);
        this.mainQuery = finquery;
        this.hitMainQuery();
    }


    /* prepares the where clause for search parameter */
    gridSearchfilter() {
        try {
            let searchval = this.consearchparam;
            var SearchFields = this.fpDataTableCols;
            searchval = searchval.replace(/'/g, "\\'");
            var createqry = '';
            for (let i in SearchFields) {
                let fieldtype = SearchFields[i].actualType;//.toUpperCase();
                let objname = SearchFields[i].objName;
                let queryname;  // = SearchFields[i].fieldApiName;
                let fieldName = SearchFields[i].fieldApiName;
                if(objname == 'Contact'){
                    queryname = this.namespacePrefix+'Contact__r.'+SearchFields[i].fieldApiName;
                }
                else if(objname == 'Firm'){
                    queryname =  this.namespacePrefix+'Account__r.'+SearchFields[i].fieldApiName  
                }else{
                    queryname = SearchFields[i].fieldApiName;   
                }
                //queryname = this.namespacePrefix+'Contact__r.'+SearchFields[i].fieldApiName;
                
                if (fieldtype == 'CURRENCY' || fieldtype == 'DOUBLE') {
                    var objRegExp = /(^-?\d\d*\.\d\d*$)|(^-?\d\d*$)|(^-?\.\d\d*$)/;    // In this number 2. is a error
                    if (objRegExp.test(searchval) && searchval <= 2147483647) {
                        createqry = createqry + queryname + ' = ' + searchval + ' OR ';
                    }
                }

                else if (fieldtype == 'INT') {
                    var objRegExp = /^\s*-?[0-9]{1,18}\s*$/;        // In this number  is a Integer
                    if (objRegExp.test(searchval) && searchval <= 2147483647) {
                        createqry = createqry + queryname + ' = ' + searchval + ' OR ';
                    }
                }
                else if (fieldtype == 'PERCENT') {
                    var objRegExp = /(^-?\d\d*\.\d\d*$)|(^-?\d\d*$)|(^-?\.\d\d*$)/;
                    if (searchval.indexOf('%') > -1) {
                        searchval = searchval.substring(0, searchval.length - 1);
                    }
                    if (objRegExp.test(serachtext) && searchval <= 2147483647) {
                        createqry = createqry + queryname + ' = ' + searchval + ' OR ';
                    }
                }
                else if (fieldtype == 'MULTIPICKLIST') {
                    createqry = createqry + queryname + ' includes ( \'' + searchval + '\' )  OR ';
                }
                else if (fieldName == 'Email<@>Contact' || fieldName == 'Name<@>Contact') {
                    createqry = createqry + queryname + '  like \'%' + searchval + '%\' OR ';
                }
                else if (fieldtype == 'STRING' && (objname == 'Contact')) {
                    createqry = createqry + queryname + '  like \'%' + searchval + '%\' OR ';
                }
            }
            createqry = '( ' + createqry.substring(0, createqry.lastIndexOf('OR ')) + ' )';
            return createqry;
        }
        catch (err) {
            this.showToast(this, 'Error!', err.message, 'error');
        }
    }

    
    /* Handles Search Prospects datatable sort based on header clicked */
    handleDataTableSort(event){
        console.log("Method Called");
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.conData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.conData = parseData;
    }

    /*handle template select in template component*/
    handletemplateselect(event) {
        this.selectedTemplate = event.detail; 
        this.tempIds=this.selectedTemplate.map(val=>{return val.templateId});
    }

    /*Purpose: changes the currentpage name on previous button click */
    handlePrevious() {
        this.currentPage = this.currentPage == 'Review Page' ? 'Email Template' : 'filter';
        if(this.currentPage=='filter'){
            this.template.querySelector('[data-id="filterpg"]').style.display='';
        }
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.massemailtable .slds-th__action {
            background: #f3f3f3 !important;
            box-shadow: none;
        }
        .massemailtable .slds-has-focus.slds-is-resizable .slds-th__action,
        .massemailtable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .massemailtable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .massemailtable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .massemailtable .slds-is-resizable .slds-th__action:focus,
        .massemailtable .slds-is-resizable .slds-th__action:focus:hover,
        .massemailtable .slds-table th:focus,
        .massemailtable .slds-table th.slds-has-focus,
        .massemailtable .slds-table [role="gridcell"]:focus,
        .massemailtable .slds-table [role="gridcell"].slds-has-focus,
        .massemailtable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th,
        .massemailtable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            box-shadow: none !important;
        }
        .massemailtable .slds-th__action:focus,
        .slds-th__action:hover,
        .massemailtable .slds-table tr:hover {
            box-shadow: none !important;
        }
        .massemailtable .slds-th__action {
            background: #f3f3f3 !important;
        }
        .massemailtable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th {
            background: none !important;
        }
        .massemailtable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            background: none !important;
        }
        .massemailtable .slds-button:focus {
            box-shadow: none;
        }
        .massemailtable .slds-button:active {
            border: none;
        }
        td{
            height: 40px !important; 
        }
        .massemailtable a.slds-th__action.slds-text-link_reset.slds-is-sorted_asc.slds-is-sorted{
            background: none !important;
            box-shadow: none;
            border: none;
        }`;
        this.template.querySelector('.main-Container')?.appendChild(style);
    }
}