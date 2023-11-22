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
 * Created: 14/09/2023
 * Last Updated: 14/09/2023
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

public class OdooSalesOrderSyncQueuable implements Queueable, Database.AllowsCallouts {

    public Integer offset;
    public Integer limiter = 100;
    public Boolean isSandbox;
    public String environment;
    public Integer maxOffset = 100000;

    /* Constructors */

    public OdooSalesOrderSyncQueuable(Integer offSet, Integer limiter){
        this.offset = offSet;
        this.limiter = limiter;
        this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        this.environment = this.isSandbox ? 'Sandbox' : 'Production';
        this.maxOffset = Integer.valueOf(Sync_Setting__mdt.getInstance('Invoices_Orders').Max_Offset__c);
    }

    public void execute(QueueableContext context){
            System.debug('starting syncOrders');
            syncOrders(offset, limiter);
    }

    public void syncOrders(Integer offset, Integer limiter){

        Callout callout = Callout.prepareCallout(this.environment, 'Sales_Order', offset, limiter);

        //Make the callout and get the response
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);

        Integer retryCount = 0;
        //If the response is 200, parse the response and upsert the products
        //Todo: add retry logic in case of 500 error, retry 3 times, then abort
        //After the third time create an error record

        Integer statusCode = response.getStatusCode();
        System.debug('statusCode: ' + statusCode);
        if (statusCode == 500) {
            while (statusCode == 500 && retryCount < 3) {
                System.debug('retryCount: ' + retryCount);
                System.debug('statusCode: ' + statusCode);
                response = calloutHandler.makeCallout(callout);
                statusCode = response.getStatusCode();
                retryCount++;
            } if (statusCode == 500) {
                System.debug('statusCode: ' + statusCode);
                System.debug('retryCount: ' + retryCount);
                //Create error record
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Error_Message__c = 'Sales Order Sync failed after 3 retries, last offset: ' + offset;
                errorLog.Object__c = 'Sales Order';
                insert errorLog;
            }
        }

        if (response.getStatusCode() == 200) {
            //System.debug('Response: ' + response.getBody());
            OdooSalesOrder orderData = OdooSalesOrder.parse(response.getBody());
            List<OdooSalesOrder.Data> data = orderData.data;
            OdooSaleOrderService.parseSaleOrdertoOrder(data, true);

            System.debug('meta: ' + orderData.meta.offset);
            System.debug('maxOffset: ' + maxOffset);
            OdooSalesOrder.Meta meta = orderData.meta;
            if (meta.offset <= maxOffset) {
                if (meta.offset + meta.limit_x < meta.total) {
                    system.debug('meta.offset: ' + meta.offset);
                    system.debug('meta.limit_x: ' + meta.limit_x);
                    system.debug('meta.total: ' + meta.total);
                    OdooSalesOrderSyncQueuable sync = new OdooSalesOrderSyncQueuable(meta.offset + meta.limit_x, meta.limit_x);
                    System.enqueueJob(sync);
                }
            } else {
                System.debug('done');
            }
        }
    }
}