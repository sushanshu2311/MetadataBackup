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
import { LightningElement,api } from 'lwc';

export default class navatarCreateMenuDealForm2Lwc extends LightningElement {
    @api dealHeader;
    @api dealBody;
    connectedCallback(){
        console.log(this.dealBody);
    }
    handleNo() {
        const ev = new CustomEvent("handleno");
        this.dispatchEvent(ev);        
    }

    handleYes() {
        const ev = new CustomEvent("handleyes");
        this.dispatchEvent(ev);
    }
}