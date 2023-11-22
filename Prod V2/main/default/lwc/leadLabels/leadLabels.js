/**
 * Created by Upeo on 20/10/2023.
 */

import {LightningElement, api, track} from 'lwc';
import getLeadLabels from '@salesforce/apex/SearchableComboboxController.getLeadLabels';
import { updateRecord } from 'lightning/uiRecordApi';
import LEAD_LABEL_FIELD from '@salesforce/schema/Lead.Labels__c';
import LEAD_ID_FIELD from '@salesforce/schema/Lead.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LeadLabels extends LightningElement {

    @api recordId;
    lead;
    leadLabel;
    @track leadLabels;

    connectedCallback() {
        console.log('recordId: ' + this.recordId);
        getLeadLabels({recordId: this.recordId})
            .then((result) => {
                this.leadLabel = result;
                this.leadLabels = this.setAccountLabels();
            })
    }

    handleAddSelectedValue(event) {
        console.log('handleAddSelectedValue: ' + event.detail);
        let newLabel = event.detail;
        let leadLabels = this.leadLabels
        if(leadLabels != null && leadLabels.includes(newLabel)) {
            console.log('Label already exists');
        } else {
            console.log('Label does not exist yet');
            leadLabels.push(newLabel);
        }
        this.leadLabels = leadLabels;
        this.leadLabel = this.leadLabels.join(';');
        this.handleSave();
    }

    handleRemove(event) {
        console.log('handleRemove: ' + event.target.dataset.label);
        let labelToRemove = event.target.dataset.label;
        let leadLabels = this.leadLabels;
        let index = leadLabels.indexOf(labelToRemove);
        if (index > -1) {
            leadLabels.splice(index, 1);
        }
        this.leadLabels = leadLabels;
        this.leadLabel = this.leadLabels.join(';');
        this.handleSave();
    }

    setAccountLabels() {
        console.log('setAccountLabels');
        console.log('account: ' + JSON.stringify(this.leadLabel));
        if(this.leadLabel != null && this.leadLabel.includes(';')) {
            if(this.leadLabel.endsWith(';')) {
                return [this.leadLabel.substring(0, this.leadLabel.length - 1)];
            }  else {
                return this.leadLabel.split(';');
            }
        } else if(this.leadLabel != null) {
            return [this.leadLabel];
        } else {
            return [];
        }
    }

    handleSave() {

        const fields = {};
        fields[LEAD_LABEL_FIELD.fieldApiName] = this.leadLabel;
        fields[LEAD_ID_FIELD.fieldApiName] = this.recordId;
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