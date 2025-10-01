/* eslint-disable no-alert */
/* eslint-disable no-shadow */
/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable consistent-return */
/* eslint-disable array-callback-return */
/* eslint-disable eqeqeq */
import { LightningElement, api } from "lwc";
import getPickListValues from "@salesforce/apex/NavatarExpBuilderLookupPopupCtrl.getLookUpValues";
import getSearchResults from "@salesforce/apex/NavatarExpBuilderLookupPopupCtrl.SearchItem";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarResearchExpBuilderLookupPopUpLwc extends LightningElement {

    @api objectname; // specific field's Object whose values are required to select
    @api pickval;    // specific field whose values are required to select
    @api fieldtype;    // specific field's type whose values are required to select
    @api isopenmodal;  // to control the modal open/close from parent itself.
    @api operation;   // not determined yet
    @api existingvalues;
    selectedValueSet = [];
    currentmessage = '';    // to show any more relevant messages on the UI
    isloading = true;   //will be used for loading gif to show loading
    title = '';         // informative use
    searchparam = '';   // will be used to keep search parameter intact
    showsearch = false; // search will only be enabled on reference type field so for tracking the same
    lookupvalues;  // will hold the js side values to showCase on UI.
    serverresponse;    // will hold initial APEX Results so as to maintain initial Data with further functionalities.
    error;
    radioval;
    radiooptions;
    selectedVal;
    maxrow = 500;
    selectedrows = [];
    selectedrowindices = [];
    columns = [
        { label: 'Value', fieldName: 'label' }];

    get isPicklist() {
        return this.fieldtype == 'PICKLIST' || this.fieldtype == 'MULTIPICKLIST';
    }
    /*(--------INITIAL APEX INVOCATION---------)
    function is responsible for Fetching the values against specific field on component load.
    */
    connectedCallback() {
        console.log(this.objectname + '-' + this.pickval + '-' + this.fieldtype + '-');
        this.isopenmodal = false;
        // this.selectedValueSet = this.existingvalues != '' && this.existingvalues != undefined ? this.existingvalues.split(',') : [];
        if (this.fieldtype != 'BOOLEAN') {
            getPickListValues({
                objectname: this.objectname,
                pickval: this.pickval,
                datatype: this.fieldtype,
                operation: this.operation
            })
                .then(data => {
                    this.serverresponse = JSON.parse(JSON.stringify(data));
                    this.title = this.serverresponse.title;
                    this.objectname = this.serverresponse.objectname;
                    let serverResponse = this.serverresponse.lookupvalues;
                    serverResponse.forEach(item => {
                        if (this.selectedValueSet.includes(item.Id)) {
                            item.checked = true;
                        }
                    });
                    this.lookupvalues = serverResponse;
                    this.maxrow = this.lookupvalues.length || 500;
                    console.log('lookupvalues' + JSON.stringify(this.serverresponse));
                    if (this.fieldtype != "" && this.objectname.toUpperCase() != 'RECORDTYPE'
                        && this.fieldtype.toUpperCase().includes("REFERENCE")) {
                        this.showsearch = true;
                    }
                    this.isloading = false;
                    this.isopenmodal = true;
                })
                .catch(error => {
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(", ");
                    } else if (typeof error.body.message === "string") {
                        this.error = error.body.message;
                    }
                    console.log("inside error" + JSON.stringify(error));
                    this.isPriviliged = false;
                    this.showNotification("Error!!", this.error, "error");
                    this.isloading = false;
                    this.isopenmodal = true;

                });
        }
        else {
            this.title = 'Please select the Picklist Value to Add below.'
            this.lookupvalues = [
                { label: 'True', value: 'True' },
                { label: 'False', value: 'False' }
            ];
            this.showsearch = false;
            this.maxrow = 1;
            this.isloading = false;
            this.isopenmodal = true;
        }
    }

    /* */
    get disableinsert() {
        return (this.selectedVal == '' || this.selectedVal == undefined || this.selectedVal.length < 1);
    }
    /*
     function is responsible for keeping searched parameter intact within JS for further functionalities
     */
    setSearchParam(evt) {
        this.searchparam = evt.detail.value;
        if (this.searchparam == '') {
            let currentselectedrows = this.template.querySelector('lightning-datatable') != null ? this.template.querySelector('lightning-datatable').selectedRows : [''];
            this.currentmessage = '';
            this.lookupvalues = JSON.parse(JSON.stringify(this.serverresponse.lookupvalues));
            if (this.selectedrowindices.length > 0) {
                this.selectedrows = [...currentselectedrows, ...this.selectedrowindices];
                this.selectedrowindices = [];
            } else {
                this.selectedrows = currentselectedrows;
            }
        }
    }
    get disablegobutton() {
        return this.searchparam != '' ? false : true;
    }
    /*
     function is solely responsible for handling search on a specific value
     Will make Apex Invocation also if initial results does not match the entered search value
     */
    handleSearch() {
        this.isloading = true;
        this.selectedrowindices = this.template.querySelector('lightning-datatable').selectedRows;
        this.callApexForSearch();

    }
    /* ------(APEX INVOCATION)----------
        function is responsible for getting values from Apex for the particular field of an object
    */
    callApexForSearch() {
        getSearchResults({
            searchparam: this.searchparam,
            objname: this.objectname,
            currentIndex: this.serverresponse.lookupvalues.length
        })
            .then(result => {
                try {
                    if (result.responseMessage == 'Success') {
                        this.currentmessage = '';
                        this.isloading = false;
                        this.lookupvalues = JSON.parse(JSON.stringify(result.lookupvalues));
                        let newlist = [];
                        let selectedrows = [...this.selectedrowindices];
                        for (let val in result.lookupvalues) {
                            var already = this.lookupvalues.filter(function (element) {
                                return element.Id == result.lookupvalues[val].Id;
                            });
                            if (!already.length > 0) {
                                newlist.push(result.lookupvalues[val]);
                            } else {
                                const index = selectedrows.indexOf(result.lookupvalues[val].Id);
                                if (index > -1) {
                                    selectedrows.splice(index, 1);
                                }
                            }
                        }
                        if (newlist.length > 0) {
                            Array.prototype.push.apply(this.serverresponse.lookupvalues, newlist);
                        }
                        //console.log(selectedrows);
                        this.selectedrows = this.selectedrowindices;
                        this.selectedrowindices = selectedrows;
                    } else if (result.responseMessage == 'No Data Found') {
                        let dummy = [];
                        this.lookupvalues = dummy;
                        this.currentmessage = 'No Data Found';
                        this.isloading = false;
                    }
                    else {
                        this.selectedrows = this.selectedrowindices;
                        console.log('inside error-->' + result.responseMessage);
                        this.isloading = false;
                    }
                } catch (ex) {
                    console.log(ex.message);
                }
            })
            .catch((error) => {
                console.log('inside error-->' + JSON.stringify(error));
                this.isloading = false;
            });
    }

    /*
    function is responsible for closing the modal and intimating parent component about it*/
    closeModal() {
        const selectedEvent = new CustomEvent("closemodal");
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.isopenmodal = false;
    }
    handlePickListSelect(event) {
        const selectedItemValue = event.detail.value || event.currentTarget.value;
        let lookupvalues = this.lookupvalues;
        const menuIndex = lookupvalues.findIndex(item => item.Id === selectedItemValue);
        if (menuIndex > -1) {
            lookupvalues[menuIndex].checked = !lookupvalues[menuIndex].checked;
        }
        this.lookupvalues = lookupvalues;
        this.selectedVal = lookupvalues.filter(val => val.checked == true);
        console.log('selectedVal ' + JSON.stringify(this.selectedVal));
    }
    /*
    function is responsible for handling checkbox Selection for Values against specific field */
    updateCheckBox(event) {
        this.selectedrows = this.template.querySelector('lightning-datatable').selectedRows;
        const row = event.detail.selectedRows;
        // console.log(row);
        this.selectedVal = JSON.parse(JSON.stringify(row));
    }
    /* IN CASE if The Datatype is BOOLEAN
    function is responsible for handling checkbox Selection for Values against specific field */
    updateradio(evt) {
        this.radioval = evt.target.value;
    }
    /*
    function is responsible for finalising the selected values and passing it to parent component using events*/
    insertValues() {
        var result={label:"",Id:""};
        if (this.selectedVal != undefined && this.selectedVal.length > 0) {
           // alert('--->'+this.fieldtype);
            if (this.fieldtype != 'BOOLEAN') {
                
                result.label = this.selectedVal.map(e => e.label);
                result.Id = this.selectedVal.map(e => e.Id);
            }
            else {
                result = this.selectedVal[0].value;
            }
           // alert(JSON.stringify(result));
            const selectedEvent = new CustomEvent("insertvalues", { detail: result });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
        this.closeModal();
    }
    /*------(TOAST for Error/SUCCESS/INFO)----------
    for showing error on UI*/
    showNotification(_title, message, variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    /*
        function is responsible for Resetting all selected values to its initial State*/
    resetAll() {
        // console.log(JSON.stringify(this.template.querySelector('lightning-datatable').selectedRows));
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedVal = [];
    }

//This fuction used for styling
renderedCallback(){
    //Ehatsham Changes 
    console.log(this.isRendered);
            this.isRendered = true;
            const style = document.createElement('style');
            style.innerText =`
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
        
        .datatable_theme .slds-table_header-fixed_container.slds-scrollable_x {
            overflow-x: hidden;
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
        }`;
    
                try {
                    this.template.querySelector('.main-Container-search').appendChild(style);
                } catch (err) {
                    console.log(err)
                }
            }
}