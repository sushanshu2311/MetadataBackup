import { LightningElement } from 'lwc';
import { KEY_METRICS } from 'c/customDealDataService';

export default class CustomKeyMetricsCard extends LightningElement {
    get metricRows() {
        const rows = [];
        for (let i = 0; i < KEY_METRICS.length; i += 2) {
            rows.push({
                id: 'row-' + i,
                left: KEY_METRICS[i],
                right: KEY_METRICS[i + 1] || { label: '', value: '' }
            });
        }
        return rows;
    }
}