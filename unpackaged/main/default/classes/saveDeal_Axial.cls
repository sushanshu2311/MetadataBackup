/*    
    Developer: Sameer Rath, 
    Edited date: 26 feb 2015
    Project: Axial Integration   
    Functionality: verify the client's data and save the informations to the database
*/

Public With Sharing class saveDeal_Axial{
    
    Public class oauthException extends Exception{} //Hold the Exception of this class
    public saveDeal_Axial(){
       
    }
    
/*  Developer : Sameer Rath  
    Edited date: 22 feb 2015
    Functionality:  To verify all the necessary parameters that sent by the client to create a deal. 
*/
    public void parameterReview(NavatarDealCreate temp_obj)
    {
        if(string.isBlank(temp_obj.External_ID) ||string.isBlank(temp_obj.Name) ||string.isBlank(temp_obj.Company_Name.name) ||string.isBlank(temp_obj.Company_Name.External_Id) ||string.isBlank(temp_obj.Company_Name.Source) || string.isBlank(temp_obj.Company_Name.Contact.Email)|| string.isBlank(temp_obj.Company_Name.Contact.Last_Name)|| string.isBlank(temp_obj.Company_Name.Contact.First_Name)|| string.isBlank(temp_obj.Company_Name.Contact.External_ID)){
            throw new oauthException('{"statusId":"403","exception":"Required information missing to create a deal."}');
        }
        else{
           
           // SK: 8Dec2017
           List<Account> lstAcct = new List<Account>();
           if(Schema.sObjectType.account.isAccessible() && Schema.sObjectType.Account.Fields.External_System_ID__c.isAccessible())
           {
               lstAcct = [select id,External_System_ID__c from account where External_System_ID__c = :temp_obj.Company_Name.External_ID];
           }
                   
           for(account acc : lstAcct){
                if(acc.External_System_ID__c.equals(temp_obj.Company_Name.External_ID)){
                    throw new oauthException('{"statusId":"409","exception":"Company External ID already exists."}');
                }
            }
            
            // SK: 8Dec2017
            List<Contact> lstCont = new List<Contact>();
            if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.Fields.External_System_ID__c.isAccessible()){
                lstCont = [select id,External_System_ID__c from contact where External_System_ID__c = :temp_obj.Company_Name.contact.External_ID];
            }
            
            for(Contact con : lstCont){
                if(con.External_System_ID__c.equals(temp_obj.Company_Name.contact.External_ID)){
                    throw new oauthException('{"statusId":"409","exception":"Company contact External ID already exists."}');
                }
            }
            
            // SK: 8Dec2017
            List<Pipeline__c> lstPipeLine = new List<Pipeline__c>();
            if(Schema.sObjectType.Pipeline__c.isAccessible() && Schema.sObjectType.Pipeline__c.Fields.External_System_ID__c.isAccessible()){
                lstPipeLine = [select id,External_System_ID__c from Pipeline__c where External_System_ID__c = :temp_obj.External_ID];
            }
            
            for(Pipeline__c pipe : lstPipeLine){
                if(pipe.External_System_ID__c.Equals(temp_obj.External_ID)){
                    throw new oauthException('{"statusId":"409","exception":"Deal External ID already exists."}');
                }
            }
        } 
        
        
        if(temp_obj.Source_Firm != null){
            if(string.isNotBlank(temp_obj.Source_Firm.Source) || string.isNotBlank(temp_obj.Source_Firm.Name) || string.isNotBlank(temp_obj.Source_Firm.External_ID) || string.isNotBlank(temp_obj.Source_Firm.Website)  || string.isNotBlank(temp_obj.Source_Firm.Industry) || string.isNotBlank(temp_obj.Source_Firm.Geographic_Region) || string.isNotBlank(temp_obj.Source_Firm.Employees) || string.isNotBlank(temp_obj.Source_Firm.Street) || string.isNotBlank(temp_obj.Source_Firm.City) || string.isNotBlank(temp_obj.Source_Firm.State) || string.isNotBlank(temp_obj.Source_Firm.Postal_Code) || string.isNotBlank(temp_obj.Source_Firm.Country) ){
                if(string.isBlank(temp_obj.Source_Firm.Name) || string.isBlank(temp_obj.Source_Firm.External_ID)){
                    throw new oauthException('{"statusId":"404","exception":"Required information missing to create source firm."}');
                }
                else{
                    if(temp_obj.Source_Firm.External_ID.Equals(temp_obj.Company_Name.External_Id)){
                        throw new oauthException('{"statusId":"409","exception":"You can not provide same external ID for company and source firm."}');
                    }
                    
                    // SK: 8Dec2017
                    List<Account> lstAcct = new List<Account>();
                    if(Schema.sObjectType.account.isAccessible() && Schema.sObjectType.Account.Fields.External_System_ID__c.isAccessible()){
                        lstAcct = [select id,External_System_ID__c from account where External_System_ID__c = :temp_obj.Source_Firm.External_ID];
                    }
                    
                    for(account acc : lstAcct){
                        if(acc.External_System_ID__c.Equals(temp_obj.Source_Firm.External_ID)){
                            throw new oauthException('{"statusId":"409","exception":"Source firm External ID already exists."}');
                        }
                    }
                }
                 
            }
            
        }
        if(temp_obj.Source_Firm.Contact != null){
            if(string.isNotBlank(temp_obj.Source_Firm.Contact.First_Name) || string.isNotBlank(temp_obj.Source_Firm.Contact.Last_Name) || string.isNotBlank(temp_obj.Source_Firm.Contact.External_ID) || string.isNotBlank(temp_obj.Source_Firm.Contact.Mailing_Street) || string.isNotBlank(temp_obj.Source_Firm.Contact.Mailing_City) || string.isNotBlank(temp_obj.Source_Firm.Contact.Mailing_State) || string.isNotBlank(temp_obj.Source_Firm.Contact.Mailing_Postal_Code) || string.isNotBlank(temp_obj.Source_Firm.Contact.Mailing_Country) || string.isNotBlank(temp_obj.Source_Firm.Contact.Email) || string.isNotBlank(temp_obj.Source_Firm.Contact.Phone) ){
                if(string.isBlank(temp_obj.Source_Firm.Contact.Last_Name) || string.isBlank(temp_obj.Source_Firm.Contact.External_ID)){
                    throw new oauthException('{"statusId":"404","exception":"Required information missing to create source contact."}');
                }
                else{
                    if(temp_obj.Source_Firm.contact.External_ID.Equals(temp_obj.Company_Name.contact.External_Id)){
                        throw new oauthException('{"statusId":"409","exception":"You can not provide same External ID for company contact and source contact."}');
                    }
                    
                    // SK: 8Dec2017
                    List<Contact> lstCont = new List<Contact>();
                    if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.Fields.External_System_ID__c.isAccessible()){
                        lstCont = [select id,External_System_ID__c from contact where External_System_ID__c = :temp_obj.Source_Firm.contact.External_ID];
                    }
                    
                    for(Contact con : lstCont){
                        if(con.External_System_ID__c.Equals(temp_obj.Source_Firm.contact.External_ID)){
                            throw new oauthException('{"statusId":"409","exception":"Source contact External ID already exists."}');
                        }
                    }
                    if(string.isBlank(temp_obj.Source_Firm.Name)){
                        throw new oauthException('{"statusId":"403","exception":"Source firm information is required since source contact information is provided."}');
                    }
                    else{
                        if(temp_obj.Source_Firm.External_ID.Equals(temp_obj.Company_Name.External_Id)){
                        throw new oauthException('{"statusId":"409","exception":"You can not provide same External ID for company and source firm."}');
                        }
                        
                        // SK: 8Dec2017
                        List<Account> lstAcct = new List<Account>();
                        if(Schema.sObjectType.account.isAccessible() && Schema.sObjectType.Account.Fields.External_System_ID__c.isAccessible()){
                            lstAcct = [select id,External_System_ID__c from account where External_System_ID__c = :temp_obj.Source_Firm.External_ID];
                        }
                        
                        for(account acc : lstAcct){
                            if(acc.External_System_ID__c.Equals(temp_obj.Source_Firm.External_ID)){
                                throw new oauthException('{"statusId":"409","exception":"Source firm External ID already exists."}');
                            }
                        }
                    }
                }            
            }
        }
    }

