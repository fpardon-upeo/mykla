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
 * Created: 15/09/2023
 * Last Updated: 15/09/2023
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

global class PackageLineHandlerBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id, Product__r.Id, Package__r.Allowed_PriceList_Ids__c, Product__c, Package__c, Quantity__c, Odoo_ID__c FROM Package_Line__c WHERE Odoo_ID__c != null AND Product__r.Odoo_Id__c != null AND Package__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Package_Line__c> scope) {

        System.debug('scope: ' + scope.size());

        List<Package_Line__c> packageLines = new List<Package_Line__c>();
        List<String> productIds = new List<String>();
        for(Package_Line__c packageLine : scope){
            if(packageLine.Product__c != null && productIds.contains(packageLine.Product__c) == false){
                productIds.add(packageLine.Product__c);
            }
        }

        System.debug('productIds: ' + productIds.size());

        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Odoo_ID__c, UnitPrice FROM PricebookEntry WHERE Product2Id IN :productIds AND Pricebook2.Odoo_ID__c != null];

        System.debug('pricebookEntries: ' + pricebookEntries.size());

        for(Package_Line__c pLine : scope){
            for(PricebookEntry pbe : pricebookEntries){
                System.debug('pLine.Product__r.Id: ' + pLine.Product__r.Id);
                System.debug('pbe.Product2Id: ' + pbe.Product2Id);
                if(pLine.Product__r.Id == pbe.Product2Id){
                    System.debug('pLine.Package__r.Allowed_PriceList_Ids__c: ' + pLine.Package__r.Allowed_PriceList_Ids__c);
                    if(pLine.Package__r.Allowed_PriceList_Ids__c == null || pLine.Package__r.Allowed_PriceList_Ids__c.contains(String.valueOf(pbe.Pricebook2.Odoo_ID__c))) {
                        Package_Line__c newPackageLine = new Package_Line__c();
                        newPackageLine.Product__c = pLine.Product__c;
                        newPackageLine.Package__c = pLine.Package__c;
                        newPackageLine.Quantity__c = pLine.Quantity__c;
                        newPackageLine.Price__c = pbe.UnitPrice;
                        newPackageLine.External_Id__c = pLine.Odoo_ID__c + '-' + pbe.Id;
                        newPackageLine.Price_Book__c = pbe.Pricebook2Id;
                        packageLines.add(newPackageLine);
                    }
                }
            }
        }

        System.debug('packageLines: ' + packageLines.size());
        upsert packageLines External_Id__c;

    }

    global void finish(Database.BatchableContext BC) {

        List<Package_Price_Book__c> pPBooks = new List<Package_Price_Book__c>();

        List<Package__c> packs = [SELECT Id, Allowed_Pricelist_Ids__c, Odoo_Id__c from Package__c];

        for(Package__c pack : packs){
            if(pack.Allowed_Pricelist_Ids__c != null){
                List<String> plists = pack.Allowed_Pricelist_Ids__c.split(';');
                for(String pb : plists){
                    System.debug('pb ' +pb);
                    Package_Price_Book__c ppb = new Package_Price_Book__c();
                    ppb.Package__c = pack.Id;
                    ppb.Price_Book__r = new Pricebook2(Odoo_Id__c = Integer.valueOf(pb));
                    ppb.External_Id__c = pack.Odoo_Id__c + '-' + pb;
                    System.debug(ppb);
                    pPBooks.add(ppb);
                }
            }
        }

        upsert pPBooks External_Id__c;

    }



}