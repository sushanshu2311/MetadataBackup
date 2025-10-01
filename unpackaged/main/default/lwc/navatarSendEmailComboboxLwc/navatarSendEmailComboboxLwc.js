import { LightningElement, track, api } from "lwc";
import search from "@salesforce/apex/NavatarSendEmailCtrl.search";
import getUsersData from "@salesforce/apex/NavatarSendEmailCtrl.getUsersData";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarSendEmailComboboxLwc extends LightningElement {
    isDropDownVisible = false;
    itemvisible=[];
    searchTerm = "";
    blurTimeout;
    boxClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";

    _selectedValues = [];
    selectedValuesMap = new Map();
    tempOptions = [];
    selectedItems = [];
    isPills = true;
    value = '';
    finalOption = [];
    emailAddress;
    @track items=[];
    @track inputVal='';


    
    connectedCallback(){
        getUsersData({
        }).then(result=>{
          this.itemvisible = result;
          this.items = result;
        }).catch(error=>{

        })
        this.tempOptions = this.options;
        this.finalOption =  [...this.tempOptions]
       
    }

    itemSelect(event){
       let val =  event.target.closest('.dropLists').getAttribute('data-value');
        const selectedValuesEvent = new CustomEvent("selection", { detail: { selectedValues: val} });
        this.dispatchEvent(selectedValuesEvent);
      
        this.items.map(item=>{
            if(item.value == val){
                item.isSelected = true;
                item.usermail= item.label + ' <'+item.value+'>';
            }
        })
       
        this.template.querySelector('.input').value ='';
        this.isDropDownVisible = false;
    }
    @track islistvisible = false;
   
    handleKeyUp(event) {        
        this.value = event.target.value;
        let value = event.target.value;
        this.islistvisible = true;
        if (value.length > 1) {
            let arr = this.options.filter(e=> e.value.toLocaleLowerCase().match(value.toLocaleLowerCase()));
            this.finalOption = [...arr]
        }
        else
        {
            this.finalOption = [...this.options]
        }
    }

    
    handleSearchChange(event){
        this.inputVal=event.target.value;
    }
    statusValue = 'Completed';
    priorityValue = 'Normal';

    get options() {
        return [
            { label: 'Completed', value: 'Completed' },
        ];
    }
    get selectedValues() {
        return this._selectedValues;
    }
    set selectedValues(value) {
        this._selectedValues = value;
        const selectedValuesEvent = new CustomEvent("selection", { detail: { selectedValues: this._selectedValues} });
        this.dispatchEvent(selectedValuesEvent);
    }

    handleInputChange(event){
        let searchVal = event.target.value;
        this.inputVal=event.target.value;
        if( searchVal != '' && searchVal.length>1){
        search({
            searchString : searchVal
        }).then(result=>{
            if(result.length>0){
                this.itemvisible = result;
                this.isDropDownVisible = true;
            }else{
                this.itemvisible = [];
                this.isDropDownVisible = false;
            }
        }).catch({})
    }
    else if( event.target.value.length ===0){
        this.itemvisible = [];
        this.isDropDownVisible = false;
    }
    this.inputVal='';
    } 


   




    handleBlur() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = setTimeout(() => {
            this.boxClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
            const value = this.template.querySelector('input.input').value
            if (value !== undefined && value != null && value !== "") {
                this.selectedValuesMap.set(value, value);
                this.selectedValues = [...this.selectedValuesMap.keys()];
            }

            this.template.querySelector('input.input').value = "";
        }, 300);
        
    }

    get hasItems() {
        return this.items.length;
    }

    handleKeyPress(event) {
        if (event.keyCode == 13) {
            this.inputVal=event.target.value;
            const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if(event.target.value.match(emailRegex)){
           
                const filtered = this.items.find( (obj) => {
                    return ( obj.value === event.target.value); 
                  }); 
                  if(filtered == undefined ){
                let arr =
                {
                isSelected : true,
                label : '',
                value : event.target.value,                       
                usermail : '<'+event.target.value+'>'
                }
            ;
            this.items.push(arr);

            const selectedValuesEvent = new CustomEvent("selection", { detail: { selectedValues: event.target.value} });
             this.dispatchEvent(selectedValuesEvent);
            
            
        }
        this.inputVal='';
        this.template.querySelector('.input').value = '';
    }
    else{
        const event = new ShowToastEvent({
            title:'Error!',
            variant: 'Error',
            message: 'Please enter valid email',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
}

}
}

    handleRemove(event) {
        
        let val =  event.detail.name;
        this.items.map(item=>{
            if(item.value == val){
                item.isSelected = false;
            }
        })
        const selectedValuesEvent = new CustomEvent("selection", { detail: { selectedValues: event.detail.name,isRemove:true} });
        this.dispatchEvent(selectedValuesEvent);
       
    }

    

    @api reset() {
        this.selectedValuesMap = new Map();
        this.selectedValues = [];
    }

    @api validate() {
        this.template.querySelector('input').reportValidity();
        const isValid = this.template.querySelector('input').checkValidity();
        return isValid;
    }
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = ``;
            this.template.querySelector('.main-Container').appendChild(style);
      
    }
   
}