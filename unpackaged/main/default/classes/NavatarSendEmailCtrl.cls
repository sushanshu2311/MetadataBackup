/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : To get the internal users data
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Hema
****************************************************************************************************/
public with sharing class NavatarSendEmailCtrl {
    Public static List<User> userList;
       
       @AuraEnabled
       public static List<UserWrapper>  getUsersData(){
           List<UserWrapper> userWrapperList = new List<UserWrapper>();
           UserWrapper usrWrapper = new UserWrapper();
           List<User> userList = [SELECT Id, Name, Email FROM User WHERE isActive=true WITH SECURITY_ENFORCED]; //  Added by Hema - W.R.T Secuity Fix
           
           for(User userRec : userList){
              UserWrapper  tempWrapper =   usrWrapper.clone();
                tempWrapper.value = userRec.Email;
               tempWrapper.label = userRec.Name;
               tempWrapper.isSelected = false;
               userWrapperList.add(tempWrapper);
           }
           return userWrapperList;
       }
   
       public class UserWrapper{
          @AuraEnabled  public String value;
          @AuraEnabled public String label;
          @AuraEnabled public Boolean isSelected;
           @AuraEnabled public String usermail;
       }
       
       
       @AuraEnabled
       public static List<UserWrapper> search(String searchString) {
           List<SObject> searchList = new List<SObject>();
            List<UserWrapper> userWrapperList = new List<UserWrapper>();
           UserWrapper usrWrapper = new UserWrapper();
           try {
               String searchStr = '*' + searchString + '*';
               String searchquery =
                   'FIND\'' +
                   searchStr +
                   '\'IN ALL FIELDS RETURNING User( name, email where email != null AND isActive = true)';
               List<List<SObject>> searchResult = search.query(searchquery,AccessLevel.USER_MODE); //  Added by Hema - W.R.T Secuity Fix
               for (List<SObject> curList : searchResult) {
                   searchList.addAll(curList);
               }
             //  contactsList = ((List<Contact>)searchResult[0]);
               userList  = ((List<User>)searchResult[0]);
               
               for(User userRec : userList){
                   UserWrapper  tempWrapper =   usrWrapper.clone();
                   tempWrapper.value = userRec.Email;
                   tempWrapper.label = userRec.Name;
                   tempWrapper.isSelected = false;
                   userWrapperList.add(tempWrapper);
               }
               
   
               system.debug('userWrapperList:::' + userWrapperList);
           } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
           }
           return userWrapperList;
       }
   
   
       @AuraEnabled
       public static void sendEmailController(String emailDetailStr) {
           EmailWrapper emailDetails = (EmailWrapper) JSON.deserialize(emailDetailStr, EmailWrapper.class);
           List < String > toAddressList = emailDetails.toAddress;
           Messaging.reserveSingleEmailCapacity(toAddressList.size());
           Messaging.SingleEmailMessage[] messages = new List < Messaging.SingleEmailMessage > ();
           try {
               messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
               mail.setToAddresses(toAddressList);
               mail.setCcAddresses(emailDetails.ccAddress);
               mail.setBccAddresses(emailDetails.bccAddress);
               mail.setSubject(emailDetails.subject);
               mail.setHtmlBody(emailDetails.body);
               messages.add(mail);
               Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
               for (Messaging.SendemailResult currentResult: results) {
                   if (!currentResult.isSuccess()) {} else if (currentResult.isSuccess()) {}
               }
           } catch (exception e) {
               throw new AuraHandledException(e.getMessage());
           }
       }
   
      public Class EmailWrapper {
          @AuraEnabled  public List<String> toAddress;
          @AuraEnabled  public List<String> ccAddress;
           @AuraEnabled  public List<String> bccAddress;
          @AuraEnabled  public String subject;
           @AuraEnabled public String body;
           @AuraEnabled public List<String> files;
       }
   }