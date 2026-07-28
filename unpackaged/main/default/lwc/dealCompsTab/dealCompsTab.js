import { LightningElement, api } from 'lwc';

const COMPS = [
    { id: 'c1', code: 'BH', name: 'Project Lighthouse — BrightPath Health',  meta: 'UK outpatient rehab · £32M revenue · Closed Nov 2023 · 10.8× EBITDA',      note: 'Same sector, same banker. CMS risk present — resolved via operational restructure.' },
    { id: 'c2', code: 'CH', name: 'Project Harrier — Crestwood Health',       meta: 'UK primary care · £41M revenue · Lost at LOI Nov 2024 · 12.1× (Advent won)', note: 'Advent ring-fenced management with earn-out — useful precedent for retention structuring.' },
    { id: 'c3', code: 'PT', name: 'Project Titan — Pinnacle Therapy Group',   meta: 'UK physiotherapy · £19M revenue · Passed at SIM',                           note: 'Passed for same CMS supervision issue at 2 sites — benchmark for current risk.' },
];

export default class DealCompsTab extends LightningElement {
    @api recordId;
    comparables = COMPS;
}