import { LightningElement } from 'lwc';

const showContactSectionDetails =()=>{
    let cols = [{ type: 'button', hideDefaultActions: true, fixedWidth: 30, typeAttributes: {iconName: { fieldName: 'downloadIcon'}, variant: 'base', name: 'downloadIcon', title: 'Add Contact'},cellAttributes:{ class: 'text-icon'}},
// ui fix for icon 13jan
                            { type: 'button', hideDefaultActions: true, fixedWidth: 30, typeAttributes: {iconName: 'utility:people', variant: 'base', name:'Connections', title: 'Connections'},cellAttributes:{ class: 'text-icon'}},
                            { label: 'Deals', iconName:'utility:user_role', initialWidth: 60, fieldName: 'dealRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name:'dealRef', tooltip: {fieldName: 'dealRef'}}},
                            { label: 'Meetings and Calls', iconName:'utility:event', initialWidth: 60, iconSize:'medium', fieldName: 'meetCallRef', type: 'button', cellAttributes: { alignment: 'center'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRef', tooltip: {fieldName: 'meetCallRef'}}}
                        ];
//Bug 00046006 fixed by Deepak
   
    return cols;
}

const referencedCol = (ref)=>{
    console.log('refTabValue123',ref.refTabValue)
    if(['Firms', 'People', 'Deals', 'Funds'].includes(ref.refTabValue)){
        return [            
        //Replaced "this.refTabValue" with "Name" by LK on 2024-05-30 to fix 00045983
            { label: 'Name', fieldName: 'ref', type: 'url',  hideDefaultActions: true, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', tooltip: { fieldName: 'name' }}, cellAttributes: { class: {fieldName: 'refColClass'}}},
            { label: 'Times Referenced', iconName:'utility:number_input', type: 'button', initialWidth: 100, typeAttributes: { label: {fieldName: 'timesRef'}, variant: 'base', name:'timesRef', tooltip: {fieldName: 'timesRef'}}, cellAttributes: { alignment: 'center'}}
        ];
    } else if(ref.refTabValue === 'Themes'){
        return [
            //Replaced "this.refTabValue" with "Name" by LK on 2024-05-30 to fix 00045983
            { label: 'Name', fieldName: 'ref', type: 'url',  hideDefaultActions: true, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', tooltip: { fieldName: 'name' }}, cellAttributes: { class: {fieldName: 'refColClass'}}}        ];
    } else if(ref.refTabValue === 'Clips'){
        return [
        //Replaced "this.refTabValue" with "Name" by LK on 2024-05-30 to fix 00045983
            { label: 'Name', type: 'button', initialWidth: 100, typeAttributes: { label: {fieldName: 'clipName'}, variant: 'base', name:'clipName', tooltip: {fieldName: 'clipName'}}, cellAttributes: { alignment: 'left', class: 'custom_text_css'}}, //Modified by Anshika Ahuja W.R.To Bug #00034694
            { label: 'Summary', fieldName: 'summary', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'summary' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'summary' }, title: { fieldName: 'summary' }}, cellAttributes:{ class: 'refColClass text-black'}}
        ];
    }
    
    
}

const renderText = () =>{
    return `@media (max-width: 600px) {.for_mob .slds-table_header-fixed_container {padding-top: 0px;}
    .for_mob .slds-table_header-fixed {padding-top: 2rem;}}
    
    /*00046035 fixed by raju on 12-06-2024*/
    .for_mob .slds-grid_vertical-align-center{
        display: flex;
        justify-content: right;
    }

    .for_mob .slds-grid_vertical-align-center .slds-icon{
        position: relative;
        left: 2px;
    }

    .for_mobExternal .slds-grid_vertical-align-center{
        display: flex;
        justify-content: right;
    }

    .for_mobExternal .slds-grid_vertical-align-center .slds-icon_container{
        position: relative;
        left: 4px;
    }


    .sortedbycss .slds-combobox__input{
        border: none;
        background: none;
        padding-top: 1px;
        color:#0176d3;
    }
    .errorMsgPopover .slds-popover, .errorMsgPopoverFullWidthTable .slds-popover {background-color: transparent; border: 0; box-shadow: 0; width: 190px;}
    .errorMsgPopover .slds-nubbin_bottom-left:before, .errorMsgPopoverFullWidthTable .slds-nubbin_bottom-left:before {left: 155px;}
    .errorMsgPopover .slds-nubbin_bottom-left:before, .errorMsgPopoverFullWidthTable .slds-nubbin_bottom-left:before {background-color: #BA0517}
    .errorMsgPopover .slds-nubbin_bottom-left:after, .errorMsgPopoverFullWidthTable .slds-nubbin_bottom-left:after{display: none}
    .iconErrCls .slds-icon_xx-small {width: 0.75rem !important; height: 0.75rem !important;}
    .iconErrCls:hover {display:block}
    .sortedbycss .slds-combobox__input:focus, .slds-combobox__input.slds-has-focus{
        box-shadow: none;
    }
    .sortedbycss label.slds-form-element__label{
        display: none;
    }
    .sortedbycss .slds-icon-utility-down .slds-icon{
        fill:#0176d3;
    }
    .sortedbycss .slds-combobox__input-value{
        color:#0176d3;
        padding-left:5px;
        padding-right:25px;
    }
    .info .slds-icon:hover {
        fill: #355d96;
    }
    .sortedbycss span.slds-truncate{
        font-size:12px;
    }
    .sortedbycss .slds-dropdown_fluid{
        min-width: 8rem !important;
        max-width: 100% !important;
        width: 100% !important;
        z-index:9;
    }
    .sortedbycss .slds-listbox__option{
        padding: 0.5px 10px;
    }
    .slds-docked-form-footer{
        z-index: 8 !important;
    }
    .sortedbycss .slds-listbox__option-icon{
        display:none;
    }
    @media (max-width: 1512px) {
        .sortedbycss .slds-combobox__input{
            border: none;
            background: none;
            padding-top: 1px;
            color:#0176d3;
            padding-left: 3px;
            padding-right: 25px;
        }
    }
    .tabhead span.slds-truncate {
    display:block !important;
    }
    .text-black button.slds-button{
        color:#000 !important;
        white-space: nowrap;
        text-overflow: ellipsis;
        max-width: 100%;
        display: block;
        overflow: hidden;
        cursor : text;
    }
    
    .slds-button:active{
        border:none;
    }
    .tabcont .slds-scrollable_y{
        overflow-y: auto !important;
        height: 100%;
    }
    .slds-th__action{
        background: #f3f3f3 !important;
    }
    .radioBtnsInterExter span.slds-radio_faux, .radioBtnsInterExterFund span.slds-radio_faux{
        white-space: nowrap;
    }
    @media only screen and (min-device-width: 1240px) and (max-device-width: 1550px) {
        .slds-table_header-fixed_container.slds-scrollable_x{
            overflow-x: hidden !important;
        }
        .radioBtnsInterExter span.slds-radio_faux, .radioBtnsInterExterFund span.slds-radio_faux{
            padding: 0px 10px 0px 10px;
        }
    }
    .radioBtnsInterExter .slds-form-element__label, .radioBtnsInterExterFund .slds-form-element__label{
        display:none;
    }
    .radioBtnsInterExter .slds-radio_button__label, .radioBtnsInterExterFund .slds-radio_button__label{
        background: #787878;
        color: #fff;
    }
    .radioBtns .slds-form-element__label{
        display:none;
    }
    .radiofourbtns .slds-form-element__label{
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
        width: 18px;
        height: 18px;
    }
    .bg-blu-icon svg.slds-icon.slds-icon_xx-small{
        position: relative;
        bottom: 5px;
        right: 3px;
        width: 14px;
        height: 14px;
    }
    .shadowremovedatatable .slds-th__action {
        background: #f3f3f3 !important;
        box-shadow: none;
    }
    .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action,
    .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
    .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
    .shadowremovedatatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
    .shadowremovedatatable .slds-is-resizable .slds-th__action:focus,
    .shadowremovedatatable .slds-is-resizable .slds-th__action:focus:hover,
    .shadowremovedatatable .slds-table th:focus,
    .shadowremovedatatable .slds-table th.slds-has-focus,
    .shadowremovedatatable .slds-table [role="gridcell"]:focus,
    .shadowremovedatatable .slds-table [role="gridcell"].slds-has-focus,
    .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th,
    .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
        box-shadow: none !important;
    }
    .shadowremovedatatable .slds-th__action:focus,
    .slds-th__action:hover,
    .shadowremovedatatable .slds-table tr:hover {
        box-shadow: none !important;
    }
    .shadowremovedatatable .slds-th__action {
        background: #f3f3f3 !important;
    }
    .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th {
        background: none !important;
    }
    .shadowremovedatatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
        background: none !important;
    }
    .shadowremovedatatable .slds-button:focus {
        box-shadow: none;
    }
    .shadowremovedatatable .slds-button:active {
        border: none;
    }
    .shadowremovedatatable .slds-text-link:hover button.slds-button:hover,
    .shadowremovedatatable .slds-text-link:focus button.slds-button:focus {
        text-decoration: none !important;
    }
    .truncate_text_themes .slds-truncate {
        padding-right: 14px;
    }
    .slds-popover.slds-popover_tooltip.slds-nubbin_bottom-left{
        background-color: #16325c !important;
    }
    
    @media (max-width: 64em) {
    .slds-radio_button .slds-radio_faux, .slds-radio_button .slds-radio--faux, .slds-radio--button .slds-radio_faux, .slds-radio--button .slds-radio--faux{
        padding-left: 8px;
        padding-right: 8px;
        }
    }
    .no-data-main-tab .dt-outer-container{
        height: auto !important;
        position: relative;
        margin-bottom: 2px;
    }
    button:hover + .slds-popover.slds-popover_tooltip.slds-hide {
        display : block!important;
    }
    .custom_text_css button.slds-button{
        white-space: nowrap;
        text-overflow: ellipsis;
        max-width: 100%;
        display: block;
        overflow: hidden;
    }
    .icon_sz svg.slds-icon.slds-icon-text-default.slds-icon_x-small{
        height: 15px;
        width: 14px;
    }
    .text-icon button.slds-button {
        white-space: nowrap !important;
        text-overflow: ellipsis !important;
        max-width: 100% !important;
        display: block !important;
        overflow: hidden !important;
        border: none;
    }`;
}

const dealHelptext = ()=>{
   return "View deals where the contact is a member of the deal team. Click the deal to view or edit details. Click the plus icon to create new deals.";
}

const handleHelpText = (ref) =>{
    let helpText = 'View deals where the contact is a member of the deal team. Click the deal to view or edit details. Click the plus icon to create new deals.';
    switch (ref){
        case "Lender" :
            helpText = "View deals associated with this firm. Click on a deal to view or edit details. Click the plus icon to create new deals.";
            break;

        case "Advisor" : 
        helpText = "View deals associated with this firm. Click on a deal to view or edit details.";
        break;

        case "Portfolio_Company" : 
        helpText = "View deals associated with this firm. Click on a deal to view or edit details. Click the plus icon to create new deals.";
        break;

        case "Company" : 
        helpText = "View deals associated with this firm. Click on a deal to view or edit details. Click the plus icon to create new deals.";
        break;

        case "Intermediary" : 
        helpText = "View deals associated with this firm. Click on a deal to view or edit details. Click the plus icon to create new deals.";
        break;
        case "Institution" : 
        helpText = "View fundraisings associated with this institution. Click on a fundraising to view or edit details. Click the plus icon to create new fundraisings.";
        break;
    }
    return helpText;
}

const infoHelpText = () => {
    return 'The firms, contacts, deals, themes or clips (click on the relevant tab) are listed here since they have been tagged within interactions with this firm. They may also be listed because this firm was tagged in another interaction, deal, theme or clip. Click on the number next to each to view the interactions. ';
}

const createErrMsg = () =>  {
    return 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
}

const delErrMsg = () =>{
    return 'There\'s a problem saving this record. You might not have permission to edit it, or it might have been deleted or archived. Contact your administrator for help.';
}

const infoHelpTextFDR = () => {
    return 'The firms, contacts, themes or clips (click on the relevant tab) are listed here since they have been tagged within interactions with this firm. They may also be listed because this firm was tagged in another interaction, theme or clip. Click on the number next to each to view the interactions.';
}

const infoHelpTextAct = () => {
    return 'The firms, contacts, deals, themes or clips (click on the relevant tab) are listed here since they have been tagged within interactions with this firm. They may also be listed because this firm was tagged in another interaction, deal, theme or clip. Click on the number next to each to view the interactions.';
}

const infoHelpTextInst = () => {
    return 'The firms, contacts, funds, themes or clips (click on the relevant tab) are listed here since they have been tagged within interactions with this firm. They may also be listed because this firm was tagged in another interaction, fund, theme or clip. Click on the number next to each to view the interactions.';
}

const conColsMobValue = () => {
    return [
        { label: 'Name', fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}},
        { label: '', iconName:'utility:user_role', initialWidth: 60, fieldName: 'dealRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name:'dealRefMob', tooltip: {fieldName: 'dealRef'}}},
        { label: '', iconName:'utility:event', initialWidth: 60, iconSize:'medium', fieldName: 'meetCallRef', type: 'button', cellAttributes: { alignment: 'center'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRefMob', tooltip: {fieldName: 'meetCallRef'}}},
    ];
}

const internalColsMob = () =>{
    return [
        { label: 'Name', fieldName: 'name', type: 'button', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'name' }, target: '_blank', variant: 'base', name: 'name', tooltip: { fieldName: 'name' }, title: { fieldName: 'name' }}, cellAttributes:{ class: 'text-black'}},
        { label: '', iconName:'utility:user_role', initialWidth: 60, fieldName: 'dealRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name:'dealRefMob', tooltip: {fieldName: 'dealRef'}}},
        { label: '', iconName:'utility:event', initialWidth: 60, iconSize:'medium', fieldName: 'meetCallRef', type: 'button', cellAttributes: { alignment: 'center'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRefMob', tooltip: {fieldName: 'meetCallRef'}}}
    ];
}

const conColsMob2 = () => {
    return [{ label: 'Name', fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}},
    { label: '', iconName:'utility:user_role', initialWidth: 60, fieldName: 'dealRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name:'dealRefMob', tooltip: {fieldName: 'dealRef'}}},
    { label: '', iconName:'utility:event', initialWidth: 60, iconSize:'medium', fieldName: 'meetCallRef', type: 'button', cellAttributes: { alignment: 'center'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRefMob', tooltip: {fieldName: 'meetCallRef'}}},
    ];
}

const dealsColsMob1 = (ref) =>{
    console.debug('dealsColsMob1');
    let cols= [{label: ref.fieldHeader1, fieldName: 'fieldRef1', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank'}, variant: 'base' },
    { label: ref.fieldHeader4, fieldName: 'field4', initialWidth: 120, type: 'text', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'field4' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'field4' }, title: { fieldName: 'field4' }}, cellAttributes:{ class: 'text-black'}}
    ];
    return cols;
}

const fundColsMob = (ref) => {
    return [{label: ref.fieldHeader1, fieldName: 'fieldRef1', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank'}, variant: 'base' },
    { label: ref.fieldHeader2, fieldName: 'field2', initialWidth: 120, type: 'text', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'field2' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'field2' }, title: { fieldName: 'field2' }}, cellAttributes:{ class: 'text-black'}}
    ];
}

const coInvColsMob = (ref) =>{
    return [{label: ref.fieldHeader1, fieldName: 'fieldRef1', type: 'url', hideDefaultActions: true, cellAttributes: { alignment: 'left' }, typeAttributes: { tooltip: { fieldName: 'field1' }, label: { fieldName: 'field1' }, target: '_blank'}, variant: 'base' },
    { label: ref.fieldHeader2, fieldName: 'field2', initialWidth: 120, type: 'text', hideDefaultActions: true, sortable: false, typeAttributes: { label: { fieldName: 'field2' }, target: '_blank', variant: 'base', tooltip: { fieldName: 'field2' }, title: { fieldName: 'field2' }}, cellAttributes:{ class: 'text-black'}}];
}

const helpTextForDealSections = () =>{
    return 'View deals associated with this firm. Click on a deal to view or edit details. Click the plus icon to create new deals.';
}

const dealsColsValue = () =>{
    return [{ label: 'Deal Name' , fieldName: 'nameRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}}];
}

const conCols1 = () =>{
    return [{ type: 'button', hideDefaultActions: true, fixedWidth: 30, typeAttributes: {iconName: 'utility:people', variant: 'base', name:'Connections', title: 'Connections'}},
    { label: 'Name' , fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}},
    { label: 'Deals', iconName:'utility:user_role', initialWidth: 60, fieldName: 'dealRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name:'dealRef', tooltip: {fieldName: 'dealRef'}}},
    { label: 'Meetings and Calls', iconName:'utility:event', initialWidth: 60, iconSize:'medium', fieldName: 'meetCallRef', type: 'button', cellAttributes: { alignment: 'center'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRef', tooltip: {fieldName: 'meetCallRef'}}}
    ];
}

const conColsMob1 = () =>{
    return [{ label: 'Name' , fieldName: 'conRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}},
    { label: '', iconName:'utility:user_role', initialWidth: 60, fieldName: 'dealRef', type: 'button', cellAttributes: { alignment: 'center' }, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'dealRef' }, variant: 'base', name:'dealRefMob', tooltip: {fieldName: 'dealRef'}}},
    { label: '', iconName:'utility:event', initialWidth: 60, iconSize:'medium', fieldName: 'meetCallRef', type: 'button', cellAttributes: { alignment: 'center'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'meetCallRef' }, variant: 'base', name:'meetCallRefMob', tooltip: {fieldName: 'meetCallRef'}}}
    ];
}

const conCols2 = () => {
    return [{ label: 'Fundraising Name' , fieldName: 'nameRef', type: 'url', cellAttributes: { iconName: { fieldName: 'icRef'}, class: {fieldName: 'conColCls'}, alignment: 'left'}, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'name' }, target: '_blank', tooltip: {fieldName: 'name'}}}];
}



export {showContactSectionDetails, referencedCol , renderText, dealHelptext , handleHelpText, infoHelpText,createErrMsg , delErrMsg, infoHelpTextFDR,
    infoHelpTextInst , infoHelpTextAct, conColsMobValue, internalColsMob, conColsMob2, dealsColsMob1, fundColsMob, coInvColsMob, helpTextForDealSections,
    dealsColsValue, conCols1, conColsMob1, conCols2
 }