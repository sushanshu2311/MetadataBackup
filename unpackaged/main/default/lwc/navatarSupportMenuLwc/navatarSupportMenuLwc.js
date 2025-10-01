import { LightningElement, track } from 'lwc';

export default class NavatarSupportMenuLwc extends LightningElement {
    @track search = '';
    helpDesk = false;   // added by Sudhanshu for 47982
    baseURL;        // For Holding the aura application url
    connectedCallback() {
        this.baseURL = window.location.origin + '/navpeII_dev18/NavatarHelpandSupport.app';
    }


    handleKeyDown(event) {
        if (event.keyCode === 13) { // Check if Enter key was pressed
            const searchInput = this.template.querySelector('.lightning-input-css');
            const searchValue = searchInput.value;
            // Navigate to the search results page with the search query as a parameter
            window.open('/navpeII_dev18/NavatarSupport&s='+encodeURIComponent(searchValue)+'.app', '_blank');
        }
    }


    handleNavigate() {
        const searchInput = this.template.querySelector('.lightning-input-css');
        const searchValue = searchInput.value;
        // Navigate to the search results page with the search query as a parameter
        window.open('/navpeII_dev18/NavatarSupport&s='+encodeURIComponent(searchValue)+'.app', '_blank');
    }

    searchKeyword(event) {
        this.searchValue = event.target.value;
    }

    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.searchlabel label.slds-form-element__label.slds-no-flex {
            display: none; 
        }`;
    this.template.querySelector('.maincontainer_supportmenu')?.appendChild(style);	
}}