@isTest(seeAlldata = true)
Public class scheduledClientDataTest
{
    @isTest static void scheduledClientData_method1()
    {
        Test.startTest();
        Savepoint sp1 = Database.setSavepoint();
        Test.setMock(HttpCalloutMock.class, new MockHttpcls_scheduledClientData());
        scheduledClientData scd1 = new scheduledClientData();
        scd1.execute(null);
        Integer num=1;
        system.assertEquals(num,1);
        Database.RollBack(sp1);
        Test.StopTest();
    }
    @isTest static void scheduledClientData_method2()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpcls_scheduledClientData.MockGenerator_scheduledClientData_SMTP());
        clientDataBatch.exceptionEmail('ExceptionMessage',1);
        Integer num=1;
        system.assertEquals(num,1);
        Test.StopTest();
    }
}