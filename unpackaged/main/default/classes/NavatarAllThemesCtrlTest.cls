/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle All Themes Page &  Add to Theme button logic
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2023-01-14          Hema
****************************************************************************************************/
@isTest public with sharing class NavatarAllThemesCtrlTest {
    @testsetup public static void themeTestData(){
        navpeII_dev18__Theme__c themeRec = new navpeII_dev18__Theme__c();
        themeRec.Name = 'New Theme Test Record';
        themeRec.navpeII_dev18__Description__c  = 'New Theme Description';
        Insert themeRec;
        
        navpeII_dev18__Theme__c existingthemeRec = new navpeII_dev18__Theme__c();
        existingthemeRec.Name = 'New Theme Record 2';
        existingthemeRec.navpeII_dev18__Description__c  = 'New Theme Description 2';
        Insert existingthemeRec;
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Navatar';
        con.Email = 'test.navatar123@sumologics-ng.com';
        con.AccountId = acc.Id;
        insert con;
        
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII_dev18__Company__c = acc.id;
        deal.navpeII_dev18__Our_Role__c = 'Lead';
        deal.navpeII_dev18__Stage__c = 'IOI';
        insert deal;
        
        navpeII_dev18__Fund__c fund1 = new navpeII_dev18__Fund__c();
        fund1.Name = 'Test';
        fund1.navpeII_dev18__Fund_Type__c = 'Fund';
        fund1.navpeII_dev18__Investment_Category__c = 'Fund';
        insert fund1;
        
        navpeII_dev18__Theme_Relation__c themeRel = new navpeII_dev18__Theme_Relation__c();
        themeRel.navpeII_dev18__Theme__c = existingthemeRec.Id;
        themeRel.navpeII_dev18__Other_Theme__c = themeRec.Id;
        Insert themeRel;
        
        navpeII_dev18__Theme_Relation__c themeRel1 = new navpeII_dev18__Theme_Relation__c();
        themeRel1.navpeII_dev18__Theme__c = themeRec.Id;
        themeRel1.navpeII_dev18__Other_Theme__c = existingthemeRec.Id;
        Insert themeRel1;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        navpeII_dev18__Theme_Team__c themeTeam = new navpeII_dev18__Theme_Team__c();
        themeTeam.navpeII_dev18__Member__c = thisUser.Id;
        themeTeam.navpeII_dev18__Theme__c = themeRec.Id;
        Insert themeTeam;
        
        navpeII_dev18__Theme_Team__c themeTeam2 = new navpeII_dev18__Theme_Team__c();
        themeTeam2.navpeII_dev18__Member__c = thisUser.Id;
        themeTeam2.navpeII_dev18__Theme__c = existingthemeRec.Id;
        Insert themeTeam2;
        
        navpeII_dev18__Clip__c clipRec = new navpeII_dev18__Clip__c();
        clipRec.Name = 'Test Clip';
        Insert clipRec;
        
        Task taskRec = new Task();
        taskRec.navpeII_dev18__Related_Associations__c = String.valueOf(existingthemeRec.Id);
        Insert taskRec;
        
        Event eveRec = new Event();
        eveRec.Subject = 'Call';
        eveRec.DurationInMinutes = 1;
        eveRec.ActivityDateTime = System.now();
        eveRec.navpeII_dev18__Related_Associations__c = String.valueOf(existingthemeRec.Id);
        Insert eveRec;
    }
    
    @isTest public static void getAllThemesTest(){
        Test.startTest();
        navpeII_dev18__Theme__c themeRec = [Select Id,Name from navpeII_dev18__Theme__c Where Name ='New Theme Record 2'];
        String existingThemeId= themeRec.Id;
        navpeII_dev18__Theme__c themeNewRec = [Select Id,Name from navpeII_dev18__Theme__c Where Name ='New Theme Test Record'];
        String newThemeId= themeNewRec.Id;
        NavatarAllThemesCtrl.saveThemeRecord(existingThemeId , newThemeId ,'','',false,true );
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = themeRec.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        NavatarAllThemesCtrl.getSearchedThemes('Test');
        
        Id [] fixedSearchResults1= new Id[1];
        fixedSearchResults1[0] = themeRec.Id;
        Test.setFixedSearchResults(fixedSearchResults1);
        NavatarAllThemesCtrl.getSearchedThemes('New');
        
        navpeII_dev18__Pipeline__c dealRec = [Select Id,Name from navpeII_dev18__Pipeline__c Where Name ='Testing'];
        List<String> relatedObjList = new List<String>();
        relatedObjList.add('Account');
        Boolean isDealInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, dealRec.Id, 'navpeII_dev18__Pipeline__c',relatedObjList);
        system.assert(isDealInserted);
        
        Contact conRec = [Select Id,Name from Contact Where LastName ='Test Navatar'];  
        Boolean isConInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, conRec.Id, 'Contact',relatedObjList);
        system.assert(isConInserted);
        
        navpeII_dev18__Fund__c fundRec = [Select Id,Name from navpeII_dev18__Fund__c Where Name ='Test'];
        List<String> relatedObjListfdr = new List<String>();
        relatedObjListfdr.add('navpeII_dev18__Fundraising__c');
        relatedObjListfdr.add('navpeII_dev18__Theme__c');
        relatedObjListfdr.add('navpeII_dev18__Clip__c');
        relatedObjListfdr.add('Activities');
        //Test class coverage fix by LK on 2024-11-06
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Id RecordTypeIdFirm2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Portfolio Company').getRecordTypeId();
        Account acc2 = new Account(name='test',RecordTypeId = RecordTypeIdFirm2);
        insert acc2;
        
        navpeII_dev18__Fundraising__c fundraisingRecord = new navpeII_dev18__Fundraising__c(Name = 'testFundraising', navpeII_dev18__Fund_Name__c = fundRec.Id, navpeII_dev18__Legal_Name__c = acc1.Id, navpeII_dev18__Portfolio_Company__c = acc2.Id);
        insert fundraisingRecord;
        
        Event eveRec = new Event();
        eveRec.Subject = 'Call';
        eveRec.DurationInMinutes = 1;
        eveRec.ActivityDateTime = System.now();
        eveRec.navpeII_dev18__Related_Associations__c = String.valueOf(newThemeId)+','+String.valueOf(fundraisingRecord.Id);
        Insert eveRec;
        
        Boolean isFundInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, fundRec.Id, 'navpeII_dev18__Fund__c',relatedObjListfdr);
        //
        //Boolean isFundInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, fundRec.Id, 'navpeII_dev18__Fund__c',Null);
        //system.assert(isFundInserted);
        
        Account accRec = [Select Id,Name from Account Where Name ='Test' limit 1];
        List<String> relatedObjListAcc = new List<String>();
        relatedObjListAcc.add('Contact');
        
        Boolean isAccInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, accRec.Id, 'Account',relatedObjListAcc);
        system.assert(isAccInserted);
        
        navpeII_dev18__Clip__c clipRec = [Select Id,Name from navpeII_dev18__Clip__c Where Name ='Test Clip'];
        //Boolean isClipInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, clipRec.Id, 'navpeII_dev18__Clip__c',relatedObjList);
        //system.assert(isClipInserted); 
        
        navpeII_dev18__Theme__c newThemeRec = new navpeII_dev18__Theme__c();
        newThemeRec.Name = 'New Theme Rec';
        newThemeRec.navpeII_dev18__Description__c = 'New Theme Desc';
        Insert newThemeRec;  
        relatedObjList.add('navpeII_dev18__Fundraising__c');
        relatedObjList.add('navpeII_dev18__Theme__c');
        relatedObjList.add('navpeII_dev18__Clip__c');
        relatedObjList.add('Activities');
        
        Boolean isThemeInserted = NavatarAllThemesCtrl.addToTheme(newThemeId, newThemeRec.Id, 'navpeII_dev18__Theme__c',relatedObjList);
       // system.assert(isThemeInserted); 
        
        NavatarAllThemesCtrl.getThemeFields();
        NavatarAllThemesCtrl.getRelatedObjectRecords(accRec.Id);
        NavatarAllThemesCtrl.getRelatedObjectRecords(newThemeRec.Id);
        NavatarAllThemesCtrl.getRelatedObjectRecords(fundRec.Id);
        
        NavatarAllThemesCtrl.getRelatedObjectRecords(dealRec.Id);
        NavatarAllThemesCtrl.getRelatedObjectRecords(conRec.Id);
        
        Test.stopTest();
        
        
        
        String themeName = NavatarAllThemesCtrl.getThemeName(existingThemeId);
        system.assert(themeName!='');
    }    
    
}