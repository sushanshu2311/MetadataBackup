import { LightningElement, api, wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleInteractionsInfo from '@salesforce/apex/NavatarAcuityCtrl.handleInteractionsInfo';
import handleInternalConnInfo from '@salesforce/apex/NavatarAcuityCtrl.handleInternalConnInfo';
import handleExternalConnInfo from '@salesforce/apex/NavatarAcuityCtrl.handleExternalConnInfo';
import handleInteractionsSearch from '@salesforce/apex/NavatarAcuityCtrl.handleInteractionsSearch';
import getDealTeamInfo from '@salesforce/apex/NavatarAcuityCtrl.getDealTeamInfo';
import getContactEmailList from '@salesforce/apex/NavatarAcuityCtrl.getContactEmailList';
import getUserEmailList from '@salesforce/apex/NavatarAcuityCtrl.getUserEmailList';
import getCntCntInteractions from '@salesforce/apex/NavatarAcuityCtrl.getCntCntInteractions';
import getRecName from '@salesforce/apex/NavatarAcuityCtrl.getRecName';//Added by LK on 2024-10-11 to fix 00047757

export default class NavatarAcuityRedirectionLwc extends NavigationMixin(LightningElement) {
    @api ltpId;//Added by LK on 2024-04-08 to open the activity popup from sdg [RESEARCH]
    calledFromSdg = false;//Added by LK on 2024-04-08 to open the activity popup from sdg [RESEARCH]
    
    @api currRecId;//Added by LK on 2024-10-11 to fix 00047757
    @api currRecApiName;//Added by LK on 2024-10-11 to fix 00047757
    @api header = 'All Interactions';
    @api actIdList;
    @api dealList;
    @api namespacePrefix;
    @api emptyModalKeyword = 'All Interactions';
    @api email;
    @api recordId;
    @api objApiName;
    @api showMore = false;
    @api isDealAccessible;//Modified by LK on 20240410 to fix 00044459

    interactionsCount = 0;
    enableSpinner = false;
    errMsg = 'No items to display.';
    noData;
    tableCols = [];
    tableData;
    partialTableData;
    displayFilter = false;
    urlParamsMap = {};
    isFirstTimeCalled = true;
    
    /* Filter Popover : START */
    displayFilterPopup = false;
    popoverCheckedFilterOptionsSet = new Set();
    /* Filter Popover : END */

    /* Toggle : Start */
    internalTableCols = [];
    externalTableCols = [];
    displayToggle = false;
    isInternal = true;
    isExternal = false;
    tabValue = 'Internal';
    internalData;
    externalData;
    queryExternalData = true;
    isRgApiError = false; //Added by LK on 2024-10-07 to fix 00047722
    /* Toggle : End */

    /* Search : Start */
    displaySearch = false;
    /* Search : End */

    /* RG : Start */
    @api emailCallerParam;
    @api mailboxId;
    @api parentEmailId;
    /* RG : End */

    /* CSS class for handling filter and search */
    get rightHeaderClass(){
        return (['All Interactions', 'Interactions'].includes(this.emptyModalKeyword)
               ? 'slds-size_9-of-12'
               : 'slds-size_12-of-12') + ' slds-float_right';
    }

    /* Connections : Tab Switching */
    get optnsInternalExternal() {
        return [
            { label: 'Internal', value: 'Internal' },
            { label: 'External', value: 'External' },
        ];
    }

    /* Filter popover values */
    get popoverValuesMap(){
        switch(this.emptyModalKeyword){
            //Modified label for All, Email & List Email on 2022-09-22 to fix label issue for filter
            case 'All Interactions' :
            case 'Interactions' : return [{'label' : 'All Types', 'value' : 'All', isChecked : true},
                                          {'label' : 'Emails', 'value' : 'Email', isChecked : true},
                                          {'label' : 'Meetings', 'value' : 'Meeting', isChecked : true},
                                          {'label' : 'Calls', 'value' : 'Call', isChecked : true},
                                          {'label' : 'Tasks', 'value' : 'Task', isChecked : true},
                                          {'label' : 'List Emails', 'value' : 'List Email', isChecked : true}//Phase 3 Critical Bug - 00045488 & 00045499
                                         ];
            //Modified label for All on 2022-09-22 to fix label issue for filter
            case 'Meetings' : return [{'label' : 'All Types', 'value' : 'All', isChecked : true},
                                      {'label' : 'Meetings', 'value' : 'Meeting', isChecked : true},
                                      {'label' : 'Calls', 'value' : 'Call', isChecked : true}
                                     ];
            case 'Emails' : return [{'label' : 'All Types', 'value' : 'All', isChecked : true},
                                    {'label' : 'Inbound', 'value' : 'inboundEmails', isChecked : true},
                                    {'label' : 'Outbound', 'value' : 'outboundEmails', isChecked : true},
                                    {'label' : 'Indirect', 'value' : 'indirectEmails', isChecked : true}
                                   ];
        }
    }
    
    /****************************** Page Load Methods : Start ******************************/
    @api isMobile =false;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //Added JSON.stringify(currentPageReference.state) !== '{}' by LK on 2024-04-04 (00044463)
        if(!this.isMobile){
        if(currentPageReference && currentPageReference.state != undefined && JSON.stringify(currentPageReference.state) !== '{}' && currentPageReference.state.c__calledFrom !== 'url'){
            let stateParams = currentPageReference.state;
            this.header = stateParams.c__header;
            this.namespacePrefix = stateParams.c__namespacePrefix;
            this.emptyModalKeyword = stateParams.c__emptyModalKeyword  ? stateParams.c__emptyModalKeyword : this.emptyModalKeyword;
            this.actIdList = stateParams.c__actIdList ? stateParams.c__actIdList.split(',') : '';
            this.email = stateParams.c__email;
            this.recordId = stateParams.c__recordId;
            this.objApiName = stateParams.c__objApiName;
            this.dealList = stateParams.c__dealList ? stateParams.c__dealList.split(',') : '';
            this.isDealAccessible = stateParams.c__isDealAccessible;//Modified by LK on 20240410 to fix 00044459
            this.emailCallerParam = stateParams.c__emailCallerParam;
            this.mailboxId = stateParams.c__mailboxId;
            this.parentEmailId = stateParams.c__parentEmailId;
			}
        }
        if (currentPageReference && this.emptyModalKeyword === 'All Interactions' && currentPageReference.state.hasOwnProperty('c__params')) {
            this.urlParamsMap = JSON.parse(currentPageReference.state.c__params);
        }
        //Added by LK on 2024-04-08 to open the activity popup from sdg [RESEARCH]
        if(currentPageReference && currentPageReference.state != undefined && JSON.stringify(currentPageReference.state) !== '{}' && currentPageReference.state.c__calledFrom === 'url' && this.emptyModalKeyword === 'Interactions'){
            this.calledFromSdg = true;
        }
    }

    isinteractionPage = false;
    isinteractionRecord = false;
    /* Page load operations handling */
    connectedCallback(){
        /*Nikita change*/
        if(this.recordId != undefined){
            this.isinteractionPage = false;
            this.isinteractionRecord = true;
        }else{
            this.isinteractionPage = true;
            this.isinteractionRecord = false;
        }
        /*Nikita change*/
        this.enableSpinner = true;
        let parentThis = this;
        this.template.addEventListener('click',function(e){              
            if(!e.target.closest(".myfilter") && parentThis.popoverFilterCheckbox ){
                parentThis.closeFilterPopover()
            }          
        });
        if(this.emptyModalKeyword === 'All Interactions'){
            this.displayFilter = true;
            this.displayToggle = false;
            this.displaySearch = true;
            this.processInteractionsInfo();
        } else if(this.emptyModalKeyword === 'Connections'){
            this.displayToggle = true;
            this.handleInternalConnInfo();
        } else if(this.emptyModalKeyword === 'Deals'){
            this.getDealTeamInfo();
        } else if(this.emptyModalKeyword === 'Emails'){
            //this.displayFilter = true; commented by Shivam for medium bug 00033997
            if(this.emailCallerParam === 'childIcEmail'){
                this.getUserEmailList();
            } else if(this.emailCallerParam === 'childEcEmail'){
                this.getCntCntInteractions();
            } else {
                this.getContactEmailList();
            }
        } else {
            if(this.emptyModalKeyword === 'Interactions'){
                this.displaySearch = true;
                this.fetchRecName();//Added by LK on 2024-10-11 to fix 00047757
            }
            //To store all values in "popoverCheckedFilterOptionsSet" by default (Default Behavior)
            if(this.popoverValuesMap != undefined){
            for(let index = 0; index < this.popoverValuesMap.length; index++){
                this.popoverCheckedFilterOptionsSet.add(this.popoverValuesMap[index].value);
            }
            }
            this.processInteractionsInfo();
        }
    }

    /****************************** Page Load Methods : End ******************************/

    /****************************** Connections Methods : Start ******************************/

    /* Handles the Connections section tab switching */
    handleTabSwitch(event) {
        this.tabValue = event.detail.value;
        if (this.tabValue === 'Internal') {
            this.isInternal = true;
            this.isExternal = false
        } else if(this.tabValue === 'External') {
            this.isInternal = false;
            this.isExternal = true;
            if(this.queryExternalData){
                //Call Shivam's code for getting SF contacts IDs
                this.handleExternalConnInfo();
                this.queryExternalData = false;
            }
        }
    }

    /* Processes the Internal tab info */
    handleInternalConnInfo(){
        let internalTableCols = [{ label: 'Name', fieldName: 'name', type: 'text', hideDefaultActions: true, sortable: false, cellAttributes:{ class: 'text-black' }},                  
                                  //{ label: 'Last Interaction Date', fieldName: 'lastInteractionDate', initialWidth:160, type: 'button', hideDefaultActions: true, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' }, typeAttributes: { label: { fieldName: 'lastInteractionDate'}, variant:'base', name: 'lastInteractionDate', tooltip: { fieldName: 'lastInteractionDate' }}},
                                  //{ label: 'Interaction Notes', fieldName: 'lastInteractionNote', type: 'button', hideDefaultActions: true, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' }, typeAttributes: { label: { fieldName: 'lastInteractionNote' }, variant:'base', name:'lastInteractionNote', tooltip: { fieldName: 'lastInteractionNote' }}},//commented by shivam bug #00035221
                                  { label: 'Deals', iconName:'utility:user_role', initialWidth: 10, fieldName: 'dealRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor text-black-btn texthover', alignment: 'center' }, typeAttributes: { label: { fieldName: 'dealRef' }, variant: 'base', name: 'dealRef' }},
                                  { label: 'Meetings and Calls', iconName:'utility:event', initialWidth: 10, fieldName: 'meetCallRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor text-black-btn texthover', alignment: 'center' }, typeAttributes: { label: { fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRef'}}
                                 ];
        handleInternalConnInfo({recordId : this.recordId, objApiName: this.objApiName, namespacePrefix: this.namespacePrefix, email: this.email, actIdList : this.actIdList})
        .then((result) => {
            if(result.isEmailDrillDownEnabled){
                internalTableCols.push({ label: 'Emails', iconName:'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor text-black-btn texthover', alignment: 'center' }, typeAttributes: { label: { fieldName: 'emailRef' }, variant: 'base', name: 'emailRef' }});
            } else {
                //Replaced "text-black" with "disabledEDDCss" by LK on 2024-05-17 to fix 00045893
                //Removed "class: 'disabledEDDCss'" by LK on 2024-06-20 to fix 00046471 ; 00046121
                internalTableCols.push({ label: 'Emails', iconName:'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'text', sortable: false, cellAttributes: { alignment: 'center' }});
            }
            this.internalTableCols = internalTableCols;
            //Added if condition and moved existing code inside else condition by Mitul to display error if API is not working
            // if(result.apiError){
            //     this.showToast(this, 'Error!','An Error occurred in API', 'error');
            //     this.enableSpinner = false;
            // } else {
            //Removed the if else condition and added the isRgApiError variable value setting by LK on 2024-10-07 to fix 00047722
            this.isRgApiError = result.apiError === true;
            if(result.conSecDynFieldHeader){
                this.internalTableCols.splice(1, 0, { label: result.conSecDynFieldHeader, fieldName: 'roleRef', type: 'text', hideDefaultActions: true, sortable: false, cellAttributes:{ class: 'text-black' }});
            }
            if(result.conInfoWrapper.length > 0){
                this.internalData = [];
                for(let recInfo of result.conInfoWrapper){
                    this.internalData.push({id: recInfo.recId, name: recInfo.name, roleRef: recInfo.fieldInfo, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, lastInteractionDate: recInfo.lastInteractionDate, lastInteractionNote: recInfo.lastInteractionNote, lastInteractionId: recInfo.lastInteractionId, lastInteractionType: recInfo.lastInteractionType});
                }
                this.internalData.sort(this.sortBy('totalActCount', -1));
            }
            this.enableSpinner = false;
            //}
        })
        .catch((error) => {
            this.internalTableCols = internalTableCols;
            this.showToast(this, 'Error!', error.body.message, 'error');
            this.enableSpinner = false;
        });
    }

    /* Processes the External tab info */
    handleExternalConnInfo(){
        this.enableSpinner = true;
        let externalTableCols = [{ type: 'button', hideDefaultActions: true, fixedWidth: 32, typeAttributes: { iconName: { fieldName: 'downloadIcon' }, variant: 'base', name:'downloadIcon', title:'Add Contact' }},
                                      { label: 'Name', fieldName: 'conRef', hideDefaultActions: true, type: 'url', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular' }, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', tooltip: { fieldName: 'name' }}},
                                      { label: 'Firm', fieldName: 'firmUrl', hideDefaultActions: true, type: 'url', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular slds-is-sorted_asc' }, typeAttributes: {label: {fieldName: 'firmName'}, target: '_blank', tooltip: {fieldName: 'firmName'}}},//added by Shivam
                                      //{ label: 'Last Interaction Date', fieldName: 'lastInteractionDate', initialWidth:160, type: 'button', hideDefaultActions: true, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' }, typeAttributes: { label: { fieldName: 'lastInteractionDate' }, variant:'base' ,name:'lastInteractionDate', tooltip: { fieldName: 'lastInteractionDate' }}},
                                      //{ label: 'Interaction Notes', fieldName: 'lastInteractionNote', initialWidth:160, type: 'button', hideDefaultActions: true, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor' }, typeAttributes: { label: { fieldName: 'lastInteractionNote' }, variant:'base', name: 'lastInteractionNote', tooltip: { fieldName: 'lastInteractionNote' }}},// commented by shivam for #00035221
                                      { label: 'Deals', iconName: 'utility:user_role', initialWidth: 10, fieldName: 'dealRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor texthover', alignment: 'center' }, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name: 'dealRef' }},
                                      { label: 'Meetings and Calls', iconName: 'utility:event', initialWidth: 10, fieldName: 'meetCallRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor texthover', alignment: 'center' }, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name: 'meetCallRef' }}
                                     ];
        handleExternalConnInfo({recordId : this.recordId, objApiName: this.objApiName, namespacePrefix: this.namespacePrefix, email: this.email, actIdList : this.actIdList})//added by shivam RG for defect #00038728
        .then((result) => {//Shivam Removed some else as part of defect #00038728
            if(result.isEmailDrillDownEnabled){
                externalTableCols.push({ label: 'Emails', iconName: 'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor texthover', alignment: 'center' }, typeAttributes: {label: {fieldName: 'emailRef' }, variant: 'base', name: 'emailRef' }});
            } else {
                //Replaced "text-black" with "disabledEDDCss" by LK on 2024-05-17 to fix 00045893
                //Removed "class: 'disabledEDDCss'" by LK on 2024-06-20 to fix 00046471 ; 00046121
                externalTableCols.push({ label: 'Emails', iconName: 'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'text', sortable: false, cellAttributes: { alignment: 'center' }});
            }
            this.externalTableCols = externalTableCols;
            if(result == null || result.apiError){
                this.showToast(this, 'Error!','An Error occurred in API', 'error');
                this.enableSpinner = false;
            } 
            if(result.conSecDynFieldHeader){
                    this.externalTableCols.splice(3, 0, { label: result.conSecDynFieldHeader, fieldName: 'roleRef', type: 'text', hideDefaultActions: true, sortable: false, cellAttributes:{ class: 'text-black' }})
            }
            if(result.conInfoWrapper.length > 0){
                    this.externalData = [];
                    for(let recInfo of result.conInfoWrapper){
                        this.externalData.push({downloadIcon: recInfo.downloadIcon, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList, lastInteractionDate: recInfo.lastInteractionDate, lastInteractionNote: recInfo.lastInteractionNote,
                            lastInteractionId: recInfo.lastInteractionId,
                            firmUrl : recInfo.firmRef,
                            firmName : recInfo.firmName}); //Critical resolved Shivam as part of 35192
                    }
                    this.externalData.sort(this.sortBy('totalActCount', -1));
                }
            this.enableSpinner = false;
        })
        .catch((error) => {
            this.externalTableCols = externalTableCols;
            this.showToast(this, 'Error!', 'An Error occurred in API', 'error');
            this.enableSpinner = false;
        });
    }

    //Added by LK on 202410-07 to fix 00047722
    showErrorMsgPopover(){
        let showDiv = this.template.querySelector('.errorMsgPopover');
        showDiv.classList.remove("slds-hide");
        showDiv.classList.add("slds-show");
    }
    //Added by LK on 202410-07 to fix 00047722
    hideErrorMsgPopover(){
        let showDiv = this.template.querySelector('.errorMsgPopover');
        showDiv.classList.remove("slds-show");
        showDiv.classList.add("slds-hide");
    }

    /****************************** Connections Methods : End ******************************/

    /****************************** Filter Methods : Start ******************************/

    /* Filters the data on the basis of checkboxes checked in filter popover */
    filterData(event){
        this.template.querySelector('[data-id="popoverFilter"]').classList.remove('dash-filter');
        if(event.target.name === 'All'){
            //To filter the data
            if(event.target.checked){
                this.partialTableData = this.tableData;
                for(let index = 0; index < this.popoverValuesMap.length; index++){
                    this.popoverCheckedFilterOptionsSet.add(this.popoverValuesMap[index].value);
                }
            } else {
                this.partialTableData = undefined;
                this.popoverCheckedFilterOptionsSet = new Set();
            }
            //To check/uncheck the checkboxes
            const popoverFilter = this.template.querySelectorAll('[data-id="popoverFilter"]');
            if(popoverFilter){
                for(let index = 0; index < popoverFilter.length; index++){
                    popoverFilter[index].checked = event.target.checked;
                }
            }
        } else {
            if(event.target.checked){
                this.popoverCheckedFilterOptionsSet.add(event.target.name);
                this.partialTableData = this.tableData.filter(rec => this.popoverCheckedFilterOptionsSet.has(rec.type));
                //To not display any data if no filter criteria matches
                if(this.partialTableData.length === 0){
                    //Added if condition on 2022-09-27 to display empty data error message if filtering returns no data
                    this.partialTableData = undefined;
                }
                //To check "All" if all checkboxes other than it are checked
                if(this.popoverValuesMap.length - this.popoverCheckedFilterOptionsSet.size === 1){
                    const popoverFilter = this.template.querySelectorAll('[data-id="popoverFilter"]');
                    if(popoverFilter){
                        popoverFilter[0].checked = true;
                    } else {
                        this.template.querySelector('[data-id="popoverFilter"]').classList.add('dash-filter');	
                    }
                } else {
                    this.template.querySelector('[data-id="popoverFilter"]').classList.add('dash-filter');
                }
            } else {
                this.popoverCheckedFilterOptionsSet.delete("All");
                this.popoverCheckedFilterOptionsSet.delete(event.target.name);
                this.partialTableData = this.popoverCheckedFilterOptionsSet === null
                                        ? undefined
                                        : this.tableData.filter(rec => this.popoverCheckedFilterOptionsSet.has(rec.type));
                //To not display any data if no filter criteria matches
                if(this.partialTableData.length === 0){
                    this.partialTableData = undefined;
                }
                //To uncheck "All" checkbox if any option is unchecked
                const popoverFilter = this.template.querySelectorAll('[data-id="popoverFilter"]');
                if(popoverFilter){
                    popoverFilter[0].checked = false;
                    this.template.querySelector('[data-id="popoverFilter"]').classList.add('dash-filter');
                }
            }
        }
        this.interactionsCount = this.partialTableData && this.partialTableData.length ? this.partialTableData.length : 0;
    }

    /* Shows filter popover */
    showFilterPopover(){
        //Moved code inside if condition on 2022-09-23 to only open filter if it has been closed
        if(!this.displayFilterPopup){
            this.displayFilterPopup = true;
            //To store all values in "popoverCheckedFilterOptionsSet" by default (Default Behavior)
            for(let index = 0; index < this.popoverValuesMap.length; index++){
                this.popoverCheckedFilterOptionsSet.add(this.popoverValuesMap[index].value);
            }
            //Added below line by Lakshya on 2022-09-13 to fix 00031428
            this.partialTableData = this.tableData;
        }
        setTimeout(() => {	
            this.displayFilterPopup = true;	
        });
    }
    
    /* Hides filter popover */
    closeFilterPopover(){
        this.displayFilterPopup = false;
    }

    /****************************** Filter Methods : End ******************************/

    /****************************** Interactions Methods : Start ******************************/

    /* Fetches the record name using the record ID */
    //Added by LK on 2024-10-11 to fix 00047757
    fetchRecName(){
        getRecName({ recId: this.currRecId, recApiName: this.currRecApiName })
        .then((result) => {
            if(result){
                this.header = 'All Interactions With ' + result;
            }
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
            this.enableSpinner = false;
        })
    }

    /* Processes the Interactions info */
    processInteractionsInfo(){
        this.tableCols = [{ label: 'Type', cellAttributes: { iconName: { fieldName: 'iconName' } }, hideDefaultActions: true, initialWidth: 50, typeAttributes: { label: { fieldName: 'type' }, target: '_blank', tooltip: { fieldName: 'type' }}},
                          { label: 'Date', fieldName: 'date', type: 'text', initialWidth: 150, sortable: false, hideDefaultActions: true, class: { fieldName: 'slds-border_left' }},
                          { label: 'Subject', fieldName: 'subjRef', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'subject' }, variant: 'base', tooltip: { fieldName: 'subject' }, name: 'subject'}, cellAttributes: { class: 'text_decor' }},
                          { label: 'Details', fieldName: 'detail', initialWidth: 450, hideDefaultActions: true, type: 'button', typeAttributes: { label: { fieldName: 'detail' }, target: '_blank', variant: 'base', name:'detail', tooltip: { fieldName: 'detail' }, title: { fieldName: 'detail' }}, cellAttributes: { class: 'text-black detail-text' }},
                          { label: 'Participants', fieldName: 'participants', type: 'button', hideDefaultActions: true, variant: 'base', typeAttributes: { label: { fieldName: 'participants' }, variant: 'base', name:'participants', target: '_blank', tooltip: { fieldName: 'participants' }}, cellAttributes: { class: 'text_decor' }},
                          { label: 'Tags', fieldName: 'tags', hideDefaultActions: true, type: 'button', variant: 'base', typeAttributes: { label: { fieldName: 'tags' }, variant: 'base', name:'tags', target: '_blank', tooltip: { fieldName: 'tags' }}, cellAttributes: { class: 'text_decor' }}
                         ];
     this.tableColsmob = [{ label: 'Subject', fieldName: 'subjRef', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'subject' }, variant: 'base', tooltip: { fieldName: 'subject' }, name: 'subjectMob'}, cellAttributes: { class: 'text_decor' }}];                 
        this.handleInteractionsInfo();
    }

    /* Fetches the Interactions info */
    handleInteractionsInfo(){
        if(!(this.emptyModalKeyword !== 'All Interactions' && this.actIdList && this.actIdList.length === 0)){
            let namePrefWithShowMore = this.namespacePrefix+'-'+this.showMore;
            let tskId = [];
            let evtId = [];
            //console.log('this.actIdList',this.actIdList,this.actIdList.length);
            // Bug 00047632 fixed by Sudhanshu on 30-05-2025
            handleInteractionsInfo({actIdList : this.emptyModalKeyword !== 'All Interactions' ? this.actIdList : null, namespacePrefix : namePrefWithShowMore, isAcuity : false})
            .then((result) => {
                console.log('handleInteractionsInfo ===> ', result);
                if(result && result.length > 0){
                    this.interactionsCount = result.length;
                    if(this.showMore){
                        this.showMore = false;
                    }
                    result.sort(this.sortBy('actDateAsLong', -1));
                    this.tableData = [];
                    for(let recInfo of result){
                        let attendeesStr = 'attendees' in recInfo
                                            ? this.createStrWithComma(recInfo['attendees'])
                                            : '';
                        let referencesStr = 'references' in recInfo
                                            ? this.createStrWithComma(recInfo['references'])
                                            : '';
                        this.tableData.push({iconName: recInfo.iconName, type: recInfo.type, date: recInfo.actDate, subject: recInfo.subject, subjRef: '/' + recInfo.actId, detail: recInfo.detail, participants: attendeesStr, tags: referencesStr, participantsInfo: recInfo.attendees, tagsInfo: recInfo.references, priority: recInfo.priority, actOwner: recInfo.actOwner, status: recInfo.status, classification: recInfo.classification,actInfo : recInfo.actInfo});
                        //Added above line & commented below line by LK on 2024-04-08 [RESEARCH] as per discussion with SR
                        //this.tableData.push({iconName: recInfo.iconName, type: recInfo.type, date: recInfo.actDate, subject: recInfo.subject, subjRef: '/' + recInfo.actId, detail: recInfo.detail, participants: attendeesStr, tags: referencesStr, participantsInfo: recInfo.attendees, tagsInfo: recInfo.references, priority: recInfo.priority, actOwner: recInfo.actOwner, status: recInfo.status, classification: recInfo.classification});
                        if(recInfo.actId.substring(0,3) === '00U'){
                            evtId.push(recInfo.actId);
                        }else{
                            tskId.push(recInfo.actId);
                        }
                    }
                    if(this.emptyModalKeyword === 'All Interactions' && (evtId.length === 150 || tskId.length === 150)){
                        this.showMore = true;
                    console.log(this.showMore,404);
                    }
                    this.partialTableData = this.tableData;
                }
                this.displayFilter = this.tableData != undefined;
                this.enableSpinner = false;
            })
            .catch((error) => {
                this.showToast(this, 'Error!', error.body.message, 'error');
                this.enableSpinner = false;
            });
        } else {
            this.enableSpinner = false;
        }
    }

    /* Handles the Interactions info search */
    handleSearch(event){
        if(event.keyCode === 13){
            let searchTerm = event.target.value.trim();
            if(searchTerm.length > 1){
                if(this.emptyModalKeyword === 'All Interactions'){
                    this.enableSpinner = true;
                    handleInteractionsSearch({ searchTerm : searchTerm })
                    .then((result) => {
                        if(result && result.length > 0){
                            result.sort(this.sortBy('actDateAsLong', -1));
                            this.partialTableData = [];
                            for(let recInfo of result){
                                let attendeesStr = 'attendees' in recInfo
                                                    ? this.createStrWithComma(recInfo['attendees'])
                                                    : '';
                                let referencesStr = 'references' in recInfo
                                                    ? this.createStrWithComma(recInfo['references'])
                                                    : '';
                                this.partialTableData.push({iconName: recInfo.iconName, type: recInfo.type, date: recInfo.actDate, subject: recInfo.subject, subjRef: '/' + recInfo.actId, detail: recInfo.detail, participants: attendeesStr, tags: referencesStr, participantsInfo: recInfo.attendees, tagsInfo: recInfo.references, priority: recInfo.priority, actOwner: recInfo.actOwner, status: recInfo.status, classification: recInfo.classification}); //Modified by Anshika Ahuja to show all details in task view popup for Anurag Critical bug #00033690
                            }
                        } else {
                            this.partialTableData = undefined;
                        }
                        this.enableSpinner = false;
                    })
                    .catch((error) => {
                        this.showToast(this, 'Error!', error.body.message, 'error');
                        this.enableSpinner = false;
                    });
                } else {
                    this.partialTableData = [];
                    for(let rec of this.tableData){
                        if((rec['detail'] != undefined && rec['detail'].toLowerCase().includes(searchTerm.toLowerCase()))
                           || (rec['subject'] != undefined && rec['subject'].toLowerCase().includes(searchTerm.toLowerCase()))
                           || rec['participants'].toLowerCase().includes(searchTerm.toLowerCase())
                           || rec['tags'].toLowerCase().includes(searchTerm.toLowerCase())){
                            this.partialTableData.push(rec);
                           }
                    }
                    if(this.partialTableData.length === 0){
                        //Added if condition on 2022-09-27 to display empty data error message if filtering returns no data
                        this.partialTableData = undefined;
                    }
                }
                
            } else {
                this.showToast(this, 'Error!','Your search term must have 2 or more characters.', 'error');
            }
        } else if(event.target.value.length === 0) {
            this.partialTableData = this.tableData;
        }
    }

    /* Handles count click operations */
    handleRowAction(event){
        if(event.detail.action.name === 'downloadIcon' && this.tabValue == 'External'){
            const modalPopup = this.template.querySelector('c-navatar-acuity-ext-connection-add-popup-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention
                modalPopup.email = event.detail.row.email;
                // const myName = event.detail.row.name.split(" ");//added by shivam
                // modalPopup.lastNameValue = myName[1];
                //Logic updated by LK on 2024-08-01 to fix 00046613
                const recName = event.detail.row.name.trim();
                if(recName.includes('@')){
                    modalPopup.lastNameValue = recName.split("@")[0];
                } else {
                    let lastIndexOfSpace = recName.lastIndexOf(' ');
                    modalPopup.firstNameValue = recName.substring(0, lastIndexOfSpace).trim();
                    modalPopup.lastNameValue = recName.substring(lastIndexOfSpace + 1).trim();
                }
                modalPopup.openModal();
        
        } else if(event.detail.action.name === 'participants'){
            //Above condition is for opening the tagged info modal for participants
            if(event.detail.row.participantsInfo != undefined){
                const modalPopup = this.template.querySelector('c-navatar-acuity-interaction-column-popup-lwc'); //Modified by Anshika Ahuja W.R.To Naming Convention
                modalPopup.associatesWrapper = event.detail.row.participantsInfo;
                modalPopup.openModal();
            }
        } else if(event.detail.action.name === 'tags'){
            //Above condition is for opening the tagged info modal for participants
            if(event.detail.row.tagsInfo != undefined){
                const modalPopup = this.template.querySelector('c-navatar-acuity-interaction-column-popup-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention
                modalPopup.associatesWrapper = event.detail.row.tagsInfo;
                modalPopup.openModal();
            }
        } else if(event.detail.action.name === 'meetCallRef'){
            // let compDef = {
            //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
            //     attributes: {
            //         header: 'Meetings & Calls With ' + event.detail.row.name,
            //         actIdList: event.detail.row.actIdsList != undefined ? event.detail.row.actIdsList : [],
            //         namespacePrefix: this.namespacePrefix,
            //         emptyModalKeyword: 'Meetings'
            //     }
            // };
            // this.navigateToLwcComp(compDef);

            this[NavigationMixin.GenerateUrl]({
                type: "standard__navItemPage",
                attributes: {
                    apiName: "navpeII_dev18__Interactions",
                },
                state: {
                    c__header: 'Meetings & Calls With ' + event.detail.row.name,
                    c__actIdList: event.detail.row.actIdsList != undefined ? event.detail.row.actIdsList : [],
                    c__namespacePrefix: this.namespacePrefix,
                    c__emptyModalKeyword: 'Meetings'
                },
            }).then(generatedUrl => {
                window.open(generatedUrl,  "_blank");
            });
        } else if(event.detail.action.name === 'subject'){
            //Above condition is for opening the tagged info modal for participants
            if(event.detail.row != undefined){
                this.setGridDataIndex();
                let selectedData = event.detail.row;
                const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention// Additional changes by anurag For bug Id 00039198
                modalPopup.openModalNew(selectedData, this.partialTableData);
            }
        }else if(event.detail.action.name === 'subjectMob'){
            //Above condition is for opening the tagged info modal for participants
            let selectedData = JSON.parse(JSON.stringify(event.detail.row));
                var compDefinition = {
                    componentDef: "navpeII_dev18:navatarAllInteractionsViewModalMobileLwc",
                    attributes: {
                    propertyValue: "100"
                    },
                    state:{//c__selectedData : selectedData,
                        //c__tableData : this.tableData,
                        c__recordId : selectedData && selectedData.subjRef.substring(1),
                        c__objectType : selectedData && ["Event", "Meeting"].includes(selectedData.type) ? "Event" : "Task",
                        c__componentName : 'view'+'@@@@'+this.recordId //Modified by Anshika Ahuja W.R.To send parent record id for Anurag bug ID '00034568'
                    }
                    };
                    // Base64 encode the compDefinition JS object
                    var encodedCompDef = btoa(JSON.stringify(compDefinition));
                    this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                    url: '/one/one.app#' + encodedCompDef
                    }
                    });
            
        }else if(event.detail.action.name === 'dealRef'){
            //Modified by LK on 20240410 to fix 00044459
            if(this.isDealAccessible === true || this.isDealAccessible === "true"){
                // let compDef = {
                //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
                //     attributes: {
                //         header: 'Deals With ' + event.detail.row.name,
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
                        c__header: 'Deals With ' + event.detail.row.name,
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
        } else if(event.detail.action.name === 'emailRef'){
            // let compDef = {
            //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
            //     attributes: {
            //         header: `Emails With ${event.detail.row.name}`,
            //         namespacePrefix: this.namespacePrefix,
            //         emptyModalKeyword: 'Emails',
            //         email: event.detail.row.email,
            //         emailCallerParam: this.tabValue === 'Internal' ? 'childIcEmail' : 'childEcEmail',
            //         mailboxId: event.detail.row.mailboxId,
            //         parentEmailId: this.email
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
                    c__email: event.detail.row.email,
                    c__emailCallerParam: this.tabValue === 'Internal' ? 'childIcEmail' : 'childEcEmail',
                    c__mailboxId: event.detail.row.mailboxId,
                    c__parentEmailId: this.email
                },
            }).then(generatedUrl => {
                window.open(generatedUrl,  "_blank");
            });

        } else if(event.detail.action.name === 'to'){
            const modalPopup = this.template.querySelector('c-navatar-acuity-interaction-column-popup-lwc'); //Modified by Anshika Ahuja W.R.To Naming Convention
            modalPopup.associatesWrapper = event.detail.row.toReferences;
            modalPopup.openModal();
        } else if(event.detail.action.name === 'cc'){
            const modalPopup = this.template.querySelector('c-navatar-acuity-interaction-column-popup-lwc'); //Modified by Anshika Ahuja W.R.To Naming Convention
            modalPopup.associatesWrapper = event.detail.row.ccReferences;
            modalPopup.openModal();
        } else if(['lastInteractionDate', 'lastInteractionNote'].includes(event.detail.action.name)){
            const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention  // Additional changes by anurag For bug Id 00039179
            modalPopup.openModalSingleComponent(event.detail.row.lastInteractionId, event.detail.row.lastInteractionType, 'view');
        }
    }

    setGridDataIndex() {
        for(var d in this.partialTableData) {
            this.partialTableData[d].index = d;
        }
    }

    /****************************** Interactions Methods : End ******************************/

    getDealTeamInfo(){
        getDealTeamInfo({dealList : this.dealList, namespacePrefix: this.namespacePrefix})
        .then((result) => {
            //Replaced static labels with dynamic labels by LK on 2024-10-15 to fix 00047795
            this.tableColsmob = [{ label: result.fieldHeader1,  fieldName: 'dealUrl',  type: 'url',  hideDefaultActions: true, sortable: false, typeAttributes: {label: { fieldName: 'dealName'}, variant: 'base', target: '_blank', name:'call', tooltip: { fieldName: 'dealName' }}},//Deal
                              { label: result.fieldHeader2, fieldName: 'compUrl', type: 'url', hideDefaultActions: true, sortable: false, typeAttributes: {label: {fieldName: 'compName', },  variant: 'base',name:'call', target: '_blank', tooltip: {fieldName: 'compName'}}}]//Company
            //Replaced static labels with dynamic labels by LK on 2024-10-15 to fix 00047795
            this.tableCols = [{ label: result.fieldHeader1,  fieldName: 'dealUrl',  type: 'url',  hideDefaultActions: true, sortable: false, typeAttributes: {label: { fieldName: 'dealName'}, variant: 'base', target: '_blank', name:'call', tooltip: { fieldName: 'dealName' }}},//Deal
                              { label: result.fieldHeader2, fieldName: 'compUrl', type: 'url', hideDefaultActions: true, sortable: false, typeAttributes: {label: {fieldName: 'compName', },  variant: 'base',name:'call', target: '_blank', tooltip: {fieldName: 'compName'}}},//Company
                              { label: result.fieldHeader4, fieldName: 'date', initialWidth:145, type: 'text', hideDefaultActions: true, sortable: false},//Date Received
                              { label: result.fieldHeader3, fieldName: 'stage',initialWidth: 145,hideDefaultActions: true,type: 'button', typeAttributes: { label: { fieldName: 'stage' }, target: '_blank',variant: 'base',name:'stage', tooltip: { fieldName: 'stage' }, title: { fieldName: 'stage' }}, cellAttributes:{ class: 'text-black detail-text'}},//Stage
                              { label: result.fieldHeader5, fieldName: 'SourcefirmUrl', type: 'url', hideDefaultActions: true, sortable: false,typeAttributes: {label: {fieldName: 'Sourcefirm', }, target: '_blank',  tooltip: {fieldName: 'Sourcefirm'}}},//Source Firm
                              { label: result.fieldHeader6, fieldName: 'SourcecontactUrl', type: 'url', hideDefaultActions: true, sortable: false,typeAttributes: {label: {fieldName: 'Sourcecontact', }, target: '_blank', tooltip: {fieldName: 'Sourcecontact'}}},//Source Contact
            ];
            if(result.dealsDataList.length > 0){
                this.tableData = [];
                for(let recInfo of result.dealsDataList){
                    this.tableData.push({dealUrl: '/'+recInfo.fieldInfo1.nameRef,
                        dealName : recInfo.fieldInfo1.name, compName : recInfo.fieldInfo2.name == null ? '' : recInfo.fieldInfo2.name,
                        compUrl : recInfo.fieldInfo2.nameRef == null ? '' : '/'+recInfo.fieldInfo2.nameRef, 
                        stage: recInfo.fieldInfo3.name == null ? '' : recInfo.fieldInfo3.name,
                        date : recInfo.fieldInfo4.name == null ? '' : recInfo.fieldInfo4.name,
                        SourcefirmUrl: recInfo.fieldInfo5.nameRef == null ? '' : '/'+recInfo.fieldInfo5.nameRef, 
                        Sourcefirm : recInfo.fieldInfo5.name == null ?'': recInfo.fieldInfo5.name,
                        SourcecontactUrl: recInfo.fieldInfo6.nameRef == null ? '' : '/'+recInfo.fieldInfo6.nameRef, 
                        Sourcecontact : recInfo.fieldInfo6.nameRef == null ? '' : recInfo.fieldInfo6.name})
                }
                this.partialTableData = this.tableData;
            }
            this.enableSpinner = false;
        })
        .catch(error=>{
            this.showToast(this, 'Error!', error.body.message, 'error');
            this.enableSpinner = false;
        });
    }

    getContactEmailList(){
        this.tableCols = [{ label: 'Category', hideDefaultActions: true, initialWidth:150, type: 'button', sortable: false, fieldName: 'activityCategoryLabel', cellAttributes: { class: 'category-col text-black'}, typeAttributes: { label: { fieldName: 'activityCategoryLabel' },variant: 'base',tooltip: { fieldName: 'activityCategoryLabel' }, title: { fieldName: 'activityCategoryLabel' }}},
                          { label: 'Date', fieldName: 'sendEmailDate', type: 'text', initialWidth: 110, sortable: false, hideDefaultActions: true, cellAttributes: { class: 'Date-col'}},
                          { label: 'Subject', fieldName: 'activityId', type: 'url', initialWidth: 450, hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'subject' }, variant: 'base', name: 'call', tooltip: { fieldName: 'subject' }}, cellAttributes: { class: 'subject-col'}},
                          { label: 'To', fieldName: 'toEmailNames', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'toEmailNames' }, variant: 'base', name: 'to', tooltip: { fieldName: 'toEmailNames' }, target: '__blank'}, cellAttributes: { class: 'text-href'}},
                          { label: 'CC', fieldName: 'ccEmailNames', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'ccEmailNames', }, variant: 'base', name: 'cc', tooltip: { fieldName: 'ccEmailNames' }, target:'__blank'}, cellAttributes: { class: 'to-cc text-href'}}
                         ];
        getContactEmailList({conEmail : this.email, namespacePrefix : this.namespacePrefix, requestBody:''})
        .then(result => {
            if(result){
                result = result.length === 0 ? undefined : result;
                this.tableData = [];
                this.tableData =  result;
                if(result && result.length > 0){
                    this.displayFilter = true; //added by shivam for medium bug 00033997
                    this.tableData.sort(this.sortBy("longDateTime",-1));//Added to fix 00032369 by LK
                    this.partialTableData = this.tableData;
                }
            }
            this.enableSpinner = false;
        })
        .catch(error=>{
            //Added if condition and moved existing code inside else condition by Mitul to display error if API is not working
            if(error.status!=200){
                this.showToast(this, 'Error!',' An Error occurred in API', 'error'); // message changed by shivam
                this.enableSpinner = false;
            } else {
                this.showToast(this, 'Error!', error.body.message, 'error');
                this.enableSpinner = false;
            }
        });
    }

    getUserEmailList(){
        this.tableCols = [{ label: 'Category', hideDefaultActions: true, initialWidth:150, type: 'button', sortable: false, fieldName: 'activityCategoryLabel', cellAttributes: { class: 'category-col text-black'}, typeAttributes: { label: { fieldName: 'activityCategoryLabel' },variant: 'base',tooltip: { fieldName: 'activityCategoryLabel' }, title: { fieldName: 'activityCategoryLabel' }}},
                          { label: 'Date', fieldName: 'sendEmailDate', type: 'text', initialWidth: 110, sortable: false, hideDefaultActions: true, cellAttributes: { class: 'Date-col'}},
                          { label: 'Subject', fieldName: 'activityId', type: 'url', initialWidth: 450, hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'subject' }, variant: 'base', name: 'call', tooltip: { fieldName: 'subject' }}, cellAttributes: { class: 'subject-col'}},
                          { label: 'To', fieldName: 'toEmailNames', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'toEmailNames' }, variant: 'base', name: 'to', tooltip: { fieldName: 'toEmailNames' }, target: '__blank'}, cellAttributes: { class: 'text-href'}},
                          { label: 'CC', fieldName: 'ccEmailNames', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'ccEmailNames', }, variant: 'base', name: 'cc', tooltip: { fieldName: 'ccEmailNames' }, target:'__blank'}, cellAttributes: { class: 'to-cc text-href'}}
                         ];
        getUserEmailList({userEmail : this.parentEmailId, namespacePrefix : this.namespacePrefix, mailboxId: this.mailboxId})
        .then(result => {
            if(result){
                result = result.length === 0 ? undefined : result;
                this.tableData = [];
                this.tableData =  result;
                if(result && result.length > 0){
                    this.displayFilter = true; //added by shivam for medium bug 00033997
                    this.tableData.sort(this.sortBy("longDateTime",-1));//Added to fix 00032369 by LK
                    this.partialTableData = this.tableData;
                }
            }
            this.enableSpinner = false;
        })
        .catch(error=>{
            //Added if condition and moved existing code inside else condition by Mitul to display error if API is not working
            if(error.status!=200){
                this.showToast(this, 'Error!',' An Error occurred in API', 'error'); // message changed by shivam
                this.enableSpinner = false;
            } else {
                this.showToast(this, 'Error!', error.body.message, 'error');
                this.enableSpinner = false;
            }
        });
    }

    getCntCntInteractions(){
        getCntCntInteractions({withCntEmail : this.email, cntEmail : this.parentEmailId})
        .then(result => {
            this.tableCols = [{ label: 'Category', hideDefaultActions: true, initialWidth:150, type: 'button', sortable: false, fieldName: 'activityCategoryLabel', cellAttributes: { class: 'category-col text-black'}, typeAttributes: { label: { fieldName: 'activityCategoryLabel' },variant: 'base',tooltip: { fieldName: 'activityCategoryLabel' }, title: { fieldName: 'activityCategoryLabel' }}},
                              { label: 'Date', fieldName: 'sendEmailDate', type: 'text', initialWidth: 110, sortable: false, hideDefaultActions: true, cellAttributes: { class: 'Date-col'}},
                              { label: 'Subject', fieldName: 'activityId', type: 'url', initialWidth: 450, hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'subject' }, variant: 'base', name: 'call', tooltip: { fieldName: 'subject' }}, cellAttributes: { class: 'subject-col'}},
                              { label: 'To', fieldName: 'toEmailNames', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'toEmailNames' }, variant: 'base', name: 'to', tooltip: { fieldName: 'toEmailNames' }, target: '__blank'}, cellAttributes: { class: 'text-href'}},
                              { label: 'CC', fieldName: 'ccEmailNames', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'ccEmailNames', }, variant: 'base', name: 'cc', tooltip: { fieldName: 'ccEmailNames' }, target:'__blank'}, cellAttributes: { class: 'to-cc text-href'}}
                            ];
            if(result){
                result = result.length === 0 ? undefined : result;
                this.tableData = [];
                this.tableData =  result;
                if(result && result.length > 0){
                    this.displayFilter = true; //added by shivam
                    this.tableData.sort(this.sortBy("longDateTime",-1));//Added to fix 00032369 by LK
                    this.partialTableData = this.tableData;
                }
            }
            this.enableSpinner = false;
        })
        .catch(error=>{
            //Added if condition and moved existing code inside else condition by Mitul to display error if API is not working
            if(error.status!=200){
                this.showToast(this, 'Error!',' An Error occurred in API', 'error'); // message changed by shivam
                this.enableSpinner = false;
            } else {
                this.showToast(this, 'Error!', ' An Error occurred in API', 'error');
                this.enableSpinner = false;
            }
        });
    }

    showMoreInteraction(){
        console.log('@@ ',this.showMore);
        this.enableSpinner = true;
        this.handleInteractionsInfo();
        this.showMore = false;
        // let compDef = {
        //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
        //     attributes: {
        //         header: 'All Interactions',
        //         namespacePrefix: this.namespacePrefix,
        //         emptyModalKeyword: 'All Interactions',
        //         showMore:true
        //     }
        // };
        // this.navigateToLwcComp(compDef);
    }

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

    /* Creates the comma separated string using the record name list */
    createStrWithComma(recList){
        let strWithComma = '';
        for(let rec of recList){
            strWithComma += rec.name + ',';
        }
        strWithComma = strWithComma.slice(0, strWithComma.length - 1);
        return strWithComma;
    }
    
    /****************************** Common Methods : End ******************************/

    /* This function is used for styling */
    renderedCallback() {
        //Added by LK on 2024-04-08 to open the activity popup from sdg [RESEARCH]
        if(this.calledFromSdg){
            const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');
            if(modalPopup && this.isFirstTimeCalled){
                //findMatchingLtpData
                if(Array.isArray(this.partialTableData) && this.partialTableData.length > 0){
                    this.setGridDataIndex();
                    let selectedData = this.partialTableData.find(actData => actData.subjRef === ('/' + this.ltpId));
                    modalPopup.openModalNew(selectedData, this.partialTableData);
                    this.isFirstTimeCalled =  false;
                }
            }
        }

        if(this.emptyModalKeyword === 'All Interactions'){
            const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention //Changes y anurag For resolving bug 00039179
            if(modalPopup && this.isFirstTimeCalled && this.urlParamsMap.hasOwnProperty('recId')){
                modalPopup.openModalSingleComponent(this.urlParamsMap['recId'], this.urlParamsMap['recType'], this.urlParamsMap['mode']);
                this.isFirstTimeCalled = false;
            }
        }
        const style = document.createElement('style');
        style.innerText = `{
            .tab-ht .slds-table td:last-child{
                color: #585858; 
                height:41px;
        }`;
        let lineClamp = document.createElement('style');
        let SubjectlineClamp = document.createElement('style');
        let butnText = document.createElement('style');     
        let showTootil_hide_slds_truncate = document.createElement('style');
        showTootil_hide_slds_truncate.innerText = '.viewallScreen_icon table tr th:nth-last-child(-n+3) .slds-th__action .slds-truncate{display: none}';  
        butnText.innerText = `.radioBtnsInterExter .slds-radio_button__label {
            background: #787878;
            color: #fff;
        }
        .viewallScreen .slds-button {
               text-align: left;
               line-height: 18px;
               white-space: nowrap;
               text-overflow: ellipsis;
               max-width: 100%;
               display: block;
               overflow: hidden;
        }
        .viewallScreen .slds-table_bordered tbody td, .slds-table_bordered tbody th, .slds-table--bordered tbody td, .slds-table--bordered tbody th{
               height: 41px !important;
        }
        @media (max-width:600px){
            .viewallScreen .slds-table_bordered tbody td, .slds-table_bordered tbody th, .slds-table--bordered tbody td, .slds-table--bordered tbody th, .slds-table td{
                font-size:12px !important;
                font-weight:normal !important;
            }
            .viewallScreen .slds-button{
                font-size:12px !important;
            }
            .viewallScreen .slds-table td{
                font-size:12px !important;
                font-weight:normal !important;
            }
            /*Fixed by raju on dated 16-07-2024 00046388, 00046390*/
            .main-Container-alltheme.slds-theme_shade{
                background-color: inherit !important;
            }
        }
        .text-black button.slds-button{
            color: inherit !important;
            white-space: nowrap;
            text-overflow: ellipsis;
            max-width: 100%;
            display: block;
            overflow: hidden;
            border: none;
        }
        .text_decor:hover{
            text-decoration : underline;
            color:#355d96;
        }
        .detail-text button.slds-button{
            cursor:text;
        }
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .viewallScreen .slds-is-resizable .slds-th__action:focus,
        .viewallScreen .slds-is-resizable .slds-th__action:focus:hover,
        .viewallScreen .slds-table th:focus,
        .viewallScreen .slds-table th.slds-has-focus,
        .viewallScreen .slds-table [role="gridcell"]:focus,
        .viewallScreen .slds-table [role="gridcell"].slds-has-focus,
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover > td,
        .viewallScreen .slds-button:focus, .slds-th__action:focus, .slds-th__action:hover,
        .viewallScreen .slds-table tr:hover{
            box-shadow: none !important;
        } 
        .viewallScreen .slds-th__action:focus, .slds-th__action:hover{
            background: #f3f3f3 !important;
            box-shadow:none !important; 
        }
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>td,
        .viewallScreen .slds-table_header-fixed tbody tr td, .viewallScreen .slds-table_header-fixed tbody tr th, .viewallScreen .slds-table--header-fixed tbody tr td, .viewallScreen .slds-table--header-fixed tbody tr th,
        .tablecolorshadow_css_mob  .slds-table:not(.slds-no-row-hover) tbody tr:hover>td,
        .tablecolorshadow_css_mob  .slds-table_header-fixed tbody tr td, .tablecolorshadow_css_mob  .slds-table_header-fixed tbody tr th, .tablecolorshadow_css_mob  .slds-table--header-fixed tbody tr td, .tablecolorshadow_css_mob  .slds-table--header-fixed tbody tr th{
            background: none !important;
            box-shadow:none !important; 
        }
        .viewallScreen tr.slds-hint-parent, .viewallScreen tr.slds-hint-parent:hover{
            background: #fff !important; 
        }
        .viewallScreen .slds-table tbody tr.slds-is-selected>td, .slds-table tbody tr.slds-is-selected>th,
        .tablecolorshadow_css_mob .slds-table tbody tr.slds-is-selected>td, .slds-table tbody tr.slds-is-selected>th{
            box-shadow: none !important;   
        }
        .viewallScreen td.slds-text-body_regular:hover, .viewallScreen td.slds-text-body_regular:focus, .viewallScreen .slds-table tbody tr.slds-is-selected>td:hover, .slds-table tbody tr.slds-is-selected>th:hover{
            box-shadow: none !important;
        }
        .tablecolorshadow_css_mob .slds-table th:focus, .tablecolorshadow_css_mob .slds-table th.slds-has-focus, .tablecolorshadow_css_mob .slds-table [role=gridcell]:focus, .tablecolorshadow_css_mob .slds-table [role=gridcell].slds-has-focus, .tablecolorshadow_css_mob .slds-has-focus .slds-th__action, .viewallScreen .slds-table th:focus, .viewallScreen .slds-table th.slds-has-focus, .viewallScreen .slds-table [role=gridcell]:focus, .viewallScreen .slds-table [role=gridcell].slds-has-focus, .viewallScreen .slds-has-focus .slds-th__action{
            box-shadow:none !important;
            background-color:#f3f3f3;
        }
        .viewallScreen span.slds-th__action, .viewallScreen span.slds-th__action:hover,.viewallScreen span.slds-th__action:focus ,.viewallScreen slds-th__action:focus, .viewallScreen .slds-th__action:hover{
            background-color:#f3f3f3;
        }
        .viewallScreen .slds-button:active{
            border:none;
        }
        .texthover button.slds-button{
            text-decoration:none !important;
        }
        .texthover button.slds-button:hover, .texthover button.slds-button:active{
            text-decoration:none !important;
        }
        .tablecolorshadow_css_mob .slds-scrollable_y{ overflow-y: auto !important; } 
        .tablecolorshadow_css_mob .slds-th__action{ background: #f3f3f3 !important; box-shadow: none; } 
        .tablecolorshadow_css_mob .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table--bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table--bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>td:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table_bordered:not(.slds-no-row-hover) tbody tr:focus>th:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>td:not(.slds-has-focus), 
        .tablecolorshadow_css_mob .slds-table_bordered:not(.slds-no-row-hover) tbody tr:hover>th:not(.slds-has-focus) { 
            box-shadow: none;
        } 
        .tablecolorshadow_css_mob .slds-table tbody tr.slds-is-selected>td, 
        .tablecolorshadow_css_mob .slds-table tbody tr.slds-is-selected>th{ 
            background-color: #e9e8e83d !important;
       }
       .con-data-tble .slds-grid_vertical-align-center{
            display: flex;
            align-items: center;
            justify-content: center;
       }
       .dash-filter:before{               
            content: '';
            display: block;
            width: var(--lwc-squareIconXSmallContent,0.5rem);
            height: 2px;
            border: 0;
            transform: translate3d(-50%, -50%, 0);
            background: var(--slds-c-checkbox-mark-color-foreground, var(--sds-c-checkbox-mark-color-foreground, var(--lwc-brandAccessible,rgb(1, 118, 211))));
            position: relative;
            top: 15px;
            left: 8px;
            z-index: 2;                          
        }
        `;

        // ui change after removing last touch point to truncate deal metting email count 10feb, By Shivam as part of 35221
        let childIndexInter = this.internalTableCols.length === 5 ? 3 : 4;
        let childIndexExter = this.externalTableCols.length === 6 ? 4 : 5;
        //Added "disabledEDDCss" CSS by LK on 2024-05-17 to fix 00045893
        //Commented "disabledEDDCss" CSS by LK on 2024-06-20 to fix 00046471 ; 00046121
        showTootil_hide_slds_truncate.innerText = `.companyTableInter table tr th:nth-child(${childIndexInter}) .slds-th__action .slds-truncate{
            display: none;
        }
        .companyTableInter table tr th:nth-child(${childIndexInter + 1}) .slds-th__action .slds-truncate{
            display: none;
        }
        .companyTableInter table tr th:nth-child(${childIndexInter + 2}) .slds-th__action .slds-truncate{
            display: none;
        }
        .companyTableExter table tr th:nth-child(${childIndexExter}) .slds-th__action .slds-truncate{
            display: none;
        }
        .companyTableExter table tr th:nth-child(${childIndexExter + 1}) .slds-th__action .slds-truncate{
            display: none;
        }
        .companyTableExter table tr th:nth-child(${childIndexExter + 2}) .slds-th__action .slds-truncate{
            display: none;
        }
        /*.disabledEDDCss{
            cursor: default !important;
            color: #0176D3;
        }*/`;
        
        this.template.querySelector('lightning-datatable').appendChild(butnText);
        this.template.querySelector('lightning-datatable').appendChild(lineClamp);
        this.template.querySelector('lightning-datatable').appendChild(SubjectlineClamp);
        this.template.querySelector('main-Container-alltheme')?.appendChild(style);//shivam's bug handled by jagriti part of 34628
        this.template.querySelector('lightning-datatable').appendChild(showTootil_hide_slds_truncate);
    }
   
}