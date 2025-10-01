public with sharing class FundSelectionDistribution {

    public Sobject obj;
    public FundSelectionDistribution(ApexPages.StandardController controller) {
        
        obj = controller.getRecord();
        part = new Partnership__c();
    }

    public PageReference evaluate()
    {
        try
        {    
            if(obj.get('Fund_Name__c') != null){
                 string st = string.valueOf(obj.get('Fund_Name__c'));  
                Fund__c f = new Fund__C(id = st);
                return new PageReference('/apex/createDistribution?scontrolCaching=1&id='+st);
            }
            else{
                return null;
            }
           
        }
        catch(System.NullPointerException e)
        {
            system.assert(e.getMessage().contains('de-reference a null object'));
        }
        catch(System.TypeException e)
        {
            system.assert(e.getMessage().contains('Invalid id'));
        }
        catch(System.StringException e)
        {
            system.assert(e.getMessage().contains('Invalid id'));
        }
        return null;
    }

    public Partnership__c part{get;set;}
    
    public PageReference redirectFun(){   
        return new PageReference('/apex/createDistribution?scontrolCaching=1&id='+part.Fund__c);
    }

    //Test meathod
    public static testMethod void testFundSelectionDistribution()
    {
        Fund__c fnd = new Fund__c(name = 'Test Fund');
        if(Schema.sObjectType.Fund__c.isCreateable()){
          insert fnd;
        }
        
        Fund_Distribution__c fndDistribution= new Fund_Distribution__c(Fund_Name__c =fnd.id);
        if(Schema.sObjectType.Fund_Distribution__c.isCreateable()){
          insert fndDistribution;
        }
        
        Fund__c fnd1=[select name from Fund__c where id=:fnd.id];
        System.assertEquals('Test Fund',fnd1.name);
        ApexPages.StandardController sc = new ApexPages.StandardController(fndDistribution);
        FundSelectionDistribution f = new FundSelectionDistribution(sc);
        //f.evaluate();
        ApexPages.currentPage().getParameters().put('retURL','hksdfsld');
        f.evaluate();
        f.part = new Partnership__c(name='Test Part', Fund__c = fnd.id);
        if(Schema.sObjectType.Partnership__c.isCreateable()){
          insert f.part;
       }
        ApexPages.currentPage().getParameters().put('retURL',fnd.id);
        f.evaluate();
        ApexPages.currentPage().getParameters().put('retURL',f.part.id);
        f.evaluate();
        f.redirectFun();
    }
}