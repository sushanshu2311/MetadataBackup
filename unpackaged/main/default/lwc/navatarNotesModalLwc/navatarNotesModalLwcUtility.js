import { LightningElement } from 'lwc';

const exclusionWordList = ()=>{
    return `Capital Project Group Partner Partners Next Work America Systems Credit Active First Business company services Service companies products consulting growth water direct food sales Health corp healthcare finance management enterprises marketing will care family brokers Adam Allan Alex Andrew Anna Anne Anthony Barry Bill Brad Brenda Brian Carl Caroline Cathy Charles Chris Christopher Cook Craig Cynthia Daniel Dave David Donald Doug Elizabeth Eric Frank Fred Gary George Greg Gregory Harry Henry Jack Jackie James Jason Jeff Jeffrey Jennifer Jeremy Jill John Jonathan Jones Joseph Josh Julie Julia Karen Kevin Mark Michael Michelle Mike Nancy Nick Nicholas Paul Peter Phil Philip Richard Robert Ronald Roger Scott Smith Stephen Steve Steven Susan Thomas Todd William corporation International solutions manufacturing technologies chemicals equity technology american packaging industrial industrials speciality energy software office manufacturer corporate investments securities supply polymers GmbH Boston research distributor commercial data California Alliance consumer Spectrum Canada Europe Berlin access Acquisition Advisors advisory asset Associates bank banking Board building case center Chicago Clinical Dental Development devices Diagnostic diagnostics diversified doctor endowment engineering European financial focus foundation France Fund funds German Germany glass high home hospital income industry information innovation insurance invest investing investment investor investors labs level Life Limited London managed Market markets Medical medicine Miami Morgan national network Opportunities opportunity Part pension people performance pharma plan Private process product provider quality real reinsurance School science Sciences source SPAC Special state strategic strategies strategy Summit system team three time total transaction trust University value venture ventures well with world Aaron Alexander Bell Berg best Brown Clark Tests
     Frederik Harris Howard Kelly Marc Martin Marvin Matt Miller Murphy Patel Patrick Ryan Simon Taylor Tony west Williams holding Frankfurt young Ernst instruments Media general biopharma Vision future implants Legal clinics design centre Scientific small Dutch Belgium cell computer electronic training plus brothers innovative MedTech control Austria online productions travel Roland integrated partnership materials video biotechnologies clinic Labor early retail test price point Stefan Christian Philippe Dirk global Firm Biotech tech surgical drug digital consultants consultancy line dynamics trading discovery imaging managers Institute executive human pharmaceutical info therapy link factory white exchange automotive agency trade heart applied resources micro wave brain distribution deal Industries college Street pipeline security great City transportation power branded platform infrastructure flow Park logistics contractor chain chemical Rental public auto Hill parts heavy electrical brand brands holdings contract fire meat employees below record assets specialty division steel electronics call acquisitions advanced segment long facility United River house facilities stores Post customer environmental businesses operations cash place waste Asia space paper hotel natural premium hotels storage light union risk maintenance transport production super double fuel base wood technical professional core defense wireless staffing country label legacy estate gold Retirement institutional County founders South education proprietary delivery press event delta action Restaurant Party material communication practice communications dealer Pizza restaurants unit franchise franchisee units king fitness forward Wealth Arthur Stein Michel Markus Stephan Erik Sean Andy Bryan Justin Derek Matthew Bruce Lewis Jamie Stanley Edward Kyle Jordan Rich Johnson Rick Dennis Graham Larry Arnold page ball Jose list Andreas Philipp Oliver Nicole Amanda Davis Stephens Clay Jake Timothy Douglas Tests
     construction equipment mezzanine Planning portfolio support radio adhesives north safety pipe fruit alternative Butler Coast Cohen Compensation fixed from Gilde Merck metal molecular Novartis Plastics preferred Purpose sense Therapeutics Arnoud Hans Schoot vliet Vries Warren willem Wright this Utrecht Oncology Benelux Hamburg Nordic cancer Gruppe open Kapital chance York Have Grery close interim spin gene search voor PortCo payment machine benefit Impact Road master based floor Cable mail personal color mobile related full coffee rock kitchen guys client profile Pieter Hugo Frans Lars Wolfgang Tobias Rene Francois Christoph Florian does here`;
 }

 const renderCss = ()=>{
    return `.task-box .slds-accordion__section{
            padding: 10px 5px 0px !important;}
       // .slds-rich-text-editor__toolbar.slds-shrink-none{display:none !important;}
        }

        span.slds-checkbox [type=checkbox]:focus+.slds-checkbox__label .slds-checkbox_faux{
            outline: 0 !important;
            outline-offset: 0 !important; 
        }

        .hide-toolbar  .slds-rich-text-editor__toolbar {
            display: none !important;
        }    
        .notetextareaEdit .slds-rich-text-editor {
            min-height: 300px;
        }

        /*Research by raju on 17-10-2024 for @function*/
        .clsSldsMedia.slds-media{
            align-items: center !important;
        }

         /*toggle icon by raju on 17-10-2024 RTA*/
        .clsToggleIconPos .slds-checkbox_on,  .clsToggleIconPos .slds-checkbox_off{
            display: none !important;
        }

        /*00047862, Fixed by Raju on dated 18-10-2024*/
        .notetextareaEdit .slds-rich-text-area__content {
            background-color: transparent !important;
        }

        .slds-checkbox1 {

            width: 2px !important;
            height: 2px !important;
        }
        .clsPopover .slds-popover_medium  {
            min-width: 5rem !important;
        }



        /*Changed by raju on 17-10-2024 for @function*/ 
        /*.suggest-css .slds-icon_small{
            width: 20px !important;
            height: 20px !important;
        }*/
        .suggest-css span.slds-media__figure.slds-listbox__option-icon{
            margin-right: 4px !important;
        }
        .pillsHide .slds-pill__remove{
            display: none !important;
        }
      //  .slds-rich-text-editor__toolbar.slds-shrink-none{
        //    display:none;
        //}
        .slds-file-selector__dropzone{
            padding: 0;
        }
        .slds-file-selector__body{
           max-width: 36px;
           overflow-x: hidden;
           white-space: nowrap;
           max-height: 28px;
           overflow: hidden;
           justify-content: start;
           gap: 15px;
           border: 1px solid #ddd;
        }
        .slds-file-selector__button{
           padding-left:10px;
        }
        
      //  .slds-rich-text-editor__toolbar.slds-shrink-none{
      //      display:none !important;
    
        //}
       // .slds-rich-text-editor__toolbar.slds-shrink-none {
       //     display: none;
       // }
        .advance-font span.slds-accordion__summary-content {
            font-size: 12px;
            padding-top: 5px;
        }
        .advance-font svg.slds-accordion__summary-action-icon.slds-button__icon.slds-button__icon_left.slds-icon.slds-icon-text-default.slds-icon_x-small{
            width: 11px;
            height: 11px;
        }
       
        .detailsAccor .slds-accordion__summary-action{
            padding-left:0px;
        }
        .detailsAccor .slds-accordion__section.slds-is-open{
            background:#f3f3f3;
        }
        .detailsAccor .slds-accordion__summary{
            background:#fff;
            padding-left: 31px !important;
        }
        .detailsAccor .slds-pill{
            background: #f3f3f3;
        }
        .seletedtag-datatable .slds-table_bordered tbody td, .slds-table_bordered tbody th, .slds-table--bordered tbody td, .slds-table--bordered tbody th{
            height: 41px !important;
        }
        .seletedtag-datatable .slds-table tbody tr.slds-is-selected>td, .slds-table tbody tr.slds-is-selected>th{
            box-shadow: none !important;   
        }
        .seletedtag-datatable td.slds-text-body_regular:hover, .seletedtag-datatable td.slds-text-body_regular:focus, .seletedtag-datatable .slds-table tbody tr.slds-is-selected>td:hover, .slds-table tbody tr.slds-is-selected>th:hover{
            box-shadow: none !important;
        }
        .seletedtag-datatable .slds-table th:focus, .seletedtag-datatable .slds-table th.slds-has-focus, .seletedtag-datatable .slds-table [role=gridcell]:focus, .seletedtag-datatable .slds-table [role=gridcell].slds-has-focus, .seletedtag-datatable .slds-has-focus .slds-th__action{
            box-shadow:none !important;
        }
        .seletedtag-datatable span.slds-th__action, .seletedtag-datatable span.slds-th__action:hover,.seletedtag-datatable span.slds-th__action:focus ,.seletedtag-datatable slds-th__action:focus, .seletedtag-datatable .slds-th__action:hover{
            background-color:#f3f3f3;
        }
        .seletedtag-datatable .slds-button {
            border: 0 !important;
        }
        .seletedtag-datatable tr th:nth-child(1) .slds-button__icon {fill: #ea001e;}
        @media only screen and (min-width: 91em) and (max-width: 120em) { 
            .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
                max-height: 228px !important;
                overflow-y: auto;
        }}
        .picklist-ht:last-child .slds-dropdown-trigger_click.slds-is-open:last-child .slds-dropdown:last-child, .slds-dropdown-trigger--click.slds-is-open:last-child .slds-dropdown:last-child{
            max-height: 152px;
            overflow-y: auto;
        }
        .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            max-height: 152px;
            overflow-y: auto;
        }
      //  .slds-rich-text-editor__toolbar.slds-shrink-none{
      //      display:none;
      //  }
        .slds-file-selector__dropzone{
            padding: 0;
        }
        .slds-file-selector__body{
           max-width: 36px;
           overflow-x: hidden;
           white-space: nowrap;
           max-height: 28px;
           overflow: hidden;
           justify-content: start;
           gap: 15px;
           border: 1px solid #ddd;
        }
        .slds-file-selector__button{
           padding-left:10px;
        }
      //  .slds-rich-text-editor__toolbar{
      //      display:none !important;
      //  }
        .advance-font span.slds-accordion__summary-content {
            font-size: 12px;
            padding-top: 5px;
        }
        .advance-font svg.slds-accordion__summary-action-icon.slds-button__icon.slds-button__icon_left.slds-icon.slds-icon-text-default.slds-icon_x-small{
            width: 11px;
            height: 11px;
        }
        .detailsAccor .slds-accordion__summary-action{
            padding-left:0px;
        }
        .detailsAccor .slds-accordion__section.slds-is-open{
            background:#f3f3f3;
        }
        .detailsAccor .slds-accordion__summary{
            background:#fff;
        }
        .detailsAccor .slds-pill{
            background: #f3f3f3;
        }
        .seletedtag-datatable .slds-th__action {
            background: #f3f3f3 !important;
            box-shadow: none;
        }
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action,
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action:focus,
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action:hover,
        .seletedtag-datatable .slds-has-focus.slds-is-resizable .slds-th__action:focus:hover,
        .seletedtag-datatable .slds-is-resizable .slds-th__action:focus,
        .seletedtag-datatable .slds-is-resizable .slds-th__action:focus:hover,
        .seletedtag-datatable .slds-table th:focus,
        .seletedtag-datatable .slds-table th.slds-has-focus,
        .seletedtag-datatable .slds-table [role="gridcell"]:focus,
        .seletedtag-datatable .slds-table [role="gridcell"].slds-has-focus,
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th,
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            box-shadow: none !important;
        }
        .seletedtag-datatable .slds-th__action:focus,
        .slds-th__action:hover,
        .seletedtag-datatable .slds-table tr:hover {
            box-shadow: none !important;
        }
        .seletedtag-datatable .slds-th__action {
            background: #f3f3f3 !important;
        }
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>th {
            background: none !important;
        }
        .seletedtag-datatable .slds-table:not(.slds-no-row-hover) tbody tr:hover>td {
            background: none !important;
        }
        .seletedtag-datatable .slds-button:focus {
            box-shadow: none;
        }
        .seletedtag-datatable .slds-button:active {
            border: none;
        }
        .clsForHeaderDeleteIcon .slds-table thead tr th:first-child .slds-th__action .slds-icon{
            cursor: pointer;
        }
        .clsForHeaderDeleteIcon .slds-button{
            padding-right: 0 !important;
            padding-left: 0 !important;
        }
        .slds-table tbody tr {
            height: 40px !important;
        }
        @media only screen and (min-width: 91em) and (max-width: 120em) { 
            .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
                max-height: 228px !important;
                overflow-y: auto;
        }}
        .picklist-ht:last-child .slds-dropdown-trigger_click.slds-is-open:last-child .slds-dropdown:last-child, .slds-dropdown-trigger--click.slds-is-open:last-child .slds-dropdown:last-child{
            max-height: 152px;
            overflow-y: auto;
        }
        .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            max-height: 152px;
            overflow-y: auto;
        }
        .creatrecord_css .slds-radio .slds-form-element__label{
            display: none !important;
        }
        .creatrecord_css .radio_grp .slds-form-element__control{
            display: flex !important;
            justify-content: center;
            gap: 60px;
            padding-left: 1rem;
        }
        .creatrecord_css .slds-dropdown-trigger .slds-dropdown{
            max-height: 192px;
            position: fixed !important;
            width: 246px !important;
        }
        .dropdownout_css .slds-dropdown-trigger .slds-dropdown{
            max-height: 192px;
            position: fixed !important;
            width: 246px !important;
        }
        .creatrecord_css .slds-form-element__label:empty{
            display:none !important;
        }
        .lookup_css_h .pillwidth lightning-button-icon.slds-pill__remove {
            position: absolute;
            right: 2px;
            top: 0px;
        }
        .dash-filter{
            z-index: 1 !important;        
        }
        .noteareacss textarea.slds-textarea{
            border: none !important;
            overflow-y: auto;
            padding: 0px 0px;
            box-shadow: none;
            min-height:60px;
            max-height:100px;
            overflow: auto;
            resize: none;
            background-color: inherit;
        }

        .noteareacss .slds-form-element__label:empty{
            display: none !important;
        }

        
        .detailsnoteareacss .slds-form-element__label:empty{
            display: none !important;
        }

        .dropdownout_css .slds-dropdown-trigger .slds-dropdown{
            max-height:150px;
            position: fixed !important;
            width: 246px !important;
            bottom: 40px;
        }
        .dash-filter:before{               
            content: '';
            display: block;
            width: var(--lwc-squareIconXSmallContent,0.5rem);
            height: 2px;
            border: 0;
            transform: translate3d(-50%, -50%, 0);
            background: var(--slds-c-checkbox-mark-color-foreground, var(--sds-c-checkbox-mark-color-foreground, var(--lwc-brandAccessible,rgb(1, 118, 211))));
            position: absolute;
            top: 58%;
            left: 43%; // 45106 fixed by Raju Phase 3
            z-index: 1 !important;                          
        }
        .comb_css .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
            max-height: 195px;
        }
        .lightning-basecombobox_basecombobox{
            z-index:9999999999999999 !important;
            max-height: 150px !important;
        }
        @media only screen and (min-width: 91em) and (max-width: 120em) { 
            .picklist-ht .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .slds-dropdown-trigger--click.slds-is-open .slds-dropdown{
                max-height: 228px !important;
                overflow-y: auto;
        }
        .lightning-basecombobox_basecombobox{
            z-index:9999999999999999 !important;
            max-height: 150px !important;
        }}
        .label_hide_css .slds-form-element__legend{
            display:none !important;
        }
        
        /*00048348 fixed by raju on dated 03-12-2024*/
        .notetextareaEdit .slds-rich-text-area__content {
                min-height: inherit;
                max-height: inherit;
                height: 300px;
        }
        `
 }

 export {exclusionWordList,renderCss
 }