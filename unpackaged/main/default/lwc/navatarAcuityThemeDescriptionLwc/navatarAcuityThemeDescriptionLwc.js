/*
** Module Name : Acuity 2.0 - Acuity
** Description : Displays the Themes Description and Theme Teams details.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Anshika Ahuja  Acuity Phase 2
** Added by Tejaswini
*/
import { LightningElement, api, track } from 'lwc';
//Added By Tejaswini - Naming Convention 
import handleOnLoadDescription from '@salesforce/apex/NavatarThemeAcuityCtrl.handleOnLoadDescription';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NavatarAcuityThemeDescriptionLwc extends LightningElement {
    @api recordId;
    @track themeTeamMembers='';
    @track themeDescription='';
    @track noDescriptinMsg='No Description Found.';
    @track noTeamMemberMsg='No Team Member Found.';
    
    actionRequired = true;
    expand = false;
    showless = false;

    showToast(cmp, title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        cmp.dispatchEvent(event);
    }
    connectedCallback(){
        this.handleOnLoadDescription();
        
    }

    handleOnLoadDescription(){
        handleOnLoadDescription({recordId : this.recordId})
        .then((result) => {
            this.themeTeamMembers = result.themeTeamMembers;
            this.themeDescription = result.themeDescription;
            if(this.themeDescription.length < 326){
                console.log("16")
                this.expand = false;
                this.showless = false;
            }else{
                console.log("20")
                this.expand = true;
                this.showless = false;
                
            }
            
        })
        .catch((error) => {
            this.showToast(this, 'Error!', error.body.message, 'error');
        });
                    
                
    }


    showmoretext(){
        let popModal = this.template.querySelector('.desc_li_theme');
        popModal.classList.remove("multiline_truncate");
        if(popModal.classList.contains('description_li')){
            popModal.classList.remove("description_li")
            this.expand = false;
            this.showless = true;
            console.log("con1")
        }else{
            popModal.classList.add("description_li")
            this.expand = false;
            this.showless = true;
            console.log("con2")
        }
    }

    showlesstext(){
        let popModal = this.template.querySelector('.desc_li_theme');
       
        popModal.scrollTop = 0;
        if(popModal.classList.contains('description_li')){
            popModal.classList.remove("description_li")
            this.expand = true;
            this.showless = false;
            popModal.classList.add("multiline_truncate"); 
            console.log("con1")
        }else{
            popModal.classList.add("description_li")
            this.expand = false;
            this.showless = true;
           
            console.log("con2")
        }
        
    } 
}