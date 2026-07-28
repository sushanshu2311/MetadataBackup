@isTest
public class DynamicDataFactoryTest {

    @isTest
    static void testCreateSObject_AllBranches() {
        // Account
        SObject acc = DynamicDataFactory.createSObject('Account', true, 1);
        System.assertNotEquals(null, acc.get('Name'), 'Account Name should be set');

        // Contact
        SObject con = DynamicDataFactory.createSObject('Contact', true, 2);
        System.assertNotEquals(null, con.get('LastName'), 'Contact LastName should be set');

        // User
        User u = (User)DynamicDataFactory.createSObject('User', true, 3);
        System.assertNotEquals(null, u.get('LastName'), 'User LastName should be set');

        // Deal
        SObject deal = DynamicDataFactory.createSObject('navpeII__Pipeline__c', true, 4);
        System.assertNotEquals(null, deal, 'Deal SObject should not be null');

        // Task
        SObject task = DynamicDataFactory.createSObject('Task', true, 5);
        System.assertNotEquals(null, task, 'Task SObject should not be null');

        // Event
        SObject event = DynamicDataFactory.createSObject('Event', true, 6);
        System.assertNotEquals(null, event, 'Event SObject should not be null');

        // Fund
        SObject fund = DynamicDataFactory.createSObject('navpeII__Fund__c', true, 7);
        System.assertNotEquals(null, fund, 'Fund SObject should not be null');

        // Fundraising
        SObject fundraising = DynamicDataFactory.createSObject('navpeII__Fundraising__c', true, 8);
        System.assertNotEquals(null, fundraising, 'Fundraising SObject should not be null');
    }

    @isTest
    static void testGetDefaultPicklistValue() {
        SObject acc = DynamicDataFactory.createSObject('Account');
        Schema.DescribeFieldResult fieldDescribe = Account.Industry.getDescribe();
        String pickVal = DynamicDataFactory.getDefaultPicklistValue(acc, fieldDescribe);
        System.assertNotEquals(null, pickVal, 'Picklist value should not be null');
    }

    @isTest
    static void testUnsupportedObjectTypeException() {
        Boolean exceptionThrown = false;
        try {
            DynamicDataFactory.createSObject('NonExistentObject');
        } catch (DynamicDataFactory.UnsupportedObjectTypeException e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'Exception should be thrown for unsupported object type');
    }
}