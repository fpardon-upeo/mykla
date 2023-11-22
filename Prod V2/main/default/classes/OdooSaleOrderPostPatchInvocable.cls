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

public with sharing class OdooSaleOrderPostPatchInvocable {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Order' Description='The Order to send to Odoo')
        public Order order;
    }

    @InvocableMethod(Label='Post or Patch Order to Odoo' Callout=true Description='Post or Patch Order to Odoo' IconName='resource:odoo:top')
    public static void postPatchOrderToOdoo(List<RequestWrapper> requestWrappers) {
        for (RequestWrapper requestWrapper : requestWrappers) {
            OdooSaleOrderService.parseOrderToSaleOrder(requestWrapper.order);
        }
    }

}