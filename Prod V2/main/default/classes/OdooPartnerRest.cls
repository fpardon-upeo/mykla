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
 * Created: 30/08/2023
 * Last Updated: 30/08/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
/**
@Description: REST enabled class to handle Odoo Partner related requests

@Change Log:

@Dependencies:

@Test Classes:

*/
@RestResource(urlMapping='/OdooPartner')
global class OdooPartnerRest {

    @HttpPost
    global static void handleRequest(){


        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        res.addHeader('Content-Type', 'application/json');

        try {
            String body = (String) req.requestBody.toString();
            OdooCallback cb = OdooCallback.parse(body);

            System.debug('starting callback');

            Callout callout = Callout.prepareCallbackCallout(environment, 'Partner', cb.data.ids[0]);
            CalloutHandler calloutHandler = new CalloutHandler();
            HttpResponse response = calloutHandler.makeCallout(callout);

            System.debug('callback done');

            body = response.getBody();

            System.debug('body: ' + body);

            OdooPartner.Data p = OdooPartner.parsePartnerData(body);

            List<OdooPartner.Data> partners = new List<OdooPartner.Data>();
            partners.add(p);
            Map<Integer, String> results = OdooPartnerService.parsePartnerToAccount(partners, p.attributes.company_type);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(results));
        }
        catch(Exception e){
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }

        Webhook_Request__c wr = new Webhook_Request__c();
        wr.Body__c = req.requestBody.toString();
        wr.Response__c = res.responseBody.toString();
        wr.Type__c = 'POST';
        wr.Object__c = 'Partner';
        insert wr;

    }


}