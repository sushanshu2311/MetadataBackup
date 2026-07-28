import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpenTasks from '@salesforce/apex/NavCompanyPageController.getOpenTasks';

const OWNER_OPTIONS = [{ label: 'Mine', value: 'mine' }];

/**
 * FR-SHD-04 / FR-COMP-10 — the Tasks widget on Overview.
 *
 * Search box plus an All / Mine filter (All by default) and nothing else:
 * overdue items sort first anyway. No open-count label. Sorted ascending by
 * due date. The checkbox marks a task complete; clicking the row opens the
 * task to edit. '+' opens the standard new-task form, pre-linked to the record.
 */
export default class NavTasksWidget extends NavigationMixin(LightningElement) {
    @api recordId;

    searchTerm = '';
    ownerFilter = [];
    wiredResult;
    tasks = [];
    error;

    ownerOptions = OWNER_OPTIONS;

    @wire(getOpenTasks, { recordId: '$recordId' })
    wiredTasks(result) {
        this.wiredResult = result;
        if (result.data) {
            this.tasks = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.tasks = [];
        }
    }

    get visibleTasks() {
        const term = this.searchTerm.trim().toLowerCase();
        const mineOnly = this.ownerFilter.includes('mine');
        return this.tasks.filter((task) => {
            if (mineOnly && !task.isMine) {
                return false;
            }
            if (!term) {
                return true;
            }
            const haystack = `${task.subject || ''} ${task.ownerName || ''}`.toLowerCase();
            return haystack.includes(term);
        });
    }

    get hasTasks() {
        return this.visibleTasks.length > 0;
    }

    get emptyMessage() {
        if (this.tasks.length === 0) {
            return 'No open tasks on this company.';
        }
        return 'No tasks match this filter.';
    }

    handleSearch(event) {
        this.searchTerm = event.detail.value || '';
    }

    handleOwnerFilter(event) {
        this.ownerFilter = event.detail.values;
    }

    handleNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: { objectApiName: 'Task', actionName: 'new' },
            state: { defaultFieldValues: `WhatId=${this.recordId}` }
        });
    }

    handleOpen(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Task',
                actionName: 'view'
            }
        });
    }

    /** The checkbox completes the task; it must not also open the row. */
    async handleComplete(event) {
        event.stopPropagation();
        const taskId = event.target.dataset.id;
        try {
            await updateRecord({ fields: { Id: taskId, Status: 'Completed' } });
            await refreshApex(this.wiredResult);
            this.dispatchEvent(
                new ShowToastEvent({ variant: 'success', message: 'Task marked complete.' })
            );
        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    variant: 'error',
                    title: 'Could not complete the task',
                    message: e.body ? e.body.message : 'Please try again.'
                })
            );
        }
    }
}