/*********************************************************************************
** @Module Name : Acuty 2.0
** @Description : Test class for NavatarThemeTeamCtrl
** @Organization : Navatar Group
** @Revision History:-
** @Version Date(YYYY-MM-DD)          Author                  
** 1.0     2022-12-02             Virendra Kumar
*********************************************************************************/
@isTest(seeAllData=false)
public class NavatarThemeTeamCtrlTest {
    
    //Create Test Data
    @TestSetup
    public static void createTestData(){   
        
        navpeII_dev18__Theme__c theme = new navpeII_dev18__Theme__c();
        theme.Name = 'Test';
        theme.navpeII_dev18__Description__c = 'Test for Method';
        insert theme;
        
        navpeII_dev18__Theme_Team__c themeteam =  new navpeII_dev18__Theme_Team__c(); 
        themeTeam.navpeII_dev18__Theme__c = theme.Id;
        themeTeam.navpeII_dev18__Role__c = 'Advisor';
        themeTeam.navpeII_dev18__Member__c = Userinfo.getUserId();
        insert themeTeam;  
    }
    
    /*****************************************************************************************************
    * @Name         :   themeTeamTestMethod
    * @Description  :   Method to test deleteSelectedThemeTeam, processConInfo, getThemeTeams method
    *****************************************************************************************************/
    public static TestMethod void themeTeamTestMethod(){
        Test.startTest();
        
        navpeII_dev18__Theme__c themeRelation = [Select Id From navpeII_dev18__Theme__c Limit 1];
        List<Id> selectedTeamIds = new List<Id>();  
        selectedTeamIds.add(themeRelation.Id);
        
        navpeII_dev18__Theme_Team__c themeTeam = [Select Id, navpeII_dev18__Role__c,navpeII_dev18__Member__c, navpeII_dev18__Theme__r.Name, navpeII_dev18__Theme__r.navpeII_dev18__Description__c  From navpeII_dev18__Theme_Team__c Limit 1];
        
        Map<String , navpeII_dev18__Theme_Team__c> themeTeamMap = new Map<String , navpeII_dev18__Theme_Team__c>();
        themeTeamMap.put(themeTeam.Id, themeTeam);
        
        Acuity_Setting__mdt MetaAcuity = new Acuity_Setting__mdt();
        MetaAcuity.DeveloperName = 'Acuity_ThemeTeam_Field1';
        MetaAcuity.Value__c = 'navpeII_dev18__User__r.Name';        
        
        Acuity_Setting__mdt MetaAcuity1 = new Acuity_Setting__mdt();
        MetaAcuity1.DeveloperName = 'Acuity_ThemeTeam_Field2';
        MetaAcuity1.Value__c = 'navpeII_dev18__User__r.Title';
        
        Acuity_Setting__mdt MetaAcuity2 = new Acuity_Setting__mdt();
        MetaAcuity2.DeveloperName = 'Acuity_ThemeTeam_Field3';
        MetaAcuity2.Value__c = 'navpeII_dev18__Role__c';        
        String objName = 'navpeII_dev18__Theme_Team__c';
        String fieldName = 'navpeII_dev18__Role__c';
        
        NavatarThemeTeamCtrl.ResponseWrapper responseForThemeTeam = NavatarThemeTeamCtrl.getThemeTeams(themeRelation.Id);
        NavatarThemeTeamCtrl.deleteSelectedThemeTeam(selectedTeamIds);
        NavatarThemeTeamCtrl.fetchFieldLabel(objName, fieldName);
        NavatarThemeTeamCtrl.ResponseWrapper responseForData = NavatarThemeTeamCtrl.processConInfo(themeTeamMap , 'Acuity_ThemeTeam_Field1' , 'Acuity_ThemeTeam_Field2' ,'Acuity_ThemeTeam_Field3'); 
        Test.stopTest();        
        System.Assert(responseForThemeTeam != null, 'Theme Team should be there.');
        System.Assert(responseForData != null, 'Theme Team data should be there.');
    }
    
    /*****************************************************************************************************fv
    * @Name         :   shouldTestDataBasedOnMeta
    * @Description  :   Method to test processConInfo method
    *****************************************************************************************************/
    public static TestMethod void shouldTestDataBasedOnMeta(){
        Test.startTest();
        
        navpeII_dev18__Theme_Team__c themeTeam = [Select Id, navpeII_dev18__Role__c,navpeII_dev18__Member__c, navpeII_dev18__Theme__r.Name, navpeII_dev18__Theme__r.navpeII_dev18__Description__c  From navpeII_dev18__Theme_Team__c Limit 1];
        
        Map<String , navpeII_dev18__Theme_Team__c> themeTeamMap = new Map<String , navpeII_dev18__Theme_Team__c>();
        themeTeamMap.put(themeTeam.Id, themeTeam);
        
        Acuity_Setting__mdt MetaAcuity = new Acuity_Setting__mdt();
        MetaAcuity.DeveloperName = 'Acuity_ThemeTeam_Field1';
        MetaAcuity.Value__c = 'navpeII_dev18__User__r.Name';        
        
        Acuity_Setting__mdt MetaAcuity1 = new Acuity_Setting__mdt();
        MetaAcuity1.DeveloperName = 'Acuity_ThemeTeam_Field2';
        MetaAcuity1.Value__c = 'navpeII_dev18__User__r.Title';
        
        Acuity_Setting__mdt MetaAcuity2 = new Acuity_Setting__mdt();
        MetaAcuity2.DeveloperName = 'Acuity_ThemeTeam_Field3';
        MetaAcuity2.Value__c = 'navpeII_dev18__User__r.Email'; 
        
        NavatarThemeTeamCtrl.ResponseWrapper responseForData = NavatarThemeTeamCtrl.processConInfo(themeTeamMap , 'Acuity_ThemeTeam_Field1' , 'Acuity_ThemeTeam_Field2' ,'Acuity_ThemeTeam_Field3'); 
        Test.stopTest();
        System.Assert(responseForData != null, 'Theme Team data should be there.');
    }
    
    /*****************************************************************************************************
    * @Name         :   shouldTestDataBasedOnMeta
    * @Description  :   Method to test processConInfo method
    *****************************************************************************************************/
    public static TestMethod void shouldCheckForDuplicate(){
        navpeII_dev18__Theme__c themeRelation = [Select Id From navpeII_dev18__Theme__c Limit 1];
        
        Test.startTest();
        navpeII_dev18__Theme_Team__c themeteam =  new navpeII_dev18__Theme_Team__c(); 
        themeTeam.navpeII_dev18__Theme__c = themeRelation.Id;
        themeTeam.navpeII_dev18__Role__c = 'Advisor';
        themeTeam.navpeII_dev18__Member__c = Userinfo.getUserId();
        try {
            insert themeTeam; 
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Member already exists with the same role'));
        }        
        Test.stopTest();
    }
    
}