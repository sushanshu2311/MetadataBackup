@isTest
public class TestContactTransferAddOn_ctrl {
	
    public static String namespacePrefix = 'navmnaI__';
    public static String advanceSetting1;
    public static String advanceSetting2;
    public static String advanceSetting3;
    public static string activitySetting1;
    public static string activitySetting2;
    public static string activitySetting3;
    public static String orgMetadataActive;
    public static String fundraisingObject;
    public static String affiliationObjName;
    public static String affiliationAccountLookup; 
    public static String strObjectName = getOrgSpecificObject();
    
    public static String getOrgSpecificObject(){
        String objectName;
        if(Schema.getGlobalDescribe().containsKey(nameSpacePrefix+'Product_Setting__c') == true){
            objectName = nameSpacePrefix+'Product_Setting__c';
            orgMetadataActive = 'Active__c';
            affiliationObjName = nameSpacePrefix+'Affiliations__c';
            affiliationAccountLookup = namespacePrefix+'Account__c';
            advanceSetting1 ='Contact Only';
            advanceSetting2 ='Contact and Account';
            advanceSetting3 = 'Contact, Account and Custom Object';
            activitySetting1 = 'Old Account Only';
            activitySetting2 = 'Old and New Accounts';
            activitySetting3 = 'Do not move Activities';
        }
        else{
            nameSpacePrefix = 'navpeII__';
            orgMetadataActive = 'IsActive__c';
            objectName = nameSpacePrefix+'Navatar_Setup__c'; 
            fundraisingObject = nameSpacePrefix+'Fundraising_Contact__c';
            affiliationObjName = nameSpacePrefix+'Affiliation__c';
            affiliationAccountLookup = 'Institution__c';
            advanceSetting1 ='Contact Only';
            advanceSetting2 ='Contact and Institution';
            advanceSetting3 = 'Contact, Institution and Custom Object';
            activitySetting1 = 'Old Institution Only';
            activitySetting2 = 'Old and New Institutions';
            activitySetting3 = 'Do not move Activities';
        }
        return objectName;
    }
    
    static void createSetupData(String activitySetting, String advanceSetting) {
        Map<String, Schema.SObjectType> scDesc = Schema.getGlobalDescribe();
        Schema.SobjectType oTypeSetup;
        sobject object_instance_Setup;
        if(scDesc.get('navpeII__Navatar_Setup__c') != null){
            oTypeSetup = scDesc.get('navpeII__Navatar_Setup__c');
            object_instance_Setup = oTypeSetup.newSObject();
            object_instance_Setup.put('navpeII__CTS_Activity__c',activitySetting);
            object_instance_Setup.put('navpeII__CTS_Advanced__c',advanceSetting);
            object_instance_Setup.put('navpeII__Admin_Setting__c',true);
        }
        else if(scDesc.get('navmnaI__Product_Setting__c') != null){
            oTypeSetup = scDesc.get('navmnaI__Product_Setting__c');
            object_instance_Setup = oTypeSetup.newSObject();
            object_instance_Setup.put('navmnaI__CTS_Activity__c',activitySetting);
            object_instance_Setup.put('navmnaI__CTS_Advanced__c',advanceSetting);
            object_instance_Setup.put('navmnaI__Admin_Setting__c',true);
        }
        insert object_instance_Setup;
        
    }
    
    static TestMethod void TestMethod1(){
        
        Account acc = new Account(Name = 'Account 1');
        insert acc;
        system.assertEquals('Account 1', acc.Name);
        
        Account acc1 = new Account(Name = 'Account 2');
        insert acc1;
        
        Contact con = new Contact();
        con.FirstName = 'Naruto';
        con.LastName = 'Uzumaki';
        con.Email = 'narutoforhokage@konoha.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Sasuke';
        con1.LastName = 'Uchiha';
        con1.Email = 'uchiha@sharingan.com';
        con1.AccountId = acc.Id;
        insert con1;
                
        createSetupData(activitySetting1,advanceSetting1);
        apexpages.currentpage().getparameters().put('id',con1.id);
        ContactTransferAddOn_ctrl contactTransferObj= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(con1));
        
        contactTransferObj.contactLookup = con1;
        contactTransferObj.contactName = con1.FirstName+' '+con1.LastName;
        contactTransferObj.displayMessage = '';
        contactTransferObj.isContactIdNull = false;
        contactTransferObj.legalIdOld = acc.Id;
        contactTransferObj.legalNameOld = acc.Name;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId;
        contactTransferObj.legalNameNew = contactTransferObj.contactLookup.Name;
        contactTransferObj.isError = false;
        contactTransferObj.errorMessage = '';
        contactTransferObj.isOrgSettingActive = true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;
        contactTransferObj.accAPIName = affiliationAccountLookup;
        contactTransferObj.affiliationObjName = affiliationObjName;
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        
        Task t1 = new task();
        t1.WhoId = con1.Id;
        t1.Subject ='Task sub';
        t1.Status ='Completed';
        t1.Priority = 'Normal';
        t1.WhatId = null;
        insert t1;
        
