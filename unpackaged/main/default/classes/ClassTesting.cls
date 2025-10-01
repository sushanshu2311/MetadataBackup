@isTest
private class ClassTesting {
    static String sCompanyApi =  CommonUtility.chkmasterLookupInPiplineAPI();
	// Changes Today 01/10/2025 1
    //Added for security review
    public static testMethod void myUnitTestQfp() {
        Test.startTest();
        {
            // TO DO: implement unit test
            String RecInst = '';
            String RecLim = '';
            String RecCom = '';
            RecordType[] Rec = [Select id,Name,SObjectType from RecordType];
            for(RecordType R:Rec)
            {
                if(R.Name == 'Institution' && R.SObjectType == 'Account')
                {
                    RecInst = R.Id;
                }
                if(R.Name == 'Limited Partner' && R.SObjectType == 'Account')
                {
                    RecLim = R.Id;
                }
                if(R.Name == 'Company' && R.SObjectType == 'Account')
                {
                    RecCom = R.Id;
                }
             }
            Account inst = new Account(RecordTypeId = RecInst,Familiar_Name__c='@isTest1',Name='@isTest1');
            insert inst;
            Account inst2 = new Account(RecordTypeId = RecInst,Familiar_Name__c='@isTest2',Name='@isTest2');
            insert inst2;
            Account inst3 = new Account(RecordTypeId = RecInst,Familiar_Name__c='@isTest3',Name='@isTest3');
            insert inst3;
            Account limpart = new Account(RecordTypeId = RecLim,Name='@isTest',ParentId = inst.Id);
            insert limpart;
            Account com = new Account(RecordTypeId = RecCom,Name='@isTest');
            insert com;
        
            Fund__c fund = new Fund__c(Name = '@isTest',Investment_Category__c = 'Fund');
            insert fund;
            Fund__c coinv = new Fund__c(Name = '@isTest',Investment_Category__c = 'Co-Investment');
            insert coinv;
            
            Advisor_Involvement__c ai1 = new  Advisor_Involvement__c(Legal_name__c = inst.Id,Fund__c = fund.Id);
            insert ai1;
                System.assert(ai1.Id != null);
            Advisor_Involvement__c ai2 = new  Advisor_Involvement__c(Legal_name__c = limpart.Id,Fund__c = fund.Id);
            try
            {
                insert ai2;
            }
            catch(Exception e)
            {
                System.assert(ai2.Id == null);
            }
            Advisor_Involvement__c ai3 = new  Advisor_Involvement__c(Legal_name__c = com.Id,Fund__c = fund.Id);
            try
            {
                insert ai3;
            }
             catch(Exception e)
            {
                System.assert(ai3.Id == null);
            }
            try
            {
               delete fund;
            }
            catch(Exception e)
            {
                System.assert(fund.Id != null);
            }
            
            Contact concre = new Contact(LastName = 'Manjot@isTest' ,AccountId = inst.Id);
            insert concre;
            System.assert(concre.Id != null);
            Contact concre2 = new Contact(LastName = 'Manjot@isTest' ,AccountId = inst2.Id);
            insert concre2;
               
            Partnership__c part = new Partnership__c(Name='Part',Fund__c=fund.Id);
            insert part;
            Fund_Drawdown__c fdd = new Fund_Drawdown__c(Fund_Name__c = fund.id);
            insert fdd;
            Fund_Distribution__c fd = new Fund_Distribution__c(Fund_Name__c = fund.id);
            insert fd;
            try
            {
                delete inst;
            }
             catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            try
            {
                delete fund;    // For all The related Objects to Fund.
            }
             catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
        }
        Test.stopTest();
    }

