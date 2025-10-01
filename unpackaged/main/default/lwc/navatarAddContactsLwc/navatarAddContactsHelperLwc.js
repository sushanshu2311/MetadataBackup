import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // To display toast
export const helper = {
    setDefaults(cmp) {
        let objApiNamesListTab = ['Account', 'Contact'];
        cmp.defaultFieldList = ["Contact:Name:Full Name:string",
        "Contact:Email:Email:email",
        "Contact:Phone:Phone :phone",
        "Account:Name:Account Name:string"];
        cmp.objApiNamesListTab = objApiNamesListTab;
        cmp.objName = 'Contact';
    },
    prepareWhereClause(cmp, whereClauseFromApex) { // uncommented for bug #42367 ,#42408 fixes by salauddin sheikh
        cmp.whereClause = whereClauseFromApex;
        console.log('inside prepareWhereClause-->'+whereClauseFromApex.split('.')[0]);
        if (whereClauseFromApex.split('.')[0] == cmp.nameSpacePrefix + 'Account__r') {
        
            cmp.whereClause = 'Contact.Account.' + whereClauseFromApex.split('.')[1];
        } else{
            cmp.whereClause = whereClauseFromApex;
        }
        
        if (whereClauseFromApex.split('.')[0] ==  'Contact__r') {
            
            cmp.whereClause =  whereClauseFromApex.split('.')[1]; // Modified by Anshika Ahuja W.R.To Bug No-00029506
        } else {
            cmp.whereClause = whereClauseFromApex;
        }
        if (cmp.whereClause.indexOf('Contact.') > -1 && cmp.whereClause.indexOf('@@@@') > -1) {
            var whereCondition_Split_val = cmp.whereClause.split('@@@@');
            cmp.whereClause = whereCondition_Split_val[0];
            cmp.whereCon_Contact = whereCondition_Split_val[1];
        }
    },
    fieldAccessCheck(cmp) {
        let columnsToShow = [];
        let columnsToShow1 = [];
        let columnsReviewContactNew = [];
        for (let field of cmp.columnsToShow) {
            let fieldApiName = field.split(':')[0] + '.' + field.split(':')[1];
        
            columnsToShow.push(field);
           
        }
        cmp.columnsToShow = columnsToShow;
        for (let field of cmp.columnsToShow1) {
            
            let fieldApiName = field.split(':')[0] + '.' + field.split(':')[1];
            
            columnsToShow1.push(field);

        }
        cmp.columnsToShow1 = columnsToShow1;
        for (let field of cmp.columnsReviewContactNew) {
            
            let fieldApiName = field.split(':')[0] + '.' + field.split(':')[1];
            
            columnsReviewContactNew.push(field);

        }
        cmp.columnsReviewContactNew = columnsReviewContactNew;
    },
    prepareQuery(cmp) {
        try {

            cmp.mainQuery = '';
            cmp.pageName= 'DAIT_AccContactTab';
            
            if (cmp.pageName == 'DAIT_AccContactTab' || cmp.onLoad) {
                this.setHeaderValuesSecondtab(cmp);
            }
        
            else if (cmp.pageName == 'DAIT') {
                this.setHeaderValues(cmp);
            }
            
            else if (cmp.pageName == 'DAIT_ConRole') {
                this.setHeaderValues(cmp);
            }
            
        } catch (err) {
            console.log('error in prep query' + err.message);
        }
    },
    setHeaderValuesSecondtab(cmp) {
        
        let orderbycol = 'Name';
        let direction = 'ASC';
        console.log('cmp.whereClause---->'+cmp.whereClause)
        let whereCon = cmp.whereClause != undefined ? cmp.whereClause : '';
       // console.log('--------------------------inside setHeaderValuesSecondtab ---------------------------');
        let getqueryMain = "Select ";
       // console.log(JSON.stringify(cmp.columnsToShow));
        for (let field of cmp.columnsToShow) {
            var objectName = field.split(':')[0];
            var MainfieldName = field.split(':')[1];
            var fieldType = field.split(':')[3];
            //Code added by Anshika Ahuja postfix part W.R.TO Case 0029531
            var postfix = MainfieldName.substr(-2).indexOf('Id') == -1 ? MainfieldName : MainfieldName.slice(0, -2) + '.Name';
          //  console.log(postfix);
            if (objectName == 'Contact') {
              
                if(fieldType == 'date'){    //Ui date fixes by salauddin sheikh
                    getqueryMain += "Contact." +'FORMAT('+ postfix +')'+ ", ";
                }
                else{
                    getqueryMain += "Contact." + postfix + ", ";
                }
            }
            if (objectName == 'Account') {
                getqueryMain += "Account." + postfix + ", ";
            }
        }
        getqueryMain += " Contact.Id  from Contact where " + (whereCon == '' ? "id IN ('')" : whereCon) + ") order by Contact.Name ASC ";// Modified by Anshika Ahuja W.R.To Bug no-00029507 & 00029508
        cmp.mainQuery = getqueryMain;
    },
    processResults(cmp, queryResults) {
        this.createtablestructure(cmp);
        let existingIdSet = cmp.existingIdSet;
        var dataList;
        if (cmp.enableLoadMore) {
            dataList = cmp.allDataList;
        } else {
            dataList = [];
        }
        if (queryResults.length > 0) {
            for (let field of cmp.conColumns) {
                for (const index in queryResults) {
                    if (cmp.pageName == 'DAIT_ConRole') {
                        if (field.objName.toLowerCase() == 'account') {
                            let firstField = (queryResults[index][cmp.nameSpacePrefix + 'Account__r'] || {});
                            if (field.type == 'url' || field.type == 'conClicks') {
                                queryResults[index][field.fieldName + '_label'] = firstField[field.fieldApiName];
                                queryResults[index][field.fieldName] = '/' + firstField['Id'];
                            } else {
                                queryResults[index][field.fieldName] = field.fieldApiName.substr(-2).toLowerCase().indexOf('id') == -1  ||
                                queryResults[index][cmp.nameSpacePrefix + field.objName + '__r'].hasOwnProperty(field.fieldApiName) == false ? //queryResults[index].hasOwnProperty(field.fieldApiName) == false ?
                                                                       firstField[field.fieldApiName] :
                                                                       firstField[field.fieldApiName.slice(0, -2)].Name;
                            }

                        } else if (field.objName.toLowerCase() == 'contact') {
                            let firstField = (queryResults[index][cmp.nameSpacePrefix + field.objName + '__r'] || {});
                           // console.log(JSON.stringify(firstField)+'firstField');
                            if (field.fieldName == 'Name_Contact') {
                                queryResults[index][field.fieldName + '_label'] = firstField[field.fieldApiName];
                                queryResults[index][field.fieldName] = '/' + firstField['Id'];
                                queryResults[index]['Id'] = firstField['Id'];
                                existingIdSet.push(firstField['Id']);
                            } else {
                                /*Replaced firstField[field.fieldApiName] with ternary condition by Lakshya on 20210405 1500 to display Name incase of Id type of data */
                                queryResults[index][field.fieldName] = field.fieldApiName.substr(-2).toLowerCase().indexOf('id') == -1  ||
                                                                       queryResults[index][cmp.nameSpacePrefix + field.objName + '__r'].hasOwnProperty(field.fieldApiName) == false ?
                                                                       firstField[field.fieldApiName] :
                                                                       firstField[field.fieldApiName.slice(0, -2)].Name;//firstField[field.fieldApiName];//firstField[field.fieldApiName.slice(0, -2)].Name;
                            }
                        }
                    } else {
                        if (field.objName.toLowerCase() == 'account') {
                           // console.log('inside field.objName.toLowerCase() ==');
                            let firstField = (queryResults[index][field.objName] || {});
                            if (field.type == 'url' || field.type == 'conClicks') {
                                queryResults[index][field.fieldName + '_label'] = firstField[field.fieldApiName];
                                queryResults[index][field.fieldName] = '/' + firstField['Id'];
                            } 
                            else {
                                /*Replaced firstField[field.fieldApiName] with ternary condition by Lakshya on 20210405 1500 to display Name incase of Id type of data */
                                queryResults[index][field.fieldName] = field.fieldApiName.substr(-2).toLowerCase().indexOf('id') == -1 ||
                                                                       (queryResults[index].hasOwnProperty(field.fieldApiName) == false &&
                                                                       queryResults[index]['Account'].hasOwnProperty(field.fieldApiName) == false) ?
                                                                       firstField[field.fieldApiName] :
                                                                       firstField[field.fieldApiName.slice(0, -2)].Name;
                            }

                        } else if (field.objName.toLowerCase() == 'contact') {
                            let queryResult = field.fieldApiName.substr(-2).toLowerCase().indexOf('id') == -1 ||
                            queryResults[index].hasOwnProperty(field.fieldApiName) == false ?
                            queryResults[index][field.fieldApiName] :
                            queryResults[index][field.fieldApiName.slice(0, -2)].Name;
                           // console.log('test contact result-->'+queryResult);
                            
                            let firstField = (queryResult || '');
                            if (field.fieldName == 'Name_Contact') {
                              
                                    queryResults[index][field.fieldName + '_label'] = firstField;
                              
                                queryResults[index][field.fieldName] = '/' + queryResults[index]['Id'];
                               
                                 existingIdSet.push(queryResults[index]['Id']);
                                
                            }
                            else {
                                //console.log('inside ELse-->'+field.fieldName);
                                queryResults[index][field.fieldName] = firstField;
                            }
                        }
                        else if (field.objName.toLowerCase() == 'custom') {
                            let queryResult = field.fieldApiName.substr(-2).toLowerCase().indexOf('id') == -1 ||
                            queryResults[index].hasOwnProperty(field.fieldApiName) == false ?
                            queryResults[index][field.fieldApiName] :
                            queryResults[index][field.fieldApiName.slice(0, -2)].Name;

                            
                            let firstField = (queryResult || '');
                            if (field.fieldName == 'Meetings_Custom') {
                                queryResults[index][field.fieldName + '_label'] = queryResults[index]['Meetings']; //firstField;
                                queryResults[index][field.fieldName] = queryResults[index]['Meetings'];
                                existingIdSet.push(queryResults[index]['Meetings']);
                                
                            } 
                            else {
                                queryResults[index][field.fieldName] = firstField;
                            }
                        }
                    }

                }
            }
            cmp.showAllOption = true;
        } else {
            cmp.enableLoadMore = false;
            cmp.showAllOption = false;
        }
        dataList = [...dataList, ...queryResults];
        
        cmp.allDataList = dataList;
       // console.log(JSON.stringify(cmp.allDataList)+'cmp.allDataList');
       
        cmp.existingIdSet = existingIdSet;
        cmp.selectedRows = [];
        if(cmp.sel_SelectedData.length>0)
        {
            let selectedIdSet = cmp.sel_SelectedData.map(val => { return val.Id });
            dataList= dataList.filter( x => !selectedIdSet.includes(x.Id) );
        }
      //  console.log('dataList =>' + existingIdSet.length + ' == ' + JSON.stringify(dataList));
        // if (dataList.length > 20) {
        //     cmp.contactData = dataList.slice(0, 20);
        // } else {
            cmp.contactData = dataList;
       // }

    },
    sortByKey(array, key1, sortDirection) {
        if (array.length >= 2) {
            array.sort(function (a, b) {
                if (a[key1] == undefined) return sortDirection == 'desc' ? 1 : -1;
                if (b[key1] == undefined) return sortDirection == 'desc' ? -1 : 1;
                if (a[key1] < b[key1]) {
                    return sortDirection == 'desc' ? 1 : -1;
                }
                if (a[key1] > b[key1]) {
                    return sortDirection == 'desc' ? -1 : 1;
                }
                return 0;
            });
        }
        return array;
        
},
formatDate(dateString) {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat(undefined, {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(date);
},
    createtablestructure(cmp) {
        cmp.conColumns = [];
        var items = [];
        var temp = [];
        var temp1 = [];
        var tableAttributes = new Object();
        tableAttributes.alignment = "left";
        for (const val of cmp.columnsToShow) {
            let finalVal = new Object();
            finalVal.cellAttributes = tableAttributes;
            finalVal.objName = val.split(':')[0];
            finalVal.fieldApiName = val.split(':')[1];
            finalVal.fieldName = val.split(':')[1] + '_' + val.split(':')[0];
            finalVal.label = val.split(':')[2];
            finalVal.actualType = val.split(':')[3];
            finalVal.type = val.split(':')[3];
            finalVal.hideDefaultActions=true;       //Ui fixes by salauddin sheikh 
            finalVal.sortable = false;  //changes for bug #00041504 fixes by salauddin sheikh
            if (finalVal.fieldName.includes('Name_Contact')) {
              
                finalVal.type = cmp.pageName == 'DAIT' ? 'conClicks' : 'url';
               
                finalVal.typeAttributes = {
                    target: '_blank',
                    tooltip: { fieldName: finalVal.fieldName + '_label' },
                    label: { fieldName: finalVal.fieldName + '_label' }
                };
            } else if (finalVal.fieldName.includes('Name_Account')) {
               
                finalVal.type = cmp.pageName == 'DAIT' || cmp.pageName == 'DAIT_ConRole' ? 'conClicks' : 'url';
              
                finalVal.typeAttributes = {
                    target: '_blank',
                    tooltip: { fieldName: finalVal.fieldName + '_label' },
                    label: { fieldName: finalVal.fieldName + '_label' }
                }; 
                
            }
            else if (finalVal.objName === 'Custom') {
                finalVal.label = 'Meeting and Calls';
                finalVal.type = 'button'; //cmp.pageName == 'DAIT' || cmp.pageName == 'DAIT_ConRole' ? 'conClicks' : 'url';
                finalVal.initialWidth = 60; //Ui fixes by salauddin sheikh
                finalVal.iconName = 'utility:event';
                finalVal.iconSize = 'medium';
                finalVal.hideDefaultActions = true;
               // tableAttributes.alignment = "center"; //Ui fixes by salauddin sheikh
                finalVal.typeAttributes = {
                    label: { fieldName: finalVal.fieldName + '_label' },
                    tooltip:  { fieldName: finalVal.fieldName + '_label' }, //fixes for bug #00041603 by salauddin sheikh
                    variant: 'base',
                };
            }
          
           if(finalVal.type=='reference')
            {
                finalVal.type='string';
                finalVal.actualType='string';
            }
            if(finalVal.type == 'date'){ //UI, local fixes by salauddin sheikh 6th july 2023
                finalVal.typeAttributes = {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour12: false
                },
                finalVal.actualType='date-local';
                finalVal.cellAttributes= { alignment: 'left' }
                finalVal.formatter= this.formatDate;
            }
            //Added below if clause by LK on 2024-05-23 to fix 00045879
            if(finalVal.type == 'email'){
                finalVal.initialWidth = 300;
            }
           
            items.push(finalVal);
        }

        // console.log('items' + JSON.stringify(items));
       
        cmp.conColumns = items;
       
        cmp.nonsortable=[];
       
       for (const val of cmp.columnsToShow1) {
        let finalVal = new Object();
        finalVal.cellAttributes = tableAttributes;
        finalVal.objName = val.split(':')[0];
        finalVal.fieldApiName = val.split(':')[1];
        finalVal.fieldName = val.split(':')[1] + '_' + val.split(':')[0];
        finalVal.label = val.split(':')[2];
        finalVal.actualType = val.split(':')[3];
        finalVal.type = val.split(':')[3];
        finalVal.sortable = false;
        finalVal.hideDefaultActions=true;    //Ui fixes by salauddin sheikh 
        if (finalVal.fieldName.includes('Name_Contact')) {
            finalVal.type = cmp.pageName == 'DAIT' ? 'conClicks' : 'url';
           
            finalVal.typeAttributes = {
                target: '_blank',
                tooltip: { fieldName: finalVal.fieldName + '_label' },
                label: { fieldName: finalVal.fieldName + '_label' }
            };
        } else if (finalVal.fieldName.includes('Name_Account')) {
            finalVal.type = cmp.pageName == 'DAIT' || cmp.pageName == 'DAIT_ConRole' ? 'conClicks' : 'url';
          
            finalVal.typeAttributes = {
                target: '_blank',
                tooltip: { fieldName: finalVal.fieldName + '_label' },
                label: { fieldName: finalVal.fieldName + '_label' }
            };
            
        }
        else if (finalVal.fieldName.includes('Meetings_Custom')) {
            finalVal.type = 'button';
          
            finalVal.typeAttributes = {
                target: '_blank',
                tooltip: { fieldName: finalVal.fieldName + '_label' },
                label: { fieldName: finalVal.fieldName + '_label' }
            };
            
        }
      
       if(finalVal.type=='reference')
        {
            finalVal.type='string';
            finalVal.actualType='string';
        }
       
        temp.push(finalVal);
    }
        let sel_ConColumns = JSON.parse(JSON.stringify(temp));
        sel_ConColumns.forEach(item => {
            if (item.type == 'conClicks') {
                item.type = 'url';
            }
            if (item.type == 'multipicklist') {
                cmp.nonsortable.push(item.fieldName);
            }
        })
        sel_ConColumns.unshift({
            type: 'button-icon',
            label: 'Remove',
            fixedWidth: 70,
            typeAttributes: {
                iconName: 'utility:close',
                name: 'delete',
                iconClass: 'slds-icon-text-error',
                variant: 'bare',
                title: 'Remove Record'//Updated title msg by LK on 2024-10-10 to fix 00047534
                
            }
        });
  
        cmp.sel_ConColumns = sel_ConColumns;
        //console.log('####sel_ConColumns'+JSON.stringify(cmp.sel_ConColumns));
        for (const val of cmp.columnsReviewContactNew) {
            let finalVal = new Object();
            finalVal.cellAttributes = tableAttributes;
            finalVal.objName = val.split(':')[0];
            finalVal.fieldApiName = val.split(':')[1];
            finalVal.fieldName = val.split(':')[1] + '_' + val.split(':')[0];
            finalVal.label = val.split(':')[2];
            finalVal.actualType = val.split(':')[3];
            finalVal.type = val.split(':')[3];
            finalVal.sortable = false;
            finalVal.hideDefaultActions=true;    //Ui fixes by salauddin sheikh 
           // console.log('columnNew-->'+finalVal.fieldName);
            if (finalVal.fieldName.includes('Name_Contact')) {
                finalVal.type = cmp.pageName == 'DAIT' ? 'conClicks' : 'url';
               
                finalVal.typeAttributes = {
                    target: '_blank',
                    tooltip: { fieldName: finalVal.fieldName + '_label' },
                    label: { fieldName: finalVal.fieldName + '_label' }
                };
            } else if (finalVal.fieldName.includes('Name_Account')) {
                finalVal.type = cmp.pageName == 'DAIT' || cmp.pageName == 'DAIT_ConRole' ? 'conClicks' : 'url';
              
                finalVal.typeAttributes = {
                    target: '_blank',
                    tooltip: { fieldName: finalVal.fieldName + '_label' },
                    label: { fieldName: finalVal.fieldName + '_label' }
                };
                
            }
            else if (finalVal.fieldName.includes('navpeII_dev18__Role__c_navpeII_dev18__Fundraising_Contact__c')) {
                finalVal.type = 'picklist';
              
                finalVal.typeAttributes = {
                    // target: '_blank',
                    // tooltip: { fieldName: finalVal.fieldName + '_label' },
                    // label: { fieldName: finalVal.fieldName + '_label' },
                    context: {  fieldName: 'Id' },
                    editable: true,
                    options: { fieldName: 'picklistOptions'},
                    value: { fieldName: 'selectedPicklistOptions'},
                    fieldApiName: finalVal.fieldApiName
                };
                finalVal.fieldName = 'selectedRole';
                
            }
          
           if(finalVal.type=='reference')
            {
                finalVal.type='string';
                finalVal.actualType='string';
            }
           
            temp1.push(finalVal);
        }
        let sel_ConColumns1 = JSON.parse(JSON.stringify(temp1));
        sel_ConColumns1.forEach(item => {
            if (item.type == 'conClicks') {
                item.type = 'url';
            }
            if (item.type == 'multipicklist') {
                cmp.nonsortable.push(item.fieldName);
            }
        })
        sel_ConColumns1.unshift({
            type: 'button-icon',
            label: 'Remove',
            fixedWidth: 70,
            typeAttributes: {
                iconName: 'utility:close',
                name: 'delete',
                iconClass: 'slds-icon-text-error',
                variant: 'bare',
                title: 'Remove Record'//Updated title msg by LK on 2024-10-10 to fix 00047534
                
            }
        });
  
        cmp.sel_ConColumns1 = sel_ConColumns1;

    },

    showToast(cmp, title, message, variant) {
        if (message && message.toLowerCase().includes('permission')) {
            cmp.errorInfo = {
                'infoTitle': 'Insufficient Permission',
                'infoMessage': message
            }
        } else {
            cmp.errorInfo = undefined;
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            cmp.dispatchEvent(event);
        }
    }
}