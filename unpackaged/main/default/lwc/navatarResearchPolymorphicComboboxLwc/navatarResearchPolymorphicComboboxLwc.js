/****************************************************************************************************

** Module Name : theme lookup , dynamic lookup on advance part.

** Description : Custom lookup component to search across all Navatar Research Page Functionaality.

** Throws : NA

** Calls : NavatarReseachAdvanceChildCmpLwc

** Organization : Navatar Group

** Product Name & Version : phase 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-11-21          Ehatsham Ahamed

****************************************************************************************************/
import ExternalId from '@salesforce/schema/Product2.ExternalId';
import { LightningElement, api, track, wire } from 'lwc';

import option1 from './navatarResearchPolymorphicComboboxLwc.html';
//import option2 from './customLookupResearchLWC2.html';
export default class NavatarResearchPolymorphicComboboxLwc extends LightningElement {
    @api whichone = 'first';
    @api currFunctionalityChecker=false;
    @api currPageRecordObj;
    @api currPageRecordId;
    @api objOptionList;
@track objName;
@track selectedComingRecordList=[];
    /* add new rows for Search for specific records and Search by field parameters*/  
    @track operationList=[]      
    @track listOfAccounts=[];
    @track listOfAccountsPara;
    @track makingObj;
    valueSpecefic = 'Select';
    renderDO=false;
    connectedCallback() {
        this.renderDO=true;
        //alert('danish -->'+this.currPageRecordObj);
        if(this.currPageRecordId != '' && this.currPageRecordId != undefined){
       
            this.currFunctionalityChecker=true;
            this.valueSpecefic=this.currPageRecordObj;
            }
        this.objName='Account';
        this.initData();
        
        if(this.propertyValue == '300'){
            this.advanceSearch = true;
            this.mainSearchfromTheme = true;
            this.mainSearch = false;
        }
       // this.currPageRecordId='';
    }
    render() {
        return this.whichone === 'first' ? option1 : option2;
      }
    initData() {
        let listOfAccounts = [];
      
        this.createRow(this.listOfAccounts);
       
        //this.listOfAccounts = this.listOfAccounts;
        
        
    }
    get disableMoreRows(){ 
        
          return (this.listOfAccounts.length >= 10 || this.listOfAccounts.length < 1);
        
    }
    createRow(lookupList) {
        let accountObject = {obj:"Account",currId:"",RecordName:"",iconName:"",loopkUp:true};
        accountObject.obj="";
        if(this.currPageRecordId != null && this.currPageRecordId != undefined){
           // alert('DDD');
            accountObject.obj=this.currPageRecordObj;
            accountObject.currId=this.currPageRecordId;
        }
        if(lookupList.length > 0) {
            accountObject.indexOrder = lookupList[lookupList.length - 1].indexOrder + 1;
        } else {
            accountObject.indexOrder = 1;
        }
        if( accountObject.indexOrder == 1){
             accountObject.hideBtn = false;
        }else{
            accountObject.hideBtn = true;
        }
        this.listOfAccounts.push(accountObject);
        this.currPageRecordId=null;
    }
    
    addNewRow() {
        if(!this.template.querySelector('.posibtn1').classList.contains('btnposition_btn1')){
            this.template.querySelector('.posibtn1').classList.add('btnposition_btn1');
        }
        
        if(this.template.querySelector('.posibtn1').classList.contains('position_btn1')){
            this.template.querySelector('.posibtn1').classList.remove('position_btn1');
        }
        
        this.currFunctionalityChecker=false;
        
        //this.selectedComingRecordList.push(this.makingObj);
        this.makingObj='';
        
        this.createRow(this.listOfAccounts);
        
    }
    
