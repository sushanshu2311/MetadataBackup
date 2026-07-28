/*************************************************************************************************************
Developer               :   Mohammad Ubaid
Product Version         :   PE 4.0
Date of Creation        :   22/01/2019
Purpose of Creation     :   To update Deal Quality and Deals Shown fields of Contact from Flow
**************************************************************************************************************/

trigger updateContDealQuality on Contact (after delete , after Undelete) {

        SET<ID> finalContact = new SET<ID>();
       
        if(Trigger.isDelete){
            for(Contact  contDel : Trigger.old){
                if(contDel.MasterRecordId != null)
                    finalContact.add(contDel.MasterRecordId);
            }
        }
        
        if(Trigger.isUndelete)
        {
            for(Contact  contDel : Trigger.new){
                finalContact.add(contDel.Id);
            }
        }
        system.debug('finalContact:::::::' + finalContact);
        if(finalContact.size()>0){
            callPipelineRollUpFlow.dealQualityAndShownForContact(finalContact);
        }
}