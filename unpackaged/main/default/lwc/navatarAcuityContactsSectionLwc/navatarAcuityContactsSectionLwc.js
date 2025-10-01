import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import handleExternalConnInfo from '@salesforce/apex/NavatarAcuityCtrl.handleExternalConnInfo';
import ICON_CHANNEL from "@salesforce/messageChannel/navatarLwcChannel__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class NavatarAcuityContactsSectionLwc extends NavigationMixin(LightningElement) {
    showPopoverErrorMsg = true;
    @api isMobile = false;//Added by LK on 2024-08-09 to fix 00046350
    @api contactTableLable;
    @api objName;
    @api recId;
    @api conData;
    @api  namespacePrefix;
    @api contactEmail;
    @api actIdList;
    @api internalData;
    @api conCols;
    @api conColsMob;
    @api internalTableCols;
    @api internalTableColsMob;
    @api isDealAccessible;//Modified by LK on 2024-04-11 to fix 00044459
    @api taggedSecOptions;
    @api isRgApiError;
    @api isEmailDrillDownEnabled;
    @api currRecName;//Added by LK on 2024-05-27 to fix 00037882 ; 00045898 ; 00045899
    IsAccount;
    IsContact;
    conTitle ='Contacts';
    noData;
    errMsg = 'No items to display.';

    /* Contact Section Toggle : Start */
    externalTableCols = [];
    externalTableColsMob = [];
    conSecTabValue = 'Internal';
    displayConSecToggle = false;
    isInternal = true;
    isExternal = false;
    externalData;
    queryExternalData = true;
   /* Contact Section Toggle : End */
    
    get displayAddContact(){
       return this.objName === 'Account';
    }
    
    @wire(MessageContext)
    messageContext;
    publishEvent(actionName) {
       const messaage = {
          quickActionName: actionName
    };
    //Publishing the message 
        publish(this.messageContext, ICON_CHANNEL, messaage);
   }

    handleNewContact(){
        this.publishEvent('Account.New_Contact');
    }; 

    connectedCallback(){
        this.conTitle = this.objName === 'Account' ?  this.contactTableLable : 'Connections';
        this.displayConSecToggle = this.objName === 'Contact';
        console.log('obj Name'+this.objName);
        //Added by Shivam as part of 35117,35100,35169
        if(this.objName === 'Account'){
            this.IsAccount = true;
            this.IsContact=false;
        } else if(this.objName === 'Contact'){
            this.IsAccount = false;
            this.IsContact = true;
        }
    }

    showErrorMsgPopover(){
        let showDiv = this.template.querySelector('.errorMsgPopover');
        showDiv.classList.remove("slds-hide");
        showDiv.classList.add("slds-show");
    }
     
    hideErrorMsgPopover(){
        let showDiv = this.template.querySelector('.errorMsgPopover');
        showDiv.classList.remove("slds-show");
        showDiv.classList.add("slds-hide");
    }

    /* Contact Acuity > Connections Section tab switching */
    get optnsInternalExternal() {
       return [
           { label: 'Internal', value: 'Internal' },
           { label: 'External', value: 'External' }
        ];
    }

    /****************************** Contacts/Connections Section Methods : Start ******************************/

   /* Handles tab switching : Connections Section */
    handleConSecTabSwitch(event) {
       this.conSecTabValue = event.detail.value;
       if (this.conSecTabValue === 'Internal') {
           this.isInternal = true;
           this.isExternal = false;
      } else if(this.conSecTabValue === 'External') {
           this.isInternal = false;
           this.isExternal = true;
           if(this.queryExternalData){
              //Call Shivam's code for getting SF contacts IDs
               this.handleExternalConnInfo();
               this.queryExternalData = false;
           }
       }
    }

    /* Processes the External Connections info */
    handleExternalConnInfo(){
       // this.enableSpinner = true;//Shivam fixed Critical 00034628
        let externalTableCols = [{ type: 'button', hideDefaultActions: true, fixedWidth: 32, typeAttributes: { iconName: { fieldName: 'downloadIcon' }, variant: 'base', name:'downloadIcon', title:'Add Contact' }},
                            { label: 'Name', fieldName: 'conRef', hideDefaultActions: true, type: 'url', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular' }, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', tooltip: { fieldName: 'name' }}},
                            { label: 'Firm', fieldName: 'firmUrl', hideDefaultActions: true, type: 'url', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular slds-is-sorted_asc' }, typeAttributes: {label: {fieldName: 'firmName'},  target: '_blank', tooltip: {fieldName: 'firmName'} } },//added by Shivam
                            { label: 'Deals', iconName: 'utility:user_role', initialWidth: 10, fieldName: 'dealRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor', alignment: 'center' }, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name: 'dealRef', tooltip: { fieldName: 'dealRef' }}},
                            { label: 'Meetings and Calls', iconName: 'utility:event', initialWidth: 10, fieldName: 'meetCallRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor', alignment: 'center' }, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name: 'meetCallRef', tooltip: { fieldName: 'meetCallRef' }}}
                            ];
        this.externalTableCols = [...externalTableCols];
        //Added below line and spread in above line by LK on 2024-10-10 to fix 00047680
        this.externalTableCols.push({ label: 'Emails', iconName: 'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor', alignment: 'center' }, typeAttributes: {label: {fieldName: 'emailRef' }, variant: 'base', name: 'emailRef', tooltip: { fieldName: 'emailRef' }}});
                            console.log('ext cols'+externalTableCols + 'recId '+this.recId+'objName '+this.objName +'nap '+this.namespacePrefix +'conte '+this.contactEmail+'email '+this.email+'actid '+this.actIdList);
        this.externalTableColsMob = [{ label: 'Name', fieldName: 'conRef', hideDefaultActions: true, type: 'url', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular' }, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', tooltip: { fieldName: 'name' }}},
                            { label: '', iconName: 'utility:user_role', initialWidth: 10, fieldName: 'dealRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor', alignment: 'center' }, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name: 'dealRefMob', tooltip: { fieldName: 'dealRef' }}},//changed by shivam bug #00038201
                            { label: '', iconName: 'utility:event', initialWidth: 10, fieldName: 'meetCallRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor', alignment: 'center' }, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name: 'meetCallRefMob', tooltip: { fieldName: 'meetCallRef' }}}//changed by shivam bug #00038203
                            ];
        handleExternalConnInfo({recordId : this.recId, objApiName: this.objName, namespacePrefix: this.namespacePrefix, email: this.objName == 'Contact' ? this.contactEmail : this.email, actIdList : this.actIdList})//added by shivam RG for defect #00038728
            .then((result) => {
            if(result.isEmailDrillDownEnabled){
                externalTableCols.push({ label: 'Emails', iconName: 'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'button', sortable: false, cellAttributes: { class: 'slds-text-link slds-text-body_regular textColor', alignment: 'center' }, typeAttributes: {label: {fieldName: 'emailRef' }, variant: 'base', name: 'emailRef', tooltip: { fieldName: 'emailRef' }}});
            } else {
                externalTableCols.push({ label: 'Emails', iconName: 'utility:email', initialWidth: 10, fieldName: 'emailRef', hideDefaultActions: true, type: 'text', sortable: false, cellAttributes:{ class: 'text-black', alignment: 'center'}});
            }
            this.externalTableCols = externalTableCols;
            if(result.conSecDynFieldHeader){
                this.externalTableCols.splice(3, 0, { label: result.conSecDynFieldHeader, fieldName: 'roleRef', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'roleRef' }, target: '_blank', variant: 'base', name:'roleRef', tooltip: { fieldName: 'roleRef' }, title: { fieldName: 'roleRef' }}, cellAttributes:{ class: 'text-black'}});
            }
            if(result.conInfoWrapper.length > 0){
                this.externalData = [];
                for(let recInfo of result.conInfoWrapper){
                    this.externalData.push({downloadIcon: recInfo.downloadIcon, id: recInfo.recId, conRef: recInfo.nameRef, name: recInfo.name, roleRef: recInfo.fieldInfo, meetCallRef: recInfo.meetingCallCount, emailRef: recInfo.emailCount, totalActCount: recInfo.totalActCount, actIdsList: recInfo.meetingCallIdList, email: recInfo.email, mailboxId: recInfo.mailboxId, dealRef: recInfo.dealCount, dealIdsList: recInfo.dealIdList,
                        firmUrl : recInfo.firmRef,
                        firmName : recInfo.firmName});//added by shivam
                }
                this.externalData.sort(this.sortBy('totalActCount', -1));
            }
            //this.enableSpinner = false;
            //Added condition for "isMobile" by LK on 2024-08-09 to fix 00046350
             if(result.apiError && !this.isMobile){
                 this.showToast(this, 'Error!', 'An Error occurred in API', 'error');
             }
            //Commented above if condition and added below line by LK on 2024-08-14 to fix 00044507
            //this.isRgApiError = result.apiError;
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
           // this.enableSpinner = false;
        });
    }

