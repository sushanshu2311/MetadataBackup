trigger chkIns_Upd_Del_Fund_Distribution on Fund_Distribution__c (before insert, after update, after delete, after undelete)
{
    if(Trigger.size == 1)
    {
        List<Fund_Distribution__c> lstFD = new List<Fund_Distribution__c>();
        Double TotalAmt = 0.00;
        Fund__c fndUpdate;
        
        // (PE3.5, SK, 10Aug2017)
        Fund_Distribution__c objFundDistrNew = new Fund_Distribution__c();
        Fund_Distribution__c objFundDistrOld = new Fund_Distribution__c();
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Fund_Distribution__c objFDistr : Trigger.New){
                objFundDistrNew = objFDistr;
            }
        }
        if(Trigger.isUpdate || Trigger.isDelete){
            for(Fund_Distribution__c objFDistr : Trigger.old){
                objFundDistrOld = objFDistr;
            }
        }
        
        
        if(Trigger.isInsert)
        {
            if(objFundDistrNew.Fund_Name__c == null)
                objFundDistrNew.Fund_Name__c.addError('Please select a Fund Name.');
        }
        else if(Trigger.isUpdate)
        {
            if(objFundDistrNew.Fund_Name__c != null)
            {
                lstFD = [select id, Capital_Returned_Recallable__c, Fund_Name__r.Total_Recallable_Capital__c from Fund_Distribution__c where Fund_Name__c = :objFundDistrNew.Fund_Name__c and Capital_Returned_Recallable__c > 0  Limit 1000];
                fndUpdate = new Fund__c(id = objFundDistrNew.Fund_Name__c);
                
                for(Integer i=0 ; i<lstFD.size() ; i++)
                    TotalAmt += lstFD[i].Capital_Returned_Recallable__c;
    
                if(lstFD.size() < 1000)
                {
                    fndUpdate.Total_Recallable_Capital__c = TotalAmt;
                }
                else
                {
                    Double Capital_Returned_Recallable = objFundDistrNew.Capital_Returned_Recallable__c - objFundDistrOld.Capital_Returned_Recallable__c;
                    fndUpdate.Total_Recallable_Capital__c = lstFD[0].Fund_Name__r.Total_Recallable_Capital__c + Capital_Returned_Recallable;
                }
                update fndUpdate;
            }
        }
        else if(Trigger.isDelete)
        {
            if(objFundDistrOld.Fund_Name__c != null)
            {
                lstFD = [select id, Capital_Returned_Recallable__c, Fund_Name__r.Total_Recallable_Capital__c from Fund_Distribution__c where Fund_Name__c = :objFundDistrOld.Fund_Name__c and Capital_Returned_Recallable__c > 0 Limit 1000];
                fndUpdate = new Fund__c(id = objFundDistrOld.Fund_Name__c);
                
                for(Integer i=0 ; i<lstFD.size() ; i++)
                    TotalAmt += lstFD[i].Capital_Returned_Recallable__c;
    
                if(lstFD.size() < 1000)
                {
                    fndUpdate.Total_Recallable_Capital__c = TotalAmt;
                }
                else
                {
                    Double Capital_Returned_Recallable = objFundDistrOld.Capital_Returned_Recallable__c;
                    fndUpdate.Total_Recallable_Capital__c = lstFD[0].Fund_Name__r.Total_Recallable_Capital__c - Capital_Returned_Recallable;
                }
                update fndUpdate;
            }
        }
    }
    else if(Trigger.isUndelete)
    {
        for(Fund_Distribution__c fd : Trigger.new)
            fd.addError('Fund Distribution cannot be mass undeleted.');
    }
}