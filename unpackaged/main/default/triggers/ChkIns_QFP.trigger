trigger ChkIns_QFP on Quarterly_Financial_Performance__c (before insert) {
/*  New Implimentation:
        Developer               :   Manjot Singh 
        Product Version         :   PE 2.0
        Date of Creation        :   03/03/2009
        Purpose of Creation     :   To prevent the linking of QFP to a Institution or limited partner.

        Updated by              :   Amit Kumar
        Product Version         :   PE 2.2
        Date of Updation        :   02/07/2009
        Purpose of Updation     :   Dynamic error messages.
        
        Updated by              :   Deimple Lala
        Product Version         :   PE 2.5
        Date of Updation        :   30/01/2012
        Purpose of Updation     :   To prevent the linking of QFP to record types other than Private Equity record types.
                                    To prevent the linking of QFP to a Fund Manager or Fund Manager's Fund.
                                    
        Updated by              :   Deimple Lala
        Product Version         :   PE 3
        Date of Updation        :   01/06/2012
        Purpose of Updation     :   To allow the linking of QFP to a Fund Manager or record types other than Private Equity record types.
                                    To prevent the linking of QFP to a Fund Manager's Fund.                         
*/                                  
    if(Trigger.size == 1)
    {
        String company = '';
        for(Quarterly_Financial_Performance__c obj : Trigger.new){
            company = obj.Company__c;
        }
        Account[] tempAccount = [Select RecordType.Name from Account where id = :company];
        
        // if the record type of selected Company is Fund Manager’s Fund
        if(tempAccount.size()>0 && (tempAccount[0].RecordType.Name == 'Fund Manager’s Fund' ) ){
            for(Quarterly_Financial_Performance__c obj : Trigger.new){
                obj.Company__c.addError('A "Fund Manager\'s Fund" is not allowed to be associated with a "Quarterly Financial Performance".');
            }
        }
        
    }
}