import { LightningElement, api } from 'lwc';
/* Added the below line by Lakshya on 2023-11-07 to check if activity is archived or, not (00043034) */
import checkActivityArchivedState from '@salesforce/apex/NavatarNotesModalCtrl.checkActivityArchivedState';
/* Added the below line by Lakshya on 2023-11-07 to display toast message(00043034) */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarAcuityInteractionTileLwc extends LightningElement {
    @api actDate;
    @api actType;
    @api actIconName;
    @api buttonTitle;
    @api actSubject;
    @api actId;
    @api actDetail;
    @api actAssociates;
    @api isFutureActivity;
    remActAssociatesCount = 0;
    @api actInfo = {};
    @api recordId;
    taskType;
    displayEditButton = true; // Added to hide or display edit note button on basis of activitytype

    activityType;
    isShowNote = false;
    isRedirectToRecord = false;

    /* Returns the button variant to be used */
    get buttonVariant(){
        return this.buttonTitle === 'Add Note' ? 'brand' : '';
    }

    /* Returns the button icon name to be used */
    get buttonIconName(){
        return this.buttonTitle === 'Add Note' ? 'utility:add' : 'utility:edit';
    }

    /* Returns references info to be displayed as pills */
    get partialActAssociates(){
        if(this.actAssociates){
            if(this.actAssociates.length <= 2){
                return this.actAssociates;
            } else if(this.actAssociates.length > 2){
                this.remActAssociatesCount = '+' + JSON.stringify(this.actAssociates.length - 2);
                return this.actAssociates.slice(0, 2);
            }
        }
    }

    /* Sets up the event listeners of the various clicks inside the tile */
    connectedCallback(){
        this.activityType = this.actType == 'Meeting' ? 'Event' : 'Task';
        //Modified by Anshika Ahuja W.R.To Critical_Bug # 00038135
        if(this.actType =='Call'){
            this.taskType = 'Call';    
        }
        else if(this.actType =='Email'){
            this.taskType = 'Email'; 
        }
        else if(this.actType == 'List Email'){//Added By Harshwardhan on 26March,2023 for hiding edit note button for list emails
            this.displayEditButton = false;
        }
        else{
            this.taskType = '';     
        }
    }

    /* Redirects to activity on card click */
    redirectToActivity(){
        window.open(this.actUrl, '_blank');
    }

    /* Closes the notes modal along with button label change */
    handleCloseModal(){
        if(this.actType === 'Event'){
            this.buttonTitle = this.isFutureActivity ? 'Add Note' : 'Edit Note';
        }
        this.noteModalClosed();
    }

    /* Closes the notes modal */
    noteModalClosed(){
        this.isShowNote = false;
    }
    
    meetingCallEmailViewpopup(){
        const modalPopup = this.template.querySelector('c-navatar-all-interactions-view-modal-lwc');//Modified by Anshika Ahuja W.R.To Naming Convention
        let activityInfo = JSON.parse(JSON.stringify(this.actInfo));
        if(!activityInfo.hasOwnProperty('actId')){
            activityInfo.actId = this.actId;
        }
        modalPopup.openModalNew(activityInfo, []);
    }
   
    handleNoteClick(){
        /* Added below method and moved existing code in else condition by Lakshya on 2023-11-07 to display warning when editing archived activity */
        checkActivityArchivedState({
            activityId : this.actId,
            activityType : this.actId.slice(0, 3) === '00T' ? 'Task' : 'Event'
        })
        .then(res=>{
            if(res === 'true'){
                //Modified the toast mode to "dismissable" on 2023-11-07 to fix the issue (00043034)
                // Bug 00047232 fixed by Sudhanshu
                this.showToast(this, 'Error', 'You do not have permission to edit Archived records. Please contact your Navatar Administrator.', 'error', 'dismissible');
            } else {
                this.isShowNote = true;
            }
        })
        .catch((err=>{
            this.showToast(this, 'Error!', err, 'error', 'sticky');
        }))
    }

    /* Added below method by Lakshya on 2023-11-07 to display toast message (00043034) */
    showToast(cmp, title, message, variant, mode){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        cmp.dispatchEvent(event);
    }

    /* This function is used for styling */
    // UI-fix-bug id-31628 new class date-field-height-23-09-22--added renderedcallback-----------------
    // UI-fix-bug id-35355 critical bug fix 17feb23 cls_butonSize1 added margin-right and changed padding ---  
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.addMinus .slds-button{
            height:30px;
            width:30px;
            border: none;
        }
        .cls_butonSize1 .slds-button{
            white-space: nowrap !important;    
            padding: 0px 4px 0px !important;    
        }   
        .cls_butonSize1 lightning-primitive-icon{    
            display:flex;    
        }
        .cls_butonSize1 svg.slds-button__icon.slds-button__icon_left {
            margin-right:3px !important;
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
        }
        
        `;
        this.template.querySelector('.main-Container')?.appendChild(style);
    }
}