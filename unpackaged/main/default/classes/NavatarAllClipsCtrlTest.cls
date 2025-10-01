/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle All Clips Page 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2023-01-14          Hema
****************************************************************************************************/
@isTest public with sharing class NavatarAllClipsCtrlTest {
    @testsetup public static void themeTestData(){
        List<navpeII_dev18__Clip_Relation__c> clipRelList = new  List<navpeII_dev18__Clip_Relation__c>();
        navpeII_dev18__Clip__c clipRec = new navpeII_dev18__Clip__c();
        clipRec.Name = 'New Clip Test Record';
        clipRec.navpeII_dev18__Summary__c  = 'New Clip Description';
        clipRec.navpeII_dev18__Notes__c  = 'New Clip Notes';
        Insert clipRec;
        
        navpeII_dev18__Clip__c clipRec2 = new navpeII_dev18__Clip__c();
        clipRec2.Name = 'New Clip Test Record 2';
        clipRec2.navpeII_dev18__Summary__c  = 'New Clip Description 2';
        clipRec2.navpeII_dev18__Notes__c  = 'New Clip Notes 2';
        Insert clipRec2;
        
        navpeII_dev18__Theme__c themeRec = new navpeII_dev18__Theme__c();
        themeRec.Name = 'New Theme Record 2';
        themeRec.navpeII_dev18__Description__c  = 'New Theme Description 2';
        Insert themeRec;
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Test';
        //Test class coverage fix by LK on 2024-11-06
        acc1.RecordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        insert acc1;
        
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
        
        navpeII_dev18__Fundraising__c fundRec = new navpeII_dev18__Fundraising__c();
        fundRec.Name ='Test Fundraising';
        fundRec.navpeII_dev18__Legal_Name__c = acc1.id;
        fundRec.navpeII_dev18__Fund_Name__c = fund1.Id;
        Insert fundRec;
            
        navpeII_dev18__Theme_Relation__c themeRel1 = new navpeII_dev18__Theme_Relation__c();
        themeRel1.navpeII_dev18__Theme__c = themeRec.Id;
        themeRel1.navpeII_dev18__clip__c= clipRec.Id;
        Insert themeRel1;
        
        navpeII_dev18__Clip_Relation__c clipRel1 = new navpeII_dev18__Clip_Relation__c();
        clipRel1.navpeII_dev18__Fund__c = fund1.Id;
        clipRel1.navpeII_dev18__clip__c= clipRec.Id;
         clipRelList.add(clipRel1);
        
        navpeII_dev18__Clip_Relation__c clipRel2 = new navpeII_dev18__Clip_Relation__c();
        clipRel2.navpeII_dev18__Account__c = acc.Id;
        clipRel2.navpeII_dev18__clip__c= clipRec2.Id;
         clipRelList.add(clipRel2);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        navpeII_dev18__Clip_Relation__c clipRel3 = new navpeII_dev18__Clip_Relation__c();
        clipRel3.navpeII_dev18__User__c = thisUser.Id;
        clipRel3.navpeII_dev18__clip__c= clipRec2.Id;
         clipRelList.add(clipRel3);
       
        navpeII_dev18__Clip_Relation__c clipRel4 = new navpeII_dev18__Clip_Relation__c();
        clipRel4.navpeII_dev18__contact__c = con.Id;
        clipRel4.navpeII_dev18__clip__c= clipRec2.Id;
         clipRelList.add(clipRel4);
        
        navpeII_dev18__Clip_Relation__c clipRel5 = new navpeII_dev18__Clip_Relation__c();
        clipRel5.navpeII_dev18__Deal__c = deal.Id;
        clipRel5.navpeII_dev18__clip__c= clipRec.Id;
         clipRelList.add(clipRel5);
        
        navpeII_dev18__Clip_Relation__c clipRel6 = new navpeII_dev18__Clip_Relation__c();
        clipRel6.navpeII_dev18__Deal__c = deal.Id;
        clipRel6.navpeII_dev18__clip__c= clipRec.Id;
         clipRelList.add(clipRel6);
        
         navpeII_dev18__Clip_Relation__c clipRel7 = new navpeII_dev18__Clip_Relation__c();
        clipRel7.navpeII_dev18__Fundraising__c = fundRec.Id;
        clipRel7.navpeII_dev18__clip__c= clipRec.Id;
         clipRelList.add(clipRel7);
        
        Insert clipRelList;
    }
    
    @isTest public static void getAllClipsTest(){
        
        navpeII_dev18__Clip__c clipRec = [Select Id,Name from navpeII_dev18__Clip__c Where Name ='New Clip Test Record 2'];
        String clipId = clipRec.Id;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = clipRec.Id;
        Test.setFixedSearchResults(fixedSearchResults);
       List<NavatarAllClipsCtrl.AllClipsPageWrapper> wrapperList=  NavatarAllClipsCtrl.getSearchedThemes('Test');
        System.assert(wrapperList.size()>0); 
        
        List<String> clipsIdList = new  List<String>{clipId}; 
        ApexPages.currentPage().getParameters().put('id',clipId);
        ApexPages.StandardController sc = new ApexPages.StandardController(clipRec);
		NavatarClipsPDFCtrl  obj = new NavatarClipsPDFCtrl();
    }    
}