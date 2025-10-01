import { LightningElement, track ,api } from "lwc";
import sendEmailController from "@salesforce/apex/NavatarSendEmailCtrl.sendEmailController";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavatarSendEmailLwc extends LightningElement {
    
    @track toAddress = [];
    @track  ccAddress = [];
    @track  bccAddress=[];
   // subject = ""; 
    @api subject;
   // body = ""; 
     @api body;
    ccpop = false;
    bccpop = false;
    @track files = [];

    wantToUploadFile = false;
    noEmailError = false;
    invalidEmails = false;
    @track isError=false;
    @track errorMessage=[];
    @api message; // Added by Hema - Changes made related to 00035181

    ccPopup(){
        ccpop = true;  
    }
    toggleFileUpload() {
        this.wantToUploadFile = !this.wantToUploadFile;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.files = [...this.files, ...uploadedFiles];
        this.wantToUploadFile = false;
    }

    handleRemove(event) {
        const index = event.target.dataset.index;
        this.files.splice(index, 1);
    }

    handleToAddressChange(event) {
        if(event.detail.isError){
            this.isError=event.detail.isError;
            this.errorMessage=event.detail.errorMessage;
        }
        else{
            this.isError=false;
            this.errorMessage=''; 
            this.toAddress.push(event.detail.selectedValues);
        }
        if(event.detail.isRemove){
        let val =event.detail.selectedValues;
        this.toAddress = this.toAddress.filter(value => value !==val);
        }
    }

    handleCcAddressChange(event) {
        if(event.detail.isError){
            this.isError=event.detail.isError;
            this.errorMessage=event.detail.errorMessage;
        }
        else{
            this.isError=false;
            this.errorMessage=''; 
            this.ccAddress.push(event.detail.selectedValues);
        }
        if(event.detail.isRemove){
            let val =event.detail.selectedValues;
            this.ccAddress = this.ccAddress.filter(value => value !==val);
            }
    }
    handleBccAddressChange(event) {
        if(event.detail.isError){
            this.isError=event.detail.isError;
            this.errorMessage=event.detail.errorMessage;
        }
        else{
            this.isError=false;
            this.errorMessage=''; 
            this.bccAddress.push(event.detail.selectedValues);
        }
        if(event.detail.isRemove){
            let val =event.detail.selectedValues;
            this.bccAddress = this.bccAddress.filter(value => value !==val);
            }
    }

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleBodyChange(event) {
        this.body = event.target.value;
    }


    validateEmail(email) {
        console.log("In VE");
        const res = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()s[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log("res", res);
        return res.test(String(email).toLowerCase());
    }

    handleReset() {
        this.toAddress = [];
        this.ccAddress = [];
        this.bccAddress=[];
        this.template.querySelectorAll("c-navatar-Send-Email-Combobox-Lwc").forEach((input) => input.reset());
    }

    handleSendEmail() {
        this.noEmailError = false;
        this.invalidEmails = false;
       
      
        let emailDetails = {
            toAddress: this.toAddress,
            ccAddress: this.ccAddress,
            bccAddress: this.bccAddress,
            subject: this.subject,
            body: this.body
        };
        if( this.toAddress != '' &&  this.toAddress != undefined){
        sendEmailController({ emailDetailStr: JSON.stringify(emailDetails) })
            .then(() => {
                const event = new ShowToastEvent({
                    variant: 'Success',
                    message: 'Email has been Sent Successfully!',
                });
                this.dispatchEvent(event);
                this.closeModal();
                this.handleReset();
            })
            .catch((error) => {
            });
        }
        else{
            this.errorMessage="Add a recipient to send an email";
            this.isError=true;
           
        }
    }
    @track isModalOpen = true;
    newThemeNoPopclick(){
        this.newThemeNoPop = true;
    }
    @api
    openModal(recordsID) {
        // to open modal set isModalOpen tarck value as true
        this.recordId=recordsID;
        this.isModalOpen = true;
        this.isError=false;
        this.errorMessage='';
      
    }
    ccLink = true;
    ccPopup(){
        this.ccpop = true;
       // this.template.querySelector('.noBtn').classList.add('dynamicCSS');
       this.ccLink = false;
        this.template.querySelector('.lbelfirst').classList.add('lbel')
    }
    
   
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.template.querySelector('.lbelfirst').classList.add('lbel')
        // inputWidth.classList.add('lbel');
        this.ccLink = true;
        this.ccpop = false;
        this.isModalOpen = false;
       // Added by Hema - Changes made related to 00035181 , // Added Namespace by Hema - 39195 
        window.open( 'https://' +window.location.hostname + '/lightning/n/navpeII_dev18__Clips?c__isModalOpen='+this.message , '_self');
    }
   
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `
            .txt_ht .slds-textarea{
                min-height: 100px !important;
            }
            .lbel .slds-form-element__label{
                width: 64px;
            }
            .lbelfirst .slds-form-element__label{
                width: 64px;
            }
            .slds-form-element__label:empty{
                display: none;
            }
            .lbelfirst .slds-input{
                width: 356px;
                margin-bottom: 2px;
            }
            .lbel .slds-input{
                width: 370px;
                margin-bottom: 2px;
            }
            .slds-pill__remove{
                display: block;
                position: relative;
                top: -3px;
            }
            .noBtn button.slds-button{
                box-shadow: none;
                border: none;
            }`;

        this.template.querySelector('.maincont-sendemail')?.appendChild(style);
    }
}