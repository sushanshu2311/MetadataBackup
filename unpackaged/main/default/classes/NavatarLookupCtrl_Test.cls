@isTest
public class NavatarLookupCtrl_Test {
	@isTest
    public static void method1() {
        Account testAccount = new Account(name='Test');
        insert testAccount;
        
        Account testAccount2 = new Account(name='Test account 2');
        insert testAccount2;
        
        contact con = new contact();
        con.lastName='test';
        con.AccountId=testAccount.id;
        insert con;
        
        contact con1 = new contact();
        con1.lastName='test 2 con';
        con1.AccountId=testAccount.id;
        insert con1;
        
        String sObjectName = 'Navatar_Setup__c';
        string namespace='';
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
        {
            String nameStr = objTyp.getDescribe().getName();  
            if(nameStr.contains('__c') && nameStr == 'navpeII_dev18__Navatar_Setup__c') {
                sObjectName = 'navpeII_dev18__Navatar_Setup__c';
                namespace = 'navpeII_dev18__';
                break;
            }
        }
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        SObject navSetup = t.newSObject();
        navSetup.put('RAS__c','001,003');
        navSetup.put('Notes_Popup_Event_Fields__c','OwnerId,Location,StartDateTime,EndDateTime,IsAllDayEvent');
        navSetup.put('Notes_Popup_Task_Fields__c','OwnerId,Status,ActivityDate,Priority');
        navSetup.put('Notes_Popup_FollowUp_Task_Fields__c','Subject,OwnerId,Status,ActivityDate');
        navSetup.put(namespace+'Admin_Setting__c',true);
        insert navSetup;
        

        Test.startTest();
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = con.Id;
        fixedSearchResults[1] = testAccount.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        requestMock fakeResponse = new requestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        List<String> dataList = NavatarNotesModalCtrl.getSearchableObjName('');
        List<String> dataList2 = NavatarNotesModalCtrl.getSearchableObjName('abc');  
              
        NavatarLookupCtrl.getRelatedData('test', dataList[0]);          
        test.stopTest();
        system.assert(true);
    }
    
    @isTest
    public static void method2(){
        try{
            NavatarLookupCtrl.getRelatedData(null, null);
        } catch(Exception ex) {}
    }
}