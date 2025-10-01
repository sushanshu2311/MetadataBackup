/****************************************************************************************************
** Module Name : Acuity 2.0 - Quick Deal Creation
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14       Virendra Kumar
****************************************************************************************************/
import { LightningElement } from 'lwc';

export default class navatarCreateMenuDealForm3Lwc extends LightningElement {
    showError = false;
    errorMessage='';
    selectedCompany = '';
    nameLabel = 'Company Name'

    //Get Selected Record from Lookup filter
    handleSelectedRecord(event) {
        this.showError = false;
        this.selectedCompany =  JSON.parse(event.detail).data.Id !== undefined && JSON.parse(event.detail).data.Id !== ''? JSON.parse(event.detail).data.Id : JSON.parse(event.detail).searchKey;
    }

    //Handle back
    handleBack() {
        this.showError = false;
        const ev = new CustomEvent("handleback");
        this.dispatchEvent(ev);        
    }

    //Handle Save button
    handleSave() {

        const childDisplayState = this.template.querySelectorAll('c-navatar-single-lookup-lwc');
        if(childDisplayState != null){
            for(let eachPick of childDisplayState){
                if(this.selectedCompany === '' || this.selectedCompany === undefined){
                    this.showError = true;
                    this.errorMessage = "These required fields must be completed: "+ this.nameLabel +'.';
                    eachPick.showerror();
                }else {
                    const ev = new CustomEvent("handlesave",{detail : this.selectedCompany});
                    this.dispatchEvent(ev);
                }
            }
        }
    }

    handleSelectedFirmRecord(event){
        let obj = {};
        obj = JSON.parse(event.detail);
       this.selectedCompany  = obj.data.Id;
       this.firmName = obj.data.Name;
    }

    handleAccountName(event){
        this.selectedCompany = event.detail;
    }

    renderedCallback(){
        let popupSize = document.createElement('style');
        popupSize.innerText = `.lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
                                    position: absolute;
                                    right: 2px;
                                    top: 0px;
                                }
                                    `;
        this.template.querySelector('.listdiv').appendChild(popupSize);         

    }
}