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

public with sharing class OdooPriceListSync {

    public static void getPriceLists(){
        // Get the price lists from Odoo
        // Get the price list items from Odoo
        // Update the price lists in Salesforce
        // Update the price list items in Salesforce

        //Get the environment
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';
        Integer offset = 0;
        Integer limiter = 200;


        Callout callout = Callout.prepareCallout(environment, 'Price_List', offset, limiter);

        //Make the callout and get the response
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);

        //If the response is 200, parse the response and upsert the products
        if(response.getStatusCode() == 200) {
            List<Pricebook2> pricebooks = new List<Pricebook2>();
            OdooPriceList odooPriceLists = OdooPriceList.parse(response.getBody());
            System.debug('odooPriceLists: ' + odooPriceLists);
            for(OdooPriceList.data priceList : odooPriceLists.data){
                Pricebook2 pricebook = new Pricebook2();
                if(priceList.attributes.name.contains('IAK')){
                    pricebook.Brand__c = 'i.am.klean';
                } else if (priceList.attributes.name.contains('CPC')){
                    pricebook.Brand__c = 'Cent Pur Cent';
                } else {
                    pricebook.Brand__c = '';
                }
                pricebook.Name = priceList.attributes.name;
                pricebook.IsActive = priceList.attributes.active;
                pricebook.Odoo_ID__c = priceList.id;
                pricebooks.add(pricebook);
            }
            upsert pricebooks Odoo_ID__c;
        }
    }

}