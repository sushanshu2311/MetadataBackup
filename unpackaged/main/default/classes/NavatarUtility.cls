/************************************************************************************
** Module Name : NavatarUtility
** Description : This is a utility class to define method used in different classes
** Class: NavatarUtility
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)          Author                  
** 1.0     2022-11-25              Adil Aleem   
*/
public with sharing class NavatarUtility {
    /*****************************************************************************************************
    * @Name         :   isNotificationAllowed
    * @Description  :   Method to check if notification is allowed
    * @Parameter    :   void
    *****************************************************************************************************/
    @AuraEnabled
    public static Map<String, Boolean> isNotificationAllowed(){
        String strQuery;
        Map<String, Boolean> response = new Map<String, Boolean>();
        List <sObject> setupRecord = new List <sObject> ();
        try{
            strQuery = 'SELECT Id, NN_Action__c, NN_Information__c, NN_Action_Review_Tag__c  FROM navpeII_dev18__Navatar_Setup__c Where navpeII_dev18__Admin_Setting__c = true LIMIT 1';
            setupRecord = Database.query(string.escapesinglequotes(strQuery));
        }
        catch(exception ex){
            strQuery = 'SELECT Id, NN_Action__c, NN_Information__c, NN_Action_Review_Tag__c  FROM navpeII_dev18__Navatar_Setup__c Where navpeII_dev18__Admin_Setting__c = true LIMIT 1';
            setupRecord = Database.query(string.escapesinglequotes(strQuery));
        }
        if(!setupRecord.isEmpty()) {
            response.put( 'action' , Boolean.valueOf(setupRecord[0].get('NN_Action__c')));
            response.put( 'info' , Boolean.valueOf(setupRecord[0].get('NN_Information__c')));
            response.put( 'review' , Boolean.valueOf(setupRecord[0].get('NN_Action_Review_Tag__c')));
        }

        return response;
    }  
}