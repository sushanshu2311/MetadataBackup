trigger chkIns_Upd_Del_Fund_Drawdown on Fund_Drawdown__c (before insert, after update, after delete, after undelete)
{
    if(Trigger.size == 1)
    {
        List<Fund_Drawdown__c> lstFD = new List<Fund_Drawdown__c>();
        Double TotalAmt = 0.00;
        Fund__c fndUpdate;
        
        
        // (PE3.5, SK, 10Aug2017)
        Fund_Drawdown__c objFundDrawdownNew = new Fund_Drawdown__c();
        Fund_Drawdown__c objFundDrawdownOld = new Fund_Drawdown__c();
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Fund_Drawdown__c objFDrawd : Trigger.New){
                objFundDrawdownNew = objFDrawd;
            }
        }
        if(Trigger.isUpdate || Trigger.isDelete){
            for(Fund_Drawdown__c objFDrawd : Trigger.old){
                objFundDrawdownOld = objFDrawd;
            }
        }
        
        
        if(Trigger.isInsert)
        {
            if(objFundDrawdownNew.Fund_Name__c == null)
                objFundDrawdownNew.Fund_Name__c.addError('Please select a Fund Name.');
        }
        else if(Trigger.isUpdate)
        {
            if(objFundDrawdownNew.Fund_Name__c != null)
            {
                lstFD = [select id, Call_Amount__c, Fund_Name__r.Total_Capital_Called__c from Fund_Drawdown__c where Fund_Name__c = :objFundDrawdownNew.Fund_Name__c Limit 1000];
                fndUpdate = new Fund__c(id = objFundDrawdownNew.Fund_Name__c);
                
                for(Integer i=0 ; i<lstFD.size() ; i++)
                    TotalAmt += lstFD[i].Call_Amount__c;
    
                if(lstFD.size() < 1000)
                {
                    fndUpdate.Total_Capital_Called__c = TotalAmt;
                }
                else
                {
                    Double Call_Amount = objFundDrawdownNew.Call_Amount__c - objFundDrawdownOld.Call_Amount__c;
                    fndUpdate.Total_Capital_Called__c = lstFD[0].Fund_Name__r.Total_Capital_Called__c + Call_Amount;
                }
                update fndUpdate;
            }
        }
        else if(Trigger.isDelete)
        {
            if(objFundDrawdownOld.Fund_Name__c != null)
            {
                lstFD = [select id, Call_Amount__c, Fund_Name__r.Total_Capital_Called__c from Fund_Drawdown__c where Fund_Name__c = :objFundDrawdownOld.Fund_Name__c Limit 1000];
                fndUpdate = new Fund__c(id = objFundDrawdownOld.Fund_Name__c);
                
                for(Integer i=0 ; i<lstFD.size() ; i++)
                    TotalAmt += lstFD[i].Call_Amount__c;
    
                if(lstFD.size() < 1000)
                {
                    fndUpdate.Total_Capital_Called__c = TotalAmt;
                }
                else
                {
                    Double Call_Amount = objFundDrawdownOld.Call_Amount__c;
                    fndUpdate.Total_Capital_Called__c = lstFD[0].Fund_Name__r.Total_Capital_Called__c - Call_Amount;
                }
                update fndUpdate;
            }
        }
    }
    else if(Trigger.isUndelete)
    {
        for(Fund_Drawdown__c fd : Trigger.new)
            fd.addError('Fund Drawdown cannot be mass undeleted.');
    }
}