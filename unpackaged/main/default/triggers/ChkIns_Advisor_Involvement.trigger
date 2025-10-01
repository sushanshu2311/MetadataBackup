trigger ChkIns_Advisor_Involvement on Advisor_Involvement__c (before insert) {
/*  New Implimentation:
    Developer               :   Manjot Singh 
    Product Version         :   PE 2.0
    Date of Creation        :   03/03/2009
    Purpose of Creation     :   To prevent the linking of Advisor Involvement to a Company or limited partner.
    
    Updated by              :   Amit Kumar
    Product Version         :   PE 2.2
    Date of Updation        :   02/07/2009
    Purpose of Updation     :   Dynamic error messages.
    
    Updated by              :   Deimple Lala
    Product Version         :   PE 2.5
    Date of Updation        :   30/01/2012
    Purpose of Updation     :   To prevent the linking of Advisor Involvement to record types other than Private Equity record types.
                                To prevent the linking of Advisor Involvement to a Fund Manager’s Fund.
                                
    Updated by              :   Deimple Lala
    Product Version         :   PE 3
    Date of Updation        :   31/05/2012
    Purpose of Updation     :   To allow linking of Advisor Involvement to record types other than Private Equity record types.
*/                                  
    if(Trigger.size == 1)
    {
        String LegalNameId = '';
        for(Advisor_Involvement__c obj : Trigger.new){
            LegalNameId = obj.Legal_Name__c;
        }
        Account[] tempAccount = [Select RecordType.Name From Account Where id = :LegalNameId];
        if(tempAccount.size() > 0 && tempAccount[0].RecordType.Name == 'Fund Manager’s Fund') {
            for(Advisor_Involvement__c obj : Trigger.new){
                obj.Legal_Name__c.addError('Please select Legal Name other than "Fund Manager’s Fund".');
            }
        }
        
    }
}