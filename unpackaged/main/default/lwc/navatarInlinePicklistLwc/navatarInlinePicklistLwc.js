import LightningDatatable from 'lightning/datatable';
import navatarPicklistColumn from './navatarInlinePicklistComboboxLwc.html';

export default class NavatarInlinePicklistLwc extends LightningDatatable {

    static customTypes = {
        picklist: {
            template: navatarPicklistColumn,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','fieldApiName','editable']
        }
    };
}