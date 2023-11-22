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

public with sharing class OdooPartnerContactPostPatchInvocable {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Contact' Description='The Contact to send to Odoo')
        public Contact contact;
    }

    @InvocableMethod(Label='Post or Patch Contact to Odoo' Callout=true Description='Post or Patch Contact to Odoo' IconName='resource:odoo:top')
    public static void postPatchContactToOdoo(List<RequestWrapper> requestWrappers) {
        List<Contact> contacts = new List<Contact>();
        for (RequestWrapper requestWrapper : requestWrappers) {
            contacts.add(requestWrapper.contact);
        }
        OdooPartnerService.parseContactToPartner(contacts);
    }

}