/*
Class            : clientDataBatch
Purpose          : For fetching loginHistory Data and sends data to Sales org using call out. 
Version          : v4.2
*/
global class clientDataBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    global String noOfDays;
    global  final string sfdcEndPoint = Label.Navatar_URL+'services/apexrest/loginHistory'; // Sales org Site API URL
    global  static final string smtpEndPoint = 'https://api.smtp.com/v4/messages?api_key=7c53d69fe8471ee4d3bde6d70a1f0e181e0e0b55'; // SMTP API token
    global  Map<string,user>  mapUserdetail = new Map<string,user>(); // map of UserId and UserDetails
    global  set<string> userSet = new set<string>();
    global  clientDataHistory clntData = new clientDataHistory();
    
    global clientDataBatch(String noOfDays)
    {
        this.noOfDays = noOfDays;
    }
            
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        try
        {
            clntData.isBatches = false;
            clntData.orgId = UserInfo.getOrganizationId();
            
            List<orgLicenseDetail> licnsDetailList = new List<orgLicenseDetail>();
            Set<string> licnsList = new Set<string>();
            
            for(UserLicense usrLicns : [SELECT Id, Name, TotalLicenses, UsedLicenses FROM UserLicense WHERE Name = 'Salesforce' OR Name = 'Salesforce Platform'])
            {
                orgLicenseDetail licnsDetail = new orgLicenseDetail();
                licnsDetail.orglicenseName = usrLicns.Name;
                licnsDetail.orgTotalLicenses = usrLicns.TotalLicenses;
                licnsDetail.orgUsedLicenses =  usrLicns.UsedLicenses;
                licnsDetailList.add(licnsDetail);

                licnsList.add(usrLicns.Id);
            }
            
            if(licnsDetailList.size()>0)
                clntData.orgLicenses = licnsDetailList;

            if(licnsList.size()>0)
            {
                for(user usr : [SELECT Id, Name, isActive, UserName, Email, Profile.UserLicense.Name FROM User WHERE Profile.UserLicense.Id IN : licnsList])
                {
                    mapUserdetail.put(usr.Id,usr);
                    userSet.add(usr.Id);
                }
            }

            String query = 'SELECT Id, UserId, LoginTime, Status, Browser, Application, SourceIp FROM LoginHistory WHERE LoginTime = '+noOfDays+' AND UserId IN :userSet order by LoginTime desc';
            system.debug('query:::'+query);
            return Database.getQueryLocator(query);
        }
        catch(Exception Ex)
        {   
            exceptionEmail('In \'start\' method of \'clientDataBatch\' class - '+Ex.getMessage(), Ex.getLineNumber());
            return null;
        }
    }
    
    //This method is for for proccessing loginHistory data
    global void execute(Database.BatchableContext BC, List<LoginHistory> loginhstry)
    {
        try{
            List<usrLoginHistory> lgnHistoryList = new List<usrLoginHistory>();
            for(LoginHistory lgn : loginhstry)
            {
                if(lgn.Status == 'Success')
                {
                    usrLoginHistory lgnHstry = new usrLoginHistory();
                    lgnHstry.loginHistoryId = lgn.Id;
                    lgnHstry.userInfo = createUserdetail(lgn.UserId);
                    lgnHstry.usrApplication = lgn.Application;
                    lgnHstry.usrBrowser = lgn.Browser;
                    lgnHstry.usrSourceIp = lgn.SourceIp;
                    lgnHstry.usrLoginTime = lgn.LoginTime;
                    lgnHistoryList.add(lgnHstry);
                }
            }
            if(lgnHistoryList.size()>0)
            {
                clntData.lgnHistory = lgnHistoryList;
                string JsonclntData = Json.serialize(clntData);
                postForLgnHstry(JsonclntData);
                clntData.isBatches = true;
                lgnHistoryList = new List<usrLoginHistory>();
            }
        }
        catch(Exception Ex)
        {
            exceptionEmail('In \'execute\' method of \'clientDataBatch\' class - '+Ex.getMessage(), Ex.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    global userDetailInfo createUserdetail(string usId)
    {
        userDetailInfo usrdtl = new userDetailInfo();
        usrdtl.usrId = usId;
        usrdtl.usrName = mapUserdetail.get(usId).Name;
        usrdtl.usrActive = mapUserdetail.get(usId).isActive;
        usrdtl.usrUserName = mapUserdetail.get(usId).UserName;
        usrdtl.usrUserEmail = mapUserdetail.get(usId).Email;
        usrdtl.usrUserProfileUserLicenseName = mapUserdetail.get(usId).Profile.UserLicense.Name;
        return usrdtl;
    }
    
    //This method is to send Email in any exception occur
    global static void exceptionEmail(string exMessage , integer exLineNo)
    {
        string emailsubject = 'Scheduler Error in Fetching/Processing Login History Data – '+UserInfo.getOrganizationId();
        string emailBody = 'Hello,<br/><br/>An error has occurred in the scheduler while fetching or processing Login History Data for Client Org – <b>'+UserInfo.getOrganizationId()+'</b>. Kindly check the below error for reference:<br/><br/> <b>'+exMessage+' at Line no.'+exLineNo+'</b><br/><br/>Please do not respond to this mail.';
        
        string reqbdy = createSMTPBody(emailsubject, emailBody).replace('fromDetail','from');
        emailFromSMTP(reqbdy);
    }
    
    // This method create  SMTP Body
    global static string createSMTPBody(string emailsubject, string emailBody)
    {
        
        Address frmAddrss = new Address();
        frmAddrss.name = 'noreply@navatargroup.com';
        frmAddrss.address = 'noreply@navatargroup.com';
        
        List<Address> listToAddrss = new List<Address>();
        Address toAddrss = new Address();
        toAddrss.name = 'navatarexception@navatargroup.com';
        toAddrss.address = 'navatarexception@navatargroup.com';
        listToAddrss.add(toAddrss);
        
        
        senderDetails sndrDtl = new senderDetails();
        sndrDtl.fromDetail = frmAddrss;
        
        recipientsDetails rcpntDtl = new recipientsDetails();
        rcpntDtl.to = listToAddrss;
        
        msgBody emlBody = new msgBody();
        List<bodyParts> listBdyPrts = new List<bodyParts>();
        bodyParts bdyprts = new bodyParts();
        bdyprts.content = '<html><head></head><body>'+emailBody+'</body></html>';
        bdyprts.content_type = 'text/html';
        bdyprts.encoding = 'quoted-printable';
        listBdyPrts.add(bdyprts);
        emlBody.parts = listBdyPrts;
        
        smtpRequest smtpReq = new smtpRequest();
        smtpReq.originator = sndrDtl;
        smtpReq.body = emlBody;
        smtpReq.recipients = rcpntDtl;
        smtpReq.channel = 'rjoe_navatargroup_com';
        smtpReq.subject = emailsubject;
        
        return Json.serialize(smtpReq);
        
    }
    
    // This method for callout SalesOrg
    global void postForLgnHstry(string reqBody)
    {
        system.debug('reqBody========='+reqBody);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(sfdcEndPoint);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(reqBody);
        response = http.send(req);
        system.debug('response:::'+response);
        system.debug('responseBody:::'+response.getBody());
        if(response.getStatusCode() != 200)
        {
            string emailsubject = 'Scheduler Error during making Call-Out to Sales Org – '+UserInfo.getOrganizationId();
            string emailBody = 'Hello,<br/><br/>An error has occurred in the scheduler while making call-out to Sales Org from Client Org – <b>'+UserInfo.getOrganizationId()+'</b>. Kindly check the below error for reference:<br/><br/> <b> In \'postForLgnHstry\' method of \'scheduledClientData\' class - '+response.getStatusCode()+' '+response.getBody()+'</b><br/><br/>Please do not respond to this mail.';
            
            string reqbdy = createSMTPBody(emailsubject, emailBody).replace('fromDetail','from');
            
            system.debug('reqbdy========='+reqbdy);
            HttpResponse response1 = new HttpResponse();
            HttpRequest req1 = new HttpRequest();
            Http http1 = new Http();
            req1.setEndpoint(smtpEndPoint);
            req1.setMethod('POST');
            req1.setTimeout(120000);
            req1.setHeader('Content-Type', 'application/json');
            req1.setBody(reqbdy);
            response1 = http1.send(req1);
            system.debug('response:::'+response1);
            system.debug('responseBody:::'+response1.getBody());
        }
    }
    
    //This method is for SMTP Email
    global static void emailFromSMTP(string reqbdy)
    {
        system.debug('reqbdy========='+reqbdy);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(smtpEndPoint);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(reqbdy);
        response = http.send(req);
        system.debug('response:::'+response);
        system.debug('responseBody:::'+response.getBody());
    }
    
    //******************Wrapper for Login History*************************************
    global class clientDataHistory
    {
        global Boolean isBatches;
        global string orgId;
        global List<orgLicenseDetail> orgLicenses;
        global List<usrLoginHistory> lgnHistory;
    }
    global class orgLicenseDetail
    {
        global string orglicenseName;
        global Integer orgTotalLicenses;
        global Integer orgUsedLicenses;
    }
    global class usrLoginHistory
    {
        global string loginHistoryId;
        global userDetailInfo userInfo;
        global string usrApplication;
        global string usrBrowser;
        global string usrSourceIp;
        global dateTime usrLoginTime;
    }
    global class userDetailInfo
    {
        global string usrId; 
        global string usrName;
        global Boolean usrActive;
        global string usrUserName;
        global string usrUserEmail;
        global string usrUserProfileUserLicenseName;
    }
    //****************************************************END*****************************

    //******************Wrapper for Sending SMTP Email*************************************
    global class smtpRequest
    {
        global senderDetails originator;
        global msgBody body;
        global recipientsDetails recipients;
        global string channel;
        global string subject;
    }
    global class senderDetails
    {
        global Address fromDetail;
    }
    global class Address
    {
        global string name;
        global string address;
    }
    global class msgBody
    {
        global List<bodyParts> parts;
    }
    global class bodyParts
    {
        global string content;
        global string content_type;
        global string encoding;
    }
    global class recipientsDetails
    {
        global List<Address> to;
    }
    //****************************************************END*****************************
}