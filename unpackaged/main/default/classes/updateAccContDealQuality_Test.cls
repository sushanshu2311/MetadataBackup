/*************************************************************************************************************
Developer               :   Mohammad Ubaid
Product Version         :   PE 4.0
Date of Creation        :   22/01/2019
Purpose of Creation     :   This class covers the code coverage for PE4.0 Triggers
**************************************************************************************************************/
@istest
public class updateAccContDealQuality_Test
{
    static testMethod void  test_updateAccContDealQuality()
    {
        test.startTest();
        Account acc1 = (Account)DynamicDataFactory.createSObject('Account',true);   
        acc1.Name = 'Test_Acc';
        Insert acc1;
        
        Account acc2 = (Account)DynamicDataFactory.createSObject('Account',true);
        acc2.Name = 'Test_Acc2';
        Insert acc2;
        
        Contact cont1 = (Contact)DynamicDataFactory.createSObject('Contact',true);
        cont1.LastName = 'Test_Cont';
        cont1.AccountId = acc1.id;
        Insert Cont1;
        
        Contact cont2 = (Contact)DynamicDataFactory.createSObject('Contact',true);
        cont2.LastName = 'Test_Cont2';
        cont2.AccountId = acc2.id;
        Insert Cont2;
        
        
        navpeII__Pipeline__c tst_pipeline = (navpeII__Pipeline__c)DynamicDataFactory.createSObject('navpeII__Pipeline__c',true);
        tst_pipeline.name = 'Pipeline 1';
        // tst_pipeline.navpeII__Company_Name__c = acc1.id ;
        tst_pipeline.navpeII__Stage__c = 'First Round Bid';
        tst_pipeline.navpeII__Source_Contact__c = Cont1.Id; 
        tst_pipeline.navpeII__Source_Company__c = acc1.id;
        insert tst_pipeline;
        
        
        tst_pipeline.navpeII__Source_Contact__c = Cont2.Id;
        tst_pipeline.navpeII__Source_Company__c = acc2.id;
        update tst_pipeline;
        
        merge acc1 acc2;
        merge Cont1 Cont2;
        undelete acc2;
        undelete cont2;
        delete tst_pipeline;
        test.stopTest();
    }
    
    static testMethod void  test_DynamicDataFactory()
    {
        test.startTest();
        DynamicDataFactory.getDefaultPicklistValue(new Account(), Account.Industry.getDescribe());
        test.stopTest();
    }
}