/*************************************************************************************************************
Developer               :   Mohammad Ubaid
Product Version         :   PE 4.0
Date of Creation        :   22/01/2019
Purpose of Creation     :   To update Average Deal Quality and Total Deals shown fields of Account from Flow
**************************************************************************************************************/

trigger updateAccDealQuality on Account (after delete , after Undelete) {
    
        SET<ID> finalAccount = new SET<ID>();
        
        if(Trigger.isDelete){
            for(Account  accDel : Trigger.old){
                if(accDel.MasterRecordId != null)
                    finalAccount.add(accDel.MasterRecordId);
            }
        }
        
        if(Trigger.isUndelete)
        {
            for(Account  accDel : Trigger.new){
                finalAccount.add(accDel.Id);
            }
        }
         system.debug('finalAccount:::::::' + finalAccount);
        if(finalAccount.size()>0){
            callPipelineRollUpFlow.dealQualityAndShownForAccount(finalAccount);
        }
    
}