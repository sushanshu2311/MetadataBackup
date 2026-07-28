import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import NAVATAR_AI_CHANNEL from '@salesforce/messageChannel/NavatarAI__c';
import getMandateData from '@salesforce/apex/MandatesController.getMandateData';
import updateMandates from '@salesforce/apex/MandatesController.updateMandates';
import searchLookup from '@salesforce/apex/MandatesController.searchLookup';

/**
 * mandatesLive
 * Live, inline-editable Mandates board backed by real navmnaI__Deal__c data.
 * Columns are entirely CMDT-driven (Mandate_Column__mdt). Styled to match the
 * reference (reference/Mandates_Overview_v4.html): facet + search filter bar,
 * collapsible stage groups with rich meta, indent guides, record hyperlinks,
 * an always-on Notes column, and inline text/lookup editing.
 */
export default class MandatesLive extends LightningElement {
    @wire(MessageContext) messageContext;

    @track columns = [];
    @track rows = [];
    @track groupOrder = [];

    @track drafts = {};            // { rowId: { colName: { writeField, value, display } } }
    @track closedGroups = {};      // { stage: true }
    @track expandedId = null;

    @track editing = null;         // { rowId, colName }
    @track editValue = null;
    @track lookupResults = [];

    // When true, only the always-on Notes column is editable; every other
    // column is read-only (no click-to-edit / lookup / pencil).
    notesOnlyEdit = false;

    // Filter state
    @track searchTerm = '';
    @track facetSel = {};          // { colName: [values] }
    @track openFacet = null;

    wiredResult;
    error;
    _focused = false;

    @wire(getMandateData)
    wired(result) {
        this.wiredResult = result;
        if (result.data) {
            this.columns = result.data.columns;
            this.rows = result.data.rows;
            this.groupOrder = result.data.groupOrder;
            this.error = undefined;
        } else if (result.error) {
            this.error = this.reduceError(result.error);
        }
    }

    connectedCallback() {
        this.publishAi({ mandatesReset: true });
    }

    renderedCallback() {
        if (!this.editing || this._focused) return;
        const el = this.template.querySelector('.is-editing .cell-input');
        if (el) {
            el.focus();
            el.select();
            this._focused = true;
        }
    }

    /* ─────────────────────────────  Column helpers  ─────────────────── */

    colByName(name) {
        return this.columns.find((c) => c.name === name);
    }

    isCat(col) {
        // "Categorical" text columns render as reference-style links (Sector/Geography).
        return (
            col.type === 'picklist' ||
            col.type === 'multipicklist' ||
            (col.type === 'text' && !col.isLink)
        );
    }

    isNotesCol(col) {
        return (col.label || '').toLowerCase() === 'notes';
    }

    get dealValueCol() {
        return this.columns.find((c) => c.type === 'number') || null;
    }

    get milestoneCol() {
        return this.columns.find((c) => (c.label || '').toLowerCase().indexOf('milestone') > -1) || null;
    }

    /* ─────────────────────────────  Header model  ───────────────────── */

    get headerCols() {
        return this.columns.map((c) => ({
            name: c.name,
            label: c.label,
            thClass: c.align === 'right' ? 'th num' : 'th'
        }));
    }

    get colspan() {
        return this.columns.length + 1;
    }

    get hasDrafts() {
        return Object.keys(this.drafts).length > 0;
    }

    get isEmpty() {
        return !this.error && this.rows.length === 0;
    }

    /* ─────────────────────────────  Filter bar  ─────────────────────── */

    get facets() {
        return this.columns.filter((c) => this.isCat(c)).map((c) => {
            const sel = this.facetSel[c.name] || [];
            const opts = this.facetValues(c).map((v) => ({
                key: c.name + '::' + v,
                value: v,
                selected: sel.includes(v)
            }));
            return {
                colName: c.name,
                label: c.label,
                options: opts,
                pickClass: 'ms-pick' + (this.openFacet === c.name ? ' open' : ''),
                btnClass: 'ms-btn' + (sel.length ? ' has-selection' : ''),
                btnLabel: sel.length ? c.label + ' (' + sel.length + ')' : c.label + ': All'
            };
        });
    }

