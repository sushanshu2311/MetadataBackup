import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService'; 
import messagingChannel from "@salesforce/messageChannel/navatarClipAuraUtilityBarChannel__c"; 
import getAllClipsRecords from '@salesforce/apex/NavatarAllClipsCtrl.getAllClipsRecords';

export default class NavatarAllClipsViewModalLwc  extends NavigationMixin(LightningElement) {
    @track isModalOpenview = false;
    @track mySlideV;
    @track indexMap ={'minIndex':0,'maxIndex':0,'currentIndex':0};
    @track prevdisableButtonMock = true;
    @track nextDisableButtonMock = true;
    @track tagDataList =[];
    @api gridDataList = [];
    @track selectedData = {};
    @track sendEmailView=false;
    @wire(MessageContext) messageContext;
    @api clipIcon;
    @api
     openModal(text) {
         // to open modal set isModalOpen tarck value as true
         this.isModalOpenview = true;
         setTimeout(() => {
             let sectmodal = this.template.querySelector(".slds-modal");
             let bodyClose = sectmodal.closest('body');
             bodyClose.style.overflow = "hidden";
             console.log(bodyClose,'bodyClose');
 
         }, 0);
     }

     @api
     openModalNew(selectedDataOpen, gridDataListLocal) {
       this.gridDataList = JSON.parse(JSON.stringify(gridDataListLocal));
        this.indexMap.maxIndex = this.gridDataList.length-1;
        this.setSelectedDataForScreen(selectedDataOpen);

        this.isModalOpenview = true;
    }
    //Added by Anshika Ahuja called from Themes page on click of Clip name 29-12-2022
    @api
    openModalSingleClip(clipRecordId){
        let clipRecIdList = [];
        clipRecIdList.push(clipRecordId);
        getAllClipsRecords({clipsIdList: clipRecIdList})
        .then(res => {
        this.isModalOpenview = true;
        let selectedData={
            index: 0,
            id: res[0].Id,
            nameName: res[0].Name,
            Summary: res[0].Summary,
            Notes: res[0].Notes,
            tagName: res[0].ClipsTagsRef,
            date: res[0].CreatedDate
        };
        let recordWrapper = selectedData;
        this.setSelectedDataForScreen(recordWrapper);
        })
        .catch(err => {
        })
    }

     closeModal() {
         // to close modal set isModalOpen tarck value as false
        this.isModalOpenview = false;
        let sectmodal = this.template.querySelector(".slds-modal");
 
        let bodyClose = sectmodal.closest('body');
        bodyClose.style.overflow = "auto";
        console.log(bodyClose,'bodyClose');
        /* for caousel reset*/
        this.currentindexno = 0; 
        this.i = 0;
        this.getdisabled = false;
        this.prevdisableButton = true;
        this.currentindex = 0;
       
         /* for caousel reset*/
      
     }

     isEmail
     
     handlesendEmailClick(event){
         console.log("hello:: email"+ this.selectedData.id);
        //  const objChild = this.template.querySelector('c-add-Notes-Popup');
        //  objChild.openModal();
        //  this.isModalOpenview = false;
        this.isModalOpenview = false;
        this.sendEmailView= true;
      
         let sectmodal = this.template.querySelector(".slds-modal");
 
        let bodyClose = sectmodal.closest('body');
        bodyClose.style.overflow = "auto";
        console.log(bodyClose,'bodyClose');
        /* for caousel reset*/
        this.currentindexno = 0; 
        this.i = 0;
        this.getdisabled = false;
        this.prevdisableButton = true;
        this.currentindex = 0;
       
       if(this.sendEmailView){
        const modalPopup = this.template.querySelector('c-navatar-Send-Email-Lwc');
         modalPopup.openModal(this.selectedData.id);
       }
       
             }

     handleNoteClickTaskview(evt) {
      this.isModalOpenview = false;
         let sectmodal = this.template.querySelector(".slds-modal");
 
        let bodyClose = sectmodal.closest('body');
        bodyClose.style.overflow = "auto";
        console.log(bodyClose,'bodyClose');
        /* for caousel reset*/
        this.currentindexno = 0; 
        this.i = 0;
        this.getdisabled = false;
        this.prevdisableButton = true;
        this.currentindex = 0;
      //  localStorage.setItem("storePopupId", "a0p7e000006Mkj5AAC");
        let message = { message : this.selectedData.id };
        publish(this.messageContext, messagingChannel, message);

     }



    

    // handlesendEmailClick() {
    //     this.isModalOpen = false;
    //     const objChild = this.template.querySelector('c-send-Email-Popup');
    //     objChild.openModal(this.recordId);
    // }

    // handlesendEmailClick() {
    //     this.isModalOpenview = false;
    //       let sectmodal = this.template.querySelector(".slds-modal");
  
