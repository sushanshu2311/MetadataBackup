/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : To get the internal users data
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2023-01-18          Hema
****************************************************************************************************/
@isTest public with sharing class NavatarSendEmailCtrlTest {
    @isTest public static void getSearchTest(){
        List<NavatarSendEmailCtrl.UserWrapper> emlWrapperList = new List<NavatarSendEmailCtrl.UserWrapper>();
        Profile prof = [Select Id from profile where Name='System Administrator'];
        User newUser = new User();
        newUser.FirstName = 'Test';
        newUser.LastName = 'User';
        newUser.Email = 'newUser@test.com';
        newUser.IsActive = True;
        newUser.profileId = prof.Id;
        newUser.username = 'newUser18@test.com';
        newUser.EmailEncodingKey = 'ISO-8859-1'; 
        newUser.Alias = 'Navtest';  
        newUser.TimeZoneSidKey = 'America/Los_Angeles';  
        newUser.LocaleSidKey = 'en_US'; 
        newUser.LanguageLocaleKey = 'en_US'; 
        
        Insert newUser;
        
        emlWrapperList = NavatarSendEmailCtrl.getUsersData();
        System.assert(emlWrapperList.size()>0);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = newUser.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        emlWrapperList =NavatarSendEmailCtrl.search('Test');
        System.assert(emlWrapperList.size()>0);
        
        List<String> toAddressList = new List<String>{'test123@gmail.com'};
        List<String> ccAddressList = new List<String>{'test123@gmail.com'};
        List<String> bccAddressList = new List<String>{'test123@gmail.com'};
            
        NavatarSendEmailCtrl.EmailWrapper emailWrapperRec = new NavatarSendEmailCtrl.EmailWrapper();
         emailWrapperRec.toAddress = toAddressList;
         emailWrapperRec.ccAddress = ccAddressList;
         emailWrapperRec.bccAddress = bccAddressList;
         emailWrapperRec.subject  ='Test Email Subject';
         emailWrapperRec.body = 'Test Email body';
        
          
         NavatarSendEmailCtrl.sendEmailController(JSON.serialize(emailWrapperRec));
        
    } 
}