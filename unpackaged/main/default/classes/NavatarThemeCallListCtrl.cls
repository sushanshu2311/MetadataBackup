public with sharing class NavatarThemeCallListCtrl {
    
    @AuraEnabled    
    public static ThemeCallListWrapper getThemeCallListData(String recordId){
        string namespacePrefix = getNamespacePrefix();
        namespacePrefix = (string.isNotBlank(namespacePrefix)) ? namespacePrefix+'__' : '';

        ThemeCallListWrapper dWrap = new ThemeCallListWrapper();
        String objName;
        String strFields;
        String mtdRecIdentifier;
        try {
            mtdRecIdentifier='Theme_Call_List';
            Acuity_Setting__mdt field1Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier+'_Field1');
            Acuity_Setting__mdt field2Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier+'_Field2');
            Acuity_Setting__mdt field3Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier+'_Field3');
            Acuity_Setting__mdt field4Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier+'_Field4');
            Acuity_Setting__mdt field5Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier+'_Field5');
            Acuity_Setting__mdt field6Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier+'_Field6');
            
            if(field1Metadata != null && field1Metadata.Value__c != null){
                dWrap.fieldHeader1=fetchFieldLabel(field1Metadata.Value__c.split('\\.')[0].replace('__r',''),field1Metadata.Value__c);            
                dWrap.fieldHeader1 = checkLabel(dWrap.fieldHeader1);
            }

            if(field2Metadata != null && field2Metadata.Value__c != null){
                dWrap.fieldHeader2=(field2Metadata!=null && field2Metadata.Value__c!=null)
                                ? fetchFieldLabel(field2Metadata.Value__c.split('\\.')[0].replace('__r',''),field2Metadata.Value__c)//modified for fixing Bug #31507
                                : null;
                dWrap.fieldHeader2 = checkLabel(dWrap.fieldHeader2);
            }
            
            if(field3Metadata != null && field3Metadata.Value__c != null){
                dWrap.fieldHeader3=(field3Metadata!=null && field3Metadata.Value__c!=null)
                                ? fetchFieldLabel(field3Metadata.Value__c.split('\\.')[0].replace('__r',''),field3Metadata.Value__c)//modified for fixing Bug #31507
                                : null;                
                dWrap.fieldHeader3 = checkLabel(dWrap.fieldHeader3);
            }
            
            if(field4Metadata != null && field4Metadata.Value__c != null){
                dWrap.fieldHeader4=(field4Metadata!=null && field4Metadata.Value__c!=null)
                                ? fetchFieldLabel(field4Metadata.Value__c.split('\\.')[0].replace('__r',''),field4Metadata.Value__c)//modified for fixing Bug #31507
                                : null;                
                dWrap.fieldHeader4 = checkLabel(dWrap.fieldHeader4);
            }

            if(field5Metadata != null && field5Metadata.Value__c != null){
                dWrap.fieldHeader5=(field5Metadata!=null && field5Metadata.Value__c!=null)
                                ? fetchFieldLabel(field5Metadata.Value__c.split('\\.')[0].replace('__r',''),field5Metadata.Value__c)//modified for fixing Bug #31507
                                : null;            
                dWrap.fieldHeader5 = checkLabel(dWrap.fieldHeader5);
            }

            dWrap.fieldHeader6='Log Notes';            
            dWrap.fieldHeader6 = checkLabel(dWrap.fieldHeader6);
            
            dWrap.isFieldTypeURL2=(field2Metadata!=null && 
                                  field2Metadata.Value__c!=null &&
                                  field2Metadata.Value__c.contains('.'))
                                  ? true:false;
            //Modified checkTypeAttribute() to handle 2 parameters by Anmol
            System.debug(field1Metadata);
            strFields=((field1Metadata!=null && field1Metadata.Value__c!=null)
                       ? (','+field1Metadata.Value__c)
                       :'')+
                      ((field2Metadata!=null && field2Metadata.Value__c!=null)
                       ? (','+'navpeII_dev18__Contact__r.'+field2Metadata.Value__c)
                       :'') +
                      ((field3Metadata!=null && field3Metadata.Value__c!=null)
                       ? (','+field3Metadata.Value__c.replace('Account','Firm'))
                       : '')+
                      ((field4Metadata!=null && field4Metadata.Value__c!=null)
                       ? (','+field4Metadata.Value__c.replace('Account','Firm'))
                       : '') + 
                       ((field5Metadata!=null && field5Metadata.Value__c!=null)
                       ? (','+field5Metadata.Value__c.replace('Account','Firm'))
                       : '');
            
            if(strFields.startsWith(','))   strFields = strFields.right(strFields.length() - 1);
            
            // To check fields dynamically - start
            Map<String, String> lstOfObj = new Map<String, String>();
            lstOfObj.put('navpeII_dev18__Theme_Relation__c', 'navpeII_dev18__Theme_Relation__c');
            for(Schema.SObjectField ster : Theme_Relation__c.getSobjectType().getDescribe().fields.getMap().values()){    
                if(ster.getDescribe().getType()+'' == 'REFERENCE'){
                    for(Schema.SObjectType reference : ster.getDescribe().getReferenceTo()) {            
                        lstOfObj.put(reference.getDescribe().getName(), ster.getDescribe().getRelationshipName());
                    }
                }
            }
            Map<String, Set<String>> objFieldValues = new Map<String, Set<String>>();
            for(String str : lstOfObj.keySet()){
                System.debug(str);
                objFieldValues.put(lstOfObj.get(str), Schema.getGlobalDescribe().get(str).getDescribe().fields.getMap().keySet());
            }
            System.debug(objFieldValues);
            // To check fields dynamically - end

            List <sObject> listRecs = new List < sObject >();
            
            if(!strFields.contains('navpeII_dev18__Contact__c'))
            strFields += ',navpeII_dev18__Contact__c'; 
                
            if(!strFields.contains('navpeII_dev18__Contact__r.AccountId'))
                strFields += ',navpeII_dev18__Contact__r.AccountId';
            list<string> fieldList = strFields.split(',');
            system.debug('fieldList++'+fieldList);
            list<string> tempList = new list<string>();
            for(string fld : fieldList){                
                system.debug('fld++'+fld);
                if(fld.contains('__r')){
                    String[] setString = fld.split('\\.');
                    if(setString.size() == 2 && objFieldValues.containsKey(setString[0]) && objFieldValues.get(setString[0]+'').contains((setString[1]).toLowercase())){
                        string temp = fld;
                        fld = 'FORMAT('+temp+')';
                        tempList.add(fld);
                    }else if(setString.size() == 3){
                        string temp = fld;
                        fld = 'FORMAT('+temp+')';
                        tempList.add(fld);
                    }
                }else{
                    string temp = fld;
                    fld = 'FORMAT('+temp+')';
                    tempList.add(fld);
                }
            }
            system.debug('2 fieldList++'+fieldList);
            system.debug('2 tempList++'+tempList);
                      
            strFields = string.join(tempList,',');
            String strSOQL = 'SELECT Id, ' + String.escapeSingleQuotes(strFields) + ' FROM navpeII_dev18__Theme_Relation__c WHERE navpeII_dev18__Theme__c =: recordId AND navpeII_dev18__Contact__c != null ';
            Boolean touchpointOverdue = false;
            if(objFieldValues.containsKey('navpeII_dev18__Contact__r') && objFieldValues.get('navpeII_dev18__Contact__r').contains(('Touchpoint_Overdue__c').toLowercase())){
                strSOQL += ' order by navpeII_dev18__Contact__r.Touchpoint_Overdue__c desc ';
                touchpointOverdue = true;
            }            
            if(objFieldValues.containsKey('navpeII_dev18__Contact__r') && objFieldValues.get('navpeII_dev18__Contact__r').contains(('Next_Touchpoint_Date__c').toLowercase())){
                if(!touchpointOverdue){
                    strSOQL += ' order by navpeII_dev18__Contact__r.Next_Touchpoint_Date__c';
                }else{
                    strSOQL += ' ,navpeII_dev18__Contact__r.Next_Touchpoint_Date__c';
                }                
            }

            system.debug('strSOQL++'+strSOQL);
            listRecs = Database.query(strSOQL);
            List<ThemeListFldWrapper> dInfoWrapprList=new List<ThemeListFldWrapper>();
            
            for(SObject sRec:listRecs){
                ThemeListFldWrapper dealInfoWrapRec=new ThemeListFldWrapper();
                ReferenceWrapper resRec1=new ReferenceWrapper();
                ReferenceWrapper resRec2=new ReferenceWrapper();
                ReferenceWrapper resRec3=new ReferenceWrapper();
                ReferenceWrapper resRec4=new ReferenceWrapper();
                ReferenceWrapper resRec5=new ReferenceWrapper();
                ReferenceWrapper resRec6=new ReferenceWrapper();
                if(dWrap.fieldHeader1 != null){
                    if(sRec.get('navpeII_dev18__Contact__c')!= null && field1Metadata != null && field1Metadata.value__c != null){
                        resRec1.nameRef='/'+sRec.get('navpeII_dev18__Contact__c');
                    }else{  
                        resRec1.nameRef='';
                    }
                    if(sRec.get('navpeII_dev18__Contact__c') != null && field1Metadata != null && field1Metadata.value__c != null){
                    resRec1.name=(field1Metadata.Value__c.contains('.')?
                                String.valueOf(sRec.getsObject(field1Metadata.Value__c.replace('Account','Firm').split('\\.')[0]).get(field1Metadata.Value__c.split('\\.')[1])):
                                String.valueOf(sRec.get(field1Metadata.Value__c)));
                    }else{
                        resRec1.name = '';
                    }                    
                }
                dealInfoWrapRec.fieldInfo1=resRec1;
                
                if(dWrap.fieldHeader2 != null){
                    if(sRec.get('navpeII_dev18__Contact__c')!= null){
                        resRec2.nameRef='/'+sRec.getsObject('navpeII_dev18__Contact__r').get('AccountId');
                    }else{
                        resRec2.nameRef='';
                    }
                    System.debug(sRec);
                    System.debug(sRec.getsObject('navpeII_dev18__Contact__r'));
                        resRec2.name=(field2Metadata!=null && field2Metadata.Value__c!=null && sRec.get('navpeII_dev18__Contact__c') != null && sRec.getsObject('navpeII_dev18__Contact__r').get('AccountId')!=null ? 
                        (field2Metadata.Value__c.contains('.'))?
                                String.valueOf(sRec.getsObject('navpeII_dev18__Contact__r').getsObject('Account').get(field2Metadata.Value__c.split('\\.')[1])) : String.valueOf(sRec.get(field2Metadata.Value__c)):'');
                    
                }
                dealInfoWrapRec.fieldInfo2=resRec2;

                if(dWrap.fieldHeader3 != null){
                    resRec3.nameRef=(field3Metadata!=null && field3Metadata.Value__c!=null && field3Metadata.Value__c.contains('.') && sRec.get(field3Metadata.Value__c.split('\\.')[0].replace('__r','__c').replace('Account','Firm'))!=null)?
                    ('/'+String.valueOf(sRec.getsObject(field3Metadata.Value__c.replace('Account','Firm').split('\\.')[0]).get('Id'))):'';
                    
                    resRec3.name=(field3Metadata!=null && field3Metadata.Value__c!=null && sRec.get(field3Metadata.Value__c.replace('__r','__c').split('\\.')[0])!=null?
                                (field3Metadata.Value__c.contains('.')?
                                String.valueOf(checkDateAttribute(mtdRecIdentifier+'_Field3',sRec.getsObject(field3Metadata.Value__c.replace('Account','Firm').split('\\.')[0]).get(field3Metadata.Value__c.split('\\.')[1]))):
                                String.valueOf(checkDateAttribute(mtdRecIdentifier+'_Field3',sRec.get(field3Metadata.Value__c)))):'');                    
                }
                dealInfoWrapRec.fieldInfo3=resRec3;
                
                if(dWrap.fieldHeader4 != null){
                    resRec4.nameRef=(field4Metadata!=null && field4Metadata.Value__c!=null && field4Metadata.Value__c.contains('.') && sRec.get(field4Metadata.Value__c.split('\\.')[0].replace('__r','__c').replace('Account','Firm'))!=null)?
                    ('/'+String.valueOf(sRec.getsObject(field4Metadata.Value__c.replace('Account','Firm').split('\\.')[0]).get('Id'))):'';
                    resRec4.name=(field4Metadata!=null && field4Metadata.Value__c!=null && sRec.get(field4Metadata.Value__c.replace('__r','__c').split('\\.')[0])!=null?
                                (field4Metadata.Value__c.contains('.')?
                                String.valueOf(checkDateAttribute(mtdRecIdentifier+'_Field4',sRec.getsObject(field4Metadata.Value__c.replace('Account','Firm').split('\\.')[0]).get(field4Metadata.Value__c.split('\\.')[1]))):
                                String.valueOf(checkDateAttribute(mtdRecIdentifier+'_Field4',sRec.get(field4Metadata.Value__c)))):'');                    
                }
                dealInfoWrapRec.fieldInfo4=resRec4;

                if(dWrap.fieldHeader5 != null){
                    resRec5.nameRef=(field5Metadata!=null && field5Metadata.Value__c!=null && field5Metadata.Value__c.contains('.') && sRec.get(field5Metadata.Value__c.split('\\.')[0].replace('__r','__c').replace('Account','Firm'))!=null)?
                    ('/'+String.valueOf(sRec.getsObject(field5Metadata.Value__c.replace('Account','Firm').split('\\.')[0]).get('Id'))):'';
                    resRec5.name=(field5Metadata!=null && field5Metadata.Value__c!=null && sRec.get(field5Metadata.Value__c.replace('__r','__c').split('\\.')[0])!=null?
                                (field5Metadata.Value__c.contains('.')?
                                String.valueOf(checkDateAttribute(mtdRecIdentifier+'_Field5',sRec.getsObject(field5Metadata.Value__c.replace('Account','Firm').split('\\.')[0].replace('Account','Firm')).get(field5Metadata.Value__c.split('\\.')[1]))):
                                String.valueOf(checkDateAttribute(mtdRecIdentifier+'_Field5',sRec.get(field5Metadata.Value__c)))):'');
                }
                dealInfoWrapRec.fieldInfo5=resRec5;

                resRec6.name= 'lognoteIcon';
                resRec6.iconName ='utility:new_direct_message';
                dealInfoWrapRec.fieldInfo6=resRec6;
        
                dInfoWrapprList.add(dealInfoWrapRec);
            }
            dWrap.themeDataList=dInfoWrapprList;
            system.debug('dWrap++'+dWrap);
            return dWrap;
            
        } catch(Exception e) {
            system.debug('e.linenumber++'+e.getlinenumber() + ' > ' + e.getMessage());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    public static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix;
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }

    public static String fetchFieldLabel(String objName, String fieldName){
        try {
            if(fieldName.contains('.')) fieldName = fieldName.split('\\.')[1];
            if(fieldName == 'Name' && objName == 'Account'){
                return 'Firm'; // Updated the legal name as Firm at all places
            }else{
                if(Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase())){ 
                    return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel(); 
                } 
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Handles the check Date values
     * Input : identifier        [String identifier for metadata setting to be used]
     *         dateVal           [date value to be processed]
     * Returns : Final date value formatted in User locale as String
     */
    public static String checkDateAttribute(String identifier,Object dateVal){
        try {
            if(String.isNotBlank(String.valueOf(dateVal)) && Acuity_Setting__mdt.getInstance(identifier).Value__c.contains('Date')){
                //Date dVal=Date.valueOf(dateVal);
                return String.valueOf(dateVal);
            } else {
                return String.valueOf(dateVal);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }

    public static string checkLabel(string label){
        if(label == 'Business Phone'){
            label = 'Phone';
        }else if(label == 'Full Name'){
            label = 'Name';
        }
        return label;
    }

    @AuraEnabled
    public static ThemeCallListWrapper getFirmListData(String recordId){
        ThemeCallListWrapper dWrap = new ThemeCallListWrapper();
        String objName;
        String strFields;
        String mtdRecIdentifier;
        try {
            mtdRecIdentifier='Theme_Call_List_Import_Field1';
            Acuity_Setting__mdt field1Metadata = Acuity_Setting__mdt.getInstance(mtdRecIdentifier);
            dWrap.fieldHeader1=(field1Metadata!=null && field1Metadata.Value__c!=null)
                               ? fetchFieldLabel('Account',field1Metadata.Value__c)
                               : null;

            dWrap.fieldHeader1 = checkLabel(dWrap.fieldHeader1);

            dWrap.fieldHeader2= 'Record Type';

            strFields=(field1Metadata!=null && field1Metadata.Value__c!=null)
            ? (field1Metadata.Value__c)
            :'';
            List <sObject> listRecs = new List < sObject >();
            if(string.isNotBlank(strFields)){
                strFields += ', RecordType.Name, RecordtypeId '; 
            }else{
                strFields = ' RecordType.Name, RecordtypeId '; 
            }

            String strSOQL = 'SELECT Id, ' + String.escapeSingleQuotes(strFields) + ' FROM Account WHERE Id In (SELECT navpeII_dev18__Account__c FROM navpeII_dev18__Theme_Relation__c Where navpeII_dev18__Theme__c =: recordId)';
            system.debug('strSOQL++'+strSOQL);
            listRecs = Database.query(strSOQL);
            List<ThemeListFldWrapper> dInfoWrapprList=new List<ThemeListFldWrapper>();

            for(SObject sRec:listRecs){
                ThemeListFldWrapper dealInfoWrapRec=new ThemeListFldWrapper();
                ReferenceWrapper resRec1=new ReferenceWrapper();
                ReferenceWrapper resRec2=new ReferenceWrapper();

                system.debug('sRec++'+sRec);

                resRec1.nameRef='/'+sRec.get('Id');
                resRec1.name=(field1Metadata.Value__c.contains('.')?
                                String.valueOf(sRec.getsObject(field1Metadata.Value__c.split('\\.')[0]).get(field1Metadata.Value__c.split('\\.')[1])):
                                String.valueOf(sRec.get(field1Metadata.Value__c)));
                dealInfoWrapRec.fieldInfo1=resRec1;
                system.debug('resRec1++'+resRec1);

                resRec2.name = string.valueOf(sRec.getsObject('RecordType').get('Name'));
                dealInfoWrapRec.fieldInfo2=resRec2;

                system.debug('dealInfoWrapRec++'+dealInfoWrapRec);

                dInfoWrapprList.add(dealInfoWrapRec);
                
            }
            dWrap.themeDataList=dInfoWrapprList;
            system.debug('dWrap++'+dWrap);
            return dWrap;
            
        } catch(Exception e) {
            system.debug('e.linenumber++'+e.getlinenumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }

    @AuraEnabled
    public static Boolean importContactsToTheme(String recordId, List<Id> selectedFirm){
        try {
            Set<Id> contactSet = new Set<Id>();
            for(navpeII_dev18__Theme_Relation__c themeRel : [Select navpeII_dev18__Contact__c From navpeII_dev18__Theme_Relation__c Where navpeII_dev18__Theme__c =: recordId AND navpeII_dev18__Contact__c != null]){
                contactSet.add(themeRel.navpeII_dev18__Contact__c);
            }
            List<navpeII_dev18__Theme_Relation__c> relationList = new List<navpeII_dev18__Theme_Relation__c>();
            for(Contact con : [Select Id, Name From Contact Where AccountId IN: selectedFirm AND Id NOT IN: contactSet]){
                navpeII_dev18__Theme_Relation__c thmObj = new navpeII_dev18__Theme_Relation__c();
                thmObj.navpeII_dev18__Contact__c = con.Id;
                thmObj.navpeII_dev18__Theme__c = recordId;
                relationList.add(thmObj);
            }
            if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isCreateable()){
                insert relationList;
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ReferenceWrapper{
        @AuraEnabled public String name;    //Record Name
        @AuraEnabled public String nameRef; //Record URL
        @AuraEnabled public String type;    //Record Object name
        @AuraEnabled public String iconName;//Record Icon
    }

    /*
     * Purpose : Wrapper for Themes Section info
     */
    public class ThemeListFldWrapper{
        @AuraEnabled public ReferenceWrapper fieldInfo1;    //Stores info of 1st column
        @AuraEnabled public ReferenceWrapper fieldInfo2;    //Stores info of 2nd column
        @AuraEnabled public ReferenceWrapper fieldInfo3;    //Stores info of 3rd column
        @AuraEnabled public ReferenceWrapper fieldInfo4;    //Stores info of 4th column
        @AuraEnabled public ReferenceWrapper fieldInfo5;    //Stores info of 5th column
        @AuraEnabled public ReferenceWrapper fieldInfo6;    //Stores info of 6th column
    }

    /*
     * Purpose : Wrapper for Theme Datapoint/Modal info
     */
    public class ThemeCallListWrapper{
        @AuraEnabled public List<ThemeListFldWrapper> themeDataList;   //Stores info of Theme
        @AuraEnabled public String fieldHeader1;    //Stores column header label of 1st column
        @AuraEnabled public String fieldHeader2;    //Stores column header label of 2nd column
        @AuraEnabled public String fieldHeader3;    //Stores column header label of 3rd column
        @AuraEnabled public String fieldHeader4;    //Stores column header label of 4th column
        @AuraEnabled public String fieldHeader5;    //Stores column header label of 5th column
        @AuraEnabled public String fieldHeader6;    //Stores column header label of 6th column
        @AuraEnabled public Boolean isFieldTypeURL2;  //Stores column header type (url/text) of 2nd column
        // @AuraEnabled public Boolean isFieldTypeURL3;  //Stores column header type (url/text) of 3rd column
        // @AuraEnabled public Boolean isFieldTypeURL4;  //Stores column header type (url/text) of 4th column
        @AuraEnabled public String title;           //Stores header of Deals Section
    }
}