    public static testMethod void testAll1()
    {
        Test.startTest();
        {
            String RInst='';
            String RLim='';
            String RCom='';
            String RII = '';//Test class coverage fix by LK on 2024-11-06
            
            RecordType[] R1=[Select Id,Name,SObjectType from RecordType];
            for(RecordType R:R1)
            {
              if(R.Name=='Institution' && R.SObjectType=='Account')
              {
                 RInst=R.Id;
              }
              
              if(R.Name=='Limited Partner' && R.SObjectType=='Account')
              {
                 RLim=R.Id;
              }
              if(R.Name=='Company' && R.SObjectType=='Account')
              {
                 RCom=R.Id;
              }
                //Test class coverage fix by LK on 2024-11-06
              if(R.Name=='Individual Investor' && R.SObjectType=='Account')
              {
                 RII=R.Id;
              }
            }
            
            Account pacc=new Account(RecordTypeId=RInst,Familiar_Name__c='Test 123',Name='Test 123');       
            insert pacc;
            String ParentId=pacc.Id;
            
            Account lacc=new Account(RecordTypeId=RLim,Familiar_Name__c='Test 1234',Name='Test 1234',parentId=ParentId);     
            insert lacc;
            String LimId=lacc.Id;
            
            Fund__c fnd=new Fund__c(Name='Fund 123',Investment_Category__c='Fund');
            insert fnd;
            String FId=fnd.Id;
             
            Fund__c fnd1=new Fund__c(Name='Fund 234',Investment_Category__c='Co-investment');
            insert fnd1;
            String FId1=fnd1.Id;
             
            Partnership__c P1=new  Partnership__c(Name='TestPart', Fund__c=FId);
            insert P1;
            String PId=P1.Id;
            
            Partnership__c P2=new  Partnership__c(Name='TestPart',Fund__c=FId1);
            insert P2;
            String PId1=P2.Id;
            
            Account port=new Account(RecordTypeId=RCom,Name='Test 1234');
            insert port;
            
            Commitment__c c=new Commitment__c(Limited_Partner__c=LimId,Partnership__c=PId,Commitment_Amount_nearest__c = 70000000);
            insert c;
             
            Commitment__c c1=new Commitment__c(Limited_Partner__c=LimId,Partnership__c=PId1, Portfolio_Company__c=port.Id,Commitment_Amount_nearest__c = 20000000);
            insert c1;
			//Test class coverage fix by LK on 2024-11-06
			Account iiAcc=new Account(RecordTypeId=RII,Familiar_Name__c='Test 4',Name='Test 4');       
            insert iiAcc;
            Fundraising__c fundr= new Fundraising__c(Name='TestFundraising',Fund_Name__c=FId1, Legal_Name__c=iiAcc.id);
            insert fundr;

            Pipeline__c pline = new Pipeline__c(name='TestPipline', stage__c='Idea Generation');
            pline.put(sCompanyApi, port.id);
            insert pline;
            
            Advisor_Involvement__c AdIv = new Advisor_Involvement__c(Legal_Name__c=pacc.id , Pipeline__c=pline.id);
            insert AdIv;

            Quarterly_Financial_Performance__c qfpTemp = new Quarterly_Financial_Performance__c(Company__c=port.id, Quarter__c='Q1', Quarter_end_Date__c=System.today(), Fiscal_Year_end__c=System.today());
            insert qfpTemp;

            Advisor__c prt=new Advisor__c(Advisor__c=LimId, Client__c=LimId,Role__c = 'Legal',Reverse_Role__c = 'Client');

            try
            {
                delete pline;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            try
            {
                insert prt;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            prt.Advisor__c=ParentId;
            prt.Client__c=ParentId;
            try
            {
                insert prt;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            c1.Commitment_Amount_nearest__c=300000000;
            update c1;
             
            pacc.Total_Fund_Commitments__c = c.Commitment_Amount_nearest__c;
            update pacc;
            
            lacc.Total_Fund_Commitments__c = c.Commitment_Amount_nearest__c;
            update lacc;
                    
            P1.Total_Commitments__c = c.Commitment_Amount_nearest__c;
            update P1;

            try
            {
                delete port;
            }
            catch(Exception e)
            {
                 System.assert(ApexPages.hasMessages()==True);
            }
            try
            {
                delete pacc;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            Database.DeleteResult delAd = Database.delete(AdIv);
            System.assert(delAd.isSuccess() ==true);    
            
            try
            {
                Database.DeleteResult delpipe = Database.delete(pline);
                
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            Database.DeleteResult delfundr = Database.delete(fundr);
            System.assert(delfundr.isSuccess() ==true);

            Database.DeleteResult delc = Database.delete(c);
            System.assert(delc.isSuccess() ==true);
            /*
            Database.DeleteResult delc1 = Database.delete(c1);
            System.assert(delc1.isSuccess() ==true);

            Database.DeleteResult delqfpTemp = Database.delete(qfpTemp);
            System.assert(delqfpTemp.isSuccess() ==true);
            
            Database.DeleteResult delport = Database.delete(port);
            System.assert(delport.isSuccess() ==true);

            Database.DeleteResult delp1 = Database.delete(p1);
            System.assert(delp1.isSuccess() ==true);

            Database.DeleteResult delp2 = Database.delete(p2);
            System.assert(delp2.isSuccess() ==true);

            Database.DeleteResult dellacc = Database.delete(lacc);
            System.assert(dellacc.isSuccess() ==true);

            Database.DeleteResult delpacc = Database.delete(pacc);
            System.assert(delpacc.isSuccess() ==true);
            */
        }
        Test.stopTest();
    }

    public static testMethod void testAll2()
    {
        String RInst='';
        String RLim='';
        String RCom='';
        Test.startTest();
        {
            RecordType[] R1=[Select Id , Name,SObjectType from RecordType];
            for(RecordType R:R1)
            {
              if(R.Name=='Institution' && R.SObjectType=='Account')
              {
                 RInst=R.Id;
              }
              
              if(R.Name=='Limited Partner' && R.SObjectType=='Account')
              {
                 RLim=R.Id;
              }
              if(R.Name=='Company' && R.SObjectType=='Account')
              {
                 RCom=R.Id;
              }
              
            }
            
            Account pacc=new Account(RecordTypeId=RInst,Familiar_Name__c='Test 123',Name='Test 123');       
            insert pacc;
            String ParentId=pacc.Id;
            
            Account pacc1=new Account(RecordTypeId=RInst,Familiar_Name__c='Test 234',Name='Test 234');
            insert pacc1;

            Account port=new Account(RecordTypeId=RCom,Name='Port Comp');
            insert port;

            Contact con = new Contact(lastname = 'Tester', AccountID=ParentId);
            insert con;
            
            Account lacc=new Account(RecordTypeId=RLim,Familiar_Name__c='Test 1234',Name='Test 1234',parentId=ParentId);     
            insert lacc;
            String LimId=lacc.Id;

            Account lacc1=new Account(RecordTypeId=RLim,Familiar_Name__c='Test 34',Name='Test 34',parentId=ParentId);     
            insert lacc1;

            try
            {
                delete pacc;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
             
            Fund__c fnd=new Fund__c(Name='Fund 123',Investment_Category__c='Fund');
            insert fnd;
            String FId=fnd.Id;
             
            Partnership__c P1=new  Partnership__c(Name='TestPart1', Fund__c=FId);
            insert P1;
            String PId=P1.Id;

            Partnership__c P2=new  Partnership__c(Name='TestPart2', Fund__c=FId);
            insert P2;

            Fund__c fnd1=new Fund__c(Name='Fund 234 Co',Investment_Category__c='Co-investment');
            insert fnd1;

            Partnership__c P3=new  Partnership__c(Name='TestPartCo', Fund__c=fnd1.Id);
            insert P3;
        }
        Test.stopTest();
   
    }

    public static testMethod void testAll3()
    {
        Test.startTest();
        {
            String RInst='';
            String RLim='';
            String RCom='';
            String RII='';//Test class coverage fix by LK on 2024-11-06
            
            RecordType[] R1=[Select Id,Name,SObjectType from RecordType];
            for(RecordType R:R1)
            {
              if(R.Name=='Institution' && R.SObjectType=='Account')
              {
                 RInst=R.Id;
              }
              
              if(R.Name=='Limited Partner' && R.SObjectType=='Account')
              {
                 RLim=R.Id;
              }
              if(R.Name=='Company' && R.SObjectType=='Account')
              {
                 RCom=R.Id;
              }
                //Test class coverage fix by LK on 2024-11-06
              if(R.Name=='Individual Investor' && R.SObjectType=='Account')
              {
                 RII=R.Id;
              }
              
            }

             //****************Trggr AutoCreatePartners.***************
            Account pacc=new Account(RecordTypeId=RInst,Familiar_Name__c='Test 123',Name='Test 123');       
            insert pacc;
          
            String ParentId=pacc.Id;

            Account pacc1=new Account(RecordTypeId=RInst,Familiar_Name__c='Test 3',Name='Test 3');       
            insert pacc1;

            Account lacc=new Account(RecordTypeId=RLim, ParentId=pacc.Id, Familiar_Name__c='LTest 123', Name='LTest 123');       
            insert lacc;

            Account port = new Account(Name='Prtfolio', RecordTypeId=RCom);
            insert port;

            Contact con=new Contact(FirstName='Test',LastName='Con', AccountId=pacc1.id);
            insert con;
             
            Fund__c fnd=new Fund__c(Name='Fund 123',Investment_Category__c='Fund');
            insert fnd;
            String FId=fnd.Id;

            Fund__c fnd1=new Fund__c(Name='Fund 234',Investment_Category__c='Co-investment');
            insert fnd1;
            String FId1=fnd1.Id;

            Partnership__c P1=new  Partnership__c(Name='TestPart', Fund__c=FId);
            insert P1;
            String PId=P1.Id;
             
            //Test class coverage fix by LK on 2024-11-06
            Account iiAcc=new Account(RecordTypeId=RII,Familiar_Name__c='Test 4',Name='Test 4');       
            insert iiAcc;
            Fundraising__c fundr= new Fundraising__c(Name='TestFundraising',Fund_Name__c=FId, Legal_Name__c=iiAcc.id);//Test class coverage fix by LK on 2024-11-06
            insert fundr;
            
            Fundraising_Contact__c conRole=new Fundraising_Contact__c(Fundraising__c=fundr.Id,Contact__c=con.Id,Role__c='Advisor', Institution__c=con.AccountId);
            insert conRole;
            conRole.Role__c='Client';
            update conRole;
            
            conRole.Institution__c=lacc.id;
            try
            {
                update conRole;
            }
            catch(Exception e)

            {
                System.assert(ApexPages.hasMessages()==True);
            }

            fundr.Legal_Name__c = pacc1.id;
            try
            {
                update fundr;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            Advisor__c prt=new Advisor__c(Advisor__c=pacc1.id, Client__c=pacc.id, Role__c = 'Legal',Reverse_Role__c = 'Client');
            insert prt;
            System.assert(prt.Id!=null);

            Advisor__c prt1=new Advisor__c(Advisor__c=pacc1.id, Client__c=pacc.id, Role__c = 'Advisor',Reverse_Role__c = 'Client');
            insert prt1;
            System.assert(prt1.Id!=null);
            
            prt1.Role__c = 'Legal';
            try
            {
                update prt1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            prt.Advisor__c = lacc.id;
            try
            {
                update prt;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            Fundraising_Contact__c CR1 = [Select Contact__c ,Institution__c  from Fundraising_Contact__c where Id=: conRole.Id];
            
            Fundraising__c fundr1= new Fundraising__c(Name='TestFundraising1', Fund_Name__c= FId, Legal_Name__c=lacc.id, Portfolio_Company__c=port.id);

            try
            {
                insert fundr1;
            } 
            catch(Exception e)
            {
               System.assert(ApexPages.hasMessages()==True);
            }
            
            fundr1.Fund_Name__c = FId1;
            fundr1.Portfolio_Company__c=null;
            try
            {
                insert fundr1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            fundr1.Portfolio_Company__c=lacc.id;
            try
            {
                insert fundr1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            fundr1.Fund_Name__c = null;
            try
            {
                insert fundr1;
            }
            catch(Exception e)
            {
               System.assert(ApexPages.hasMessages()==True);
            }
            fundr1.Fund_Name__c = FId1;
            fundr1.Portfolio_Company__c=port.id;
            fundr1.Legal_Name__c=iiAcc.id;//Test class coverage fix by LK on 2024-11-06
            upsert fundr1;
            
            fundr1.Portfolio_Company__c=null;
            try
            {
                update fundr1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            fundr1.Portfolio_Company__c=lacc.id;
            try
            {
                update fundr1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            try
            {
                delete pacc1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            Account lacc1=new Account(RecordTypeId=RLim, ParentId=pacc.Id, Familiar_Name__c='LTest 1', Name='LTest 1');
            insert lacc1;
            lacc1.ParentId = lacc.Id;
            try
            {
                update lacc1;
            }
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            try
            {
                delete pacc;
            } 
            catch(Exception e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            //delete CR1;
            delete prt1;
            delete prt;
            //delete con;
            delete fundr1;
            delete fundr;
            delete lacc1;
            delete lacc;
            //delete pacc;
             //*******************************************************  
            //Transfer Trigger
        }
        Test.stopTest();
    }    

    // Transfer Code
    public static testMethod void testAll4()
    {
        String RInst='';
        String RLim='';
        String RCom='';
       
            RecordType[] R1=[Select Id,Name,SObjectType from RecordType];
            for(RecordType R:R1)
            {
              if(R.Name=='Institution' && R.SObjectType=='Account')
              {
                 RInst=R.Id;
              }
              
              if(R.Name=='Limited Partner' && R.SObjectType=='Account')
              {
                 RLim=R.Id;
              }
              if(R.Name=='Company' && R.SObjectType=='Account')
              {
                 RCom=R.Id;
              }
              
            }
            
            Account pacc=new Account(RecordTypeId=RInst,Familiar_Name__c='Test 123',Name='Test 123');       
            insert pacc;
            String ParentId=pacc.Id;
            
            Account port=new Account(RecordTypeId=RCom,Name='Port Comp');
            insert port;

            Account lacc=new Account(RecordTypeId=RLim,Familiar_Name__c='Test 1234',Name='Test 1234',parentId=ParentId);     
            insert lacc;
            String LimId=lacc.Id;

            Account lacc1=new Account(RecordTypeId=RLim,Familiar_Name__c='Test 34',Name='Test 34',parentId=ParentId);     
            insert lacc1;

            Fund__c fnd=new Fund__c(Name='Fund 123',Investment_Category__c='Fund');
            insert fnd;
            String FId=fnd.Id;
             
            Partnership__c P1=new  Partnership__c(Name='TestPart1', Fund__c=FId);
            insert P1;
            String PId=P1.Id;

            Partnership__c P2=new  Partnership__c(Name='TestPart2', Fund__c=FId);
            insert P2;

            Fund__c fnd1=new Fund__c(Name='Fund 234 Co',Investment_Category__c='Co-investment');
            insert fnd1;

            Partnership__c P3=new  Partnership__c(Name='TestPartCo', Fund__c=fnd1.Id);
            insert P3;

            Commitment__c c=new Commitment__c(Limited_Partner__c=LimId,Partnership__c=PId,Commitment_Amount_nearest__c = 70000000);
            insert c;

            Commitment__c c1=new Commitment__c(Limited_Partner__c=port.id,Partnership__c=P3.Id,Commitment_Amount_nearest__c = 70000000, Portfolio_Company__c=port.id);
            try
            {
                insert c1;
            }
            catch(DMLException e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            c1.Portfolio_Company__c = LimId;
            try
            {
                insert c1;
            }
            catch(DMLException e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            Transfer__c OT1 = new Transfer__c(Commitment_Name__c=c.Id, Transfer_Amount_nearest__c=10000000, Transfer_to_Limited_Partner__c=lacc.Id, Transfer_to_Partnership__c=P2.Id, Transfer_Date__c=System.Today());
            insert OT1;

            try
            {
                delete c;
            }
            catch(DMLException e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            Commitment__c newCmtId = [select id from Commitment__c where id in (select New_Commitment__c from Transfer__c where id=:OT1.id)];
            try
            {
                delete newCmtId;
            }
            catch(DMLException e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }

            Transfer__c OT3 = new Transfer__c(Commitment_Name__c=newCmtId.Id, Transfer_to_Limited_Partner__c=lacc1.Id, Transfer_to_Partnership__c=P2.Id, Transfer_Date__c=System.Today());
            OT3.Transfer_Amount_nearest__c=10000;
            insert OT3;

            try
            {
                delete OT1;
            }
            catch(DMLException e)
            {
                System.assert(ApexPages.hasMessages()==True);
            }
            
            
            Test.startTest();
        {
            delete OT3;
            Database.DeleteResult deltrans = Database.delete(OT1);
            System.assert(deltrans.isSuccess() ==true);
              
            Database.DeleteResult delc = Database.delete(c);
            System.assert(delc.isSuccess() ==true);
          
            Database.DeleteResult delp1 = Database.delete(p1);
            System.assert(delp1.isSuccess() ==true);
         
            Database.DeleteResult delp2 = Database.delete(p2);
            System.assert(delp2.isSuccess() ==true);
         
           
        }
        Test.stopTest();
        
        Database.DeleteResult delfnd = Database.delete(fnd);
        System.assert(delfnd.isSuccess() ==true);
      
        Database.DeleteResult dellacc1 = Database.delete(lacc1);
        System.assert(dellacc1.isSuccess() ==true);
   
        Database.DeleteResult dellacc = Database.delete(lacc);
        System.assert(dellacc.isSuccess() ==true);

        Database.DeleteResult delpacc = Database.delete(pacc);
        System.assert(delpacc.isSuccess() ==true);
         
    }

    // Distribution Test Meathods
    public static testMethod void testAll5()
    {
        RecordType[] RT = [select Name from Recordtype where SObjectType='Account'];
        Map<String, ID> mapRT = new Map<String, ID>();
        for(RecordType r : RT)
            mapRT.put(r.Name, r.id);
        Account Inst = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        insert Inst;
        Account LP = new Account(name='LP', parentId=Inst.id, recordTypeId=mapRT.get('Limited Partner'));
        insert LP;
        Fund__c fnd = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        insert fnd;
        Partnership__c part = new Partnership__c(name='Test Part', Fund__c=fnd.id);
        insert part;
        Commitment__c cmt1 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        insert cmt1;
        Commitment__c cmt2 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        insert cmt2;

        // Distribution Creation.
        ApexPages.StandardController sc = new ApexPages.StandardController(fnd);
        createDistribution c = new createDistribution(sc);
        c.capRecalled = true;
        c.SetInD();
        c.getInvestorDistribution();
        c.capReturnSummary = 1.2;
        c.DividendSummary = 0.56;
        c.reGainSummary = 0.12;
        c.othProceedsSummary = 0.12;
        c.saveInvestorDisrtibutions();    // Save Successfully.
        Fund_Distribution__c tempFD0 = c.fund_Distribution;
        
        sc = new ApexPages.StandardController(fnd);
        createDistribution c0 = new createDistribution(sc);
        c0.capRecalled = true;
        c0.SetInD();
        c0.getInvestorDistribution();
        c0.capReturnSummary = 1.2;
        c0.DividendSummary = 0.56;
        c0.reGainSummary = 0.12;
        c0.othProceedsSummary = 0.12;
        c0.saveInvestorDisrtibutions();    // Save Successfully.
        Fund_Distribution__c tempFD1 = c0.fund_Distribution;
        List<Investor_Distribution__c> invd = [select id, name, Commitment__c from Investor_Distribution__c where Fund_Distribution__c=:tempFD1.id];

        tempFD0.Fund_Name__c = null;
        try
        {
            update tempFD0;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Value once set cannot be changed'), 'Fund Name cannot be Changed.');
        }

        invd[0].Capital_Return__c = 1.50;
        update invd[0];
        
        // Distribution Deletion.
        delete tempFD0;
        delete tempFD1;
        
        List<Fund_Distribution__c> lst = new List<Fund_Distribution__c>{tempFD0,tempFD1};
        try{
            undelete lst;
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Fund Distribution cannot be mass undeleted.'), 'Multiple Distribution cannot be undeleted.');
        }

        Fund_Distribution__c fdd = new Fund_Distribution__c();
        try
        {
            insert fdd;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Please select a Fund Name'), 'Fund Name cannot is required field.');
        }
    }

    // Drawdown Test Meathods
    public static testMethod void testAll6()
    {
        RecordType[] RT = [select Name from Recordtype where SObjectType='Account'];
        Map<String, ID> mapRT = new Map<String, ID>();
        for(RecordType r : RT)
            mapRT.put(r.Name, r.id);
        Account Inst = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        insert Inst;
        Account LP = new Account(name='LP', parentId=Inst.id, recordTypeId=mapRT.get('Limited Partner'));
        insert LP;
        Fund__c fnd = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        insert fnd;
        Partnership__c part = new Partnership__c(name='Test Part', Fund__c=fnd.id);
        insert part;
        Commitment__c cmt1 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        insert cmt1;
        Commitment__c cmt2 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        insert cmt2;

        // Drawdown Creation.
        ApexPages.StandardController sc = new ApexPages.StandardController(fnd);
        createDrawdown c1 = new createDrawdown(sc);
        c1.AmountSelected = true;    // For Amount in Currency.
        c1.fund_Drawdown.Due_Date__c=System.today();
        c1.fund_Drawdown.Call_Date__c=System.today();
        c1.AmountSelected = false;    // For Amount acc to percentage selected.
        c1.actionCapitalCalls();
        c1.getcapitalCalls();
        c1.total_capitalAmount = 1.2;
        c1.total_managementFee = 0.56;
        c1.total_otherFee = 0.12;
        c1.saveCapitalCalls();    // Save Successfully.
        Fund_Drawdown__c tempFD2 = c1.fund_Drawdown;

        sc = new ApexPages.StandardController(fnd);
        createDrawdown c2 = new createDrawdown(sc);
        c2.AmountSelected = true;    // For Amount in Currency.
        c2.fund_Drawdown.Due_Date__c=System.today();
        c2.fund_Drawdown.Call_Date__c=System.today();
        c2.AmountSelected = false;    // For Amount acc to percentage selected.
        c2.actionCapitalCalls();
        c2.getcapitalCalls();
        c2.total_capitalAmount = 1.2;
        c2.total_managementFee = 0.56;
        c2.total_otherFee = 0.12;
        c2.saveCapitalCalls();    // Save Successfully.
        Fund_Drawdown__c tempFD3 = c2.fund_Drawdown;
        List<Capital_Call__c> cc = [select id, name, Commitment__c from Capital_Call__c where Fund_Drawdown__c=:tempFD3.id];
        
        tempFD3.Fund_Name__c = null;
        try{
            update tempFD3;
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Value once set cannot be changed'), 'Fund Name cannot be Changed.');
        }

        cc[0].Capital_Amount__c = 1.50;
        update cc[0];

       // Drawdown Deletion.
        delete tempFD2;
        delete tempFD3;
        
        List<Fund_Drawdown__c> lst = new List<Fund_Drawdown__c>{tempFD2,tempFD3};
        try{
            undelete lst;
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Fund Drawdown cannot be mass undeleted.'), 'Multiple Drawdown cannot be undeleted.');
        }
        
        Fund_Drawdown__c fdd = new Fund_Drawdown__c();
        try
        {
            insert fdd;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Please select a Fund Name'), 'Fund Name cannot is required field.');
        }
    }

    // FOFT Trigger and Fund Manager - Fund Manager's Fund Test Meathod
    public static testMethod void testAll7()
    {
        RecordType[] RT = [select Name from Recordtype where SObjectType='Account'];
        Map<String, ID> mapRT = new Map<String, ID>();
        for(RecordType r : RT)
            mapRT.put(r.Name, r.id);
        Account Inst = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        insert Inst;
        Fund__c fnd = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        insert fnd;
        Fund_of_Funds_Transaction__c foft = new Fund_of_Funds_Transaction__c(Fund__c = fnd.id, Fund_Manager_s_Fund__c = Inst.id);
        try
        {
            insert foft;
        }
        Catch(DMLException e)
        {
          
          System.assert(ApexPages.hasMessages()==True);
        
         
          
        }
        
        Account fM = new Account(name='Fund Manager',recordTypeId=mapRT.get('Fund Manager'));
        insert fM;
        
        Account fMF = new Account(name='Fund Manager’s Fund',recordTypeId=mapRT.get('Fund Manager’s Fund'), ParentId = fM.id);
        insert fMF;
        
        Contact con = new Contact(lastname='Test Con', AccountId = fM.id);
        insert con;
        delete con;
        delete fMF;
        
        try
        {
            delete fM;
        }
        Catch(DMLException e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
        Account Insts = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        insert Insts;
        Account Insts1 = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        insert Insts1;
        Account LPs = new Account(name='LP', parentId=Insts1.id, recordTypeId=mapRT.get('Limited Partner'));
        insert LPs;
        Account LPs1 = new Account(name='LP', parentId=Insts.id, recordTypeId=mapRT.get('Limited Partner'));
        insert LPs1;
        Fund__c fnds = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        insert fnds;
        Partnership__c parts = new Partnership__c(name='Test Part', Fund__c=fnd.id);
        insert parts;
        Commitment__c cmt1s = new Commitment__c(Limited_Partner__c=LPs.id, Partnership__c=parts.id, Commitment_Amount_nearest__c=2000000);
        try
        {
        insert cmt1s;
        }
        catch(Exception e)
        {
        System.assert(cmt1s.Id != null);
        }
         Transfer__c OT1s = new Transfer__c(Commitment_Name__c=cmt1s.Id, Transfer_Amount_nearest__c=1000, Transfer_to_Limited_Partner__c=LPs1.Id, Transfer_to_Partnership__c=parts.Id, Transfer_Date__c=System.Today());
        insert OT1s;
         try
        {
        insert cmt1s;
        }
        catch(Exception e)
        {
        System.assert(OT1s.Id != null);
        }
        try
        {
            delete parts;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
         Account Insts2 = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        insert Insts2;
        Account LPs2 = new Account(name='LP', parentId=Insts2.id, recordTypeId=mapRT.get('Limited Partner'));
        insert LPs2;
        Fund__c fnds2 = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        insert fnds2;
        Partnership__c parts2 = new Partnership__c(name='Test Part', Fund__c=fnds2.id);
        insert parts2;
        Commitment__c cmt1s2 = new Commitment__c(Limited_Partner__c=LPs2.id, Partnership__c=parts2.id, Commitment_Amount_nearest__c=3000000);
        try
        {
        insert cmt1s2 ;
        }
        catch(Exception e)
        {
        System.assert(cmt1s2.Id != null);
        }
        
        try
        {
            delete parts2;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
        //delete fM; 
    }
}