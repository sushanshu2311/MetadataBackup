trigger chkIns_Upd_Del_Fundraising_Contact on Fundraising_Contact__c (before insert, before update,  after delete)
{
    /*  New Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   24/12/2008
        Purpose of Creation     :   1.  To prevent duplicate Fundraising Contact creation.
                                    2.  To prevent Institution updation via Sys Admin, -values once set cannot be changed.
        Date of Updation        :   26/03/2009
        Purpose of Updation     :   1.  Set Primary, For selecting exactly one primary Fundraising Contact.
    */
    
    /*  New Implementation:
        Developer               :   Shruti Garg
        Product Version         :   PE 2.4
        Date of Updation        :   2/1/2012
        Purpose of Updation     :   Prevent the linking of contact related to the institution of record type other than PE product.
        
        Updated by:
        Developer               :   Shruti Garg
        Product Version         :   PE 2.5
        Date of Updation        :   8/6/2012
        Purpose of Updation     :   Linking of contact related to the institution of record type other than PE product.
                                    Prevent the creation of Fundraising Contact with orphan Fundraising
                                    Prevent the creation of Fundraising Contact with orphan Contact
                                    
        Updated by:
        Developer               :   Sameer Rath
        Product Version         :   PE 3.0
        Date of Updation        :   8/10/2015
        Purpose of Updation     :   Bulkified the whole trigger. 
    */
    
    if(Trigger.isInsert || Trigger.isUpdate){
        map<id,Fundraising__c> fundRmap = new map<id,Fundraising__c>();
        map<id,id> conAccId = new map<id,id>(); 
        set<string> testDuplicateAdvisor = new set<string>();
        list<Advisor__c> AdvList = new list<Advisor__c>();
        map<id,id> primaryCheck = new map<id,id>();
        list<Fundraising_Contact__c> listFC = new list<Fundraising_Contact__c>();
        boolean updateFC = false;
        list<id> lstConids =  new List<id>();
        list<id> lstFundraisingids =  new List<id>();
        
        for(Fundraising_Contact__c tempFc : trigger.new)
        {
            if(tempFc.Contact__c != null){
                lstConids.add(tempFc.Contact__c);
            }                
            lstFundraisingids.add(tempFc.Fundraising__c);
        }
        
        list<Fundraising__c> lstFundraisingRecs = [select id,Legal_Name__c, (Select id,Institution__c,Contact__c from Fundraising_Contact__r) from Fundraising__c where id in :lstFundraisingids];
        for(Fundraising__c temp_fundr: lstFundraisingRecs)
        {
            fundRmap.put(temp_fundr.id,temp_fundr);
        }
        list<contact> lstContacts = [select id, accountId from contact where id in : lstConids];
        
        for(contact temp_con: lstContacts)
        {
            conAccId.put(temp_con.id,temp_con.accountId);
        }
        
        list<Advisor__c> lstAdvisors = [select Client__c,Advisor__c,Fundraising__c,Role__c from Advisor__c LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]; //(PE3.5, SK, 16Aug2017): added limit clause
        
        for(Advisor__c adv:lstAdvisors){
            string comb_adv;
            comb_adv = adv.Client__c+'_@_'+adv.Advisor__c+'_@_'+adv.Fundraising__c+'_@_'+adv.Role__c;
            testDuplicateAdvisor.add(comb_adv);
        }
        list<Fundraising_Contact__c> lstFundraising_Contacts = [select IsPrimary__c,Fundraising__c from Fundraising_Contact__c where IsPrimary__c = true];
        
        for(Fundraising_Contact__c tempFcR : lstFundraising_Contacts){
            primaryCheck.put(tempFcR.Fundraising__c , tempFcR.id);
        }
        
        
        if(Trigger.isInsert)
        {
            for(Fundraising_Contact__c tempFc : trigger.new)
            {
                string presentComb;
                if(!CreateMassFundraisingCls.triggerenabled){
                    for(integer i=0;i<fundRmap.get(tempFc.Fundraising__c).Fundraising_Contact__r.size();i++)
                    {
                        if((fundRmap.get(tempFc.Fundraising__c).Fundraising_Contact__r[i].Institution__c == tempFc.Institution__c) && (fundRmap.get(tempFc.Fundraising__c).Fundraising_Contact__r[i].Contact__c == tempFc.Contact__c)){
                            tempFc.addError('Duplicate Fundraising Contact cannot be created');
                        }
                    }
                }
                if(fundRmap.get(tempFc.Fundraising__c).Legal_Name__c == null)
                {
                    tempFc.Fundraising__c.addError('Please associate this "Fundraising" with a Legal Name.');
                }
                
                if(conAccId.get(tempFc.Contact__c) == null){
                    tempFc.Contact__c.addError('Please associate this Contact with a Legal Name.');
                }
                else
                {
                    tempFc.Institution__c = conAccId.get(tempFc.Contact__c);
                    presentComb = fundRmap.get(tempFc.Fundraising__c).Legal_Name__c+'_@_'+tempFc.Institution__c+'_@_'+tempFc.Fundraising__c+'_@_'+'Advisor';
                    if((!testDuplicateAdvisor.contains(presentComb)) && (tempFc.Institution__c != fundRmap.get(tempFc.Fundraising__c).Legal_Name__c))
                    {
                        Advisor__c tempAdvisor = new Advisor__c();
                        tempAdvisor.Advisor__c = tempFc.Institution__c;
                        tempAdvisor.Client__c = fundRmap.get(tempFc.Fundraising__c).Legal_Name__c;
                        tempAdvisor.Fundraising__c = tempFc.Fundraising__c; 
                        tempAdvisor.Role__c = 'Advisor';
                        tempAdvisor.Reverse_Role__c = 'Client';
                        AdvList.add(tempAdvisor);
                    }
                }
            }
            try
            {
                database.insert(AdvList);
            }
            catch(dmlException ex)
            {
                system.debug(ex);
            }
        }
        else
        {
            for(Fundraising_Contact__c tempFc : trigger.new)
            {
                if(tempFc.Institution__c != Trigger.oldMap.get(tempFc.id).Institution__c)
                    tempFc.addError('Value once set cannot be changed');
            }
        }   
        
        // To Handle the set Primary Contact Functionality
        /*
            This is special handling for Admin Profile to overcome the Limitation of selecting more than one Primary Contacts 
            For other profile this field is Read only. 
            This piece of code will reset the Primary attribute of other Fundraising Contacts to false
            In order to keep exactly one Fundraising Contact as Primary Contact of the Fundraising. 
        */ 
        
        for(Fundraising_Contact__c tempFc : trigger.new) 
        {
            if(tempFc.IsPrimary__c)
            {
                updateFC = true;
                Fundraising_Contact__c tempFcr = new Fundraising_Contact__c(id = primaryCheck.get(tempFc.Fundraising__c));
                tempFcr.IsPrimary__c = false;
                listFC.add(tempFcr);
            }
        }
        
        if(updateFC){
            try{
                update listFC;
                updateFC = false;
            }
            catch(dmlexception ex)
            {
                system.debug('Error in update'+ex);
            }
        }
    }
    
    
    
    
    
    /*  New Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   29/12/2008
        Purpose of Creation     :   To delete the Advisor record if you are deleting last Fundraising Contact of related Fundraising.
    */
    /*  New Implementation:
        Developer               :   Sameer Rath
        Product Version         :   PE 3.0
        Date of Updation        :   8/10/2015
        Purpose of Updation     :   Bulkified the whole trigger. 
    */  
    IF(Trigger.isDelete)
    {
        list<Advisor__c> delAdvisor = new list<Advisor__c>();
        map<string,Advisor__c> getAdvisor = new map<string,Advisor__c>();
        map<id,id> getClientId = new map<id,id>();
        
        for(Advisor__c temp_adv :[select id,Client__c,Advisor__c,Fundraising__c,Role__c from Advisor__c LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]){ //(PE3.5, SK, 16Aug2017): added limit clause
            string comb_adv;
            comb_adv = temp_adv.Advisor__c+'_@_'+temp_adv.Client__c+'_@_'+temp_adv.Fundraising__c;
            getAdvisor.put(comb_adv,temp_adv);
        }
        
        for(Fundraising__c temp_adv :[select id,Legal_name__c from Fundraising__c LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]){ //(PE3.5, SK, 16Aug2017): added limit clause
            getClientId.put(temp_adv.id,temp_adv.Legal_name__c);
        }
        
        for(Fundraising_Contact__c tempFc : Trigger.old)
        {
            Advisor__c delAv =  getAdvisor.get(tempFc.Institution__c+'_@_'+getClientId.get(tempFc.Fundraising__c)+'_@_'+tempFc.Fundraising__c);
            if(delAv != null)
                delAdvisor.add(delAv);
        }
        
        if(delAdvisor.size() >0)
            delete delAdvisor;
    }
    
    
}