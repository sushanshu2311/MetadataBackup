global with sharing class Listener implements Messaging.InboundEmailHandler {
      public XMLDomDp dom;
      Account accObj = new Account ();
      pipeline__c pipeObj = new  pipeline__c ();
      Contact conObj = new Contact ();
  //    FeedPost fpost=new  FeedPost ();
      Errorlog__c errorObj=new Errorlog__c ();
     
      String ErrorMsg = '' ; 
      public string usrStatus {get;set;}
      Public string usrIdentifier{get;set;}
      Public string NavatarProductUserName{get;set;}
      Public string replyto{get;set;}   
      Public string strKeyContactName;
      Integer i = 0 ; 
      Public string cstmInfomsg;
      Public String DpmlSubject{get;set;}
      list<user> usrob=new list<user>();
      Public list<string> lstname=new list<string>();
      Public string strconlastname='';

      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
      {
        
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        try
        {         
          String DpmlText= '';
          DpmlSubject=email.subject.trim();
          
          if(DpmlSubject.contains('Force.com Sandbox'))
          {
                   DpmlSubject = DpmlSubject.Replace('Force.com Sandbox: ','').trim();
          }
          integer dpmlstr=0;
          integer dpmlend=0;
           DpmlText= string.valueof(email.htmlBody);
           
           if(DpmlText.contains('<html>') || DpmlText.contains('</html>'))
           { 
           dpmlstr=DpmlText.indexOf('<DPML>');
           dpmlend=DpmlText.indexOf('</html>');
          
           DpmlText=DpmlText.substring(dpmlstr,dpmlend);
           }
          
          dom=new XMLDomDp(DpmlText); 
         
          if(DpmlSubject!=null &&  DpmlText!=null)
          {
            if(DpmlSubject.trim()=='DPML1')
            {
               for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
              {
                  usrIdentifier=e.getValue('UserIdentifier');
                  replyto=e.getValue('ReplyTo');
                  
                  NavatarProductUserName=e.getValue('NavatarProductUserName');
                  i = 1 ;
              } 
            }
            else
            {
               for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
               {
                 usrIdentifier=e.getValue('UserIdentifier');
               }
            }
            if(i ==1)
            {
               if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.Fields.User_Identifier__c.isAccessible() && Schema.sObjectType.User.Fields.Username.isAccessible() && Schema.sObjectType.User.Fields.IsActive.isAccessible() ){ 
                   usrob =[select id,Username, IsActive , User_Identifier__c from user where UserName=:NavatarProductUserName limit 1 ];
               }
               if(usrob.size() == 0)
                {
                   Errormsg='<DPML><Value>3</Value><UserIdentifier>'+usrIdentifier+'</UserIdentifier><ErrorMsg>The Product UserName you have provided Does Not Exist.Contact Support</ErrorMsg><ProductOrgId>'+UserInfo.getOrganizationId()+'</ProductOrgId><Product>PE</Product></DPML>';
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                   mail.setSubject('DPML3');

                   mail.setPlainTextBody(Errormsg);
                   mail.setUseSignature(false);
                   mail.setToAddresses(new String[] {replyto});

                   
                   Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.Email[] {mail});
                   if(r[0].IsSuccess() == false)
                   {
                        if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                            errorObj.Error_Description__c = 'Email Limit Exceeded';
                        }
                        if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                            errorObj.DPML_Subject__c=DpmlSubject;
                        }
                        
                        if(Schema.sObjectType.Errorlog__c.isCreateable()){
                            insert errorObj ;
                        }
                   }
                }
              
              }
              else
              { 
                if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.Fields.User_Identifier__c.isAccessible() && Schema.sObjectType.User.Fields.Username.isAccessible() && Schema.sObjectType.User.Fields.IsActive.isAccessible() ){ 
                    usrob =[select id,Username, IsActive , User_Identifier__c from user where User_Identifier__c=:usrIdentifier limit 1 ];
                }
              }
          
          for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
          {
             usrIdentifier=e.getValue('UserIdentifier');
          }
          
        if(usrob.size()>0)
        {
          //User Verification in PE 
          If(DpmlSubject.trim()=='DPML1')
          {
         
          if(usrob[0].isactive==false)
          {
          // Send DPML 3
          
           Errormsg='<DPML><Value>3</Value><UserIdentifier>'+usrIdentifier+'</UserIdentifier><ErrorMsg>"The Product UserName you have provided is inactive"</ErrorMsg><ProductOrgId>'+UserInfo.getOrganizationId()+'</ProductOrgId><Product>PE</Product></DPML>';
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
           mail.setSubject('DPML3');
           mail.setPlainTextBody(Errormsg);
           mail.setUseSignature(false);
           mail.setToAddresses(new String[] {replyto});

          
           Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.Email[] {mail});
           
               if(r[0].IsSuccess() == false)
               {
                    if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                        errorObj.Error_Description__c = 'Email Limit Exceeded';
                    }
                    if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                        errorObj.DPML_Subject__c=DpmlSubject;
                    }
                    if(Schema.sObjectType.Errorlog__c.isCreateable()){
                        insert errorObj ;
                    }
               }
          }
          else if(usrob[0].User_Identifier__c !=null)
          {
          // Send DPML 3
           Errormsg='<DPML><Value>3</Value><UserIdentifier>'+usrIdentifier+'</UserIdentifier><ErrorMsg>"The Product UserName you have provided is already in use. Contact Support"</ErrorMsg><ProductOrgId>'+UserInfo.getOrganizationId()+'</ProductOrgId><Product>PE</Product></DPML>';
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
           mail.setSubject('DPML3');
           mail.setPlainTextBody(Errormsg);
           mail.setUseSignature(false);
           mail.setToAddresses(new String[] {replyto});

          
           Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.Email[] {mail});
                       if(r[0].IsSuccess() == false)
                       {
                            if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                                errorObj.Error_Description__c = 'Email Limit Exceeded';
                            }
                            if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                                errorObj.DPML_Subject__c=DpmlSubject;
                            }
                            if(Schema.sObjectType.Errorlog__c.isCreateable()){
                                insert errorObj ;
                            }
                       }
          }
          else 
          {
          // Sending DPML 2
          
          if(Schema.sObjectType.User.fields.User_Identifier__c.isUpdateable())
            usrob[0].User_Identifier__c=usrIdentifier;
          try
          {
            if(Schema.sObjectType.User.isUpdateable()){
                update usrob;
            }
            
           Errormsg='<DPML><Value>2</Value><UserIdentifier>'+usrIdentifier+'</UserIdentifier><ProductOrgId>'+UserInfo.getOrganizationId()+'</ProductOrgId><Product>PE</Product></DPML>';
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
           mail.setSubject('DPML2');
           mail.setPlainTextBody(Errormsg);
           mail.setUseSignature(false);
           mail.setToAddresses(new String[] {replyto});

           
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.Email[] {mail});
                       if(r[0].IsSuccess() == false)
                       {
                            if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                                errorObj.Error_Description__c = 'Email Limit Exceeded';
                            }
                            if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                                errorObj.DPML_Subject__c=DpmlSubject;
                            }
                            if(Schema.sObjectType.Errorlog__c.isCreateable()){
                                insert errorObj ;
                            }
                       }
          
          } 
          catch (System.DmlException e) {
               for (Integer i = 0; i < e.getNumDml(); i++) {    
                  ErrorMsg  =  ErrorMsg  + e.getDmlMessage(i);
                }
                if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                    errorObj.Error_Description__c = ErrorMsg ;
                }
                if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                    errorObj.DPML_Subject__c=DpmlSubject;
                }
               
               if(Schema.sObjectType.Errorlog__c.isCreateable()){
                    insert errorObj ;
               }
            }
          }
          
          }
          
          //Deal Portal to PE
          
          
          if(DpmlSubject=='DPML9') 
          {
           
          strKeyContactName='';
          string s='';
          
          // SK: 7Dec2017
          List<RecordType> rtypes = new List<RecordType>();
          if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.Name.isAccessible() && 
              Schema.sObjectType.RecordType.Fields.sObjectType.isAccessible() && Schema.sObjectType.RecordType.Fields.isActive.isAccessible())
          {
              rtypes = [Select Name, Id From RecordType where sObjectType='account' and isActive=true and Name='Company' limit 1];
          }
            
          //}
          for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
          {
            //  check for null in account
            if(e.getvalue('GeographicRegion')=='null' && Schema.sObjectType.ACCOUNT.fields.Geographic_Region__c.isCreateable())
            {
                accObj.Geographic_Region__c='';
            }
            else 
            {
                if(Schema.sObjectType.ACCOUNT.fields.Geographic_Region__c.isCreateable()){
                    accObj.Geographic_Region__c=e.getvalue('GeographicRegion');
                }
            }
                     
            
            // Pipeline 
            if(Schema.sObjectType.pipeline__c.fields.name.isCreateable()){
                if(e.getvalue('DealName')=='null')
                {
                    pipeObj.name='';
                }
                else
                {
                    pipeObj.name=e.getvalue('DealName');
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.Stage__c.isCreateable()){
                if(e.getvalue('stage')=='null')
                { 
                    pipeObj.Stage__c='New/Initial Interest';
                }
                else
                { 
                    pipeObj.Stage__c='New/Initial Interest';
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.Transaction_Type__c.isCreateable()){
                if(e.getvalue('TransactionType')=='null')
                {
                    pipeObj.Transaction_Type__c='';
                }
                else
                {
                    pipeObj.Transaction_Type__c=e.getvalue('TransactionType');
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.Revenue_Range_in_mn__c.isCreateable()){
                if(e.getvalue('Revenue')=='null')
                {
                    pipeObj.Revenue_Range_in_mn__c='';
                }
                else
                {
                    pipeObj.Revenue_Range_in_mn__c=e.getvalue('Revenue');
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.EBITDA_Range_in_mn__c.isCreateable()){
                if(e.getvalue('EBITDA')=='null')
                {
                    pipeObj.EBITDA_Range_in_mn__c='';
                }
                else
                {
                    pipeObj.EBITDA_Range_in_mn__c=e.getvalue('EBITDA');
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.Deal_Size_Range_in_mn__c.isCreateable()){
                if(e.getvalue('DealSize')=='null' || e.getvalue('DealSize')=='')
                {
                    pipeObj.Deal_Size_Range_in_mn__c='';
                }
                else
                {
                    pipeObj.Deal_Size_Range_in_mn__c=e.getvalue('DealSize');
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.Deal_Description__c.isCreateable()){
                if(e.getvalue('Description')=='null' || e.getvalue('Description')=='')
                {
                    pipeObj.Deal_Description__c='';
                }
                else
                {
                    pipeObj.Deal_Description__c=e.getvalue('Description');
                }
            }
            
            if(Schema.sObjectType.pipeline__c.fields.Deal_Keywords__c.isCreateable()){
                if(e.getvalue('DealKeywords')=='null')
                {
                    pipeObj.Deal_Keywords__c='';
                }
                else
                {
                    pipeObj.Deal_Keywords__c=e.getvalue('DealKeywords');
                }
            }
            
            // check for contact
            if(e.getvalue('KeyContactName')=='null')
            {
                strKeyContactName='';
                if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                    conObj.lastname='';
                }
            }
            else
            {
                strKeyContactName=e.getvalue('KeyContactName');
                if(strKeyContactName.contains(' '))
                {
                    lstname=strKeyContactName.split(' ');
                }
                if(lstname.size()>1)
                {
                    if(Schema.sObjectType.Contact.fields.firstname.isCreateable()){
                        conObj.firstname= lstname[0];
                    }
                    
                    for(integer i=1;i<lstname.size();i++)
                    {
                        strconlastname=strconlastname+' '+lstname[i];
                    }
                    
                    if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                        conObj.lastname=strconlastname.trim();
                    }
                }
                else if(lstname.size()==1){
                    if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                        conObj.lastname=lstname[0];
                    }
                }
                else if(lstname.size()==0){
                    if(strKeyContactName !='' && Schema.sObjectType.Contact.fields.lastname.isCreateable())
                        conObj.lastname=strKeyContactName;
                }
            }
            
            if(Schema.sObjectType.Contact.fields.Phone.isCreateable()){
                if(e.getvalue('KeyContactPhone')=='null'){
                    conObj.Phone= '';
                }
                else{
                    conObj.Phone=e.getvalue('KeyContactPhone');
                }
            }
            
            if(Schema.sObjectType.Contact.fields.email.isCreateable()){         
                if(e.getvalue('KeyContactEmail')=='null'){
                    conObj.email='';
                }
                else
                {
                    conObj.email=e.getvalue('KeyContactEmail');
                }
            }
            
            if(Schema.sObjectType.Contact.fields.fax.isCreateable()){   
                if(e.getvalue('KeyContactFax')=='null'){
                    conObj.fax='';
                }
                else{
                    conObj.fax=e.getvalue('KeyContactFax');
                }
            }
            
            //insert account;
            if(Schema.sObjectType.ACCOUNT.fields.name.isCreateable()){
                accObj.name=e.getvalue('DealName');
             }
             if(Schema.sObjectType.ACCOUNT.fields.RecordTypeId.isCreateable()){
                accObj.RecordTypeId=rtypes[0].id ;
             }
             if(Schema.sObjectType.ACCOUNT.fields.ownerid.isCreateable()){
                accObj.ownerid=usrob[0].Id ;
             }
             if(Schema.sObjectType.ACCOUNT.fields.Source__c.isCreateable()){
                accObj.Source__c ='Navatar Deal Connect';
             }
                         
            if(Schema.sObjectType.pipeline__c.fields.Source__c.isCreateable()){
                pipeObj.Source__c ='Navatar Deal Connect';
            }
            if(Schema.sObjectType.pipeline__c.fields.Pipeline_Data_Currency__c.isCreateable()){
                pipeObj.Pipeline_Data_Currency__c='USD';
            }
            
            if(Schema.sObjectType.Contact.fields.Source__c.isCreateable()){
                conObj.Source__c ='Navatar Deal Connect';
            }
            if(Schema.sObjectType.Contact.fields.OwnerId.isCreateable()){
                conObj.OwnerId = usrob[0].Id ;
            }
          }
          
          if(Schema.sObjectType.Account.isCreateable()){
            insert accObj;
          }
          // Check pipeline Company relationship in PE v4.5  By Rahulk
          if(Schema.getGlobalDescribe().get(CommonUtility.strNameSpacePrefix+'Pipeline__c').getDescribe().fields.getMap().get(CommonUtility.strNameSpacePrefix+CommonUtility.chkmasterLookupInPiplineAPI()).getDescribe().isCreateable()){
             pipeObj.put(CommonUtility.chkmasterLookupInPiplineAPI(), accObj.id);
           }
            if(Schema.sObjectType.Contact.fields.accountid.isCreateable()){
                conObj.accountid=accObj.id;
            }

            if(strKeyContactName!='')
            {
                if(Schema.sObjectType.Contact.isCreateable()){
                    insert conObj ;
                }
            }
            if(Schema.sObjectType.pipeline__c.isCreateable()){
                insert pipeObj ;
            }

            if(usrIdentifier !='' && usrIdentifier!=null)
            {
                cstmInfomsg='New information has been downloaded from Navatar Deal Connect. Please check for duplicates.';                    
                
                DPInfo__c DPcustomstng = new DPInfo__c();
                if(Schema.sObjectType.DPInfo__c.fields.UserIdentifier__c.isCreateable() || Schema.sObjectType.DPInfo__c.fields.UserIdentifier__c.isUpdateable()){
                    DPcustomstng.UserIdentifier__c = usrIdentifier;
                }
                if(Schema.sObjectType.DPInfo__c.fields.Name.isCreateable() || Schema.sObjectType.DPInfo__c.fields.Name.isUpdateable()){
                    DPcustomstng.Name = usrIdentifier;
                }
                if(Schema.sObjectType.DPInfo__c.fields.Info__c.isCreateable() || Schema.sObjectType.DPInfo__c.fields.Info__c.isUpdateable()){
                    DPcustomstng.Info__c = cstmInfomsg;
                }
                
                
                if(Schema.sObjectType.DPInfo__c.isCreateable() || Schema.sObjectType.DPInfo__c.isUpdateable()){
                    upsert  DPcustomstng UserIdentifier__c;
                }                    
            }
          }
          
          //Company Download - Deal Portal to PE (Full Download)
          
          else if(DpmlSubject.trim()=='DPML10')
          {
 
           strKeyContactName='';
           string s='';
           
           // SK: 7Dec2017
          List<RecordType> rtype = new List<RecordType>();
          if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.Name.isAccessible() && 
              Schema.sObjectType.RecordType.Fields.sObjectType.isAccessible() && Schema.sObjectType.RecordType.Fields.isActive.isAccessible())
          {
              rtype = [Select Name, Id From RecordType where sObjectType='account' and isActive=true and Name= 'Institution' limit 1];
          }
          
          for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
          {
            if(Schema.sObjectType.Account.fields.billingstreet.isCreateable()){
                if(e.getvalue('BillingStreet')=='null')
                {
                    accObj.billingstreet='';
                }
                else
                {
                    accObj.billingstreet=e.getvalue('BillingStreet');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingcity.isCreateable()){
                if(e.getvalue('BillingCity')=='null')
                {
                    accObj.billingcity ='';
                }
                else
                {
                    accObj.billingcity=e.getvalue('BillingCity');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingstate.isCreateable()){
                if(e.getvalue('BillingState')=='null')
                {
                    accObj.billingstate='';
                }
                else
                {
                    accObj.billingstate=e.getvalue('BillingState');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingpostalcode.isCreateable()){
                if(e.getvalue('BillingPostalCode')=='null')
                {
                    accObj.billingpostalcode='';
                }
                else
                {
                    accObj.billingpostalcode=e.getvalue('BillingPostalCode');
                }
            }
            
            if(Schema.sObjectType.Account.fields.fax.isCreateable()){
                if(e.getvalue('Fax')=='null')
                {
                    accObj.fax='';
                }
                else
                {
                    accObj.fax=e.getvalue('Fax');
                }
            }
            
            if(Schema.sObjectType.Account.fields.Keywords__c.isCreateable()){
                if(e.getvalue('CompanyKeywords')=='null')
                {
                    accObj.Keywords__c='';
                }
                else
                {
                    accObj.Keywords__c=e.getvalue('CompanyKeywords');
                }
            }
            
            if(Schema.sObjectType.Account.fields.Institution_Type__c.isCreateable()){   
                if(e.getvalue('CompanyType')== 'null')
                {
                    accObj.Institution_Type__c='';
                }
                else
                {
                    accObj.Institution_Type__c=e.getvalue('CompanyType') ;
                }
            }
            
            if(Schema.sObjectType.Account.fields.website.isCreateable()){
                if(e.getvalue('Website')=='null')
                {
                    accObj.website='';
                }
                else
                {
                    accObj.website=e.getvalue('Website');
                }
            }
            
            if(Schema.sObjectType.Account.fields.Phone.isCreateable()){         
                if(e.getvalue('Phone')=='null')
                {
                accObj.Phone='';
                }
                else
                {
                accObj.Phone=e.getvalue('Phone');
                }   
            }
            
            if(Schema.sObjectType.Account.fields.billingcountry.isCreateable()){    
                if(e.getvalue('BillingCountry')=='null')
                {
                accObj.billingcountry='';
                }
                else
                {
                accObj.billingcountry=e.getvalue('BillingCountry');
                }
            }
            
            // check for null in contact
            if(e.getvalue('KeyContactName')== 'null')
            {
                strKeyContactName='';
                
                if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                    conObj.lastname='';
                }
            }
            else
            {
                strKeyContactName=e.getvalue('KeyContactName');
                if(strKeyContactName.contains(' '))
                {
                    lstname=strKeyContactName.split(' ');
                }
                
                if(lstname.size()>1)
                {
                    if(Schema.sObjectType.Contact.fields.firstname.isCreateable()){
                        conObj.firstname= lstname[0];
                    }
                    
                    for(integer i=1;i<lstname.size();i++)
                    {
                        strconlastname=strconlastname+' '+lstname[i];
                    }
                    
                    if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                        conObj.lastname=strconlastname.trim();
                    }
                }
                else if(lstname.size()==1)
                {
                    if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                        conObj.lastname=lstname[0];
                    }
                }
                else if(lstname.size()==0)
                {
                    if(strKeyContactName !=''){
                        if(Schema.sObjectType.Contact.fields.lastname.isCreateable()){
                            conObj.lastname=strKeyContactName;
                        }
                    }
                }
            }
            
            if(Schema.sObjectType.Contact.fields.Phone.isCreateable()){
                if(e.getvalue('KeyContactPhone')=='null')
                {
                    conObj.Phone= '';
                }
                else
                {
                    conObj.Phone=e.getvalue('KeyContactPhone');
                }
            }
            
            if(Schema.sObjectType.Contact.fields.email.isCreateable()){
                if(e.getvalue('KeyContactEmail')=='null')
                {
                    conObj.email='';
                }
                else
                {
                    conObj.email=e.getvalue('KeyContactEmail');
                }
            }
            
            if(Schema.sObjectType.Contact.fields.fax.isCreateable()){
                if(e.getvalue('KeyContactFax')=='null')
                {
                    conObj.fax='';
                }
                else
                {
                    conObj.fax=e.getvalue('KeyContactFax');
                }
            }
            
            if( Schema.sObjectType.Account.fields.name.isCreateable() ){
                accObj.name=e.getvalue('AccountName');
            }
            if( Schema.sObjectType.Account.fields.RecordTypeId.isCreateable() ){
                accObj.RecordTypeId=rtype[0].id;
            }
            if( Schema.sObjectType.Account.fields.ownerid.isCreateable() ){
                accObj.ownerid=usrob[0].Id ;
            }
            if( Schema.sObjectType.Account.fields.Source__c.isCreateable() ){
                accObj.Source__c ='Navatar Deal Connect';
            }
            
            if(Schema.sObjectType.Contact.fields.Source__c.isCreateable()){
                conObj.Source__c ='Navatar Deal Connect';
            }
            if(Schema.sObjectType.Contact.fields.OwnerId.isCreateable()){
                conObj.OwnerId = usrob[0].Id ;
            }
        }
           
          
            if(Schema.sObjectType.Account.isCreateable()){
                insert accObj;
            }
            
            if(Schema.sObjectType.Contact.fields.accountid.isCreateable()){
                conObj.accountid=accObj.id;
            }
            
            if(strKeyContactName!='')
            {
                if(Schema.sObjectType.Contact.isCreateable()){
                    insert conObj ;
                }
            }
            
            if(usrIdentifier !='' && usrIdentifier!=null)
            {
            cstmInfomsg='New information has been downloaded from Navatar Deal Connect. Please check for duplicates.';                    
            DPInfo__c DPcustomstng=new DPInfo__c();
            if(Schema.sObjectType.DPInfo__c.fields.UserIdentifier__c.isCreateable() || Schema.sObjectType.DPInfo__c.fields.UserIdentifier__c.isUpdateable())
                DPcustomstng.UserIdentifier__c=usrIdentifier;
            if(Schema.sObjectType.DPInfo__c.fields.name.isCreateable() || Schema.sObjectType.DPInfo__c.fields.name.isUpdateable())
                DPcustomstng.name=usrIdentifier;
            if(Schema.sObjectType.DPInfo__c.fields.Info__c.isCreateable() || Schema.sObjectType.DPInfo__c.fields.Info__c.isUpdateable())
                DPcustomstng.Info__c=cstmInfomsg;
                if(Schema.sObjectType.DPInfo__c.isCreateable() || Schema.sObjectType.DPInfo__c.isUpdateable()){
                    upsert  DPcustomstng UserIdentifier__c;                    
                }
            }
            
          }
          
          //Company Download - Deal Portal to PE (Partial Download)
          else if(DpmlSubject.trim()=='DPML11')
          {
          string s='';
          
          // SK: 7Dec2017
          List<RecordType> rtype = new List<RecordType>();
          if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.Fields.Name.isAccessible() && 
            Schema.sObjectType.RecordType.Fields.sObjectType.isAccessible() && Schema.sObjectType.RecordType.Fields.isActive.isAccessible())
          {
              rtype = [Select Name, Id From RecordType where sObjectType='account' and isActive=true and Name='Institution' limit 1];
          }
          
          for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
          {
            //Insert Account 
            if(Schema.sObjectType.Account.fields.website.isCreateable()){
                if(e.getvalue('Website')=='null')
                {
                    accObj.website='';
                }
                else
                {
                    accObj.website=e.getvalue('Website');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingcountry.isCreateable()){
                if(e.getvalue('BillingCountry')=='null')
                {
                    accObj.billingcountry='';
                }
                else
                {
                    accObj.billingcountry=e.getvalue('BillingCountry');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingstreet.isCreateable()){
                if(e.getvalue('BillingStreet')=='null')
                {
                    accObj.billingstreet='';
                }
                else
                {
                    accObj.billingstreet=e.getvalue('BillingStreet');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingcity.isCreateable()){
                if(e.getvalue('BillingCity')== 'null')
                {
                    accObj.billingcity ='';
                }
                else
                {
                    accObj.billingcity=e.getvalue('BillingCity');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingstate.isCreateable()){
                if(e.getvalue('BillingState')== 'null')
                {
                    accObj.billingstate='';
                }
                else
                {
                    accObj.billingstate=e.getvalue('BillingState');
                }
            }
            
            if(Schema.sObjectType.Account.fields.billingpostalcode.isCreateable()){
                if(e.getvalue('BillingPostalCode')== 'null' )
                {
                    accObj.billingpostalcode='';
                }
                else
                {
                    accObj.billingpostalcode=e.getvalue('BillingPostalCode');
                }
            }
            
            if(Schema.sObjectType.Account.fields.fax.isCreateable()){
                if(e.getvalue('Fax')== 'null')
                {
                    accObj.fax='';
                }
                else
                {
                    accObj.fax=e.getvalue('Fax');
                }
            }
            
            if(Schema.sObjectType.Account.fields.phone.isCreateable()){
                if(e.getvalue('Phone')== 'null')
                {
                    accObj.phone='';
                }
                else
                {
                    accObj.phone=e.getvalue('Phone');
                }
            }
            
            if(Schema.sObjectType.Account.fields.Keywords__c.isCreateable()){
                if(e.getvalue('CompanyKeywords')=='null')
                {
                    accObj.Keywords__c='';
                }
                else
                {
                    accObj.Keywords__c=e.getvalue('CompanyKeywords');
                }
            }
            
            if(Schema.sObjectType.Account.fields.Institution_Type__c.isCreateable()){
                if(e.getvalue('CompanyType')== 'null')
                {
                    accObj.Institution_Type__c='';
                }
                else
                {
                    accObj.Institution_Type__c=e.getvalue('CompanyType') ;
                }
            }
            
            if(Schema.sObjectType.Account.fields.name.isCreateable()){
                accObj.name=e.getvalue('AccountName');
            }
            if(Schema.sObjectType.Account.fields.RecordTypeId.isCreateable()){
                accObj.RecordTypeId=rtype[0].id ;
            }
            if(Schema.sObjectType.Account.fields.Source__c.isCreateable()){
                accObj.Source__c ='Navatar Deal Connect'; 
            }
            if(Schema.sObjectType.Account.fields.OwnerId.isCreateable()){
                accObj.OwnerId = usrob[0].Id ;
            }
          }
          
            if(Schema.sObjectType.Account.isCreateable()){
                insert accObj;  
            }
            
            if(usrIdentifier !='' && usrIdentifier!=null)
            {
            cstmInfomsg='New information has been downloaded from Navatar Deal Connect. Please check for duplicates.';                    
            DPInfo__c DPcustomstng=new DPInfo__c();
            if(Schema.sObjectType.DPInfo__c.fields.UserIdentifier__c.isCreateable() || Schema.sObjectType.DPInfo__c.fields.UserIdentifier__c.isUpdateable())
                DPcustomstng.UserIdentifier__c=usrIdentifier;
            if(Schema.sObjectType.DPInfo__c.fields.name.isCreateable() || Schema.sObjectType.DPInfo__c.fields.name.isUpdateable())
                DPcustomstng.name=usrIdentifier;
            if(Schema.sObjectType.DPInfo__c.fields.Info__c.isCreateable() || Schema.sObjectType.DPInfo__c.fields.Info__c.isUpdateable())
                DPcustomstng.Info__c=cstmInfomsg;
                            
                if(Schema.sObjectType.DPInfo__c.isCreateable() || Schema.sObjectType.DPInfo__c.isUpdateable()){
                    upsert  DPcustomstng UserIdentifier__c;                    
                }
            }
  
          }
          else if(DpmlSubject.trim()=='DPML12')
          {
         /* for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
          {            
            if(Schema.sObjectType.FeedPost.fields.ParentId.isCreateable()){
                fpost.ParentId = usrob[0].Id;                       
            }
            if(Schema.sObjectType.FeedPost.fields.Body.isCreateable()){
                fpost.Body = e.getvalue('Msg'); 
            }
            if(Schema.sObjectType.FeedPost.fields.CreatedById.isCreateable()){
                fpost.CreatedById=usrob[0].Id;              
            }
          }
            
            if(Schema.sObjectType.FeedPost.isCreateable()){
                insert fpost;   
            }*/
        
         }
          
          //Deal Match – Notification
          else if(DpmlSubject.trim()=='DPML13')
          {
             /* for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
              {            
                 if(Schema.sObjectType.FeedPost.fields.ParentId.isCreateable()){
                    fpost.ParentId = usrob[0].Id; 
                 }
                 if(Schema.sObjectType.FeedPost.fields.CreatedById.isCreateable()){
                    fpost.CreatedById=usrob[0].Id;                  
                 }
                 if(Schema.sObjectType.FeedPost.fields.Body.isCreateable()){
                    fpost.Body = e.getvalue('Msg');  
                 }
              }
              
              if(Schema.sObjectType.FeedPost.isCreateable()){
                insert fpost;   
              }*/
          
          }else if(DpmlSubject.trim()=='DPML16')
          {
              /*for(XMLDomDp.element e: dom.getElementsByTagName('DPML'))
              {            
                 if(Schema.sObjectType.FeedPost.fields.ParentId.isCreateable()){
                    fpost.ParentId = usrob[0].Id; 
                 }
                 if(Schema.sObjectType.FeedPost.fields.CreatedById.isCreateable()){
                    fpost.CreatedById=usrob[0].Id;                  
                 }
                 if(Schema.sObjectType.FeedPost.fields.Body.isCreateable()){
                    fpost.Body = e.getvalue('Msg');  
                 }
               
              }
              
              if(Schema.sObjectType.FeedPost.isCreateable()){
                insert fpost;   
              }*/
          }
        }
        else
        {
            if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                errorObj.Error_Description__c ='User Identifier is null,You are not verified Or does not exist in Navatar Deal Connect,Contact Support with your User Name';
            }
            if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                errorObj.DPML_Subject__c=DpmlSubject;
            }
            
            if(Schema.sObjectType.Errorlog__c.isCreateable()){
                insert errorObj ;
            }
        } 
        } 
          return result;  
        }
        catch (exception e) 
        {
            if(e.getTypeName()=='System.XmlException') 
        {           
              ErrorMsg=e.getMessage()+', '+'Please Check DPML';
              if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                errorObj.Error_Description__c = ErrorMsg ;
              }
              if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                errorObj.DPML_Subject__c=DpmlSubject;
              }
              if(Schema.sObjectType.Errorlog__c.isCreateable()){
                insert errorObj ;
              }
        }
        else 
        {
            ErrorMsg  =  ErrorMsg  + e.getMessage();
            if(Schema.sObjectType.Errorlog__c.fields.Error_Description__c.isCreateable()){
                errorObj.Error_Description__c = ErrorMsg   ;
            }
            if(Schema.sObjectType.Errorlog__c.fields.DPML_Subject__c.isCreateable()){
                errorObj.DPML_Subject__c=DpmlSubject;
            }
            
            if(Schema.sObjectType.Errorlog__c.isCreateable()){
                insert errorObj ;
           }
        
        }
        return null;
        }
           
      }  

  }