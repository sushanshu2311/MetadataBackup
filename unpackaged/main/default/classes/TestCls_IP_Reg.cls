@isTest
public class TestCls_IP_Reg{

    static testMethod void Cls_IP_Reg()
    {
        ID ProfileID = [ Select id from Profile where name = 'System Administrator'].id;
        System.assertNotEquals('MI1test', ProfileID); // (PE3.5, SK, 9Aug2017)
        
        User u1 = new User( email='test-user@fakeemail.com',  profileid = profileid, 
                    UserName=ProfileID+'test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1', 
                    TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                    LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
        insert u1;
        System.assertEquals(ProfileID+'test-user@fakeemail.com', u1.UserName); // (PE3.5, SK, 9Aug2017)
        
        ApexPages.currentPage().getHeaders().put('Host','');
        
        system.runas(u1){
            Cls_IP_Reg  clsReg = new Cls_IP_Reg ();
        }   
    }
}