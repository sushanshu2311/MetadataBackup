@isTest
    private class Test_EmailProspect_Ctlr
    {
        @isTest(onInstall=true)
        static void testApController()
        {
            Marketing_Initiative__c dummyMI=new Marketing_Initiative__c(Name='MI1 test');
            insert dummyMI;
            System.assertEquals('MI1 test', dummyMI.Name); // (PE3.5, SK, 9Aug2017)
            
            ApexPages.currentPage().getParameters().put('id',dummyMI.Id);
            list<Marketing_Initiative__c > lstMI=new List<Marketing_Initiative__c >();
            lstMI.add([Select id,name from Marketing_Initiative__c where id=:dummyMI.Id]);
            EmailProspect_Ctlr Mep_cls= new EmailProspect_Ctlr(new ApexPages.StandardSetController(lstMI));
            string contactIDString='a021a000001brOW,a021a000001brOW';
            Apexpages.currentPage().getParameters().put('selectConId_Id',contactIDString);
            Mep_cls.fundid='fghjdfdj';
            Mep_cls.urlNotExist=true;
            Mep_cls.ErrorStatusInsufficient=true;           
            Mep_cls.proptxtdata='abcdjdfdj';
            Mep_cls.ErrorVal='errabc';
            Mep_cls.MIid='a0036000004lriq';
            Mep_cls.folderId='00l36000000ZMNXAA4';
            
            Mep_cls.ETData();
            Mep_cls.getItems();
            Mep_cls.getfolderListIds();
            Mep_cls.getfolderOtherIds();
            Mep_cls.selectedContact='a0R36000000yXehEAE@@a0R36000000yXehEAE,a0R36000000yXehEAA@@a0R36000000yXehEAA';
            Mep_cls.sendmassmail();
            //Added above 2 lines & commented below code by Lakshya on 2022-02-25 to fix code coverage
            //Mep_cls.MassemailName= 'Test Mass Email';
            /*Mep_cls.selectedContact='a0R36000000yXehEAE@@a0R36000000yXehEAE,a0R36000000yXehEAA@@a0R36000000yXehEAA';
            Mep_cls.isSendingFailed=true;
            Mep_cls.ErrorStatusInsufficient=false;
            Mep_cls.isUse_My_Signature=true;
            Mep_cls.Store_as_an_activity=true;
            Mep_cls.isBCC_Me_On_One=true;
            Mep_cls.isbcc=true;         
            Mep_cls.sendmassmail();
            
            //Mep_cls.MassemailName= 'Test Mass Email';
            Mep_cls.selectedContact='a0R36000000yXehEAE@@a0R36000000yXehEAE,a0R36000000yXehEAA@@a0R36000000yXehEAA';
            Mep_cls.isSendingFailed=true;
            Mep_cls.isUse_My_Signature=true;
            Mep_cls.Store_as_an_activity=true;
            Mep_cls.isBCC_Me_On_One=false;
            Mep_cls.isbcc=true;
            Mep_cls.sendmassmail();
                        
            //Mep_cls.MassemailName= '';
            Mep_cls.selectedContact='a0R36000000yXehEAE@@a0R36000000yXehEAE,a0R36000000yXehEAA@@a0R36000000yXehEAA';
            Mep_cls.isSendingFailed=true;
            Mep_cls.MIid='';
            Mep_cls.isUse_My_Signature=true;
            Mep_cls.ErrorStatusInsufficient=false;
            Mep_cls.Store_as_an_activity=true;
            Mep_cls.isBCC_Me_On_One=true;
            Mep_cls.isbcc=true;
            Mep_cls.isSuccessmsgTrigger=true;
            Mep_cls.sendmassmail();*/
            
            Mep_cls.cancel();
        }
        //Added below test method by Lakshya on 2022-02-25 to improve code coverage of EmailProspect_CtlrBatch batch class
        @isTest
        static void EmailProspect_CtlrBatchTest(){
            Contact con = new Contact();
            con.LastName = 'Dummy Contact';
            con.Email = 'test@gmail.com';
            insert con;
            
            Marketing_Prospect__c mp = new Marketing_Prospect__c();
            mp.Contact__c = con.Id;
            insert mp;
            
            Test.startTest();
            Map<String, String> conIdVsWhatIdMap = new Map<String, String>();
            conIdVsWhatIdMap.put(con.Id, 'a0R36000000yXehEAE');
            Database.executeBatch(new EmailProspect_Ctlr(conIdVsWhatIdMap, 'a0R36000000yXehEAE', false, false, false));
            Test.stopTest();
        }
    }