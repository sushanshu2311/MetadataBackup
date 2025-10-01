@isTest
public class Test_AccountTrigger
{
    static string RecTypeInst='';
    static string RecTypeLP='';
   static  string RecTypeCompany='';
   static string RecTypeFM='';
   static string RecTypeFMF='';
  static  String RecTypeOther='';
  static     RecordType[] Rec;
    
public static testmethod void ForInstititution()
{
     Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
    for(RecordType R:Rec)
    {
        if(R.Name == 'Institution')
        {
            RecTypeInst= R.Id;
        }
        if(R.Name == 'Limited Partner')
        {
            RecTypeLP= R.Id;
        }
        if(R.Name == 'Company')
        {
            RecTypeCompany= R.Id;
        }
        if(R.Name == 'Fund Manager')
        {
            RecTypeFM= R.Id;
        }
        if(R.Name == 'Fund Manager’s Fund')
        {
            RecTypeFMF= R.Id;
        }
    }

    // Institution Scenario
    Account ins1=new Account(Name='ins1',RecordTypeId=RecTypeInst,Familiar_Name__c='ins1');  // Parent Institution is blank
    insert ins1;
    
    Account lp1=new Account( parentId=ins1.id,Name='lp1',RecordTypeId=RecTypeLP);
    insert lp1;
    
    Account Company1=new Account(Name='company',RecordTypeId=RecTypeCompany);
    insert Company1;
    
    Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
    insert fm1;
    
    Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
    insert fmf1;
    
    ProductSetting__c.getInstance('InstitutionwithFMF').status__c=false;
    update  ProductSetting__c.getInstance('InstitutionwithFMF');
    
    ProductSetting__c.getInstance('InstitutionwithFM').status__c=false;
    update ProductSetting__c.getInstance('InstitutionwithFM');
    
    Account ins3=new Account(parentId=fm1.id,RecordTypeId=RecTypeInst,Name='ins1',Familiar_Name__c='ins1'); // parent institution is Fudn manager
    try{
        insert ins3;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    Account ins4=new Account(parentId=fmf1.id,RecordTypeId=RecTypeInst,Name='ins1',Familiar_Name__c='ins1'); // parent institution is Fudn manager's fund
    try
    {
        insert ins4;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
     Account ins5=new Account(parentId=lp1.id,RecordTypeId=RecTypeInst,Name='ins1',Familiar_Name__c='ins1'); // Parent institution is Limited Partner
      try
    {
    insert ins5;
       }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    // update 
    ins1.parentId=null; // parent institution is blank
    update ins1;
    ins1.parentId=lp1.id; // paraent institution is Limited partner
    try
    {
        update ins1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    ins1.parentId=company1.id; // parent institution is company
    update ins1;
    ins1.parentId=Fm1.id; // paraent institution is Fund Manager
    try
    {
        update ins1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    ins1.parentId=Fmf1.id; // paraent institution is Fund Manager'sfund
    try
    {
        update ins1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    lp1.parentId=null;
    try
    {
        update lp1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    lp1.parentId=Fmf1.id;
    try
    {
        update lp1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    
    
    
}
public static testmethod void ForCoompany()
{
 Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
    for(RecordType R:Rec)
    {
        if(R.Name == 'Institution')
        {
            RecTypeInst= R.Id;
        }
        if(R.Name == 'Limited Partner')
        {
            RecTypeLP= R.Id;
        }
        if(R.Name == 'Company')
        {
            RecTypeCompany= R.Id;
        }
        if(R.Name == 'Fund Manager')
        {
            RecTypeFM= R.Id;
        }
        if(R.Name == 'Fund Manager’s Fund')
        {
            RecTypeFMF= R.Id;
        }
    }

    // Institution Scenario
    Account ins1=new Account(Name='ins1',RecordTypeId=RecTypeInst,Familiar_Name__c='ins1');  // Parent Institution is blank
    insert ins1;
    
    Account lp1=new Account( parentId=ins1.id,Name='lp1',RecordTypeId=RecTypeLP);
    insert lp1;
    
    Account Company1=new Account(Name='company',RecordTypeId=RecTypeCompany);
    insert Company1;
    
    Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
    insert fm1;
    
    Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
    insert fmf1;
    
    Account company2=new Account(parentId=ins1.id,RecordTypeId=RecTypeCompany,Name='company2'); // paraent institution  is institution
    insert company2;
    
   ProductSetting__c.getInstance('CompanywithFM').status__c=false;
    update  ProductSetting__c.getInstance('CompanywithFM');
    
   ProductSetting__c.getInstance('CompanywithFMF').status__c=false;
    update ProductSetting__c.getInstance('CompanywithFMF');
    
    Account Company3=new Account(parentId=fm1.id,RecordTypeId=RecTypeCompany,Name='company3'); // parent institution is Fudn manager
    try{
        insert Company3;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    Account Company4=new Account(parentId=fmf1.id,RecordTypeId=RecTypeCompany,Name='company4'); // parent institution is Fudn manager's fund
    try
    {
        insert Company4;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
     Account Company5=new Account(parentId=lp1.id,RecordTypeId=RecTypeCompany,Name='company5'); // Parent institution is Limited Partner
      try
    {
    insert Company5;
       }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    // update 
    Company1.parentId=null; // parent institution is blank
    update Company1;
    Company1.parentId=lp1.id; // paraent institution is Limited partner
    try
    {
        update Company1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    Company1.parentId=company2.id; // parent institution is company
    update Company1;
    Company1.parentId=Fm1.id; // paraent institution is Fund Manager
    try
    {
        update Company1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    Company1.parentId=Fmf1.id; // paraent institution is Fund Manager'sfund
    try
    {
        update Company1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    
    
    
}

public static testmethod void ForLimietdPartner()
{
    Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
    for(RecordType R:Rec)
    {
        if(R.Name == 'Institution')
        {
            RecTypeInst= R.Id;
        }
        if(R.Name == 'Limited Partner')
        {
            RecTypeLP= R.Id;
        }
        if(R.Name == 'Company')
        {
            RecTypeCompany= R.Id;
        }
        if(R.Name == 'Fund Manager')
        {
            RecTypeFM= R.Id;
        }
        if(R.Name == 'Fund Manager’s Fund')
        {
            RecTypeFMF= R.Id;
        }
    }
    
     Account LP1=new Account(Name='ins1',RecordTypeId=RecTypeLP);  // Parent Institution is blank
    try
    {
        insert LP1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
     Account company1=new Account(Name='comp',RecordTypeId=RecTypeCompany);  // Parent Institution is blank
     insert company1;
     Account LP2=new Account(Name='ins1',parentId=company1.id,RecordTypeId=RecTypeLP);  // Parent Institution is company
    try
    {
        insert LP2;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    
    
}
public static testmethod void ForFundManager()
{
    Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
    for(RecordType R:Rec)
    {
        if(R.Name == 'Institution')
        {
            RecTypeInst= R.Id;
        }
        if(R.Name == 'Limited Partner')
        {
            RecTypeLP= R.Id;
        }
        if(R.Name == 'Company')
        {
            RecTypeCompany= R.Id;
        }
        if(R.Name == 'Fund Manager')
        {
            RecTypeFM= R.Id;
        }
        if(R.Name == 'Fund Manager’s Fund')
        {
            RecTypeFMF= R.Id;
        }
    }
    Account FM1=new Account(Name='FM!',RecordTypeId=RecTypeFM);  // Parent Institution is blank
    insert FM1;
    
    Account FM2=new Account(Name='FM!',parentId=FM1.id,RecordTypeId=RecTypeFM);  // Parent Institution is Fund Manager
    insert FM2;
    Account comp=new Account(name='comp',RecordTypeId=RecTypeCompany);
    insert comp;
    Account FMf3=new Account(Name='FMf!',parentId=FM1.id,RecordTypeId=RecTypeFMF);  // 
    insert FMf3;
    
    Account FM4=new Account(Name='FMf!',parentId=FMf3.id,RecordTypeId=RecTypeFM);  // Parent Institution is Fund Manager's Fund
    
    try
    {
        insert FM4;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    // For Update
    FM1.parentId=null;
    update FM1;
    
    FM1.parentId=comp.id;
    update FM1;
    
    FM1.parentId=FMf3.id;
    try
    {
        update FM1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    
    
    
    
    
}
public static testmethod void ForFundManagersfund()
{
    Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
    
    for(RecordType R:Rec)
    {
        if(R.Name == 'Institution')
        {
            RecTypeInst= R.Id;
        }
        if(R.Name == 'Limited Partner')
        {
            RecTypeLP= R.Id;
        }
        if(R.Name == 'Company')
        {
            RecTypeCompany= R.Id;
        }
        if(R.Name == 'Fund Manager')
        {
            RecTypeFM= R.Id;
        }
        if(R.Name == 'Fund Manager’s Fund')
        {
            RecTypeFMF= R.Id;
        }
    }
    
     Account fmf1=new Account(Name='fmf1',RecordTypeId=RecTypeFMF);  // Parent Institution is blank
    try
    {
        insert fmf1;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
     Account company1=new Account(Name='comp',RecordTypeId=RecTypeCompany);  // Parent Institution is blank
     insert company1;
     Account fmf2=new Account(Name='fmf2',parentId=company1.id,RecordTypeId=RecTypeFMF);  // Parent Institution is company
    try
    {
        insert fmf2;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
    insert fm1;
    
    Account fmf3=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
    insert fmf3;
    fmf3.parentId=null;
    try
    {    update fmf3;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    fmf3.parentId=company1.id;
    try
    {    update fmf3;
    }
    catch(Exception e)
    {
         System.assert(ApexPages.hasMessages()==True);
    }
    
    
    
    
}
    

}