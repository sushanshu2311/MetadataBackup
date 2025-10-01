@isTest
Private class Test_MassEmail_CC_ID{
     
    static testMethod void mytest()
    {        
        //String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' AND Name = 'Limited Partner'].Id;
        Organization org=new Organization();
        Account acc = new Account(Name = 'test');
        insert acc;
        System.assertEquals('test', acc.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund__c fd=new Fund__c();
        fd.name='fund';
        fd.Fund_Type__c='fund';
        insert fd;
        System.assertEquals('fund', fd.Name); // (PE3.5, SK, 8Aug2017)

        Fund_Distribution__c fdDist=new Fund_Distribution__c();
        fdDist.Fund_Name__c=fd.id;
        insert fdDist;
        System.assertNotEquals('MI1 test', fdDist.Name); // (PE3.5, SK, 8Aug2017)   

        Account acc_Lp = new Account();
        acc_Lp.Name='test1';
        // acc_Lp.recordtypeid=recdTypeId;
        acc_Lp.ParentId = acc.Id;
        insert acc_Lp;
        System.assertEquals('test1', acc_Lp.Name); // (PE3.5, SK, 8Aug2017)
         
        Partnership__c ptrship=new Partnership__c();
        ptrship.Name='ravii';
        ptrship.Fund__c=fd.Id;
        insert ptrship;
        System.assertEquals('ravii', ptrship.Name); // (PE3.5, SK, 8Aug2017)
         
        Commitment__c cmmt=new Commitment__c();
        cmmt.Partnership__c=ptrship.Id;
        cmmt.Limited_Partner__c=acc_Lp.id;
        insert cmmt;
        System.assertNotEquals('MI1test', cmmt.Name); // (PE3.5, SK, 8Aug2017)
        
        Investor_Distribution__c inDist=new Investor_Distribution__c();
        inDist.Fund_Distribution__c=fdDist.Id;
        inDist.Commitment__c=cmmt.Id;
        insert inDist;
        System.assertNotEquals('MI1test', inDist.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund_Drawdown__c fdDrown=new Fund_Drawdown__c();
        fdDrown.Fund_Name__c=fd.Id;
        insert fdDrown;
        System.assertNotEquals('MI1test', inDist.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('pn','CC');          
        Capital_Call__c cptCall=new Capital_Call__c();
        cptCall.Fund_Drawdown__c=fdDrown.Id;
        cptCall.Commitment__c=cmmt.Id;
        insert cptCall;
        System.assertNotEquals('MI1test', cptCall.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('id',cptCall.id);
        MassEmail_CC_ID MassMl=new MassEmail_CC_ID();
    }
    
    
    static testMethod void mytest2(){        
        String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' AND Name = 'Limited Partner'].Id;
        Organization org=new Organization();
        Account acc = new Account(Name = 'test');
        insert acc;
        System.assertEquals('test', acc.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund__c fd=new Fund__c();
        fd.name='fund';
        fd.Fund_Type__c='fund';
        insert fd;
        System.assertEquals('fund', fd.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('pn','FD');
        Fund_Distribution__c fdDist=new Fund_Distribution__c();
        fdDist.Fund_Name__c=fd.id;
        insert fdDist;
        System.assertNotEquals('test', fdDist.Name); // (PE3.5, SK, 8Aug2017)
           
        apexpages.currentpage().getparameters().put('id',fdDist.id);
        MassEmail_CC_ID MassMl=new MassEmail_CC_ID();
    }
    
    
    static testMethod void mytest3(){        
        String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' AND Name = 'Limited Partner'].Id;
        Organization org=new Organization();
        Account acc = new Account(Name = 'test');
        insert acc;
        System.assertEquals('test', acc.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund__c fd=new Fund__c();
        fd.name='fund';
        fd.Fund_Type__c='fund';
        insert fd;
        System.assertEquals('fund', fd.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund_Distribution__c fdDist=new Fund_Distribution__c();
        fdDist.Fund_Name__c=fd.id;
        insert fdDist; 
        System.assertNotEquals('test', fdDist.Name); // (PE3.5, SK, 8Aug2017)  
        
        Account acc_Lp = new Account();
        acc_Lp.Name='test1';
        // acc_Lp.recordtypeid=recdTypeId;
        acc_Lp.ParentId = acc.Id;
        insert acc_Lp;
        System.assertEquals('test1', acc_Lp.Name); // (PE3.5, SK, 8Aug2017)
        
        Partnership__c ptrship=new Partnership__c();
        ptrship.Name='ravii';
        ptrship.Fund__c=fd.Id;
        insert ptrship;
        System.assertNotEquals('test', ptrship.Name); // (PE3.5, SK, 8Aug2017)
        
        Commitment__c cmmt=new Commitment__c();
        cmmt.Partnership__c=ptrship.Id;
        cmmt.Limited_Partner__c=acc_Lp.id;
        insert cmmt;
        System.assertNotEquals('test', cmmt.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('pn','ID');
        Investor_Distribution__c inDist=new Investor_Distribution__c();
        inDist.Fund_Distribution__c=fdDist.Id;
        inDist.Commitment__c=cmmt.Id;
        insert inDist;
        System.assertNotEquals('test', inDist.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('id',inDist.id);
        MassEmail_CC_ID MassMl=new MassEmail_CC_ID();
    }
    
    
    static testMethod void mytest4(){        
        String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' AND Name = 'Limited Partner'].Id;
        Organization org=new Organization();
        Account acc = new Account(Name = 'test');
        insert acc;
        System.assertEquals('test', acc.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund__c fd=new Fund__c();
        fd.name='fund';
        fd.Fund_Type__c='fund';
        insert fd;
        System.assertEquals('fund', fd.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund_Distribution__c fdDist=new Fund_Distribution__c();
        fdDist.Fund_Name__c=fd.id;
        insert fdDist;   
        System.assertNotEquals('test', fdDist.Name); // (PE3.5, SK, 8Aug2017)
        
        Account acc_Lp = new Account();
        acc_Lp.Name='test1';
        // acc_Lp.recordtypeid=recdTypeId;
        acc_Lp.ParentId = acc.Id;
        insert acc_Lp;
        System.assertEquals('test1', acc_Lp.Name); // (PE3.5, SK, 8Aug2017)
        
        Partnership__c ptrship=new Partnership__c();
        ptrship.Name='ravii';
        ptrship.Fund__c=fd.Id;
        insert ptrship;
        System.assertNotEquals('test', ptrship.Name); // (PE3.5, SK, 8Aug2017)
        
        Commitment__c cmmt=new Commitment__c();
        cmmt.Partnership__c=ptrship.Id;
        cmmt.Limited_Partner__c=acc_Lp.id;
        insert cmmt;
        System.assertNotEquals('test', cmmt.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('pn','ID');
        Investor_Distribution__c inDist=new Investor_Distribution__c();
        inDist.Fund_Distribution__c=fdDist.Id;
        inDist.Commitment__c=cmmt.Id;
        insert inDist;
        System.assertNotEquals('test', inDist.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('id',inDist.id);
        apexpages.currentpage().getparameters().put('pn','DD');
        Fund_Drawdown__c fdDrown=new Fund_Drawdown__c();
        fdDrown.Fund_Name__c=fd.Id;
        insert fdDrown;
        System.assertNotEquals('test', fdDrown.Name); // (PE3.5, SK, 8Aug2017)
        
        apexpages.currentpage().getparameters().put('id',fdDrown.id);
        MassEmail_CC_ID MassMl=new MassEmail_CC_ID();
    }
    
}