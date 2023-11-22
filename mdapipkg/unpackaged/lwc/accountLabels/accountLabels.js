/**
 * Created by Frederik on 20/10/2023.
 */

import {LightningElement, api, track} from 'lwc';
import getAccountLabels from '@salesforce/apex/SearchableComboboxController.getAccountLabels';
import { updateRecord } from 'lightning/uiRecordApi';
import ACCOUNT_LABEL_FIELD from '@salesforce/schema/Account.Labels__c';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AccountLabels extends LightningElement {

    @api recordId;
    account;
    accountLabel;
    @track accountLabels;

    connectedCallback() {
        console.log('recordId: ' + this.recordId);
        getAccountLabels({recordId: this.recordId})
            .then((result) => {
                this.accountLabel = result;
                this.accountLabels = this.setAccountLabels();
            })
    }

    handleAddSelectedValue(event) {
        console.log('handleAddSelectedValue: ' + event.detail);
        let newLabel = event.detail;
        let accountLabels = this.accountLabels
        if(accountLabels != null && accountLabels.includes(newLabel)) {
            console.log('Label already exists');
        } else {
            console.log('Label does not exist yet');
            accountLabels.push(newLabel);
        }
        this.accountLabels = accountLabels;
        this.accountLabel = this.accountLabels.join(';');
        this.handleSave();
    }

    handleRemove(event) {
        console.log('handleRemove: ' + event.target.dataset.label);
        let labelToRemove = event.target.dataset.label;
        let accountLabels = this.accountLabels;
        let index = accountLabels.indexOf(labelToRemove);
        if (index > -1) {
            accountLabels.splice(index, 1);
        }
        this.accountLabels = accountLabels;
        this.accountLabel = this.accountLabels.join(';');
        this.handleSave();
    }

    setAccountLabels() {
        console.log('setAccountLabels');
        console.log('account: ' + JSON.stringify(this.accountLabel));
        if(this.accountLabel != null && this.accountLabel.includes(';')) {
            if(this.accountLabel.endsWith(';')) {
                return [this.accountLabel.substring(0, this.accountLabel.length - 1)];
            }  else {
                return this.accountLabel.split(';');
            }
        } else if(this.accountLabel != null) {
            return [this.accountLabel];
        } else {
            return [];
        }
    }

    handleSave() {

        const fields = {};
        fields[ACCOUNT_LABEL_FIELD.fieldApiName] = this.accountLabel;
        fields[ACCOUNT_ID_FIELD.fieldApiName] = this.recordId;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                console.log('Labels updated');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Labels updated',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.log('Labels not updated');
                console.log('error: ' + JSON.stringify(error));
            });

    }

}