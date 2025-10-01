@isTest(SeeAllData = true)
public Class TestRequireFieldComp_Ctlr
{

   
    static testMethod void TestRequireFieldCompMethod()
    {
        List<RecordType> lstTypeId = [Select id from recordtype where name='Institution' Limit 1];
        Account A1 = new Account(Name = 'Test Account' ,recordTypeId = lstTypeId[0].id);
        insert A1;
        System.assertEquals('Test Account', A1.Name); // (PE3.5, SK, 9Aug2017)
        
        contact con = new Contact(lastname='testContact',accountid=A1.id);
        insert con;
        System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        ID ProfileID = [ Select id from Profile where name = 'System Administrator'].id; 
        User u1 = new User( email='test-user@fakeemail.com', profileid = profileid, 
                    UserName='PE3.5requireCompuser@fakeemail.com', alias='f55user', CommunityNickName='perequireuser1', 
                    TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                    LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ,  isActive=true);
        insert u1;
        System.assertEquals('PE3.5requireCompuser@fakeemail.com', u1.userName); // (PE3.5, SK, 9Aug2017)
        
        System.runas(u1)
        {
            Test.StartTest();
            RequireFieldComp_Ctlr objRequireField = new RequireFieldComp_Ctlr();
            objRequireField.strObjectApiName = 'Account';
            objRequireField.getLayoutNameData();
            objRequireField.strObjectLayoutName = 'institution';
            objRequireField.getLayoutInformation();
            Test.StopTest();
        }
    }
    
    
}