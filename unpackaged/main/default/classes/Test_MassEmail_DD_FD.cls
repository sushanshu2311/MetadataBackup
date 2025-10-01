@isTest
public class Test_MassEmail_DD_FD{

    public static testmethod void testMethod1(){
        apexpages.currentpage().getparameters().put('pn','ID');
        MassEmail_DD_FD obj1= new MassEmail_DD_FD();
        obj1.getItems();
        obj1.goToMainPage();
        obj1.cancel();
        contact con = new contact();
            con.lastName = 'Test last Contact'; 
            con.firstname = 'Test First Name'; 
            con.HasOptedOutOfEmail=false;  
            con.MailingCity ='Test City'; 
            con.MailingCountry='Test country'; 
            con.MailingPostalCode = '102010';
            con.MailingState = 'Test State';
            con.MailingStreet='Test street';
            con.Description='test hello how are you';
            con.Fax='012423';
            con.Phone = '01245263';
            con.otherCity = 'test other city';
            con.otherCountry='Test other country'; 
            con.otherPostalCode = '1020101';
            con.otherState = 'Test other State';
            con.otherStreet='Test other street';  
        insert con;
        System.assertEquals('Test last Contact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fund= new Fund__c(Name= 'testFund', Fund_Type__c='Fund');
        insert fund;
        System.assertEquals('testFund', fund.Name); // (PE3.5, SK, 9Aug2017)
        
        Fund_Distribution__c fd= new Fund_Distribution__c(Fund_Name__c= fund.id);
        insert fd;
        System.assertNotEquals('MI1 test', fd.Name); // (PE3.5, SK, 9Aug2017)
        
        string conId= con.id+'@@'+fd.id+','+con.id+'@@'+fd.id+','+con.id+'@@'+fd.id+','+con.id+'@@'+fd.id+','+con.id+'@@'+fd.id+','+con.id+'@@'+fd.id;
        
        obj1.selectedConId= conId;
        obj1.Store_as_an_activity= true;
        obj1.bCC_Me_On_One= true;
        obj1.sendmassmail();
        List<String> lstS= new List<String>();
        for(String str: conId.split(',')){
            lstS.add(str);
        }         
        MassEmail_DD_FD.sendFinalMail(lstS,'00X41000000Djba',true,true,true,true);
        MassEmail_DD_FD.GetEmailLimit();
        
        apexpages.currentpage().getparameters().put('pn','FD');
        MassEmail_DD_FD obj2= new MassEmail_DD_FD();
        obj2.getItems();
        obj2.goToMainPage();
        apexpages.currentpage().getparameters().put('pn','DD');
        MassEmail_DD_FD obj3= new MassEmail_DD_FD();
        obj3.getItems();
        obj3.goToMainPage();
        apexpages.currentpage().getparameters().put('pn','CC');
        MassEmail_DD_FD obj4= new MassEmail_DD_FD();
        obj4.getItems();
        obj4.goToMainPage();
    }

}