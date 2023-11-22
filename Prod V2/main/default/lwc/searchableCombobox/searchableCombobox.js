/**
 * Created by Upeo on 20/10/2023.
 */

import {LightningElement} from 'lwc';
import getValuesFromTable from '@salesforce/apex/SearchableComboboxController.getObjectValues';

export default class SearchableCombobox extends LightningElement {
    picklistOrdered;
    searchResults;
    selectedSearchResult;

    get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;
    }

    connectedCallback() {
        getValuesFromTable().then((result) => {
            console.log('result: ' + JSON.stringify(result));
            let picklistOptions = [];
            result.forEach((picklistOption) => {
                //Only push the values when they are not null and when they are not already in the list
                if (picklistOption && !picklistOptions.includes(picklistOption)){
                    picklistOptions.push({
                        label: picklistOption,
                        value: picklistOption
                    })
                }
            });
            // Sort the picklist options by label
            picklistOptions.sort((a, b) => (a.label > b.label ? 1 : -1));
            this.picklistOrdered = picklistOptions;
        })
    }

    search(event) {
        this.searchResults = null;
        const input = event.target.value.toLowerCase(); // Use event.target to access the input value
        console.log('input: ' + input);

        // If the input is empty, clear the searchResults and return
        if (!input) {
            this.clearSearchResults();
            return;
        }

        // Filter the picklist options based on the input
        const result = this.picklistOrdered.filter(picklistOption =>
            picklistOption.label.toLowerCase().includes(input)
        );

        console.log('result: ' + JSON.stringify(result));
        this.searchResults = result;
    }

    searchHelper(event) {
        let input = event.detail.value.toLowerCase();
        console.log('input: ' + input);
        let result = this.picklistOrdered.filter(picklistOption =>
            picklistOption.label.toLowerCase().includes(input)
        );
        console.log('result: ' + JSON.stringify(result));
        this.searchResults = result;
    }

    selectSearchResult(event) {
        console.log('selectedValue: ' + event.currentTarget.dataset.value);
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedSearchResult = this.picklistOrdered.find(
            (picklistOption) => picklistOption.value === selectedValue
        );
        this.sendSelectedValue();
        this.clearSearchResults();
    }

    sendSelectedValue() {
        this.dispatchEvent(new CustomEvent('selectedvalue', {detail: this.selectedSearchResult.value}));
    }

    clearSearchResults() {
        this.searchResults = null;
    }

    showPicklistOptions() {
        if (!this.searchResults) {
            this.searchResults = this.picklistOrdered;
        }
    }
}