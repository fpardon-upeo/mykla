/**
 * Created by Upeo on 18/09/2023.
 */

import {LightningElement, api, wire, track} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import getLoyaltyPrograms from '@salesforce/apex/LoyaltyProgramController.getRewards';
import saveRewards from '@salesforce/apex/LoyaltyProgramController.saveRewards';
import getLoyaltyPoints from '@salesforce/apex/LoyaltyProgramController.getLoyaltyPoints';

const columns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Points Cost', fieldName: 'Point_Cost__c', type: 'number',
            cellAttributes: { alignment: 'left' },
    },
];

const columnsSelected = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Points Cost', fieldName: 'Point_Cost__c', type: 'number',
        cellAttributes: { alignment: 'left' },
    },
];


export default class LoyaltyProducts extends LightningElement {

    @api recordId;
    refreshHandlerID;
    loyaltyPrograms;
    @track selectedRewards = [];
    columns = columns;
    loading = false;

    showAllProducts = false;
    showSelectedProducts = false;
    loyaltyPoints;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    disconnectedCallback() {
        this.dispatchEvent(new RefreshEvent());
    }

    connectedCallback() {
        console.log('recordId: ' + this.recordId);
        this.loading = true;
        getLoyaltyPoints({OrderId: this.recordId})
            .then(result => {
                console.log('result: ' + JSON.stringify(result));
                this.loyaltyPoints = result;
                this.loyaltyPoints = parseFloat(this.loyaltyPoints).toFixed(3);
            })
        getLoyaltyPrograms({OrderId: this.recordId})
            .then(result => {

                result.forEach(function (item) {
                    item.Point_Cost__c = parseFloat(item.Point_Cost__c).toFixed(3);
                });


                this.loyaltyPrograms = result;
                console.log('this.loyaltyPrograms: ' + JSON.stringify(this.loyaltyPrograms));
                this.loading = false;
                this.showAllProducts = true;
            })
            .catch(error => {
                console.log('error: ' + JSON.stringify(error));
                this.loading = false;
                this.showAllProducts = false;
            });
    }

    addLoyaltyPrograms() {
        console.log('addLoyaltyPrograms');

        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
        console.log(selected);

        if(selected.length == 0 ||selected == null){
            this.showNoProductsSelectedToast();
            return;
        }

        let index = 0;
        selected.forEach(function (item) {
            item.Quantity__c = 1;
            item.Index = index;
            item.Cost = item.Point_Cost__c;
            index++;
        });

        this.selectedRewards = selected;
        this.showAllProducts = false;
        this.showSelectedProducts = true;

        console.log('this.selectedRewards: ' + JSON.stringify(this.selectedRewards));

    }

    handleQuantityChange(event) {
        console.log('handleQuantityChange');
        console.log('event.target.name: ' + event.target.name);
        console.log('event.target.value: ' + event.target.value);
        console.log('data-id: ' + event.target.dataset.id);
        //update the selectedRewards record that matches the data-id
        let index = event.target.dataset.index;
        let selectedRewards = this.selectedRewards;
        console.log('index: ' + index);
        selectedRewards[index].Quantity__c = event.target.value;
        selectedRewards[index].Point_Cost__c = selectedRewards[index].Cost * event.target.value;
        //make sure we only have 4 decimals
        selectedRewards[index].Point_Cost__c = parseFloat(selectedRewards[index].Point_Cost__c).toFixed(3);
        console.log('this.selectedRewards: ' + JSON.stringify(selectedRewards));
        this.selectedRewards = selectedRewards;
        console.log('this.selectedRewards: ' + JSON.stringify(this.selectedRewards));
    }

    saveLoyaltyRewards() {
        if(parseInt(this.totalPoints) > parseInt(this.loyaltyPoints)){
            this.showTotalExceededToast();
            return;
        }
        console.log('saveLoyaltyPrograms');
        saveRewards({rewards: this.selectedRewards, OrderId: this.recordId})
            .then(result => {
                this.dispatchEvent(new RefreshEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Loyalty rewards saved',
                        variant: 'success',
                    }));
                const closeActionEvent = new CloseActionScreenEvent();
                this.dispatchEvent(closeActionEvent);
            })
            .catch(error => {
                console.log('error: ' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error saving loyalty rewards',
                        variant: 'error',
                    }));
            });
    }

    get totalPoints() {
        let totalPoints = 0;
        this.selectedRewards.forEach(function (item) {
            totalPoints = parseFloat(item.Point_Cost__c) + parseFloat(totalPoints);
        });
        totalPoints = parseFloat(totalPoints).toFixed(3);
        return totalPoints;
    }

    get addLoyaltyProgramsEnabled() {
        if(parseInt(this.totalPoints) > parseInt(this.loyaltyPoints)){
            console.log('disabled');
            return false;
        }
        else{
            console.log('enabled');
            return true;
        }
    }

    get totalPointsStyling() {
        console.log('totalPoints = ' + this.totalPoints);
        console.log('loyaltyPoints = ' + this.loyaltyPoints);
        if (parseInt(this.totalPoints) > parseInt(this.loyaltyPoints)) {
            return 'color: red';
        }
        else {
            return 'color: green';
        }
    }

    showNoProductsSelectedToast() {
        const event = new ShowToastEvent({
            title: 'No products selected',
            message: 'Please select at least one product',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showTotalExceededToast() {
        const event = new ShowToastEvent({
            title: 'Not enough points',
            message: 'The total points exceeds the available points',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


}