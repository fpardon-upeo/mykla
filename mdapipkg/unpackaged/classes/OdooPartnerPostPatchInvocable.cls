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

public with sharing class OdooPartnerPostPatchInvocable {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Partner Id' Description='POST or PATCH, depending on whether the record needs to be created or updated')
        public String operation;
        @InvocableVariable(Required=true Label='Account' Description='The Account to send to Odoo')
        public Account account;
    }

    @InvocableMethod(Label='Post or Patch Account to Odoo' Callout=true Description='Post or Patch Account to Odoo' IconName='resource:odoo:top')
    public static void postPatchAccountToOdoo(List<RequestWrapper> requestWrappers) {
        List<Account> accounts = new List<Account>();
        for (RequestWrapper requestWrapper : requestWrappers) {
            accounts.add(requestWrapper.account);
        }
        OdooPartnerService.parseAccountToPartner(accounts);
    }

}