    facetValues(col) {
        const set = new Set();
        this.rows.forEach((row) => {
            const raw = this.cellRaw(row, col.name);
            if (raw === null || raw === undefined || raw === '') return;
            if (col.type === 'multipicklist') {
                String(raw).split(';').forEach((v) => v && set.add(v.trim()));
            } else {
                set.add(String(raw));
            }
        });
        return Array.from(set).sort();
    }

    cellRaw(row, colName) {
        const cell = row.cells.find((c) => c.key === colName);
        return cell ? cell.value : null;
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
    }

    toggleFacet(event) {
        const colName = event.currentTarget.dataset.col;
        this.openFacet = this.openFacet === colName ? null : colName;
    }

    toggleFacetOption(event) {
        const { col, value } = event.currentTarget.dataset;
        const cur = this.facetSel[col] ? [...this.facetSel[col]] : [];
        const i = cur.indexOf(value);
        if (i > -1) cur.splice(i, 1);
        else cur.push(value);
        this.facetSel = { ...this.facetSel, [col]: cur };
    }

    clearFacet(event) {
        const colName = event.currentTarget.dataset.col;
        this.facetSel = { ...this.facetSel, [colName]: [] };
    }

    /* ─────────────────────────────  Grouped rows  ───────────────────── */

    get filteredRows() {
        const term = this.searchTerm.trim().toLowerCase();
        const facetCols = Object.keys(this.facetSel).filter((k) => (this.facetSel[k] || []).length);
        return this.rows.filter((row) => {
            if (term) {
                const hay =
                    (row.name || '') +
                    ' ' +
                    row.cells.map((c) => (c.display || '') + ' ' + (c.value == null ? '' : c.value)).join(' ');
                if (hay.toLowerCase().indexOf(term) === -1) return false;
            }
            for (const colName of facetCols) {
                const sel = this.facetSel[colName];
                const col = this.colByName(colName);
                const raw = this.cellRaw(row, colName);
                const vals =
                    col.type === 'multipicklist' && raw
                        ? String(raw).split(';').map((v) => v.trim())
                        : [raw === null || raw === undefined ? '' : String(raw)];
                if (!vals.some((v) => sel.includes(v))) return false;
            }
            return true;
        });
    }

    get groups() {
        const all = this.filteredRows;
        return this.groupOrder
            .map((stage) => {
                const groupRows = all.filter((r) => r.stage === stage);
                const collapsed = !!this.closedGroups[stage];
                return {
                    stage,
                    hidden: groupRows.length === 0,
                    headerClass: collapsed ? 'grp-row grp-closed' : 'grp-row',
                    meta: this.groupMeta(groupRows),
                    rows: collapsed ? [] : groupRows.map((r) => this.mapRow(r))
                };
            })
            .filter((g) => !g.hidden);
    }

    groupMeta(groupRows) {
        const n = groupRows.length;
        let meta = n + (n === 1 ? ' mandate' : ' mandates');
        const dv = this.dealValueCol;
        if (dv) {
            let sum = 0;
            groupRows.forEach((r) => {
                const v = Number(this.cellRaw(r, dv.name));
                if (!isNaN(v)) sum += v;
            });
            if (sum > 0) meta += ' · $' + sum.toLocaleString('en-US', { maximumFractionDigits: 0 }) + 'M';
        }
        const ms = this.milestoneCol;
        if (ms) {
            const next = groupRows.map((r) => this.cellRaw(r, ms.name)).find((v) => v);
            if (next) meta += ' · next: ' + next;
        }
        return meta;
    }

    mapRow(row) {
        const expanded = this.expandedId === row.id;
        return {
            id: row.id,
            name: row.name,
            expanded,
            expKey: 'exp-' + row.id,
            rowClass: expanded ? 'lc-row row-open' : 'lc-row',
            chevron: expanded ? '▼' : '▶',
            cells: this.columns.map((col) => this.mapCell(row, col)),
            detailPairs: this.columns.map((col) => ({
                key: row.id + '-d-' + col.name,
                label: col.label,
                value: this.displayFor(row, col)
            }))
        };
    }

