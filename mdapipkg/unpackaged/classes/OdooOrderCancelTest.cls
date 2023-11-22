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
 * Created: 24/10/2023
 * Last Updated: 24/10/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooOrderCancelTest {

    @TestSetup
    static void setup() {

        Account account = new Account();
        account.Name = 'Test Account';

        insert account;

        Order order = new Order();
        order.AccountId = account.Id;
        order.Status = 'Draft';
        order.EffectiveDate = Date.today();
        order.Description = 'Test Order';
        order.Odoo_ID__c = 1;

        insert order;

    }


    @IsTest
    static void testBehavior() {


        SingleRequestMock singleRequestMock = new SingleRequestMock(200, 'OK', '{"result": {"success": true}}', null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/sale_order/1', singleRequestMock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        List<OdooOrderCancel.RequestWrapper> requestList = new List<OdooOrderCancel.RequestWrapper>();
        OdooOrderCancel.RequestWrapper request = new OdooOrderCancel.RequestWrapper();
        request.order = 1;
        requestList.add(request);

        OdooOrderCancel.postPatchOrderToOdoo(requestList);
        Test.stopTest();


    }
}