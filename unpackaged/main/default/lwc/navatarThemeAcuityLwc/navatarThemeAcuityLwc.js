/*
** Module Name : Acuity 2.0 - Acuity
** Description : Displays the Acuity information of Acuity 2.0 including Interactions Section and Themes details.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Anshika Ahuja  Acuity Phase 2
** Added by tejaswini - Naming Convention
*/
import { LightningElement, track, api, wire } from 'lwc';
//Added By Tejaswini - Naming Convention 
import handleOnLoadInfo from '@salesforce/apex/NavatarThemeAcuityCtrl.handleOnLoadInfo';
import handleInteractionsInfo from '@salesforce/apex/NavatarThemeAcuityCtrl.handleInteractionsInfo';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LandingPageTheme - old name
export default class NavatarThemeAcuityLwc extends NavigationMixin(LightningElement) {

    /*Variables used for displaying Description Details*/
    @api recordId;
    completeActIdList = [];
    namespacePrefix = '';
    interactionsInfoArray = [];
    errMsg = 'No items to display.'; // Bug 00048316 fixed by Sudhanshu
    enableSpinner = false;
    currRecName;
    isFirstTimeLoad = true;

     /* Interactions Section : START */
     interactionsPartialInfoArray;
     displayViewAll = false;
     isCallLogOpen = false;  //For opening/closing of the Log Call Notes popup
     /* Interactions Section : END */

    showToast(cmp, title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        cmp.dispatchEvent(event);
    }

    connectedCallback(){
        this.handleOnLoadInfo();
        
    }
    /* For modifying the Interactions section tile CSS based on the count of the tiles */
    get interactionSecCls(){
        return 'slds-grid ' + (this.displayViewAll ? 'allcardheight' : 'less_cards');
    }

    /*For opening the Log a Call notes popup */
    callViewpopup(){
        this.isCallLogOpen = true;
    }

    /* Processes the info to be displayed on page load */
    handleOnLoadInfo(){
        this.enableSpinner = true;
        handleOnLoadInfo({recordId : this.recordId})
        .then((result) => {
            this.namespacePrefix = result.namespacePrefix;
            this.completeActIdList = result.completeActIdList;
            this.currRecName = result.currentRecordName;
            if(this.completeActIdList != null){
                this.handleInteractionsInfo();
            }
            else{
                this.enableSpinner = false;
            }
        
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
        });
                    
                
    }
    handleInteractionsInfo(){
        handleInteractionsInfo({namespacePrefix : this.namespacePrefix, actIdList : this.completeActIdList})
                .then((result) => {
                    if(result && result.length > 0){
                        this.interactionsPartialInfoArray = [];
                        //Added below line on 2022-09-27 to fix data sorting issue
                        result.sort(this.sortBy('actDateAsLong', -1));
                        this.displayViewAll = result.length > 4;
                        for(let recInfo of result.slice(0, 4)){
                            this.interactionsPartialInfoArray.push({iconName: recInfo.iconName, type: recInfo.type, date: recInfo.actDate, buttonTitle: recInfo.buttonTitle, subject: recInfo.subject, id: recInfo.actId, detail: recInfo.detail, participantsInfo: recInfo.attendees, tagsInfo: recInfo.references, priority: recInfo.priority, actOwner: recInfo.actOwner, classification: recInfo.classification, status: recInfo.status,actInfo: recInfo.actInfo });
                        }
                      
                    }
                    this.enableSpinner = false;
                    
                })
                .catch((error) => {
                    this.showToast(this, 'Error!', error.body.message, 'error');
                });
    }



    /* Processes activities info on View All click */
    handleViewAllClick(){ //Added Namespace by Hema - 39200
        //Phase 3 Critical Bug - 00045332,00045334
        let compDef = {
            componentDef: "navpeII_dev18:navatarAcuityRedirectionLwc",
            attributes: {
                header: 'All Interactions With ' + this.currRecName,
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

        // this[NavigationMixin.GenerateUrl]({
        //     type: "standard__navItemPage",
        //     attributes: {
        //         apiName: "navpeII_dev18__Interactions",
        //     },
        //     state: {
        //         c__header: 'All Interactions With ' + this.currRecName,
        //         c__namespacePrefix: this.namespacePrefix,
        //         c__actIdList: this.completeActIdList,
        //         c__emptyModalKeyword: 'Interactions'
        //     },
        // }).then(generatedUrl => {
        //     window.open(generatedUrl,  "_blank");
        // });
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

    addThemeRecordPop(){
        //Added by Tejaswini - Naming Convention
        const objChild = this.template.querySelector('c-navatar-acuity-theme-add-to-theme-lwc');
        objChild.openModal();
    }


    //This fuction used for styling
    // UI-fix-bug id-00038119 critical bug fix 17feb23 cls_butonSize1 added margin-right and changed padding ---
    renderedCallback() {
    console.log(this.isRendered);
    this.isRendered = true;
    const style = document.createElement('style');
    style.innerText = `.tabhead span.slds-truncate {
        display:block !important;
        }

        .logcallbtn .slds-icon{
            fill:#0176d3;
        }
        .bg-color-blue .slds-icon{
            fill:#fff;
        }
        .power-btn button.slds-button{
            white-space: nowrap !important;
            text-overflow: ellipsis !important;
            max-width: 160px !important;
            display: block !important;
            overflow: hidden !important;
        }
        .slds-button:active,
        .slds-button:focus {
            border: none !important;
            box-shadow: none !important;
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
        .cls_butonSize1 .slds-button{
            white-space: nowrap !important;    
            padding: 0px 4px 0px !important;    
        }   
        .cls_butonSize1 svg.slds-button__icon.slds-button__icon_left {
            margin-right:3px !important;
        }  
        .cls_butonSize1 lightning-primitive-icon{    
            display:flex;    
        }
        .radioBtnsInterExter .slds-form-element__label{
            display:none;
        }
        .radioBtns .slds-form-element__label{
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
        }`;
        try {
            this.template.querySelector('.main-Container').appendChild(style);
        } catch (err) {
            console.log(err)
        }
}
noteModalClosed() {
    this.isCallLogOpen = false;
}

//Samiulla Pathan: Theme Export popup. 
    //This method call the createExportRecords() method from navatarAcuityThemeCategoriesLWC js and 
    //opens the theme export popup
    onclickExport(){
        this.template.querySelector("c-navatar-acuity-theme-categories-l-w-c").createExportRecords();
    }

}