/****************************** Contacts/Connections Section Methods : End ******************************/

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

//Modified by Anshika Ahuja W.R.TO Redirection
fetchActInfo(event){
    if(['timesRef', 'meetCallRef'].includes(event.detail.action.name)){
        let header, emptyModalKeyword;
        header = (event.detail.action.name === 'timesRef' ? 'All Interactions With ' : 'Meetings & Calls With ') + event.detail.row.name;
        emptyModalKeyword = event.detail.action.name === 'timesRef' ? 'Interactions' : 'Meetings';
        // let compDef = {
        //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
        //     attributes: {
        //         header: header,
        //         actIdList: event.detail.row.actIdsList != undefined ? event.detail.row.actIdsList : [],
        //         namespacePrefix: this.namespacePrefix,
        //         emptyModalKeyword: emptyModalKeyword
        //     }
        // };
        // this.navigateToLwcComp(compDef);

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
        // let compDef = {
        //     componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
        //     attributes: {
        //         header: `Connections of ${event.detail.row.name}`,
        //         email: event.detail.row.email,
        //         recordId: event.detail.row.id,
        //         objApiName: this.objName,
        //         actIdList: event.detail.row.actIdsList,
        //         namespacePrefix: this.namespacePrefix,
        //         emptyModalKeyword: 'Connections',
        //         dealList: event.detail.row.dealIdsList,
        //         dealPermissions: this.dealPermissions
        //     }
        // };
        // this.navigateToLwcComp(compDef);

        this[NavigationMixin.GenerateUrl]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "navpeII_dev18__Interactions",
            },
            state: {
                c__email: event.detail.row.email,
                c__recordId: event.detail.row.id,
                c__objApiName: this.objName,//Modified by LK on 2024-04-11 to fix 00044436
                c__actIdList: event.detail.row.actIdsList,
                c__namespacePrefix: this.namespacePrefix,
                c__emptyModalKeyword: 'Connections',
                c__dealList: event.detail.row.dealIdsList,
                c__isDealAccessible: this.isDealAccessible,//Modified by LK on 2024-04-11 to fix 00044459
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
    }
    //Modified by Anshika Ahuja W.R.TO Redirection
    else if(event.detail.action.name === 'dealRefMob'){
        if(this.isDealAccessible){//Modified by LK on 2024-04-11 to fix 00044459
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
        if(this.isDealAccessible){//Modified by LK to fix 00044459
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
    } 
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
                c__emailCallerParam: this.objName === 'Contact' ? this.conSecTabValue === 'Internal' ? "childIcEmail" : "childEcEmail" : '',//Modified by LK on 2024-04-11 to fix 00044436
                c__mailboxId: event.detail.row.mailboxId,
                c__email: event.detail.row.email,
                c__parentEmailId :this.contactEmail
            },
        }).then(generatedUrl => {
            window.open(generatedUrl,  "_blank");
        });
        
    } else if(event.detail.action.name === 'downloadIcon'){
        // const myName = event.detail.row.name.split(" ");//added by shivam
        // let lastName = '';
        // if(myName.length >1){
        //     lastName = myName[1];
        // } else {
        //     //Added else clause by LK on 2024-05-27 to fix 00037882 ; 00045898 ; 00045899
        //     lastName = myName[0].split("@")[0];
        // }
        //Logic updated by LK on 2024-08-01 to fix 00046608
        const recName = event.detail.row.name.trim();
        let firstName = '';
        let lastName = '';
        if(recName.includes('@')){
            lastName = recName.split("@")[0];
        } else {
            let lastIndexOfSpace = recName.lastIndexOf(' ');
            firstName = recName.substring(0, lastIndexOfSpace).trim();
            lastName = recName.substring(lastIndexOfSpace + 1).trim();
        }
        //Modified by LK on 2024-04-11 to fix 00044436
        if(this.objName === 'Account'){
            const modalPopup = this.template.querySelector('c-navatar-acuity-ext-connection-add-popup-lwc');  //Modified by Anshika Ahuja W.R.TO Redirection
            modalPopup.firstNameValue = firstName;//Added by LK on 2024-08-01 to fix 00046608
            modalPopup.lastNameValue = lastName;//added by shivam
            modalPopup.email = event.detail.row.email;
            modalPopup.objectApiName = "Account";
            modalPopup.accountRecordId = this.recId;//Replaced "this.recordId" with "this.recId" by LK on 2024-05-27 to fix 00037882 ; 00045898 ; 00045899
            modalPopup.accountRecordName = this.currRecName;
            modalPopup.openModal();
        } else if(this.objName === 'Contact'){//Modified by LK on 2024-04-11 to fix 00044436
            //Replaced "objApiName" with "objName" by LK on 2024-07-30 to fix 00046436
            const modalPopup = this.template.querySelector('c-navatar-acuity-ext-connection-add-popup-lwc'); //Modified by Anshika Ahuja W.R.TO Redirection
            modalPopup.firstNameValue = firstName;//Added by LK on 2024-08-01 to fix 00046608
            modalPopup.lastNameValue = lastName;//added by shivam
            modalPopup.email = event.detail.row.email;
            modalPopup.openModal();
        }
    }
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

