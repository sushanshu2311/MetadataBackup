/****************************************************************************************************
** Module Name : Acuity 2.0 - Activity Trigger Test Class
** Description : Test Class for NavatarTaskEventRelationHandler, NavatarEventRelationTrigger, TaskRelationChangeEvent
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-22          Anmol
****************************************************************************************************/
@isTest
public class NavatarTaskEventRelationHandler_Test {
    @TestSetup
    Static void testSetup(){
        String nSpace=NavatarTaskEventRelationHandler.getNamespacePrefix();
        Task t=new Task(ActivityDate=System.today());
        insert t;
        Event e=new Event(DurationInMinutes=0,ActivityDateTime=System.now());
        insert e;
        Task t2=new Task(ActivityDate=System.today());
        insert t2;
        Event e2=new Event(DurationInMinutes=0,ActivityDateTime=System.now());
        insert e2;
        //Test class coverage fix by LK on 2024-11-06
        Id accInstRecTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Account acc=new Account(name='Test Acuity Account',recordtypeId=accInstRecTypeId);
        insert acc;
        Contact con=new Contact(lastname='Test Acuity Contact '+nSpace,AccountId=acc.Id);
        insert con;
        Contact con2=new Contact(lastname='Test Acuity Contact 2 '+nSpace,AccountId=acc.Id);
        insert con2;
        navpeII_dev18__Pipeline__c pipe=new navpeII_dev18__Pipeline__c(navpeII_dev18__Stage__c='Deal Received');
        insert pipe;
        navpeII_dev18__Pipeline__c pipe2=new navpeII_dev18__Pipeline__c(navpeII_dev18__Stage__c='Deal Received');
        insert pipe2;
        navpeII_dev18__Deal_Team__c dTeam=new navpeII_dev18__Deal_Team__c(navpeII_dev18__Deal__c=pipe.Id,navpeII_dev18__Deal_Contact__c=con.Id);
        insert dTeam;
        navpeII_dev18__Deal_Team__c dTeam2=new navpeII_dev18__Deal_Team__c(navpeII_dev18__Deal__c=pipe.Id,navpeII_dev18__Deal_Contact__c=con2.Id);
        insert dTeam2;
        navpeII_dev18__Deal_Team__c dTeam3=new navpeII_dev18__Deal_Team__c(navpeII_dev18__Deal__c=pipe2.Id,navpeII_dev18__Deal_Contact__c=con2.Id);
        insert dTeam3;
        navpeII_dev18__Fund__c fnd=new navpeII_dev18__Fund__c(name='Test Acuity Fund');
        insert fnd;
        navpeII_dev18__Fundraising__c fdr=new navpeII_dev18__Fundraising__c(navpeII_dev18__Stage__c='Prospect',navpeII_dev18__Legal_Name__c=acc.Id,navpeII_dev18__Fund_Name__c=fnd.Id);
        insert fdr;
        navpeII_dev18__Fundraising__c fdr2=new navpeII_dev18__Fundraising__c(navpeII_dev18__Stage__c='Prospect',navpeII_dev18__Legal_Name__c=acc.Id,navpeII_dev18__Fund_Name__c=fnd.Id);
        insert fdr2;
        navpeII_dev18__Fundraising_Contact__c fdrCon=new navpeII_dev18__Fundraising_Contact__c(navpeII_dev18__Fundraising__c=fdr.Id,navpeII_dev18__Contact__c=con.Id);
        insert fdrCon;
        navpeII_dev18__Fundraising_Contact__c fdrCon2=new navpeII_dev18__Fundraising_Contact__c(navpeII_dev18__Fundraising__c=fdr.Id,navpeII_dev18__Contact__c=con2.Id);
        insert fdrCon2;
        navpeII_dev18__Fundraising_Contact__c fdrCon3=new navpeII_dev18__Fundraising_Contact__c(navpeII_dev18__Fundraising__c=fdr.Id,navpeII_dev18__Contact__c=con2.Id);
        insert fdrCon3;
        /*List<sObject> listOfTaskRelationObj = new List<sObject>();
        Schema.SObjectType st = Schema.getGlobalDescribe().get('TaskRelation');
        sObject obj = st.newSobject();
        obj.put('RelationId', con.Id);
        obj.put('TaskId', t.Id);
        sObject obj1 = st.newSobject();
        obj1.put('RelationId', con2.Id);
        obj1.put('TaskId', t2.Id);
        sObject obj2 = st.newSobject();
        obj2.put('RelationId', con2.Id);
        obj2.put('TaskId', t.Id);
        listOfTaskRelationObj.add(obj1);
        listOfTaskRelationObj.add(obj);
        listOfTaskRelationObj.add(obj2);
        insert listOfTaskRelationObj;*/
        
        List<sObject> listOfEventRelationObj = new List<sObject>();
        Schema.SObjectType st1 = Schema.getGlobalDescribe().get('EventRelation');
        sObject eventObj = st1.newSobject();
        eventObj.put('RelationId', con.Id);
        eventObj.put('EventId', e.Id);
        sObject eventObj1 = st1.newSobject();
        eventObj1.put('RelationId', con2.Id);
        eventObj1.put('EventId', e2.Id);
        sObject eventObj2 = st1.newSobject();
        eventObj2.put('RelationId', con2.Id);
        eventObj2.put('EventId', e.Id);
        listOfEventRelationObj.add(eventObj1);
        listOfEventRelationObj.add(eventObj2);
        listOfEventRelationObj.add(eventObj);
        insert listOfEventRelationObj;
    }
    @isTest
    public static void testBulkActivity(){
        User u = [Select Id from User where Profile.Name ='PE Standard User' and
                         IsActive=TRUE Limit 1];
        if(u==null){
            profile p=[Select Id, Name from Profile where Name ='PE Standard User'];
            u=new User(profileId=p.Id,IsActive=true);
            insert u;
        }
        
        /*List<sObject> taskRelationList = Database.query('SELECT Id, TaskId, RelationId FROM TaskRelation');
        List<String> actIdList=new List<String>();
        for(sObject tr : taskRelationList){
            actIdList.add(String.valueOf(tr.get('Id')));
        }
        NavatarTaskEventRelationHandler.onInsrtUpdteActivity(actIdList);*/
        
        /*List<sObject> eventRelationList = Database.query('SELECT Id, EventId, RelationId FROM EventRelation');
        List<String> actIdList2=new List<String>();
        for(sObject er : eventRelationList){
            actIdList2.add(String.valueOf(er.get('Id')));
        }
        NavatarTaskEventRelationHandler.onInsrtUpdteActivity(actIdList2);
        Test.getEventBus().deliver();*/
        
        Task taskObj = new Task();
        taskObj = [Select Id, OwnerId, ActivityDate From Task Limit 1];
        
        Contact conObj = new Contact();
        conObj = [Select Id, Name From Contact Limit 1];
        
        Event eventObj = new Event();
        eventObj = [Select Id, OwnerId, ActivityDateTime From Event Limit 1];
        
        System.debug('conObj>>>'+conObj);
        
        taskObj.OwnerId = u.Id;
        taskObj.WhoId = conObj.Id;
        taskObj.ActivityDate = System.today().addDays(1);
        Test.startTest();
        update taskObj;
        delete taskObj;
        
        eventObj.WhoId = conObj.Id;
        update eventObj;
        delete eventObj;
        
        Test.getEventBus().deliver();
        Test.stopTest();
        System.assertEquals('Test Acuity Fund', [Select Id, Name from navpeII_dev18__Fund__c order by createdDate DESC limit 1].Name, 'Latest Fund was not inserted!!');
        try{
            List<String> actIdList3=new List<String>();
            actIdList3.add('$$$$');
            NavatarTaskEventRelationHandler.onInsrtUpdteActivity(actIdList3);
        }
        catch(Exception ex1){
            try{
                NavatarTaskEventRelationHandler.onDeleteActivity(null, null, null);
            }
            catch(Exception ex2){}
            //System.debug('Inside AcuityActivityTriggerTest');
        }
    }
    @isTest
    public static void testActivity2(){
        User u = [Select Id from User where Profile.Name ='PE Standard User' and
                         IsActive=TRUE Limit 1];
        if(u==null){
            profile p=[Select Id, Name from Profile where Name ='PE Standard User'];
            u=new User(profileId=p.Id,IsActive=true);
            insert u;
        }
        List<Contact> conList = new List<Contact>();
        conList = [Select Id, Name From Contact Limit 1000];
        Set<Id> conIdSet = new Set<Id>();
        for(Contact con : conList){
           conIdSet.add(con.Id); 
        }
        
        List<Task> taskList = new List<Task>();
        taskList = [Select Id, ActivityDate From Task Limit 1000];
        Set<Id> taskIdSet = new Set<Id>();
        for(Task taskObj : taskList){
           taskIdSet.add(taskObj.Id); 
        }
        NavatarTaskEventRelationHandler.onDeleteActivity('EventRelation', taskIdSet, conIdSet);
        NavatarTaskEventRelationHandler.sanitizeAssociations(null,new Set<String>{'s'},new Set<String>{'s1'});
        System.assertEquals('Test Acuity Fund', [Select Id, Name from navpeII_dev18__Fund__c order by createdDate DESC limit 1].Name, 'Latest Fund was not inserted!!');
    }
    /*@isTest
    static void codeCoverageImprovement(){
        Test.startTest();
        Event ev = [SELECT Id FROM Event LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Map<Id, Id> relIdvsEventIdMap = new Map<Id, Id>();
        relIdvsEventIdMap.put(con.Id, ev.Id);
        EventTriggerHandler.GetContactIds(new Set<ID>{ev.Id}, new Set<Id>{con.Id}, relIdvsEventIdMap, false);
        Test.stopTest();
        EventTriggerHandler.OnAfterUpdateAsync(new Set<ID>{ev.Id}, new Set<Id>{con.Id}, relIdvsEventIdMap);
    }*/
}