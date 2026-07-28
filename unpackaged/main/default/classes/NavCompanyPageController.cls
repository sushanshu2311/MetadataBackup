/**
 * Data for the Company record screen (Account) — Overview, Contacts, Deals,
 * Interactions and Documents tabs.
 *
 * Only CRM data lives here. AI-generated sections (Current Summary, Activity
 * Insights / News / Recommendations, Network, Landscape) are supplied by the
 * navDemoData LWC module until generation timing is decided (BRD OI-7).
 */
public with sharing class NavCompanyPageController {

    // Contacts reach a company either directly (AccountId) or through an Affiliation.
    private static final String ROLE_FORMER_EMPLOYEE = 'Former Employee';

    // Deal stage -> All / Active / Closed / Passed bucket (FR-COMP-09).
    private static final Set<String> CLOSED_STAGES = new Set<String>{ 'Closed' };
    private static final Set<String> PASSED_STAGES = new Set<String>{ 'Declined/Dead' };

    // ---------------------------------------------------------------- Overview

    @AuraEnabled(cacheable=true)
    public static CompanyProfile getCompanyProfile(Id recordId) {
        List<Account> rows = [
            SELECT Id, Name, navpeII__Sector__c, navpeII__Industry_Level_2__c,
                   BillingCity, BillingState, BillingCountry,
                   navpeII__LTM_Revenue__c, navpeII__LTM_EBITDA__c,
                   navpeII__Entity_Type__c, NumberOfEmployees, navpeII__Status__c
            FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            return null;
        }
        return new CompanyProfile(rows[0]);
    }

    @AuraEnabled(cacheable=true)
    public static List<TaskItem> getOpenTasks(Id recordId) {
        List<TaskItem> items = new List<TaskItem>();
        for (Task t : [
            SELECT Id, Subject, ActivityDate, OwnerId, Owner.Name, Status, Priority
            FROM Task
            WHERE WhatId = :recordId AND IsClosed = false
            ORDER BY ActivityDate ASC NULLS LAST
            LIMIT 200
        ]) {
            items.add(new TaskItem(t));
        }
        return items;
    }

    // ---------------------------------------------------------------- Contacts

    /**
     * Primary        = contacts at the company
     * Alumni         = affiliations with role Former Employee
     * Extended       = every other affiliation
     * AI Recommended = supplied client-side; not yet in the system
     */
    @AuraEnabled(cacheable=true)
    public static List<ContactRow> getContacts(Id recordId) {
        List<ContactRow> rows = new List<ContactRow>();
        Set<Id> seen = new Set<Id>();

        for (Contact c : [
            SELECT Id, Name, Title, Email, Account.Name, navpeII__Last_Touch_Point__c
            FROM Contact
            WHERE AccountId = :recordId
            WITH SECURITY_ENFORCED
            ORDER BY Name
            LIMIT 500
        ]) {
            rows.add(new ContactRow(c, 'primary', c.Account.Name));
            seen.add(c.Id);
        }

        for (navpeII__Affiliation__c a : [
            SELECT Id, navpeII__Role__c, navpeII__Contact__c, navpeII__Institution__r.Name,
                   navpeII__Contact__r.Name, navpeII__Contact__r.Title,
                   navpeII__Contact__r.Email, navpeII__Contact__r.Account.Name,
                   navpeII__Contact__r.navpeII__Last_Touch_Point__c
            FROM navpeII__Affiliation__c
            WHERE navpeII__Institution__c = :recordId AND navpeII__Contact__c != null
            WITH SECURITY_ENFORCED
            ORDER BY navpeII__Contact__r.Name
            LIMIT 500
        ]) {
            if (seen.contains(a.navpeII__Contact__c)) {
                continue;
            }
            String role = a.navpeII__Role__c == null ? '' : a.navpeII__Role__c;
            String category = role.contains(ROLE_FORMER_EMPLOYEE) ? 'alumni' : 'extended';
            // Sub-line reads "<company> · <role>", the same shape as a primary contact's.
            String company = a.navpeII__Institution__r == null ? null : a.navpeII__Institution__r.Name;
            String org = joinNonBlank(
                new List<String>{ company, role.replace(';', ' · ') }, ' · '
            );
            rows.add(new ContactRow(a.navpeII__Contact__r, category, String.isBlank(org) ? null : org));
            seen.add(a.navpeII__Contact__c);
        }
        return rows;
    }

    @AuraEnabled
    public static ContactRow createContact(Id recordId, String firstName, String lastName,
                                           String title, String email, String category) {
        if (String.isBlank(lastName)) {
            throw new AuraHandledException('Name is required.');
        }
        Contact c = new Contact(
            FirstName = String.isBlank(firstName) ? null : firstName.trim(),
            LastName = lastName.trim(),
            Title = String.isBlank(title) ? null : title.trim(),
            Email = String.isBlank(email) ? null : email.trim()
        );
        // Primary contacts sit on the company; everyone else reaches it via an affiliation.
        if (category == 'primary') {
            c.AccountId = recordId;
        }
        insert c;

        if (category != 'primary') {
            insert new navpeII__Affiliation__c(
                navpeII__Contact__c = c.Id,
                navpeII__Institution__c = recordId,
                navpeII__Role__c = category == 'alumni' ? ROLE_FORMER_EMPLOYEE : 'Consultant'
            );
        }

        Contact fresh = [
            SELECT Id, Name, Title, Email, Account.Name, navpeII__Last_Touch_Point__c
            FROM Contact WHERE Id = :c.Id LIMIT 1
        ];
        return new ContactRow(fresh, category, category == 'primary' ? fresh.Account.Name : null);
    }

    /** Removes the contact's link to this company, or the contact itself when it lives here. */
    @AuraEnabled
    public static void removeContact(Id recordId, Id contactId) {
        List<navpeII__Affiliation__c> links = [
            SELECT Id FROM navpeII__Affiliation__c
            WHERE navpeII__Institution__c = :recordId AND navpeII__Contact__c = :contactId
        ];
        if (!links.isEmpty()) {
            delete links;
            return;
        }
        List<Contact> owned = [SELECT Id FROM Contact WHERE Id = :contactId AND AccountId = :recordId];
        if (!owned.isEmpty()) {
            delete owned;
        }
    }

    // ------------------------------------------------------------------- Deals

    @AuraEnabled(cacheable=true)
    public static List<DealRow> getDeals(Id recordId) {
        List<DealRow> rows = new List<DealRow>();
        for (navpeII__Pipeline__c p : [
            SELECT Id, Name, navpeII__Deal_Type__c, navpeII__Stage__c,
                   navpeII__Enterprise_Value__c, navpeII__Log_In_Date__c, Owner.Name,
                   navpeII__Source_Company__c, navpeII__Source_Company__r.Name,
                   navpeII__Source_Contact__c, navpeII__Source_Contact__r.Name
            FROM navpeII__Pipeline__c
            WHERE navpeII__Company__c = :recordId
            WITH SECURITY_ENFORCED
            ORDER BY navpeII__Log_In_Date__c DESC NULLS LAST
            LIMIT 200
        ]) {
            rows.add(new DealRow(p));
        }
        return rows;
    }

    // ------------------------------------------------------------ Interactions

    /** Logged emails, calls and meetings — completed Tasks plus Events. */
    @AuraEnabled(cacheable=true)
    public static List<InteractionRow> getInteractions(Id recordId) {
        List<InteractionRow> rows = new List<InteractionRow>();

        for (Task t : [
            SELECT Id, Subject, ActivityDate, Description, TaskSubtype, WhoId, Who.Name
            FROM Task
            WHERE WhatId = :recordId AND IsClosed = true
            ORDER BY ActivityDate DESC NULLS LAST
            LIMIT 200
        ]) {
            rows.add(new InteractionRow(t));
        }

        for (Event e : [
            SELECT Id, Subject, ActivityDate, Description, WhoId, Who.Name
            FROM Event
            WHERE WhatId = :recordId
            ORDER BY ActivityDate DESC NULLS LAST
            LIMIT 200
        ]) {
            rows.add(new InteractionRow(e));
        }

        rows.sort();
        return rows;
    }

    // --------------------------------------------------------------- Documents

    @AuraEnabled(cacheable=true)
    public static List<DocumentRow> getDocuments(Id recordId) {
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.Description,
                   ContentDocument.FileExtension, ContentDocument.CreatedDate
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            LIMIT 500
        ];
        if (links.isEmpty()) {
            return new List<DocumentRow>();
        }

        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink l : links) {
            docIds.add(l.ContentDocumentId);
        }

        // A document's deal comes from the same file being linked to a deal on this company.
        Map<Id, String> dealNameByDoc = new Map<Id, String>();
        Map<Id, String> dealNames = new Map<Id, String>();
        for (navpeII__Pipeline__c p : [
            SELECT Id, Name FROM navpeII__Pipeline__c WHERE navpeII__Company__c = :recordId LIMIT 200
        ]) {
            dealNames.put(p.Id, p.Name);
        }
        if (!dealNames.isEmpty()) {
            Set<Id> dealIds = dealNames.keySet();
            for (ContentDocumentLink l : [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :docIds AND LinkedEntityId IN :dealIds
            ]) {
                dealNameByDoc.put(l.ContentDocumentId, dealNames.get(l.LinkedEntityId));
            }
        }

        List<DocumentRow> rows = new List<DocumentRow>();
        for (ContentDocumentLink l : links) {
            rows.add(new DocumentRow(l, dealNameByDoc.get(l.ContentDocumentId)));
        }
        rows.sort();
        return rows;
    }

    // ------------------------------------------------------------------ Wrappers

    public class CompanyProfile {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String name;
        @AuraEnabled public String sector;
        @AuraEnabled public String subsector;
        @AuraEnabled public String geography;
        @AuraEnabled public String hq;
        @AuraEnabled public String revenue;
        @AuraEnabled public String ebitda;
        @AuraEnabled public String ownership;
        @AuraEnabled public String employees;
        @AuraEnabled public String status;

        public CompanyProfile(Account a) {
            recordId = a.Id;
            name = a.Name;
            sector = blankToDash(a.navpeII__Sector__c);
            subsector = blankToDash(a.navpeII__Industry_Level_2__c);
            geography = blankToDash(a.BillingCountry);
            hq = blankToDash(joinNonBlank(new List<String>{ a.BillingCity, a.BillingState }, ', '));
            revenue = millions(a.navpeII__LTM_Revenue__c);
            ebitda = ebitdaWithMargin(a.navpeII__LTM_EBITDA__c, a.navpeII__LTM_Revenue__c);
            ownership = blankToDash(a.navpeII__Entity_Type__c);
            employees = a.NumberOfEmployees == null ? '-' : String.valueOf(a.NumberOfEmployees);
            status = blankToDash(a.navpeII__Status__c);
        }
    }

    public class TaskItem {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String subject;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public String ownerName;
        @AuraEnabled public Boolean isMine;
        @AuraEnabled public Boolean isOverdue;
        @AuraEnabled public String priority;

        public TaskItem(Task t) {
            recordId = t.Id;
            subject = t.Subject;
            dueDate = t.ActivityDate;
            ownerName = t.Owner == null ? null : t.Owner.Name;
            isMine = t.OwnerId == UserInfo.getUserId();
            isOverdue = t.ActivityDate != null && t.ActivityDate < Date.today();
            priority = t.Priority;
        }
    }

    public class ContactRow {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String name;
        @AuraEnabled public String org;
        @AuraEnabled public String role;
        @AuraEnabled public String email;
        @AuraEnabled public Date lastTouchpoint;
        @AuraEnabled public String category;
        @AuraEnabled public Boolean isSuggested;

        public ContactRow(Contact c, String category, String org) {
            this.recordId = c.Id;
            this.name = c.Name;
            this.org = org;
            this.role = blankToDash(c.Title);
            this.email = c.Email;
            this.lastTouchpoint = c.navpeII__Last_Touch_Point__c;
            this.category = category;
            this.isSuggested = false;
        }
    }

    public class DealRow {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String name;
        @AuraEnabled public String dealType;
        @AuraEnabled public String enterpriseValue;
        @AuraEnabled public String stage;
        @AuraEnabled public String dealYear;
        @AuraEnabled public String lead;
        @AuraEnabled public String bucket;
        // Carried so inline entity references in AI text can resolve to real records.
        @AuraEnabled public Id sourceFirmId;
        @AuraEnabled public String sourceFirmName;
        @AuraEnabled public Id sourceContactId;
        @AuraEnabled public String sourceContactName;

        public DealRow(navpeII__Pipeline__c p) {
            recordId = p.Id;
            name = p.Name;
            dealType = blankToDash(p.navpeII__Deal_Type__c);
            enterpriseValue = millions(p.navpeII__Enterprise_Value__c);
            stage = blankToDash(p.navpeII__Stage__c);
            dealYear = p.navpeII__Log_In_Date__c == null ? '-' : String.valueOf(p.navpeII__Log_In_Date__c.year());
            lead = p.Owner == null ? '-' : p.Owner.Name;
            sourceFirmId = p.navpeII__Source_Company__c;
            sourceFirmName = p.navpeII__Source_Company__r == null ? null : p.navpeII__Source_Company__r.Name;
            sourceContactId = p.navpeII__Source_Contact__c;
            sourceContactName = p.navpeII__Source_Contact__r == null ? null : p.navpeII__Source_Contact__r.Name;
            String s = p.navpeII__Stage__c;
            bucket = CLOSED_STAGES.contains(s) ? 'closed' : (PASSED_STAGES.contains(s) ? 'passed' : 'active');
        }
    }

    public class InteractionRow implements Comparable {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String subject;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public String body;
        @AuraEnabled public String snippet;
        @AuraEnabled public String interactionType;
        @AuraEnabled public Id primaryContactId;
        @AuraEnabled public String primaryContactName;

        public InteractionRow(Task t) {
            recordId = t.Id;
            subject = t.Subject;
            activityDate = t.ActivityDate;
            body = t.Description;
            snippet = snip(t.Description);
            interactionType = t.TaskSubtype == 'Email' ? 'email' : (t.TaskSubtype == 'Call' ? 'call' : 'other');
            primaryContactId = t.WhoId;
            primaryContactName = t.Who == null ? null : t.Who.Name;
        }

        public InteractionRow(Event e) {
            recordId = e.Id;
            subject = e.Subject;
            activityDate = e.ActivityDate;
            body = e.Description;
            snippet = snip(e.Description);
            interactionType = 'meeting';
            primaryContactId = e.WhoId;
            primaryContactName = e.Who == null ? null : e.Who.Name;
        }

        public Integer compareTo(Object other) {
            InteractionRow o = (InteractionRow) other;
            if (activityDate == o.activityDate) {
                return 0;
            }
            if (activityDate == null) {
                return 1;
            }
            if (o.activityDate == null) {
                return -1;
            }
            return activityDate > o.activityDate ? -1 : 1;   // newest first
        }
    }

    public class DocumentRow implements Comparable {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String title;
        @AuraEnabled public String source;
        @AuraEnabled public String dealName;
        @AuraEnabled public Datetime uploadedDate;
        @AuraEnabled public String fileExtension;

        public DocumentRow(ContentDocumentLink l, String dealName) {
            recordId = l.ContentDocumentId;
            title = l.ContentDocument.Title;
            // Source tag is stored on the file description: Navatar or SharePoint.
            source = String.isBlank(l.ContentDocument.Description) ? 'Navatar' : l.ContentDocument.Description;
            this.dealName = dealName;
            uploadedDate = l.ContentDocument.CreatedDate;
            fileExtension = l.ContentDocument.FileExtension;
        }

        public Integer compareTo(Object other) {
            DocumentRow o = (DocumentRow) other;
            if (uploadedDate == o.uploadedDate) {
                return 0;
            }
            return uploadedDate > o.uploadedDate ? -1 : 1;
        }
    }

    // ------------------------------------------------------------------ Helpers

    private static String blankToDash(String value) {
        return String.isBlank(value) ? '-' : value;
    }

    private static String joinNonBlank(List<String> parts, String sep) {
        List<String> kept = new List<String>();
        for (String p : parts) {
            if (String.isNotBlank(p)) {
                kept.add(p);
            }
        }
        return String.join(kept, sep);
    }

    /** navpeII financial figures on these objects are held in millions. */
    private static String millions(Decimal value) {
        if (value == null) {
            return '-';
        }
        Decimal rounded = value.setScale(1, System.RoundingMode.HALF_UP);
        String text = rounded.stripTrailingZeros().toPlainString();
        return '$' + text + 'M';
    }

    private static String ebitdaWithMargin(Decimal ebitda, Decimal revenue) {
        String base = millions(ebitda);
        if (ebitda == null || revenue == null || revenue == 0) {
            return base;
        }
        Decimal margin = (ebitda / revenue * 100).setScale(0, System.RoundingMode.HALF_UP);
        return base + ' · ' + margin.toPlainString() + '%';
    }

    private static String snip(String body) {
        if (String.isBlank(body)) {
            return null;
        }
        String flat = body.replaceAll('\\s+', ' ').trim();
        return flat.length() > 140 ? flat.substring(0, 140) + '...' : flat;
    }
}