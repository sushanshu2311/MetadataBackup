import { LightningElement, api } from 'lwc';
import getTemplatedata from "@salesforce/apex/NavatarSendEmailTemplateCtrl.retrievefolders";
const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Type', fieldName: 'TemplateType', type: 'text', sortable: true },
    { label: 'Description', fieldName: 'Description', type: 'text', sortable: true},
    {
        label: 'Preview', fieldName: 'templateurl', type: 'url', typeAttributes: {
            target: '_blank',
            tooltip: 'Preview',
            label: 'Preview'
        }
    }
];
export default class NavatarSendEmailTemplateLwc extends LightningElement {
    templatedata;
    allTemplateList;
    templateoptions;
    columns = columns;
    @api selectedval=[];
    isloading = true;
    @api emailpreviewdata;
    sortDirection = 'asc';
    sortedBy;

    connectedCallback() {
        console.log(JSON.stringify(this.emailpreviewdata)+'this.emailpreviewdata')
        getTemplatedata({emailData : this.emailpreviewdata})
            .then(result => {
                console.log('result is '+JSON.stringify(result));
                let templateresult = JSON.parse(JSON.stringify(result));
                if (result.responseMsg == 'Success') {
                    this.templateoptions = templateresult.options;
                    this.templatedata = templateresult.emailingTemplates;
                    this.allTemplateList = this.templatedata;
                    console.log(JSON.stringify(this.allTemplateList));
                } else {
                    console.log(result.responseMsg);
                }
                this.isloading = false;
            }).catch(ex => {
                console.log(ex);
                this.isloading = false;
            });
    }
    handletemplateoptionselect(event) {
        var selOption = event.detail.value;
        console.log(selOption);
        if (selOption == 'All') {
            this.selectedval = '';
            this.templatedata = JSON.parse(JSON.stringify(this.allTemplateList));
        } else if (selOption == 'Others') {
            let shortlisted = this.allTemplateList.filter(element => {
                return element.hasfolder == false;
            });
            this.templatedata = JSON.parse(JSON.stringify(shortlisted));
        } else {
            let shortlisted = this.allTemplateList.filter(element => {
                return element.folderId == selOption;
            });

            this.templatedata = JSON.parse(JSON.stringify(shortlisted));
           /* const selectedEvent = new CustomEvent("templateselect", { detail: '' });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);*/
        }
    }
    handlerowSelect(event) {
        const row = event.detail.selectedRows;
        let currentselectedrows = this.template.querySelector('lightning-datatable');
        let selrows = currentselectedrows != null ? currentselectedrows.selectedRows : '';
        console.log('selectedrows---'+selrows);
        //this.selectedval = row.map(val=>{return val.templateId});
        this.selectedval=this.template.querySelector('lightning-datatable').selectedRows;
        console.log('selectedval-----'+JSON.stringify(this.selectedval));
        const selectedEvent = new CustomEvent("templateselect", { detail: row });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    //sorting action
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        console.log(event.detail);
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.templatedata];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.templatedata = cloneData;
        //this.tabledata = this.initTableData.slice(0, 12);
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}