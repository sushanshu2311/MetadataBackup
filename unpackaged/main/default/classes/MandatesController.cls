/**
 * MandatesController
 * ------------------------------------------------------------------
 * Backend for the live, inline-editable Mandates grid (mandatesLive LWC).
 *
 * Columns are NOT hardcoded — they are read from the Mandate_Column__mdt
 * custom metadata type, which drives:
 *   - which navmnaI__Deal__c fields are queried and displayed,
 *   - their labels / order / alignment / type,
 *   - whether each is inline-editable (further gated by the running
 *     user's field-level security).
 *
 * Rows are real navmnaI__Deal__c records whose Stage is one of the four
 * mandate groups (Mandated / Execution / Invoicing / Completed).
 */
public with sharing class MandatesController {

    // The deal/mandate object differs by managed package (M&A vs PE) — auto-detect
    // so one codebase serves both orgs. The Stage field mirrors the namespace.
    private static final String DEAL = resolveDealObject();
    private static final String STAGE_FIELD = DEAL.substringBefore('__') + '__Stage__c';

    // Stage picklist values that make up the board, in display order — per object.
    private static final List<String> GROUP_ORDER = resolveGroups();

    private static String resolveDealObject() {
        Map<String, Schema.SObjectType> g = Schema.getGlobalDescribe();
        if (g.containsKey('navmnaI__Deal__c')) return 'navmnaI__Deal__c';
        if (g.containsKey('navpeII__Pipeline__c')) return 'navpeII__Pipeline__c';
        return 'navmnaI__Deal__c';
    }

    private static List<String> resolveGroups() {
        if (DEAL == 'navpeII__Pipeline__c') {
            return new List<String>{
                'Deal Received', 'NDA Signed', 'Management Meeting', 'IOI', 'LOI', 'Due Diligence', 'Closed'
            };
        }
        return new List<String>{ 'Mandated', 'Execution', 'Invoicing', 'Completed' };
    }

    /* ─────────────────────────────  DTOs  ───────────────────────────── */

    public class Option {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public Option(String l, String v) { label = l; value = v; }
    }

    public class ColumnDef implements Comparable {
        public Decimal sortOrder;                   // used only for ordering
        @AuraEnabled public String name;            // CMDT DeveloperName (stable key)
        @AuraEnabled public String fieldApiName;    // read/display path (may be a __r.Name path)
        @AuraEnabled public String writeField;      // field written on update
        @AuraEnabled public String label;
        @AuraEnabled public String type;            // text|textarea|currency|number|percent|date|picklist|multipicklist|reference|boolean
        @AuraEnabled public Boolean editable;       // CMDT flag AND user FLS updateable
        @AuraEnabled public Boolean isLink;
        @AuraEnabled public String align;
        @AuraEnabled public List<Option> options;   // picklist / multipicklist
        @AuraEnabled public String referenceObject; // reference: target sObject api name

        public Integer compareTo(Object other) {
            Decimal a = sortOrder == null ? 999999 : sortOrder;
            Decimal b = ((ColumnDef) other).sortOrder == null ? 999999 : ((ColumnDef) other).sortOrder;
            return a == b ? 0 : (a > b ? 1 : -1);
        }
    }

    public class Cell {
        @AuraEnabled public String key;             // column DeveloperName
        @AuraEnabled public Object value;           // raw value (edit source; JS formats numerics/dates)
        @AuraEnabled public String display;         // server display override (reference name); null otherwise
    }

    public class Row {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String stage;
        @AuraEnabled public String url;
        @AuraEnabled public List<Cell> cells;
    }

    public class MandateData {
        @AuraEnabled public List<ColumnDef> columns;
        @AuraEnabled public List<Row> rows;
        @AuraEnabled public List<String> groupOrder;
    }

    /* ─────────────────────────  Read: columns + rows  ───────────────── */

    @AuraEnabled(cacheable=true)
    public static MandateData getMandateData() {
        Map<String, Schema.SObjectField> fieldMap =
            Schema.getGlobalDescribe().get(DEAL).getDescribe().fields.getMap();

        List<ColumnDef> columns = buildColumns(fieldMap);

        // Assemble the query field set: keys + the display path of every column,
        // plus each reference column's raw Id field (for the editor).
        Set<String> queryFields = new Set<String>{ 'Id', 'Name', STAGE_FIELD };
        for (ColumnDef c : columns) {
            queryFields.add(c.fieldApiName);
            if (c.writeField != c.fieldApiName) {
                queryFields.add(c.writeField);
            }
        }

        String soql = 'SELECT ' + String.join(new List<String>(queryFields), ', ') +
                      ' FROM ' + DEAL +
                      ' WHERE ' + STAGE_FIELD + ' IN :stages ORDER BY Name';
        List<String> stages = GROUP_ORDER;
        List<SObject> records = Database.query(soql);
        // Enforce read FLS; inaccessible fields are blanked rather than throwing.
        records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();

        List<Row> rows = new List<Row>();
        for (SObject rec : records) {
            Row r = new Row();
            r.id = (Id) rec.get('Id');
            r.name = (String) rec.get('Name');
            r.stage = (String) rec.get(STAGE_FIELD);
            r.url = '/' + r.id;
            r.cells = new List<Cell>();
            for (ColumnDef c : columns) {
                Cell cell = new Cell();
                cell.key = c.name;
                if (c.type == 'reference') {
                    cell.value = c.writeField == c.fieldApiName ? null : rec.get(c.writeField);
                    cell.display = (String) getPathValue(rec, c.fieldApiName);
                } else {
                    cell.value = getPathValue(rec, c.fieldApiName);
                }
                r.cells.add(cell);
            }
            rows.add(r);
        }

        MandateData data = new MandateData();
        data.columns = columns;
        data.rows = rows;
        data.groupOrder = GROUP_ORDER;
        return data;
    }

    /**
     * Build the column model from Mandate_Column__mdt. Each record supplies only
     * the field API name, its order, and an optional label override — EVERYTHING
     * else (type, editability, alignment, lookup handling, picklist options, the
     * record-link column) is derived at runtime from the field describe.
     *
     * For a lookup, the record stores the raw field (e.g. navmnaI__Account__c /
     * OwnerId); this method resolves the relationship's Name for display and
     * writes the Id on edit.
     */
    private static List<ColumnDef> buildColumns(Map<String, Schema.SObjectField> fieldMap) {
        List<Mandate_Column__mdt> defs = [
            SELECT Field_API_Name__c, Column_Label__c, Sort_Order__c
            FROM Mandate_Column__mdt
        ];

        List<ColumnDef> columns = new List<ColumnDef>();
        for (Mandate_Column__mdt d : defs) {
            String raw = (d.Field_API_Name__c == null) ? '' : d.Field_API_Name__c.trim();
            Schema.SObjectField token = fieldMap.get(raw.toLowerCase());
            if (token == null) continue; // field not found — skip rather than break the grid
            Schema.DescribeFieldResult dfr = token.getDescribe();

            ColumnDef c = new ColumnDef();
            c.sortOrder = d.Sort_Order__c;
            c.name = raw.replace('.', '_'); // stable JS key
            c.writeField = raw;
            c.label = String.isBlank(d.Column_Label__c) ? dfr.getLabel() : d.Column_Label__c;
            c.editable = dfr.isUpdateable();
            c.isLink = raw.equalsIgnoreCase('Name');
            c.type = mapType(dfr.getType());

            if (c.type == 'reference') {
                c.fieldApiName = dfr.getRelationshipName() + '.Name'; // display path
                for (Schema.SObjectType t : dfr.getReferenceTo()) {
                    String n = t.getDescribe().getName();
                    if (c.referenceObject == null) c.referenceObject = n;
                    if (n == 'User') { c.referenceObject = 'User'; break; }
                }
            } else {
                c.fieldApiName = raw;
                if (c.type == 'picklist' || c.type == 'multipicklist') {
                    c.options = new List<Option>();
                    for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
                        if (pe.isActive()) c.options.add(new Option(pe.getLabel(), pe.getValue()));
                    }
                }
            }
            c.align = (c.type == 'currency' || c.type == 'number' || c.type == 'percent')
                ? 'right' : 'left';
            columns.add(c);
        }
        columns.sort();
        return columns;
    }

    private static String mapType(Schema.DisplayType t) {
        switch on t {
            when REFERENCE { return 'reference'; }
            when CURRENCY { return 'currency'; }
            when DOUBLE, INTEGER, LONG { return 'number'; }
            when PERCENT { return 'percent'; }
            when DATE { return 'date'; }
            when DATETIME { return 'datetime'; }
            when PICKLIST { return 'picklist'; }
            when MULTIPICKLIST { return 'multipicklist'; }
            when TEXTAREA { return 'textarea'; }
            when BOOLEAN { return 'boolean'; }
            when else { return 'text'; }
        }
    }

    /* ─────────────────────────────  Update  ─────────────────────────── */

    /**
     * Persist inline edits. `changes` is a JSON list of
     *   { "id": "<recordId>", "fields": { "<writeField>": <value>, ... } }
     * Only fields declared editable in Mandate_Column__mdt are honoured;
     * writes are further gated by FLS via stripInaccessible.
     */
    @AuraEnabled
    public static void updateMandates(String changes) {
        if (String.isBlank(changes)) return;
        List<Object> edits = (List<Object>) JSON.deserializeUntyped(changes);
        if (edits == null || edits.isEmpty()) return;

        // Whitelist of allowed write fields + their type, from the CMDT.
        Map<String, Schema.SObjectField> fieldMap =
            Schema.getGlobalDescribe().get(DEAL).getDescribe().fields.getMap();
        Map<String, String> allowed = new Map<String, String>(); // lower(writeField) -> type
        Map<String, String> refObj = new Map<String, String>();  // lower(writeField) -> reference target
        for (ColumnDef c : buildColumns(fieldMap)) {
            if (!c.editable) continue;
            allowed.put(c.writeField.toLowerCase(), c.type);
            if (c.type == 'reference') refObj.put(c.writeField.toLowerCase(), c.referenceObject);
        }

        List<SObject> toUpdate = new List<SObject>();
        for (Object o : edits) {
            Map<String, Object> row = (Map<String, Object>) o;
            Object recId = row.get('id');
            Object fieldsObj = row.get('fields');
            if (recId == null || fieldsObj == null) continue;
            Map<String, Object> fields = (Map<String, Object>) fieldsObj;
            SObject rec = Schema.getGlobalDescribe().get(DEAL).newSObject((Id) String.valueOf(recId));
            Boolean touched = false;
            for (String f : fields.keySet()) {
                String type = allowed.get(f.toLowerCase());
                if (type == null) continue; // not an editable column — ignore
                Object val;
                if (type == 'reference') {
                    val = resolveReference(fields.get(f), refObj.get(f.toLowerCase()));
                    if (val == null && fields.get(f) != null) continue; // name didn't resolve — skip
                } else {
                    val = coerce(fields.get(f), type);
                }
                rec.put(properCase(fieldMap, f), val);
                touched = true;
            }
            if (touched) toUpdate.add(rec);
        }
        if (toUpdate.isEmpty()) return;

        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.UPDATABLE, toUpdate);
        update dec.getRecords();
    }

    /* ─────────────────────────  Lookup search  ──────────────────────── */

    @AuraEnabled
    public static List<Option> searchLookup(String objectApiName, String term) {
        List<Option> out = new List<Option>();
        if (String.isBlank(objectApiName)) return out;
        String searchTerm = '%' + String.escapeSingleQuotes(term == null ? '' : term) + '%';
        String q = 'SELECT Id, Name FROM ' + String.escapeSingleQuotes(objectApiName) +
                   ' WHERE Name LIKE :searchTerm ORDER BY Name LIMIT 10';
        for (SObject s : Database.query(q)) {
            out.add(new Option((String) s.get('Name'), (String) s.get('Id')));
        }
        return out;
    }

    /* ─────────────────────────────  Helpers  ────────────────────────── */

    // Traverse a (possibly relationship) field path, e.g. navmnaI__Account__r.Name.
    private static Object getPathValue(SObject rec, String path) {
        if (rec == null) return null;
        if (!path.contains('.')) return rec.get(path);
        List<String> parts = path.split('\\.');
        SObject cursor = rec;
        for (Integer i = 0; i < parts.size() - 1; i++) {
            if (cursor == null) return null;
            cursor = cursor.getSObject(parts[i]);
        }
        return cursor == null ? null : cursor.get(parts[parts.size() - 1]);
    }

    // Resolve the correctly-cased API name (put() is case-sensitive on some fields).
    private static String properCase(Map<String, Schema.SObjectField> fieldMap, String f) {
        Schema.SObjectField t = fieldMap.get(f.toLowerCase());
        return t == null ? f : t.getDescribe().getName();
    }

    // Resolve a reference cell's typed value: a real Id passes through; anything
    // else is treated as a record Name and looked up on the target object.
    private static Id resolveReference(Object v, String objApiName) {
        if (v == null) return null;
        String s = String.valueOf(v).trim();
        if (String.isBlank(s)) return null;
        try {
            Id direct = (Id) s;      // already an Id?
            return direct;
        } catch (Exception ignored) {
            // fall through to name lookup
        }
        if (String.isBlank(objApiName)) return null;
        String q = 'SELECT Id FROM ' + String.escapeSingleQuotes(objApiName) +
                   ' WHERE Name = :s LIMIT 1';
        List<SObject> hits = Database.query(q);
        return hits.isEmpty() ? null : (Id) hits[0].get('Id');
    }

    // Coerce a JSON value into the type the field expects.
    private static Object coerce(Object v, String type) {
        if (v == null) return null;
        String s = String.valueOf(v);
        if (String.isBlank(s)) return null;
        switch on type {
            when 'currency', 'number', 'percent' { return Decimal.valueOf(s); }
            when 'date' { return Date.valueOf(s); }
            when else { return s; }
        }
    }

}