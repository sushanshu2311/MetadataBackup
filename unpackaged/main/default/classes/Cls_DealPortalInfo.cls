public with sharing class Cls_DealPortalInfo 
{
   
 public List<User> allUser;
 public DPInfo__c dpInfo{get; set;}
 public String info{get; set;}
 
 public Cls_DealPortalInfo()
 { 
   allUser = new List<User>();
   if(Schema.sObjectType.User.isAccessible() &&  Schema.sObjectType.User.fields.User_Identifier__c.isAccessible())
        allUser=[select id,User_Identifier__c from User where id=:userInfo.getUserId() Limit 1];
   if(allUser.size()>0 && allUser!=null && allUser[0].User_Identifier__c!=null && allUser[0].User_Identifier__c!='')
   {
        dpInfo=DPInfo__c.getValues(allUser[0].User_Identifier__c); 
        if(dpInfo!=null)
        {
            info=dpInfo.Info__c;
        }
        
   }   
 }
 
  public void deleteInfo() 
  {
   if(dpInfo!=null && Schema.sObjectType.DPInfo__c.isDeletable())
       delete dpInfo;
   info=null;
  }

//    Test Method

public static testMethod void testDealPortalInfo()
{
  Cls_DealPortalInfo testDeal=new Cls_DealPortalInfo();
  System.assertnotEquals(2,testDeal.allUser.size());
  testDeal.deleteInfo();
}


 
}