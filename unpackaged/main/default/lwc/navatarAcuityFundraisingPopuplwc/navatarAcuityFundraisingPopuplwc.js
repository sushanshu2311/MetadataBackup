import { LightningElement, track, api,wire } from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import { NavigationMixin } from 'lightning/navigation';
import  FUNDRAISING_OBJECT from '@salesforce/schema/Fundraising__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createFundRaising from '@salesforce/apex/NavatarAcuityFundraisingPopupCtrl.createFundRaising';
import getFundRecordDetails from '@salesforce/apex/NavatarAcuityFundraisingPopupCtrl.getFundRecordDetails';
import getFundData from '@salesforce/apex/NavatarAcuityFundraisingPopupCtrl.getFundData';
import getFirm from '@salesforce/apex/NavatarAcuityFundraisingPopupCtrl.getFirm';
import ICON_CHANNEL from "@salesforce/messageChannel/navatarLwcChannel__c";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';//Added by LK on 2024-05-22 to fix 00045424

export default class NavatarAcuityFundraisingPopupLwc extends NavigationMixin(LightningElement) {
    @api selectedId;
    @api objName;
    @api contactCheck;
    @api switchTabValue;
    @api landingPageObjApiName;//Added by LK on 2024-03-09 to fix 00044270
   // @api label;
    displayAccountAsLookup = false;//Added by LK on 2024-03-09 to fix 00044270
    addfundraisingpop = false;
    chckBoxdel = true;
    cancelRemove = false;
    addDisableexter = true;
    @track hasRendered = true;
    companyCheck = false;
    @wire(MessageContext)
    messageContext;
    publishEvent(actionName) {
        const messaage = {
            quickActionName: actionName
          };
          //4. Publishing the message 
          publish(this.messageContext, ICON_CHANNEL, messaage);
    }

    /*************************nikita S. code******************************/

    objectApiName = FUNDRAISING_OBJECT;
    fundName ; 
     stage;
     closingField;
     closingDateField;
    likelyAmountField;
    openModal = true;
    selectedLegalId ;
    fundRaisingName = ''; 
    investmentCategory;
    selectedCompanyId;
    investor;
    company;
    Name;
    error;
    openCoinvestmentModal = false;
    dateValue;
    stages;
    amount;
    closeFields;
    comapnyRecordType;
    investmentCategoryType;
    comapnyRecordTypes;
    institutionRecordType;
    portfolioRecordType;
    limitedPartnerRecordType;
    myOptions;
    optionsclosing;
    companyId;
    fundraisingRecordId;
    fundCheck = false;
    legalName;
    selectedFundId;
    recordPassId;
    legalHeadingName;
    investorNewName = '';
    newCompanyName = '';
    newFundName = '';
    fundType;
    areDetailsVisible = false;
    tabValue;
    isError = false;
    showError = false;
    errorMessage;
    selFundName = '';//Added by LK on 2024-05-09 to fix 00045523

      // to get all the metadata field labels   
        connectedCallback(){
            //Added below line by LK on 2024-03-09 to fix 00044270
            this.displayAccountAsLookup = (this.landingPageObjApiName === 'Contact');
                getFundData({recordId : this.selectedId})      
                 .then(result=>{
                 let data = result;
               this.closingDateField = data.labels[3];
               this.fundName = data.labels[0];
               this.stage = data.labels[1];
               this.closingField = data.labels[2];
               this.likelyAmountField = data.labels[4];
               this.investor = data.labels[5];
               this.legalName = data.labels[7];
               this.company = data.labels[6];
               if(this.objName == "Fund"){
                this.Name = data.fundData.fund[0].Name;
                this.investmentCategory = data.fundData.fund[0].navpeII_dev18__Investment_Category__c;
               }
               this.investmentCategoryType = data.fundData.investmenCategoryType;
               this.openNewFundraising(this.investmentCategoryType,this.investmentCategory);
               this.comapnyRecordTypes = data.fundData.company;
               this.institutionRecordType = data.fundData.institution;
               this.portfolioRecordType = data.fundData.portFoloioCompany;
               this.fundType = data.fundData.investmentFundType;
               this.limitedPartnerRecordType = data.fundData.limitedPartner;
                 }).catch(error=>{
                    this.genericShowToastMessage(error.body.message,'error','sticky');
                 })
           if(this.objName == "Account"){
                 getFirm({recordId : this.selectedId})
                 .then(result=>{
                    this.fundCheck = true;
                    this.legalHeadingName = result.firm[0].Name;
                }).catch(error=>{
                    this.genericShowToastMessage(error.body.message,'error','sticky');
                 })
            }
        }
      

