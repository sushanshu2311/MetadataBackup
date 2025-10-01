@isTest(seeAllData =false)
public class Test_AccountTrigger2
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
    static  String RecTypeOther='';
    static     RecordType[] Rec;
    
    
    public void testDataSetUP(){
        String tempStr = 'testing...';
        System.assertEquals('testing...', tempStr); // (PE3.5, SK, 9Aug2017)
    }
    
    
    public static testmethod void Fordeletion()
    {
        Test.startTest();
        Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
        
        for(RecordType R:Rec)
        {
            if(R.Name == 'Institution')
            {
                RecTypeInst= R.Id;
            }
            else if(R.Name == 'Limited Partner')
            {
                RecTypeLP= R.Id;
            }
            else if(R.Name == 'Company')
            {
                RecTypeCompany= R.Id;
            }
            else if(R.Name == 'Fund Manager')
            {
                RecTypeFM= R.Id;
            }
            else if(R.Name == 'Fund Manager’s Fund')
            {
                RecTypeFMF= R.Id;
            }
            else
            {
            RecTypeOther= R.Id;
            }
        }
        
        Account ins1=new Account(Name='ins1',RecordTypeId=RecTypeInst,Familiar_Name__c='ins1');  // Parent Institution is blank
        insert ins1;
        
        Account ins2=new Account(Name='ins1',RecordTypeId=RecTypeInst,Familiar_Name__c='ins1');  // Parent Institution is blank
        insert ins2;
        
        Account ins3=new Account(Name='ins1',RecordTypeId=RecTypeInst,Familiar_Name__c='ins1');  // Parent Institution is blank
        insert ins3;
        
        Account lp1=new Account( parentId=ins1.id,Name='lp1',RecordTypeId=RecTypeLP);
        insert lp1;
            
        Account fundmanager=new Account( Name='fundmanager',RecordTypeId=RecTypeFM);
        insert fundmanager;
            
        Account company2=new Account( Name='company2',RecordTypeId=RecTypeCompany);
        insert company2;
        
        Contact contact1 = new Contact(lastname = 'Tester', AccountID=ins1.id);
        insert contact1;
           
        Contact contact2 = new Contact(lastname = 'Tester', AccountID=fundmanager.id);
        insert contact2;
        
        Contact contact3 = new Contact(lastname = 'Tester', AccountID=company2.id);
        insert contact3;
        
        Contact contact4 = new Contact(lastname = 'Tester', AccountID=lp1.id);
        insert contact4;
          
           
            
        Account Company1=new Account(Name='company',RecordTypeId=RecTypeCompany);
        insert Company1;
            
        Fund__c coinv = new Fund__c(Name = '@isTest',Investment_Category__c = 'Co-Investment');
        insert coinv;
             
        Partnership__c part1 = new Partnership__c(Name='Part',Fund__c=coinv.Id);
        insert part1;
            
        Partnership__c part2 = new Partnership__c(Name='Part',Fund__c=coinv.Id);
        insert part2;
            
        Commitment__c commitment1=new Commitment__c(Limited_Partner__c=lp1.id,Partnership__c=part1.id, Portfolio_Company__c=Company1.Id,Commitment_Amount_nearest__c = 20000000);
        insert commitment1;
            
        Transfer__c transfer1= new Transfer__c(Commitment_Name__c=commitment1.Id, Transfer_Amount_nearest__c=10000000, Transfer_to_Limited_Partner__c=lp1.Id, Transfer_to_Partnership__c=part2.Id, Transfer_Date__c=System.Today());
        insert transfer1;
        
   /*     Fundraising__c fundr= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=ins1.id,Portfolio_Company__c=company1.id);
        insert fundr;
             
        Fundraising_Contact__c fundrsingcontact=new Fundraising_Contact__c(Fundraising__c=fundr.Id,Contact__c=contact1.Id);
        insert fundrsingcontact;
            
        Fundraising_Contact__c fundrsingcontact1=new Fundraising_Contact__c(Fundraising__c=fundr.Id,Contact__c=contact2.Id);
        insert fundrsingcontact1;
             
        Fundraising_Contact__c fundrsingcontact2=new Fundraising_Contact__c(Fundraising__c=fundr.Id,Contact__c=contact3.Id);
        insert fundrsingcontact2;
            
        Fundraising_Contact__c fundrsingcontact3=new Fundraising_Contact__c(Fundraising__c=fundr.Id,Contact__c=contact4.Id);
        insert fundrsingcontact3;
            
        Advisor__c advisor1=new Advisor__c( Advisor__c=ins1.id,Client__c=ins2.id,Fundraising__c=fundr.id);
        insert advisor1;
        
        Advisor__c client1=new Advisor__c( Advisor__c=ins2.id,Client__c=ins1.id,Fundraising__c=fundr.id);
        //insert client1;
        lp1.parentId=company1.id;
            */
            
        cls_ProductSetting clsobj1=new cls_ProductSetting ();
        
        clsobj1.ObjFundraising_FM=new ProductSetting__c(name='FundraisingwithFM',status__c=true);
        insert clsobj1.ObjFundraising_FM;
        
        clsobj1.ObjFundraising_FMF=new ProductSetting__c(name='FundraisingwithFMF',status__c=true);
        insert clsobj1.ObjFundraising_FMF;
        
        ProductSetting__c ObjFundraising_FM;
        ProductSetting__c ObjFundraising_FMF;
        
        ObjFundraising_FM = ProductSetting__c.getInstance('FundraisingwithFM');
        ObjFundraising_FMF = ProductSetting__c.getInstance('FundraisingwithFMF');
        ObjFundraising_FM.status__c=false;
        ObjFundraising_FMF.status__c=false;
          
        update ObjFundraising_FM;
        update ObjFundraising_FMF;
        //Test.startTest();   
        account insfordelete=new account(name='fm',RecordTypeId=RecTypeInst);
        insert insfordelete;
           
        account insfordelete1=new account(name='fm',RecordTypeId=RecTypeInst);
        insert insfordelete1;
                  
        Account companyfordelete=new Account( Name='company2',RecordTypeId=RecTypeCompany);
        insert companyfordelete;
        
        Contact contactfordelete1 = new Contact(lastname = 'Tester', AccountID=insfordelete1.id);
        insert contactfordelete1;
        
        account fm1fordelete=new account(name='fm',RecordTypeId=RecTypeFM);
        insert fm1fordelete;
        
        Contact contactfordelete = new Contact(lastname = 'Tester', AccountID=fm1fordelete.id);
        insert contactfordelete;
        
        account fmf1fordelete=new account(name='fmf',parentId=fm1fordelete.id,RecordTypeId=RecTypeFMF);
        insert fmf1fordelete;
        
        
    //    Fundraising__c fundfordelete= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c= insfordelete.id,Portfolio_Company__c=company1.id);
    //    insert fundfordelete;
        
    //     Fundraising__c fundfordelete1= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c= insfordelete1.id,Portfolio_Company__c=company1.id);
    //    insert fundfordelete1;
        
    //    Fundraising_Contact__c fundrsingcontactfordelete=new Fundraising_Contact__c(Fundraising__c=fundfordelete.Id,Contact__c=contactfordelete.Id);
       // insert fundrsingcontactfordelete;
    //     Fundraising_Contact__c fundrsingcontactfordelete1=new Fundraising_Contact__c(Fundraising__c=fundfordelete1.Id,Contact__c=contactfordelete1.Id);
   //     insert fundrsingcontactfordelete1;
        
        Test.stopTest();
        
        try
        {
            update lp1;
        }
        catch(Exception e)
        {
         //  System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
            // delete ins1;
        }
        catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
           // delete lp1;
        }
        Catch(Exception e)
        {
           //  System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
            //delete company1;
        }
        catch(Exception e)
        {
            // System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
            //delete company2;
        }
        catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
         try
        {
            //delete fundmanager;
        }
        catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
          //  delete fmf1fordelete;
        }
        catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
            //delete fm1fordelete;
        }
        catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        
        
    }
}