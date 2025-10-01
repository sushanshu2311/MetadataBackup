/****************************************************************************************************
** Module Name : Acuity 2.0 - Activity Trigger Test Class
** Description : Test Class for DealTriggerHandler, DealTrigger
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-22          Anmol
** 2.0        2023-02-09          Pavani
****************************************************************************************************/
@isTest
public class NavatarDealTriggerHandlerTest{
    
    @TestSetup
    static void makeData(){
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Test Auto Created Deal $$$$$$$';
        deal.navpeII_dev18__Stage__c = 'Deal Received';
        insert deal;    
        
        navpeII_dev18__Pipeline__History  dealHis = new navpeII_dev18__Pipeline__History();
        dealHis.ParentId = deal.id;
        dealHis.Field = 'navpeII_dev18__Stage__c';
        insert dealHis;
        
    }
    @isTest
    private static void testOnAfterInsrtDeal(){

        User u = [Select Id from User where Profile.Name ='PE Standard User' and
                         IsActive=TRUE Limit 1];
        navpeII_dev18__Navatar_Setup__c navatarSetting = new navpeII_dev18__Navatar_Setup__c();
        navatarSetting.NN_Action__c = true;
        navatarSetting.NN_Information__c= true;
        navatarSetting.navpeII_dev18__Admin_Setting__c = true;
        insert navatarSetting;
        
        navpeII_dev18__Pipeline__History deallHistory =[SELECT Id FROM navpeII_dev18__Pipeline__History LIMIT 1];
		navpeII_dev18__Pipeline__c deal=[Select Id, navpeII_dev18__Stage__c from navpeII_dev18__Pipeline__c where name='Test Auto Created Deal $$$$$$$' limit 1];
        Account acc= [Select Id ,Name,isAutoCreated__c from Account where Name ='Test Auto Created Deal $$$$$$$' limit 1 ];
                
        Test.startTest();
        deal.navpeII_dev18__Stage__c = 'NDA Signed';
        update deal;
       	Test.stopTest();
		System.assertEquals(NavatarConstants.ACCOUNT_INFO,[Select Type__c from Navatar_Notification__c].Type__c, 'Account info created');
        
    }
    @isTest
    public static void testBulkDealCompanyCreation(){
        List<navpeII_dev18__Pipeline__c> bulkDeals=new List<navpeII_dev18__Pipeline__c>();
        for(Integer i=0;i<100;i++){
            navpeII_dev18__Pipeline__c pipe=new navpeII_dev18__Pipeline__c(name='Test Acuity Deal4Company '+i);
            bulkDeals.add(pipe);
        }
        if(bulkDeals.size()>0){
            insert bulkDeals;
        }
        navpeII_dev18__Pipeline__c pipe=new navpeII_dev18__Pipeline__c(name='Test Acuity Deal4Company 1');
        insert pipe;
        //System.assertEquals('Test Acuity Deal4Company 1', [Select Id, Name from navpeII_dev18__Pipeline__c order by createdDate DESC limit 1].Name, 'Latest Pipeline was not inserted!!');
    }
    @isTest
    public static void testBulkDealThemeCreation(){
        Account acc =new Account(name='Test Acuity Acc');
        insert acc;
        List<navpeII_dev18__Pipeline__c> bulkDeals=new List<navpeII_dev18__Pipeline__c>();
        for(Integer i=0;i<100;i++){
            navpeII_dev18__Pipeline__c pipe=new navpeII_dev18__Pipeline__c(name='Test Acuity Deal4Company '+i,navpeII_dev18__Company__c=acc.Id);
            bulkDeals.add(pipe);
        }
        if(bulkDeals.size()>0){
            insert bulkDeals;
        }
        Theme__c t=new Theme__c();
        insert t;
        Theme_Relation__c tr=new Theme_Relation__c(Theme__c=t.Id,Account__c=acc.Id);
        insert tr;
        navpeII_dev18__Pipeline__c pipe=new navpeII_dev18__Pipeline__c(name='Test Acuity Deal4Company 1',navpeII_dev18__Company__c=acc.Id);
        insert pipe;
        Theme_Relation__c tr2=new Theme_Relation__c(Theme__c=t.Id,Deal__c=pipe.Id);
        insert tr2;
        navpeII_dev18__Pipeline__c pipe2=new navpeII_dev18__Pipeline__c(name='Test Acuity Deal4Company 2',navpeII_dev18__Company__c=acc.Id);
        insert pipe2;
        //System.assertEquals('Test Acuity Deal4Company 1', [Select Id, Name from navpeII_dev18__Pipeline__c order by createdDate DESC limit 1].Name, 'Latest Pipeline was not inserted!!');

    }
}