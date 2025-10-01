/****************************************************************************************************

** Module Name : Connections 2.0

** Description : get the metadata records of report.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/

public class NavatarReportCtrl {

    
    /****************************************************************************************************
    Purpose : get the report data from metadata based on recordtype

    Input : recordId - recordid of record

    Returns : String if success returns recordid else error message
    ****************************************************************************************************/
    @AuraEnabled
    public static string getReportData(String recordId){
        try {
            List<ReportWrapper> reportList = new List<ReportWrapper>();
            List<Reports_Setting__mdt> reportMetadataList = new List<Reports_Setting__mdt>();
            String sObjName = '';
            if(recordId != null && recordId != ''){
                String recordTypeName = '';
                ID myId = (Id)recordId;
                sObjName = myId.getSObjectType().getDescribe().getName();
                if(sObjName == 'Account'){
                    List<Account> accList = new List<Account>();
                    accList = [SELECT Id, Name, Recordtypeid, Recordtype.DeveloperName FROM Account WHERE Id =:recordId];
                    recordTypeName = accList[0].Recordtype.DeveloperName;
                }
                if(sObjName == 'Contact'){
                    List<RecordType> recTypeList = new List<RecordType>();
                    recTypeList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType where IsActive = true and SobjectType = 'Contact'];
                    if(recTypeList.size() > 0){
                        List<Contact> conList = new List<Contact>();
                        conList =Database.query('SELECT Id, Name, Recordtypeid, Recordtype.DeveloperName FROM Contact WHERE Id =:recordId and Recordtypeid != null');
                        if(conList.size()>0){
                            recordTypeName = (String)conList[0].getSobject('Recordtype').get('DeveloperName');
                        }else{
                            recordTypeName = 'Master';
                        }
                    }else{
                        recordTypeName = 'Master';
                    }
                }
                reportMetadataList = [SELECT Id, Rpt_Report_Name__c, Rpt_Record_Type__c, Rpt_Report_URL__c, Rpt_Description__c FROM Reports_Setting__mdt WHERE  Rpt_Record_Type__c =: recordTypeName ];
            
            }else{
                reportMetadataList = [SELECT Id, Rpt_Report_Name__c, Rpt_Record_Type__c, Rpt_Report_URL__c, Rpt_Description__c FROM Reports_Setting__mdt WHERE  Rpt_Record_Type__c = null ];
            }
            if(!reportMetadataList.isEmpty()) {
                For(Reports_Setting__mdt reportData : reportMetadataList){
                    ReportWrapper rw = new ReportWrapper();
                    rw.reportName = reportData.Rpt_Report_Name__c;
                    string fullURL = reportData.Rpt_Report_URL__c;
                    if(sObjName == 'Account'){
                        fullURL = fullURL.replace('{!Account.Id}',recordId);
                    }
                    if(sObjName == 'Contact'){
                        fullURL = fullURL.replace('{!Contact.Id}',recordId);
                    }
                    rw.reportURL = fullURL;
                    rw.reportDescription = reportData.Rpt_Description__c;
                    reportList.add(rw);
                }
            }
            return JSON.serialize(reportList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Wrapper to store report data.
    public class ReportWrapper{
        @AuraEnabled public string reportName;
        @AuraEnabled public string reportURL;
        @AuraEnabled public string reportDescription;
    }
}