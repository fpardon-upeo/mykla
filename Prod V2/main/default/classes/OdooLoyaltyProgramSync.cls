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
 * Created: 18/09/2023
 * Last Updated: 18/09/2023
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

public with sharing class OdooLoyaltyProgramSync {

    public static void getLoyaltyPrograms() {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';
        Integer offset = 0;
        Integer limiter = 100;



        Callout callout = Callout.prepareCallout(environment, 'Loyalty_Program', offset, limiter);

        //Make the callout and get the response
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);
        System.debug(response);

        List<Loyalty_Program__c> loyaltyPrograms = new List<Loyalty_Program__c>();
        List<Loyalty_Program_Reward__c> loyaltyProgramRewards = new List<Loyalty_Program_Reward__c>();

        //Parse the response
        if(response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            OdooLoyaltyProgram loyaltyProgram = OdooLoyaltyProgram.parse(responseBody);
            System.debug(loyaltyProgram);
            for(OdooLoyaltyProgram.Data data : loyaltyProgram.data) {
                Loyalty_Program__c loyaltyProgramRecord = new Loyalty_Program__c();
                loyaltyProgramRecord.Name = data.attributes.name;
                loyaltyProgramRecord.Odoo_Id__c = data.id;
                loyaltyPrograms.add(loyaltyProgramRecord);
                System.debug('data: ' + data.attributes);
                for(OdooLoyaltyProgram.Reward reward : data.attributes.reward_ids) {
                    Loyalty_Program_Reward__c loyaltyProgramReward = new Loyalty_Program_Reward__c();
                    loyaltyProgramReward.Name = reward.attributes.name.left(80);
                    loyaltyProgramReward.Odoo_Id__c = reward.id;
                    loyaltyProgramReward.Loyalty_Program__r = new Loyalty_Program__c(Odoo_Id__c = data.id);
                    loyaltyProgramReward.Point_Cost__c = reward.attributes.point_cost;
                    loyaltyProgramReward.Minimum_Points__c = reward.attributes.minimum_points;
                    loyaltyProgramReward.Product__r = new Product2(Odoo_ID__c = reward.attributes.reward_product_id);
                    loyaltyProgramRewards.add(loyaltyProgramReward);
                }
            }

            Schema.SObjectField lpId = Loyalty_Program__c.Fields.Odoo_ID__c;
            Schema.SObjectField lprId = Loyalty_Program_Reward__c.Fields.Odoo_ID__c;

            List<Database.UpsertResult> loyaltyUpserts = DMLHandler.upsertRecordsWithReturn(lpId, loyaltyPrograms);
            List<Database.UpsertResult> rewardUpserts = DMLHandler.upsertRecordsWithReturn(lprId, loyaltyProgramRewards);
        }
    }

}