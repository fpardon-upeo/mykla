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
private class OdooTemplateSyncTest {

    @IsTest
    static void testBehavior() {


        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
        );
        update standardPricebook;

        Product2 p1 = new Product2(Name = 'Test Product 1', Odoo_ID__c = 5955);
        Product2 p2 = new Product2(Name = 'Test Product 2', Odoo_ID__c = 5625);

        insert p1;
        insert p2;

        PricebookEntry pbe1 = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = p1.Id,
                UnitPrice = 100,
                IsActive = true
        );

        PricebookEntry pbe2 = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = p2.Id,
                UnitPrice = 200,
                IsActive = true
        );

        insert pbe1;
        insert pbe2;

        Pricebook2 pb1 = new Pricebook2(Name = 'Test Pricebook 1', Odoo_ID__c = 150);
        insert pb1;

        PricebookEntry pbe3 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = p1.Id,
                UnitPrice = 100,
                IsActive = true
        );

        PricebookEntry pbe4 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = p2.Id,
                UnitPrice = 200,
                IsActive = true
        );

        insert pbe3;
        insert pbe4;

        String json=
                '{'+
                        '    "meta": {'+
                        '        "total": 1,'+
                        '        "size": 1,'+
                        '        "limit": 1,'+
                        '        "offset": 0'+
                        '    },'+
                        '    "data": ['+
                        '        {'+
                        '            "id": 2,'+
                        '            "type": "sale_order_template",'+
                        '            "attributes": {'+
                        '                "name": "CPC Accessoires",'+
                        '                "validation_days": 0,'+
                        '                "template_line_ids": ['+
                        '                    {'+
                        '                        "id": 169,'+
                        '                        "type": "sale_order_template_line",'+
                        '                        "attributes": {'+
                        '                            "product_id": 5955,'+
                        '                            "name": "[4128112]  CPC Make Up Tas (Klein)",'+
                        '                            "uom_qty": 2.0'+
                        '                        }'+
                        '                    },'+
                        '                    {'+
                        '                        "id": 177,'+
                        '                        "type": "sale_order_template_line",'+
                        '                        "attributes": {'+
                        '                            "product_id": 5625,'+
                        '                            "name": "[4179370] CPC Blender (Groot)",'+
                        '                            "uom_qty": 2.0'+
                        '                        }'+
                        '                    }'+
                        '                ],'+
                        '                "package_type": "year",'+
                        '                "allowed_pricelist_ids": ['+
                        '                    150'+
                        '                ],'+
                        '                "date_from": "2023-08-29",'+
                        '                "date_to": "2023-09-08"'+
                        '            }'+
                        '        }'+
                        '    ]'+
                        '}';

        String dateFrom = String.valueOf(Date.today().addDays(-1));
        String dateTo = String.valueOf(Date.today().addDays(1));
        System.debug('dateFrom: ' + dateFrom);
        System.debug('dateTo: ' + dateTo);

        json = json.replace('2023-08-29', dateFrom);
        json = json.replace('2023-09-08', dateTo);

        SingleRequestMock mock = new SingleRequestMock(
                200,
                'OK',
                json,
                null
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/sale_order_template?offset=0&limit=100', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        System.enqueueJob(new OdooTemplateSyncQueueable(0, 100));
        Test.stopTest();

        List<Package__c> packages = [SELECT Id, Name, Package_Type__c FROM Package__c WHERE Name = 'CPC Accessoires'];

        List<Package_Line__c> packageLines = [SELECT Id, Name, Product__c, Quantity__c FROM Package_Line__c WHERE Package__c = :packages[0].Id];






    }
}