/**
 * Created by fpardon on 20/09/2023.
 */

public with sharing class OdooOrderCancel {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Odoo Id' Description='The Order Id to cancel in Odoo')
        public Integer order;
    }

    @InvocableMethod(Label='Cancel Order in Odoo' Callout=true Description='Cancel Order in Odoo' IconName='resource:odoo:top')
    public static void postPatchOrderToOdoo(List<RequestWrapper> requestWrappers) {
        for (RequestWrapper requestWrapper : requestWrappers) {
            OdooSaleOrderService.cancelOdooOrder(requestWrapper.order);
        }
    }

}