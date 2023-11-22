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
 * Created: 31/08/2023
 * Last Updated: 31/08/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
/**
@Description: This class is used to sync products from Odoo to Salesforce.
It is a Queueable class that is called from the OdooProductSyncScheduler class.

@Change Log:
Date        Developer       Description
----------  --------------  --------------------------------------------------------------------
2021-08-31  Upeo        Initial Creation
2021-09-01  Upeo        Added callout to Odoo to get products

@Dependencies:
OdooProduct.cls
Callout.cls
CalloutHandler.cls
Odoo_Endpoint_Config__mdt
DMLHandler.cls

@Test Classes:

*/

public class OdooProductSyncQueueable implements Queueable, Database.AllowsCallouts{

    /* Class Variables */

    public Integer offset;
    public Integer limiter = 100;
    public Boolean isSandbox;
    public String environment;

    /* Constructors */

    public OdooProductSyncQueueable(Integer offSet, Integer limiter){
        this.offset = offSet;
        this.limiter = limiter;
        this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        this.environment = this.isSandbox ? 'Sandbox' : 'Production';
    }

    /* Methods */

    public void execute(QueueableContext context){
        try{
            System.debug('starting syncProducts');
            syncProducts(offset, limiter);
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }

    /**
      * @Description: This method is used to sync products from Odoo to Salesforce.
      * The callout uses the Odoo_Endpoint_Config__mdt custom metadata type to get the endpoint and method to use.
      * The response is then parsed and the products are upserted to Salesforce.
      * Error handling is done in the CalloutHandler class.
      * @param offset  Integer offset
      * @param limiter Integer limiter
      * @Return: void
    */

    public void syncProducts(Integer offset, Integer limiter){

        //Prepare the callout
        Callout callout = Callout.prepareCallout(this.environment, 'Product', offset, limiter);

        //Make the callout and get the response
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);

        //If the response is 200, parse the response and upsert the products
        if(response.getStatusCode() == 200) {
            OdooProduct productData = OdooProduct.parse(response.getBody());
            parseOdooProducts(productData);
            System.debug('parsed products: ' + productData.data.size());
            OdooProduct.meta meta = productData.meta;
            if(meta.offset + meta.limit_x < meta.total){
                system.debug('meta.offset: ' + meta.offset);
                system.debug('meta.limit_x: ' + meta.limit_x);
                system.debug('meta.total: ' + meta.total);
                OdooProductSyncQueueable sync = new OdooProductSyncQueueable(meta.offset + limiter, meta.limit_x);
                System.enqueueJob(sync);
                System.debug('calling next syncProducts');
            }
        }
    }

    /**
      * @Description: This method is used to parse the response from Odoo and upsert the products to Salesforce.
      * DML Errors are handled in the DMLHandler class and are logged as Error_Log__c records.
      * @param productData  OdooProduct productData
      * @Return: void
    */

    public void parseOdooProducts(OdooProduct productData){

        List<Product2> products = new List<Product2>();
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        String standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;

        for(OdooProduct.Data product : productData.data){
            Product2 p = new Product2();
            p.Name = product.attributes.name;
            p.ProductCode = product.attributes.cnk_code;
            //p.StockKeepingUnit  = String.valueOf(product.id);
            p.Description = product.attributes.description;
            p.IsActive = product.attributes.active;
            p.Odoo_ID__c = product.id;
            p.Available_stock__c = product.attributes.available_qty;
            p.Retail_Price_ex_VAT__c = product.attributes.list_price;
            //p.Odoo_Last_Updated__c = product.write_date;
            //p.Odoo_Sync_Status__c = 'Synced';
            products.add(p);
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = standardPricebookId;
            pbe.Product2 = new Product2(Odoo_ID__c = product.id);
            pbe.UnitPrice = product.attributes.list_price;
            //Round UnitPrice to 2 decimals
            pbe.UnitPrice = pbe.UnitPrice.setScale(2);
            pbe.Odoo_ID__c = product.id+'-standard';
            pbe.IsActive = product.attributes.active;
            standardPricebookEntries.add(pbe);
        }

        Schema.SObjectField pId = Product2.fields.Odoo_ID__c;
        Schema.SObjectField pbId = PricebookEntry.fields.Odoo_ID__c;
        DMLHandler.upsertRecords(pId, products);
        DMLHandler.upsertRecords(pbId, standardPricebookEntries);

        System.debug('parsed products: ' + products.size());
        System.debug('parsed pricebook entries: ' + standardPricebookEntries.size());

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();


        //Loop through the retrieved result again and create price book entries

        for(OdooProduct.Data product : productData.data){
            if(product.attributes.active == true) {
                for (String pbIdOdoo : product.attributes.prices.keySet()) {
                    PricebookEntry pbe = new PricebookEntry();
                    pbe.Pricebook2 = new Pricebook2(Odoo_ID__c = Integer.valueOf(pbIdOdoo));
                    pbe.Product2 = new Product2(Odoo_ID__c = product.id);
                    pbe.UnitPrice = product.attributes.prices.get(pbIdOdoo).setScale(2);
                    pbe.Odoo_ID__c = product.id + '-' + pbIdOdoo;
                    pbe.IsActive = product.attributes.active;
                    pricebookEntries.add(pbe);
                }
            }
        }

        System.debug('parsed pricebook entries: ' + pricebookEntries.size());

        Schema.SObjectField pbId2 = PricebookEntry.fields.Odoo_ID__c;
        DMLHandler.upsertRecords(pbId2, pricebookEntries);

    }
}