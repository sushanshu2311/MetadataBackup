@isTest
private class Test_listener 
{
  static String sCompanyApi =  CommonUtility.chkmasterLookupInPiplineAPI();

 public static testMethod void dpmltest13() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar12@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
    // Added by PE Team
    
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
  acc.RecordTypeId=Rec[0].id;

/////    End   //
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';


 //DPML 13
                Errormsg='<DPML><Value>13</Value><UserIdentifier>A002</UserIdentifier><Msg>Your account has been updataed</Msg></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML13';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
                }
                
public static testMethod void dpmltest131() 
{
string Errormsg;
XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString();  
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar22@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    System.assertEquals('a',usrob.Alias);
                    System.assertEquals('navatar22@navatargroup.com',usrob.username);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
     // Added by PE Team
    
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
  acc.RecordTypeId=Rec[0].id;

/////    End   //
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

//DPML 13
                Errormsg='<DPML><Value>13</Value><UserIdentifier>A002</UserIdentifier><Msg></Msg></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML13';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
              
}
public static testMethod void dpmltest161() 
{
string Errormsg;
XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString();  
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar22@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account     
    
  
 Account acc=new Account();
 RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
 acc.RecordTypeId=Rec[0].id;
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
 
    // Added by PE Team
    
  
  acc.RecordTypeId=Rec[0].id;

/////    End   //
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

//DPML 13
                Errormsg='<DPML><Value>16</Value><UserIdentifier>A002</UserIdentifier><Msg></Msg></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML16';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
              
}
public static testMethod void dpmltest9() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar345@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
    // Added by PE Team
    
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
  acc.RecordTypeId=Rec[0].id;

/////    End   //
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

//DPML 9
                Errormsg='<DPML><Value>9</Value><UserIdentifier>A002</UserIdentifier><DealName>Deal9</DealName><GeographicRegion>North America</GeographicRegion><Description>Deal has been downloaded</Description><TransactionType>Distressed Investment</TransactionType><Revenue>100-150</Revenue><EBITDA>50-100</EBITDA><DealSize>15</DealSize><Industries><Industry><Level1ID>1</Level1ID><Level1Name>Wheat</Level1Name></Industry></Industries><DealKeywords>test</DealKeywords><KeyContactName>Deal9</KeyContactName><KeyContactPhone>9876543110</KeyContactPhone><KeyContactFax>9876543210</KeyContactFax><KeyContactEmail>my12321@gmail.com</KeyContactEmail></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML9';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
              dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
}

public static testMethod void dpmltest91() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar34@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
 acc.RecordTypeId=Rec[0].id;
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);
 
   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

//DPML 9
                Errormsg='<DPML><Value>9</Value><UserIdentifier>A002</UserIdentifier><DealName>null</DealName><GeographicRegion>null</GeographicRegion> <Description>null</Description><TransactionType>null</TransactionType><Revenue>null</Revenue><EBITDA>null</EBITDA><DealSize>null</DealSize><Industries><Industry><Level1ID>null</Level1ID><Level1Name>null</Level1Name></Industry></Industries><DealKeywords>null</DealKeywords><KeyContactName>null</KeyContactName><KeyContactPhone>null</KeyContactPhone><KeyContactFax>null</KeyContactFax><KeyContactEmail>null</KeyContactEmail></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML9';
                mail.htmlbody =Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
              dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
}

public static testMethod void dpmltest10() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar1q@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    insert usrob;
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
 acc.RecordTypeId=Rec[0].id;
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

 //DPML 10
                Errormsg='<DPML><Value>10</Value><UserIdentifier>A002</UserIdentifier><AccountName>Navatar</AccountName><BillingStreet>Sec-63</BillingStreet><BillingCity>Noida</BillingCity><BillingState>UP</BillingState><BillingPostalCode>201301</BillingPostalCode><BillingCountry>India</BillingCountry><Website>www.yahoo.com</Website><Phone>9876543210</Phone><Fax>9876543210</Fax><Industries><Industry><Level1ID>1</Level1ID><Level1Name>wheat</Level1Name></Industry></Industries><CompanyKeywords>test</CompanyKeywords><CompanyType>Private Equity</CompanyType><KeyContactName>Deal9</KeyContactName><KeyContactPhone>9876543110</KeyContactPhone><KeyContactFax>9876543210</KeyContactFax><KeyContactEmail>my12321@gmail.com</KeyContactEmail></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML10';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
                 dm.getElementByTagName('Value');
                 dm.ownerDocument() ;              
}

public static testMethod void dpmltest101() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar23@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
 acc.RecordTypeId=Rec[0].id;
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);
 
   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

//DPML 10
                Errormsg='<DPML><Value>10</Value><UserIdentifier>A002</UserIdentifier><DealName>trialsf</DealName><BillingStreet>null</BillingStreet><BillingCity>null</BillingCity><BillingState>null</BillingState><BillingPostalCode>null</BillingPostalCode><BillingCountry>null</BillingCountry><Website>null</Website><Phone>null</Phone><Fax>null</Fax><CompanyKeywords>null</CompanyKeywords><CompanyType>null</CompanyType><KeyContactName>null</KeyContactName><KeyContactPhone>null</KeyContactPhone><KeyContactFax>null</KeyContactFax><KeyContactEmail>null</KeyContactEmail></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML10';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
               
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
              
}

public static testMethod void dpmltest11() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar2q@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
 acc.RecordTypeId=Rec[0].id;
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

