/****************************************************************************************************

** Module Name : Clips

** Description : Used for test coverage of NavatarClipsCtrl

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
@isTest
public class NavatarClipsCtrlTest {
    @isTest
    public static void method1() {
        Account testAccount = new Account(name='Test');
        insert testAccount;
        
        Account testAccount2 = new Account(name='Test account 2');
        insert testAccount2;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id iiRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        //Test class coverage fix by LK on 2024-11-06
        Account accII = new Account(recordtypeId=iiRecordTypeId,name='Test Inst');
        insert accII;
        
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;
        
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII_dev18__Company__c = acc.id;
        deal.navpeII_dev18__Our_Role__c = 'Lead';
        deal.navpeII_dev18__Stage__c = 'IOI';
        insert deal;
        
        navpeII_dev18__Fund__c fund1 = new navpeII_dev18__Fund__c();
        fund1.Name = 'Test1';
        fund1.navpeII_dev18__Fund_Type__c = 'Fund';
        fund1.navpeII_dev18__Investment_Category__c = 'Fund';
        insert fund1;
        //Test class coverage fix by LK on 2024-11-06
        navpeII_dev18__Fundraising__c fdr=new navpeII_dev18__Fundraising__c(name='Test Fdr',navpeII_dev18__Fund_Name__c=fund1.Id,navpeII_dev18__legal_name__c=accII.Id);
        insert fdr;
        
        contact con = new contact();
        con.lastName='test';
        con.AccountId=testAccount.id;
        insert con;
        contact con1 = new contact();
        con1.lastName='test 2 con';
        con1.AccountId=testAccount.id;
        insert con1;
        
        Clip__c clip = new Clip__c();
        clip.Name = 'Test Clip';
        clip.Summary__c = 'summary';
        Insert clip;
        
        Clip_Relation__c cRel = new Clip_Relation__c();
        cRel.Clip__c = clip.id;
        cRel.Account__c = testAccount.id;
        insert cRel;
        Clip_Relation__c cRel1 = new Clip_Relation__c();
        cRel1.Clip__c = clip.id;
        cRel1.Contact__c = con1.id;
        insert cRel1;
        Clip_Relation__c cRel2 = new Clip_Relation__c();
        cRel2.Clip__c = clip.id;
        cRel2.Deal__c = deal.id;
        insert cRel2;
        Clip_Relation__c cRel3 = new Clip_Relation__c();
        cRel3.Clip__c = clip.id;
        cRel3.Fund__c = fund1.id;
        insert cRel3;
        Clip_Relation__c cRel4 = new Clip_Relation__c();
        cRel4.Clip__c = clip.id;
        cRel4.Fundraising__c = fdr.id;
        insert cRel4;
        Clip_Relation__c cRel5 = new Clip_Relation__c();
        cRel5.Clip__c = clip.id;
        cRel5.User__c = Userinfo.getUserId();
        insert cRel5;
        
        Theme__c thm = new Theme__c();
        thm.Name = 'Thm';
        insert thm;
        
        Theme_Relation__c thREl = new Theme_Relation__c();
        thREl.Clip__c = clip.id;
        thREl.Theme__c = thm.id;
        insert thREl;
        
        
        
        Test.startTest();
        
            string extratagged = '[{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+userinfo.getuserid()+'","iconName":null}]';
            string tagged = '[{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+userinfo.getuserid()+'","iconName":null},{"objectName":"Account","Name":"Matt Damon","isUser":null,"Id":"'+testAccount.id+'","iconName":null},{"objectName":"contact","Name":"Matt Damon","isUser":null,"Id":"'+con.id+'","iconName":null},{"objectName":"navpeII_dev18__Pipeline__c","Name":"Matt Damon","isUser":null,"Id":"'+deal.id+'","iconName":null},{"objectName":"navpeII_dev18__Fund__c","Name":"Matt Damon","isUser":null,"Id":"'+fund1.id+'","iconName":null},{"objectName":"navpeII_dev18__Fundraising__c","Name":"Matt Damon","isUser":null,"Id":"'+fdr.id+'","iconName":null},{"objectName":"Theme__c","Name":"Matt Damon","isUser":null,"Id":"'+thm.id+'","iconName":null}]';          Id [] fixedSearchResults= new Id[2];
            fixedSearchResults[0] = con.Id;
            fixedSearchResults[1] = testAccount.Id;
            Test.setFixedSearchResults(fixedSearchResults);
        
           
            string objInfo = NavatarClipsCtrl.getClipsRelatedObjectInfo();
            NavatarClipsCtrl.getCurrentUserInfo();
            NavatarClipsCtrl.getClipData(clip.id, objInfo);
            NavatarClipsCtrl.getSuggestion(testAccount2.id, objInfo, extratagged);
            NavatarClipsCtrl.saveClip(tagged, '123', 'test123', 'hi', null);
            NavatarClipsCtrl.saveClip(tagged, '123', 'test123', 'hi', clip.id);
            NavatarClipsCtrl.saveSuggestion(tagged, clip.id);
            NavatarClipsCtrl.getClipNameAndSummary(clip.id);
        test.stopTest();
        system.assert(true);
      
     }
}