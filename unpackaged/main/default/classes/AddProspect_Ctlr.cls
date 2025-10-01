/*  Added Functionality:
    Developer               :  Vivek Pokharia
    Product Version         :   PE 3.5
    Date of Creation        :   02/06/2016
    Date of Last Update     :   23/06/2016
    Last Updated By         :   Vivek pokharia 
    Purpose of Creation     :   Listed below:
                            1.This class is used as a controller for add prospect Page this is used to send reportsfolders and data and to create marketing prospects in marketing Initiative  
                            2.This classes pass following paremeter to page
                                i)locale Info 
                               ii)report folder 
                              iii)namespace 
                              iv)tree structure  
                              v)currency symbols 
    Developer - Deepak Singh
    Reason - Hyperforce Issue fix Phase 3                 
*/
global with sharing class AddProspect_Ctlr 
{

     public String namspace {get;set;} /* variable for namespace of org*/
     public string propId {get;set;} /*variable  for getting marketing initiative d from url*/
     public string marketingIntvNames {get;set;} /*variable  for  marketing initiative name*/
     public boolean ischkAddProspect {get;set;}
     public string ids{get;set;}
     public Marketing_Prospect__c objlookup1 {get;set;} /*variable  for  lookup field of marketing initiative */
     public string getAPID { get;set;}
     public string rportsFoldername;
     public String createTrees {get;set;} /*variable  used for making tree in report section  */
     public boolean isCurrency {get;set;} /*variable  to check if multicurrency is enabled in class or not  */
     public string localeString {get;set;} /*variable  to check locale of the user  */
     public string strCurrencySystembol {get;set;} /*variable  to check default currency of the user  */
     public static boolean triggerenabled = false;
     public string proptxtdata {get;set;}
     public string ErrorVal {get;set;}
    public string redirecturi{get;set;}
     public boolean ErrorStatus{get;set;}
     public boolean ErrorStatusInsufficient{get;set;}
     public list<string> reportname{get;set;}
     public string instanceNames{get;set;}
     public string keyprfx{get;set;}
     /* This is the standard controller of the class where we get the currencyvalue,default locale,userid marketing initiative 
     @param strCurrencySystembol:  is used to get currency value
     @param userid: is used to get user id.
     @param localeString: Is used to get locale of the user.
     @param namspace:Is used to get namespace of org.
     @param isCurrency :is used to find the org is multicurrency org or not.
     @param rportsFoldername:is used to get the names of folder.
     Createreporttree function is to create tree structure of report in popup. 
     @param objlookup1 :Param used in page for look up fields.
     
     */
     public AddProspect_Ctlr(ApexPages.StandardController controller)
    {
       try 
        {       
            strCurrencySystembol = UserInfo.getDefaultCurrency();
            string user_id = Userinfo.getUserId();
            localeString = UserInfo.getLocale();
            //added by sameer security check
            keyprfx=Marketing_Initiative__c.sobjecttype.getDescribe().getKeyPrefix();
            instanceNames = [select InstanceName from Organization limit 1].InstanceName;
            id temp_ids = apexpages.currentpage().getparameters().get('MIID'); 
            ids = string.valueOf(temp_ids);
            redirecturi= 'https//:'+instanceNames+'.salesforce.com/'+ids;         
            ErrorStatus=true;
            ErrorStatusInsufficient=true;
            reportname=new list<string>();
            namspace = CommonUtility.strNameSpacePrefix;
            
            if(ids != '')
            {
               
               if (Schema.sObjectType.Marketing_Prospect__c.isCreateable() && Schema.sObjectType.Marketing_Prospect__c.isUpdateable() && Schema.sObjectType.Marketing_Prospect__c.isDeletable() && Schema.sObjectType.Marketing_Prospect__c.isAccessible())
                {               
                ErrorStatusInsufficient=true;        
                }
                else
                {              
                ErrorStatusInsufficient=false; 
                }
                objlookup1 = new Marketing_Prospect__c();
                // Added by sameer Security check up 
                id temp_propId = ApexPages.currentPage().getParameters().get('MIID');
                 propId = string.valueOf(temp_propId);
                //propId = ApexPages.currentPage().getParameters().get('MIID');
                list < Marketing_Initiative__c > marketingintvname =  new list < Marketing_Initiative__c >();
                if(Schema.sObjectType.Marketing_Initiative__c.isAccessible() && Schema.sObjectType.Marketing_Initiative__c.fields.name.isAccessible())
                    marketingintvname = [select name from Marketing_Initiative__c where id = : ids limit 1];
                if (marketingintvname.size() > 0)
                {
                    marketingintvnames = marketingintvname[0].name;
                }
                isCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
      
                rportsFoldername = retrievenames();
                createreporttree();
            }
        
            else
            {
              ErrorStatus=false;             
              pageerror();   
             
            }
        } 
        catch (Exception err)
        {
            apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
        }

    }

     /* Back Method is used to redirect Add prospect back to the marketing initiative page layout,*/
     public Pagereference Back()
    {
          try 
        {
           Pagereference pageRef = new Pagereference('/' + propId);         
           pageRef.setredirect(true);
           return pageRef;
        } 
        catch (Exception ex)
        {   
            apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
           ApexPages.addMessage(myMsg);
           return null;

        }
    }
 
  public Pagereference pageerror() 
    {
        try 
        {
            ErrorStatus=false;          
            createTrees='';           
            return null;
        }
        catch (Exception ex) 
        {
            apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
               return null;
        }
    }

     /* Add Prospect method invokes when the user click the Addprospect to MarketInitiative 
    This mehod creates marketprospect based on selected contacts and marketinitiate in which you select add prospect 
    @param getAPID :This is used to holds all the contact ids that user has selected from the add prospect page.
    @param mpclist :This is the parameter to hold already exist marketing initiatives.
    @param MISetID :This param is used to hold all contacts ids that user has selected from page.  
     */
    public PageReference addprospectmethod() 
    {
          try
          {
           triggerenabled = true;
           boolean checkexcep = false;
           list < Marketing_Prospect__c > createlistNew = new list < Marketing_Prospect__c > ();
        
           ischkAddProspect = false;
           List < ID > MIConID = new List < ID > ();
           set < ID > MISetID = new Set < ID > ();          
           string[] MIAddProspect = getAPID.split(',');
           for (string str: MIAddProspect) {
            str = str.Remove('\'');
            MIConID.add((ID) str);
           }
           MISetID.addAll(MIConID);
           if (!Schema.sObjectType.Marketing_Prospect__c.fields.Contact__c.isAccessible()) {

            return null;

           }
           list < Marketing_Prospect__c > mpclist =  new list < Marketing_Prospect__c >();
            if(Schema.sObjectType.Marketing_Prospect__c.isAccessible() && Schema.sObjectType.Marketing_Prospect__c.fields.contact__c.isAccessible()  && Schema.sObjectType.Marketing_Prospect__c.fields.Marketing_Initiative__c.isAccessible() && Schema.sObjectType.contact.fields.name.isAccessible() && Schema.sObjectType.contact.isAccessible())
                mpclist = [select contact__r.id, contact__r.name from Marketing_Prospect__c where Marketing_Initiative__c = : propId and contact__c in : MISetID];

           if (mpclist.size() > 0) {
            ischkAddProspect = true;
            for (Marketing_Prospect__c mpc1: mpclist) {
             MISetID.remove(mpc1.contact__r.id);
            }
           }         
            if (MISetID.size() > 0) 
            {
                for (string contactid1: MISetID) {

                 if (contactid1 != null) {
                  if (!Marketing_Initiative__c.sObjectType.getDescribe().isAccessible()) {

                   return null;

                  }

                  ////Marketing_Prospect__c cc1 = new Marketing_Prospect__c(Contact__c = contactid1, Marketing_Initiative__c = propId);
                  Marketing_Prospect__c cc1 = new Marketing_Prospect__c();
                  if(Schema.sObjectType.Marketing_Prospect__c.fields.Contact__c.isCreateable()){
                    cc1.Contact__c = contactid1;
                  }
                  if(Schema.sObjectType.Marketing_Prospect__c.fields.Marketing_Initiative__c.isCreateable()){
                    cc1.Marketing_Initiative__c = propId;
                  }
                  
                  createlistNew.add(cc1);
                 }
                }
            }
            if (createlistNew.size() > 0) {
                if(Schema.sObjectType.Marketing_Prospect__c.isCreateable()){
                    insert createlistNew;
                }
                triggerenabled = false;
                checkexcep = false;

            }

               if (checkexcep == false) {
                PageReference pageRef = new PageReference('/' + propId);
                pageRef.setredirect(true);
                return pageRef;

               } else {
                return null;
               }

          } catch (Exception ex) {      
       apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
       ApexPages.addMessage(myMsg);
       return null;
      }
     }

 /* 
 This method is used to get he names of custom  folder from the report 
 @param fldrnames :Is used to holds all the foldernames of report.
 
 
 */
 public string retrievenames() {
  try {
   set < string > fldrnames = new set < string > ();
   String fldername;
   list<report> lstReport = new list<report>();
   if(Schema.sObjectType.report.isAccessible() && Schema.sObjectType.report.fields.FolderName.isAccessible())
       lstReport = [select FolderName from report order by FolderName asc LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
   for (report renames:lstReport) {  //(PE3.5, SK, 16Aug2017): added limit clause
    fldrnames.add(renames.FolderName);
   }
   if (fldrnames.size() > 0) {
    fldername = json.serialize(fldrnames);

   }
   return fldername;
  } catch (exception ex) {
   apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
   ApexPages.addMessage(myMsg);
   return 'null';
  }
 }

 /* This method is used to create the tree structure from the report folder and the reports  
@param report_foldername .This param is used to hold the name of reports and folder.
@param mapofreports: param of map type holds value in foldername and reports list
@param createtree :used to create json structure for extjs tree in vf page.

 */
 public void createreporttree()
    {
      try {
       map < string, list < list < string >>> mapofreports = new map < string, list < list < string >>> ();
       // Added By Qadir Khan 06 DEC 2017(Security Issue)..
       list<report> listReport = new list<report>();
       if(Schema.sObjectType.report.isAccessible() && Schema.sObjectType.report.fields.name.isAccessible() && Schema.sObjectType.report.fields.FolderName.isAccessible()){
           listReport = [select id, name, foldername from report order by name Asc limit 10000];
       }
       for (Report report_foldername: listReport) 
       {
            list < string > reporlist = new list < string > ();
            reporlist.add(report_foldername.id);
            reportname.add(String.escapeSingleQuotes(report_foldername.name));  
            reporlist.add(String.escapeSingleQuotes(report_foldername.name));
            
            try 
            {
                if (mapofreports.get(String.escapeSingleQuotes(report_foldername.foldername)).size() > 0)
                {
                  list < list < string >> listdata = mapofreports.get(String.escapeSingleQuotes(report_foldername.foldername));
                  listdata.add(reporlist);
                  mapofreports.put(String.escapeSingleQuotes(report_foldername.foldername), listdata);
                } else 
                {
                  list < list < string >> listdata = new list < list < string >> ();
                  listdata.add(reporlist);
                  mapofreports.put(String.escapeSingleQuotes(report_foldername.foldername), listdata);
                }
            } 
            catch (exception ex)
            {
                 list < list < string >> listdatas = new list < list < string >> ();
                 listdatas.add(reporlist);
                 mapofreports.put(String.escapeSingleQuotes(report_foldername.foldername), listdatas);

            }

        }
           createTrees = '[';
           string createtree;
            if (mapofreports.size() > 0)
            {
                for (string maps: mapofreports.keyset())
                {
                 createtree = '{id:"",text:"' + CommonUtility.replaceChars(maps) + '",cls:"",leaf:false,checked:null,expanded:true,children:[';
                 string child = '';
                 for (List < String > aa: mapofreports.get(maps)) {
                  child = child + '{id:"' + aa.get(0) + '",text:"' + CommonUtility.replaceChars(aa.get(1)) + '",cls:"",leaf:true,checked:null,expanded:false},';
                 }
                 createtree = createtree + child;
                 createtree = createtree.removeEnd(',');
                 createtree = createtree + ']},';
                 createTrees = createTrees + createtree;
                }
            }
           createTrees = createTrees.removeEnd(',');
           createTrees = createTrees + ']';
        }
        catch (Exception ex)
        {
           apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
           ApexPages.addMessage(myMsg);
        }
    }

 /* Report response Remote Action  method this method is used to hit 
 rest on report on based of its id to get all data from the report .
 @param instanceName: This parameter is used to hold name of instance ex na30 of the org.
 @param responsestring :param used to get the response body of the report.
 @param EndUrl: Param used to get the endpont url of the report.
 
 */
     @RemoteAction
     public static String reportresponse(string reportid,string Repname,string body,string counter) 
        {
          try
            {
               string responsestring;
               Id reportsid;
               // Added By Qadir Khan 06 DEC 2017(Security Issue)..
               if(Schema.sObjectType.report.isAccessible() && Schema.sObjectType.report.fields.name.isAccessible()){
                   list<report> id_report =[select id  from report where name =:repname limit 1];
                   reportsid=id_report[0].id;
               }  
              // String instanceName = [select InstanceName from Organization limit 1].InstanceName;
              // instanceName = instanceName.toLowerCase();
              // Hyperforce Issue fix Deepak
              String instanceName = URL.getOrgDomainUrl().toExternalForm();
               if (counter != '1') 
               {
                      
                    //string EndUrl = 'https://' + instanceName + '.salesforce.com/services/data/v34.0/analytics/reports/' + reportsid;                   
                    string EndUrl =  instanceName + '/services/data/v34.0/analytics/reports/' + reportsid;                 
                    
                    HttpRequest req = new HttpRequest();
                    req.setEndPoint(EndUrl);                   
                    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

                    req.setMethod('POST');
                    req.setHeader('content-type', 'application/json');
                    req.setBody(body);
                    Http reqs = new Http();
                    HttpResponse resp = reqs.send(req);
                    responsestring = resp.getBody();
                    

                } else 
                {                    
                    //string EndUrl = 'https://' + instanceName + '.salesforce.com/services/data/v34.0/analytics/reports/' + reportsid;
                    
                    string EndUrl = instanceName + '/services/data/v34.0/analytics/reports/' + reportsid;
                    HttpRequest req = new HttpRequest();
                    req.setEndPoint(EndUrl);
                    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                    req.setMethod('GET');
                    req.setHeader('content-type', 'application/json');
                    Http reqs = new Http();
                    HttpResponse resp = reqs.send(req);
                    responsestring = resp.getBody();                   
                }
                return responsestring;
            }
            catch (exception ex)
            {
               apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
               ApexPages.addMessage(myMsg);
               return null;

            }
        }
    }