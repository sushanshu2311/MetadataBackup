trigger chkIns_Del_Account on Account (before insert, before update,  before delete)
{
    /*  Added Functionality:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   02/03/2009
        Purpose of Creation     :   Listed below:
                                    1. To check weather Institution is selected as Parent while creating/updating Limited Partner.
                                    2. To check weather Parent is not selected while creating/updating Institution or Company.   
                                    3. To prevent the change in Parent Institution of Limited Partner if there exists related transfers or commitments.
    */
    
    
    
     /*  Added Functionality:
        Developer               :   Ankit Gupta 
        Product Version         :   PE 2.1
        Date of Creation        :   27/1/2012
        Purpose of Creation     :   Listed below:
                                    1. To allow the company, Institution or (Fund manager, fund manager’s fund on the basis of same condition) as a parent institution of another institution.
                                    2. To allow the company, Institution, or (Fund manager, fund manager’s fund on the basis of same condition) as a parent institution of a company.
                                    3. To allow the company or Institution as a parent institution of a Fund manager.

                                    
    */
         /*  Added Functionality:
        Developer               :   Brahmaditya bhaskar
        Product Version         :   PE 3.5
        Date of Creation        :   20/06/2016
        Purpose of Creation     :   Listed below:
                                    1. To allow the LP's parent as a Individual Investor. Line No 104


                                    
    */
    /* 
        Developer               :  Hemendra Singh Rajawat
        Product Version         :  PE 4.5
		Date of Creation        :  30/07/2020
        Purpose of Creation     :  One More Condition added for Portfolio_Company record type with Company record type
    */
    
    if(Trigger.size == 1 && (Trigger.isInsert || Trigger.isUpdate) )
    {
       // (PE3.5, SK, 10Aug2017)
        Account objAccountNew = new Account();
        for(Account objAccount : Trigger.new){
            objAccountNew = objAccount;
        } 
       
       Boolean boolErr = true; // Vraiable for Check the Trigger Size
       String strAccountRecordTypeName; // For Account Record type Name
       set<string> vowelset=new set<string>{'a','e','i','o','u','A','E','I','O','U'};      
       
       if(boolErr)  // Execut when only one record is insert or update.
       {
            strAccountRecordTypeName = [select name from RecordType where id =: objAccountNew.RecordTypeId].name;  // To Store Account RecordType Name.
            String strParentAccountRecordTypeName = (objAccountNew.parentId == null) ? null : [select RecordType.name from Account where id = :objAccountNew.parentId].RecordType.name;
            if(strAccountRecordTypeName=='Company' || strAccountRecordTypeName=='Portfolio Company' || strAccountRecordTypeName=='Fund Manager' ||strAccountRecordTypeName=='Fund Manager’s Fund' ||strAccountRecordTypeName=='Institution' || strAccountRecordTypeName=='Limited Partner')  // checking the Private Equity Record Type
            {
                
                if(Trigger.isInsert) // Check for Inser 
                {
                    if(strAccountRecordTypeName=='Institution')  // check for Institution
                    {
                        if(strParentAccountRecordTypeName!=null) // check Parent Institution is not blank
                        {
                            if(strParentAccountRecordTypeName=='Limited Partner') // If parent Institution Record type is Limited Partner
                            {
                                objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent Institution of an "Institution".');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager') && (ProductSetting__c.getInstance('InstitutionwithFM').status__c!=true) ) // If parent Institution Record type is Fund Manager
                            {
                                objAccountNew.parentId.addError(' A "Fund Manager" is not allowed to be a Parent Institution of an "Institution".');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager’s Fund') && (ProductSetting__c.getInstance('InstitutionwithFMF').status__c!=true) ) // If parent Institution Record type is Fund Manager’s Fund
                            {
                                objAccountNew.parentId.addError('A "Fund Manager’s Fund" is not allowed to be a Parent Institution of an "Institution".');
                            }
                            else if(strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Institution')  //Check Parent Institution Record type is Company or Institution
                            {
                                
                            }
                        }
                        
                    }
                    else if(strAccountRecordTypeName=='Company' || strAccountRecordTypeName=='Portfolio Company')  // check for Company
                    {
                        if(strParentAccountRecordTypeName!=null) // check Parent Institution is not blank
                        {
                            if(strParentAccountRecordTypeName=='Limited Partner') // If parent Institution Record type is Limited Partner
                            {
                                objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent Institution of a "Company". ');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager') && (ProductSetting__c.getInstance('CompanywithFM').status__c!=true) ) // If parent Institution Record type is Fund Manager
                            {
                                objAccountNew.parentId.addError('A "Fund Manager" is not allowed to be a Parent Institution of a "Company".');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager’s Fund') && (ProductSetting__c.getInstance('CompanywithFMF').status__c!=true) ) // If parent Institution Record type is Fund Manager’s Fund
                            {
                               
                                objAccountNew.parentId.addError('A "Fund Manager’s Fund" is not allowed to be a Parent Institution of a "Company".');
                            }
                            else if(strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Portfolio Company' || strParentAccountRecordTypeName=='Institution')  //Check Parent Institution Record type is Company or Institution
                            {
                                
                            }
                            
                        }
                        
                    }
                    else if(strAccountRecordTypeName=='Limited Partner')  // check for Limited Partner
                    {
                        if(strParentAccountRecordTypeName!=null) //Check Parent institution is not blank
                        {
                            if(strParentAccountRecordTypeName!='Institution'&&strParentAccountRecordTypeName!='Individual Investor') // check parent institution record type is not the Institution ****updated by brahma
                            {
                                objAccountNew.parentId.addError('Please select an "Institution" or "Individual Investor" as a parent of the "Limited Partner".');
                            }
                        }
                        else
                        {
                            objAccountNew.parentId.addError('You must enter a value.');
                        }
                            
                        
                        
                    }
                    else if(strAccountRecordTypeName=='Fund Manager')  // check for Fund Manager
                    {
                        if(strParentAccountRecordTypeName!=null) //Check Parent institution is not blank
                        {
                            if(strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Portfolio Company' || strParentAccountRecordTypeName=='Institution' || strParentAccountRecordTypeName=='Fund Manager') // check parent institution record type is Institution,Company or fund manager
                            {
                                
                            }
                            else if(strParentAccountRecordTypeName=='Fund Manager’s Fund') //Check for the Parent Institution Record Type is Fund Manager's Fund
                            {                                 
                                objAccountNew.parentId.addError('A "Fund Manager\'s Fund" is not allowed to be a Parent Institution of a "Fund Manager".');
                            }
                            else if( strParentAccountRecordTypeName=='Limited Partner') //Check for the Parent Institution Record Type is Limited Partner 
                            {                                 
                                objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent Institution of a "Fund Manager".');
                            }
                        }
                    }
                    else if(strAccountRecordTypeName=='Fund Manager’s Fund')  // check for Fund Manager’s Fund
                    {
                        if(strParentAccountRecordTypeName!=null) //Check Parent institution is not blank
                        {
                            if(strParentAccountRecordTypeName!='Fund Manager')
                            {
                                objAccountNew.parentId.addError('Please select a "Fund Manager" as the Parent of a "Fund Manager\'s Fund".');
                            }
                        }
                        else // execute when paraent institution is blank
                        {
                            objAccountNew.parentId.addError('You must enter a value.');
                        }
                    }
                    
                    
                    
                } // Trigger IsInsert End
                If(trigger.isUpdate)
                {
                    // (PE3.5, SK, 10Aug2017)
                    Account objAccountOld = new Account();
                    for(Account objAccount : Trigger.old){
                        objAccountOld = objAccount;
                    } 
                    
                    if(strAccountRecordTypeName=='Institution')  // check for Institution
                    {
                        if(strParentAccountRecordTypeName!=null)
                        {
                            if(strParentAccountRecordTypeName=='Limited Partner') // If parent Institution Record type is Limited Partner
                            {
                                objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent Institution of an "Institution".');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager') && (ProductSetting__c.getInstance('InstitutionwithFM').status__c!=true) ) // If parent Institution Record type is Fund Manager
                            {
                                objAccountNew.parentId.addError('A "Fund Manager" is not allowed to be a Parent Institution of an "Institution".');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager’s Fund') && (ProductSetting__c.getInstance('InstitutionwithFMF').status__c!=true) ) // If parent Institution Record type is Fund Manager’s Fund
                            {
                                objAccountNew.parentId.addError('A "Fund Manager’s Fund" is not allowed to be a Parent Institution of an "Institution".');
                            }
                            else if(strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Portfolio Company' || strParentAccountRecordTypeName=='Institution')  // Check if Paraent Institution Record type is company or institution
                            {
                                
                            }
                        }
                        
                    }
                    else if(strAccountRecordTypeName=='Company' || strAccountRecordTypeName=='Portfolio Company')  // check for Company
                    {
                        if(strParentAccountRecordTypeName!=null)
                        {
                            if(strParentAccountRecordTypeName=='Limited Partner') // If parent Institution Record type is Limited Partner
                            {
                                objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent Institution of a "Company". ');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager') && (ProductSetting__c.getInstance('CompanywithFM').status__c!=true) ) // If parent Institution Record type is Fund Manager
                            {
                                objAccountNew.parentId.addError('A "Fund Manager" is not allowed to be a Parent Institution of a "Company".');
                            }
                            else if((strParentAccountRecordTypeName=='Fund Manager’s Fund') && (ProductSetting__c.getInstance('CompanywithFMF').status__c!=true) ) // If parent Institution Record type is Fund Manager’s Fund
                            {
                               
                                objAccountNew.parentId.addError('A "Fund Manager’s Fund" is not allowed to be a Parent Institution of a "Company".');
                            }
                            else if(strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Portfolio Company' || strParentAccountRecordTypeName=='Institution') // Check if Paraent Institution Record type is company or institution
                            {
                                
                            }
                        }
                        
                    }
                    else if(strAccountRecordTypeName=='Limited Partner')  // check for Company
                    {
                        Account accTemp = [Select id, RecordType.Name, (Select id from Commitment__r limit 1000), (Select id from Transfer__r limit 1000) from Account where id = :objAccountNew.id];
                        strAccountRecordTypeName = accTemp.RecordType.Name;
                        if(objAccountNew.ParentID != objAccountOld.ParentID && strAccountRecordTypeName == 'Limited Partner' && (accTemp.Commitment__r.size() > 0 || accTemp.Transfer__r.size() > 0))  // Check limited partner has commitement or transfer
                        {
                            objAccountNew.ParentID.addError('Value once set cannot be changed as there are related "Transfer" or "Commitment" record(s).');
                        
                        }       
                        else if(strParentAccountRecordTypeName!=null) // check Parent institution is not blank
                        {
                            if(strParentAccountRecordTypeName!='Institution'&& strParentAccountRecordTypeName!='Individual Investor')// check paraent Insitution record type is not institution
                            {
                                    objAccountNew.parentId.addError('Please select an "Institution" or "Individual Investor" as a parent of the "Limited Partner".');
                            }
                        }
                        
                        else // When parent institution is blank
                        {
                            objAccountNew.parentId.addError('You must enter a value.');
                        }
                            
                        
                        
                    }
                    else if(strAccountRecordTypeName=='Fund Manager')  // check for Fund Manager
                    {
                        if(strParentAccountRecordTypeName!=null) //Check Parent institution is not blank
                        {
                            if(strParentAccountRecordTypeName=='Company' || strParentAccountRecordTypeName=='Portfolio Company' || strParentAccountRecordTypeName=='Institution'|| strParentAccountRecordTypeName=='Fund Manager') // check parent institution record type is Institution,Company or fund manager
                            {
                                
                            }
                            else if(strParentAccountRecordTypeName=='Fund Manager’s Fund') //Check for the Parent Institution Record Type is Fund Manager's Fund
                            {                                 
                                objAccountNew.parentId.addError('A "Fund Manager\'s Fund" is not allowed to be a Parent Institution of a "Fund Manager".');
                            }
                            else if( strParentAccountRecordTypeName=='Limited Partner') //Check for the Parent Institution Record Type is Limited Partner 
                            {                                 
                                objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent Institution of a "Fund Manager".');
                            }
                        }
                    }
                    else if(strAccountRecordTypeName=='Fund Manager’s Fund')  // check for Fund Manager’s Fund
                    {
                        if(strParentAccountRecordTypeName!=null) //Check Parent institution is not blank
                        {
                            if(strParentAccountRecordTypeName!='Fund Manager')
                            {
                                objAccountNew.parentId.addError('Please select a "Fund Manager" as the Parent of a "Fund Manager\'s Fund".');
                            }
                                
                                
                        }
                        else // execute when paraent institution is blank
                        {
                            objAccountNew.parentId.addError('You must enter a value.');
                        }
                    }
                }// Trigger IsUpdate end
            }// Check For PE Record Type end
            else
            {
                if(strParentAccountRecordTypeName=='Limited Partner') // Check Parent intitution record type of outside the Private equity
                {
                    objAccountNew.parentId.addError('A "Limited Partner" is not allowed to be a Parent of '+((vowelset.contains(strAccountRecordTypeName.substring(0,1))==true)?'an ':'a ')+'"'+strAccountRecordTypeName+'".');
                }
            }
        }// Check For bulk udpate end
    }
    
    
    
    if(Trigger.size < 3 && Trigger.isDelete)
    {
        // (PE3.5, SK, 10Aug2017)
        Account objAcctOld = new Account();
        Integer countFlg = 0;
        
        list<id> acclist=new list<id>();
        for(account acc:trigger.old)
        {
            acclist.add(acc.id);
            
            // (PE3.5, SK, 10Aug2017)
            if(countFlg == 0){
                objAcctOld = acc;
            }
            countFlg++;
            
        }
        
        try
        {
            //(PE3.5, SK, 16Aug2017)
            Map<Id, Account> mapAcct2 = new Map<Id, Account>([Select id, RecordType.Name, (Select Id From ChildAccounts limit 1000), (Select id from Advisor__r Where Fundraising__c != null limit 1000), (Select id from Client__r Where Fundraising__c != null limit 1000), (Select id from Fundraising__r limit 1000 ), (Select id from Transfer__r limit 1000 ),(Select id from Commitment_Company__r limit 1000 ),(Select id from Commitment__r limit 1000) From Account Where id In:acclist]);
            
            //(PE3.5, SK, 16Aug2017)
            Map<Id, Integer> acctIdComitmentCountMap = new Map<Id, Integer>();
            for(Commitment__c obj : [Select Id, Limited_Partner__r.parentid From Commitment__c Where Limited_Partner__r.parentid IN:mapAcct2.keyset()]){
                if( !acctIdComitmentCountMap.containsKey(obj.Limited_Partner__r.parentid) ){
                    acctIdComitmentCountMap.put(obj.Limited_Partner__r.parentid, 0);
                }
                acctIdComitmentCountMap.put(obj.Limited_Partner__r.parentid, acctIdComitmentCountMap.get(obj.Limited_Partner__r.parentid)+1 );
            }
            
            //(PE3.5, SK, 16Aug2017)
            Map<Id, Integer> acctIdTransferCount1Map = new Map<Id, Integer>();
            for(Transfer__c obj : [Select Id, Transfer_to_Limited_Partner__r.parentid From Transfer__c Where Transfer_to_Limited_Partner__r.parentid IN:mapAcct2.keyset()]){
                if( !acctIdTransferCount1Map.containsKey(obj.Transfer_to_Limited_Partner__r.parentid) ){
                    acctIdTransferCount1Map.put(obj.Transfer_to_Limited_Partner__r.parentid, 0);
                }
                acctIdTransferCount1Map.put(obj.Transfer_to_Limited_Partner__r.parentid, acctIdTransferCount1Map.get(obj.Transfer_to_Limited_Partner__r.parentid)+1 );
            }
            
            //(PE3.5, SK, 16Aug2017)
            Map<Id, Integer> acctIdTransferCount2Map = new Map<Id, Integer>();
            for(Transfer__c obj : [Select Id, Commitment_Name__r.Portfolio_Company__c From Transfer__c Where Commitment_Name__r.Portfolio_Company__c IN:mapAcct2.keyset()]){ 
                if( !acctIdTransferCount2Map.containsKey(obj.Commitment_Name__r.Portfolio_Company__c) ){
                    acctIdTransferCount2Map.put(obj.Commitment_Name__r.Portfolio_Company__c, 0);
                }
                acctIdTransferCount2Map.put(obj.Commitment_Name__r.Portfolio_Company__c, acctIdTransferCount2Map.get(obj.Commitment_Name__r.Portfolio_Company__c)+1 );
            }
            
            
            Account [] accTemp = [Select id, RecordType.Name, (Select Id From ChildAccounts limit 1000), (Select id from Advisor__r limit 1000), (Select id from Client__r limit 1000), (Select id from Fundraising__r limit 1000 ), (Select id from Transfer__r limit 1000 ),(Select id from Commitment_Company__r limit 1000 ),(Select id from Commitment__r limit 1000) from Account where id in :acclist];
            
            Boolean isAccDependent = false;
            set<String> errObjects = new set<String>();
            for(account acountcheck : accTemp)
            {
                if(acountcheck.RecordType.Name == 'Fund Manager' || acountcheck.RecordType.Name == 'Institution' || acountcheck.RecordType.Name == 'Limited Partner' || acountcheck.RecordType.Name == 'Company' || acountcheck.RecordType.Name == 'Portfolio Company' || acountcheck.RecordType.Name == 'Fund Manager’s Fund' || acountcheck.RecordType.Name == 'Individual Investor') // Check the Record Type with in Private Equity
                {
                    boolean checkCommitment=false;
                    boolean checkTransfer=false;
                    
                    if(acountcheck.RecordType.Name == 'Institution' || acountcheck.RecordType.Name == 'Individual Investor') // Check Record type is Institution or individual investor updated by brahma
                    {
                        if(acountcheck.Commitment__r.size()>0)  //check for Commitment
                        {
                            errObjects.add('Commitment');
                            isAccDependent  = true;
                            checkCommitment=true;
                        }
                        if(acountcheck.Transfer__r.size()>0) // check for Transfer
                        {
                            errObjects.add('Transfer');
                            isAccDependent  = true;
                            checkTransfer=true;
                        }
                        
                        //(PE3.5, SK, 16Aug2017)
                        // Integer lpCount = [Select count() from Account where parentid = :acountcheck.id limit 1000];
                        Integer lpCount = acountcheck.ChildAccounts.size();
                        
                        if(lpCount > 0)  // check for commitement and Transfer
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer commitementcount = [Select count() from Commitment__c where Limited_Partner__r.parentid= :acountcheck.id limit 1000];
                            Integer commitementcount = (acctIdComitmentCountMap.containsKey(acountcheck.id) ? acctIdComitmentCountMap.get(acountcheck.id) : 0);
                            
                            if(commitementcount>0 && checkCommitment!=true)  //check for Commitment
                            {
                                errObjects.add('Commitment');
                                isAccDependent  = true;
                            }
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Transfercount = [Select count() from Transfer__c where Transfer_to_Limited_Partner__r.parentid= :acountcheck.id limit 1000] ;
                            Integer Transfercount = (acctIdTransferCount1Map.containsKey(acountcheck.id) ? acctIdTransferCount1Map.get(acountcheck.id) : 0);
                            
                            if(Transfercount>0 && checkTransfer!=true) // check for Transfer
                            {
                                errObjects.add('Transfer');
                                isAccDependent  = true;
                            }
                        }
                        if(acountcheck.Client__r.size() > 0) // check for Client with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Clientcount = [Select count() from  Advisor__c where Advisor__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Clientcount = mapAcct2.get(acountcheck.id).Advisor__r.size();
                            
                            if(Clientcount>0)
                            {
                                errObjects.add('Client');
                                isAccDependent  = true;
                            }
                        }
                        if(acountcheck.Advisor__r.size() > 0) // Check For Advisor with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Advisorcount = [Select count() from Advisor__c where Client__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Advisorcount = mapAcct2.get(acountcheck.id).Client__r.size();
                            
                            if(Advisorcount>0)
                            {
                                errObjects.add('Advisor');
                                isAccDependent  = true;
                            }
                        }

                    }
                    else if(acountcheck.RecordType.Name == 'Company' || acountcheck.RecordType.Name == 'Portfolio Company')       //for checking related records of recordtype 'Company'.
                    {
                        if(acountcheck.Commitment_Company__r.size() > 0) // Check company with commitement
                        {
                            errObjects.add('Commitment');
                            isAccDependent  = true;
                        }
                         if(acountcheck.Commitment_Company__r.size() > 0) // Check company with trnasfer
                         {
                               //(PE3.5, SK, 16Aug2017)
                               //Integer Transfercount=[select count() from Transfer__c where Commitment_Name__r.Portfolio_Company__c=:acountcheck.id limit 1000];
                               Integer Transfercount = (acctIdTransferCount2Map.containsKey(acountcheck.id) ? acctIdTransferCount2Map.get(acountcheck.id) : 0);
                               
                               if(Transfercount>0)
                               {
                                    errObjects.add('Transfer');
                                    isAccDependent  = true;
                                }
                         }
                         
                        if(acountcheck.Client__r.size() > 0) // check for Client with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Clientcount = [Select count() from  Advisor__c where Advisor__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Clientcount = mapAcct2.get(acountcheck.id).Advisor__r.size();
                            
                            if(Clientcount>0)
                            {
                                errObjects.add('Client');
                                isAccDependent  = true;
                            }
                        }
                        if(acountcheck.Advisor__r.size() > 0) // Check For Advisor with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Advisorcount = [Select count() from Advisor__c where Client__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Advisorcount = mapAcct2.get(acountcheck.id).Client__r.size();
                            
                            if(Advisorcount>0)
                            {
                                errObjects.add('Advisor');
                                isAccDependent  = true;
                            }
                        }
                    }
                    else if(acountcheck.RecordType.Name == 'Limited Partner')    // For checking related records of recordtype 'Limited Partner'. 
                    {
                        if(acountcheck.Commitment__r.size() > 0) // check Limited partner has Commitement
                        {
                            errObjects.add('Commitment');
                            isAccDependent  = true;
                        }
                        if(acountcheck.Transfer__r.size() > 0) // Check Limited Partner has Transfer
                        {
                            errObjects.add('Transfer');
                            isAccDependent  = true;
                        }
                        if(acountcheck.Client__r.size() > 0) // check for Client with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Clientcount = [Select count() from  Advisor__c where Advisor__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Clientcount = mapAcct2.get(acountcheck.id).Advisor__r.size();
                            
                            if(Clientcount>0)
                            {
                                errObjects.add('Client');
                                isAccDependent  = true;
                            }
                        }
                        if(acountcheck.Advisor__r.size() > 0) // Check For Advisor with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Advisorcount = [Select count() from Advisor__c where Client__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Advisorcount = mapAcct2.get(acountcheck.id).Client__r.size();
                            
                            if(Advisorcount>0)
                            {
                                errObjects.add('Advisor');
                                isAccDependent  = true;
                            }
                        }
                    }
                    else if(acountcheck.RecordType.Name == 'Fund Manager') // Checking Fund Manager has Advisor or Client
                    {
                        if(acountcheck.Client__r.size() > 0) // check for Client with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Clientcount = [Select count() from  Advisor__c where Advisor__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Clientcount = mapAcct2.get(acountcheck.id).Advisor__r.size();
                            
                            if(Clientcount>0)
                            {
                                errObjects.add('Client');
                                isAccDependent  = true;
                            }
                        }
                        if(acountcheck.Advisor__r.size() > 0) // Check For Advisor with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Advisorcount = [Select count() from Advisor__c where Client__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Advisorcount = mapAcct2.get(acountcheck.id).Client__r.size();
                            
                            if(Advisorcount>0)
                            {
                                errObjects.add('Advisor');
                                isAccDependent  = true;
                            }
                        }
                    }
                    else if(acountcheck.RecordType.Name == 'Fund Manager’s Fund') // Checking Fund Manager's Fund has Advisor or Client
                    {
                           
                        if(acountcheck.Advisor__r.size() > 0) // Check For Advisor with Fundraising
                        {
                            //(PE3.5, SK, 16Aug2017)
                            //Integer Advisorcount = [Select count() from Advisor__c where Client__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                            Integer Advisorcount = mapAcct2.get(acountcheck.id).Client__r.size();
                            
                            if(Advisorcount>0)
                            {
                                errObjects.add('Advisor');
                                isAccDependent  = true;
                            }
                        }
                    }
                    
                }
                else
                {
                    if(acountcheck.Client__r.size() > 0) // check for Client with Fundraising
                    {
                        //(PE3.5, SK, 16Aug2017)
                        //Integer Clientcount = [Select count() from  Advisor__c where Advisor__c= :acountcheck.id and Fundraising__c!=null limit 1000];
                        Integer Clientcount = mapAcct2.get(acountcheck.id).Advisor__r.size();
                        
                        if(Clientcount>0)
                        {
                            errObjects.add('Client');
                            isAccDependent  = true;
                        }
                    }
                }
                
            
            }
            if(isAccDependent)  // For Genric Error messages if any.
            {
                list<string> errormsg=new list<string>();
                errormsg.addAll(errObjects);
                String err = 'Please delete the related "'+errormsg[0]; // err varibale fro display the error
                if(errormsg.size()>1)
                {
                    for(Integer tempInt=1 ; tempInt<(errormsg.size()-1) ; tempInt++)
                    err += '", "'+errormsg[tempInt];
                    err += '" and "'+errormsg[errormsg.size()-1]+'" record(s) before deleting the "'+accTemp[accTemp.size()-1].RecordType.Name+'".';
                }
                else
                err += '" record(s) before deleting the "'+accTemp[accTemp.size()-1].RecordType.Name+'".';
                Trigger.oldMap.get(accTemp[accTemp.size()-1].Id).addError(err);
            }
            
            
        }
        catch(QueryException e) // Error Msg. statement. If governor limits are triggered.
        {
            objAcctOld.addError('Please delete all the related records before deleting this record.');
        }
    }
    
    
}