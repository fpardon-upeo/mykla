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
private class OdooOpportunityPostPatchInvocableTest {

    @TestSetup
    static void setup() {

        Account a = new Account();
        a.Name = 'Test Account';
        a.Odoo_ID__c = 17042;
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
                IsActive = true,
                Odoo_ID__c = '21233-1'
        );


        insert pbe;
        insert pbe2;

        Opportunity o = new Opportunity();
        o.Name = 'Test Opportunity';
        o.AccountId = a.Id;
        o.Pricebook2Id = pb1.Id;
        o.StageName = 'New';
        o.CloseDate = Date.today();

        insert o;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = o.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 100;

        insert oli;





    }

    @IsTest
    static void testBehavior() {

        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(2, [SELECT COUNT() FROM PricebookEntry]);

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
                        '            "name": "Test Opportunity",'+
                        '            "start_date": "2023-10-23 09:38:04",'+
                        '            "price_list_id": 1,'+
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
                        '                        "product_id": 21233,'+
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
                        '            "salesforce_identifier": null,'+
                        '            "pdf": "https://mykla-odoo-v15-a744342ab99e.deltablue.io/api/v1/documents/sale_order/938d57b9-fb13-45eb-ae2f-014743c1d2a4/86450"'+
                        '        }'+
                        '    }'+
                        '}';

        SingleRequestMock mock = new SingleRequestMock(200, 'OK', jsonString, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/sale_order', mock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        List<OdooOpportunityPostPatchInvocable.RequestWrapper> requestWrappers = new List<OdooOpportunityPostPatchInvocable.RequestWrapper>();
        OdooOpportunityPostPatchInvocable.RequestWrapper requestWrapper = new OdooOpportunityPostPatchInvocable.RequestWrapper();
        requestWrapper.opportunity = [SELECT Id, Name, AccountId, Account.Odoo_ID__c, CloseDate, Pricebook2.Odoo_ID__c, Odoo_ID__C FROM Opportunity];
        requestWrappers.add(requestWrapper);

        OdooOpportunityPostPatchInvocable.postPatchOrderToOdoo(requestWrappers);
        Test.stopTest();






    }
}