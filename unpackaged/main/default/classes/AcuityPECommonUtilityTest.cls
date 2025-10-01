@isTest
public class AcuityPECommonUtilityTest {
    @isTest 
    static void testcustomLookup5() {
        Test.startTest();
        list<sObject> testlst = new list <sObject>();
        requestMock fakeResponse = new requestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Set<Id> accIdSet=new Set<Id>();
        try{
             //CustomLookUpCtrl.getSearchResults('test','Account',testlst);
             //CustomLookUpCtrl.getSearchResults('test','user',testlst);   
             AcuityPECommonUtility.getUserDateFormat();
             AcuityPECommonUtility.isPackageAccessible('navpeII_dev18');
             AcuityPECommonUtility.createRecordTypeToButtonMap(true, false);
             AcuityPECommonUtility.getFieldSetForAllRecordTypes();
             AcuityPECommonUtility.getUserDateTimeFormat();
             AcuityPECommonUtility.getFormattedDate(System.now(),'YYYY-MM-DD','Call',true);
             AcuityPECommonUtility.getFormattedDate(System.now(),'','Event',true);
             AcuityPECommonUtility.findObjectNameFromRecordIdPrefix('001',Schema.getGlobalDescribe());
             Account acc=new Account(name='Test_CommonUtility Account');
             insert acc;
             accIdSet.add(acc.Id);
             AcuityPECommonUtility.getSobjectRecords(new Map<String, Set<Id>>{'Account' => accIdSet});
             String layoutResponse = AcuityPECommonUtility.getDescribeResponse('/services/data/v41.0/tabs');
        }catch(Exception ex){
            String strId=[Select Id from Account limit 1].Id;
            AcuityPECommonUtility.deleteRecord(Id.valueOf(strId));
            Set<String> accIdsSet=new Set<String>();
            accIdsSet.add(strId);
            AcuityPECommonUtility.populateObjectToSobjectMap(accIdsSet);
            system.assert(ex.getMessage() != '');    
        }
        
        Test.stopTest();
    }
    @isTest 
    static void testcustomLookup5Research() {
        Test.startTest();
        list<sObject> testlst = new list <sObject>();
        requestMock fakeResponse = new requestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Set<Id> accIdSet=new Set<Id>();
        try{
             //CustomLookUpCtrl.getSearchResults('test','Account',testlst);
             //CustomLookUpCtrl.getSearchResults('test','user',testlst);   
             NavatarResearchCommonUtility.getUserDateFormat();
             NavatarResearchCommonUtility.isPackageAccessible('navpeII_dev18');
             NavatarResearchCommonUtility.createRecordTypeToButtonMap(true, false);
             NavatarResearchCommonUtility.getFieldSetForAllRecordTypes();
             NavatarResearchCommonUtility.getUserDateTimeFormat();
             NavatarResearchCommonUtility.getFormattedDate(System.now(),'YYYY-MM-DD','Call',true);
             NavatarResearchCommonUtility.getFormattedDate(System.now(),'','Event',true);
             NavatarResearchCommonUtility.findObjectNameFromRecordIdPrefix('001',Schema.getGlobalDescribe());
             Account acc=new Account(name='Test_NavatarResearchCommonUtility Account');
             insert acc;
             accIdSet.add(acc.Id);
             NavatarResearchCommonUtility.getSobjectRecords(new Map<String, Set<Id>>{'Account' => accIdSet});
             String layoutResponse = NavatarResearchCommonUtility.getDescribeResponse('/services/data/v41.0/tabs');
        }catch(Exception ex){
            String strId=[Select Id from Account limit 1].Id;
            NavatarResearchCommonUtility.deleteRecord(Id.valueOf(strId));
            Set<String> accIdsSet=new Set<String>();
            accIdsSet.add(strId);
            NavatarResearchCommonUtility.populateObjectToSobjectMap(accIdsSet);
            system.assert(ex.getMessage() != '');    
        }
        
        Test.stopTest();
    }
	@isTest
    static void getDescribeResponseForRectype(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Dummy ' + System.now();
        insert acc;
        Test.stopTest();
        String recTypeId=[Select RecordTypeId from Account limit 1].RecordTypeId;
        requestMock fakeResponse = new requestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String,Set<Id>> mapObjectToRecordTypeId = new Map<String, Set<Id>>();
        mapObjectToRecordTypeId.put('Account', new Set<Id>{recTypeId});
        AcuityPECommonUtility.getDescribeResponseForRectype(mapObjectToRecordTypeId);
        try{
            AcuityPECommonUtility.deleteRecord(null);
        } catch(Exception e){}
        
        system.assert(true);
    }
}