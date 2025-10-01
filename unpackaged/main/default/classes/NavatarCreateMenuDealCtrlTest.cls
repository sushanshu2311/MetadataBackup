/****************************************************************************************************
** Module Name : Acuity 2.0 - Quick Deal Creation
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-25       Virendra Kumar
****************************************************************************************************/
@isTest
public class NavatarCreateMenuDealCtrlTest{

    // Create test data
    @TestSetup
    Public Static Void createTestData() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        Account acc = New Account();
        acc.Name = 'Test';
        Insert acc;
        
        Contact contact = New Contact();
        contact.LastName = 'Test';
        contact.AccountId = acc.Id;
        Insert contact;
        
        navpeII_dev18__Pipeline__c deal = New navpeII_dev18__Pipeline__c();
        deal.Name = 'Test';
        deal.navpeII_dev18__Company__c = acc.Id;
        deal.navpeII_dev18__Stage__c = 'Deal Received ';
        Insert deal;
        
        Theme_Relation__c themeRelation = New Theme_Relation__c();
        themeRelation.Account__c = acc.Id;
        themeRelation.Deal__c = deal.Id;
        Insert themeRelation;
        
        Clip_Relation__c clipRelation = New Clip_Relation__c();
        clipRelation.Deal__c = deal.Id;
        clipRelation.Account__c = acc.Id;
        Insert clipRelation; 
        
        User user = New User(); 
        user.firstname = 'ABC'; 
        user.lastName = 'XYZ';
        user.email = 'testing1@abcd.com';
        user.Username = 'testingnav1@abcd.com'; 
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.Alias = 'Test';
        user.LanguageLocaleKey = 'en_US'; 
        user.ProfileId = pf.Id;
        Insert user;
            
        Event event = New Event();
        event.Related_Associations__c = acc.Id;
        event.WhatId = acc.id;
        event.StartDateTime = system.today();
        event.EndDateTime = system.today()+5;
        Insert event;
        
        Task task = New Task();
        task.Related_Associations__c = acc.Id;
        task.Type = 'Other';
        task.Subject = 'Other';
        task.Status = 'In Progress';
        task.Priority = 'Normal';
        task.OwnerId = user.Id;
        Insert task;
    }
    
    /*****************************************************************************************************
	* @Name         :   shouldTestCloneWithConfirmation
	* @Description  :   Method to test cloneChildRecords, getRelatedContacts, getCloneConfirmation, cloneSelectedContacts method
	*****************************************************************************************************/
    public Static TestMethod Void shouldTestCloneWithConfirmation() {
        Test.StartTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        navpeII_dev18__Pipeline__c deal = [SELECT Id FROM navpeII_dev18__Pipeline__c LIMIT 1];
        
        List<Contact> contacts = NavatarCreateMenuDealCtrl.getRelatedContacts(acc.Id);    
        
        NavatarCreateMenuDealCtrl.cloneChildRecords(deal.Id, acc.Id, true, true); 

        string cloneId1 = '[{"id":"';
        string cloneId2 = '","role":"Vice President"}]';
        string cloneIds = cloneId1 + contact.Id + cloneId2;
        
        NavatarCreateMenuDealCtrl.cloneSelectedContacts(deal.Id, cloneIds);
        
        NavatarCreateMenuDealCtrl.getCloneConfirmation(acc.Id);
        
        Test.stopTest();
        
        System.assert(contacts.size() > 0);

    }    
    
}