//DPML11
                Errormsg='<DPML><Value>11</Value><UserIdentifier>A002</UserIdentifier><DealName>Navatar</DealName><BillingStreet>SEC-12</BillingStreet><BillingCity>Noida</BillingCity><BillingState>UP</BillingState><BillingPostalCode>243001</BillingPostalCode><BillingCountry>India</BillingCountry><Website>www.yahoo.com</Website><Phone>98765443321</Phone><Fax>9879876578</Fax><CompanyKeywords>Deal111</CompanyKeywords><CompanyType>Buy-side M&A</CompanyType></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML11';
                mail.htmlbody  = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
              
}

public static testMethod void dpmltest1101() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString(); 
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar3e@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
 acc.RecordTypeId=Rec[0].id;
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

 //DPML11
                Errormsg='<DPML><Value>11</Value><UserIdentifier>A002</UserIdentifier><AccountName>null</AccountName><BillingStreet>null</BillingStreet><BillingCity>null</BillingCity><BillingState>null</BillingState><BillingPostalCode>null</BillingPostalCode><BillingCountry>null</BillingCountry><Website>null</Website><Phone>null</Phone><Fax>null</Fax><Industries><Industry><Level1ID>null</Level1ID><Level1Name>null</Level1Name></Industry></Industries><CompanyKeywords>null</CompanyKeywords><CompanyType>null</CompanyType></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML11';
                mail.htmlbody  = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
              
}


public static testMethod void dpmltest1() 
{
string Errormsg;
  XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString();
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar65@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
 
     // Added by PE Team
    
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
  acc.RecordTypeId=Rec[0].id;

/////    End   //

   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

 //DPML 1
                Errormsg='<DPML><Value>1</Value><NavatarProductUserName>testpe@gmail.com</NavatarProductUserName><UserIdentifier>A002</UserIdentifier><ReplyTo>arora.charu05@gmail.com</ReplyTo></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML1';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
}

public static testMethod void dpmltest1111() 
{
string Errormsg;
 XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString();  
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar78@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 acc.OwnerId=usrob.Id ;
    // Added by PE Team
    
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
  acc.RecordTypeId=Rec[0].id;

/////    End   //
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);

   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

 //DPML 1
                Errormsg='<DPML><Value>1</Value><NavatarProductUserName></NavatarProductUserName><UserIdentifier></UserIdentifier><ReplyTo>arora.charu05@gmail.com</ReplyTo></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML1';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
}

public static testMethod void dpmltest10111() 
{
string Errormsg;
XMLDomDp dm=new XMLDomDp ();
    dm.dumpall();
    //dm.Element();
   
   dm.toXmlString();   
        
       // insert  user     
     user usrob=new user();
                    
                    usrob.username='navatar79@navatargroup.com';
                    usrob.LastName='abc';
                    usrob.Email='my123@gmail.com';
                    usrob.Alias='a';
                    usrob.phone='76764787';
                    usrob.CommunityNickname='4fff';
                    usrob.EmailEncodingKey='ISO-8859-1';
                    List<Profile> lstProfile = [select Id from Profile where Name = 'System Administrator'];
                        if(lstProfile.size() > 0)
                        {
                                usrob.ProfileId =lstProfile[0].Id;
                        }

                    usrob.User_Identifier__c='A002';
                    usrob.TimeZoneSidKey='America/Los_Angeles';
                    usrob.LocaleSidKey='en_US';
                    usrob.LanguageLocaleKey='en_US';
                    usrob.IsActive=false;
                    insert usrob;
                    System.assertEquals('A002',usrob.User_Identifier__c);
                    
    // insert account                
 Account acc=new Account();
 acc.Name='Navatar';
 //acc.OwnerId=usrob.Id ;
    // Added by PE Team
    
  RecordType[] Rec= [Select id,Name,SObjectType from RecordType where name='Company'and SObjectType='Account'];
  acc.RecordTypeId=Rec[0].id;

/////    End   //
   insert acc;
 
  // insert contact
 Contact con=new Contact();
 con.LastName='Navatar1';
 con.accountid=acc.id;
 //con.OwnerId = usrob.Id ;
   insert con;
   
   // insert pipeline
 Pipeline__c   pi=new Pipeline__c();
 pi.Stage__c='New/Initial Interest';
 pi.put(sCompanyApi, acc.id);
 
   insert pi; 
                   
                    
 
Listener pe=new Listener();

pe.usrIdentifier='A001';
pe.usrStatus='LOI';
pe.NavatarProductUserName='testpe@gmail.com';
pe.replyto='arora.charu05@gmail.com';                
                        

 //DPML 1
                Errormsg='<DPML><Value>1</Value><NavatarProductUserName>testpe@gmail.com</NavatarProductUserName><UserIdentifier>A002</UserIdentifier><ReplyTo>arora.charu05@gmail.com</ReplyTo></DPML>';
                Messaging.InboundEmail mail = new Messaging.InboundEmail();
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                mail.toAddresses=new string[] {'arora.charu0511@gmail.com'};
                mail.Subject='DPML1';
                mail.htmlbody = Errormsg;
                envelope.fromAddress = 'arora.charu05@gmail.com';
                Messaging.InboundEmailResult  result = pe.handleInboundEmail(mail,envelope);
                System.assert (result.success, 'InboundEmailResult returned a failure message');
                dm.getElementByTagName('Value');
                 dm.ownerDocument() ; 
}
}