        fundRaisingRecord  = {'sobjectType' : FUNDRAISING_OBJECT }
        //Added below wire method and getter by LK on 2024-05-22 to fix 00045424
        @wire(getObjectInfo, { objectApiName: FUNDRAISING_OBJECT}) 
        fdrRec;
        get newFdrLabel(){
            return Object.keys(this.fdrRec).length !== 0 ? `New ${this.fdrRec["data"]["label"]}` : 'New Fundraising';
        }
        //call to save new fundraising record
        saveNewFundraising() {
         if(this.openCoinvestmentModal){
            this.investorPopUpSave();
          //  this.companyPopUpSave();
         }else if(this.companyCheck){
        //    this.fundCompanyPopUpSave();
              this.fundPopUpSave();
         }else if(this.fundCheck == true){
            this.fundPopUpSave();  
         }
         else{
            this.investorPopUpSave();
         }
     }

     // to save the new fundraising record where fund record selected
     fundPopUpSave(){
            if(this.selectedFundId == undefined && this.newFundName === ''){
                this.template.querySelectorAll("c-navatar-single-lookup-lwc").forEach(item => {
                    if(this.selectedFundId === undefined){
                        this.showError = true;
                        this.errorMessage = "These required fields must be completed: Fund Name";
                        item.showerror();
                         return;
                    } else{
                        item.setCustomValidity("");
                        this.showError = false;
                    }
                    });
               
            }else{
                this.saveNewRecord();
            }
     }

    
   
     // to save new fundraising investor field need to select
          investorPopUpSave(){
            if(this.selectedLegalId === undefined && this.investorNewName === ''){
            this.template.querySelectorAll("c-navatar-single-lookup-lwc").forEach(item => {
                if(this.selectedLegalId === undefined && this.investorNewName === ''){
                    this.showError = true;
                    this.errorMessage = "These required fields must be completed: "+ this.investor +'.';
                    item.showerror();
                    //  return;
                }
                else{
                    item.setCustomValidity("");
                    this.showError = false;
                }
                
                });
            
        }else{
            this.saveNewRecord();
            }
        }

        // fundCompanyPopUpSave(){
        // try{
        //     if(this.newCompanyName == '' && this.selectedCompanyId == undefined){
        //     const childDisplayState = this.template.querySelectorAll('c-custom-lookup-single-l-w-c');
        //     if(childDisplayState != null){
        //         for(let eachPick of childDisplayState){
        //             if(this.selectedFundId === undefined && this.newFundName === ''){
        //                 this.showError = true;
        //                 this.errorMessage = "These required fields must be completed: Fund Name";
        //                 eachPick.showerror();
        //             }
        //             // if(this.selectedCompanyId == undefined && eachPick.currentInputClass == "field2"){ 
        //             //     this.showError = true;
        //             //     this.errorMessage = "These required fields must be completed: Company.";
        //             //     eachPick.showerror();
        //             // } 
        //                         }
        //             }
        //             } else{
        //                 this.saveNewRecord();
        //                 }
        //             }catch(e){

        //             }
        // }
   
    

