/*********************************************************************************
    ** Project: PE 3.5
    ** Module Name : CreateDistribution
    ** Description : This opens when "Create Distribution" button gets clicked
    ** Organization : Navatar Group
    ** Revision History:-
    ** Version Date(YYYY-MM-DD)       Author                
    ** 3.5     2016-05-20             Brahmaditya Bhaskar   
*********************************************************************************/
public with sharing class CreateDistribution
{
    public Boolean ShowID {get; set;}
    public String namspace {get;set;} /* variable for namespace of org*/
    private Fund__c fundObj;
    public Fund_Distribution__c fund_Distribution {get; set;}
    public Decimal capReturnSummary{set;get;}
    public Decimal DividendSummary{set;get;}
    public Decimal reGainSummary{set;get;}
    public Decimal othProceedsSummary{set;get;}
    public Boolean idDisable {get;set;}
    public Boolean capRecalled{get;set;}
    public Boolean noCommitments {get; private set;}
    private boolean capRecalled1 = false;
    private List<Partnership__c> partArr;
    public string errormsg{get; set;}
    public String TotalDistributioncurrency{get;set;}
    public Fund__c objFundCC{get;set;}
    public Boolean isshowerroronpage {get;set;}
    public CreateDistribution(ApexPages.StandardController controller) 
    {
        fundObj = (Fund__c)controller.getRecord();
        // Added By Qadir Khan for PE 3.5 .
        if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Capital_Called_mn__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Commitments_USD_mn__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Commitments__c.isAccessible()){
            fundObj = [select Total_Capital_Called_mn__c,Total_Capital_Called__c , Total_Commitments_USD_mn__c, Total_Commitments__c from Fund__c where id=:fundObj.id]; //Use new field Total_Commitments__c instead of Total_Commitment__c
        }
        InvestorDistribution = new List<InD>();
        ShowID = false;
        isshowerroronpage=false;
        namspace = CommonUtility.strNameSpacePrefix;
        fund_Distribution = new Fund_Distribution__c();
        capReturnSummary = 0.00;
        DividendSummary = 0.00;
        reGainSummary = 0.00;
        othProceedsSummary = 0.00;
        idDisable = false;
        capRecalled = false;
        noCommitments = true;
        TotalDistributioncurrency='';
        objFundCC = new Fund__c();
        if(Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isUpdateable())
            objFundCC.Total_Capital_Called__c = 0.00;
        partArr = new List<Partnership__c>();
        if(Schema.sObjectType.Partnership__c.isAccessible() && Schema.sObjectType.Partnership__c.fields.Fund__c.isAccessible() && Schema.sObjectType.Commitment__c.isAccessible() && Schema.sObjectType.Commitment__c.fields.name.isAccessible() && Schema.sObjectType.Commitment__c.fields.Commitment_Amount_nearest__c.isAccessible() && Schema.sObjectType.Commitment__c.fields.Limited_Partner__c.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible()){
            partArr = [Select (Select id, name, Commitment_Amount_nearest__c, Limited_Partner__r.name, Limited_Partner__c  from Commitment__r) from Partnership__c where Fund__c =:fundObj.id];
        }
        for(Partnership__c p : partArr)    // Searching whether fund have any commitment or not?
        {
            for(Commitment__c c : p.Commitment__r)
            {
                noCommitments = false;
                break;
            }
            if(!noCommitments)
                break;
        }
        
    }
    
    public Decimal getTotal_Capital_Called_mn()
    {
        if(fundObj.Total_Capital_Called__c == null && Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isUpdateable())
           fundObj.Total_Capital_Called__c =0.0;
        
        return fundObj.Total_Capital_Called__c;
    }

    private Class InD
    {
        public String capReturn{get;set;}
        public String Dividend{get;set;}
        public String reGain{get;set;}
        public String othProceeds{get;set;}
        public String totDistruibution{get;set;}
        public String commitmentAmount{get;set;}
        public Decimal commAmount{get;set;}
        public ID limPartnerId{get;set;}
        public ID commitmentId{get;set;}
        public String limPartner{get;set;}
        public String commitment{get;set;}       
    }
    
    public void SetInD()
    {   
    
        InvestorDistribution = new List<InD>();
        ShowID = true;
        idDisable = true;
        capRecalled1 = capRecalled;
        Decimal total_Commitment = 0.0; 
        for(Partnership__c p:partArr)
        {
            for(Commitment__c com:p.Commitment__r)
            {
                InD tempFD = new InD();
                tempFD.limPartner = com.Limited_Partner__r.name;
                tempFD.commitment = com.name;
                tempFD.limPartnerId = com.Limited_Partner__c;
                tempFD.commitmentId = com.id;
                tempFD.commAmount = com.Commitment_Amount_nearest__c;
                tempFD.commitmentAmount = String.valueOf(com.Commitment_Amount_nearest__c.setScale(3));
                this.InvestorDistribution.add(tempFD);
                total_Commitment += com.Commitment_Amount_nearest__c;                                   
            }
        }
        
        if(total_Commitment==0)
            total_Commitment = 1.0;
        else
            total_Commitment = fundObj.Total_Commitments__c;         //New code for the use of total_commitment of fund 
         
        for(Integer i=0;i<InvestorDistribution.size();i++)
        {
            InvestorDistribution[i].capReturn = String.valueOf(((capReturnSummary*InvestorDistribution[i].commAmount)/total_Commitment).setScale(3));               // Divide the calculation with Fund's Total_Commitments__c field
            InvestorDistribution[i].Dividend = String.valueOf(((DividendSummary*InvestorDistribution[i].commAmount)/total_Commitment).setScale(3));                 // Divide the calculation with Fund's Total_Commitments__c field
            InvestorDistribution[i].reGain = String.valueOf(((reGainSummary*InvestorDistribution[i].commAmount)/total_Commitment).setScale(3));                     // Divide the calculation with Fund's Total_Commitments__c field
            InvestorDistribution[i].othProceeds = String.valueOf(((othProceedsSummary*InvestorDistribution[i].commAmount)/total_Commitment).setScale(3));
            InvestorDistribution[i].totDistruibution = String.valueOf(Decimal.valueOf(InvestorDistribution[i].capReturn).setScale(3) + Decimal.valueOf(InvestorDistribution[i].Dividend).setScale(3) + Decimal.valueOf(InvestorDistribution[i].reGain).setScale(3) + Decimal.valueOf(InvestorDistribution[i].othProceeds).setScale(3));
        }
    }

    public Pagereference cancelSetup()
    {
        ShowID = false;
        errormsg='';
        return null;
    }
    
    public void TotalDistribution_currency()
    {
        try
        {   
            if(Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isUpdateable())            
                objFundCC.Total_Capital_Called__c = Decimal.valueOf(TotalDistributioncurrency);             
        }
        catch(Exception objExcp)
        {            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        } 
    }
    
    public Pagereference saveInvestorDisrtibutions()
    {
        isshowerroronpage= false;
         
        errormsg ='';
            for(InD c : InvestorDistribution)
            {   
            if(c.capReturn=='')
                c.capReturn='0';
            if(c.Dividend=='')
                c.Dividend='0';
            if(c.reGain=='')
                c.reGain='0';  
            if(c.othProceeds=='')
               c.reGain='0'; 
            
            Set<String> invalidDecimal = new Set<String>();
            Set<String> negativeDecimal = new Set<String>();
            List<String> invalidDecimalL = new List<String>();
            String invalidMessage = '';
            String negativeMessage = '';
            try {
                Decimal.valueOf(c.capReturn);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                {
                    invalidDecimal.add('Capital Return');
                    invalidDecimalL .add('Capital Return');
                }
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
            try {
                Decimal.valueOf(c.Dividend);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                {
                    invalidDecimalL .add('Dividends');
                    invalidDecimal.add('Dividends');
                }
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
            try {
                Decimal.valueOf(c.reGain);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                {
                    invalidDecimal.add('Realized Gain');
                    invalidDecimalL .add('Realized Gain');
                }
                    
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
            try {
                Decimal.valueOf(c.othProceeds);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                {
                    invalidDecimal.add('Other Proceeds');
                    invalidDecimalL .add('Other Proceeds');
                }
                    
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }

          
            if(invalidDecimalL.size() == 1)
                invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+' of Investor Distribution related to Commitment '+c.commitment+'.';
            else if(invalidDecimalL.size() == 2)
                    invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+' and '+invalidDecimalL[1]+' of Investor Distribution related to Commitment '+c.commitment+'.';
                else if(invalidDecimalL.size() == 3)
                        invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+ ', ' + invalidDecimalL[1] + ' and ' + invalidDecimalL[2]+' of Investor Distribution related to Commitment '+c.commitment+'.';
                            else if(invalidDecimalL.size() == 4)
                                    invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+ ', ' + invalidDecimalL[1] +', '+invalidDecimalL[2]+ ' and ' + invalidDecimalL[3]+' of Investor Distribution related to Commitment '+c.commitment+'.';
                        
            if(invalidMessage != '')    // Invalid Message Added.
             errormsg = invalidMessage;
//                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, invalidMessage));
             List<String> negativeDecimalL = new List<String>();
            if(!invalidDecimal.contains('Capital Return') && isNegative(Decimal.valueOf(c.capReturn)))
            { 
                 negativeDecimalL .add('Capital Return');
                 negativeDecimal.add('Capital Return');
            }
            if(!invalidDecimal.contains('Dividends') && isNegative(Decimal.valueOf(c.Dividend)))
            {
                negativeDecimal.add('Dividends');
                negativeDecimalL .add('Dividends');
            }
                
            if(!invalidDecimal.contains('Realized Gain') && isNegative(Decimal.valueOf(c.reGain)))
            {
                negativeDecimal.add('Realized Gain');
                negativeDecimalL .add('Realized Gain');
            }
                
             if(!invalidDecimal.contains('Other Proceeds') && isNegative(Decimal.valueOf(c.othProceeds)))
             {
                negativeDecimal.add('Other Proceeds');
                negativeDecimalL .add('Other Proceeds');
             }
                

         
            if(negativeDecimalL.size() == 1)
                negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+' of Investor Distribution related to Commitment '+c.commitment+'.';
            else if(negativeDecimalL.size() == 2)
                    negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+' and '+negativeDecimalL[1]+' of Investor Distribution related to Commitment '+c.commitment+'.';
                else if(negativeDecimalL.size() == 3)
                        negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+ ', ' + negativeDecimalL[1] + ' and ' + negativeDecimalL[2]+' of Investor Distribution related to Commitment '+c.commitment+'.';
                            else if(negativeDecimalL.size() == 4)
                                    negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+ ', ' + negativeDecimalL[1] + ', ' + negativeDecimalL[2]+' and '+ negativeDecimalL[3]+ ' of Investor Distribution related to Commitment '+c.commitment+'.';
            if(negativeMessage != '')    // Negative Message Added.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, negativeMessage));

            if(ApexPages.hasMessages())
            {
                return null;
            }
            if(errormsg.length()>0)
            {
                
                           //string generateerrormsg=' <div class="grid"><div id="error"  class="error"><p><span style="color:#666666;font-weight:normal;font-size:12px;" ><strong style="color:#FF0000; font-size:14px; font-weight:bold;">Error</strong><br/>'+errormsg +' </span></p></div></div>';
                    string generateerrormsg= errormsg;     
                   errormsg =generateerrormsg;
                   isshowerroronpage = true;
                return null;
            }
                
            }
        
        // Fund Distribution Insertion.
        
        if (Schema.sObjectType.Fund_Distribution__c.fields.Fund_Name__c.isCreateable()) {
            fund_Distribution.Fund_Name__c = fundObj.id;
        }
        if (Schema.sObjectType.Fund_Distribution__c.isCreateable()) {
          insert fund_Distribution;
        }

        // Investor Distribution Insertion.InvestorDistribution
        List<Investor_Distribution__c> allIDs = new List<Investor_Distribution__c>();
        for(InD i: InvestorDistribution)
        {
            Investor_Distribution__c tempID = new Investor_Distribution__c();
            if(Schema.sObjectType.Investor_Distribution__c.fields.Fund_Distribution__c.isCreateable()){
                tempID.Fund_Distribution__c = fund_Distribution.id;
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Commitment__c.isCreateable()){
                tempID.Commitment__c = i.commitmentId;
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Capital_Return__c.isCreateable()){
                tempID.Capital_Return__c = Decimal.valueOf(i.capReturn);
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Dividends__c.isCreateable()){
                tempID.Dividends__c = Decimal.valueOf(i.Dividend);
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Other_Proceeds__c.isCreateable()){
                tempID.Other_Proceeds__c = Decimal.valueOf(i.othProceeds);
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Realized_Gain__c.isCreateable()){
                tempID.Realized_Gain__c = Decimal.valueOf(i.reGain);
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Distribution_Date__c.isCreateable()){
                tempID.Distribution_Date__c = fund_Distribution.Distribution_Date__c;
            }
            if(Schema.sObjectType.Investor_Distribution__c.fields.Capital_Recallable__c.isCreateable()){
                tempID.Capital_Recallable__c = capRecalled1; 
            }
            
            if(Schema.sObjectType.Investor_Distribution__c.isCreateable()){
                allIDs.add(tempID);
            }
            
        }
        if (Schema.sObjectType.Investor_Distribution__c.isCreateable()) {
           // insert fund_Distribution;
            insert allIDs;
        }
        
        PageReference pRef = new PageReference('/'+fundObj.id);
        pRef.setRedirect(true);
        return pRef;
        
    }
    public List<InD> InvestorDistribution;
    public List<InD> getInvestorDistribution()
    {
        return InvestorDistribution;
    }

    private Boolean isNegative(Decimal tempInt)
    {
        if(tempInt < 0.0)
            return true;
        else
            return false;
    }
    
    // Test meathod
    

    public static testMethod void testCreateDistribution()
    {
        list<RecordType> RT = new list<RecordType>();
        if(Schema.sObjectType.Recordtype.isAccessible() && Schema.sObjectType.Recordtype.fields.name.isAccessible()){
            RT = [select Name from Recordtype where SObjectType='Account'];
        }
        Map<String, ID> mapRT = new Map<String, ID>();
        for(RecordType r : RT)
            mapRT.put(r.Name, r.id);
        
        Account Inst = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        if (Schema.sObjectType.Account.isCreateable())
            insert Inst;
        Account ac =  new  Account();
        if(Schema.sObjectType.Account.isAccessible())
            ac=[select name from Account where id=:Inst.id];
        System.assertEquals('Institution',ac.name);
        Account LP = new Account(name='LP', parentId=Inst.id, recordTypeId=mapRT.get('Limited Partner'));
        if (Schema.sObjectType.Account.isCreateable())
            insert LP;
        ac=[select name from Account where id=:LP.id];
        System.assertEquals('LP',ac.name);
        Fund__c fnd = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        if (Schema.sObjectType.Fund__c.isCreateable())
            insert fnd;
        Fund__C f = new Fund__C();
        if(Schema.sObjectType.Fund__C.isAccessible())
            f=[select name from Fund__C where id=:fnd.id];
        System.assertEquals('Test Fund',f.name);
        Partnership__c part = new Partnership__c(name='Test Part', Fund__c=fnd.id , Total_Commitments__c=100);
        if (Schema.sObjectType.Partnership__c.isCreateable())
            insert part;
        Partnership__c p = new Partnership__c();
        if(Schema.sObjectType.Partnership__c.isAccessible())
            p=[select name from Partnership__c where id=:part.id];
        System.assertEquals('Test Part',p.name);
        Commitment__c cmt1 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        if (Schema.sObjectType.Commitment__c.isCreateable())
            insert cmt1;
        Commitment__c c1 = new Commitment__c();
        if(Schema.sObjectType.Commitment__c.isAccessible())
            c1=[select Commitment_Amount_nearest__c from Commitment__c where id=:cmt1.id];
        System.assertEquals(2000000,c1.Commitment_Amount_nearest__c);
        Commitment__c cmt2 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        if (Schema.sObjectType.Commitment__c.isCreateable())
            insert cmt2;
        c1=[select Commitment_Amount_nearest__c from Commitment__c where id=:cmt2.id];
        System.assertEquals(2000000,c1.Commitment_Amount_nearest__c);
        ApexPages.StandardController sc = new ApexPages.StandardController(fnd);
        CreateDistribution c = new CreateDistribution(sc);
        c.SetInD();
        c.getInvestorDistribution();
        c.capReturnSummary = 1.2;
        c.DividendSummary = 0.56;
        c.reGainSummary = 0.12;
        c.othProceedsSummary = 0.12;
        c.saveInvestorDisrtibutions();    // Save Successfully.
        
        c.InvestorDistribution[0].capReturn = '-32423.12';
        c.InvestorDistribution[0].Dividend = '-234.12';
        c.InvestorDistribution[0].reGain = '-0.12';
        c.InvestorDistribution[0].othProceeds = '-0.12';
        c.saveInvestorDisrtibutions();    // Save Successfully.
        c.InvestorDistribution[0].capReturn = '-3aas2';
        c.InvestorDistribution[0].Dividend = '-234.12';
        c.InvestorDistribution[0].reGain = '-0.12';
        c.InvestorDistribution[0].othProceeds = '-0.12';
        c.saveInvestorDisrtibutions();    // Save Successfully.
        c.InvestorDistribution[0].capReturn = '-32423.12';
        c.InvestorDistribution[0].Dividend = '-2sdf.12';
        c.InvestorDistribution[0].reGain = '-0.dfg2';
        c.InvestorDistribution[0].othProceeds = '-0.12';
        c.saveInvestorDisrtibutions();    // Save Successfully.
        c.InvestorDistribution[0].capReturn = 'sd';
        c.InvestorDistribution[0].Dividend = 'dfs2';
        c.InvestorDistribution[0].reGain = '-0jgu2';
        c.InvestorDistribution[0].othProceeds = '-2';
        c.saveInvestorDisrtibutions();    // Save Successfully.
        c.InvestorDistribution[0].capReturn = 'sd';
        c.InvestorDistribution[0].Dividend = 'dfs2';
        c.InvestorDistribution[0].reGain = '-0jgu2';
        c.InvestorDistribution[0].othProceeds = '-sdf2';
        c.saveInvestorDisrtibutions();    // Save Successfully.
        c.InvestorDistribution[0].capReturn = '';
        c.InvestorDistribution[0].Dividend = '';
        c.InvestorDistribution[0].reGain = '';
        c.InvestorDistribution[0].othProceeds = '';
        c.saveInvestorDisrtibutions();    // Save Successfully.
        c.cancelSetup();    // Canceled Fund Drawdown.
    }
}