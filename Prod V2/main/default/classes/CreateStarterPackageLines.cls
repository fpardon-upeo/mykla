/**
 * Created by fpardon on 25/09/2023.
 */

public without sharing class CreateStarterPackageLines {

    public class RequestWrapper {
        @InvocableVariable(Required=true Label='Opportunity' Description='The Opportunity for which to create the Starter Package Lines')
        public Opportunity opportunity;
        @InvocableVariable(Required=true Label='Package' Description='The Starter Package to create the Starter Package Lines from')
        public Package__c starterPackage;
    }


    @InvocableMethod(Label='Create Package Lines from Starter Package' Description='Create Package Lines from Starter Package')
    public static void createOLILines(List<RequestWrapper> requestWrappers) {
        for (RequestWrapper requestWrapper : requestWrappers) {
            createStarterPackageLines(requestWrapper.opportunity, requestWrapper.starterPackage);
        }
    }

    public static void createStarterPackageLines(Opportunity opp, Package__c starterPackage){

        System.debug('opp ' + opp);
        System.debug('starterPackage ' + starterPackage);

        Opportunity oppWithPricebook = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id];


        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice from PricebookEntry WHERE Pricebook2Id = :oppWithPricebook.Pricebook2Id];
        List<Package_Line__c> packageLines = [SELECT Id, Product__c, Price__c,Quantity__c from Package_Line__c WHERE Package__c = :starterPackage.Id AND External_Id__c != null AND Price_Book__c = :oppWithPricebook.Pricebook2Id];

        System.debug('pbEntries size ' + pricebookEntries.size());
        System.debug('packageLines size ' + packageLines.size());

        Map<String, String> productMap = new Map<String, String>();
        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        for(PricebookEntry pbe : pricebookEntries){
            productMap.put(pbe.Product2Id, pbe.Id);
            priceMap.put(pbe.Product2Id, pbe.UnitPrice);
        }

        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

        for(Package_Line__c pLine : packageLines){
            if(productMap.containsKey(pLine.Product__c)){
                System.debug('contains key');
                System.debug('pLine ' + pLine);
                System.debug('productMap.get(pLine.Product__c) ' + productMap.get(pLine.Product__c));
                System.debug('priceMap.get(pLine.Product__c) ' + priceMap.get(pLine.Product__c));
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id;
                oli.PricebookEntryId = productMap.get(pLine.Product__c);
                oli.Quantity = pLine.Quantity__c;
                oli.UnitPrice = priceMap.get(pLine.Product__c) != null ? priceMap.get(pLine.Product__c) : 0;
                oppLineItems.add(oli);
            } else {
                System.debug('does not contain key');
            }
        }
        
        System.debug('after loop, size of oppLineItems ' + oppLineItems.size());
        insert oppLineItems;
    }



}