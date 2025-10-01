/*********************************************************************************
** Description : This is used for Save Account Associations Setup Setting.
** Throws : NA
** Calls : NA
** Test Class : NA
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)       Author  Description of Action
** 1.0     2016-07-21             Pramod  
*********************************************************************************/
public with Sharing class cls_ProductSetting{
    public list<ProductSetting__c> customsettingobj{get;set;}
    public ProductSetting__c ObjInstitution_FM{get;set;}
    public ProductSetting__c ObjInstitution_FMF{get;set;}
    public ProductSetting__c ObjCompany_FM{get;set;}
    public ProductSetting__c ObjCompany_FMF{get;set;}
    public ProductSetting__c ObjFundraising_FM{get;set;}
    public ProductSetting__c ObjFundraising_FMF{get;set;}
    public String strPageName{get;set;}    
    public Boolean isUserSystemAdmin{get;set;} 
   
    public cls_ProductSetting(){
        
        try{            
            ObjInstitution_FM=ProductSetting__c.getInstance('InstitutionwithFM');
            ObjInstitution_FMF=ProductSetting__c.getInstance('InstitutionwithFMF');
            ObjCompany_FM=ProductSetting__c.getInstance('CompanywithFM');
            ObjCompany_FMF=ProductSetting__c.getInstance('CompanywithFMF');
            ObjFundraising_FM=ProductSetting__c.getInstance('FundraisingwithFM');
            ObjFundraising_FMF=ProductSetting__c.getInstance('FundraisingwithFMF');
            Profile usrProfile = new Profile();
            if(Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible())
                usrProfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
            if(usrProfile!=null){
                if(usrProfile.name=='System Administrator'){                    
                    isUserSystemAdmin = true; 
                }
            }  
        }catch(Exception ex){           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Constructor : '+ex)); 
        }
    }
    
    /*
    @Description: Method called on click Edit to redirect page.   
    */ 
    public PageReference openeditpage(){ 
        PageReference pageRef= new PageReference('/apex/ProductSetting');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    /*
    @Description: Method called on click page name to redirect page.   
    */ 
    public PageReference redirectpage() {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
    @Description: Method called on click save.
    @Parameter1: variable ObjInstitution_FM,ObjInstitution_FMF,ObjCompany_FM,ObjFundraising_FMF is used for update setup setting.
    */ 
    public PageReference save(){        
        PageReference pageRef= new PageReference('/apex/ProductSetting');
        try{
            
            if(Schema.sObjectType.ProductSetting__c.isUpdateable())
            {
                update ObjInstitution_FM;
                update ObjInstitution_FMF;
                update ObjCompany_FM;
                update ObjCompany_FMF;
                update ObjFundraising_FM;
                update ObjFundraising_FMF;
            }
            
            pageRef.setredirect(true);
            
        }catch(Exception ex){           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in save method : '+ex)); 
        }
        return pageRef;
    }
    
    /*
    @Description: Method called on click cancel.    
    */ 
    public PageReference cancel(){ 
        PageReference pageRef= new PageReference('/apex/ProductSetting');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    /*
    @Description: Test Method used for code coverage.    
    */
    public static testmethod void testmethodforcls_productsetting(){        
        cls_ProductSetting clsobj1=new cls_ProductSetting();
        clsobj1.cancel();        
        clsobj1.ObjInstitution_FM=new ProductSetting__c(name='test1',status__c=true);
        
        if(Schema.sObjectType.ProductSetting__c.isCreateable()){
            insert clsobj1.ObjInstitution_FM;
        }
        
        clsobj1.ObjInstitution_FMF=new ProductSetting__c(name='test2',status__c=true);
        
        if(Schema.sObjectType.ProductSetting__c.isCreateable()){
            insert clsobj1.ObjInstitution_FMF;
        }
        
        clsobj1.ObjCompany_FM=new ProductSetting__c(name='test3',status__c=true);
        
        if(Schema.sObjectType.ProductSetting__c.isCreateable()){
            insert clsobj1.ObjCompany_FM;
        }
        
        clsobj1.ObjCompany_FMF=new ProductSetting__c(name='test4',status__c=true);
        
        if(Schema.sObjectType.ProductSetting__c.isCreateable()){
            insert  clsobj1.ObjCompany_FMF;
        }
        
        clsobj1.ObjFundraising_FM=new ProductSetting__c(name='test5',status__c=true);
        
        if(Schema.sObjectType.ProductSetting__c.isCreateable()){
            insert clsobj1.ObjFundraising_FM;
        }
        
        clsobj1.ObjFundraising_FMF=new ProductSetting__c(name='test6',status__c=true);
        
        if(Schema.sObjectType.ProductSetting__c.isCreateable()){
            insert clsobj1.ObjFundraising_FMF;      
        }
        
        clsobj1.save();
        clsobj1.openeditpage();
        System.assert(ApexPages.hasMessages()==false);
    }

}