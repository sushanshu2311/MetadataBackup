@isTest(seeAlldata = true)
Public class PostInstallSchedulerClassTest
{
    @isTest static void PostInstallSchedulerClass_method1()
    {
        Test.startTest();
        Savepoint sp = Database.setSavepoint();
        PostInstallSchedulerClass pic = new PostInstallSchedulerClass();
        Test.testInstall(pic, null);
        Integer num=1;
        system.assertEquals(num,1);
        Database.RollBack(sp);
        Test.StopTest();
    }
}