    mapCell(row, col) {
        const isEditing =
            this.editing && this.editing.rowId === row.id && this.editing.colName === col.name;
        const isRef = col.type === 'reference';
        const isNotes = this.isNotesCol(col);
        const cat = this.isCat(col);
        const dirty = !!(this.drafts[row.id] && this.drafts[row.id][col.name]);

        let cls = 'td';
        if (col.align === 'right') cls += ' num';
        if (col.isLink) cls += ' name-cell';
        if (dirty) cls += ' is-dirty';
        if (col.editable && !isNotes && !this.notesOnlyEdit) cls += ' editable';
        if (isEditing) cls += ' is-editing';
        if (isNotes) cls += ' notes-cell';

        const display = this.displayFor(row, col);

        let linkUrl = null;
        if (col.isLink) {
            linkUrl = row.url;
        } else if (isRef) {
            const refId = this.rawValue(row, col);
            if (refId) linkUrl = '/' + refId;
        }
        const isRecordLink = !!linkUrl && !!display;

        return {
            key: row.id + '::' + col.name,
            colName: col.name,
            rowId: row.id,
            cellClass: cls,
            display,
            isNotes,
            notesValue: display,
            // view-mode variants
            showLink: !isNotes && !isEditing && isRecordLink,
            showCat: !isNotes && !isEditing && cat && !isRecordLink,
            showPlain: !isNotes && !isEditing && !isRecordLink && !cat,
            linkUrl,
            // edit-mode variants
            isTextEdit: !isNotes && isEditing && !isRef,
            isReferenceEdit: !isNotes && isEditing && isRef,
            editValue: isEditing ? this.editValue : null,
            refPlaceholder: display || 'Search…',
            lookupResults: isEditing && isRef ? this.lookupResults : []
        };
    }

    /* ─────────────────────────────  Display  ────────────────────────── */

    rawValue(row, col) {
        const d = this.drafts[row.id] && this.drafts[row.id][col.name];
        if (d) return d.value;
        const cell = row.cells.find((c) => c.key === col.name);
        return cell ? cell.value : null;
    }

    displayFor(row, col) {
        const d = this.drafts[row.id] && this.drafts[row.id][col.name];
        if (col.type === 'reference') {
            if (d) return d.display;
            const cell = row.cells.find((c) => c.key === col.name);
            return cell ? cell.display || '' : '';
        }
        const val = d ? d.value : this.originalValue(row, col.name);
        return this.format(val, col.type);
    }

    originalValue(row, colName) {
        const cell = row.cells.find((c) => c.key === colName);
        return cell ? cell.value : null;
    }

    format(v, type) {
        if (v === null || v === undefined || v === '') return '';
        switch (type) {
            case 'currency':
                return '$' + Number(v).toLocaleString('en-US', { maximumFractionDigits: 0 });
            case 'number':
                // Deal Value is captured in millions in this demo → "$210M".
                return '$' + Number(v).toLocaleString('en-US', { maximumFractionDigits: 0 }) + 'M';
            case 'percent':
                return v + '%';
            case 'multipicklist':
                return String(v).split(';').join(', ');
            default:
                return String(v);
        }
    }

    /* ─────────────────────────────  Editing  ────────────────────────── */

    handleCellClick(event) {
        if (this.notesOnlyEdit) return; // read-only board except the Notes column
        const { rowId, col } = event.currentTarget.dataset;
        const column = this.colByName(col);
        if (!column || this.isNotesCol(column)) return; // Notes handled by its own textarea
        if (this.editing && this.editing.rowId === rowId && this.editing.colName === col) return;
        if (!column.editable) return;
        event.stopPropagation();
        this.startEdit(rowId, col);
    }

    startEdit(rowId, colName) {
        const column = this.colByName(colName);
        const row = this.rows.find((r) => r.id === rowId);
        this.lookupResults = [];
        this.editValue =
            column.type === 'reference' ? '' : this.valueOrEmpty(this.rawValue(row, column));
        this.editing = { rowId, colName };
        this._focused = false;
    }

    valueOrEmpty(v) {
        return v === null || v === undefined ? '' : v;
    }

    handleEditInput(event) {
        this.editValue = event.target.value;
    }

