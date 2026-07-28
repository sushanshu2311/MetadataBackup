import LightningDatatable from 'lightning/datatable';
import groupBadge from './groupBadge.html';

/**
 * Datatable with a custom "groupBadge" cell type that renders the value as a
 * small lightning-badge pill (instead of a full-size button).
 */
export default class EverestTeamDatatable extends LightningDatatable {
    static customTypes = {
        groupBadge: {
            template: groupBadge,
            standardCellLayout: true,
        },
    };
}