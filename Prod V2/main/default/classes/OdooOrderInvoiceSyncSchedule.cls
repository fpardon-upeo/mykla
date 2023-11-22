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
 * Created: 27/10/2023
 * Last Updated: 27/10/2023
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

global class OdooOrderInvoiceSyncSchedule implements Schedulable {

    global void execute(SchedulableContext SC) {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        AsyncOptions asyncOptions = new AsyncOptions();

        //Then Sync the Sales Orders
        System.enqueueJob(new OdooSalesOrderSyncQueuable(0, 100), asyncOptions);

        //Then Sync the Invoices
        System.enqueueJob(new OdooInvoiceSyncQueuable(0, 100), asyncOptions);

    }

}