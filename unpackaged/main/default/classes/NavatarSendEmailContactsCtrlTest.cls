@isTest
public class NavatarSendEmailContactsCtrlTest {
	@TestSetup
    static void setup(){
        Theme__c theme = new Theme__c();
        theme.Name = 'Theme 1';
        insert theme;
        
        Account acc = new Account();
        acc.Name = 'Acc 1';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Con 1';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.LastName = 'Con 1';
        con1.Email = 'test1@test.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        Theme_Relation__c themeR1 = new Theme_Relation__c(Account__c = acc.Id, Theme__c = theme.Id);	insert themeR1;
        Theme_Relation__c themeR2 = new Theme_Relation__c(Contact__c = con.Id, Theme__c = theme.Id);	insert themeR2;
        Theme_Relation__c themeR3 = new Theme_Relation__c(Contact__c = con1.Id, Theme__c = theme.Id);	insert themeR3;

    }
    
    static testmethod void fetchAllContacts(){
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test');
        insert e;
        List<String> contactList = new List<String>();
        for(Contact con : [Select Id, Name from Contact]){
            contactList.add(con.Id);
        }        
        
        Theme__c theme = [Select Id From Theme__c Limit 1];
        NavatarSendEmailContactsCtrl.getOrgNamespace();
        NavatarSendEmailContactsCtrl.init(theme.Id);
        NavatarSendEmailContactsCtrl.fetchNavatarSetupData('Test');
        NavatarSendEmailContactsCtrl.fetchMainQueryData('Select Id From Theme__c', new List<String>());
        NavatarSendEmailContactsCtrl.getEmailLimit();
        NavatarSendEmailContactsCtrl.sendMassMail(contactList, e.Id, false, false, false);
        NavatarSendEmailContactsCtrl.executeQuery1('test', 'test', 'test');
        NavatarSendEmailTemplateCtrl.retrievefolders('');
        
        System.assert(theme != null);
    }
}