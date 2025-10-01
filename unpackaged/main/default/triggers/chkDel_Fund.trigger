trigger chkDel_Fund on Fund__c (before delete)
{
    /*  New Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   23/12/2008
        Purpose of Creation     :   To prevent the deletion of Fund if there exists related records.

        Developer               :   Amit Kumar
        Product Version         :   PE 2.2
        Date of Updation        :   13/07/2009
        Purpose of Updation     :   To prevent the deletion of Fund if there exists Fund Drawdown, Fund Distribution.
    */
    
    if(Trigger.size == 1)
    {
        // (PE3.5, SK, 10Aug2017)
        Fund__c objFundOld = new Fund__c();
        for(Fund__c objFund : Trigger.old){
            objFundOld = objFund;
        }
        
        try
        {
            Fund__c fundTemp = [Select id, (Select Id From Advisor_Involvement__r), (Select Id From Fund_Drawdown__r), (Select Id From Fund_Distribution__r), (Select id from Fundraising__r), (Select id from Partnership__r) from Fund__c where id = :objFundOld.id];
            Boolean isAccDependent = false;
            List<String> errObjects = new List<String>();   // For making List of SObject which have related records regarding Fund.
             
            if(fundTemp.Advisor_Involvement__r.size() > 0)
            {
                errObjects.add('Advisor Involvement');
                isAccDependent  = true;
            }
            if(fundTemp.Fundraising__r.size() > 0)
            {
                errObjects.add('Fundraising');
                isAccDependent  = true;
            }
            if(fundTemp.Fund_Drawdown__r.size() > 0)
            {
                errObjects.add('Fund Drawdown');
                isAccDependent  = true;
            }
            if(fundTemp.Fund_Distribution__r.size() > 0)
            {
                errObjects.add('Fund Distribution');
                isAccDependent  = true;
            }
            if(fundTemp.Partnership__r.size() > 0)
            {
                Boolean haveRecords = False;
                for(Partnership__c p : [Select id, (Select id from Commitment__r), (Select id from Transfer__r) from Partnership__c where id in :fundTemp.Partnership__r])
                {
                    if(p.Commitment__r.size() > 0 || p.Transfer__r.size() > 0)
                    {
                        haveRecords = True;
                        break;
                    }
                }
                if(haveRecords)
                {
                    errObjects.add('Partnership');
                    isAccDependent  = true;
                }
            }
            if(isAccDependent)  // For Genric Error messages if any.
            {
                String err = 'Please delete the related "'+errObjects[0];
                if(errObjects.size()>1)
                {
                    for(Integer tempInt=1 ; tempInt<(errObjects.size()-1) ; tempInt++)
                        err += '", "'+errObjects[tempInt];
                    err += '" and "'+errObjects[errObjects.size()-1]+'" records before deleting the "Fund" record.';
                }
                else
                    err += '" records before deleting the "Fund" record.';
                objFundOld.addError(err);
            }
        }
        catch(QueryException e) // Error Msg. statement. If governor limits are triggered.
        {
            objFundOld.addError('Please delete all the related records before deleting this record.');
        }
    }
}