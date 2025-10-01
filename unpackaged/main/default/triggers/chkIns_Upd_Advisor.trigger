trigger chkIns_Upd_Advisor on Advisor__c (before insert, before update)
{
    /*  New Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   03/03/2009
        Purpose of Creation     :   To prevent:
                                    1. The duplication of Advisor. If Advisor, Client, Role, Fundraising are same.
                                    2. Linking of Advisors or Clients to same Institution.
                                    3. Linking of Advisors or Clients to a limited partner.
    */
    
    /*  New Implementation : 
        Developer               :   Shruti Garg
        Product Version         :   PE 2.4
        Date of Creation        :   27/01/2012
        Purpose of Creation     :   1. To prevent Linking of Advisor and Client to Record Types other then PE product.
                                    2. Creating orphan Advisors when Advisor is blank and Fundraising is blank.
                                    3. Creating orphan Clients when Client is blank and Fundraising is blank.
                                    4. Allow Advisor or Client to be associated with all the 5 record type of PE Product.
                                    
        Updated By  :
        Developer               :   Shruti Garg
        Product Version         :   PE 2.5
        Date of Creation        :   06/06/2012
        Purpose of Creation     :   1. Linking of Advisor and Client to Record Types other then PE product.
                                                                        
    */
    if(Trigger.size == 1)
    {
        // (PE3.5, SK, 10Aug2017)
        Advisor__c objAdvisory = new Advisor__c();
        for(Advisor__c objt : Trigger.new){
            objAdvisory = objt;
        }
        
        
        Account []accTemp = [Select id, RecordType.Name from Account where id IN (:objAdvisory.Client__c, :objAdvisory.Advisor__c)];
        String advisorRecordTypeName = '';  //  To store recordtype of Advisor
        String clientRecordTypeName = '';   //  To store recordtype of Client
        for(Account a : accTemp)
        {
            if(a.id == objAdvisory.Advisor__c && objAdvisory.Advisor__c != null)
                advisorRecordTypeName = a.RecordType.Name; 
            if(a.id == objAdvisory.Client__c && objAdvisory.Client__c != null)
                clientRecordTypeName = a.RecordType.Name;
        }
        //system.debug('advisorRecordTypeName '+advisorRecordTypeName );
        //system.debug('clientRecordTypeName'+clientRecordTypeName);
        
        //if(clientRecordTypeName == 'Institution' || clientRecordTypeName == 'Limited Partner' || clientRecordTypeName == 'Company' || clientRecordTypeName == 'Fund Manager' || clientRecordTypeName == 'Fund Manager’s Fund')      // Code for preventing linking of Client to Recordtype other than PE Product.
        //{
        //system.debug('clientRecordTypeName'+clientRecordTypeName);
        
        if(Trigger.isInsert)
        {
          //if(accTemp.size() == 1 && ( advisorRecordTypeName == 'Institution' || advisorRecordTypeName == 'Limited Partner' || advisorRecordTypeName == 'Company' || advisorRecordTypeName == 'Fund Manager'))
            if(accTemp.size() == 1 )
                objAdvisory.addError('Client and Advisor should not be the same.');
            else
                 if(objAdvisory.Fundraising__c == null)   // Error message when creating duplicate Advisor without Fundraising.
                        {
                            if([Select count() from Advisor__c where Client__c=:objAdvisory.Client__c and Advisor__c=:objAdvisory.Advisor__c and Fundraising__c=null and Role__c=:objAdvisory.Role__c]>0)
                                objAdvisory.addError('An advisor/client record already exists.');
                        }
                        else                                       // Error message when creating duplicate Advisor with Fundraising.
                            if([Select count() from Advisor__c where Client__c=:objAdvisory.Client__c and Advisor__c=:objAdvisory.Advisor__c and Fundraising__c=:objAdvisory.Fundraising__c and Role__c=:objAdvisory.Role__c]>0)
                                objAdvisory.addError('An advisor/client record already exists.');
        }
        else
        {
            // (PE3.5, SK, 10Aug2017)
            Advisor__c objAdvisoryOLD = new Advisor__c();
            for(Advisor__c objt : Trigger.old){
                objAdvisoryOLD = objt;
            }
            
            if(objAdvisoryOLD.Fundraising__c != null)                     //Prevent the changes made in Fundraising,Advisor and Client when Fundraising is not null
            {
                if(objAdvisory.Fundraising__c != objAdvisoryOLD.Fundraising__c || objAdvisory.Advisor__c != objAdvisoryOLD.Advisor__c || objAdvisory.Client__c != objAdvisoryOLD.Client__c)
                {
                    objAdvisory.addError('Value once set cannot be changed.');
                }
            }
            else                                                                                                                
            {
                if(objAdvisoryOLD.Advisor__c != NULL && objAdvisory.Advisor__c != objAdvisoryOLD.Advisor__c )    //Advisor cannot be change when Advisor is not null and Fundraising is null
                {
                    objAdvisory.addError('Value once set cannot be changed.');
                }
                else
                {
                    if(objAdvisoryOLD.Client__c != null && objAdvisory.Client__c != objAdvisoryOLD.Client__c)   //Client cannot be change when Client is not null and Fundraising is null
                    {
                        objAdvisory.addError('Value once set cannot be changed.');
                    }
                    else
                    {
                        if(objAdvisory.Fundraising__c != objAdvisoryOLD.Fundraising__c)                       //Fundraising cannot be change
                        {
                           objAdvisory.addError('Value once set cannot be changed.');
                        }
                        else
                        {
                            if(objAdvisory.Fundraising__c == objAdvisoryOLD.Fundraising__c && objAdvisory.Fundraising__c == null && objAdvisory.Role__c != objAdvisoryOLD.Role__c) // Error message when updating role of existing Advisor without Fundraising.
                                if([Select count() from Advisor__c where Client__c=:objAdvisory.Client__c and Advisor__c=:objAdvisory.Advisor__c and Fundraising__c=null and Role__c=:objAdvisory.Role__c]>0)
                                    objAdvisory.Role__c.addError('Advisor with role "'+ objAdvisory.Role__c +'" already exists.');
                        }
                    }
                }                       
            }
        }
    }
}