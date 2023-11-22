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
/**
@Description:

@Change Log:

@Dependencies:

@Test Classes:

*/

@IsTest
private class OdooPriceListSyncTest {

    @TestSetup
    static void setup() {

        String json=		'{'+
                '    "meta": {'+
                '        "total": 70,'+
                '        "size": 1,'+
                '        "limit": 1,'+
                '        "offset": 0'+
                '    },'+
                '    "data": ['+
                '        {'+
                '            "id": 152,'+
                '            "type": "product_pricelist",'+
                '            "attributes": {'+
                '                "name": "IAK Modules 2023 50%",'+
                '                "active": true'+
                '            }'+
                '        }'+
                '    ]'+
                '}';

        SingleRequestMock mock = new SingleRequestMock(
                200,
                'complete',
                json,
                null
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/product_pricelist?offset=0&limit=200', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

    }

    @IsTest
    static void testSync() {

        setup();

        Test.startTest();

        OdooPriceListSync.getPriceLists();

        Test.stopTest();

        List<Pricebook2> pricebooks = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'IAK Modules 2023 50%'];
        System.assertEquals(1, pricebooks.size());
        System.assertEquals('IAK Modules 2023 50%', pricebooks[0].Name);

    }

}