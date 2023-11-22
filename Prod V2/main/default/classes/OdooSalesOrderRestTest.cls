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
 * Created: 24/10/2023
 * Last Updated: 24/10/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooSalesOrderRestTest {
    @IsTest
    static void testBehavior() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"data": {"type": "sale_order", "ids": [86450]}}');
        req.requestURI = '/services/apexrest/OdooOrder';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        RestContext.response = res;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Odoo_ID__c = 135848;

        insert acc;

        Account shipping = new Account();
        shipping.Name = 'Test Account Shipping';
        shipping.Odoo_ID__c = 17042;

        insert shipping;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true,
                Odoo_ID__c = 1
        );

        Pricebook2 pb1 = new Pricebook2(Name = 'Test Pricebook 1', Odoo_ID__c = 132, IsActive = true);
        insert pb1;

        Product2 odooProduct = new Product2();
        odooProduct.Name = 'Test Product';
        odooProduct.Odoo_ID__c = 1534995;


        insert odooProduct;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = odooProduct.Id,
                UnitPrice = 100,
                IsActive = true
        );


        PricebookEntry pbe2 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = odooProduct.Id,
                UnitPrice = 300,
                IsActive = true
        );


        insert pbe;
        insert pbe2;

        String jsonString =
                '{'+
                        '    "data": {'+
                        '        "id": 86450,'+
                        '        "type": "sale_order",'+
                        '        "attributes": {'+
                        '            "account_name": 17042,'+
                        '            "invoice_id": 17042,'+
                        '            "customer_authorized_by": null,'+
                        '            "customer_authorized_date": null,'+
                        '            "amount": 664.53,'+
                        '            "name": "S64810",'+
                        '            "start_date": "2023-10-23 09:38:04",'+
                        '            "price_list_id": 133,'+
                        '            "shipping_id": 17042,'+
                        '            "state": "sale",'+
                        '            "customer_reference": null,'+
                        '            "memo": null,'+
                        '            "warehouse_id": "Mykla",'+
                        '            "lines": ['+
                        '                {'+
                        '                    "id": 1534995,'+
                        '                    "type": "sale_order_line",'+
                        '                    "attributes": {'+
                        '                        "description": "CPC Christmas 2023 Box Homme ",'+
                        '                        "list_price": 56.46,'+
                        '                        "sale_order_id": 86450,'+
                        '                        "product_id": 22061,'+
                        '                        "product_uom_qty": 3,'+
                        '                        "start_date": "2023-10-23 09:38:04",'+
                        '                        "total_price": 135.5,'+
                        '                        "discount": 20,'+
                        '                        "uom_name": "Units",'+
                        '                        "qty_delivered": 0,'+
                        '                        "qty_invoiced": 0,'+
                        '                        "salesforce_identifier": null,'+
                        '                        "loyalty_points": 0'+
                        '                    }'+
                        '                }'+
                        '            ],'+
                        '            "tracking_reference": ['+
                        '            ],'+
                        '            "template_id": 87,'+
                        '            "salesforce_identifier": null,'+
                        '            "pdf": "https://mykla-odoo-v15-a744342ab99e.deltablue.io/api/v1/documents/sale_order/938d57b9-fb13-45eb-ae2f-014743c1d2a4/86450"'+
                        '        }'+
                        '    }'+
                        '}';

        SingleRequestMock mockOrder = new SingleRequestMock(200, 'OK', jsonString, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:OdooSync/sale_order/86450', mockOrder);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        //Call the REST method to test

        Test.startTest();
        OdooSalesOrderRest.doPost();
        Test.stopTest();






    }
}