    removeRow(event) {
        
        let bgWhite = event.target.closest('.dnone')
        bgWhite.classList.add('d_none');
       // alert('Ehatsham is ready'+parseInt( event.currentTarget.dataset.storeindex));
        
       if( this.selectedComingRecordList.length >= parseInt( event.currentTarget.dataset.storeindex)){
        this.selectedComingRecordList.splice(event.currentTarget.dataset.storeindex,1);
        //for(var i=parseInt( event.currentTarget.dataset.storeindex);i<this.selectedComingRecordList.length-1 ;i++){
            //this.selectedComingRecordList[parseInt(event.currentTarget.dataset.storeindex)]=this.selectedComingRecordList[parseInt(event.currentTarget.dataset.storeindex)+1];
            
        //}
       // this.selectedComingRecordList.pop();
        
        
    }else{
        this.selectedComingRecordList.pop();
    }
        
        if( this.listOfAccounts.length >= parseInt( event.currentTarget.dataset.storeindex)){
            this.listOfAccounts.splice(event.currentTarget.dataset.storeindex,1);
            if(this.renderDO){
                this.renderDO=false;
            }else{
                this.renderDO=true;
            }
            
      //  for(var i=parseInt( event.currentTarget.dataset.storeindex);i<this.listOfAccounts.length-1 ;i++){
         //   this.listOfAccounts[parseInt(event.currentTarget.dataset.storeindex)]=this.listOfAccounts[parseInt(event.currentTarget.dataset.storeindex)+1];
      //  }

    }else{
        this.listOfAccounts.pop();
    }
    
       if(this.listOfAccounts.length == 1){
            this.template.querySelector('.posibtn1').classList.remove('btnposition_btn1');
            this.template.querySelector('.posibtn1').classList.add('position_btn1');
        }
        
    }
    

    get optionsSpecefic() {
        return this.objOptionList;
        /*[
            { label: 'Firm', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
            { label: 'Deal', value: 'navpeII_dev18__Pipeline__c' },
            { label: 'Fund', value: 'navpeII_dev18__Fund__c' },
            { label: 'Fundraising', value: 'navpeII_dev18__Fundraising__c' },
            { label: 'Theme', value: 'Theme__c' }
        ];*/

    }
    handleChangeSpecefic(event) {
        this.value = event.detail.value;
        
        this.listOfAccounts[event.currentTarget.dataset.indexvalue].obj=this.value;
        this.vanishDataAccordingIndex(event.currentTarget.dataset.indexvalue);
     //   if(this.selectedComingRecordList.length > 0){
     //       this.selectedComingRecordList.pop();
    //  }
    }
    /* add new rows for Search for specific records and Search by field parameters*/


    handleSelectedCompanyRecord(event){
        //alert(event.detail.iconValue);
    try{
        
       this.makingObj='';
       var comingId=event.detail.data.Id;
       var achievers=false;
       var obj={Id:event.detail.data.Id,RecordName:event.detail.data.Name,ObjName:event.detail.obj,index:event.detail.indexData , currentFunCheck:event.detail.currentFeatureDisabled};

        /*if(this.selectedComingRecordList.length > 0){
         achievers = this.selectedComingRecordList.find(function (crossCheckData) {
            if(crossCheckData.Id != undefined ){
                return crossCheckData.Id == comingId;
            }
            
        });
    }*/
        
       // alert(JSON.stringify(this.selectedComingRecordList[parseInt(event.detail.indexData)]) +'--'+parseInt(event.detail.indexData) );
        //alert(this.selectedComingRecordList.length +'--'+parseInt(event.detail.indexData) );
        if(this.selectedComingRecordList.length-1 >= event.detail.indexData){
             this.selectedComingRecordList[parseInt(event.detail.indexData)]=obj;
             achievers=true;
        }
        this.listOfAccounts[parseInt(event.detail.indexData)].currId=comingId;
        this.listOfAccounts[parseInt(event.detail.indexData)].RecordName=event.detail.data.Name;
        this.listOfAccounts[parseInt(event.detail.indexData)].iconName=event.detail.iconValue;
        this.listOfAccounts[parseInt(event.detail.indexData)].loopkUp=false;
        
        if(!achievers){
        this.selectedComingRecordList.push(obj);
        /* this.listOfAccounts[parseInt(event.detail.indexData)].currId=comingId;
        this.listOfAccounts[parseInt(event.detail.indexData)].RecordName=event.detail.data.Name;
        this.listOfAccounts[parseInt(event.detail.indexData)].iconName=event.detail.iconValue;
        this.listOfAccounts[parseInt(event.detail.indexData)].loopkUp=false; */

        this.makingObj=obj;
        
        
        }
    
}catch(e){
//alert(JSON.stringify(e.message));
//alert(JSON.stringify(e.description));
//alert(JSON.stringify(e.lineNumber));
}
    }

