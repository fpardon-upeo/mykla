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
 * Created: 24/10/2023
 * Last Updated: 24/10/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooPartnerRestTest {
    @IsTest
    static void testBehavior() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"data": {"type": "partner", "ids": [135848]}}');
        req.requestURI = '/services/apexrest/OdooPartner';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        RestContext.response = res;

        String jsonString =

                '{'+
                        '    "data": {'+
                        '        "id": 135848,'+
                        '        "type": "res_partner",'+
                        '        "attributes": {'+
                        '            "name": "Athletic Greens",'+
                        '            "parent_odoo": null,'+
                        '            "street": "135 Chaussée de Ninove",'+
                        '            "city": "Molenbeek-Saint-Jean",'+
                        '            "postal_code": "1080",'+
                        '            "country_iso_code": "BE",'+
                        '            "description_html": null,'+
                        '            "email": "frederik@pardonder.com",'+
                        '            "mobile": null,'+
                        '            "phone": "+3236051208",'+
                        '            "website": null,'+
                        '            "language": "en_US",'+
                        '            "pricelist_odoo_id": 45,'+
                        '            "title": null,'+
                        '            "vat": "BE0480501178",'+
                        '            "company_type": "company",'+
                        '            "type": "contact",'+
                        '            "child_ids": ['+
                        '            ],'+
                        '            "salesforce_identifier": "0012600002Cwm1GAAR",'+
                        '            "ranking": null,'+
                        '            "labels": ['+
                        '            ],'+
                        '            "distribution_channel": "B2B",'+
                        '            "sub_distribution_channel": "Pharma",'+
                        '            "sales_person": null,'+
                        '            "fiscal_position": 1,'+
                        '            "loyalty_points": 0,'+
                        '            "disable_loyalty_points": false,'+
                        '            "delivery_method": null,'+
                        '            "sale_order_on_invoice_line": false,'+
                        '            "client_support": null,'+
                        '            "start": null,'+
                        '            "end": null,'+
                        '            "active": true,'+
                        '            "loyalty_program_ids": ['+
                        '            ],'+
                        '            "prospect": true,'+
                        '            "invoicing_criteria_id": null'+
                        '        }'+
                        '    }'+
                        '}';

        SingleRequestMock mockAccount = new SingleRequestMock(200, 'OK', jsonString, null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:OdooSync/partner/135848', mockAccount);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        //Call the REST method to test
        OdooPartnerRest.handleRequest();






    }
}