    handleEditCommit(event) {
        if (event.type === 'keydown') {
            if (event.key === 'Escape') {
                this.cancelEdit();
                return;
            }
            if (event.key !== 'Enter') return;
        }
        if (!this.editing) return;
        const { rowId, colName } = this.editing;
        const col = this.colByName(colName);
        this.commitDraft(rowId, col, this.editValue, this.format(this.editValue, col.type));
    }

    handleNotesBlur(event) {
        const { rowId, col } = event.currentTarget.dataset;
        const column = this.colByName(col);
        const value = event.target.value;
        const original = this.valueOrEmpty(this.originalValue({ id: rowId, cells: this.cellsFor(rowId) }, col));
        if (String(value) === String(original)) return;
        this.commitDraft(rowId, column, value, value);
    }

    cellsFor(rowId) {
        const row = this.rows.find((r) => r.id === rowId);
        return row ? row.cells : [];
    }

    handleRefKey(event) {
        if (event.key === 'Escape') this.cancelEdit();
    }

    handleLookupInput(event) {
        const term = event.target.value;
        this.editValue = term;
        const col = this.colByName(this.editing.colName);
        if (!term) {
            this.lookupResults = [];
            return;
        }
        searchLookup({ objectApiName: col.referenceObject, term })
            .then((res) => {
                this.lookupResults = res || [];
            })
            .catch(() => {
                this.lookupResults = [];
            });
    }

    handleLookupPick(event) {
        const { id, name } = event.currentTarget.dataset;
        const { rowId, colName } = this.editing;
        const col = this.colByName(colName);
        this.commitDraft(rowId, col, id, name);
    }

    commitDraft(rowId, col, value, display) {
        const next = { ...this.drafts };
        next[rowId] = { ...(next[rowId] || {}) };
        next[rowId][col.name] = { writeField: col.writeField, value, display };
        this.drafts = next;
        this.editing = null;
        this.editValue = null;
        this.lookupResults = [];
    }

    cancelEdit() {
        this.editing = null;
        this.editValue = null;
        this.lookupResults = [];
    }

    /* ─────────────────────────────  Save / cancel  ──────────────────── */

    handleSave() {
        const payload = Object.keys(this.drafts).map((rowId) => {
            const fields = {};
            const rowDrafts = this.drafts[rowId];
            Object.keys(rowDrafts).forEach((colName) => {
                const d = rowDrafts[colName];
                fields[d.writeField] = d.value === '' ? null : d.value;
            });
            return { id: rowId, fields };
        });

        updateMandates({ changes: JSON.stringify(payload) })
            .then(() => {
                this.drafts = {};
                this.toast('Saved', payload.length + ' mandate(s) updated', 'success');
                return refreshApex(this.wiredResult);
            })
            .catch((e) => {
                this.toast('Save failed', this.reduceError(e), 'error');
            });
    }

    handleCancelAll() {
        this.drafts = {};
        this.cancelEdit();
    }

    /* ─────────────────────────────  Grouping / expand  ──────────────── */

    handleToggleGroup(event) {
        const stage = event.currentTarget.dataset.stage;
        this.closedGroups = { ...this.closedGroups, [stage]: !this.closedGroups[stage] };
    }

    handleToggleExpand(event) {
        event.stopPropagation();
        const rowId = event.currentTarget.dataset.rowId;
        if (this.expandedId === rowId) {
            this.expandedId = null;
            this.publishAi({ mandatesReset: true });
            return;
        }
        this.expandedId = rowId;
        const row = this.rows.find((r) => r.id === rowId);
        // Stage-based action set (per reference v4); the row name is the context title.
        this.publishAi({ selectedContext: row ? row.name : '', itemId: 'mlive_' + (row ? row.stage : '') });
    }

    stopClick(event) {
        event.stopPropagation();
    }

    /* ─────────────────────────────  Helpers  ────────────────────────── */

    publishAi(message) {
        if (this.messageContext) publish(this.messageContext, NAVATAR_AI_CHANNEL, message);
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    reduceError(e) {
        if (!e) return 'Unknown error';
        if (Array.isArray(e.body)) return e.body.map((b) => b.message).join(', ');
        if (e.body && e.body.message) return e.body.message;
        return e.message || JSON.stringify(e);
    }
}