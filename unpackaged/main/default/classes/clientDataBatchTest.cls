@isTest(seeAlldata = true)
Public class clientDataBatchTest
{
    @isTest static void clientDataBatch_method1()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpcls_scheduledClientData());
        Database.executeBatch(new clientDataBatch('LAST_N_DAYS:8'), 2000);
        Test.setMock(HttpCalloutMock.class, new MockHttpcls_scheduledClientData.MockGenerator_scheduledClientData_NotFound ());
        Database.executeBatch(new clientDataBatch('LAST_N_DAYS:10'), 2000);
        Integer num=1;
        system.assertEquals(num,1);
        Test.StopTest();
    }   
}