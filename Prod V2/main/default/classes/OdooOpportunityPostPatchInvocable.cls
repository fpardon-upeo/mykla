/**
 * Created by fpardon on 20/09/2023.
 */

public with sharing class OdooOpportunityPostPatchInvocable {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Opportunity' Description='The Opportunity to send to Odoo')
        public Opportunity opportunity;
    }

    @InvocableMethod(Label='Post or Patch Opportunity to Odoo' Callout=true Description='Post or Patch Opportunity to Odoo' IconName='resource:odoo:top')
    public static void postPatchOrderToOdoo(List<RequestWrapper> requestWrappers) {
        for (RequestWrapper requestWrapper : requestWrappers) {
            OdooSaleOrderService.parseOpptyToSaleOrder(requestWrapper.opportunity);
        }
    }

}