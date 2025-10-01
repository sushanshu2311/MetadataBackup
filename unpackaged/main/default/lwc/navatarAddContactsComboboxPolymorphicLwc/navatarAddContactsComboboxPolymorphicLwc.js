import { LightningElement, api } from 'lwc';

export default class NavatarAddContactsComboboxPolymorphicLwc extends LightningElement {
	@api callFromThemeEmail='false';
    @api searchval = '';
    @api fieldstructure;
    @api inputVariant='Standard'; // solving the merging conflict (sharing component) lightning-input line 7 HTML
    bufferSelected = undefined;
    @api position;
    showList = false;

    get mainClass() {
        return this.showList ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    }
    get manageShowList() {
        return this.showList;
    }
    get check_field_list() {
        return this.fieldstructure.filter(item => item.displayName.toUpperCase().includes(this.searchval.toUpperCase()));
    }
    showoptions() {
        this.bufferSelected = undefined;
        this.showList = true;
    }

    /*Purpose : the search will filter the values of the fields */
    searchoption(event) {
        console.log('in combo option search')
        this.searchval = event.detail.value;
        this.bufferSelected = undefined;
        this.showList= true; 
    }
    connectedCallback(){
     //this.timeoutId = setTimeout(this.delayFunction.bind(this), 250);
     if(this.callFromThemeEmail == 'false' ){
     if(this.position != undefined && this.position != null){
        console.log('SSSSS--> '+this.position);
        this.searchval = this.fieldstructure[this.position].displayName;
        }
    }
    }
    
    toggleOnBlur() {
        console.log('in toggle on blur');
        let bufferSelected = this.bufferSelected;
        let myVar;
        if (bufferSelected == undefined) {
            myVar = window.setTimeout(function () {
                let bufferSelected = this.bufferSelected;
                if (bufferSelected == undefined) { 
                    //this.toggle();
                    let searchedlist = this.fieldstructure.filter(item => item.displayName.toUpperCase() == this.searchval.toUpperCase())
                    if (!searchedlist.length > 0) {
                        const selectedEvent = new CustomEvent('optionsearch', { detail: { 'value': this.searchval } });
                        this.dispatchEvent(selectedEvent);
                    }
                    clearTimeout(myVar);
                }
            }.bind(this), 250);
        }
    }

    toggle() {
        this.showList = false;
    }

    /*Purpose:   if user selects new field from the Field picklist then this function will update the value
  and the value will remain intact in js
  */
    selectoption(event) {
        console.log('~~~~~'+JSON.stringify(event.currentTarget.id));
        let sam = event.currentTarget.id.split('-')[0];
        if (sam != '' && sam != undefined) {
            this.searchval = this.fieldstructure[sam].displayName;
            this.bufferSelected = this.searchval;
            let selectedList = this.fieldstructure[sam];
            /*const selectedEvent = new CustomEvent('optionselect', { detail: {list:selectedList,index:sam} });
            if(this.callFromThemeEmail == 'true'){

                 selectedEvent = new CustomEvent('optionselect', { detail: selectedList });

            }
            this.dispatchEvent(selectedEvent);*/
            if(this.callFromThemeEmail == "true"){

                const selectedEvent = new CustomEvent('optionselect', { detail: selectedList});

                this.dispatchEvent(selectedEvent);

            }else{                

                const selectedEvent = new CustomEvent('optionselect', { detail: {list:selectedList,index:sam} });

                this.dispatchEvent(selectedEvent);

            }
        }
        this.showList = false;
    }
}