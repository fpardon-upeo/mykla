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
 * Created: 18/09/2023
 * Last Updated: 18/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooProductSyncQueueableTest {

    @TestSetup
    static void setup() {

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
        );
        update standardPricebook;

        Pricebook2 pb1 = new Pricebook2(Name = 'Test Pricebook 1', Odoo_ID__c = 151);
        Pricebook2 pb2 = new Pricebook2(Name = 'Test Pricebook 2', Odoo_ID__c = 152);
        insert new List<Pricebook2> {pb1, pb2};

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
                '            "id": 5850,'+
                '            "type": "product_product",'+
                '            "attributes": {'+
                '                "name": "Likami Facial Essential Serum 30ML",'+
                '                "owner": 2,'+
                '                "active": true,'+
                '                "display_url": "https://mykla15.test.dynapps.be/web/image/product.product/5850/image_1920",'+
                '                "external_id": "__export__.product_product_5850_5623f8ec",'+
                '                "code": null,'+
                '                "description": null,'+
                '                "family": ['+
                '                    "Creams"'+
                '                ],'+
                '                "cnk_code": "3675485",'+
                '                "type": "product",'+
                '                "uom_name": "Units",'+
                '                "list_price": 44.63,'+
                '                "available_qty": 66.0,'+
                '                "collection": null,'+
                '                "prices": {'+
                '                    "152": 44.63,'+
                '                    "151": 44.63'+
                '                }'+
                '            }'+
                '        },'+
                '        {'+
                '            "id": 5854,'+
                '            "type": "product_product",'+
                '            "attributes": {'+
                '                "name": "Likami Facial Intensive Hydrating Cream 50ML",'+
                '                "owner": 2,'+
                '                "active": true,'+
                '                "display_url": "https://mykla15.test.dynapps.be/web/image/product.product/5854/image_1920",'+
                '                "external_id": "__export__.product_product_5854_7ebb0e4b",'+
                '                "code": null,'+
                '                "description": null,'+
                '                "family": ['+
                '                    "Creams"'+
                '                ],'+
                '                "cnk_code": "3675493",'+
                '                "type": "product",'+
                '                "uom_name": "Units",'+
                '                "list_price": 36.36,'+
                '                "available_qty": 0.0,'+
                '                "collection": null,'+
                '                "prices": {'+
                '                    "152": 36.36,'+
                '                    "151": 36.36'+
                '                }'+
                '            }'+
                '        }'+
                '    ]'+
                '}';

        SingleRequestMock mock = new SingleRequestMock(
                200,
                'Complete',
                json,
                null
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/product?offset=0&limit=2', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

    }


    @IsTest
    static void testBehavior() {

        setup();
        Test.startTest();
        System.enqueueJob(new OdooProductSyncQueueable(0,2));
        Test.stopTest();

        List<Product2> products = [SELECT Id, Name, Odoo_ID__c FROM Product2];
        System.assertEquals(2, products.size());

    }
}