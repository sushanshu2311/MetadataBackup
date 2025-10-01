/*
    Developer               :   Sumitab Saxena
    Product Version         :   PE 3.0
    Date of Creation        :   23/01/2015
    Date of Last Update     :   22/08/2016
    Last Updated By         :   Sumitab Saxena
    Purpose of Creation     :   Listed below:
                                1. Creating Responce for search criteria of CMF and MEF visualforce page.
                                2. Convertion of Date And DateTime format dynamically according to user's Local.
                                3. Added Functionality for Advance filter Logic
*/

global with sharing class CommonUtilityGlobal
{

    public CommonUtilityGlobal(ApexPages.StandardController controller) 
    {

    }

    public CommonUtilityGlobal(ApexPages.StandardSetController controller) 
    {

    }


    public string user_locale{get;set;}    // used in OneHub_SearchOption component.    
   
    public CommonUtilityGlobal()
    {
        user_locale = UserInfo.getLocale();
    }
    
    
     
    
    //Code Updated For advance Filter Logic
    @RemoteAction
    global static string executequery1(string getqueryjson,string pageName,string FilterString)  // this method is create the query on the basis of custom criteria.
    {    try{
            list<selectioncriteria> selection1=new list<selectioncriteria>();
            string fnlquery='';
            System.JSONParser parser = JSON.createParser(getqueryjson);
            selection1=(list<selectioncriteria>)parser.readValueAs(list<selectioncriteria>.class);  // Read the value and create a wrapper class list
            map<string,string> Criterialst=new map<string,string>();
            clsOne_filter clsactivityobj= new clsOne_filter();
            string getrowContact='';
            string getrowContactSRN='';
            String fields='';
            
            for(selectioncriteria criteria1: selection1)
            {
                string fieldvalue=criteria1.field;
                list<string> fldlist=fieldvalue.split(':');
                string ObjVal=fldlist[0].trim();
                
                if(ObjVal=='Account')
                {
                    if(pageName == 'CMF')
                    {
                        fields='Legal_Name__r.'+fldlist[1];    
                    }
                    else if(pageName == 'MEF')
                    {
                        fields='Contact__r.Account.'+fldlist[1]; 
                    }
                    else if(pageName=='CMFC')
                    {
                        fields='Institution__r.'+fldlist[1];
                    }
                    else if(pageName=='MI' || pageName == 'CMFA')
                    {
                        fields='Account.'+fldlist[1];
                    }
                    else if(pageName == 'MEP')
                    {
                        fields='Contact__r.Account.'+fldlist[1]; 
                    }
                     
                }
                else if(ObjVal=='Fund')
                {
                    fields='Fund_Name__r.'+fldlist[1];     
                }
                else if(ObjVal=='Contact')
                {
                    if(pageName=='MI'){
                        fields='Contact.'+fldlist[1];
                    }
                    else if(pageName=='CMF' || pageName=='CMFA')
                    {
                        fields = fldlist[1];
                    }
                    else if(pageName=='CMFC')
                    {
                        fields ='Contact__r.'+fldlist[1];
                    }
                    else
                    {   
                        fields='Contact__r.'+fldlist[1];               
                    }
                }
                else if(ObjVal=='Fundraising')
                {
                    if(pageName == 'CMF')
                    {
                        fields = fldlist[1];
                    }
                    else if(pageName == 'MEF' || pageName == 'CMFC')
                    {
                        fields='Fundraising__r.'+fldlist[1]; 
                    }   
                }
                else if(ObjVal=='Fundraising Contact')
                {
                    if(pageName == 'CMFC' || pageName == 'MEF')
                    {
                        fields = fldlist[1];
                    }
                                           
                }
                else
                {
                    fields = fldlist[1];
                }   
                
                if(criteria1.Value==null)
                {
                    criteria1.Value='';
                }
              
                string getrow='';
                if(fldlist[3].toUpperCase()=='REFERENCE')
                  getrow = clsactivityobj.operatorOperation(fields,fldlist[3].toUpperCase(),criteria1.Operator,criteria1.Value,string.valueof(UserInfo.getLocale()));
                else
                  getrow = clsactivityobj.operatorOperation(fields,fldlist[3].toUpperCase(),criteria1.Operator,criteria1.Value,string.valueof(UserInfo.getLocale()));
                
                 Boolean isTaskApp=false;
                     
               
                if(!isTaskApp)
                {
                    Criterialst.put(criteria1.serialnumber,getrow);
                    
                }
             
            }
                      
            if(FilterString !='')
            {
                set<string> num=new set<String>{'1','2','3','4','5','6','7','8','9','10'};
                list<string> filterlogiclist = FilterString.split(',');
                for(integer i=0;i<filterlogiclist.size();i++)
                {
                    if(num.contains(filterlogiclist[i]))
                    {
                        if(Criterialst.get(filterlogiclist[i])!=null)
                        {
                            fnlquery=fnlquery+' '+Criterialst.get(filterlogiclist[i]);
                        }
                    }
                    else
                    {
                        fnlquery=fnlquery+' '+filterlogiclist[i];
                    }
                }
            }
            else
            {
                for(string s1:Criterialst.keyset())
                {
                    if(fnlquery.length()>0 && fnlquery!='')
                    {
                        fnlquery=fnlquery+' AND '+Criterialst.get(s1);
                    }
                    else
                    {
                        fnlquery = Criterialst.get(s1);
                    }
                    
                }   
                
            }
            return fnlquery;
        }
        catch(Exception objExcp){
            return null;
        }       
                   
    }
   
    class selectioncriteria // class for selection criteria
    {
        public string serialnumber{get;set;}
        public string field{get;set;}
        public string Operator{get;set;}
        public string Value{get;set;}
        
    }
      @RemoteAction
     WebService static string Specialchar(string getqueryjson)  // Handle the special character for location fields
    {
        try{
        string rtn=String.escapeSingleQuotes(getqueryjson.trim());
        return  rtn;
        }
         catch(Exception objExcp){
            return null;
        }
    }
      @RemoteAction
  WebService static string convertdate(string getqueryjson)  // convert the date in salesforce format
    {
      try 
        {
            date mydate = date.parse(getqueryjson);
            string ret=string.valueof(mydate);
            return ret;
        }
      catch(exception e)
        {
            date mydate = date.parse(getqueryjson);
            datetime d1=mydate;
            string ret=string.valueof(mydate);  
                      
            return ret;
        }
    }
      @RemoteAction
    WebService static string convertdatetime(string getqueryjson)  // convert the datetime in salesforce format
    {
        try {
            datetime mydate = datetime.parse(getqueryjson);
            string ret=string.valueof(mydate);
            
            return ret;
            
            
        }
        catch(exception e)
        {
            date mydate = date.parse(getqueryjson);
            datetime d1=mydate;
            string ret=string.valueof(mydate);
            ret=ret.substring(0,10)+' 00:00:00';
            
            return ret;
        }
    }
    
      @RemoteAction
    WebService static string convertdateGMT(string getqueryjson)   // convert the datetime in GMT salesforce format
    { try{
        date mydate =  date.parse(getqueryjson);
        string ret=string.valueof(mydate);
        datetime mydate2=datetime.valueOfGmt(ret+' '+'00:00:00');
        string ret1=mydate2.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT' );
        return ret1;
       }
      catch(Exception objExcp){
            return null;
        }
    }
    
      @RemoteAction
    WebService static string convertdatetimeGMT(string getqueryjson)  // convert the datetime in salesforce format
    { try{
        datetime mydate = datetime.parse(getqueryjson);
        string ret=string.valueof(mydate);
        datetime mydate2=datetime.valueOfGmt(ret);
        string ret1=mydate2.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT' );
        return ret1;
       }
       catch(Exception objExcp){
            return null;
        }
    }
    //Code Added For advance Filter Logic Started.
    public List<string> chckFilter(String filtertst) 
    { try{
        List<string> filtr=new List<String>();
        List<string> finalfiltr=new List<String>();
        set<string> requireddata=new set<String>{'1','2','3','4','5','6','7','8','9','10','and','or','not','(',')'};
        filtr.clear();
        finalfiltr.clear();
        filtertst=filtertst.toLowerCase();
        filtertst=filtertst.replace('(',' ( ').replace(')',' ) ').replace('and',' and ').replace('or',' or ').replace('not',' not ');
        filtr=filtertst.split(' ');       
        for(string str:filtr)
        {
            if(requireddata.contains(str))
                finalfiltr.add(str);
        } 
        return finalfiltr;
      }
      catch(Exception objExcp){
            return null;
        }
    } 
    //Code Added For advance Filter Logic End.
    public CommonUtilityGlobal.CommonUtilityGlobal(CreateMassFundraisingCls controller){
        // for extenstion used in javascrit remorting for advance filter code on OneHub_Individuals Page.    
    }
    
    
    WebService static boolean checkDate(String strCallDate, string strDueDate) {
        try{     
            return (Date.parse(strCallDate) > Date.parse(strDueDate)); 
        }
        catch(Exception objExcp){
            return false;
        }
    }
    
    
    WebService static boolean getValidDate(String strDate) {
        try{
            Date checkDate = Date.parse(strDate);   
            return true; 
        }
        catch(Exception objExcp){
            return false;
        }
    }
    @RemoteAction
    global static string nameSpacePrefix()  // this method is create the query on the basis of custom criteria.
    {
       return 'abc';
    }
    
    //Code Updated For advance Filter Logic
    @RemoteAction
    global static string executequery(string getqueryjson,string pageName){return null;}  // this method is create the query on the basis of custom criteria.
    

}