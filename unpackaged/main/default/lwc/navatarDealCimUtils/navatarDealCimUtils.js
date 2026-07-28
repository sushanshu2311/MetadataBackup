/**
 * Shared, framework-free helpers for the Project Everest / CIM Stage
 * NavatarDeal* component family. Pure functions only — no LWC lifecycle here.
 */

/** Renders an empty/blank value as an em dash, matching the read-only Snapshot convention. */
export function emDash(value) {
    if (value === null || value === undefined) return '—';
    const trimmed = String(value).trim();
    return trimmed.length ? trimmed : '—';
}

/** Days elapsed between a stage-entry date (yyyy-mm-dd) and an as-of date, floor-rounded. */
export function daysBetween(entryDateStr, asOfDateStr) {
    if (!entryDateStr) return null;
    const entry = new Date(entryDateStr);
    const asOf = asOfDateStr ? new Date(asOfDateStr) : new Date();
    const diff = Math.floor((asOf - entry) / 86400000);
    return isNaN(diff) || diff < 0 ? null : diff;
}

export function formatDays(days) {
    if (days === null || days === undefined) return emDash(null);
    return `${days} ${days === 1 ? 'day' : 'days'}`;
}

/** Case-insensitive substring match used by every search box across the tabs. */
export function matchesQuery(text, query) {
    if (!query) return true;
    return String(text || '').toLowerCase().includes(query.toLowerCase());
}

/**
 * Applies the shared "All is exclusive" multi-select rule used by every pill/filter dropdown:
 * choosing __all__ clears the rest; choosing anything else clears __all__;
 * clearing everything falls back to __all__.
 */
export function reconcileAllExclusive(selectedValues, changedValue) {
    let next = [...selectedValues];
    if (changedValue === '__all__') {
        next = ['__all__'];
    } else {
        next = next.filter((v) => v !== '__all__');
        if (!next.includes(changedValue)) {
            next.push(changedValue);
        } else {
            next = next.filter((v) => v !== changedValue);
        }
        if (next.length === 0) next = ['__all__'];
    }
    return next;
}

let _seq = 0;
/** Deterministic-enough unique id generator for client-created rows (team members, etc). */
export function nextKey(prefix) {
    _seq += 1;
    return `${prefix || 'row'}-${_seq}`;
}