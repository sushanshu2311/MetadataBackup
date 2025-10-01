import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAllClipsRecords from '@salesforce/apex/NavatarAllClipsCtrl.getAllClipsRecords';
import getSearchedThemes from '@salesforce/apex/NavatarAllClipsCtrl.getSearchedThemes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getThemeFields from '@salesforce/apex/NavatarAllThemesCtrl.getThemeFields';


export default class NavatarAllClipsLwc extends LightningElement {
    popoverFilterCheckbox = false;
    urlId2;
    popoverFilterCheckbox = false;
    data;
    clipData;
    clipsList;
    @track isExistData;
    searchValue='';
    @track selectedData = {};
    urlParamsMap = {};
    urlClipParam=''; //Added by Anshika Ahuja called from Themes page on click of Clip name 29-12-2022
    clipId;
    @track showEditTagModal = false;
    @track editRecordId = '';
    @track clipsDataList;
    enableSpinner = true;
    isFirstTimeCalled=true;
    clipIcon ='utility:copy_to_clipboard'; // Added by Hema - changed the clip icon on view - 00035174
    clipCol=[];
    errorMessage;


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
            let urlStateParameters = currentPageReference.state;
          this.urlId2 = urlStateParameters.c__isModalOpen || null;
       } 
        //Added by Anshika Ahuja called from Themes page on click of Clip name 29-12-2022
        if(currentPageReference && currentPageReference.state.c__clipParams != 'undefined'){
            this.urlClipParam = currentPageReference.state.c__clipParams;
        }
    }

    get checkBoxOptions() {
        return [
            { label: 'Email', value: 'option1' },
            { label: 'Meetings', value: 'option2' },
            { label: 'Calls', value: 'option3' },
        ];
    }

    isClickOutside() {
        var modal = document.getElementById('id01');

        // When the user clicks anywhere outside of the modal, close it
        window.onclick = function (event) {
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    }

    /*Today*/
    popoverHandleClick() {
       
        setTimeout(() => {
            this.popoverFilterCheckbox = true;
        } );
    }

    closepopoverHandleClick() {
        this.popoverFilterCheckbox = false;
        
    }
    oncloseFilterOutside(event){
        this.popoverFilterCheckbox = false;
    }

    handleRowActions(event) {
        
        if (event.detail.action.name === 'callname') {
            let selectedRec = event.detail.row;
            this.setClipsData();
            const rows = this.clipsDataList;
            const filtered = this.clipsDataList.find( (obj) => {
                return ( obj.nameName === selectedRec.Name); 
              });
            let arr = 
            {
                index: filtered.index,
                id: selectedRec.Id,
                nameName: selectedRec.Name,
                Summary: selectedRec.Summary,
                Notes:selectedRec.Notes,
                tagName: selectedRec.ClipsTagsRef,
                date: selectedRec.CreatedDate
              };
              this.selectedData= arr;
            const objChild = this.template.querySelector('c-navatar-All-Clips-View-Modal-Lwc');
            
            objChild.openModalNew(this.selectedData, this.clipsDataList);
        }
        else if (event.detail.action.name === 'tagged') {
						
                if(event.detail.row.ClipsTags!=undefined){
										
                const modalPopup = this.template.querySelector('c-navatar-Acuity-Interaction-Column-Popup-Lwc');
										
                        modalPopup.associatesWrapper = event.detail.row.ClipsTagsWrapper;
                        modalPopup.popupTitle = 'Tagged';
                        modalPopup.showTeamsScreen = false;
                        modalPopup.isClipView = true;
                        modalPopup.openModal();
                        this.enableSpinner = false;
            }
           
        }

    }
    connectedCallback(){
        /*let parentThis = this;
        this.template.addEventListener('click',function(e){              
                if(!e.target.closest(".myfilter") && parentThis.popoverFilterCheckbox ){
                    parentThis.closepopoverHandleClick()
                }          
            }); */  //Modified by Hema 14-03-2023
             
            getThemeFields({
            }) .then(result=>{
            this.clipCol=[
            { label: 'Date', fieldName: 'date', type: 'text', initialWidth: 110, sortable: false, hideDefaultActions: true ,class: { fieldName: 'slds-border_left' }},
            { label: 'Tags', fieldName: 'ClipsTags', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'tagName', }, name:'tagged',variant: 'base',  tooltip: { fieldName: 'tagName' }},cellAttributes:{ class: 'text_underline'}},
            { label: 'Created By', fieldName: 'CreatedBy', wrapText: true, type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'createdby' }, target: '_blank',variant: 'base', tooltip: { fieldName: 'createdby' }, title: { fieldName: 'createdby' }},cellAttributes:{ class: 'text-black'}},
            ];
            if(result.ClipHeader1){
                this.clipCol.splice(1, 0, { label: result.ClipHeader1,  fieldName: 'Name',  type: 'button',  hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'nameName', }, variant: 'base', name: 'callname', tooltip: { fieldName: 'nameName' }},cellAttributes:{ class: 'text_underline'}})
            }
            if(result.ClipHeader2){
                this.clipCol.splice(2, 0,{ label: result.ClipHeader2, fieldName: 'Details',initialWidth: 450, wrapText: true, type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'Details' }, target: '_blank',variant: 'base', tooltip: { fieldName: 'Details' }, title: { fieldName: 'Details' }},cellAttributes:{ class: 'text-black'}})   
            }
           
        })
            getAllClipsRecords({

            }).then(result=>{
                this.data= result;
                this.clipData= result;
                this.handleTableData();
                if(this.urlId2 != '' && this.urlId2 != undefined){
                    
                        const filtered = this.data.find( (obj) => {
                            return ( obj.Id.substring(0, 15) == this.urlId2.substring(0, 15)); 
                        });
                        let reocrds = [];
                        reocrds.push(filtered);
                        let arr = 
                        {
                            index: filtered.index,
                            id: filtered.Id,
                            nameName: filtered.Name,
                            Summary: filtered.Summary,
                            Notes:filtered.Notes,
                            tagName: filtered.ClipsTagsRef,
                            date: filtered.CreatedDate
                        };
                        this.selectedData= arr;
                        const objChild = this.template.querySelector('c-navatar-All-Clips-View-Modal-Lwc');
                        
                        objChild.openModalNew(this.selectedData, reocrds);

                    
                    
                }

            }).catch(error=>{
                this.enableSpinner = false;
                this.showToast(this, 'Error!', error.body.message, 'error','dismissible');
            })

         

    }
   
    setClipsData() {
        let tempRecords = JSON.parse( JSON.stringify( this.data ) );
        var tempList=[];
        for(let i=0; i<tempRecords.length; i++){
            let arr={
                index:i,
                id: tempRecords[i].Id,
                nameName: tempRecords[i].Name,
                Summary: tempRecords[i].Summary,
                Notes:tempRecords[i].Notes,
                tagName: tempRecords[i].ClipsTagsRef,
                date: tempRecords[i].CreatedDate
            };
            tempList.push(arr);
        }
        this.clipsDataList = tempList;

    }

    // handle table data
    handleTableData(){
        if(this.data.length>0){
        let tempRecords = JSON.parse( JSON.stringify( this.data ) );
             tempRecords = tempRecords.map( row => {
                 return { ...row, nameName : row.Name , Details :  row.Summary, date :  row.CreatedDate,createdby: row.CreatedBy,tagName : row.ClipsTags
                       };
             })
             this.clipsList = tempRecords;
             this.isExistData = true;
             this.enableSpinner = false;
            }
            else{
                this.isExistData = false;
                this.clipsList =[];
                this.enableSpinner = false;
            }
            this.enableSpinner = false;
    }

    /* edit pop overlap*/
    handleNotePopup() {
        this.showEditTagModal = true;
        this.editRecordId = evt.detail.recId
       
    }

    renderedCallback() {
        //Added by Anshika Ahuja called from Themes page on click of Clip name 29-12-2022
        const modalPopup = this.template.querySelector('c-navatar-All-Clips-View-Modal-Lwc');
        if(modalPopup && this.isFirstTimeCalled && this.urlClipParam != undefined){
            modalPopup.openModalSingleClip(this.urlClipParam);
            this.isFirstTimeCalled=false;
        }
        let lineClamp = document.createElement('style');
        let SubjectlineClamp = document.createElement('style');
        lineClamp.innerText = '.viewallScreen .slds-hyphenate {display: -webkit-box;-webkit-box-orient: vertical;overflow: hidden;text-overflow: ellipsis;-webkit-line-clamp: 2;white-space: pre-line;word-wrap: break-word;hyphens: auto; }';
        SubjectlineClamp.innerText = '.viewallScreen .slds-truncate {display: -webkit-box;-webkit-box-orient: vertical;overflow: hidden;text-overflow: ellipsis;-webkit-line-clamp: 2;white-space: pre-line;word-wrap: break-word;hyphens: auto; max-width: 100%;}';
        // this.template.querySelector('lightning-datatable').appendChild(lineClamp);

        let butnText = document.createElement('style');     
        butnText.innerText = `.viewallScreen .slds-button {
             text-align: left;
             line-height: 18px;
             white-space: nowrap;
             text-overflow: ellipsis;
             max-width: 100%;
             display: block;
             overflow: hidden;
           }
        .flexipageHeader {
            display: none !important;
        }
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .viewallScreen .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .viewallScreen .slds-is-resizable .slds-th__action:focus,
        .viewallScreen .slds-is-resizable .slds-th__action:focus:hover,
        .viewallScreen .slds-table th:focus,
        .viewallScreen .slds-table th.slds-has-focus,
        .viewallScreen .slds-table [role="gridcell"]:focus,
        .viewallScreen .slds-table [role="gridcell"].slds-has-focus,
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover > th,
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover > td {
          box-shadow: none !important;
        } 
        .viewallScreen .slds-th__action:focus, .slds-th__action:hover,
        .viewallScreen .slds-table tr:hover{
          box-shadow: none !important;
        } 
        .viewallScreen .slds-th__action{
            background: #f3f3f3 !important;
        }
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>th{
            background: none !important;
        }
        .viewallScreen .slds-table:not(.slds-no-row-hover) tbody tr:hover>td{
            background: none !important;
        }
        .viewallScreen .slds-button:focus{
            box-shadow: none;
        }
        .viewallScreen .button.slds-button:active, .viewallScreen .slds-button:active{
            border: none;
        }
        .viewallScreen .button.slds-button{
            border: none;
        }
        .text_underline button.slds-button:hover{
            text-decoration : underline;
        }
        td.text-black{
            height: 41px;
        }`;
        
        const style = document.createElement('style');
        style.innerText = `.text-black button.slds-button{
            color:#000 !important;
            white-space: nowrap;
            text-overflow: ellipsis;
            max-width: 100%;
            display: block;
            overflow: hidden;
            cursor : text;
            border: none;
        }`;

        try {
            this.template.querySelector('lightning-datatable').appendChild(butnText);
            this.template.querySelector('lightning-datatable').appendChild(lineClamp);
            this.template.querySelector('lightning-datatable').appendChild(SubjectlineClamp);
            this.template.querySelector('.main-Container-clip')?.appendChild(style);
        }
        catch (err) {
        }
        
    }
    handleKeyUp(event) {
    
        const isEnterKey = event.keyCode === 13;
        if(isEnterKey){
            this.enableSpinner = true;
            this.searchValue = event.target.value;
        if (this.searchValue !== '' && this.searchValue.length >1) {
            this.template.querySelectorAll("lightning-input").forEach(item => {
                item.setCustomValidity("");
                item.reportValidity();
            });
            getSearchedThemes({
            searchTerm :  this.searchValue.trim()
           }).then(result=>{
            this.data = result;
            this.handleTableData();
              
           }).catch(error=>{
            this.enableSpinner = false;
                this.showToast(this, 'Error!', error.body.message, 'error','sticky');
           })
         } 
        else {
            this.template.querySelectorAll("lightning-input").forEach(item => {
                let fieldValue=item.value;
                if(fieldValue.length <=1){  
                    this.errorMessage = "Your search term must have 2 or more characters";
                    item.setCustomValidity(this.errorMessage); 
                } 
                else{
                    item.setCustomValidity("");
                    }
                item.reportValidity();  
                });
            this.enableSpinner = false;
        }
    } else if(event.target.value.length===0){
        this.data=this.clipData != undefined ? this.clipData : [];
        this.handleTableData();
    }
    }

    showToast(cmp, title, message, variant,mode){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode:mode
        });
        cmp.dispatchEvent(event);
    }
}