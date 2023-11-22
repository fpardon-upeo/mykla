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
 * Created: 19/09/2023
 * Last Updated: 19/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooSaleOrderInvocableTest {
    @IsTest
    static void testOrderInvocable() {

        Account a = new Account();
        a.Name = 'Test Account';
        a.Odoo_ID__c = 12723;
        insert a;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true,
                Odoo_ID__c = 1
        );

        Pricebook2 pb1 = new Pricebook2(Name = 'Test Pricebook 1', Odoo_ID__c = 152, IsActive = true);
        insert pb1;

        Product2 odooProduct = new Product2();
        odooProduct.Name = 'Test Product';
        odooProduct.Odoo_ID__c = 21233;

        Product2 odooProduct2 = new Product2();
        odooProduct2.Name = 'Test Product 2';
        odooProduct2.Odoo_ID__c = 13631;

        insert odooProduct;
        insert odooProduct2;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = odooProduct.Id,
                UnitPrice = 100,
                IsActive = true
        );

        PricebookEntry pbe2 = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = odooProduct2.Id,
                UnitPrice = 200,
                IsActive = true
        );

        PricebookEntry pbe3 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = odooProduct.Id,
                UnitPrice = 300,
                IsActive = true
        );

        PricebookEntry pbe4 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = odooProduct2.Id,
                UnitPrice = 400,
                IsActive = true
        );

        insert pbe;
        insert pbe2;
        insert pbe3;
        insert pbe4;

        Order odooOrder = new Order();
        odooOrder.AccountId = a.Id;
        odooOrder.Pricebook2Id = pb1.Id;
        odooOrder.EffectiveDate = Date.today();
        odooOrder.Status = 'Draft';
        odooOrder.Order_Status__c = 'Draft';

        insert odooOrder;

        String orderNumber = [SELECT OrderNumber FROM Order WHERE Id = :odooOrder.Id].OrderNumber;
        System.debug('Order Number: ' + orderNumber);
        String orderName = [SELECT Order_Name__c FROM Order WHERE Id = :odooOrder.Id].Order_Name__c;
        System.debug('Order Name: ' + orderName);


        OrderItem odooOrderItem = new OrderItem();
        odooOrderItem.OrderId = odooOrder.Id;
        odooOrderItem.PricebookEntryId = pbe3.Id;
        odooOrderItem.Quantity = 1;
        odooOrderItem.UnitPrice = 300;

        OrderItem odooOrderItem2 = new OrderItem();
        odooOrderItem2.OrderId = odooOrder.Id;
        odooOrderItem2.PricebookEntryId = pbe4.Id;
        odooOrderItem2.Quantity = 1;
        odooOrderItem2.UnitPrice = 400;

        insert odooOrderItem;
        insert odooOrderItem2;

        OdooSaleOrderPostPatchInvocable.RequestWrapper requestWrapper = new OdooSaleOrderPostPatchInvocable.RequestWrapper();
        requestWrapper.order = odooOrder;

        List<OdooSaleOrderPostPatchInvocable.RequestWrapper> requestWrapperList = new List<OdooSaleOrderPostPatchInvocable.RequestWrapper>();
        requestWrapperList.add(requestWrapper);

        String json=		'{'+
                '  "data": {'+
                '    "type": "sale_order",'+
                '    "attributes": {'+
                '      "start_date": "2023-09-20",'+
                '      "price_list_id": 152,'+
                '      "name": "00015866",'+
                '      "lines": ['+
                '        {'+
                '          "type": "sale_order_line",'+
                '          "attributes": {'+
                '            "salesforce_identifier": "8027Z000006wajoQAA",'+
                '            "reward_id": 9259,'+
                '            "product_uom_qty": 3,'+
                '            "product_id": 13631,'+
                '            "list_price": 10,'+
                '            "price_unit": 10'+
                '          }'+
                '        },'+
                '        {'+
                '          "type": "sale_order_line",'+
                '          "attributes": {'+
                '            "salesforce_identifier": "8027Z000006wab0QAA",'+
                '            "product_uom_qty": 5,'+
                '            "product_id": 21233,'+
                '            "list_price": 24.71,'+
                '            "price_unit": 24.71'+
                '          }'+
                '        }'+
                '      ],'+
                '      "customer_reference": "fgfgfgf",'+
                '      "account_name": 12723,'+
                '      "state": "draft"'+
                '    }'+
                '  }'+
                '}';

        json = json.replace('00015866', 'SFO-2023-'+orderNumber);
        json = json.replace('8027Z000006wajoQAA', odooOrderItem.Id);
        json = json.replace('8027Z000006wab0QAA', odooOrderItem2.Id);

        SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/sale_order', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        OdooSaleOrderPostPatchInvocable.postPatchOrderToOdoo(requestWrapperList);
        Test.stopTest();
        //run again to test the patch
        OdooSaleOrderPostPatchInvocable.postPatchOrderToOdoo(requestWrapperList);





    }
}