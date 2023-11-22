/**
* Created by Frederik on 18/09/2023.
* Description:
* Change Log:
* Dependencies:
*/

public without sharing class LoyaltyProgramController {

    @AuraEnabled
    public static Decimal getLoyaltyPoints(String OrderId){
        System.debug('OrderId: ' + OrderId);

        Decimal loyaltyPoints = [SELECT Account.Loyaltypoints__c FROM Order WHERE Id = :OrderId].Account.Loyaltypoints__c;
        System.debug('LoyaltyPoints: ' + loyaltyPoints);
        return loyaltyPoints;
    }

    @AuraEnabled
    public static List<Loyalty_Program_Reward__c> getRewards(String OrderId){

        System.debug('OrderId: ' + OrderId);

        String AccountId = [SELECT AccountId FROM Order WHERE Id = :OrderId].AccountId;

        String LoyaltyProgramId = [SELECT Loyalty_Program__c FROM Account WHERE Id = :AccountId].Loyalty_Program__c;
        List<Loyalty_Program_Reward__c> rewards = [SELECT Id, Odoo_ID__c, Name, Minimum_Points__c, Product__r.Name, Product__c, Point_Cost__c FROM Loyalty_Program_Reward__c WHERE Loyalty_Program__c = :LoyaltyProgramId];
        return rewards;

    }

    @AuraEnabled
    public static String saveRewards(List<Loyalty_Program_Reward__c> rewards, String OrderId) {
        System.debug('Rewards: ' + rewards);
        System.debug('OrderId: ' + OrderId);
        String result = 'Success';

        try {

            List<String> rewardIds = new List<String>();
            for (Loyalty_Program_Reward__c reward : rewards) {
                rewardIds.add(reward.Product__c);
            }

            System.debug('RewardIds: ' + rewardIds);

            String PricebookId = [SELECT Pricebook2Id FROM Order WHERE Id = :OrderId].Pricebook2Id;
            System.debug('PricebookId: ' + PricebookId);

            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :rewardIds AND Pricebook2Id = :PricebookId];
            System.debug('PricebookEntries: ' + pricebookEntries);

            List<OrderItem> orderItems = new List<OrderItem>();

            for (Loyalty_Program_Reward__c reward : rewards) {
                for (PricebookEntry pricebookEntry : pricebookEntries) {
                    if (reward.Product__c == pricebookEntry.Product2Id) {
                        OrderItem orderItem = new OrderItem();
                        orderItem.OrderId = OrderId;
                        orderItem.PricebookEntryId = pricebookEntry.Id;
                        orderItem.Quantity = reward.Quantity__c;
                        orderItem.UnitPrice = 0;
                        orderItem.Loyalty_Points__c = (Decimal) reward.Point_Cost__c/1000;
                        orderItem.Odoo_Reward_ID__c = reward.Odoo_ID__c;
                        orderItems.add(orderItem);
                    }
                }
            }

            System.debug('OrderItems: ' + orderItems);
            insert orderItems;
            return result;
        } catch (Exception e) {
            System.debug('Error: ' + e);
            result = 'Error: ' + e;
            return result;
        }
    }


}