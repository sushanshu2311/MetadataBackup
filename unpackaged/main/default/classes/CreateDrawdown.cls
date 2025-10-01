/***********************************
   ** Module Name : CreateDrawdown
   ** Description : To calculate the capital call and drawdown from the total commitment of investors
   ** Throws : NA
   ** Calls : NA
   ** Test Class :  Available
   ** Organization : Navatar Group
   ** Product Name & Version : PE 3.5
   ** Revision History:-
   ** Version         Date         Author 
      PE 3.5      20-July-2016     Vasudha Tandon
   *************************************/
public with sharing class CreateDrawdown {

    private Fund__c fundObj;
    public Boolean ShowCC {get; set;}
    public Fund_Drawdown__c fund_Drawdown {get; set;}
    private List<Partnership__c> lstPart;
    
    // public properties for setting Total Drawdown Amounts.
    public Decimal total_Percent {get;set;}
    public Decimal total_capitalAmount {get;set;}
    public Decimal total_managementFee {get;set;}
    public Decimal total_otherFee {get;set;}
    public Decimal total_capitalPercent {get;set;}
    public Decimal total_managementPercent {get;set;}
    public Decimal total_otherPercent {get;set;}
    public Boolean dSDisable {get;set;}
    public Boolean AmountSelected {get;set;}
    public Boolean PercentSelected {get;set;}
    public Boolean noCommitments {get; private set;}
    public string errormsg{get; set;}
    public Fund__c objFundCC{get;set;}
    public String strCapitalCall{get;set;}
    public String strUserLocale{get;set;}
    public String strUserCurrency{get;set;}
    public string NameSpacePrefix{get; set;}
  
    
    public CreateDrawdown(ApexPages.StandardController controller) {
        NameSpacePrefix=CommonUtility.strNameSpacePrefix;
        strUserLocale = UserInfo.getLocale();
        strUserCurrency = UserInfo.getDefaultCurrency();
        fundObj = (Fund__c)controller.getRecord();
        //Added By Qadir Khan for PE 3.5 8 DEC 2017..
        if(Schema.sObjectType.Fund__c.isAccessible()  && Schema.sObjectType.Fund__c.fields.Total_Capital_Called_mn__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Commitments_USD_mn__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Total_Commitments__c.isAccessible()){
            fundObj = [select Total_Capital_Called_mn__c,Total_Capital_Called__c, Total_Commitments_USD_mn__c, Total_Commitments__c from Fund__c where id=:fundObj.id];   //Use new field Total_Commitments__c instead of Total_Commitment__c
        }
        capitalCalls = new List<CC>();
        ShowCC = false;
        fund_Drawdown = new Fund_Drawdown__c();
        total_Percent = 0.00;
        total_capitalAmount = 0.00;
        total_managementFee = 0.00;
        total_otherFee = 0.00;
        total_capitalPercent = 0.00;
        total_managementPercent = 0.00;
        total_otherPercent = 0.00;
        strCapitalCall = '';
        
        objFundCC = new Fund__c();
        if(Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isUpdateable())
            objFundCC.Total_Capital_Called__c = 0.00;
        dSDisable = false;
        AmountSelected = false;
        PercentSelected = false;
        noCommitments = true;
        lstPart = new List<Partnership__c>();
        //Added By Qadir Khan for PE 3.5 8 DEC 2017..
        if(Schema.sObjectType.Partnership__c.isAccessible() && Schema.sObjectType.Partnership__c.fields.Fund__c.isAccessible() && Schema.sObjectType.Commitment__c.isAccessible() && Schema.sObjectType.Commitment__c.fields.name.isAccessible() && Schema.sObjectType.Commitment__c.fields.Commitment_Amount_nearest__c.isAccessible() && Schema.sObjectType.Commitment__c.fields.Limited_Partner__c.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible()){
            lstPart = [Select (Select id, name, Commitment_Amount_nearest__c, Limited_Partner__r.name, Limited_Partner__c  from Commitment__r) from Partnership__c where Fund__c =:fundObj.id];
        }
        for(Partnership__c p : lstPart)    // Searching whether fund have any commitment or not?
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

    public Decimal getTotal_Capital_Called()
    {
       if(fundObj.Total_Capital_Called__c == null && Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isUpdateable())
       {
          fundObj.Total_Capital_Called__c = 0.00;       
       }      
       return fundObj.Total_Capital_Called__c;
    }
    
    public Decimal getTotal_Commitments_USD_mn()
    {
        return fundObj.Total_Commitments_USD_mn__c;
    }

    public Decimal getTotal_Commitments()                          // Change the field Total_Commitment__c to Total_Commitments__c
    {
        return fundObj.Total_Commitments__c;
    }

    private Class CC
    {
        public Id commitmentID {get; private set;}
        public Id limitedPartnerID {get; private set;}
        public String commitment {get; set;}
        public String limitedPartner {get; set;}
        public String commitmentAmountVal {get; set;}
        public String capitalAmount {get; set;}
        public String managementFee {get; set;}
        public String otherFee {get; set;}
        public String callAmount {get; set;}
        public Decimal CommitmentAmount {get; set;}
        public Commitment__c cmmt{get; set;}
    }
    
    public PageReference cancelSetup()
    {
            ShowCC = false;
            dSDisable = false;
            errormsg='';
            return null;
            
    }
        
    // CommandButton Action Function.
    public PageReference actionCapitalCalls()
    {
        capitalCalls = new List<CC>();
        if(fund_Drawdown.Call_Date__c <= fund_Drawdown.Due_Date__c)
        {
            
            ShowCC = true;
            dSDisable = true;
            if(AmountSelected == false)
                PercentSelected = true;
            else
                PercentSelected = false;
            Decimal total_Commitment = 0.0;
    
            for(Partnership__c p : lstPart)
            {
                for(Commitment__c c : p.Commitment__r)
                {
                    CC tempCC = new CC();
                    tempCC.commitmentID = c.Id;
                    tempCC.limitedPartnerID = c.Limited_Partner__c;
                    tempCC.commitment = c.name;
                    tempCC.cmmt = new Commitment__c();
                    tempCC.cmmt = c;
                    //tempCC.cmmt.Commitment_Amount_nearest__c = c.Commitment_Amount_nearest__c != null? c.Commitment_Amount_nearest__c.setScale(3) : 0.00;
                    tempCC.commitmentAmountVal = String.valueOf(c.Commitment_Amount_nearest__c != null? c.Commitment_Amount_nearest__c.setScale(3) : 0.00);
                    tempCC.limitedPartner=c.Limited_Partner__r.name;
                    tempCC.CommitmentAmount = c.Commitment_Amount_nearest__c != null? c.Commitment_Amount_nearest__c.setScale(3) : 0.00;
                    this.capitalCalls.add(tempCC);
                    
                    total_Commitment += c.Commitment_Amount_nearest__c != null? c.Commitment_Amount_nearest__c.setScale(3) : 0.00;
                }
            }
            if(total_Commitment == 0)
                total_Commitment = 1.0;           
            else
               total_Commitment =  fundObj.Total_Commitments__c;                          //New Change for the use of total_commitments field of Fund
                       
            for(Integer i=0 ; i<capitalCalls.size() ; i++)
            {
                capitalCalls[i].capitalAmount = String.valueOf(((capitalCalls[i].CommitmentAmount*total_capitalAmount)/total_Commitment).setScale(3));          // Divide the calculation with Fund's Total_Commitments__c field
                capitalCalls[i].managementFee = String.valueOf(((capitalCalls[i].CommitmentAmount*total_managementFee)/total_Commitment).setScale(3));          // Divide the calculation with Fund's Total_Commitments__c field
                capitalCalls[i].otherFee = String.valueOf(((capitalCalls[i].CommitmentAmount*total_otherFee)/total_Commitment).setScale(3));                    // Divide the calculation with Fund's Total_Commitments__c field
                capitalCalls[i].callAmount = String.valueOf(Decimal.valueOf(capitalCalls[i].capitalAmount).setScale(3) + Decimal.valueOf(capitalCalls[i].managementFee).setScale(3) + Decimal.valueOf(capitalCalls[i].otherFee).setScale(3));
            }
        }
        else
        {
              
        }
        return null;
    }
    
    public Pagereference saveCapitalCalls()
    {
       errormsg='';
        for(CC c : capitalCalls)
        {
            Set<String> invalidDecimal = new Set<String>();
            Set<String> negativeDecimal = new Set<String>();
            String invalidMessage = '';
            String negativeMessage = '';
            if(c.capitalAmount == '')
                c.capitalAmount = '0.0';
            if(c.managementFee == '')
                c.managementFee = '0.0';
            if(c.otherFee == '')
                c.otherFee = '0.0';
            try {
                Decimal.valueOf(c.capitalAmount);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                    invalidDecimal.add('Capital Amount');
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
            try {
                Decimal.valueOf(c.managementFee);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                    invalidDecimal.add('Management Fee');
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
            try {
                Decimal.valueOf(c.otherFee);
            }
            catch(System.TypeException e) {
                if(e.getMessage().contains('Invalid decimal'))
                    invalidDecimal.add('Other Fee');
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }

            List<String> invalidDecimalL = new List<String>(invalidDecimal);
            invalidDecimalL.sort();
            if(invalidDecimalL.size() == 1)
                invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+' of Capital Call related to Commitment '+c.commitment+'.';
            else if(invalidDecimalL.size() == 2)
                    invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+' and '+invalidDecimalL[1]+' of Capital Call related to Commitment '+c.commitment+'.';
                else if(invalidDecimalL.size() == 3)
                        invalidMessage = 'Please enter a valid number for ' + invalidDecimalL[0]+ ', ' + invalidDecimalL[1] + ' and ' + invalidDecimalL[2]+' of Capital Call related to Commitment '+c.commitment+'.';
            if(invalidMessage != '')    // Invalid Message Added.
            {
                errormsg=invalidMessage ;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, invalidMessage));
            }
            if(!invalidDecimal.contains('Capital Amount') && isNegative(Decimal.valueOf(c.capitalAmount)))
                negativeDecimal.add('Capital Amount');
            if(!invalidDecimal.contains('Management Fee') && isNegative(Decimal.valueOf(c.managementFee)))
                negativeDecimal.add('Management Fee');
            if(!invalidDecimal.contains('Other Fee') && isNegative(Decimal.valueOf(c.otherFee)))
                negativeDecimal.add('Other Fee');

            List<String> negativeDecimalL = new List<String>(negativeDecimal);
            negativeDecimalL.sort();
            if(negativeDecimalL.size() == 1)
                negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+' of Capital Call related to Commitment '+c.commitment+'.';
            else if(negativeDecimalL.size() == 2)
                    negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+' and '+negativeDecimalL[1]+' of Capital Call related to Commitment '+c.commitment+'.';
                else if(negativeDecimalL.size() == 3)
                        negativeMessage = 'Please enter a value greater than or equal to zero for ' + negativeDecimalL[0]+ ', ' + negativeDecimalL[1] + ' and ' + negativeDecimalL[2]+' of Capital Call related to Commitment '+c.commitment+'.';
            if(negativeMessage != '')    // Negative Message Added.
            {
            
               
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, negativeMessage));
            
            }
            
            if(ApexPages.hasMessages())
            {
                return null;
            }
             if(errormsg.length()>0)
            {
                
                string generateerrormsg=' <div class="grid"><div id="error"  class="error"><p><span style="color:#666666;font-weight:normal;font-size:12px;" ><strong style="color:#FF0000; font-size:14px; font-weight:bold;">Error</strong><br/>'+errormsg +' </span></p></div></div>';
                   errormsg =generateerrormsg;
                return null;
            }
        }
        Schema.DescribeSObjectResult funddwrDescribe=  Fund_Drawdown__c.sObjectType.getDescribe();   
        Schema.DescribeSObjectResult captlcDescribe=  Capital_Call__c.sObjectType.getDescribe();   
        // Fund Drawdown Insertion.
        if(Schema.sObjectType.Fund_Drawdown__c.fields.Fund_Name__c.isCreateable()){
            fund_Drawdown.Fund_Name__c = fundObj.id;
        }
        
        if(funddwrDescribe.isCreateable()){
            database.insert(fund_Drawdown);
        }
        
        // Capital Calls Insertion.
        List<Capital_Call__c> allCCs = new List<Capital_Call__c>();
        for(CC c: capitalCalls)
        {
            Capital_Call__c tempCC = new Capital_Call__c();
            if( Schema.sObjectType.Capital_Call__c.fields.Fund_Drawdown__c.isCreateable() ){
                tempCC.Fund_Drawdown__c = fund_Drawdown.id;
            }
            if( Schema.sObjectType.Capital_Call__c.fields.Commitment__c.isCreateable() ){
                tempCC.Commitment__c = c.commitmentID;
            }
            if( Schema.sObjectType.Capital_Call__c.fields.Capital_Amount__c.isCreateable() ){
                tempCC.Capital_Amount__c = Decimal.valueOf(c.capitalAmount);
            }
            if( Schema.sObjectType.Capital_Call__c.fields.Management_Fee__c.isCreateable() ){
                tempCC.Management_Fee__c = Decimal.valueOf(c.managementFee);
            }
            if( Schema.sObjectType.Capital_Call__c.fields.Other_Fee__c.isCreateable() ){
                tempCC.Other_Fee__c = Decimal.valueOf(c.otherFee);
            }
            if( Schema.sObjectType.Capital_Call__c.fields.Call_Date__c.isCreateable() ){
                tempCC.Call_Date__c = fund_Drawdown.Call_Date__c;
            }
            if( Schema.sObjectType.Capital_Call__c.fields.Due_Date__c.isCreateable() ){
                tempCC.Due_Date__c = fund_Drawdown.Due_Date__c;
            }
            
            if(captlcDescribe.isCreateable()){
                allCCs.add(tempCC);
            }
        }
        if(captlcDescribe.isCreateable()){
            database.insert(allCCs);
        }
        
        PageReference pRef = new PageReference('/'+fundObj.id);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public void calCapitalCall(){
        try{
            if(Schema.sObjectType.Fund__c.fields.Total_Capital_Called__c.isUpdateable())
                objFundCC.Total_Capital_Called__c = Decimal.valueOf(strCapitalCall);    
        }
        catch(Exception objExcp){
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        } 
    }
    
    public List<CC> capitalCalls;
    
    public List<CC> getcapitalCalls()
    {
        return capitalCalls;
    }
    
    private Boolean isNegative(Decimal tempInt)
    {
        if(tempInt < 0.0)
            return true;
        else
            return false;
    }
 
    // Test meathod
    public static testMethod void testCreateDrawdown()
    {
        list<RecordType> RT = new list<RecordType>();
        if(Schema.sObjectType.Recordtype.isAccessible() && Schema.sObjectType.Recordtype.fields.name.isAccessible()){
            RT = [select Name from Recordtype where SObjectType='Account'];
        }
        Map<String, ID> mapRT = new Map<String, ID>();
        Schema.DescribeSObjectResult accDescribe=  Account.sObjectType.getDescribe();   
        Schema.DescribeSObjectResult cmtDescribe=  Commitment__c.sObjectType.getDescribe(); 
        Schema.DescribeSObjectResult fundDescribe=  Fund__c.sObjectType.getDescribe();   
        Schema.DescribeSObjectResult partnrDescribe=  Partnership__c.sObjectType.getDescribe(); 
        
        for(RecordType r : RT)
            mapRT.put(r.Name, r.id);
        
        Account Inst = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        if(accDescribe.isCreateable())
            insert Inst;
        Account ac=[select name from Account where id=:Inst.id];
        System.assertEquals('Institution',ac.name);
        Account LP = new Account(name='LP', parentId=Inst.id, recordTypeId=mapRT.get('Limited Partner'));
        if(accDescribe.isCreateable())
            insert LP;
        ac=[select name from Account where id=:LP.id];
        System.assertEquals('LP',ac.name);
        Fund__c fnd = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        if(fundDescribe.isCreateable())
            insert fnd;
        Fund__C f=[select name from Fund__C where id=:fnd.id];
        System.assertEquals('Test Fund',f.name);
        Partnership__c part = new Partnership__c(name='Test Part', Fund__c=fnd.id , Total_Commitments__c=100);
        if(partnrDescribe.isCreateable())
            insert part;
        Partnership__c p=[select name from Partnership__c where id=:part.id];
        System.assertEquals('Test Part',p.name);
        Commitment__c cmt1 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        if(cmtDescribe.isCreateable())
            insert cmt1;
        Commitment__c c1=[select Commitment_Amount_nearest__c from Commitment__c where id=:cmt1.id];
        System.assertEquals(2000000,c1.Commitment_Amount_nearest__c);
        Commitment__c cmt2 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        if(cmtDescribe.isCreateable())
            insert cmt2;
        c1=[select Commitment_Amount_nearest__c from Commitment__c where id=:cmt2.id];
        System.assertEquals(2000000,c1.Commitment_Amount_nearest__c);
        ApexPages.StandardController sc = new ApexPages.StandardController(fnd);
        CreateDrawdown c = new CreateDrawdown(sc);
        c.getTotal_Capital_Called();
        c.getTotal_Commitments_USD_mn();
        c.getTotal_Commitments();
        c.AmountSelected = true;    // For Amount in Currency.
        c.fund_Drawdown.Due_Date__c=System.today();
        c.fund_Drawdown.Call_Date__c=System.today();
        c.AmountSelected = false;    // For Amount acc to percentage selected.
        c.actionCapitalCalls();
        c.getcapitalCalls();
        c.total_capitalAmount = 1.2;
        c.total_managementFee = 0.56;
        c.total_otherFee = 0.12;
        c.saveCapitalCalls();    // Save Successfully.
        c.fund_Drawdown.Due_Date__c=System.today()-1;
        c.fund_Drawdown.Call_Date__c=System.today();
        c.actionCapitalCalls();
        c.fund_Drawdown.Due_Date__c=System.today();
        c.fund_Drawdown.Call_Date__c=System.today()-1;
        c.AmountSelected = true;    // For Amount in Currency.
        c.actionCapitalCalls();
        
        c.capitalCalls[0].capitalAmount = '-32423.12';
        c.capitalCalls[0].managementFee = '-234.12';
        c.capitalCalls[0].otherFee = '-gssd';
        c.saveCapitalCalls();    // Save Successfully.
        c.capitalCalls[0].capitalAmount = '-dfs23.12';
        c.capitalCalls[0].managementFee = '-2sdf4.12';
        c.capitalCalls[0].otherFee = '-23';
        c.saveCapitalCalls();    // Save Successfully.
        c.capitalCalls[0].capitalAmount = '-32423.12';
        c.capitalCalls[0].managementFee = '-234.12';
        c.capitalCalls[0].otherFee = '-324';
        c.saveCapitalCalls();    // Save Successfully.
        c.capitalCalls[0].capitalAmount = '-dfs23.12';
        c.capitalCalls[0].managementFee = '-2sdf4.12';
        c.capitalCalls[0].otherFee = 'vhas';
        c.saveCapitalCalls();    // Save Successfully.
        c.capitalCalls[0].capitalAmount = '';
        c.capitalCalls[0].managementFee = '';
        c.capitalCalls[0].otherFee = '';
        c.saveCapitalCalls();    // Save Successfully.
        c.cancelSetup();    // Canceled Fund Drawdown.
    }
}