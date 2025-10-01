import { LightningElement, api } from 'lwc';

export default class NavatarAcuityInteractionColumnPopupLwc extends LightningElement {
    @api associatesWrapper;
    isModalOpen = false;
    checkModal = false;	
    //Modified by Anshika Ahuja W.R.To Critical_Bug #00035222/00035223
    headerName;
    //UI-change-for-window-scroller-get-hide-when-modal-popup-open---UI-CHANGE-19-09-22 added checkModal //
    /* To open modal */
    @api
    openModal(){
        //Modified by Anshika Ahuja W.R.To Critical_Bug #00035222/00035223
        if(this.associatesWrapper[0].iconName == 'standard:user' || this.associatesWrapper[0].iconName == 'standard:contact'){
            this.headerName = 'Participants';
        }
        else{
            this.headerName = 'Tags';    
        }
        this.isModalOpen = true;
        this.checkModal = true;
    }
    
    /* To close modal */
    closeModal(){
        this.isModalOpen = false;
     }	
    
    //UI-change-for-window-scroller-get-hide-when-modal-popup-open---UI-CHANGE-19-09-22 //	
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.tagsScreen{
            text-align: left;
            max-width: 100%;
            display: -webkit-box;
            -webkit-box-orient: vertical;
            -webkit-line-clamp: 1;
            overflow: hidden;
            }`;
        this.template.querySelector('.main-Container-clip')?.appendChild(style);
    }
}