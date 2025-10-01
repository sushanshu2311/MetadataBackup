trigger chkDel_Partnership on Partnership__c (before delete) {
    /*  New Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   09/01/2009
        Purpose of Creation     :   To prevent the deletion of Partnership if there exists related records.
    */
    
    if(Trigger.size == 1)
    {
        // (PE3.5, SK, 10Aug2017)
        Partnership__c objPartnershipOld = new Partnership__c();
        for(Partnership__c objPartnership : Trigger.old){
            objPartnershipOld = objPartnership;
        }
        
        try
        {
            Partnership__c partTemp = [Select id, (Select id from Commitment__r), (Select id from Transfer__r) from Partnership__c where id = :objPartnershipOld.id];
            Boolean isAccDependent = false;
            List<String> errObjects = new List<String>();   // For making List of SObject which have related records regarding Account. 

            if(partTemp.Commitment__r.size() > 0)
            {
                errObjects.add('Commitment');
                isAccDependent  = true;
            }
            if(partTemp.Transfer__r.size() > 0)
            {
                errObjects.add('Transfer');
                isAccDependent  = true;
            }
            
            if(isAccDependent)  // For Genric Error messages if any.
            {
                String err = 'Please delete the related "'+errObjects[0];
                if(errObjects.size()>1)
                {
                    err += '" and "'+errObjects[1]+'" records before deleting the "Partnership" record.';
                }
                else
                    err += '" records before deleting the "Partnership" record.';
                objPartnershipOld.addError(err);
            }
        }
        catch(QueryException e) // Error Msg. statement. If governor limits are triggered.
        {
            objPartnershipOld.addError('Please delete all the related records before deleting this record.');
        }
    }
}