    @api
    saveButtonHandling(){
        
        var objValue={recordList : this.selectedComingRecordList,currentSelectedRecord: this.makingObj};
        
        const passEvent = new CustomEvent('lookupupdatehandler', {
            detail:objValue
        });
        this.dispatchEvent(passEvent);
        //alert('go to back save advance comp');
    }

   renderedCallback(){

    const style = document.createElement('style');
    style.innerText =`.lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
        position: absolute;
        right: 2px;
        top: 1px;
         }
         .position_btn1 .slds-button{
            height:30px;
            width:30px;
            border: none;
        }
        .position_btn1 .slds-button_icon{
            fill: #0176d3 !important;
        }
        .position_btn1{
            position: relative;
            top: auto;
            right: 92px;
        }
        @media (max-width: 1512px) {
            .position_btn1{
                right: 64px;
            }
        }`;
this.template.querySelector('.main-Container-filter').appendChild(style);
const style1 = document.createElement('style');
        style1.innerText = `.pillwidth span.slds-pill {
            width: 100%;
        }
        .pillwidth lightning-button-icon.slds-pill__remove{
            position: absolute;
            right: 0;
        }
        .pillwidth .slds-pill{
            justify-content: flex-start !important;
        }
        .slds-form-element__label:empty{
            display: none;

        }
    }`;	
        this.template.querySelector('.pill_div')?.appendChild(style1);
    
         


   }
   vanishDataAccordingIndex(indexNumber){
    //alert('kk'+indexNumber);
    this.listOfAccounts[indexNumber].currId="";
    this.listOfAccounts[indexNumber].iconName="";
    this.listOfAccounts[indexNumber].RecordName="";
    this.listOfAccounts[indexNumber].loopkUp=true;
    var obj={Id:'',RecordName:'',ObjName:'',index:indexNumber , currentFunCheck:false};
    this.selectedComingRecordList[indexNumber]=obj;
   }
   handleRemovePill(event){
   // alert('vv'+event.currentTarget.dataset.listindexorder);
    this.listOfAccounts[event.currentTarget.dataset.listindexorder].currId="";
    this.listOfAccounts[event.currentTarget.dataset.listindexorder].iconName="";
    this.listOfAccounts[event.currentTarget.dataset.listindexorder].RecordName="";
    this.listOfAccounts[event.currentTarget.dataset.listindexorder].loopkUp=true;
    var obj={Id:'',RecordName:'',ObjName:'',index:event.currentTarget.dataset.listindexorder , currentFunCheck:false};
    this.selectedComingRecordList[event.currentTarget.dataset.listindexorder]=obj;
    
   
   }
   @api
   handleRemovePillFromOtherCmp(event){
    //alert(event.detail.indexData);
    this.listOfAccounts[event.detail.indexData].currId="";
    this.listOfAccounts[event.detail.indexData].iconName="";
    this.listOfAccounts[event.detail.indexData].RecordName="";
    this.listOfAccounts[event.detail.indexData].loopkUp=true;
    var obj={Id:'',RecordName:'',ObjName:'',index:event.detail.indexData , currentFunCheck:false};
    this.selectedComingRecordList[event.detail.indexData]=obj;
   }
   
}