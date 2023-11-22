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

public class OdooInvoiceSyncQueuable implements Queueable, Database.AllowsCallouts {

    public Integer offset;
    public Integer limiter = 100;
    public Boolean isSandbox;
    public String environment;
    public Integer maxOffset = 100000;

    /* Constructors */

    public OdooInvoiceSyncQueuable(Integer offSet, Integer limiter){
        this.offset = offSet;
        this.limiter = limiter;
        this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        this.environment = this.isSandbox ? 'Sandbox' : 'Production';
        this.maxOffset = Integer.valueOf(Sync_Setting__mdt.getInstance('Invoices_Orders').Max_Offset__c);
    }

    public void execute(QueueableContext context){
            System.debug('starting syncProducts');
            syncInvoices(offset, limiter);
    }

    public void syncInvoices(Integer offset, Integer limiter){

        Callout callout = Callout.prepareCallout(this.environment, 'Invoice', offset, limiter);

        //Make the callout and get the response
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);
        Integer statusCode = response.getStatusCode();
        System.debug('statusCode: ' + statusCode);
        Integer retryCount = 0;

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

        //If the response is 200, parse the response and upsert the products
        if(response.getStatusCode() == 200) {
            //System.debug('Response: ' + response.getBody());
            OdooAccountMove invoiceData = OdooAccountMove.parse(response.getBody());
            List<OdooAccountMove.Data> data = invoiceData.data;
            OdooInvoiceService.parseAccountMoveToInvoice(data);


            OdooAccountMove.Meta meta = invoiceData.meta;
            if(meta.offset <= maxOffset) {
                if (meta.offset + meta.limit_x < meta.total) {
                    system.debug('meta.offset: ' + meta.offset);
                    system.debug('meta.limit_x: ' + meta.limit_x);
                    system.debug('meta.total: ' + meta.total);
                    OdooInvoiceSyncQueuable sync = new OdooInvoiceSyncQueuable(meta.offset + meta.limit_x, meta.limit_x);
                    System.enqueueJob(sync);
                }
            }
        }
    }

}