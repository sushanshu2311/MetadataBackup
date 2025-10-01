trigger chkIns_Upd_Fundraising on Fundraising__c (before insert, before update,after insert,after update,after delete, after undelete)
{
    /*  New Implimentation:
Developer               :   Amit Kumar
Product Version         :   PE 2.0
Date of Creation        :   12/12/2008
Purpose of Creation     :   To prevent:
1. The deletion of Fundraising if there exists related Fundraising Contacts.
2. Linking of Fundraising to an Institution.
3. Linking of a Portfolio Company if 'Fund type' of Fund is "Fund" or vice-versa.
Date of Updation        :   04/03/2009
Developer               :   Manjot Singh Juneja
Product Version         :   PE 2.0       
Purpose of Updation     :   1) Linking of Fundraising to an Institution not to a Company or Limited Partner .
2) Linking of a Portfolio Company to a Company,if 'Fund type' of Fund is "Fund" or vice-versa.

Date of Updation        :   02/07/2009
Developer               :   Amit Kumar
Product Version         :   PE 2.2       
Purpose of Updation     :   1) Dynamic Error Meassages for Leagal Name, Portfolio Company. eg. "Please select an Institution instead of x."

Date of Updation        :   28/04/2015
Developer               :   Sameer Rath
Product Version         :   PE 3.0       
Purpose of Updation     :   Bulkified the trigger .

Date of Updation        :   28/06/2016
Developer               :   Brahmaditya Bhaskar
Product Version         :   PE 3.5      
Purpose of Updation     :   You can save the record without selecting portfolio company in case of co-inv fund.

Developer               :  Hemendra Singh Rajawat
Product Version         :  PE 4.5
Date of Creation        :  30/07/2020
Purpose of Creation     :  One More Condition added for Portfolio_Company record type with Company record type

Developer               :  Deepak Singh
Product Version         :  PE Phase 3
Date of Creation        :  23/03/2024
Purpose of Creation     :  LTP update on Fund from Fundraising
*/     
if(!Trigger.isDelete){                                                                 
    set<string> vowelset=new set<string>{'a','e','i','o','u','A','E','I','O','U'};      
        map<id,string> mapAccount = new map<id,string>(); // For storing the recordtype of Legal Name & portfolio
        Map<String, String> recTypeDevNameVsLabelMap = new Map<String, String>();//Added by LK on 2024-10-11 to fix 00047563
    Set<Id> setIDs = new Set<Id>();
    Set<Id> setFundIDs = new Set<Id>();
    for(Fundraising__c tempFundR : trigger.new){
        if(tempFundR.Legal_Name__c != null)
            setIDs.add(tempFundR.Legal_Name__c);        
        if(tempFundR.Portfolio_Company__c != null)
            setIDs.add(tempFundR.Portfolio_Company__c);
        if(tempFundR.Fund_Name__c != null)
            setFundIDs.add(tempFundR.Fund_Name__c);  
    }
    //Replaced Name with DeveloperName by LK on 2024-10-08 to fix 00047563
    for(account acc:[Select RecordType.Name, RecordType.DeveloperName from Account where RecordTypeId != null And Id in :setIDs]){
        mapAccount.put(acc.id,acc.RecordType.DeveloperName);
        //Added if clause and moved existing code inside {} by LK on 2024-10-11 to fix 00047563
        if(!recTypeDevNameVsLabelMap.containsKey(acc.RecordType.DeveloperName)){
            recTypeDevNameVsLabelMap.put(acc.RecordType.DeveloperName, acc.RecordType.Name);
        }
    }
        
    
    map<id,string> mapFund = new map<id,string>(); // For Investment Category
    
    for(Fund__c fund:[Select Investment_Category__c from Fund__c where id in :setFundIDs])
    {
        mapFund.put(fund.id,fund.Investment_Category__c);
    }
    
    for(Fundraising__c tempFundR : trigger.new)
    {
        boolean Flag = True;
        if(Flag)
        {
            if(Trigger.isUpdate)    // For Update
            {
                if(Trigger.oldMap.get(tempFundR.id).Total_Fundraising_Contacts__c != 0 && Trigger.oldMap.get(tempFundR.id).Legal_Name__c != tempFundR.Legal_Name__c ) //check Fundraising has fundrasisng contact and Legal Name is changed
                {
                    tempFundR.addError('Value once set cannot be changed as there are related Fundraising Contacts.');
                    Flag = False;        
                }      
            }
        }
        
        if(Flag) // Check when update or insert 
        {
            if(tempFundR.Legal_Name__c!=null) // Legal name is not blank
            {
                String InstitutionRecordTypeName = mapAccount.get(tempFundR.Legal_Name__c); 
                string chkfundInvestmentCategory = '';
                //if(InstitutionRecordTypeName=='Company' || InstitutionRecordTypeName=='Fund Manager' ||InstitutionRecordTypeName=='Fund Manager’s Fund' ||InstitutionRecordTypeName=='Institution' || InstitutionRecordTypeName=='Limited Partner' || InstitutionRecordTypeName=='Individual Investor' || InstitutionRecordTypeName=='Portfolio Company') // Check the Record type With Private Equity
                //Replaced record type names with developer names by LK on 2024-10-08 to fix 00047563
                if(InstitutionRecordTypeName=='Company' || InstitutionRecordTypeName=='Fund_Manager' ||InstitutionRecordTypeName=='Fund_Manager_s_Fund' ||InstitutionRecordTypeName=='Institution' || InstitutionRecordTypeName=='LimitedPartner' || InstitutionRecordTypeName=='Individual_Investor' || InstitutionRecordTypeName=='Portfolio_Company') // Check the Record type With Private Equity
                {
                    if(tempFundR.Fund_Name__c!=null) // check the Fund Investment Category
                    {
                        chkfundInvestmentCategory = mapFund.get(tempFundR.Fund_Name__c);
                        if(InstitutionRecordTypeName=='Company') // If parent Institution Record type is Company
                        {
                            tempFundR.Legal_Name__c.addError('A "Company" is not allowed to be associated with a "Fundraising".');
                        } //Replaced record type name with developer name by LK on 2024-10-08 to fix 00047563
                        else if(InstitutionRecordTypeName=='Portfolio_Company') { // If parent Institution Record type is Portfolio Company 
                            tempFundR.Legal_Name__c.addError('A "Portfolio Company" is not allowed to be associated with a "Fundraising".');
                        }//Replaced record type name with developer name by LK on 2024-10-08 to fix 00047563
                        else if((ProductSetting__c.getInstance('FundraisingwithFM') != null) && (InstitutionRecordTypeName=='Fund_Manager') && (ProductSetting__c.getInstance('FundraisingwithFM').status__c!=true) ) // If parent Institution Record type is Fund Manager
                        {
                            tempFundR.Legal_Name__c.addError('A "Fund Manager" is not allowed to be associated with a "Fundraising".');
                        }//Replaced record type names with developer name by LK on 2024-10-08 to fix 00047563
                        else if((ProductSetting__c.getInstance('FundraisingwithFMF') != null) && (InstitutionRecordTypeName=='Fund_Manager_s_Fund') && (ProductSetting__c.getInstance('FundraisingwithFMF').status__c!=true) ) // If parent Institution Record type is Fund Manager’s Fund
                        {
                            tempFundR.Legal_Name__c.addError('A "Fund Manager\'s Fund" is not allowed to be associated with a "Fundraising".');
                        }
                        else if(tempFundR.Portfolio_Company__c!=null) // check Potfolio comapny is blank
                        {   //Replaced record type name with developer name by LK on 2024-10-08 to fix 00047563
                            if(mapAccount.get(tempFundR.Portfolio_Company__c) != 'Company' && mapAccount.get(tempFundR.Portfolio_Company__c) != 'Portfolio_Company' && mapAccount.get(tempFundR.Portfolio_Company__c) != 'Property') // Check Portfolio Company record type is not Company
                            {
                                tempFundR.Portfolio_Company__c.addError('Please select the correct record type.');
                            } 
                        } 
                        /// Else End when condition for company ,fund manager and fund manager's fund not executed
                    } // Fund name is not empty end
                    else // When Fund is balnk
                    {
                        tempFundR.Fund_Name__c.addError('Please select a Fund.');
                    }
                } //check pe rrcord type end
                else
                {
                    //tempFundR.Legal_Name__c.addError(+((vowelset.contains(InstitutionRecordTypeName.substring(0,1))==true)?'An ':'A ')+'"'+InstitutionRecordTypeName+'" is not allowed to be associated with a "Fundraising".');
                    //tempFundR.Legal_Name__c.addError(InstitutionRecordTypeName+'" is not allowed to be associated with a "Fundraising".');
                    //Replaced "InstitutionRecordTypeName" with "recTypeDevNameVsLabelMap.get(InstitutionRecordTypeName)" by LK on 2024-10-11 to fix 00047563
                    tempFundR.Legal_Name__c.addError('A "'+recTypeDevNameVsLabelMap.get(InstitutionRecordTypeName)+'" is not allowed to be associated with a "Fundraising".'); //Error Message update suggested by Saakshi Done By Rahulk (11-11-2020)
                    
                }
            } //legal name is not blank end
            else
            {
                tempFundR.Legal_Name__c.addError('Please select Legal Name.');
            }
        } // check flag end
        
    }

    
    
    Set<String> fundIds = new Set<String>();
        
        //Iterate all Contacts in Trigger 
        for(Fundraising__c fdr : Trigger.new) {
            if(Trigger.isAfter){
                if(((Trigger.isinsert || Trigger.isundelete) && fdr.navpeII_dev18__Last_Touch_Point__c != null && fdr.navpeII_dev18__Fund_Name__c!=null) || 
                (Trigger.isupdate && ( Trigger.oldMap.get(fdr.Id).navpeII_dev18__Fund_Name__c != fdr.navpeII_dev18__Fund_Name__c || (fdr.navpeII_dev18__Last_Touch_Point__c != Trigger.oldMap.get(fdr.Id).navpeII_dev18__Last_Touch_Point__c)))) {
                    if(Trigger.isupdate && Trigger.oldMap.get(fdr.Id).navpeII_dev18__Fund_Name__c != fdr.navpeII_dev18__Fund_Name__c)
                        fundIds.add(Trigger.oldMap.get(fdr.Id).navpeII_dev18__Fund_Name__c);
                                            
                    fundIds.add(fdr.navpeII_dev18__Fund_Name__c);
                }
            }
        }

        if(fundIds.size() > 0)
            NavatarFundraisingTriggerHandler.updateFund(new List<String>(fundIds));
    
    }    
    // Bug Id - 00045708 fixed by Deepak
            if(Trigger.isAfter && Trigger.isDelete){
                Set<String> fundIds = new Set<String>();
                for(Fundraising__c fdr : Trigger.Old){
                    if((Trigger.isdelete) ) {
                        fundIds.add(fdr.navpeII_dev18__Fund_Name__c);
                    }
                }

                if(fundIds.size() > 0)
                    NavatarFundraisingTriggerHandler.updateFund(new List<String>(fundIds));
            }
    
}