/*************************************************
********************************
** Module Name : IndividualInvestorCreation_Ctlr
** Description : This apex class is responsible for following things.
    1. It creates Account & Contact with RecordType of Individual Investor, along with information provided by the user.
** Throws : NA
** Calls : NA
** Test Class :  Not yet**
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version  Date(YYYY-MM-DD)       Author       Description of Action   
** 1.0      28/06/2016             Faiz Ahmed 
** 2.0      2018-08-02             Qadir        PE v3.7: Summer 18 lightning navigation fix.  
*************************************************
********************************/

global with Sharing class IndividualInvestorCreation_Ctlr {

    public List<Navatar_Setup__c> lstNavSetup;                      /*It will hold the stored setting of Org_Setting__mdt in IIS variable. */
    public String iisSavedValues{get;set;}                          /*It will hold all the values saved in IIS at backend.*/  
    public contact conDetails{get;set;}                             /*Contact Instance use to hold the information filled by usre on VF page.*/
    public Map<String, String> FieldLabelVsApi{get;set;}            /*store sbject fields api and Label.*/
    public List<objectField> leftColumnObjectFieldList{get;set;}    /*It stores the left Column Object Field List*/
    public List<objectField> rightColumnObjectFieldList{get;set;}   /*It stores the right Column Object Field List*/
    public String strNameSpace{get; set;}                           /*Holds namespace of the current org.*/
    public Static string strSobjNameSpace{get; set;}                /*For static remoting method.*/
    public String strRequiredField{get; set;}                       /*String of required fields.*/
    public Set<String> setPgLayoutRequiredField{get; set;}          /*Required fields according to the page layout.*/
    public Account accDetails{get;set;}                             /*Account details in order to creat new account to insert*/
    public Account objAccount{get;set;}                             /*Account Instance refered on page.*/
    public Contact objContact{get;set;}                             /*Contact details to use in wrapper class*/
    public Boolean isIICreation{get;set;}                           /*It will identify checkbox will be true/false, on the basis of Org_Setting__mdt.*/
    public List<Org_Setting__mdt> lstOrgSett;                       /*It holds Org Setting Values.*/
    public static string defaultRecordTypeId;                       /*It holds record type id of default RT.*/
    public string defaultRecordTypeIdPg{get;set;}                       /*It holds record type id of default RT.*/
    public boolean checkPermission{get;set;}
    public string errorMessage{get;set;}
    /*@Description: Constructor*/
    public IndividualInvestorCreation_Ctlr()
    {
        try
        {
            errorMessage='';
            checkPermission= true;
            conDetails = new Contact();
            objAccount = new Account();
            lstOrgSett = new List<Org_Setting__mdt>();
            lstNavSetup = new List<Navatar_Setup__c>();
            FieldLabelVsApi = new Map<String, String>();
            leftColumnObjectFieldList = new List<objectfield>();  
            rightColumnObjectFieldList = new List<objectfield>();
            strNameSpace = CommonUtility.strNameSpacePrefix;
            objContact = new Contact();
            List<String> lstObject = new List<String>();        
            lstObject.add('Contact');
            lstObject.add('Account');          
             
            FieldLabelVsApi = describeSObject(lstObject); 
            
            // SK: 7Dec2017
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.Fields.IIS__c.isAccessible() && 
                Schema.sObjectType.Navatar_Setup__c.Fields.Admin_Setting__c.isAccessible()
            ){
                lstNavSetup = [SELECT IIS__c FROM Navatar_Setup__c where admin_setting__c = true LIMIT 1];
            }
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.IsActive__c.isAccessible()
                && Schema.sObjectType.Org_Setting__mdt.Fields.Label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.DeveloperName.isAccessible())
            {
                lstOrgSett = [SELECT label, IsActive__c, developername FROM Org_Setting__mdt where developername ='Ind_Inv_Creation' LIMIT 1];
            }
            
            if(lstOrgSett.size() > 0)
                isIICreation = lstOrgSett[0].IsActive__c;
            if(lstNavSetup.size() > 0)
                iisSavedValues = lstNavSetup[0].IIS__c;    
            if(lstNavSetup.size()==0){
                checkPermission= false;     
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact Navatar Support. System setup improperly. '));
            }
        }
        catch(exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ex));
            errorMessage= String.valueOf(ex.getMessage());
        }
    }
    public string strAccountLabel,strContactLabel;
    public Map<string, string> describeSObject(List<String> lstsObject)
    {
        Map<string, string> FieldLabelVsApi = new Map<string, string>();      
        try
        {
            errorMessage='';
            for(string objName : lstsObject)
            {
                List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName}); // this can accept list of strings, we describe only one object here
                if(objName == 'Account')
                    strAccountLabel  = describeSobjectsResult[0].getLabel();
                else if(objName == 'Contact')
                    strContactLabel  = describeSobjectsResult[0].getLabel(); 
                
                String objectLabel = describeSobjectsResult[0].getLabel();
                
                Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
                fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
                for(Schema.SObjectField sField : fieldMap.Values()) 
                {
                    schema.DescribeFieldResult dField = sField.getDescribe();
                    
                    if(dField.isAccessible()){
                        string apiName= (objName +':'+dfield.getName()).toLowerCase();                      
                        FieldLabelVsApi.put(apiName, objectLabel +':'+dfield.getLabel());
                    }
                    
                }
            }
        }
        Catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ex));
            errorMessage= String.valueOf(ex.getMessage());
        }
        return FieldLabelVsApi;
    }
    
    /*
    @Description: It views required fields on page layout.
    @Parameter1: strRequiredField, it contains list of required fields on layout.
    */
    public void viewRequiredFieldonPage()
    {
        try
        {
            errorMessage='';
            setPgLayoutRequiredField = new Set<String>();
            for( String str: strRequiredField.split(','))
            {
                setPgLayoutRequiredField.add(str.toLowerCase());
            }
            if(lstNavSetup.size()==0)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact Navatar Support. System setup improperly.');
                ApexPages.addMessage(myMsg); 
            }
            else
            {
                List<String> dcsInfoList = lstNavSetup[0].IIS__c.split(';');
                for(integer i=0; i<dcsInfoList.Size(); i++)
                { 
                    if(i==0 && !string.isBlank(dcsInfoList[i]) ) //left side will process for i==0 & its not null
                    {
                        for( String strfield: dcsInfoList[i].split(',') )
                        {
                            String strObjName= '';                                                    
                            List<String> fieldApiList = strfield.split(':');
                            for(integer j=0; j<fieldApiList.Size(); j++)
                            {                             
                                if(j==0)
                                {                            
                                    strObjName= fieldApiList[j];                                                  
                                }
                                if(j==1)
                                {                            
                                    objectfield objfld= new objectfield();  
                                    objfld.apiname = fieldApiList[j];
                                    if(objfld.apiname != null)
                                    {
                                        objfld.apiname = objfld.apiname.toLowerCase();
                                    }
                                    if(strObjName.contains('Account'))
                                    {
                                        
                                        objFld.objectAPIName = 'Account';
                                        objfld.objectname = objAccount;                                         
                                         
                                        string apiNames= (strObjName+':'+fieldApiList[j]).toLowerCase();
                                         
                                        
                                        if(FieldLabelVsApi.get(apiNames) != null )
                                        {
                                            objfld.label = FieldLabelVsApi.get(strObjName.toLowerCase()+':'+fieldApiList[j]);                                  
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname))
                                            {
                                                objfld.isrequired = true;
                                            }
                                                                                     
                                            //objfld.label = objfld.label.replace('Institution:','');
                                            objfld.label = objfld.label.replace(strAccountLabel+':','');
                                            leftColumnObjectFieldList.add(objfld);
                                        }
                                    }
                                    if(strObjName.contains('Contact'))
                                    {
                                        objFld.objectAPIName = 'Contact';
                                        objfld.objectname = objContact;
                                        
                                        string apiNames= (strObjName+':'+fieldApiList[j]).toLowerCase();
                                        
                                        if(FieldLabelVsApi.get(apiNames)!=null)
                                        {
                                            objfld.label = FieldLabelVsApi.get(strObjName.toLowerCase()+':'+fieldApiList[j]);                                       
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){
                                                objfld.isrequired = true;
                                            } 
                                            //objfld.label = objfld.label.replace('Contact:','');
                                            objfld.label = objfld.label.replace(strContactLabel+':','');                                        
                                            leftColumnObjectFieldList.add(objfld); 
                                        }
                                    }
                                }
                            }
                        }                
                    }
                    if(i==1) //right side
                    {
                        for(String strfield: dcsInfoList[i].split(','))
                        {
                            String strObjName= '';                                                    
                            List<String> fieldApiList = strfield.split(':');
                            for(integer k=0; k < fieldApiList.Size(); k++)
                            { 
                                if(k==0)
                                {                            
                                    strObjName= fieldApiList[k];                                                  
                                }
                                if(k==1)
                                {                            
                                    objectfield objfld= new objectfield();
                                    objfld.apiname = fieldApiList[k]; 
                                    if(objfld.apiname!=null)
                                    {
                                        objfld.apiname = objfld.apiname.toLowerCase();
                                    }                              
                                    if(strObjName.contains('Account'))
                                    {
                                        objFld.objectAPIName = 'Account';
                                        objfld.objectname = objAccount;
                                        string apiNames= (strObjName+':'+fieldApiList[k]).toLowerCase();
                                        
                                        if(FieldLabelVsApi.get(apiNames)!=null)
                                        {
                                            objfld.label = FieldLabelVsApi.get(strObjName.toLowerCase()+':'+fieldApiList[k]); 
                                            //objfld.label = objfld.label.replace('Institution:','');
                                            objfld.label = objfld.label.replace(strAccountLabel+':','');
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname))
                                            {
                                                objfld.isrequired = true;
                                            }
                                            rightColumnObjectFieldList.add(objfld); 
                                        }
                                    }
                                    if(strObjName.contains('Contact'))
                                    {
                                        objfld.objectname = conDetails;
                                        string apiNames= (strObjName+':'+fieldApiList[k]).toLowerCase();
                                        if(FieldLabelVsApi.get(apiNames) != null)
                                        {
                                            objfld.label = FieldLabelVsApi.get(strObjName.toLowerCase()+':'+fieldApiList[k]);
                                            //objfld.label =objfld.label.replace('Contact:','');
                                            objfld.label = objfld.label.replace(strContactLabel+':','');
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname))
                                            {
                                                objfld.isrequired = true;
                                            }
                                            rightColumnObjectFieldList.add(objfld);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ex));
            errorMessage= String.valueOf(ex.getMessage()); 
        }
    }
    
    
    /*@Description:Its a remoting function, use to get recrodTypeId with respect to its sObject.*/
    @RemoteAction
    global static String getRecorTypeid(String objectName)
    {
        String objRecordType='';
        strSobjNameSpace = CommonUtility.strNameSpacePrefix;
        
        // SK: 7Dec2017
        List<Navatar_Setup__c> lstNavSetup = new List<Navatar_Setup__c>();
        if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.Fields.IIS__c.isAccessible() && 
            Schema.sObjectType.Navatar_Setup__c.Fields.Admin_Setting__c.isAccessible() 
        ){
            lstNavSetup =[SELECT IIS__c, admin_setting__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
        }
        
        List<RecordType> rtList = new List<RecordType>();
        if(lstNavSetup.Size()>0)
        {
            // SK: 7Dec2017
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.Name.isAccessible() && 
                Schema.sObjectType.RecordType.Fields.DeveloperName.isAccessible() && Schema.sObjectType.RecordType.Fields.SobjectType.isAccessible() &&  
                Schema.sObjectType.RecordType.Fields.isActive.isAccessible() 
            ){
                rtList = [select Id,name from RecordType where developername ='Individual_Investor' and SobjectType = 'Account' and isActive = True];
            }
            
            if(rtList.size()>0)
            {    
                objRecordType = 'Account'+'^'+rtList[0].id;
                defaultRecordTypeId = rtList[0].id;
            }
            else // get default record type if it
            {
                for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos())
                {
                    if (rtInfo.isDefaultRecordTypeMapping()) 
                    {
                        objRecordType = 'Account'+'^'+rtInfo.getRecordTypeId();
                        defaultRecordTypeId = rtInfo.getRecordTypeId();
                    }
                }               
            }
            
            // SK: 7Dec2017
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.DeveloperName.isAccessible() && 
                Schema.sObjectType.RecordType.Fields.sobjectType.isAccessible() && Schema.sObjectType.RecordType.Fields.isActive.isAccessible()
            ){
                rtList=[Select Id, DeveloperName From RecordType where sobjecttype = 'Contact' AND isActive = True];
            }
            
            if(rtList.size()>0)
            {                
                    objRecordType = objRecordType +'~'+ 'Contact'+'^'+rtList[0].id;     
            }
            else
            {
                for(Schema.RecordTypeInfo rtInfo : Contact.SObjectType.getDescribe().getRecordTypeInfos())
                {
                    if (rtInfo.isDefaultRecordTypeMapping())                     
                        objRecordType = objRecordType +'~'+ 'Contact'+'^'+rtInfo.getRecordTypeId(); 
                }               
            }
        }       
        return objRecordType;
    }
    
    /*
    @Description: Execute on click of Create Individual Investor Button, and create new Account & Contact and oncomplete redirect to the newly created Institution Detail Page.
    */
    public pagereference createIndividualInvestorAct()
    {
        try
        {
            errorMessage='';
            accDetails = new Account();
            if( string.isBlank(accDetails.name) )
            {
                if(string.isBlank(conDetails.firstname) || conDetails.firstname == null)
                    accDetails.put( 'name', conDetails.lastname+' - HNI' );
                else
                    accDetails.put( 'name', conDetails.firstname +' '+ conDetails.lastname+' - HNI' );
            }
            for(objectField obj : leftColumnObjectFieldList )
            {
                if(obj.objectAPIName == 'Account')
                    accDetails.put(obj.apiName, obj.objectName.get(obj.apiName) );
                else if(obj.objectAPIName == 'Contact')
                    conDetails.put(obj.apiName, obj.objectName.get(obj.apiName) );
            }
            for(objectField obj : rightColumnObjectFieldList )
            {
                if(obj.objectAPIName == 'Account')
                    accDetails.put(obj.apiName,  obj.objectName.get(obj.apiName) );
                else if(obj.objectAPIName == 'Contact')
                    conDetails.put(obj.apiName,  obj.objectName.get(obj.apiName) );
            }
        }
        catch(exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ex));
            errorMessage= String.valueOf(ex.getMessage()); 
        }
        return null;
    }
    
    /*Redirect on Home when user cancel.*/
    public pageReference cancelAct()
    {
        String strnavigateTo = apexpages.currentpage().getparameters().get('retURL'); //PE v3.7: Summer 18 lightning navigation fix.
        PageReference cancelPage = new PageReference(strnavigateTo);
        cancelPage.setRedirect(true);
        return cancelPage;
    }
    
    /*
    @Description: If all conditions are fulfilled then it insert and redirect to the new Account Detail Page.
    */
    
    public pagereference createIndividualInvestorFinalAct()
    {
        try
        {
            errorMessage='';
            Schema.DescribeSObjectResult accDescribe=  Account.sObjectType.getDescribe();
            Schema.DescribeSObjectResult conDescribe=  contact.sObjectType.getDescribe();
            if(accDetails!= null && !string.isBlank(accDetails.name) )
            {
                if(Schema.sObjectType.Account.Fields.RecordTypeId.isCreateable()){
                    accDetails.recordtypeid = defaultRecordTypeIdPg;
                }
                
                if(accDescribe.isCreateable())
                    insert accDetails;
                conDetails.put('accountid',  accDetails.id );
                if(conDescribe.isCreateable())
                    insert conDetails;
                return new pagereference('/'+accDetails.id);
            }
            else{
                return null;
            }                
        }
        catch(Exception ex)
        {  
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ex));
            errorMessage= String.valueOf(ex.getMessage());          
        }
        return null;
    }
    
    /*
    @Description: Wrapper Class to details of sObject Fields.
    */
    public class objectField{    
        public String apiName{get;set;}             // for storing apiname of the field
        public String label{get;set;}               // for storing label of the field
        public String objectAPIName{get;set;}       // for storing label of the field
        public Boolean isRequired{get;set;}         // to check if the particular field is required or not
        public Boolean isEditable{get;set;}         //
        public sobject objectName{get;set;}          // for storing the objectname of the field
    }
}