        // companyPopUpSave(){
        // try{
        // if(this.newCompanyName == '' && this.selectedCompanyId == undefined){
        // const childDisplayState = this.template.querySelectorAll('c-custom-lookup-single-l-w-c');
        // if(childDisplayState != null){
        //     for(let eachPick of childDisplayState){
        //         if(this.selectedLegalId === undefined && this.investorNewName === ''){
        //             this.showError = true;
        //             this.errorMessage = "These required fields must be completed: "+ this.investor +'.';
        //             eachPick.showerror();
        //         }
        //         // if(this.selectedCompanyId == undefined && eachPick.currentInputClass == "field1"){ 
        //         //     this.showError = true;
        //         //     this.errorMessage = "These required fields must be completed: Company.";
        //         //     eachPick.showerror();
        //         // } 
        //                     }
        //         }
        //         } else{
        //             this.saveNewRecord();
        //             }
        //         }catch(e){

        //         }
       
        //     }
            
        

      
    /*To save Newly created fundraising record*/

        saveNewRecord(){
        this.tabValue = this.switchTabValue;
        if(this.objName == "Account"){
            this.recordPassId = this.selectedFundId;
            this.passLegalId = this.selectedId;
            
        }else if(this.objName == "Fund"){
            this.recordPassId = this.selectedId;
            this.passLegalId = this.selectedLegalId;
            
        }
        if(this.landingPageObjApiName === 'Contact'){
            this.passLegalId = this.selectedLegalId;
        }
        createFundRaising({record : JSON.stringify(this.fundRaisingRecord),fundRaisingName:this.fundRaisingName,fundName: this.recordPassId,
                            legalId:this.passLegalId,fundNewName:this.newFundName,legalNewName:this.investorNewName,companyNewName:this.newCompanyName,tabChangeValue:this.tabValue})
            .then(result=>{
                    if(result !== null){
                        //Updated toast msg by LK on 2024-05-29 to fix 00045964
                        this.genericShowToastMessage('Fundraising "'+this.fundRaisingName+'" was created','success','');
                        
                        this.dispatchEvent(new CustomEvent('checkselected', {detail: false }));
                        this.openModal = false;
                    }
                }).catch(error=>{
                this.genericShowToastMessage(error.body.message,'error','sticky');    
                this.selectedCompanyId = '';
                this.selectedLegalId = '';
        })
        .catch(error=>{
            this.genericShowToastMessage(error.body.message,'error','sticky');
        })
        
    }


        handleLoad(){
            this.areDetailsVisible = true;
        }

        handleInvestortName(event){
            this.investorNewName = event.detail;
            this.fundRaisingName =  this.investorNewName+'-'+this.Name; //critical bug fix smoke R15.
        }

        handleCompanyName(event){
            this.newCompanyName = event.detail;
            
        }

        handleFundName(event){
              this.selFundName = event.detail;//Added by LK on 2024-05-09 to fix 00045523
              this.newFundName = event.detail;
              this.fundRaisingName = this.legalHeadingName+'-'+this.newFundName; //critical bug fix smoke R15.
        }

        handleAmount(event){
            if(event.target.dataset.id == 'l1'){
                    this.amount = event.target.value;
                    this.fundRaisingRecord.likelyAmountField = this.amount;
            }
            }

            handleStage(event){
                if(event.target.dataset.id == 'stage1'){
                    this.stages = event.target.value;
                    this.fundRaisingRecord.stage = this.stages;
                
                }
            }

            handleClosingField(event){
                if(event.target.dataset.id == 'close'){
                    this.closeFields = event.target.value;
                    this.fundRaisingRecord.closingField = this.closeFields;
              
                }
            }
            
            handleClosingDateField(event){
                if(event.target.dataset.id == 'dateField'){
                    this.dateValue = event.target.value;
                    this.fundRaisingRecord.closingDateField = this.dateValue;
               
                }
            }

            handleSelectedRecord(event){
                let obj = {};
                obj = JSON.parse(event.detail);
                this.selectedLegalId = obj.data.Id;
                this.fundRaisingName = obj.data.Name+'-'+this.Name; // Critical fix smoke R15
            }

