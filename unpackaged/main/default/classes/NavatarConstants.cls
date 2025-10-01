/**
* --------------------------------------------------------------------------------------------------
* Apex class designed to hold the constant value which is getting used in different apex class
* --------------------------------------------------------------------------------------------------
* @author         Adil A
* @modifiedBy     Adil A
* @version        1.0
* @created        2022-11-21
* @modified       2022-11-21
* @modified       2022-12-27
*/
public with sharing class NavatarConstants {
    
    public static final String ADD_NOTE = 'Add Note';
    public static final String ADD_TAG = 'Add Tag';
    public static final String DEAL_ACTIVITY_INFO = 'Deal Activity Info';
    public static final String THEME_ACTIVITY_INFO = 'Theme Activity Info';
    public static final String ACCOUNT_INFO = 'Account Info';
    public static final String CLIP_INFO = 'Clip Info';
    /*updated static text as part of AP2T-718*/
    public static final String ACCOUNT_SUBJECT = 'Please update the name of the company';
    public static final String ACCOUNT_INFO_DESCRIPTION = 'Please update the name of the company';
    public static final String CLIP_DESCRIPTION = 'You have been added to a new clip';
    public static final String DEAL_INFO_DESCRIPTION = 'A new interaction was entered for one of your deals';
    public static final String THEME_INFO_DESCRIPTION = 'A new interaction was entered for one of your themes';//AP2T-718 update end
    //CONSTANTS merged started
    public static final String DUMMY_ACCOUNT_NAME = 'Dummy Account';
    public static final String ACCOUNT_API_NAME = 'Account'; 
    public static final String CONTACT_API_NAME = 'Contact'; 
    public static final String DEAL_TEAM_CREATE_ERROR_MSG = 'Error in creating Deal Team Records =>'; 
    public static final String ACCOUNT_REC_TYPE_ERROR_MSG = 'Error in retrieving the Account RecordType =>';
    
    public static final String TEST_ACCOUNT_NAME = 'TestCreateAccount';
    public static final String COMPANY_REC_TYPE_NAME = 'Company';
    public static final String TEST_CONTACT_NAME = 'Company';
    //CONSTANTS merged NOTIFICATION_ADD_NOTE_TYPE_SET
    public static final Set<String> NOTIFICATION_ACTION_TYPE_SET = new Set<String>{ADD_NOTE , ADD_TAG};
    public static final Set<String> NOTIFICATION_REVIEW_TYPE_SET = new Set<String>{ADD_TAG};
    public static final Set<String> NOTIFICATION_ADD_NOTE_TYPE_SET = new Set<String>{ADD_NOTE};
    public static final Set<String> NOTIFICATION_INFO_TYPE_SET = new Set<String>{DEAL_ACTIVITY_INFO , THEME_ACTIVITY_INFO, ACCOUNT_INFO, CLIP_INFO};
}