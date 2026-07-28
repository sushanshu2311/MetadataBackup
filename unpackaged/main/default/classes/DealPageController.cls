public with sharing class DealPageController {

    // ── Activity Feed ─────────────────────────────────────────────────────────

    @AuraEnabled(cacheable=true)
    public static List<FeedItemWrapper> getActivityFeed(Id recordId) {
        List<FeedItemWrapper> feed = new List<FeedItemWrapper>();

        // VINTON — meeting clips via Clip_Relation junction
        for (navpeII__Clip_Relation__c cr : [
            SELECT navpeII__Clip__c,
                   navpeII__Clip__r.Name,
                   navpeII__Clip__r.navpeII__Summary__c,
                   navpeII__Clip__r.navpeII__Notes__c,
                   navpeII__Clip__r.CreatedDate,
                   navpeII__Clip__r.Owner.Name
            FROM navpeII__Clip_Relation__c
            WHERE navpeII__Deal__c = :recordId
              AND navpeII__Clip__c != null
            ORDER BY navpeII__Clip__r.CreatedDate DESC
            LIMIT 20
        ]) {
            String preview = cr.navpeII__Clip__r.navpeII__Summary__c;
            if (String.isBlank(preview)) {
                String notes = cr.navpeII__Clip__r.navpeII__Notes__c;
                preview = String.isBlank(notes) ? null : notes.abbreviate(200);
            }
            feed.add(new FeedItemWrapper(
                String.valueOf(cr.navpeII__Clip__c),
                cr.navpeII__Clip__r.Name,
                preview,
                'interaction', 'VINTON',
                cr.navpeII__Clip__r.CreatedDate,
                cr.navpeII__Clip__r.Owner.Name
            ));
        }

        // DEAL EVENTS — stage change log
        for (navpeII__Pipeline_Stage_Log__c log : [
            SELECT Id, navpeII__Changed_Stage__c, navpeII__Date_Stage_Set__c,
                   CreatedDate, Owner.Name
            FROM navpeII__Pipeline_Stage_Log__c
            WHERE navpeII__Pipeline__c = :recordId
            ORDER BY CreatedDate DESC
            LIMIT 20
        ]) {
            String stage = String.isBlank(log.navpeII__Changed_Stage__c)
                ? 'Stage updated' : log.navpeII__Changed_Stage__c;
            feed.add(new FeedItemWrapper(
                String.valueOf(log.Id),
                'Stage changed to ' + stage,
                log.navpeII__Date_Stage_Set__c != null
                    ? 'Stage set on ' + String.valueOf(log.navpeII__Date_Stage_Set__c) : null,
                'deal', 'DEAL EVENT',
                log.CreatedDate,
                log.Owner.Name
            ));
        }

        // TASKS — logged activities / manual deal events
        for (Task t : [
            SELECT Id, Subject, Description, CreatedDate, Owner.Name, Type
            FROM Task
            WHERE WhatId = :recordId
            ORDER BY CreatedDate DESC
            LIMIT 30
        ]) {
            String badge = 'TASK';
            String fType = 'deal';
            if (t.Type == 'Call')  { badge = 'CALL';  fType = 'interaction'; }
            if (t.Type == 'Email') { badge = 'EMAIL'; fType = 'interaction'; }
            feed.add(new FeedItemWrapper(
                String.valueOf(t.Id), t.Subject,
                t.Description != null ? t.Description.abbreviate(200) : null,
                fType, badge, t.CreatedDate, t.Owner.Name
            ));
        }

        // EVENTS — calendar meetings
        for (Event e : [
            SELECT Id, Subject, Description, ActivityDateTime, Owner.Name, Type
            FROM Event
            WHERE WhatId = :recordId
            ORDER BY ActivityDateTime DESC
            LIMIT 20
        ]) {
            feed.add(new FeedItemWrapper(
                String.valueOf(e.Id), e.Subject,
                e.Description != null ? e.Description.abbreviate(200) : null,
                'interaction', 'MEETING',
                e.ActivityDateTime, e.Owner.Name
            ));
        }

        // DOCUMENTS — attached files
        for (ContentDocumentLink cdl : [
            SELECT ContentDocument.Id, ContentDocument.Title,
                   ContentDocument.FileType,
                   ContentDocument.LastModifiedDate,
                   ContentDocument.LastModifiedBy.Name
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            ORDER BY ContentDocument.LastModifiedDate DESC
            LIMIT 20
        ]) {
            feed.add(new FeedItemWrapper(
                String.valueOf(cdl.ContentDocument.Id),
                cdl.ContentDocument.Title,
                cdl.ContentDocument.FileType + ' · attached document',
                'document', 'DOCUMENT',
                cdl.ContentDocument.LastModifiedDate,
                cdl.ContentDocument.LastModifiedBy.Name
            ));
        }

        feed.sort();
        return feed;
    }

    // ── Action Items ─────────────────────────────────────────────────────────

    @AuraEnabled(cacheable=true)
    public static List<ActionItemWrapper> getActionItems(Id recordId, Boolean mineOnly) {
        Id userId = UserInfo.getUserId();
        List<Task> tasks = mineOnly
            ? [SELECT Id, Subject, Status, ActivityDate, Owner.Name, IsClosed, Priority
               FROM Task
               WHERE WhatId = :recordId AND OwnerId = :userId
               ORDER BY IsClosed ASC, ActivityDate ASC NULLS LAST
               LIMIT 50]
            : [SELECT Id, Subject, Status, ActivityDate, Owner.Name, IsClosed, Priority
               FROM Task
               WHERE WhatId = :recordId
               ORDER BY IsClosed ASC, ActivityDate ASC NULLS LAST
               LIMIT 50];

        List<ActionItemWrapper> result = new List<ActionItemWrapper>();
        for (Task t : tasks) {
            ActionItemWrapper w = new ActionItemWrapper();
            w.id          = t.Id;
            w.subject     = t.Subject;
            w.status      = t.Status;
            w.dueDate     = t.ActivityDate != null ? String.valueOf(t.ActivityDate) : null;
            w.ownerName   = t.Owner.Name;
            w.ownerInitials = getInitials(t.Owner.Name);
            w.isCompleted = t.IsClosed;
            w.isOverdue   = !t.IsClosed && t.ActivityDate != null
                            && t.ActivityDate < Date.today();
            result.add(w);
        }
        return result;
    }

    @AuraEnabled
    public static void toggleTaskComplete(Id taskId, Boolean complete) {
        Task t = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
        t.Status = complete ? 'Completed' : 'In Progress';
        update t;
    }

    // ── Deal Experts ──────────────────────────────────────────────────────────

    @AuraEnabled(cacheable=true)
    public static List<ExpertWrapper> getDealExperts(Id recordId) {
        List<ExpertWrapper> result = new List<ExpertWrapper>();
        for (navpeII__Deal_Expert__c e : [
            SELECT Id,
                   navpeII__Deal_Expert__r.Name,
                   navpeII__Deal_Expert__r.Title,
                   navpeII__Status__c,
                   navpeII__Notes__c
            FROM navpeII__Deal_Expert__c
            WHERE navpeII__Deal__c = :recordId
            LIMIT 20
        ]) {
            ExpertWrapper w = new ExpertWrapper();
            w.id       = e.Id;
            w.name     = e.navpeII__Deal_Expert__r != null
                         ? e.navpeII__Deal_Expert__r.Name  : '—';
            w.title    = e.navpeII__Deal_Expert__r != null
                         ? e.navpeII__Deal_Expert__r.Title : '';
            w.status   = e.navpeII__Status__c;
            w.notes    = e.navpeII__Notes__c;
            w.initials = getInitials(w.name);
            result.add(w);
        }
        return result;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static String getInitials(String name) {
        if (String.isBlank(name)) return '?';
        List<String> parts = name.trim().split('\\s+');
        String s = parts[0].left(1).toUpperCase();
        if (parts.size() > 1) s += parts[parts.size()-1].left(1).toUpperCase();
        return s;
    }

    // ── Wrappers ──────────────────────────────────────────────────────────────

    public class ActionItemWrapper {
        @AuraEnabled public Id      id;
        @AuraEnabled public String  subject;
        @AuraEnabled public String  status;
        @AuraEnabled public String  dueDate;
        @AuraEnabled public String  ownerName;
        @AuraEnabled public String  ownerInitials;
        @AuraEnabled public Boolean isCompleted;
        @AuraEnabled public Boolean isOverdue;
    }

    public class ExpertWrapper {
        @AuraEnabled public Id     id;
        @AuraEnabled public String name;
        @AuraEnabled public String title;
        @AuraEnabled public String status;
        @AuraEnabled public String notes;
        @AuraEnabled public String initials;
    }

    private static final Map<String,String> STRIPE_MAP = new Map<String,String>{
        'VINTON'     => '#0B2D5F',
        'DEAL EVENT' => '#0176D3',
        'CALL'       => '#DDDBDA',
        'EMAIL'      => '#DDDBDA',
        'MEETING'    => '#DDDBDA',
        'DOCUMENT'   => '#DDDBDA',
        'TASK'       => '#DDDBDA'
    };

    public class FeedItemWrapper implements Comparable {
        @AuraEnabled public String   id;
        @AuraEnabled public String   title;
        @AuraEnabled public String   preview;
        @AuraEnabled public String   feedType;
        @AuraEnabled public String   filterCat;
        @AuraEnabled public String   badge;
        @AuraEnabled public Datetime timestamp;
        @AuraEnabled public String   timestampLabel;
        @AuraEnabled public String   ownerName;
        @AuraEnabled public String   stripeColor;

        public FeedItemWrapper(String id, String title, String preview,
                               String feedType, String badge,
                               Datetime ts, String ownerName) {
            this.id             = id;
            this.title          = String.isBlank(title) ? '(No subject)' : title;
            this.preview        = preview;
            this.feedType       = feedType;
            this.badge          = badge;
            this.timestamp      = ts;
            this.timestampLabel = ts != null ? ts.format('dd MMM yyyy · HH:mm') : '';
            this.ownerName      = ownerName;
            this.stripeColor    = STRIPE_MAP.containsKey(badge)
                                  ? STRIPE_MAP.get(badge) : '#DDDBDA';
            if ('deal'.equals(feedType) || 'document'.equals(feedType)) {
                this.filterCat = 'intelligence';
            } else if ('EMAIL'.equals(badge) || 'EMAIL SUMMARY'.equals(badge)) {
                this.filterCat = 'email';
            } else {
                this.filterCat = 'meeting';
            }
        }

        public Integer compareTo(Object o) {
            FeedItemWrapper other = (FeedItemWrapper) o;
            if (timestamp == null && other.timestamp == null) return 0;
            if (timestamp == null) return 1;
            if (other.timestamp == null) return -1;
            return timestamp > other.timestamp ? -1 : (timestamp < other.timestamp ? 1 : 0);
        }
    }
}