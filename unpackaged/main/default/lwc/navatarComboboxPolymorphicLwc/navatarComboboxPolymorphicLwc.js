/****************************************************************************************************

** Module Name : Activity Associations

** Description : Custom lookup component to search across all Activity Association objects

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import lookUp from '@salesforce/apex/NavatarLookupCtrl.getRelatedData';

export default class navatarComboboxPolymorphicLwc extends LightningElement {
    @api objName;
    @api searchPlaceholder='Search';

    @track selectedName;
    @track records = [];
    @track blurTimeout;

    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    // search records on change of search string
    @wire(lookUp, {searchString : '$searchTerm', searchObjects : '$objName'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = JSON.parse(data);
        } else if (error) {
            this.error = error;
            this.records = [];
        }
    }

    // show record list only when size > 0
    get isRecordsFound(){
        return this.records.length > 0 ? true : false;
    }

    // handle click on input.
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    //onblur event on input field
    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
        //this.records = [];
    }

    // on select from record list
    onSelect(event) {

        let selectedRecord =  this.records.find(e => e.Id == event.currentTarget.dataset.id);
        console.log('==event.currentTarget.dataset==',selectedRecord);
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  JSON.stringify(selectedRecord) });
        this.dispatchEvent(valueSelectedEvent);
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        this.records = [];
    }

    // change search term value on change
    onChange(event) {
        console.log('changed=');
        this.searchTerm = event.target.value;
    }

}