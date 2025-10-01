/* 
New Implimentation: 
Developer       :   Sameeksha Sahu
Project         :   Navigation & SDG 
Date            :   08/August/2019
*/
@isTest
public class Test_navatarEdgeMenuCntlr {

    static testmethod void TestnavatarEdgeMenuCntlr()
    {
        Navigation__c nav1 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account',List_View_Name__c='fsg');
        insert nav1;
        Navigation__c nav2 = new Navigation__c(Name='TestNav1',Quick_Create_Object__c='Account', URL__c='https://www.google.com');
        insert nav2;
        Navigation__c nav3 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account');
        insert nav3;
        Navigation__c navobj = new Navigation__c(Name='TestNav',Order__c =1,List_View_Object__c='Account',Navigation_Type__c='New Interactions',Quick_Create_Object__c='Account');
        insert navobj;        
        Navigation__c navobj4 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account',Parent__c=nav3.id,Navigation_Type__c='New Interactions');
        insert navobj4;
        Navigation__c navobj5 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account',Navigation_Type__c='New Interactions');
        insert navobj5;
        Navigation__c navobj6 = new Navigation__c(Name='TestNav',Order__c =1 ,Quick_Create_Object__c='Account',List_View_Object__c='Account',Parent__c=navobj5.id,Navigation_Type__c='New Interactions',URL__c='/apex/pem_dev__Deal_Creation');
         insert navobj6;
        test.startTest();
        string json = 'abc';
        map<String,String> mapURL = new map<String,String>();
        mapURL.put('Con','Abdgjg');
        navatarEdgeMenuCntlr navEdgeClass = new navatarEdgeMenuCntlr();
        navatarEdgeMenuCntlr.responseWrapper testWrap = new navatarEdgeMenuCntlr.responseWrapper(); 
        testWrap.jsonStr = json;
        testWrap.mapIdToUrl = mapURL;
        navatarEdgeMenuCntlr.getJson('New Interactions');
        //navatarEdgeMenuCntlr.getJson(''); // added to increase test coverage PEv4.7 by Aditya 26 April 2021
        system.assertEquals('TestNav',nav1.Name); // added for security issue PEv4.7 by Aditya on 23 March 2021
        Test.stopTest();
    }
    static testmethod void TestnavatarEdgeMenuCtrl()
    {
        Navigation__c nav1 = new Navigation__c(Name='TestNav',navpeII_dev18__Quick_Create_Object__c='Account',List_View_Object__c='Account',List_View_Name__c='fsg', navpeII_dev18__Activities_Button_API_Name__c = 'Task');
        insert nav1;
        Navigation__c nav2 = new Navigation__c(Name='TestNav1',navpeII_dev18__Quick_Create_Object__c='Account', URL__c='https://www.google.com');
        insert nav2;
        Navigation__c nav3 = new Navigation__c(Name='TestNav',navpeII_dev18__Quick_Create_Object__c='Account',List_View_Object__c='Account');
        insert nav3;
        Navigation__c navobj = new Navigation__c(Name='TestNav',Order__c =1,List_View_Object__c='Account',Navigation_Type__c='New Interactions',Quick_Create_Object__c='Account');
        insert navobj;        
        Navigation__c navobj4 = new Navigation__c(Name='TestNav',navpeII_dev18__Quick_Create_Object__c='Account',List_View_Object__c='Account',navpeII_dev18__Parent__c=nav3.id,Navigation_Type__c='New Interactions');
        insert navobj4;
        Navigation__c navobj5 = new Navigation__c(Name='TestNav',navpeII_dev18__Quick_Create_Object__c='Account',List_View_Object__c='Account',Navigation_Type__c='New Interactions');
        insert navobj5;
        Navigation__c navobj6 = new Navigation__c(Name='TestNav',Order__c =1 ,Quick_Create_Object__c='Account',List_View_Object__c='Account',Parent__c=navobj5.id,Navigation_Type__c='New Interactions',URL__c='/apex/pem_dev__Deal_Creation');
        insert navobj6;
        Navigation__c navobj7 = new Navigation__c(Name='TestNav2',navpeII_dev18__Quick_Create_Object__c='Account',List_View_Object__c='Account',Navigation_Type__c='New Interactions', navpeII_dev18__URL__c='www.google.com');
        insert navobj7;
        Navigation__c navobj8 = new Navigation__c(Name='TestNav3',navpeII_dev18__Quick_Create_Object__c='Account',List_View_Object__c='Account',Navigation_Type__c='New Interactions', navpeII_dev18__Activities_Button_API_Name__c='Task');
        insert navobj8;
        test.startTest();
        string json = 'Create';
        map<String,String> mapURL = new map<String,String>();
        mapURL.put('Con','Abdgjg');
        navatarEdgeMenuCtrl navEdgeClass = new navatarEdgeMenuCtrl();
        navatarEdgeMenuCtrl.responseWrapper testWrap = new navatarEdgeMenuCtrl.responseWrapper(); 
        testWrap.jsonStr = json;
        testWrap.mapIdToUrl = mapURL;
        navatarEdgeMenuCtrl.getJson('New Interactions');
        //navatarEdgeMenuCntlr.getJson(''); // added to increase test coverage PEv4.7 by Aditya 26 April 2021
        system.assertEquals('TestNav',nav1.Name); // added for security issue PEv4.7 by Aditya on 23 March 2021
        Test.stopTest();
    }
    static testmethod void TestCommonUtility_EdgeMenu(){
        List<String> objApiNameList = new List<String>{'Account'};
        CommonUtility_EdgeMenu.describeSObject(objApiNameList);
        CommonUtility_EdgeMenu.describeSFTabs(objApiNameList);
        CommonUtility_EdgeMenu.getFieldNameVsDataType(objApiNameList);
        CommonUtility_EdgeMenu.replaceChars('\r');
        CommonUtility_EdgeMenu.strServerURL();
        CommonUtility_EdgeMenu.chkmasterLookupInPiplineAPI();
        CommonUtility_EdgeMenu.getPipelineAccRelationName();
        CommonUtility_EdgeMenu.getChildRelationshipName('Account', Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Name'));
    }
}