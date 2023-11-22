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
 * Created: 27/10/2023
 * Last Updated: 27/10/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class CreateStarterPackageOrderLinesTest {
    @TestSetup
    static void setup() {
        // Create a test account
        Account testAccount = new Account(
                Name = 'Test Account'
        );
        insert testAccount;

        //Create test Products, PriceBook and PriceBookEntries

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true,
                Odoo_ID__c = 1
        );

        Pricebook2 pb1 = new Pricebook2(Name = 'Test Pricebook 1', Odoo_ID__c = 152, IsActive = true);
        insert pb1;

        Product2 odooProduct = new Product2();
        odooProduct.Name = 'Test Product';
        odooProduct.Odoo_ID__c = 21233;

        insert odooProduct;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = odooProduct.Id,
                UnitPrice = 100,
                IsActive = true
        );

        PricebookEntry pbe2 = new PricebookEntry(
                Pricebook2Id = pb1.Id,
                Product2Id = odooProduct.Id,
                UnitPrice = 300,
                IsActive = true,
                Odoo_ID__c = '21233-1'
        );


        insert pbe;
        insert pbe2;

        //Create test Order

        Order o = new Order();
        o.AccountId = testAccount.Id;
        o.Pricebook2Id = pb1.Id;
        o.Status = 'Draft';
        o.EffectiveDate = Date.today();

        insert o;

        //Create test StarterPackage
        Package__c sp = new Package__c();
        sp.Name = 'Test Starter Package';

        insert sp;

        //Create test StarterPackageLine
        Package_Line__c pl = new Package_Line__c();
        pl.Package__c = sp.Id;
        pl.Product__c = odooProduct.Id;
        pl.Quantity__c = 1;
        pl.Price__c = 100;
        pl.Price_Book__c = pb1.Id;

        insert pl;
    }

    @isTest
    static void testCreatePackageLines(){

        Order o = [SELECT Id, Pricebook2Id FROM Order LIMIT 1];
        Package__c sp = [SELECT Id FROM Package__c LIMIT 1];

        CreateStarterPackageOrderLines.RequestWrapper rw = new CreateStarterPackageOrderLines.RequestWrapper();
        rw.order = o;
        rw.starterPackage = sp;

        List<CreateStarterPackageOrderLines.RequestWrapper> rwList = new List<CreateStarterPackageOrderLines.RequestWrapper>();
        rwList.add(rw);

        Test.startTest();
        CreateStarterPackageOrderLines.createOrderLines(rwList);
        Test.stopTest();

        List<OrderItem> oliList = [SELECT Id FROM OrderItem];
    }
}