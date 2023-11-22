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
 * Created: 19/09/2023
 * Last Updated: 19/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooLoyaltyProgramSyncTest {

    @TestSetup
    static void setup() {
        String json=
                '{'+
                '  "meta": {'+
                '    "total": 1,'+
                '    "size": 1,'+
                '    "limit": 1,'+
                '    "offset": 0'+
                '  },'+
                '  "data": ['+
                '    {'+
                '      "id": 1,'+
                '      "type": "loyalty_program",'+
                '      "attributes": {'+
                '        "name": "Spaarprogramma",'+
                '        "reward_ids": ['+
                '          {'+
                '            "id": 10382,'+
                '            "type": "loyalty_reward",'+
                '            "attributes": {'+
                '              "name": " CPC POS Luxe Bag Flower Collection Dream 22x17x16 (per 10)",'+
                '              "point_cost": 8.5,'+
                '              "minimum_points": 0,'+
                '              "reward_product_id": 22361'+
                '            }'+
                '          },'+
                '          {'+
                '            "id": 11409,'+
                '            "type": "loyalty_reward",'+
                '            "attributes": {'+
                '              "name": "CPC Mini Fixing Spray",'+
                '              "point_cost": 10.74,'+
                '              "minimum_points": 0,'+
                '              "reward_product_id": 7314'+
                '            }'+
                '          }'+
                '        ]'+
                '      }'+
                '    }'+
                '  ]'+
                '}';

        SingleRequestMock mock = new SingleRequestMock(
                200,
                'OK',
                json,
                null
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/loyalty_program?offset=0&limit=100', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

    }

    @IsTest
    static void testBehavior() {

        setup();

        Product2 product1 = new Product2(
                Name = 'CPC POS Luxe Bag Flower Collection',
                Odoo_ID__c = 22361
        );

        Product2 product2 = new Product2(
                Name = 'CPC Mini Fixing Spray',
                Odoo_ID__c = 7314
        );

        insert product1;
        insert product2;

        Test.startTest();
        OdooLoyaltyProgramSync.getLoyaltyPrograms();
        Test.stopTest();

    }
}