/*  Developer : Sameer Rath  
    Edited date: 25 feb 2015
    Functionality:  Save the informations to the database after verification. 
*/  
    
    public void saveRecord(NavatarDealCreate temp_obj2){
            account Company_info = new account(); // Hold the company information
            contact company_contact = new contact(); // Hold the Company Contact information
            account sourceFirm_info = new account(); // Hold the Source Firm information
            contact SourceFirm_contact = new contact(); // Hold the Source Firm contact information
            Pipeline__c pipelineInfo = new Pipeline__c(); // Hold the pipeline information
        try{
            
            // SK: 8Dec2017
            List<RecordType> recdType = new List<RecordType>();
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.Name.isAccessible() 
                && Schema.sObjectType.RecordType.Fields.sObjectType.isAccessible()){
                recdType = [Select id,name from RecordType where name = 'company' and sObjectType = 'Account'];
            }
            
            if(Schema.sObjectType.Account.fields.RecordTypeId.isCreateable() ) {
                Company_info.RecordTypeId = recdType[0].id;
            }
            if(Schema.sObjectType.Account.fields.Source__c.isCreateable() ) {
                Company_info.Source__c = temp_obj2.Company_Name.Source;
            }
            if(Schema.sObjectType.Account.fields.External_System_ID__c.isCreateable() ) {
                Company_info.External_System_ID__c = temp_obj2.Company_Name.External_ID;
            }
            if(Schema.sObjectType.Account.fields.Name.isCreateable() ) {
                Company_info.Name = temp_obj2.Company_Name.Name;
            }
            if(Schema.sObjectType.Account.fields.Website.isCreateable() ) {
                Company_info.Website = temp_obj2.Company_Name.Website;
            }
            if(Schema.sObjectType.Account.fields.Industry.isCreateable() ) {
                Company_info.Industry = temp_obj2.Company_Name.Industry;
            }
            if(Schema.sObjectType.Account.fields.Geographic_Region__c.isCreateable() ) {
                Company_info.Geographic_Region__c = temp_obj2.Company_Name.Geographic_Region;
            }
            
            if(string.isnotBlank(temp_obj2.Company_Name.Employees) && Schema.sObjectType.Account.fields.NumberOfEmployees.isCreateable()){
                Company_info.NumberOfEmployees = integer.valueOf(temp_obj2.Company_Name.Employees);
            }
            
            if(Schema.sObjectType.Account.fields.BillingStreet.isCreateable() ) {
                Company_info.BillingStreet = temp_obj2.Company_Name.Street;
            }
            if(Schema.sObjectType.Account.fields.BillingCity.isCreateable() ) {
                Company_info.BillingCity= temp_obj2.Company_Name.City;
            }
            if(Schema.sObjectType.Account.fields.BillingState.isCreateable() ) {
                Company_info.BillingState = temp_obj2.Company_Name.State;
            }
            if(Schema.sObjectType.Account.fields.BillingPostalCode.isCreateable() ) {
                Company_info.BillingPostalCode = temp_obj2.Company_Name.Postal_Code;
            }
            if(Schema.sObjectType.Account.fields.BillingCountry.isCreateable() ) {
                Company_info.BillingCountry = temp_obj2.Company_Name.Country;
            }
            
            if(Schema.sObjectType.Account.isCreateable()){
                insert Company_info;
            }
        }
        catch(exception ex){
            throw new oauthException('{"statusId":"400","exception":"Error in company information."}');
        }   
        try
        {
             if(Schema.sObjectType.Contact.fields.AccountId.isCreateable() ) {
                company_contact.AccountId = Company_info.Id;
             }
             if(Schema.sObjectType.Contact.fields.External_System_ID__c.isCreateable() ) {
                company_contact.External_System_ID__c = temp_obj2.Company_Name.contact.External_ID ;
             }
             if(Schema.sObjectType.Contact.fields.FirstName.isCreateable() ) {
                company_contact.FirstName = temp_obj2.Company_Name.contact.First_Name ;
             }
             if(Schema.sObjectType.Contact.fields.LastName.isCreateable() ) {
                company_contact.LastName = temp_obj2.Company_Name.contact.Last_Name ;
             }
             if(Schema.sObjectType.Contact.fields.MailingStreet.isCreateable() ) {
                company_contact.MailingStreet = temp_obj2.Company_Name.contact.Mailing_Street ;
             }
             if(Schema.sObjectType.Contact.fields.MailingCity.isCreateable() ) {
                company_contact.MailingCity = temp_obj2.Company_Name.contact.Mailing_City ;
             }
             if(Schema.sObjectType.Contact.fields.MailingState.isCreateable() ) {
                company_contact.MailingState = temp_obj2.Company_Name.contact.Mailing_State ;
             }
             if(Schema.sObjectType.Contact.fields.MailingPostalCode.isCreateable() ) {
                company_contact.MailingPostalCode = temp_obj2.Company_Name.contact.Mailing_Postal_Code ;
             }
             if(Schema.sObjectType.Contact.fields.MailingCountry.isCreateable() ) {
                company_contact.MailingCountry = temp_obj2.Company_Name.contact.Mailing_Country ;
             }
             if(Schema.sObjectType.Contact.fields.Phone.isCreateable() ) { 
                company_contact.Phone = temp_obj2.Company_Name.contact.Phone ; 
             }
             if(Schema.sObjectType.Contact.fields.Email.isCreateable() ) {
                company_contact.Email = temp_obj2.Company_Name.contact.Email ;
             }
             
             if(Schema.sObjectType.Contact.isCreateable()){
                insert company_contact;
             }
         }
         catch(exception ex){
              if(Schema.sObjectType.Account.isDeletable()){
                delete Company_info;
              }
             throw new oauthException('{"statusId":"400","exception":"Error in company contact information."}');
            
         }
         
         if(string.isnotBlank(temp_obj2.Source_Firm.Name) || string.isnotBlank(temp_obj2.Source_Firm.External_ID) ){      
               try{
                    
                    // SK: 8Dec2017
                    List<RecordType> recdType = new List<RecordType>();
                    if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.Name.isAccessible() 
                        && Schema.sObjectType.RecordType.Fields.sObjectType.isAccessible())
                    {
                        recdType = [Select id,name from RecordType where name = 'Institution' and sObjectType = 'Account'];
                    }
                    
                    if(Schema.sObjectType.ACCOUNT.fields.RecordTypeId.isCreateable() ) {
                        sourceFirm_info.RecordTypeId = recdType[0].id;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.Source__c.isCreateable() ) {
                        sourceFirm_info.Source__c = temp_obj2.Source_Firm.Source;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.External_System_ID__c.isCreateable() ) {
                        sourceFirm_info.External_System_ID__c = temp_obj2.Source_Firm.External_ID;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.Name.isCreateable() ) {
                        sourceFirm_info.Name = temp_obj2.Source_Firm.Name;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.Website.isCreateable() ) {
                        sourceFirm_info.Website = temp_obj2.Source_Firm.Website;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.Industry.isCreateable() ) {
                        sourceFirm_info.Industry = temp_obj2.Source_Firm.Industry;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.Geographic_Region__c.isCreateable() ) {
                        sourceFirm_info.Geographic_Region__c = temp_obj2.Source_Firm.Geographic_Region;
                    }
                    
                    if(string.isnotBlank(temp_obj2.Source_Firm.Employees) && Schema.sObjectType.ACCOUNT.fields.NumberOfEmployees.isCreateable() ){
                        sourceFirm_info.NumberOfEmployees = integer.valueOf(temp_obj2.Source_Firm.Employees);
                    }
                    
                    if(Schema.sObjectType.ACCOUNT.fields.BillingStreet.isCreateable() ) {
                        sourceFirm_info.BillingStreet = temp_obj2.Source_Firm.Street;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.BillingCity.isCreateable() ) {
                        sourceFirm_info.BillingCity= temp_obj2.Source_Firm.City;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.BillingState.isCreateable() ) {
                        sourceFirm_info.BillingState = temp_obj2.Source_Firm.State;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.BillingPostalCode.isCreateable() ) {
                        sourceFirm_info.BillingPostalCode = temp_obj2.Source_Firm.Postal_Code;
                    }
                    if(Schema.sObjectType.ACCOUNT.fields.BillingCountry.isCreateable() ) {
                        sourceFirm_info.BillingCountry = temp_obj2.Source_Firm.Country;
                    }
                    
                    if(Schema.sObjectType.Account.isCreateable()){
                        insert sourceFirm_info;
                    }
                } 
               catch(exception ex){
                      if(Schema.sObjectType.Account.isDeletable()){
                        delete Company_info;
                      }
                      throw new oauthException('{"statusId":"400","exception":"Error in source firm information."}');
                }   
          }       
         
         if(string.isnotBlank(temp_obj2.Source_Firm.contact.Last_Name) || string.isnotBlank(temp_obj2.Source_Firm.contact.External_ID)){
            try{
                 if(Schema.sObjectType.Contact.fields.AccountId.isCreateable() ) {
                    SourceFirm_contact.AccountId = sourceFirm_info.Id;
                 }
                 if(Schema.sObjectType.Contact.fields.External_System_ID__c.isCreateable() ) {
                    SourceFirm_contact.External_System_ID__c = temp_obj2.Source_Firm.contact.External_ID ;
                 }
                 if(Schema.sObjectType.Contact.fields.FirstName.isCreateable() ) {
                    SourceFirm_contact.FirstName = temp_obj2.Source_Firm.contact.First_Name ;
                 }
                 if(Schema.sObjectType.Contact.fields.LastName.isCreateable() ) {
                    SourceFirm_contact.LastName = temp_obj2.Source_Firm.contact.Last_Name ;
                 }
                 if(Schema.sObjectType.Contact.fields.MailingStreet.isCreateable() ) {
                    SourceFirm_contact.MailingStreet = temp_obj2.Source_Firm.contact.Mailing_Street ;
                 }
                 if(Schema.sObjectType.Contact.fields.MailingCity.isCreateable() ) {
                    SourceFirm_contact.MailingCity = temp_obj2.Source_Firm.contact.Mailing_City ;
                 }
                 if(Schema.sObjectType.Contact.fields.MailingState.isCreateable() ) {
                    SourceFirm_contact.MailingState = temp_obj2.Source_Firm.contact.Mailing_State ;
                 }
                 if(Schema.sObjectType.Contact.fields.MailingPostalCode.isCreateable() ) {
                    SourceFirm_contact.MailingPostalCode = temp_obj2.Source_Firm.contact.Mailing_Postal_Code ;
                 }
                 if(Schema.sObjectType.Contact.fields.MailingCountry.isCreateable() ) {
                    SourceFirm_contact.MailingCountry = temp_obj2.Source_Firm.contact.Mailing_Country ;
                 } 
                 if(Schema.sObjectType.Contact.fields.Phone.isCreateable() ) {
                    SourceFirm_contact.Phone = temp_obj2.Source_Firm.contact.Phone ; 
                 }
                 if(Schema.sObjectType.Contact.fields.Email.isCreateable() ) {
                    SourceFirm_contact.Email = temp_obj2.Source_Firm.contact.Email ;
                 }
                 
                 if(Schema.sObjectType.Contact.isCreateable()){
                    insert SourceFirm_contact;
                 }
             }
         
             catch(exception ex){
                 if(Schema.sObjectType.Account.isDeletable()){
                     delete Company_info;
                     delete sourceFirm_info;
                 }
                 throw new oauthException('{"statusId":"400","exception":"Error in source contact information."}');
             }
         }
         
         try{
            
			 // Check pipeline Company relationship in PE v4.5  By Rahulk
			  pipelineInfo.put(CommonUtility.chkmasterLookupInPiplineAPI(), Company_info.id);
            
            if(sourceFirm_info != null && Schema.sObjectType.Pipeline__c.fields.Source_Company__c.isCreateable()){
                pipelineInfo.Source_Company__c = sourceFirm_info.Id ;
            }
            if(SourceFirm_contact != null && Schema.sObjectType.Pipeline__c.fields.Source_Contact__c.isCreateable()){
                pipelineInfo.Source_Contact__c = SourceFirm_contact.Id ;
            }
            if( Schema.sObjectType.Pipeline__c.fields.External_System_ID__c.isCreateable() ){
                pipelineInfo.External_System_ID__c = temp_obj2.External_ID ;
            }
            if( Schema.sObjectType.Pipeline__c.fields.Name.isCreateable() ){
                pipelineInfo.Name = temp_obj2.Name ;
            }
            if(string.isnotBlank(temp_obj2.Log_In_Date) && Schema.sObjectType.Pipeline__c.fields.Log_In_Date__c.isCreateable()){
                pipelineInfo.Log_In_Date__c = date.valueOf(temp_obj2.Log_In_Date) ; //date
            }
            
            if( Schema.sObjectType.Pipeline__c.fields.Stage__c.isCreateable() ){
                pipelineInfo.Stage__c = temp_obj2.Stage ;
            }
            if( Schema.sObjectType.Pipeline__c.fields.Deal_Type__c.isCreateable() ){
                pipelineInfo.Deal_Type__c = temp_obj2.Deal_Type ;
            }
            if( Schema.sObjectType.Pipeline__c.fields.Transaction_Type__c.isCreateable() ){
                pipelineInfo.Transaction_Type__c = temp_obj2.Transaction_Type ;
            }
            if( Schema.sObjectType.Pipeline__c.fields.Source__c.isCreateable() ){
                pipelineInfo.Source__c = temp_obj2.Source ;
            }
            if( Schema.sObjectType.Pipeline__c.fields.Pipeline_Data_Currency__c.isCreateable() ){
                pipelineInfo.Pipeline_Data_Currency__c = temp_obj2.Data_Currency ;
            }
            
            if(string.isnotBlank(temp_obj2.Revenue) && Schema.sObjectType.Pipeline__c.fields.Revenue__c.isCreateable()){
                pipelineInfo.Revenue__c = Decimal.valueOf(temp_obj2.Revenue) ; // integer Convertion
            }
            if( Schema.sObjectType.Pipeline__c.fields.Revenue_Range_in_mn__c.isCreateable() ){
                pipelineInfo.Revenue_Range_in_mn__c = temp_obj2.Revenue_Range ;
            }
            if(string.isnotBlank(temp_obj2.Investment_Size) && Schema.sObjectType.Pipeline__c.fields.Investment_Size__c.isCreateable()){
                pipelineInfo.Investment_Size__c = Decimal.valueOf(temp_obj2.Investment_Size) ; //integer Convertion
            }
            if( Schema.sObjectType.Pipeline__c.fields.Deal_Size_Range_in_mn__c.isCreateable() ){
                pipelineInfo.Deal_Size_Range_in_mn__c = temp_obj2.Deal_Size_Range ;
            }
            if(string.isnotBlank(temp_obj2.EBITDA) && Schema.sObjectType.Pipeline__c.fields.EBITDA__c.isCreateable()){
                pipelineInfo.EBITDA__c = Decimal.valueOf(temp_obj2.EBITDA) ; //integer Convertion
            }
            if( Schema.sObjectType.Pipeline__c.fields.EBITDA_Range_in_mn__c.isCreateable() ){
                pipelineInfo.EBITDA_Range_in_mn__c = temp_obj2.EBITDA_Range ;
            }
            if(string.isnotBlank(temp_obj2.EBIT) && Schema.sObjectType.Pipeline__c.fields.EBIT__c.isCreateable()){
                pipelineInfo.EBIT__c = Decimal.valueOf(temp_obj2.EBIT) ; // integer Convertion
            }
            if(string.isnotBlank(temp_obj2.Enterprise_Value) && Schema.sObjectType.Pipeline__c.fields.Enterprise_Value__c.isCreateable()){
                pipelineInfo.Enterprise_Value__c = Decimal.valueOf(temp_obj2.Enterprise_Value) ; //integer Convertion
            }
            
            
            if(Schema.sObjectType.Pipeline__c.isCreateable()){
                insert pipelineInfo;
            }
         }
         catch(Exception ex){
            if(Schema.sObjectType.Account.isDeletable()){
                delete Company_info;
            }
            if(sourceFirm_info.name != null ){
                if(Schema.sObjectType.Account.isDeletable()){
                    delete sourceFirm_info;
                }
            }
            throw new oauthException('{"statusId":"400","exception":"Error in deal information."}');
         }
            
    }
 /* Developer : Sameer Rath  
    Edited date: 18 feb 2015
    Functionality:  Set the Error response for the web service.  
*/
    public void Error_Handling(string statusCodes){
        RestResponse res = RestContext.response; // Hold the Response for the webservice
        map<string,object> getReport = (map<string,object>)JSON.deserializeUntyped(statusCodes);        
        res.statusCode = integer.valueOf(getReport.get('statusId'));
        res.responsebody = blob.valueOf('{"Message":"'+(string)getReport.get('exception')+'"}');
    }
}