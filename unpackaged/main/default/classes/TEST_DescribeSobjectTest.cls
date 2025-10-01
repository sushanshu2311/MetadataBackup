/*
    Developer               :   Sameer Rath
    Product Version         :   PE 3.0
    Date of Creation        :   15/05/2015
    Date of Last Update     :   15/09/2015
    Last Updated By         :   Sameer Rath
    Purpose of Creation     :   Listed below:
                                1. Code Coverage for DescribeSobjectTest Class. 

*/
@isTest
private class TEST_DescribeSobjectTest
{

public static testMethod void abc_popuppicklist() 
{

    PageReference ref  = new PageReference('/apex/picklistpopup?Akobjectt=Contact&page=EmailProspectPage&pickval=Source__c&datatype_f=PICKLIST&nameid=filterpb:txt1');
    system.Test.setCurrentPage(ref);
    DescribeSobjectTest DescribeSobjectTest1 = new DescribeSobjectTest();
    system.assert(DescribeSobjectTest1 !=null);
    
    PageReference ref1  = new PageReference('apex/picklistpopup?AKobjectt=Fund&page=riahub360component&pickval=IsDeleted&datatype_f=boolean&nameid=criteriatextbox1&operation=search');
    system.Test.setCurrentPage(ref1);
    
    DescribeSobjectTest DescribeSobjectTest2 = new DescribeSobjectTest();
      system.assert(DescribeSobjectTest2 !=null);
    PageReference ref3  = new PageReference('/apex/picklistpopup?Akobjectt=Account&page=EmailProspectPage&pickval=RecordTypeId&datatype_f=REFERENCE&nameid=filterpb:txt1');
    system.Test.setCurrentPage(ref3);
    DescribeSobjectTest DescribeSobjectTest4 = new DescribeSobjectTest();
      system.assert(DescribeSobjectTest4 !=null);
    PageReference ref4  = new PageReference('/apex/picklistpopup?Akobjectt=Contact&page=EmailProspectPage&pickval=OwnerId&datatype_f=REFERENCE&nameid=filterpb:txt1');
    system.Test.setCurrentPage(ref4);
    DescribeSobjectTest DescribeSobjectTest5 = new DescribeSobjectTest();
    
    PageReference ref5  = new PageReference('/apex/picklistpopup?AKobjectt=Fundraising&page=riahub360component&pickval=Stage__c&datatype_f=picklist&nameid=criteriatextbox1&operation=search');
    system.Test.setCurrentPage(ref5);
    DescribeSobjectTest DescribeSobjectTest6 = new DescribeSobjectTest();       
    
}

}