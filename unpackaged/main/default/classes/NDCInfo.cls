public with sharing class NDCInfo
{
   public String Identifier {get;set;}
   public List<EmailServicesAddress> EmailAddList {get;set;}
   public string Uname{get;set;}  //Hold the User name  
   
   public NDCInfo()
   {      
        
        
      Uname=EncodingUtil.urlEncode(UserInfo.getUserName(), 'UTF-8');
        
      EmailAddList = new List<EmailServicesAddress> ();
      
      // SK: 8Dec2017
      if(Schema.sObjectType.EmailServicesAddress.isAccessible() && Schema.sObjectType.EmailServicesAddress.Fields.LocalPart.isAccessible() && 
          Schema.sObjectType.EmailServicesAddress.Fields.EmailDomainName.isAccessible())
      {
          EmailAddList = [Select LocalPart,EmailDomainName From EmailServicesAddress where LocalPart='Listener'];
      }
      
      if(EmailAddList.size()>0 )
      {
         Identifier = String.ValueOf(EmailAddList[0].LocalPart)+'@'+String.ValueOf(EmailAddList[0].EmailDomainName);
      }
      else
      {
       
       Identifier='Please contact Admin to set up your email service.';
         
      }
     
   }
   public static testMethod void TestUserInfo()
   {
    NDCInfo csInfo=new NDCInfo();
    System.assertnotEquals(2,csInfo.EmailAddList.size());
   }
}