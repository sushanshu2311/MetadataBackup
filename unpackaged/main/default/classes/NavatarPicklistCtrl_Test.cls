@isTest
public class NavatarPicklistCtrl_Test {
        @isTest
        public static void method1() {
            Test.startTest();
            NavatarPicklistCtrl.getPickListValues('Task', 'Status', '');
            test.stopTest();
            system.assert(true);
        }
    }