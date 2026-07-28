import LightningDatatable from 'lightning/datatable';
import taskInfo from './taskInfo.html';

/**
 * Datatable with a custom "taskInfo" cell type that renders the task subject
 * with the due date as a small sub-line beneath it (v10 .ti layout), so Tasks
 * can be a single column instead of Task + Due.
 */
export default class EverestTaskDatatable extends LightningDatatable {
    static customTypes = {
        taskInfo: {
            template: taskInfo,
            standardCellLayout: true,
            typeAttributes: ['due'],
        },
    };
}