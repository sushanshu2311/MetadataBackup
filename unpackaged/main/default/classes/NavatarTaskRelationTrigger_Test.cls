/****************************************************************************************************
** Module Name : Acuity 2.0 - Activity Trigger
** Description :
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2023-05-30          Lakshya        Test class to cover the NavatarTaskRelationTrigger trigger
****************************************************************************************************/
@isTest
public class NavatarTaskRelationTrigger_Test {
    @isTest static void testCreate() {
        Test.enableChangeDataCapture();
        Account acc = new Account(Name = 'Dummy Account ' + System.now());
        insert acc;
        Contact con = new Contact(LastName = 'Last Name ' + System.now(), AccountId = acc.Id);
        insert con;
        insert new Task(ActivityDate=System.today(), WhoId = con.Id);
        Test.getEventBus().deliver();
        Task[] taskList = [SELECT Id,Subject FROM Task];
        System.assertEquals(1, taskList.size(), 'The change event trigger did not create the expected task.');
    }
}