    //      let bodyClose = sectmodal.closest('body');
    //      bodyClose.style.overflow = "auto";
    //      console.log(bodyClose,'bodyClose');
    //      /* for caousel reset*/
    //      this.currentindexno = 0; 
    //      this.i = 0;
    //      this.getdisabled = false;
    //      this.prevdisableButton = true;
    //      this.currentindex = 0;
    //      let ev = new CustomEvent('childmethod', 
    //           {isEmail : true}
    //          );
    //      this.dispatchEvent(ev);
    //  }
    /* Carousel*/ 
     currentindexno = 0; 
     i = 0;
     @track getdisabled = false;
     @track prevdisableButton = true;
     @track currentindex = 0;
     
     nextslide(event){  
         let items= this.template.querySelectorAll('.slds-carousel__panel');
         this.i = (this.i+1);
         console.log("this.i",  this.i);
         console.log("items.length", items.length);
         if (items.length -2 < this.i) {
            //  this.i = 0
             this.getdisabled = true;
         }
         console.log(">>> A N ", this.i);
         if(items.length-1  >= this.i ){
             this.prevdisableButton = false;
         }else{
             this.getdisabled = true;
         }
         items.forEach(item => {
            item.classList.remove('active')
        })
         if(items.length >= this.i ){
             items[this.i].classList.add('active');
             items[this.i-1].classList.add('hideextraslide');
             items[this.i].classList.remove('hideextraslide');
         }
         this.prevdisableButton = false;
         
     }
     prevslide(){
         let items= this.template.querySelectorAll('.slds-carousel__panel');
         this.i = (this.i-1);
         console.log(">>> A N prev", this.i);
         if (0 >= this.i) {
             this.i = 0;
             this.prevdisableButton = true;
             this.getdisabled = false;
         }
         items.forEach(item => {
            item.classList.remove('active');
         })
         
         if(items.length >= this.i+1 ){
             items[this.i].classList.remove('active');
             items[this.i].classList.remove('hideextraslide');
             items[this.i+1].classList.add('hideextraslide' );
             
         }
         this.getdisabled = false;
     }
    /* Carousel*/ 

    setSelectedDataForScreen(selectedDataLocal) {
        console.log('data received from clips '+JSON.stringify(selectedDataLocal));
        this.selectedData = selectedDataLocal;
        this.indexMap.currentIndex = parseInt(this.selectedData.index);
        this.prevdisableButtonMock = (this.selectedData.index == this.indexMap.minIndex);
        this.nextDisableButtonMock = (this.selectedData.index == this.indexMap.maxIndex);
        var tagsData = this.selectedData.tagName;
        if(tagsData !='' || tagsData!= undefined) {     
            this.setTagData(tagsData);
        }
     } 

     setTagData(tagData) {
       
        this.tagDataList = [];
       
        for(let data in tagData) {
            this.tagDataList.push({
                index : tagData[data].index,
                tag : tagData[data].tag || tagData[data].name,
                tagRef :tagData[data].tagRef || tagData[data].nameRef,
                iconName :tagData[data].iconName
            })
        }
     }

    /* setTagData(tagData) {
        this.tagDataList = [];
        var tagDataList = tagData.split(',');
        for(var data in tagDataList) {
            this.tagDataList.push({
                index : data,
                value : tagDataList[data]
            })
        }
     }*/

     prevslidemock(evt) {
        var currentIndexLocal = this.indexMap.currentIndex - 1;
        if(currentIndexLocal >= this.indexMap.minIndex) {           
            this.setSelectedDataForScreen(this.getIndexedRecord(currentIndexLocal))
        }
     }

     nextslidemock(evt) {
        var currentIndexLocal = this.indexMap.currentIndex + 1;
        if(currentIndexLocal <= this.indexMap.maxIndex) {
            this.setSelectedDataForScreen(this.getIndexedRecord(currentIndexLocal))
        }

     }

     getIndexedRecord(index) {
        var indexedData = {};
        for(var d in this.gridDataList) {
            if(this.gridDataList[d].index == index) {
                indexedData = this.gridDataList[d];
                break;
            }
        }
        return indexedData;

     }
    
    
     renderedCallback(){
         const style = document.createElement('style');
         style.innerText = `.arrowBtn .slds-button__icon{
            height: 30px;
            width: 30px;
         }
         .arrowBtn .slds-button:focus{
            box-shadow:none !important;
            border:none !important;
            outline: none!important;
         } 
         .slds-pill__remove{
            display:none !important;
         }
         .noteareacss textarea.slds-textarea{
            border: none !important;
            overflow-y: auto;
            padding: 0px 0px;
            box-shadow: none;
            height: 100px !important;
            max-height: 110px;
            resize: none;
         }
         .noteareacss .slds-form-element__label:empty{
            display: none;
         }
         `;
         this.template.querySelector('.arrowBtn')?.appendChild(style);
        
     }


     handlePrint(){
        window.open(window.location.origin+'/apex/navpeII_dev18__ClipPDF?id='+this.selectedData.id);

     }
}