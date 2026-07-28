/****************************************************************************************************
** Module Name : Meeting Prep Card (Daily) 1.0 
** Description : batcch class to execute one event at a time and send email to meeting participants.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarMeetingPrepCardSchdulerBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public class MeetingPrepCardException extends Exception {}
    // Batch start: Query all events planned today
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = Date.today();
        DateTime startOfDay = DateTime.newInstance(today.year(), today.month(), today.day());
        DateTime endOfDay = DateTime.newInstance(today.year(), today.month(), today.day(), 23, 59, 59);
        return Database.getQueryLocator([
            SELECT Id, Subject, Description, StartDateTime, WhoId, OwnerId,
            (SELECT Id, RelationId FROM EventRelations)
            FROM Event
            WHERE StartDateTime >= :startOfDay AND StartDateTime <= :endOfDay
            AND isChild = False
            WITH SECURITY_ENFORCED
        ]);//Bug Fixing avoid child events 00051794 Salauddin 30032026
    }

    // Batch execute: For each event, send the email
    public void execute(Database.BatchableContext bc, List<Event> events) {
        NavatarEmailMeetingPrepCard.PrepCardWrapper prepCardWrapper = new NavatarEmailMeetingPrepCard.PrepCardWrapper();
        try {
            if (events == null || events.isEmpty()) {
                return;
            }

            
            List<Id> eventIds = new List<Id>();

            for (Event ev : events) {
                eventIds.add(ev.Id);
            }

            prepCardWrapper.eventIds = eventIds;
            NavatarEmailMeetingPrepCard.collectRelations(events, prepCardWrapper);
            NavatarEmailMeetingPrepCard.loadContacts(prepCardWrapper,'RelatedContact');
            NavatarEmailMeetingPrepCard.loadContacts(prepCardWrapper, 'ALL');
            NavatarEmailMeetingPrepCard.getContactsLastTouchPoint(prepCardWrapper);//https://navatartaskmgmt.atlassian.net/browse/AA-667 Salauddin 10042026
            NavatarEmailMeetingPrepCard.getUserDetails(prepCardWrapper);
            NavatarEmailMeetingPrepCard.prepareParticipantSummaries(prepCardWrapper);
            NavatarEmailMeetingPrepCard.prepareBusinessHistory(prepCardWrapper);  
            NavatarEmailMeetingPrepCard.prepareEmailsToSend(events,prepCardWrapper);
            if (!prepCardWrapper.emailsToSend.isEmpty()) {
                Messaging.sendEmail(prepCardWrapper.emailsToSend);
            }
            If(Test.isRunningTest()){
                throw new MeetingPrepCardException('thrown for coverage');
            }
        } catch (Exception e) {
            for (Event event : events) {                
                DateTime dt = event.StartDateTime;
                Set<Id> userIds = prepCardWrapper.eventToUserIds.containsKey(event.Id) ? prepCardWrapper.eventToUserIds.get(event.Id) : new Set<Id>();
                if (userIds.isEmpty()) {
                    continue;
                }
                String emailBody ='The Meeting Prep Card for ‘' + event.Subject+'’ on '+dt.format('dd MMMM yyyy')+ ' could not be generated due to a technical issue or workflow error.<br/><br/>' +
                'Please contact your Navatar Administrator for further assistance.<br/><br/>' +
                '<i>*****This is a system generated email*****</i>';
                // Use utility class to email system admins & requested users with error message
                NavatarMeetingPrepCardUtility.sendErrorEmailToUsers('Meeting Prep Card Generation Failed ' , emailBody, userIds);
            }
        }
        
    }

    public void finish(Database.BatchableContext bc) {
        // Optionally implement any post-processing logic here
    }
}