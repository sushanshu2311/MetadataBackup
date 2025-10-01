trigger chkIns_Upd_Del_Contact on Contact (before insert, before update,  Before Delete) {

    /*  New Implimentation:
        Developer               :   Manjot Singh 
        Product Version         :   PE 2.0
        Date of Creation        :   03/03/2009
        Purpose of Creation     :   1) To prevent the linking of Contact to a limited partner.
                                    2) To Prevent updation of Legal Name if there are related Fundraising Contact. 
        Date of Updation        :   22/06/2009
        Purpose of Updation     :   1) To prevent the linking of Contact to a Fund Manager.
    */
    
    /*  New Implimentation:
        Developer               :   Shruti Garg 
        Product Version         :   PE 2.5
        Date of Updation        :   27/01/2012
        Purpose of Updation     :   Prevent the Linking of Contact to a Fund Manager's Funds.                                     
    */      
    
    if(Trigger.size == 1 && (Trigger.isInsert || Trigger.isUpdate) )
    {    
        // (PE3.5, SK, 10Aug2017)
        Contact objContactNew = new Contact();
        for(Contact objContact : Trigger.New){
            objContactNew = objContact;
        }
        
        Boolean boolErr = true;
        if(Trigger.isupdate)
        {
            // (PE3.5, SK, 10Aug2017)
            Contact objContactOld = new Contact();
            for(Contact objContact : Trigger.old){
                objContactOld = objContact;
            }
            
            Contact conTemp = [Select id, (Select id from Fundraising_Contact__r) from Contact where id = :objContactOld.id];
            if(conTemp.Fundraising_Contact__r.size() > 0 && objContactOld.AccountId != objContactNew.AccountId)
            {
                objContactNew.addError('Value once set cannot be changed as there are related Fundraising Contacts.');
                boolErr = false;
            }
        }
        if(boolErr)
        {
            Account[] tempAccount = [Select RecordType.Name from Account where id = :objContactNew.AccountId]; 
            if(tempAccount.size()>0 )
            {
                if('Fund Manager’s Fund' == tempAccount[0].RecordType.Name || 'Fund Manager' == tempAccount[0].RecordType.Name || 'Institution' == tempAccount[0].RecordType.Name || 'Limited Partner' == tempAccount[0].RecordType.Name || 'Company' == tempAccount[0].RecordType.Name) 
                {
                    if('Fund Manager’s Fund' == tempAccount[0].RecordType.Name)       //Contact cannot be associated with Fund Manager's Fund
                    {    
                        objContactNew.AccountID.addError('Contact cannot be associated with a "Fund Manager’s Fund".');
                    }
                }
            }
        }
    }
    
    
    
    
    /*  New Implimentation:
        Developer               :   Ajay Agnihotri
        Product Version         :   MnA 2.1
        Date of Creation        :   18/Aug/2012
        Purpose of Creation     :   To delete all associated Marketing Prospects records w.r.t Contacts.
    */
    if(Trigger.isDelete)
    {
        List<Marketing_Prospect__c> lstMPs=new List<Marketing_Prospect__c>();  // List To Get MP's with associated Contacts
        set<id> MPid = new set<id>();
    
        for(Contact con: trigger.old){
            MPid.add(con.id);
        }
        
        //To Get all Prospects with associated Contacts.
        lstMPs=[Select id,Contact__c from Marketing_Prospect__c where Contact__c in:MPid];
         
        if(lstMPs.size()>10000){
            for(Contact con1: trigger.old)
            {
                con1.adderror('Cannot delete selected Contacts as there are more than 10000 associated Marketing Prospects records exists, please deselect some Contacts and try again.');
            }
        }
        else{
            delete lstMPs;
        }
    }
    
    
}