        Task t2 = new task();
        t2.WhoId = con1.Id;
        t2.Subject ='Task sub 1';
        t2.Status ='Completed';
        t2.Priority = 'Normal';
        t2.WhatId = contactTransferObj.legalIdOld;
        /*if(namespacePrefix == 'navpeII__'){
             t2.put('navpeII__Institution__c',null);
        }
        else{
            t2.put('navmnaI__Account__c',null);
        }*/
        insert t2;
        
        Event e1 = new event();
        e1.WhoId = con1.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.WhatId = null;
        e1.DurationInMinutes = 0;
        insert e1;
        
        Event e2 = new event();
        e2.WhoId = con1.Id;
        e2.Subject ='Event sub 1';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now();
        e2.WhatId = contactTransferObj.legalIdOld;
        /*if(namespacePrefix == 'navpeII__'){
             e2.put('navpeII__Institution__c',null);
        }
        else{
            e2.put('navmnaI__Account__c',null);
        }*/
        e2.DurationInMinutes = 0;
        insert e2;
        
        contactTransferObj.Cancel();
        contactTransferObj.clearAddress(); 
        contactTransferObj.retainAddress();
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();
        contactTransferObj.isError = true;
        contactTransferObj.retainAddress();
		contactTransferObj.clearAddress();   
        apexpages.currentpage().getparameters().put('id','');
        ContactTransferAddOn_ctrl contactTransferObj1= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(con1));
    }
    
    static TestMethod void TestMethod2() {
        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        system.assertEquals('Test Acc', acc.Name);
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1; 
        
        Contact con = new Contact();
        con.FirstName = 'Edward';
        con.LastName = 'Elric';
        con.Email = 'fullmetal@alchemist.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Roy';
        con1.LastName = 'Mustang';
        con1.Email = 'flame@alchemist.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        createSetupData(activitySetting1,advanceSetting2);
        
        apexpages.currentpage().getparameters().put('id',con.id);
        ContactTransferAddOn_ctrl contactTransferObj= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(con));
        
        contactTransferObj.contactLookup = con;
        contactTransferObj.contactName = con1.FirstName+' '+con1.LastName;
        contactTransferObj.displayMessage = '';
        contactTransferObj.isContactIdNull = false;
        contactTransferObj.legalIdOld = acc.Id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId;
        contactTransferObj.isError = false;
        contactTransferObj.errorMessage = '';
        contactTransferObj.isOrgSettingActive = true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;
        contactTransferObj.accAPIName = affiliationAccountLookup;
        contactTransferObj.affiliationObjName = affiliationObjName;
        
        Task t1 = new task();
        t1.WhoId = con.Id;
        t1.Subject ='Task sub';
        t1.Status ='Completed';
        t1.Priority = 'Normal';
        t1.WhatId = null;
        insert t1;
        
        Task t2 = new task();
        t2.WhoId = con.Id;
        t2.Subject ='Task subject';
        t2.Status ='Completed';
        t2.Priority = 'Normal';
        /*if(namespacePrefix == 'navpeII__'){
             t2.put('navpeII__Institution__c',null);
        }
        else{
            t2.put('navmnaI__Account__c',null);
        }*/
        t2.WhatId = acc.Id;
        insert t2;
        
        Event e1 = new event();
        e1.WhoId = con.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.WhatId = null;
        e1.DurationInMinutes = 0;
        insert e1;
        
        Event e2 = new event();
        e2.WhoId = con.Id;
        e2.Subject ='Event subject';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now();
        e2.WhatId = acc.Id;
        e2.DurationInMinutes = 0;
        /*if(namespacePrefix == 'navpeII__'){
             e2.put('navpeII__Institution__c',null);
        }
        else{
            e2.put('navmnaI__Account__c',null);
        }*/
        insert e2;
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    
    }
    
    static TestMethod void TestMethod3() {
        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        system.assertEquals('Test Acc', acc.Name);
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1; 
        
        Contact con = new Contact();
        con.FirstName = 'Edward';
        con.LastName = 'Elric';
        con.Email = 'fullmetal@alchemist.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Roy';
        con1.LastName = 'Mustang';
        con1.Email = 'flame@alchemist.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        createSetupData(activitySetting1,advanceSetting3);
        
        apexpages.currentpage().getparameters().put('id',con.id);
        ContactTransferAddOn_ctrl contactTransferObj= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(con));
        
        contactTransferObj.contactLookup = con;
        contactTransferObj.contactName = con1.FirstName+' '+con1.LastName;
        contactTransferObj.displayMessage = '';
        contactTransferObj.isContactIdNull = false;
        contactTransferObj.legalIdOld = acc.Id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId;
        contactTransferObj.isError = false;
        contactTransferObj.errorMessage = '';
        contactTransferObj.isOrgSettingActive = true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;
        contactTransferObj.accAPIName = affiliationAccountLookup;
        contactTransferObj.affiliationObjName = affiliationObjName;
        
        Task t1 = new task();
        t1.WhoId = con.Id;
        t1.Subject ='Task sub';
        t1.Status ='Completed';
        t1.Priority = 'Normal';
        t1.WhatId = null;
        insert t1;
        
        Task t2 = new task();
        t2.WhoId = con.Id;
        t2.Subject ='Task sub';
        t2.Status ='Completed';
        t2.Priority = 'Normal';
        /*if(namespacePrefix == 'navpeII__'){
             t2.put('navpeII__Institution__c',null);
        }
        else{
            t2.put('navmnaI__Account__c',null);
        }*/
        t2.WhatId = acc.Id;
        insert t2;
        
        Task t3 = new task();
        t3.WhoId = con.Id;
        t3.Subject ='Task sub';
        t3.Status ='Completed';
        t3.Priority = 'Normal';
        /*if(namespacePrefix == 'navpeII__'){
             t3.put('navpeII__Institution__c',null);
        }
        else{
            t3.put('navmnaI__Account__c',null);
        }*/
        t3.WhatId = acc1.Id;
        insert t3;
        
        Event e1 = new event();
        e1.WhoId = con.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.WhatId = null;
        e1.DurationInMinutes = 0;
        insert e1;
        
        Event e2 = new event();
        e2.WhoId = con.Id;
        e2.Subject ='Event sub';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now();
        e2.WhatId = acc.Id;
        e2.DurationInMinutes = 0;
        /*if(namespacePrefix == 'navpeII__'){
             e2.put('navpeII__Institution__c',null);
        }
        else{
            e2.put('navmnaI__Account__c',null);
        }*/
        insert e2;
        
        Event e3 = new event();
        e3.WhoId = con.Id;
        e3.Subject ='Event sub';
        e3.StartDateTime = DateTime.Now();
        e3.EndDateTime = DateTime.Now();
        e3.WhatId = acc1.Id;
        e3.DurationInMinutes = 0;
        /*if(namespacePrefix == 'navpeII__'){
             e3.put('navpeII__Institution__c',null);
        }
        else{
            e3.put('navmnaI__Account__c',null);
        }*/
        insert e3;
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    

    }
    
    static TestMethod void TestMethod4() {
        
        Account a1 = new Account();
        a1.name = 'Account New 1';
        insert a1;
        system.assertEquals('Account New 1', a1.Name);
        
        Account a2 = new Account();
        a2.name = 'Account New 2';
        insert a2; 
        
        Contact c1 = new Contact();
        c1.FirstName = 'Fuhrer';
        c1.LastName = 'Matthew';
        c1.Email = 'fmatthew@gmail.com';
        c1.AccountId = a1.Id;
        insert c1;
        
        Contact c2 = new Contact();
        c2.FirstName = 'Hohenheim';
        c2.LastName = 'Elric';
        c2.Email = 'helric@gmail.com';
        c2.AccountId = a1.Id;
        insert c2;
        
        createSetupData(activitySetting2,advanceSetting1);
        
        apexpages.currentpage().getparameters().put('id',c1.id);
        ContactTransferAddOn_ctrl contactTransferObj= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(c1));
        
        contactTransferObj.contactLookup = c1;
        contactTransferObj.contactName = c2.FirstName+' '+c2.LastName;
        contactTransferObj.displayMessage = '';
        contactTransferObj.isContactIdNull = false;
        contactTransferObj.legalIdOld = a1.Id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId;
        contactTransferObj.isError = false;
        contactTransferObj.errorMessage = '';
        contactTransferObj.isOrgSettingActive = true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;
        contactTransferObj.accAPIName = affiliationAccountLookup;
        contactTransferObj.affiliationObjName = affiliationObjName;
        
        Task t1 = new task();
        t1.WhoId = c1.Id;
        t1.Subject ='Task sub';
        t1.Status ='Completed';
        t1.Priority = 'Normal';
        t1.WhatId = null;
        insert t1;
        
        Event e1 = new event();
        e1.WhoId = c1.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.WhatId = null;
        e1.DurationInMinutes = 0;
        insert e1;
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = a2.Id;
        contactTransferObj.transferActivity();    
    }
    
    static TestMethod void TestMethod5() {
        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        system.assertEquals('Test Acc', acc.Name);
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1; 
        
        Contact con = new Contact();
        con.FirstName = 'Edward';
        con.LastName = 'Elric';
        con.Email = 'fullmetal@alchemist.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Roy';
        con1.LastName = 'Mustang';
        con1.Email = 'flame@alchemist.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        createSetupData(activitySetting2,advanceSetting2);
        
        apexpages.currentpage().getparameters().put('id',con.id);
        ContactTransferAddOn_ctrl contactTransferObj= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(con));
        
        contactTransferObj.contactLookup = con;
        contactTransferObj.contactName = con1.FirstName+' '+con1.LastName;
        contactTransferObj.displayMessage = '';
        contactTransferObj.isContactIdNull = false;
        contactTransferObj.legalIdOld = acc.Id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId;
        contactTransferObj.isError = false;
        contactTransferObj.errorMessage = '';
        contactTransferObj.isOrgSettingActive = true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;
        contactTransferObj.accAPIName = affiliationAccountLookup;
        contactTransferObj.affiliationObjName = affiliationObjName;
        contactTransferObj.activitySetting2 = activitySetting2;
        
        Task t1 = new task();
        t1.WhoId = con.Id;
        t1.Subject ='Task sub';
        t1.Status ='Completed';
        t1.Priority = 'Normal';
        t1.WhatId = null;
        insert t1;
        
        Task t2 = new task();
        t2.WhoId = con.Id;
        t2.Subject = 'Task Subject';
        t2.Status = 'Completed';
        t2.Priority = 'Normal';
        t2.WhatId = acc.Id;
        insert t2;
        
        Event e1 = new event();
        e1.WhoId = con.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.WhatId = null;
        e1.DurationInMinutes = 0;
        insert e1;
        
        Event e2 = new event();
        e2.WhoId = con.Id;
        e2.Subject = 'Event Subject';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now();
        e2.WhatId = acc.Id;
        e2.DurationInMinutes = 0;
        insert e2;
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity(); 
    }
    
    static TestMethod void TestMethod6() {
        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        system.assertEquals('Test Acc', acc.Name);
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1; 
        
        Contact con = new Contact();
        con.FirstName = 'Edward';
        con.LastName = 'Elric';
        con.Email = 'fullmetal@alchemist.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Roy';
        con1.LastName = 'Mustang';
        con1.Email = 'flame@alchemist.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        createSetupData(activitySetting2,advanceSetting3);
        
        apexpages.currentpage().getparameters().put('id',con.id);
        ContactTransferAddOn_ctrl contactTransferObj= new ContactTransferAddOn_ctrl(new ApexPages.StandardController(con));
        
        contactTransferObj.contactLookup = con;
        contactTransferObj.contactName = con1.FirstName+' '+con1.LastName;
        contactTransferObj.displayMessage = '';
        contactTransferObj.isContactIdNull = false;
        contactTransferObj.legalIdOld = acc.Id;
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.isError = false;
        contactTransferObj.errorMessage = '';
        contactTransferObj.isOrgSettingActive = true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;
        contactTransferObj.accAPIName = affiliationAccountLookup;
        contactTransferObj.affiliationObjName = affiliationObjName;
        contactTransferObj.activitySetting2 = activitySetting2;
        
        Task t1 = new task();
        t1.WhoId = con.Id;
        t1.Subject ='Task sub';
        t1.Status ='Completed';
        t1.Priority = 'Normal';
        t1.WhatId = null;
        insert t1;
        
        Task t2 = new task();
        t2.WhoId = con.Id;
        t2.Subject = 'Task Subject';
        t2.Status = 'Completed';
        t2.Priority = 'Normal';
        t2.WhatId = acc.Id;
        insert t2;
        
        Task t3 = new task();
        t3.WhoId = con.Id;
        t3.Subject = 'Task Subject';
        t3.Status = 'Completed';
        t3.Priority = 'Normal';
        t3.WhatId = acc1.Id;
        /*if(namespacePrefix == 'navpeII__'){
             t3.put('navpeII__Institution__c',null);
        }
        else{
            t3.put('navmnaI__Account__c',null);
        }*/
        insert t3;
        
        Event e1 = new event();
        e1.WhoId = con.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.WhatId = null;
        e1.DurationInMinutes = 0;
        insert e1;
        
        Event e2 = new event();
        e2.WhoId = con.Id;
        e2.Subject = 'Event Subject';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now();
        e2.WhatId = acc.Id;
        e2.DurationInMinutes = 0;
        insert e2;
        
        Event e3 = new event();
        e3.WhoId = con.Id;
        e3.Subject = 'Event Subject';
        e3.StartDateTime = DateTime.Now();
        e3.EndDateTime = DateTime.Now();
        e3.WhatId = acc1.Id;
        e3.DurationInMinutes = 0;
        /*if(namespacePrefix == 'navpeII__'){
             e3.put('navpeII__Institution__c',null);
        }
        else{
            e3.put('navmnaI__Account__c',null);
        }*/
        insert e3;
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity(); 
    }
}