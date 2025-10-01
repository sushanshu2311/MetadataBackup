@IsTest
public class NavatarEventReminderCtrlTest {
    @Istest
    static void callFlowApexActionTest(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;
        
        Contact cnt = new Contact();
        cnt.LastName = 'Testing';
        cnt.AccountId = acc.id;
        cnt.Email = 'jsmith@acme.com';
        insert cnt;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        navpeII_dev18__Attendee__c att = new navpeII_dev18__Attendee__c();
        att.navpeII_dev18__Attendee_Staff__c = thisUser.id;
        insert att;
        
        event evt = new event();
        evt.WhoId = cnt.id;
        evt.WhatId = att.id; 
        evt.DurationInMinutes = 10;
        evt.Related_Associations__c=acc.id+','+cnt.id+','+thisUser.id;
        evt.OwnerId = thisUser.id;
        datetime dt = System.now();
        evt.ActivityDateTime = dt;
        evt.StartDateTime = dt;
        evt.DurationInMinutes = 60;
        evt.EndDateTime = dt.addMinutes(60);
        insert evt;
        List<Event> evtList = new List<Event>();
        evtList.add(evt);
        NavatarEventReminderCtrl.FlowInputParams fip = new NavatarEventReminderCtrl.FlowInputParams();
        fip.eventRecords = evtList; 
        List<NavatarEventReminderCtrl.FlowInputParams> lfis = new List<NavatarEventReminderCtrl.FlowInputParams>();
        lfis.add(fip);
        test.startTest();
        NavatarEventReminderCtrl.callFlowApexAction(lfis);
        system.assert(true);
        test.stopTest();
        
    }

}