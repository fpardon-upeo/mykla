/**
 * @Version: 1.0
 * @Author: Frederik
 * @Copyright: 2021 Upeo Consulting
 * @Uses:
 *
 * -----------------------------------------------------------------------------------------------
 * Description: 
 *
 *
 * Created: 28/09/2023
 * Last Updated: 28/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
/**
@Description:

@Change Log:

@Dependencies:

@Test Classes:

*/

public without sharing class CreateStarterPackageOrderLines {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Order' Description='The OrderCrea for which to create the Starter Package Lines')
        public Order order;
        @InvocableVariable(Required=true Label='Package' Description='The Starter Package to create the Starter Package Lines from')
        public Package__c starterPackage;
    }

    @InvocableMethod(Label='Create Order Package Lines from Starter Package' Description='Create Order Package Lines from Starter Package')
    public static void createOrderLines(List<RequestWrapper> requestWrappers) {
        for (RequestWrapper requestWrapper : requestWrappers) {
            createStarterPackageLines(requestWrapper.order, requestWrapper.starterPackage);
        }
    }

    private static void createStarterPackageLines(Order order, Package__c starterPackage) {

        System.debug('order ' + order);
        System.debug('starterPackage ' + starterPackage);

        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice from PricebookEntry WHERE Pricebook2Id = :order.Pricebook2Id];
        List<Package_Line__c> packageLines = [SELECT Id, Product__c, Price__c, Quantity__c from Package_Line__c WHERE Package__c = :starterPackage.Id AND External_Id__c != null AND Price_Book__c = :order.Pricebook2Id];

        System.debug('pricebookEntries ' + pricebookEntries);
        System.debug('packageLines ' + packageLines);


        Map<String, String> productMap = new Map<String, String>();
        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        for(PricebookEntry pbe : pricebookEntries){
            productMap.put(pbe.Product2Id, pbe.Id);
            priceMap.put(pbe.Product2Id, pbe.UnitPrice);
        }

        List<OrderItem> orderItems = new List<OrderItem>();

        for (Package_Line__c packageLine : packageLines) {

            if(productMap.containsKey(packageLine.Product__c)) {
                System.debug('contains key');
                OrderItem orderItem = new OrderItem();
                orderItem.OrderId = order.Id;
                orderItem.PricebookEntryId = productMap.get(packageLine.Product__c);
                orderItem.Quantity = packageLine.Quantity__c;
                orderItem.UnitPrice = priceMap.get(packageLine.Product__c) != null ? priceMap.get(packageLine.Product__c) : 0;
                orderItems.add(orderItem);
            } else {
                System.debug('does not contain key');
            }
        }

        System.debug('orderItems ' + orderItems);

        insert orderItems;

        //Only callout when not in test context
        if(!Test.isRunningTest()) {
            updateOrder(order.Id);
        }
    }

    @Future(callout=true)
    public static void updateOrder(Id orderId) {
        Order order = [SELECT Id, Sent_to_Odoo__c from Order WHERE Id = :orderId];
        order.Sent_to_Odoo__c = true;
        update order;
    }


}