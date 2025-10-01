trigger chkIns_Upd_Del_PipeLine on Pipeline__c(before insert, after insert , after update, before delete) 
{
    /*  
    New Implimentation:
    Developer               :   Vivek Kumar
    Product Version         :   PE 2.2
    Date of Creation        :   11/12/2009

    Purpose of Creation     :   To update the Date_Created__c and Date_Last_Modified__c in Company(Institutions's Record Type) from Pipeline__c's login_In_date__c and LastModifiedDate.

    Updated by              :   Deimple Lala
    Product Version         :   PE 2.4
    Date of Updation        :   30/01/2012
    Purpose of Updation     :   To prevent the linking of Pipeline to record types other than Private Equity record types.
    To link Pipeline only to Company.

    */
    /* 
        Developer               :  Rahul Kumar Kasaundhan
        Product Version         :  PE 4.5
    Date of Creation        :  21/07/2020
        Purpose of Creation     :  Add dynamic API name exits between (Account and Pipeline)
    */
    /* 
        Developer               :  Hemendra Singh Rajawat
        Product Version         :  PE 4.5
    Date of Creation        :  30/07/2020
        Purpose of Creation     :  Add dynamic relationship name exits between (Account and Pipeline)
    */
    String sCompanyApi =  CommonUtility.chkmasterLookupInPiplineAPI();
    String pipelineAccRelName = CommonUtility.getPipelineAccRelationName();

    if(Trigger.size < 6)
    {
        
        //(PE3.5, SK, 16Aug2017)
        Pipeline__c[] PipeInLst;
        if(Trigger.isInsert || Trigger.isUpdate){
            PipeInLst = Trigger.new;
        }
        else if(Trigger.isDelete){
            PipeInLst = Trigger.old;
        }
        Map<Id, Account> acctMap = new Map<Id, Account>();
        Set<Id> acctIdsSet = new Set<Id>();
        for(Pipeline__c PLI : PipeInLst){
            if(PLI.Log_In_Date__c != NULL)  {
                acctIdsSet.add((ID) PLI.get(sCompanyApi));
            }
        }
        acctMap = new Map<Id, Account>([Select id, Date_Created__c ,HasPipeline__c, Date_Last_Modified__c From Account Where Id IN:acctIdsSet]);
        
        
        if(Trigger.isInsert)
        {
            Pipeline__c[] PipeIn = Trigger.new;
            List<Account> lstAcctUpdate = new List<Account>(); //(PE3.5, SK, 16Aug2017)
            
            for(Pipeline__c PLI : PipeIn)
            {
                if(PLI.Log_In_Date__c != NULL)  
                {
                    Account acc = acctMap.get((ID) PLI.get(sCompanyApi));
                    
                    try
                    {
                        String InsLModifydate = String.valueOf(PLI.LastModifiedDate).split(' ')[0];
                        Integer Insyr = integer.valueof(String.valueOf(InsLModifydate).split('-')[0]);
                        Integer Insmo = integer.valueof(String.valueOf(InsLModifydate).split('-')[1]);
                        Integer Insdt = integer.valueof(String.valueOf(InsLModifydate).split('-')[2]); 
                        Date InsLModate = Date.newInstance(Insyr, Insmo, Insdt); 

                        if(PLI.Log_In_Date__c < acc.Date_Created__c && acc.HasPipeline__c == true)  
                        {
                            acc.Date_Created__c = PLI.Log_In_Date__c; 
                        }
                        acc.Date_Last_Modified__c = InsLModate;  

                        if(acc.HasPipeline__c == false)
                        {
                            acc.Date_Created__c = NULL;
                            acc.Date_Last_Modified__c = NULL;
                            acc.Date_Created__c = PLI.Log_In_Date__c;
                            acc.Date_Last_Modified__c = InsLModate;     
                            acc.HasPipeline__c = true;
                        }
                        
                        lstAcctUpdate.add(acc); //(PE3.5, SK, 16Aug2017)
                    }
                    catch(Exception ei)
                    {
                        System.debug(ei);     
                    }
                }
            } 
            
            //(PE3.5, SK, 16Aug2017)
            if(lstAcctUpdate.size() > 0){
                update lstAcctUpdate;
            }      
        }

        if(Trigger.isUpdate)
        {
            Pipeline__c[] PipeUp = Trigger.new;
            List<Account> lstAcctUpdate = new List<Account>(); //(PE3.5, SK, 16Aug2017)
            
            //(PE3.5, SK, 16Aug2017)
            Set<Id> acctCompNameIdsSet = new Set<Id>();
            for(Pipeline__c PLU : PipeUp){
                acctCompNameIdsSet.add((ID) PLU.get(sCompanyApi));
            }
            Map<Id, Account> acctwithPipelineMap = new Map<Id, Account>((List<Account>)Database.query('Select Id, (Select Id, Name From ' + pipelineAccRelName +' ORDER BY Log_In_Date__c ASC) From Account Where Id IN:acctCompNameIdsSet'));
            
            
            for(Pipeline__c PLU : PipeUp)
            {
                Account acc = acctMap.get((ID) PLU.get(sCompanyApi));
                
                try
                {
                    String CurrLModifydate = String.valueOf(PLU.LastModifiedDate).split(' ')[0];
                    Integer Curryr = integer.valueof(String.valueOf(CurrLModifydate).split('-')[0]);
                    Integer Currmo = integer.valueof(String.valueOf(CurrLModifydate).split('-')[1]);
                    Integer Currdt = integer.valueof(String.valueOf(CurrLModifydate).split('-')[2]); 
                    Date UpLModate = Date.newInstance(Curryr, Currmo, Currdt);

                    Pipeline__c[] PLSS = (Pipeline__c[])acctwithPipelineMap.get((ID) PLU.get(sCompanyApi)).getsObjects(pipelineAccRelName);
                    Pipeline__c[] P = new Pipeline__c[]{PLSS[0]};
                    
                    if(acc.Date_Created__c==null && PLU.Log_In_Date__c!=null)
                    {
                        if(P[0].Log_In_Date__c<PLU.Log_In_Date__c)
                        {
                            acc.Date_Created__c = P[0].Log_In_Date__c;
                        }
                        else
                        {
                            acc.Date_Created__c = PLU.Log_In_Date__c;
                        }
                    }
                    if(PLU.Log_In_Date__c < acc.Date_Created__c)
                    {
                        acc.Date_Created__c = PLU.Log_In_Date__c;
                    }
                    if(PLU.Log_In_Date__c > acc.Date_Created__c && PLSS.size()==1)
                    {
                        acc.Date_Created__c = PLU.Log_In_Date__c;
                    }
                    if(PLU.Log_In_Date__c == acc.Date_Created__c && PLSS.size()>1)
                    {
                        acc.Date_Created__c=P[0].Log_In_Date__c;
                    }
                    if(PLU.Log_In_Date__c > acc.Date_Created__c && PLSS.size()>1)
                    {
                        acc.Date_Created__c = P[0].Log_In_Date__c;
                    }
                    acc.Date_Last_Modified__c = UpLModate;
                    
                    lstAcctUpdate.add(acc); //(PE3.5, SK, 16Aug2017)
                }
                catch(Exception eu)
                {
                System.debug(eu);    
                }
            }
            
            //(PE3.5, SK, 16Aug2017)
            if(lstAcctUpdate.size() > 0){
                update lstAcctUpdate;
            }
        }

        if(Trigger.isDelete)
        {
            Pipeline__c[] PipeDel = Trigger.old;
            List<Account> lstAcctUpdate = new List<Account>(); //(PE3.5, SK, 16Aug2017)
            
            //(PE3.5, SK, 16Aug2017)
            Set<Id> acctCompNameIdsSet = new Set<Id>();
            for(Pipeline__c PLD : PipeDel){
                acctCompNameIdsSet.add((ID) PLD.get(sCompanyApi));
            }
            Map<Id, Account> acctwithPipelineMap = new Map<Id, Account>((List<Account>) Database.query('Select Id, (Select Id, Name, Log_In_Date__c, LastModifiedDate From ' + pipelineAccRelName + ' Where Id Not IN:PipeDel ORDER BY Log_In_Date__c ASC) From Account Where Id IN:acctCompNameIdsSet'));
            
            Map<Id, Account> acctwithPipelineMap2 = new Map<Id, Account>((List<Account>) Database.query('Select Id, (Select Id, Name, Log_In_Date__c, LastModifiedDate From ' + pipelineAccRelName + ' Where Id Not IN:PipeDel ORDER BY LastModifiedDate DESC) From Account Where Id IN:acctCompNameIdsSet'));
            // check map size for account while delete the record for bug(00029384) fixing in PE4.5 by RahulK at 12/7/2020
            if(acctMap.size()>0){
                for(Pipeline__c PLD : PipeDel)
                {
                    Account acc = acctMap.get((ID) PLD.get(sCompanyApi));
                    
                    Pipeline__c[] PLS = (Pipeline__c[]) acctwithPipelineMap.get((ID) PLD.get(sCompanyApi)).getSobjects(pipelineAccRelName);
                    
                    try
                    {
                        if(PLS.size()==0)
                        {
                            acc.Date_Created__c = NULL;
                            acc.Date_Last_Modified__c = NULL;
                            acc.HasPipeline__c = false;
                            
                            lstAcctUpdate.add(acc); //(PE3.5, SK, 16Aug2017)
                        }
                        else
                        {
                            Pipeline__c[] P = new Pipeline__c[]{((Pipeline__c[]) acctwithPipelineMap.get((ID) PLD.get(sCompanyApi)).getsObjects(pipelineAccRelName))[0]};
                            Pipeline__c[] PP = new Pipeline__c[]{((Pipeline__c[]) acctwithPipelineMap2.get((ID) PLD.get(sCompanyApi)).getsObjects(pipelineAccRelName))[0]};
                            
                            
                            String DelModifydate = String.valueOf(PP[0].LastModifiedDate).split(' ')[0];
                            Integer Curryr = integer.valueof(String.valueOf(DelModifydate).split('-')[0]);
                            Integer Currmo = integer.valueof(String.valueOf(DelModifydate).split('-')[1]);
                            Integer Currdt = integer.valueof(String.valueOf(DelModifydate).split('-')[2]);
                            Date DelModate = Date.newInstance(Curryr, Currmo, Currdt);
                            
                            if(acc.Date_Created__c == PLD.Log_In_Date__c)
                            {
                                acc.Date_Created__c = P[0].Log_In_Date__c;
                            }
                            acc.Date_Last_Modified__c = DelModate;
                            
                            lstAcctUpdate.add(acc); //(PE3.5, SK, 16Aug2017)
                        }
                    }
                    catch(Exception e)
                    {
                        System.debug(e);    
                    }
                }  
          }
            //(PE3.5, SK, 16Aug2017)
            if(lstAcctUpdate.size() > 0){
                update lstAcctUpdate;
            }   
        }


        if(Trigger.isInsert)
        {
            Set<id> CompanySet=new Set<id>();
            for(Pipeline__C pipeline :trigger.New)
            {
                CompanySet.add((ID) pipeline.get(sCompanyApi));
            }

            Map<id , String> CompanyRecordType= New Map<id , String>();
            List<Account> TempAccount=[Select id , RecordType.Name from Account where id IN :CompanySet];

            for(Account acc :TempAccount )
            {
                CompanyRecordType.Put(acc.id,acc.RecordType.Name);
            }

        }
    }
    
    
    
    
    
    /*  New Implimentation:
        Developer               :   Manjot Singh 
        Product Version         :   PE 2.0
        Date of Creation        :   03/03/2009
        Purpose of Creation     :   To prevent the linking of Pipeline to a Institution or limited partner.

        Updated by              :   Amit Kumar
        Date of Updation        :   13/03/2009
        Purpose of Updation     :   To prevent the deletion of Pipeline if there exists related Advisor Involvements.
        
        Updated by              :   Amit Kumar
        Product Version         :   PE 2.2
        Date of Updation        :   02/07/2009
        Purpose of Updation     :   Dynamic error messages.
    */
    if(Trigger.size == 1 && Trigger.isBefore && (Trigger.isInsert || Trigger.isDelete) )
    {
        if(Trigger.isDelete)
        {
            // (PE3.5, SK, 10Aug2017)
            Pipeline__c objPipelineOld = new Pipeline__c();
            for(Pipeline__c objPipeline : Trigger.old){
                objPipelineOld = objPipeline;
            }
            
            Pipeline__c plnTemp = [Select Id, (Select Id From Advisor_Involvement__r) From Pipeline__c where id = :objPipelineOld.id];
            if(plnTemp.Advisor_Involvement__r.size() > 0)
                objPipelineOld.addError('Please delete the related "Advisor Involvement" records before deleting the "Pipeline" record.');
        }
    }
    
    /*  
        New Implimentation:
        Developer : Brahmaditya Bhaskar
        Product Version  :   PE 3.5
        Date of Creation :   30/05/2016
        Purpose of Creation : if we change the stage field value update the value of Pipeline Stage Log object.

    */
    if(Trigger.isafter && (Trigger.isInsert || Trigger.isupdate)){
    
        Set<ID> pipelineIds =new Set<ID>();
        List<Pipeline_Stage_Log__c> plsInserList = new List<Pipeline_Stage_Log__c>();
        List<Pipeline_Stage_Log__c> plsUpdateList = new List<Pipeline_Stage_Log__c>();
        if(CommonUtility.isPipelineTrigerRun){
            for(Pipeline__c piplneObj :Trigger.new){ 
                if(Trigger.old==null || ((Trigger.old !=null && (Trigger.oldMap.get(piplneObj.id).stage__c!=piplneObj.stage__c)))){
                    Pipeline_Stage_Log__c plsinsert = new Pipeline_Stage_Log__c();
                    plsinsert.Pipeline__c=piplneObj.id;
                    plsinsert.Date_Stage_Set__c=Date.today();
                    plsinsert.Changed_Stage__c=piplneObj.Stage__c;
                    plsInserList.add(plsinsert);
                    if(Trigger.old !=null)
                        pipelineIds.add(piplneObj.id); 
                }                
            }

            if(pipelineIds.size()>0){
                
                for(Pipeline_Stage_Log__c plsObj :[select id,Date_Stage_Changed__c from Pipeline_Stage_Log__c where Pipeline__c IN:pipelineIds AND Date_Stage_Changed__c =null]){
                    plsObj.Date_Stage_Changed__c=Date.today(); 
                    plsUpdateList.add(plsObj);  
                }       
               
            }

            //update the record after changin this stage field value 
            if(plsUpdateList.size() >0)
              update plsUpdateList;
              
            //insert the record after update the stage Field value
            if(plsInserList.size() >0)
                insert plsInserList;
            
            //set global varibale to call trigger only once
            CommonUtility.isPipelineTrigerRun = false;
        }
    }
    
    
}