/**
 * @Version: 1.0
 * @Author: Upeo
 * @Copyright: 2021 Upeo Consulting
 * @Uses:
 *
 * -----------------------------------------------------------------------------------------------
 * Description: 
 *
 *
 * Created: 18/09/2023
 * Last Updated: 18/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooSalesOrderServiceTest {

    @TestSetup
    static void setup() {

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true,
                Odoo_ID__c = 1
        );
        update standardPricebook;

        Pricebook2 pb1 = new Pricebook2(Name = 'Test Pricebook 1', Odoo_ID__c = 151, IsActive = true);
        insert pb1;

        Product2 p1 = new Product2(
                Name = 'CPC Brush Soap',
                ProductCode = 'CPC Brush Soap 5634666',
                IsActive = true,
                Odoo_ID__c = 5634
        );

        Product2 p2 = new Product2(
                Name = 'CPC Duo slijper',
                ProductCode = 'CPC Duo slijper 6028666',
                IsActive = true,
                Odoo_ID__c = 6028
        );

        insert p1;
        insert p2;

        p1 = [SELECT Id FROM Product2 WHERE Name = 'CPC Brush Soap' LIMIT 1];
        p2 = [SELECT Id FROM Product2 WHERE Name = 'CPC Duo slijper' LIMIT 1] ;
        pb1 = [SELECT Id FROM Pricebook2 WHERE Name = 'Test Pricebook 1' LIMIT 1];
        standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        PricebookEntry standardPricebookEntry1 = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = p1.Id,
                UnitPrice = 100,
                IsActive = true,
                Odoo_ID__c = '5634-1'
        );

        PricebookEntry standardPricebookEntry2 = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = p2.Id,
                UnitPrice = 200,
                IsActive = true,
                Odoo_ID__c = '6028-1'
        );

        PricebookEntry pricebookEntry1 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = p1.Id,
                UnitPrice = 100,
                Odoo_ID__c = '5634-151',
                IsActive = true
        );

        PricebookEntry pricebookEntry2 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = p2.Id,
                UnitPrice = 200,
                Odoo_ID__c = '6028-151',
                IsActive = true
        );

        insert new List<PricebookEntry>{standardPricebookEntry1, standardPricebookEntry2};
        insert new List<PricebookEntry>{pricebookEntry1, pricebookEntry2};



    }

    @IsTest
    static void testGetOrders() {

        Account acc = new Account(
                Name = 'Test Account',
                Odoo_ID__c = 7292
        );
        insert acc;

        String json=
                '{'+
                '    "meta": {'+
                '        "total": 2,'+
                '        "size": 2,'+
                '        "limit": 2,'+
                '        "offset": 0'+
                '    },'+
                '    "data": ['+
                '        {'+
                '            "id": 82552,'+
                '            "type": "sale_order",'+
                '            "attributes": {'+
                '                "account_name": 7292,'+
                '                "invoice_id": 7292,'+
                '                "customer_authorized_by": null,'+
                '                "customer_authorized_date": null,'+
                '                "amount": 2472.39,'+
                '                "name": "S62501",'+
                '                "start_date": "2023-09-12 18:05:00",'+
                '                "price_list_id": 1,'+
                '                "shipping_id": 7292,'+
                '                "state": "draft",'+
                '                "customer_reference": null,'+
                '                "memo": null,'+
                '                "warehouse_id": "Mykla",'+
                '                "lines": ['+
                '                    {'+
                '                        "id": 1469334,'+
                '                        "type": "sale_order_line",'+
                '                        "attributes": {'+
                '                            "description": "[4179438] CPC Brush Soap",'+
                '                            "list_price": 5.7,'+
                '                            "sale_order_id": 82552,'+
                '                            "product_id": 5634,'+
                '                            "product_uom_qty": 1.0,'+
                '                            "start_date": "2023-09-12 18:05:00",'+
                '                            "total_price": 4.28,'+
                '                            "discount": 25.0,'+
                '                            "uom_name": "Units",'+
                '                            "qty_delivered": 0.0,'+
                '                            "qty_invoiced": 0.0,'+
                '                            "salesforce_identifier": null,'+
                '                            "loyalty_points": 0.0'+
                '                        }'+
                '                    },'+
                '                    {'+
                '                        "id": 1469335,'+
                '                        "type": "sale_order_line",'+
                '                        "attributes": {'+
                '                            "description": "[3586039] CPC Duo slijper",'+
                '                            "list_price": 5.13,'+
                '                            "sale_order_id": 82552,'+
                '                            "product_id": 6028,'+
                '                            "product_uom_qty": 4.0,'+
                '                            "start_date": "2023-09-12 18:05:00",'+
                '                            "total_price": 15.39,'+
                '                            "discount": 25.0,'+
                '                            "uom_name": "Units",'+
                '                            "qty_delivered": 0.0,'+
                '                            "qty_invoiced": 0.0,'+
                '                            "salesforce_identifier": null,'+
                '                            "loyalty_points": 0.0'+
                '                        }'+
                '                    }'+
                '                ],'+
                '                "tracking_reference": [],'+
                '                "template_id": null,'+
                '                "salesforce_identifier": null'+
                '            }'+
                '        }'+
                '    ]'+
                '}';

        SingleRequestMock mock = new SingleRequestMock(200, 'Complete', json, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/sale_order?offset=0&limit=2', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Order o = new Order(
                AccountId = acc.Id,
                Odoo_ID__c = 82552,
                Pricebook2Id = Test.getStandardPricebookId(),
                EffectiveDate = Date.today(),
                Status = 'Draft'
        );

        insert o;

        Test.startTest();
        System.enqueueJob(new OdooSalesOrderSyncQueuable(0,2));
        Test.stopTest();






    }
}