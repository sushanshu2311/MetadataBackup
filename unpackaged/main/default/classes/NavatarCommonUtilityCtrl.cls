global without sharing class NavatarCommonUtilityCtrl{
    public NavatarCommonUtilityCtrl(ApexPages.StandardController controller) {

    }


    public NavatarCommonUtilityCtrl(ApexPages.StandardSetController controller) {

    }


public string user_locale{get;set;}    // used in OneHub_SearchOption component.    
   
    public NavatarCommonUtilityCtrl()
    {
        user_locale = UserInfo.getLocale();
    
    }
    
    
    //Code Updated For advance Filter Logic
    @RemoteAction
    global static string executequery1(string getqueryjson,string pageName,string FilterString)  // this method is create the query on the basis of custom criteria.
    {
        system.debug('FilterString+++++++++++++++++++++++++++++++'+FilterString);
        system.debug('getqueryjson+++++++++++++++++++++++++++++++'+getqueryjson);
        list<selectioncriteria> selection1=new list<selectioncriteria>();
        string Namespaceprefix1_new = NavatarSendEmailContactsCtrl.getOrgNamespace();
        if(Namespaceprefix1_new == null) Namespaceprefix1_new = '';
        string fnlquery='';
        string fnlquery_contact='';
        //Modified by Anshika Ahuja dated 1-4-2021 it was throwing error json parser null then added null check
        if(getqueryjson != null){
        System.JSONParser parser = JSON.createParser(getqueryjson);
        selection1=(list<selectioncriteria>)parser.readValueAs(list<selectioncriteria>.class);  // Read the value and create a wrapper class list
        map<string,string> Criterialst=new map<string,string>();
        //Modified by Lakshya on 20211209 to use the existing clsOne_filter class instead of the new class
		//Purpose : clsOne_filter & clsOne_filterNew contain same code
		NavatarFilterResultsCtrl clsactivityobj= new NavatarFilterResultsCtrl();
        string getrowContact='';
        string getrowContactSRN='';
        String fields='';
        system.debug('parser -------'+parser);
        for(selectioncriteria criteria1: selection1)
        {
            system.debug('criteria1..46..'+criteria1);
            string fieldvalue=criteria1.field;
            list<string> fldlist=fieldvalue.split(':');
            system.debug('fldlist..48..'+fldlist);
            
            if(fldlist[0]=='Account')
            {
                if(pageName == 'CMF')
                {
                    fields=Namespaceprefix1_new+'Legal_Name__r.'+fldlist[1];    
                }
                else if(pageName == 'MEF')
                {
                    fields=Namespaceprefix1_new+'Contact__r.Account.'+fldlist[1]; 
                }
                else if(pageName=='CMFC')
                {
                    fields=Namespaceprefix1_new+'Institution__r.'+fldlist[1];
                }
                else if(pageName=='MI' || pageName == 'CMFA')
                {
                    fields='Account.'+fldlist[1];
                }
                else if(pageName == 'MEP')
                {
                    fields=Namespaceprefix1_new+'Contact__r.Account.'+fldlist[1]; 
                }
                else if(pageName=='DAIT' )  // for Add Invite Target Page
                {
                   
                   fields=Namespaceprefix1_new+'Account_Name__r.'+fldlist[1];  
                  //  fields=fldlist[0]+'.'+Namespaceprefix1_new+'Account_Name__r.'+fldlist[1];  
                   
                }
                else if(pageName=='DAIT_ConRole')
                {
                  fields=Namespaceprefix1_new+'Account__r.'+fldlist[1];               
                  
                }
                 else if(pageName=='DAIT_AccContactTab')
                {
                  fields='Account.'+fldlist[1];                       
                  
                }
                 
            }
            else if(fldlist[0]=='Fund')
            {
                fields=Namespaceprefix1_new+'Fund_Name__r.'+fldlist[1];     
            }
            else if(fldlist[0]=='Contact')
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
                    fields =Namespaceprefix1_new+'Contact__r.'+fldlist[1];
                }
                //Updated by Qadir Khan on 03-April-2017
                 else if(pageName=='DAIT')  // for Add Invite Target Page
                {
                    
                    fields='Contact.'+fldlist[1]; 
                }
                else if(pageName=='DAIT_ConRole')
                {
                  fields=Namespaceprefix1_new+'Contact__r.'+fldlist[1];               
                                     
                }  
                else if(pageName=='DAIT_AccContactTab')
                {
                  fields='Contact.'+fldlist[1];               
                                   
                } 
                else if(pageName == 'MEP')
                {
                    fields=Namespaceprefix1_new+'Contact__r.'+fldlist[1]; 
                }
                else 
                {   
                    fields=Namespaceprefix1_new+'Contact__r.'+fldlist[1];               
                }                   
                
            }
            //Updated by Qadir Khan on 03-April-2017
            else if(fldlist[0]=='Target')
            {
                fields=Namespaceprefix1_new+'Target__r.'+fldlist[1];     
                 
                if(pageName=='DAIT' )  // for Add Invite Target Page
                {
                   fields=fldlist[0]+'.'+fldlist[1];  
                   system.debug('==fields===1========='+fields);
                   
                }
                else if(pageName=='DAIT_ConRole' )  // for Add Invite Target Page
                {
                   fields=Namespaceprefix1_new+'Target__r.'+fldlist[1]; 
                    system.debug('==fields===2========='+fields);
                   
                }
                
            }
            else if(fldlist[0]=='Fundraising')
            {
                if(pageName == 'CMF')
                {
                    fields = fldlist[1];
                }
                else if(pageName == 'MEF' || pageName == 'CMFC')
                {
                    fields=Namespaceprefix1_new+'Fundraising__r.'+fldlist[1]; 
                }   
            }
            else if(fldlist[0]=='Fundraising Contact')
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
              system.debug('fields-----------------'+fields);
               system.debug('fldlist[3]-----------------'+fldlist[3]);
            if(fldlist[3].toUpperCase()=='REFERENCE')
              getrow = clsactivityobj.operatorOperation(fields,fldlist[3].toUpperCase(),criteria1.Operator,criteria1.Value,string.valueof(UserInfo.getLocale()));
            else
              getrow = clsactivityobj.operatorOperation(fields,fldlist[3].toUpperCase(),criteria1.Operator,criteria1.Value,string.valueof(UserInfo.getLocale()));
            
             Boolean isTaskApp=false;
             System.Debug('getrow------------'+getrow);    
           
            if(!isTaskApp)
            {
                Criterialst.put(criteria1.serialnumber,getrow);
                system.debug('Criterialst--------'+Criterialst);
            }
         
        }
        system.debug('Criterialst1 --------'+Criterialst);
        system.debug('FilterString-123----'+FilterString);
        
        
        //Updated by Qadir Khan on 03-April-2017
        if(FilterString !='')
        {
            set<string> num=new set<String>{'1','2','3','4','5','6','7','8','9','10'};
            list<string> filterlogiclist = FilterString.split(',');
            system.debug('Entered filterlogiclist....+++++++++++++++++++++++++++++++'+filterlogiclist);
            
                for(integer i=0;i<filterlogiclist.size();i++)
                {
                
                    if(num.contains(filterlogiclist[i]))
                    {  
                        if(pageName!='DAIT')
                        {
                            if(fnlquery.length()>0 && fnlquery!='')
                            {
                                fnlquery=fnlquery+' '+Criterialst.get(filterlogiclist[i]);
                               
                            }
                            else
                            {
                                fnlquery = Criterialst.get(filterlogiclist[i]);
                               
                    
                            }                  
                        }
                        else
                        { 
            
                            
                            if(Criterialst.get(filterlogiclist[i]).contains('Contact') ) 
                            {                     
                              if(fnlquery_contact.length()>0 && fnlquery_contact!='')
                                {
                                    fnlquery_contact=fnlquery_contact+' '+Criterialst.get(filterlogiclist[i]);
                                    
                                }
                                else
                                {
                                    fnlquery_contact = Criterialst.get(filterlogiclist[i]);
                                    
                                }
                            }
                            else
                            {
                               if(fnlquery.length()>0 && fnlquery!='')
                                {
                                    fnlquery=fnlquery+' '+Criterialst.get(filterlogiclist[i]);
                                   
                                }
                                else
                                {
                                    fnlquery = Criterialst.get(filterlogiclist[i]);
                                   
                                }   
                            }
                            system.debug('fnlquery============='+fnlquery);
                            
                        }
                        if(fnlquery_contact!='' && fnlquery!='')
                        {
               
                        fnlquery = fnlquery + ' @@@@ '+ fnlquery_contact;
                        system.debug('fnlquery7============='+fnlquery);
                        }
                        else
                        {
              
                            fnlquery =fnlquery;
                        }
                        system.debug('fnlquerylast============='+fnlquery);
                    }
                    else
                    {
                        fnlquery=fnlquery+' '+filterlogiclist[i];
                        system.debug('FilterStringand----'+fnlquery);
                    }
                }
                               
        }  
        else
        {
            for(string s1:Criterialst.keyset())
            {
              
                if(pageName!='DAIT')
                {
                    if(fnlquery.length()>0 && fnlquery!='')
                    {
                        fnlquery=fnlquery+' AND '+Criterialst.get(s1);
                         system.debug('fnlquery1============='+fnlquery);
                    }
                    else
                    {
                        fnlquery = Criterialst.get(s1);
                        system.debug('fnlquery2============='+fnlquery);
                        
                    }                  
                }
                else
                { 
                
                
                    if(Criterialst.get(s1).contains('Contact') ) 
                    {                     
                      if(fnlquery_contact.length()>0 && fnlquery_contact!='')
                        {
                            fnlquery_contact=fnlquery_contact+' AND '+Criterialst.get(s1);
                            system.debug('fnlquery3============='+fnlquery);
                        }
                        else
                        {
                            fnlquery_contact = Criterialst.get(s1);
                            system.debug('fnlquery4============='+fnlquery);
                        }
                    }
                    else
                    {
                       if(fnlquery.length()>0 && fnlquery!='')
                        {
                            fnlquery=fnlquery+' AND '+Criterialst.get(s1);
                            system.debug('fnlquery5============='+fnlquery);
                        }
                        else
                        {
                            fnlquery = Criterialst.get(s1);
                            system.debug('fnlquery6============='+fnlquery);
                        }   
                    }
                    system.debug('fnlquery============='+fnlquery);
                }
            }
            //Modified by Anshika Ahuja as filter was not working if criteria starts from Contact object
            if(fnlquery_contact!='' && fnlquery ==''){
                fnlquery = fnlquery_contact;
              system.debug('fnlquery for contact'+fnlquery);    
            }
            //Modification ended Anshika Ahuja
            if(fnlquery_contact!='' && fnlquery!='')
            {
               
              fnlquery = fnlquery + ' @@@@ '+ fnlquery_contact;
              system.debug('fnlquery7============='+fnlquery);
            }
            else
            {
              
              fnlquery =fnlquery;
            }
            system.debug('fnlquerylast============='+fnlquery);
         
        }
            return fnlquery;
        }
        //return fnlquery_contact;
        return fnlquery;          
    } 
    //Code Added For advance Filter Logic Started.
    public List<string> chckFilter(String filtertst) 
    {
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
    
    /*
        Description:
    */
    WebService static boolean checkDate(String strCallDate, string strDueDate) {
        system.debug('------------------inside getValidateDate------');
        try{ 
        system.debug(Date.parse(strCallDate) > Date.parse(strDueDate));    
            return (Date.parse(strCallDate) > Date.parse(strDueDate)); 
        }
        catch(Exception objExcp){
            system.debug('------------------Exception in catch block------');
            return false;
        }
    }
    
    /*
        Description:
    */
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
    global static string executequery(string getqueryjson,string pageName)  // this method is create the query on the basis of custom criteria.
    {
    
     string Namespaceprefix1_new = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix + '__';
     system.debug('pageName============='+pageName);
     system.debug('getqueryjson============='+getqueryjson);
           
           if(pageName=='DAIT_ConRole')
           {             
             
           }
           else
           { 
             
           }   
           
          // user user_info=[select id,LocaleSidKey from user where id=:userinfo.getuserid() limit 1];
            list<selectioncriteria> selection1=new list<selectioncriteria>();
            string fnlquery='';
            string fnlquery_contact='';
            System.JSONParser parser = JSON.createParser(getqueryjson);
            selection1=(list<selectioncriteria>)parser.readValueAs(list<selectioncriteria>.class);  // Read the value and create a wrapper class list
            map<string,string> Criterialst=new map<string,string>();
            //Modified by Lakshya on 20211209 to use the existing clsOne_filter class instead of the new class
			//Purpose : clsOne_filter & clsOne_filterNew contain same code
			NavatarFilterResultsCtrl clsactivityobj=new NavatarFilterResultsCtrl();
            string getrowContact='';
            string getrowContactSRN='';
            String fields='';
            for(selectioncriteria criteria1:selection1)
            {
                string fieldvalue=criteria1.field;                
                 
                list<string> fldlist=fieldvalue.split(':');
                              
                if(fldlist[0]=='Account')
                {
                    if(pageName=='MI' )
                            fields='Account.'+fldlist[1];    // update by Manvendra 
                   
                   else if(pageName=='DAIT' )  // for Add Invite Target Page
                    {
                       
                       fields=Namespaceprefix1_new+'Account_Name__r.'+fldlist[1];  
                      //  fields=fldlist[0]+'.'+Namespaceprefix1_new+'Account_Name__r.'+fldlist[1];  
                       
                    }
                    else if(pageName=='DAIT_ConRole')
                    {
                      fields=Namespaceprefix1_new+'Account__r.'+fldlist[1];               
                      
                    }
                     else if(pageName=='DAIT_AccContactTab')
                    {
                      fields='Account.'+fldlist[1];                       
                      
                    }
                     
               
                    else if(pageName=='MEF' )
                       fields=Namespaceprefix1_new+'Account__r.'+fldlist[1];
                       
                    else if(pageName=='MEP') 
                       fields=Namespaceprefix1_new+'Contact__r.Account.'+fldlist[1];
                }
                else if(fldlist[0]=='Contact' )
                {
                    if(pageName=='MI')
                        fields='Contact.'+fldlist[1]; 
                    else if(pageName=='DAIT')  // for Add Invite Target Page
                    {
                        
                        fields='Contact.'+fldlist[1]; 
                    }
                    else if(pageName=='DAIT_ConRole')
                    {
                      fields=Namespaceprefix1_new+'Contact__r.'+fldlist[1];               
                                         
                    }  
                    else if(pageName=='DAIT_AccContactTab')
                    {
                      fields='Contact.'+fldlist[1];               
                                       
                    }  
                    
                    else if(pageName=='MEF' || pageName=='MEP')
                     fields=Namespaceprefix1_new+'Contact__r.'+fldlist[1];
                
                }
                 else if(fldlist[0]=='Target')
                 {
                    fields=Namespaceprefix1_new+'Target__r.'+fldlist[1];     
                     
                    if(pageName=='DAIT' )  // for Add Invite Target Page
                    {
                       fields=fldlist[0]+'.'+fldlist[1];  
                       system.debug('==fields===1========='+fields);
                       
                    }
                     if(pageName=='DAIT_ConRole' )  // for Add Invite Target Page
                    {
                       fields=Namespaceprefix1_new+'Target__r.'+fldlist[1]; 
                        system.debug('==fields===2========='+fields);
                       
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
                    {
                      getrow = clsactivityobj.operatorOperation(fields,fldlist[3].toUpperCase(),criteria1.Operator,criteria1.Value,string.valueof(UserInfo.getLocale()));
                      
                      }
                      
                    else
                    {
                      getrow = clsactivityobj.operatorOperation(fields,fldlist[3].toUpperCase(),criteria1.Operator,criteria1.Value,string.valueof(UserInfo.getLocale()));
                    
                    
                    }
                Boolean isTaskApp=false;
                if(!isTaskApp)
                {
                 Criterialst.put(criteria1.serialnumber,getrow);
                 }
              
            }
            for(string s1:Criterialst.keyset())
            {
              
              if(pageName!='DAIT')
              {
                  if(fnlquery.length()>0 && fnlquery!='')
                    {
                        fnlquery=fnlquery+' AND '+Criterialst.get(s1);
                         system.debug('fnlquery1============='+fnlquery);
                    }
                    else
                    {
                        fnlquery = Criterialst.get(s1);
                        system.debug('fnlquery2============='+fnlquery);
                        
                    }                  
              }
              else
              { 
                
                
                if(Criterialst.get(s1).contains('Contact') ) 
                {                     
                  if(fnlquery_contact.length()>0 && fnlquery_contact!='')
                    {
                        fnlquery_contact=fnlquery_contact+' AND '+Criterialst.get(s1);
                        system.debug('fnlquery3============='+fnlquery);
                    }
                    else
                    {
                        fnlquery_contact = Criterialst.get(s1);
                        system.debug('fnlquery4============='+fnlquery);
                    }
                }
                else
                {
                   if(fnlquery.length()>0 && fnlquery!='')
                    {
                        fnlquery=fnlquery+' AND '+Criterialst.get(s1);
                        system.debug('fnlquery5============='+fnlquery);
                    }
                    else
                    {
                        fnlquery = Criterialst.get(s1);
                        system.debug('fnlquery6============='+fnlquery);
                    }   
                }
            system.debug('fnlquery============='+fnlquery);
                
              }
            }
            
            if(fnlquery_contact!='' && fnlquery!='')
            {
               
              fnlquery = fnlquery + ' @@@@ '+ fnlquery_contact;
              system.debug('fnlquery7============='+fnlquery);
            }
            else
            {
              
              fnlquery =fnlquery;
            }
            system.debug('fnlquerylast============='+fnlquery);
            return fnlquery;
           // return fnlquery_contact; 
        
                              
    }
   
   
    class selectioncriteria // class for selection criteria
    {
        public string serialnumber{get;set;}
        public string field{get;set;}
        public string Operator{get;set;}
        public string Value{get;set;}
        
    }
     WebService static string Specialchar(string getqueryjson)  // Handle the special character for location fields
    {
        string rtn=String.escapeSingleQuotes(getqueryjson.trim());
        return  rtn;
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
            system.debug(d1);
            system.debug('mydate '+mydate );
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
            system.debug(d1);
            system.debug('mydate '+mydate );
            string ret=string.valueof(mydate);
            ret=ret.substring(0,10)+' 00:00:00';
            system.debug('ret'+ret);
            return ret;
        }
    }
    
    
    WebService static string convertdateGMT(string getqueryjson)   // convert the datetime in GMT salesforce format
    {
        date mydate =  date.parse(getqueryjson);
        system.debug('_mydate '+mydate );
        string ret=string.valueof(mydate);
        system.debug('ret'+ret);
        datetime mydate2=datetime.valueOfGmt(ret+' '+'00:00:00');
        string ret1=mydate2.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT' );
        system.debug('ret1'+ret1);
        return ret1;
    }
    
    
    WebService static string convertdatetimeGMT(string getqueryjson)  // convert the datetime in salesforce format
    {
        datetime mydate = datetime.parse(getqueryjson);
        string ret=string.valueof(mydate);
        datetime mydate2=datetime.valueOfGmt(ret);
        string ret1=mydate2.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT' );
        return ret1;
    }
     
    

}