/**************************************************
** Module Name : Listviewpicklist
** Description : To get list views for all sobjects.
** Test Class : TestListviewpicklist
** Organization : Navatar Group
** Revision History:-
** Version   Date        Author  
** 4.0       2018-12-05  Sheetal 
****************************************************/

global class Listviewpicklist extends VisualEditor.DynamicPickList {
    global list<String> objectNames;
    global list<ListView> lst;
    global String nameSpacePrefix;
    
    global Listviewpicklist(){    	
        //objectNames = new list<string>{'Account','Contact','Opportunity','Activity','navpeII_dev18__Capital_Call__c','navpeII_dev18__Commitment__c','Due_Dilligence__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c','navpeII_dev18__Marketing_Initiative__c','navpeII_dev18__Marketing_Prospect__c','navpeII_dev18__Pipeline__c','navpeII_dev18__Quarterly_Financial_Performance__c','User'};
        Map<String,Schema.SobjectType> schemaMap = Schema.getGlobalDescribe(); 
        objectNames = new list<string>();
        for(String obj :schemaMap.keyset()){
            objectNames.add(schemaMap.get(obj).getDescribe().getName());
        }
    }
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Account:All Accounts' , 'AllAccounts');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {                 
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        lst = [SELECT Id,DeveloperName,name,SObjectType,NameSpacePrefix FROM ListView WHERE SObjectType IN :objectNames order By SObjectType];       
        for(ListView l : lst){
            if(l.NameSpacePrefix != null && l.NamespacePrefix != ''){
                nameSpacePrefix = l.NamespacePrefix + '__';
            }
            else{
                nameSpacePrefix = '';
            }
            myValues.addRow(new VisualEditor.DataRow(l.SObjectType+':'+l.name , l.SObjectType+':'+nameSpacePrefix+l.DeveloperName));
        }
        return myValues;
    }
}