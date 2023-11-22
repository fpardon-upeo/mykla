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
/**
@Description:

@Change Log:

@Dependencies:

@Test Classes:

*/

global class OdooSyncSchedule implements Schedulable{

    global void execute(SchedulableContext SC) {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        AsyncOptions asyncOptions = new AsyncOptions();

        System.enqueueJob(new OdooConfigSyncQueueable(), asyncOptions);
        OdooPriceListSync.getPriceLists();
        OdooLoyaltyProgramSync.getLoyaltyPrograms();

        //Then Sync the Products
        System.enqueueJob(new OdooProductSyncQueueable(0, 50), asyncOptions);

        //Then Sync the Template Lines
        System.enqueueJob(new OdooTemplateSyncQueueable(0, 1), asyncOptions);

        //Then Sync the Customers
        System.enqueueJob(new OdooPartnerSyncQueueable(0, isSandbox, environment, 'company'), asyncOptions);
        System.enqueueJob(new OdooPartnerSyncQueueable(0, isSandbox, environment, 'person'), asyncOptions);
    }




}