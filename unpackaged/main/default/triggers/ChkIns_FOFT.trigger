trigger ChkIns_FOFT on Fund_of_Funds_Transaction__c (before insert) {
/*  New Implimentation:
    Developer               :   Manjot Singh 
    Product Version         :   PE 2.2
    Date of Creation        :   22/06/2009
    Purpose of Creation     :   To prevent the linking of Fund of Fund Transaction to an Institution ,a limited partner or a Company.
*/
    if(Trigger.size == 1)
    {
        String fund_Managers_Fund = '';
        for(Fund_of_Funds_Transaction__c obj : Trigger.new){
            fund_Managers_Fund = obj.Fund_Manager_s_Fund__c;
        }
        Account[] tempAccount = [Select RecordType.Name from Account where id = :fund_Managers_Fund];
        if(tempAccount.size()>0 && 'Fund Manager’s Fund' != tempAccount[0].RecordType.Name){
            for(Fund_of_Funds_Transaction__c obj : Trigger.new){
                obj.Fund_Manager_s_Fund__c.addError('Please select a "Fund Manager\'s Fund".');
            }
        }
        
    }
}