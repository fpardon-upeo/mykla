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
 * Created: 8/09/2023
 * Last Updated: 8/09/2023
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
@RestResource(urlMapping='/OdooOrder')
global class OdooSalesOrderRest {

        @HttpPost
        global static void doPost() {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String environment = isSandbox ? 'Sandbox' : 'Production';

            res.addHeader('Content-Type', 'application/json');

            try {
                String body = (String) req.requestBody.toString();
                OdooCallback cb = OdooCallback.parse(body);

                Callout callout = Callout.prepareCallbackCallout(environment, 'Sales_Order', cb.data.ids[0]);
                CalloutHandler calloutHandler = new CalloutHandler();
                HttpResponse response = calloutHandler.makeCallout(callout);

                body = response.getBody();

                OdooSalesOrder.Data o = OdooSalesOrder.parseOrderData(body);
                System.debug('Order: ' + o);

                Integer pricebookId = o.attributes.price_list_id;
                try{
                    Order oldOrder = [SELECT Id, Pricebook2.Odoo_ID__c FROM Order WHERE Odoo_Id__c = : Integer.valueOf(cb.data.ids[0]) LIMIT 1];
                    pricebookId = Integer.valueOf(oldOrder.Pricebook2.Odoo_ID__c);
                } catch(Exception e){
                    System.debug('Error: ' + e.getMessage());
                }

                o.attributes.price_list_id = pricebookId;

                List<OdooSalesOrder.Data> orderData = new List<OdooSalesOrder.Data>();
                orderData.add(o);
                OdooSalesOrderReturn returnValue = OdooSaleOrderService.parseSaleOrdertoOrder(orderData, false);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(returnValue));
                System.debug('Results: ' + res.responseBody);
            }
            catch(Exception e){
                System.debug('Error: ' + e.getMessage());
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(e.getMessage());
            }

            Webhook_Request__c wr = new Webhook_Request__c();
            wr.Body__c = req.requestBody.toString();
            wr.Response__c = res.responseBody.toString();
            wr.Type__c = 'POST';
            wr.Object__c = 'Order';
            insert wr;



        }



}