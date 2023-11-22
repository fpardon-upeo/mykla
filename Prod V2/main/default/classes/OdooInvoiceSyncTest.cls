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
private class OdooInvoiceSyncTest {

    @TestSetup
    static void setup() {

        String json=		'{'+
                '    "meta": {'+
                '        "total": 1,'+
                '        "size": 1,'+
                '        "limit": 1,'+
                '        "offset": 0'+
                '    },'+
                '    "data": ['+
                '        {'+
                '            "id": 197125,'+
                '            "type": "account_move",'+
                '            "attributes": {'+
                '                "account_name": 133058,'+
                '                "total": 49.97,'+
                '                "tax": 8.67,'+
                '                "tax_excluded": 41.3,'+
                '                "amount_due": 0.0,'+
                '                "end_date": "2023-09-13",'+
                '                "name": "FSH/2023/06626",'+
                '                "start_date": "2023-09-13",'+
                '                "type": "out_invoice",'+
                '                "price_list_id": null,'+
                '                "sale_order_line_ids": ['+
                '                    1469826,'+
                '                    1469827,'+
                '                    1469828'+
                '                ],'+
                '                "shipping_id": 133058,'+
                '                "state": "posted",'+
                '                "payment_state": "in_payment",'+
                '                "customer_ref": "#25071",'+
                '                "invoice_lines": ['+
                '                    {'+
                '                        "id": 2223868,'+
                '                        "type": "account_move_line",'+
                '                        "attributes": {'+
                '                            "account_move_id": 197125,'+
                '                            "end_date": "2023-09-13",'+
                '                            "description": "[3968179] CPC Mascara Le VOLUMINEUX Noir",'+
                '                            "list_price": 20.65,'+
                '                            "product_id": 5958,'+
                '                            "quantity": 1.0,'+
                '                            "start_date": "2023-09-13",'+
                '                            "total_price": 20.65,'+
                '                            "discount": 0.0,'+
                '                            "sale_order_line_ids": ['+
                '                                1469826'+
                '                            ]'+
                '                        }'+
                '                    }'+
                '                ]'+
                '            }'+
                '        }'+
                '    ]'+
                '}';

        String startDate = String.valueOf(Date.today().addDays(-1));
        String endDate = String.valueOf(Date.today().addDays(1));
        json = json.replace('2023-09-13', startDate);
        json = json.replace('2023-09-13', endDate);

        SingleRequestMock mock = new SingleRequestMock(200, 'OK', json, null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/account_move?offset=0&limit=100', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);


    }


    @IsTest
    static void testBehavior() {

        setup();

        Account acc = new Account(Name = '133058', Odoo_ID__c = 133058);
        insert acc;

        Product2 prod = new Product2(Name = 'CPC Mascara Le VOLUMINEUX Noir', Odoo_ID__c = 5958);
        insert prod;

        Test.startTest();
        System.enqueueJob(new OdooInvoiceSyncQueuable(0, 100));
        Test.stopTest();

        List<Invoice__c> invoices = [SELECT Id, Name FROM Invoice__c];
        System.assertEquals(1, invoices.size());
        System.assertEquals('FSH/2023/06626', invoices[0].Name);

        List<Invoice_Line__c> invoiceLines = [SELECT Id, Name FROM Invoice_Line__c];
        System.assertEquals(1, invoiceLines.size());




    }
}