            handleSelectedRecordCon(event){
                let obj = {};
                obj = JSON.parse(event.detail);
                this.selectedLegalId = obj.data.Id;
                //Added if clause by LK on 2024-05-26 to fix 00045663 ; 00045964
                if(this.landingPageObjApiName === 'Contact'){
                    this.legalHeadingName = obj.data.Name;
                }
                //Updated below code by LK on 2024-05-09 to fix 00045523
                this.fundRaisingName = obj.data.Name+'-'+this.selFundName; //critical bug fix smoke R15.
            }



            handleSelectedCompanyRecord(event){
                let companyObj = {};
                companyObj = JSON.parse(event.detail);
                if(companyObj.data !== ""){
                    this.selectedCompanyId = companyObj.data.Id;
                    this.fundRaisingRecord.companyId = this.selectedCompanyId;
                    this.companyRecordType = companyObj.data.RecordType.Name;
                }
            }
            

            handleSelectedFundRecord(event){
                let fundObj = {};
                fundObj = JSON.parse(event.detail);
                this.selectedFundId = fundObj.data.Id;
                //Commented below code by LK on 2024-05-09 to fix 00045523
                /*if(this.landingPageObjApiName === 'Contact'){
                    this.newFundName = fundObj.data.Name;
                }*/
                //Added if clause and moved existing code inside else clause by Lk on 2024-05-27 to fix 00045663 ; 00045964
                if(this.landingPageObjApiName === 'Contact'){
                    this.selFundName = fundObj.data.Name;
                    this.fundRaisingName =  this.legalHeadingName+'-'+this.selFundName;
                } else {
                    this.fundRaisingName =  this.legalHeadingName+'-'+fundObj.data.Name;
                }
                this.getFundRecordDetails(this.selectedFundId);
            }

            // to get fund record details
            getFundRecordDetails(fundIdSelected){
                getFundRecordDetails({fundId:fundIdSelected})
                 .then(result=>{
                    if(result[0].navpeII_dev18__Investment_Category__c === "Co-investment"){
                        this.companyCheck = true;
                    }else if(result[0].navpeII_dev18__Investment_Category__c === "Fund"){
                        this.companyCheck = false;
                        this.newCompanyName = '';   //critical bug fix 00039559 PE5.1_TR1
                    }
                 }).catch(error=>{
                  this.error = error;
                 })
            }
            
    
    openNewFundraising(invest,type){
        if(type === invest){
            this.openModal = true;
            this.openCoinvestmentModal = true;
        }else if(type === this.fundType){
            this.openModal = true;
            this.openCoinvestmentModal = false;
        }
     }
    

     closeNewFundraising(){
        this.openModal = false;
        this.openCoinvestmentModal = false;
        this.dispatchEvent(new CustomEvent('checkselected', {detail: false }));
     }

     /*Generic toast message method */

     genericShowToastMessage(messageNew,variantNew,modeNew){
        const toastEvent = new ShowToastEvent({
            message: messageNew,
            variant: variantNew,
            mode: modeNew
        });
        this.dispatchEvent(toastEvent);
     }


     renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `.auto_populate_field input{
            border: none !important;
            background: none !important;
            padding: 0px !important;
            font-size: 14px !important;
        }
        .auto_populate_field lightning-icon.slds-icon_container.slds-combobox__input-entity-icon.slds-icon-standard-account{
            display: none;
        }
        .auto_populate_css lightning-icon.slds-icon_container.slds-combobox__input-entity-icon.slds-icon-custom-custom34{
            display: none;
        }
        .auto_populate_css input{
            border: none !important;
            background: none !important;
            padding: 0px !important;
            font-size: 14px !important;
        }
        .pd-left .pill_div{
            padding-left : 0px !important;
        }
        
        .css_padding{
            padding: 0 0.25rem 0 0.25rem;
            margin-right: 10px;
        }
        
        .lablehide .slds-form-element__label:empty {
            display: none;
        }
        .spinner_css.slds-spinner_container {
            right: -90vh !important;
            left: -90vh !important;
        }`; 
        this.template.querySelector('.main-fundrasing')?.appendChild(style);
     }
    }