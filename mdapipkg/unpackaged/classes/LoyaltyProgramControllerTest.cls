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
private class LoyaltyProgramControllerTest {
    @TestSetup
    static void setup() {

        Loyalty_Program__c loyaltyProgram = new Loyalty_Program__c();
        loyaltyProgram.Name = 'Test Loyalty Program';
        loyaltyProgram.Odoo_Id__c = 1;

        insert loyaltyProgram;

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

        Loyalty_Program_Reward__c reward = new Loyalty_Program_Reward__c();
        reward.Name = 'Test Reward';
        reward.Odoo_ID__c = 1;
        reward.Loyalty_Program__c = loyaltyProgram.Id;
        reward.Product__c = odooProduct.Id;
        reward.Point_Cost__c = 100;
        reward.Quantity__c = 1;

        insert reward;


        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Loyaltypoints__c = 100;
        acc.Loyalty_Program__c = loyaltyProgram.Id;
        insert acc;

        Order order = new Order();
        order.AccountId = acc.Id;
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.Pricebook2Id = pricebookId;
        insert order;

    }

    @isTest
    static void testGetLoyaltyPoints(){
        Account acc = [SELECT Id, Loyaltypoints__c FROM Account WHERE Name = 'Test Account'];
        Order order = [SELECT Id, AccountId FROM Order WHERE AccountId = :acc.Id];
        Decimal loyaltyPoints = LoyaltyProgramController.getLoyaltyPoints(order.Id);
        System.assertEquals(100, loyaltyPoints);

    }

    @isTest
    static void testGetRewards(){
        Account acc = [SELECT Id, Loyaltypoints__c FROM Account WHERE Name = 'Test Account'];
        Order order = [SELECT Id, AccountId FROM Order WHERE AccountId = :acc.Id];
        List<Loyalty_Program_Reward__c> rewards = LoyaltyProgramController.getRewards(order.Id);
        System.assertEquals(1, rewards.size());
    }

    @isTest
    static void testSaveRewards(){
        Account acc = [SELECT Id, Loyaltypoints__c, Loyalty_Program__c FROM Account WHERE Name = 'Test Account'];
        Order order = [SELECT Id, AccountId FROM Order WHERE AccountId = :acc.Id];
        List<Loyalty_Program_Reward__c> rewards = [SELECT Id, Quantity__c, Minimum_Points__c, Point_Cost__c, Loyalty_Program__c, Product__c, Odoo_ID__c FROM Loyalty_Program_Reward__c WHERE Loyalty_Program__c = :acc.Loyalty_Program__c];
        System.assertEquals(1, rewards.size());
        LoyaltyProgramController.saveRewards(rewards, order.Id);

        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        System.assertEquals(1, orderItems.size());

    }
}