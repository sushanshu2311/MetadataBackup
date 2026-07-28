import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const QUESTIONS = [
    { id: 'q1', question: 'What is management\'s remediation plan for the CMS supervision requirement at the 3 affected sites?', status: 'Outstanding', source: 'AI',     added: 'Added Today — for 18 Jun meeting', answer: '' },
    { id: 'q2', question: 'What is the contractual position on the Guildford CCG referral renewal in 2027?',                     status: 'Outstanding', source: 'Manual', added: 'Added 22 May — Thomas Bennett',    answer: '' },
    { id: 'q3', question: 'What is the estimated cost of IT system upgrades across the 8 legacy sites?',                         status: 'Partial',     source: 'AI',     added: 'Added 03 Jun',                     answer: 'Management provided indicative range of £1.2–1.8M. Gartner to confirm by 17 Jun.' },
    { id: 'q4', question: 'Has Mark Hargreaves confirmed intention to remain post-close?',                                       status: 'Answered',    source: 'Manual', added: 'Answered 28 May',                  answer: 'Verbal confirmation 28 May. Subject to retention terms. Open to 3-year earn-out.' },
];

export default class DealQuestionsTab extends LightningElement {
    @api recordId;
    questions = QUESTIONS;

    handleAddQuestion() {
        this.dispatchEvent(new ShowToastEvent({ title: 'Add question', variant: 'info', mode: 'dismissible' }));
    }
}