/* This function is used for styling */
renderedCallback() {
    const style = document.createElement('style');
    //Added table height for 600px by LK on 2024-04-23 to fix 00044996 ; 00045452 ; 00045510 ; 00045757 ; 00045125
    style.innerText = `@media (max-width: 600px) {
        .for_mob .slds-table_header-fixed_container {
            padding-top: 0px;
        }
        .for_mob .slds-table_header-fixed {
            padding-top: 2rem;
        }
    }
    
    .sortedbycss .slds-combobox__input{
        border: none;
        background: none;
        padding-top: 1px;
        color:#0176d3;
    }
    .errorMsgPopover .slds-popover {background-color: transparent; border: 0; box-shadow: 0; width: 190px;}
    .errorMsgPopover .slds-nubbin_bottom-left:before {left: 155px;}
    .errorMsgPopover .slds-nubbin_bottom-left:before {background-color: #BA0517}
    .errorMsgPopover .slds-nubbin_bottom-left:after{display: none}
    .iconErrCls .slds-icon_xx-small {width: 0.75rem !important; height: 0.75rem !important;}
    .iconErrCls:hover {display:block}
    .sortedbycss .slds-combobox__input:focus, .slds-combobox__input.slds-has-focus{
        box-shadow: none;
    }
    .sortedbycss label.slds-form-element__label{
        display: none;
    }
    .sortedbycss .slds-icon-utility-down .slds-icon{
        fill:#0176d3;
    }
    .sortedbycss .slds-combobox__input-value{
        color:#0176d3;
        padding-left:5px;
        padding-right:25px;
    }
    .info .slds-icon:hover {
        fill: #355d96;
    }
    .sortedbycss span.slds-truncate{
        font-size:12px;
    }
    .sortedbycss .slds-dropdown_fluid{
        min-width: 8rem !important;
        max-width: 100% !important;
        width: 100% !important;
        z-index:9;
    }
    .sortedbycss .slds-listbox__option{
        padding: 0.5px 10px;
    }
    .slds-docked-form-footer{
        z-index: 8 !important;
    }
    .sortedbycss .slds-listbox__option-icon{
        display:none;
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
    .tabhead span.slds-truncate {
    display:block !important;
    }
    .text-black button.slds-button{
        color:#000 !important;
        white-space: nowrap;
        text-overflow: ellipsis;
        max-width: 100%;
        display: block;
        overflow: hidden;
        cursor : text;
    }
    
    .slds-button:active{
        border:none;
    }
    .tabcont .slds-scrollable_y{
        overflow-y: auto !important;
        height: 100%;
    }
    .slds-th__action{
        background: #f3f3f3 !important;
    }
    .radioBtnsInterExter span.slds-radio_faux, .radioBtnsInterExterFund span.slds-radio_faux{
        white-space: nowrap;
    }
    @media only screen and (min-device-width: 1240px) and (max-device-width: 1550px) {
        .slds-table_header-fixed_container.slds-scrollable_x{
            overflow-x: hidden !important;
        }
        .radioBtnsInterExter span.slds-radio_faux, .radioBtnsInterExterFund span.slds-radio_faux{
            padding: 0px 10px 0px 10px;
        }
    }
    .radioBtnsInterExter .slds-form-element__label, .radioBtnsInterExterFund .slds-form-element__label{
        display:none;
    }
    .radioBtnsInterExter .slds-radio_button__label, .radioBtnsInterExterFund .slds-radio_button__label{
        background: #787878;
        color: #fff;
    }
    .radioBtns .slds-form-element__label{
        display:none;
    }
    .radiofourbtns .slds-form-element__label{
        display:none;
    }
    .logcallbtn .slds-icon{
        fill:#0176d3;
    }
    .addMinus .slds-icon{
        fill: #0176d3;
    }
    .bg-color-blue .slds-icon{
        fill:#fff;
        width: 18px;
        height: 18px;
    }
    .bg-blu-icon svg.slds-icon.slds-icon_xx-small{
        position: relative;
        bottom: 5px;
        right: 3px;
        width: 14px;
        height: 14px;
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
    .truncate_text_themes .slds-truncate {
        padding-right: 14px;
    }
    .slds-popover.slds-popover_tooltip.slds-nubbin_bottom-left{
        background-color: #16325c !important;
    }
    
    @media (max-width: 64em) {
    .slds-radio_button .slds-radio_faux, .slds-radio_button .slds-radio--faux, .slds-radio--button .slds-radio_faux, .slds-radio--button .slds-radio--faux{
        padding-left: 8px;
        padding-right: 8px;
        }
    }
    .no-data-main-tab .dt-outer-container{
        height: auto !important;
        position: relative;
        margin-bottom: 2px;
    }
    button:hover + .slds-popover.slds-popover_tooltip.slds-hide {
        display : block!important;
    }
    .custom_text_css button.slds-button{
        white-space: nowrap;
        text-overflow: ellipsis;
        max-width: 100%;
        display: block;
        overflow: hidden;
    }
    .icon_sz svg.slds-icon.slds-icon-text-default.slds-icon_x-small{
        height: 15px;
        width: 14px;
    }
    .text-icon button.slds-button {
        white-space: nowrap !important;
        text-overflow: ellipsis !important;
        max-width: 100% !important;
        display: block !important;
        overflow: hidden !important;
        border: none;
    }`;
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
    //Modified by Anshika Ahuja line 1359 for adding css on clips table W.R.To Bug #00034794
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
    : `.connectionTableEmailCont .slds-table tr td:nth-child(5) .slds-truncate{
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
            padding: 0 2px !important; /*Bug Id 00045709 fixed by Raju Release Bug*/
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


}