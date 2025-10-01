/*
Class        : NavatarExpBuilderLookupPopupCtrlTest
Main Class   : NavatarExpBuilderLookupPopupCtrl
Created By   : Kushal
Created Date : 17-Feb-2023
*/
@isTest
public class NavatarExpBuilderLookupPopupCtrlTest {
	@isTest
    public static void method1() {
        NavatarExpBuilderLookupPopupCtrl.responseData res1 = NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Contact', 'AccountId', 'REFERENCE', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Contact', 'LeadSource', 'PICKLIST', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Contact', 'navpeII_dev18__Industry_Focus__c', 'PICKLIST', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Contact', 'Touchpoint_Overdue__c', 'PICKLIST', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Account', 'Source', 'Picklist', '');
        //NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Contact Role', 'Name', 'Picklist', '');
        //NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Target', 'Source', 'Picklist', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('FUND', 'Name', 'Text', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('FUNDRAISING', 'Name', 'Text', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('FUNDRAISING CONTACT', 'Name', 'Text', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('DEAL', 'Name', 'Text', '');
        NavatarExpBuilderLookupPopupCtrl.getLookUpValues('Marketing Prospect', 'Name', 'Text', '');
        
        NavatarExpBuilderLookupPopupCtrl.SearchItem('Test', 'Contact', '1');
        System.Assert(res1 != null, true);
    }
}