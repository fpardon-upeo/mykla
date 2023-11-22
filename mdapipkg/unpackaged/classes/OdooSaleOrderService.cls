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

public without sharing class OdooSaleOrderService {

    public static void parseOrderToSaleOrder(Order sOrder){

        OdooSalesOrderPost odooSalesOrder = new OdooSalesOrderPost();
        OdooSalesOrderPost.Data data = mapOrderToSaleOrder(sOrder);
        odooSalesOrder.data = data;
        //System.debug('odooSalesOrder: ' + odooSalesOrder);

        String responseString = '';

        if(sOrder.Odoo_ID__c == null){
            responseString = postOrderToOdoo(odooSalesOrder);
        }else{
            responseString = patchOrderToOdoo(odooSalesOrder);
        }

    }

    public static void cancelOdooOrder(Integer odooId){
        OdooSalesOrderPost odooSalesOrder = new OdooSalesOrderPost();
        OdooSalesOrderPost.Data odooSalesOrderData = new OdooSalesOrderPost.Data();
        OdooSalesOrderPost.Attributes attributes = new OdooSalesOrderPost.Attributes();
        odooSalesOrderData.type = 'sale_order';
        odooSalesOrderData.id = (Integer) odooId;
        attributes.state = 'cancel';
        attributes.lines = new List<OdooSalesOrderPost.OrderLines>();
        odooSalesOrderData.attributes = attributes;
        odooSalesOrder.data = odooSalesOrderData;

        //System.debug('odooSalesOrderData: ' + odooSalesOrderData);
        //System.debug('odooSalesOrder: ' + odooSalesOrder);
        String body = JSON.serialize(odooSalesOrder, true);

        System.debug('body: ' + body);

        Callout callout = Callout.preparePatchCallout('sale_order', body, odooId);

        CalloutHandler ch = new CalloutHandler();
        HttpResponse res = ch.makeCallout(callout);

        //System.debug('res: ' + res.getBody());



    }

    public static void parseOpptyToSaleOrder(Opportunity opp){

        OdooSalesOrderPost odooSalesOrder = new OdooSalesOrderPost();
        OdooSalesOrderPost.Data data = mapOpptyToSalesOrder(opp);
        odooSalesOrder.data = data;
        //System.debug('odooSalesOrder: ' + odooSalesOrder);

        String responseString = '';

        if(opp.Odoo_ID__c == null){
            responseString = postOpptyToOdoo(odooSalesOrder);
        }else{
            responseString = patchOpptyToOdoo(odooSalesOrder);
        }

    }

    public static OdooSalesOrderReturn parseSaleOrdertoOrder(List<OdooSalesOrder.Data> odooSalesOrders, Boolean isHistoricalOrder){

        List<Order> orders = new List<Order>();
        List<OrderItem> orderLines = new List<OrderItem>();
        List<Invoice__c> invoices = new List<Invoice__c>();
        List<Invoice_Line__c> invoiceLines = new List<Invoice_Line__c>();

        Map<Integer, String> odooIdToSalesforceId = new Map<Integer, String>();
        Boolean isSandBox = UserInfo.getOrganizationId().startsWith('00D');
        String environment = isSandBox == true ? 'Sandbox' : 'Production';

        Schema.SObjectField oId = Order.Fields.Odoo_ID__c;
        Schema.SObjectField oliId = OrderItem.Fields.Odoo_ID__c;


        for(OdooSalesOrder.Data odooSalesOrder : odooSalesOrders){
            //System.debug('odooSalesOrder: ' + odooSalesOrder);
            orders.add(mapSaleOrderToOrder(odooSalesOrder, isHistoricalOrder));
            Date orderDate = Date.valueOf(odooSalesOrder.attributes.start_date);
            Integer orderPriceBook = odooSalesOrder.attributes.price_list_id;
            //System.debug('orderPriceBook: ' + orderPriceBook);
            //Only add if the orderDate is within the last two years
            //System.debug(orderDate.year());
            //System.debug(Date.today().year());
            if(odooSalesOrder.attributes.lines != null && orderDate.year() >= Date.today().year() - 1){
                orderLines.addAll(mapSaleOrderLinesToOrderLines(odooSalesOrder.attributes.lines, orderPriceBook, isHistoricalOrder));
            }
        }
        System.debug('orders: ' + orders.size());
        System.debug('orderLines: ' + orderLines.size());

        List<Decimal> duplicateOrderIds = new List<Decimal>();
        List<Decimal> orderIds = new List<Decimal>();
        for(Order order : orders){
            if(orderIds.contains(order.Odoo_ID__c)) {
                duplicateOrderIds.add(order.Odoo_ID__c);
            }
        }

        System.debug('duplicateOrderIds: ' + duplicateOrderIds);
        System.debug('orderIds: ' + orderIds);

        integer successCount = 0;
        integer errorCount = 0;

        //Upsert the accounts
        List<Database.UpsertResult> orderUpserts = DMLHandler.upsertRecordsWithReturn(oId, orders);
        Map<Integer, String> orderIdMap = OdooPartnerService.parseDMLResults(orderUpserts, orders);
        for(Database.UpsertResult order : orderUpserts){
            //System.debug('order: ' + order);
            if(order.isSuccess()){
                successCount++;
            }else{
                errorCount++;
                System.debug('order: ' + order.getErrors());
            }
        }

        System.debug('successCount: ' + successCount);
        System.debug('errorCount: ' + errorCount);

        //Upsert the contacts
        List<Database.UpsertResult> orderLineUpserts = DMLHandler.upsertRecordsWithReturn(oliId, orderLines);
        Map<Integer, String> orderLineIdMap = OdooPartnerService.parseDMLResults(orderLineUpserts, orderLines);



        for(Database.UpsertResult orderLine : orderLineUpserts){
            //System.debug('orderLine: ' + orderLine);
        }

        OdooSalesOrderReturn odooReturn = new OdooSalesOrderReturn();
        OdooSalesOrderReturn.Data data = new OdooSalesOrderReturn.Data();

        //Return the map of Odoo Ids to Salesforce Ids. For every key in the returned map, created a nested map that contains the Odoo Ids of the Order Lines and the Salesforce Ids of the Order Lines
        for(Integer key : orderIdMap.keySet()){
            Map<String, String> orderLineMap = new Map<String, String>();
            for(OrderItem orderLine : orderLines){
                if(orderLine.Order.Odoo_ID__c == key){
                    orderLineMap.put(String.valueOf(orderLine.Odoo_ID__c), orderLine.Id);
                }
            }
            data.order_id = String.valueOf(key);
            data.salesforce_identifier = orderIdMap.get(key);
            data.order_lines = orderLineMap;
            odooIdToSalesforceId.put(key, orderIdMap.get(key));
            odooIdToSalesforceId.put(key, JSON.serialize(orderLineMap));
        }

        odooReturn.data = data;
        return odooReturn;

    }

    public static Order mapSaleOrderToOrder(OdooSalesOrder.Data odooSalesOrder, Boolean isHistoricalOrder){

        System.debug('odooSalesOrder price_list_id: ' + odooSalesOrder.attributes.price_list_id);

        Order order = new Order();
        order.Account = new Account(Odoo_ID__c = odooSalesOrder.attributes.shipping_id);
        order.EffectiveDate = Date.valueOf(odooSalesOrder.attributes.start_date);
        order.Pricebook2 = isHistoricalOrder == false || odooSalesOrder.attributes.price_list_id == null ? new Pricebook2 (Odoo_ID__c = odooSalesOrder.attributes.price_list_id): new Pricebook2 (Odoo_ID__c = 9999);
        order.Shipping_ID__r = new Account(Odoo_ID__c = odooSalesOrder.attributes.shipping_id);
        order.Customer_Reference__c = odooSalesOrder.attributes.customer_reference;
        order.Odoo_ID__c = odooSalesOrder.Id;
        order.Warehouse_ID__c = odooSalesOrder.attributes.warehouse_id;
        order.Invoice_To__r = odooSalesOrder.attributes.invoice_id != null ? new Account(Odoo_ID__c = odooSalesOrder.attributes.invoice_id): null;
        order.Tracking_Reference__c = odooSalesOrder.attributes.tracking_reference != null && odooSalesOrder.attributes.tracking_reference.size() > 0  ? odooSalesOrder.attributes.tracking_reference[0] : null;
        order.Status = 'Draft';
        order.Odoo_Order_Nbr__c = odooSalesOrder.attributes.name;
        order.Order_Total__c = odooSalesOrder.attributes.amount;
        order.Order_Status__c = odooSalesOrder.attributes.state;
        System.debug('order = '+ order);
        System.debug('order.Odooid = '+ order.Odoo_ID__c);

        return order;
    }

    public static List<OrderItem> mapSaleOrderLinesToOrderLines(List<OdooSalesOrder.OrderLines> odooSalesOrderLines, Integer orderPriceBook, Boolean isHistoricalOrder){


        //System.debug('orderPriceBook: ' + orderPriceBook);
        //System.debug('odooSalesOrderLines: ' + odooSalesOrderLines);
        //System.debug('isHistoricalOrder: ' + isHistoricalOrder);

        List<OrderItem> orderLines = new List<OrderItem>();
        String pricebookAsString = String.valueOf(orderPriceBook);
        if(isHistoricalOrder == true){
            pricebookAsString = 'standard';
        }

        for(OdooSalesOrder.OrderLines sOLine : odooSalesOrderLines){
            OrderItem orderLine = new OrderItem();
            orderLine.Order = new Order(Odoo_ID__c = sOLine.attributes.sale_order_id);
            orderLine.Product2 = new Product2(Odoo_ID__c = sOLine.attributes.product_id);
            orderLine.Quantity = Integer.valueOf(sOLine.attributes.product_uom_qty);
            orderLine.Quantity_Delivered__c = Integer.valueOf(sOLine.attributes.qty_delivered);
            orderLine.Quantity_Invoiced__c = Integer.valueOf(sOLine.attributes.qty_invoiced);
            orderLine.UnitPrice = sOLine.attributes.list_price;
            orderLine.Loyalty_Points__c = Integer.valueOf(sOLine.attributes.loyalty_points);
            //orderLine.TotalPrice = sOLine.attributes.total_price;
            orderLine.Discount__c = sOLine.attributes.discount;
            orderLine.Loyalty_Points__c = Integer.valueOf(sOLine.attributes.loyalty_points);
            orderLine.Description = sOLine.attributes.description;
            //orderLine.Id = sOLine.attributes.salesforce_identifier != null ? sOLine.attributes.salesforce_identifier : null;
            orderLine.ServiceDate = Date.valueOf(sOLine.attributes.start_date);
            orderLine.Odoo_iD__c = sOLine.Id;
            orderLine.PricebookEntry = new PricebookEntry(Odoo_ID__c = String.valueOf(sOLine.attributes.product_id) + '-' +pricebookAsString);
            orderLines.add(orderLine);
        }

        return orderLines;

    }

    public static OdooSalesOrderPost.Data mapOpptyToSalesOrder(Opportunity opp){

        OdooSalesOrderPost.Data odooSalesOrderData = new OdooSalesOrderPost.Data();
        OdooSalesOrderPost.Attributes attributes = new OdooSalesOrderPost.Attributes();

        Opportunity opportunity = [SELECT Id, Name, AccountId, Account.Odoo_ID__c, CloseDate, Pricebook2.Odoo_ID__c, Odoo_ID__C, Description FROM Opportunity WHERE Id = :opp.Id];
        List<OpportunityLineItem> oppLines = [SELECT Id, Odoo_Id__c, Discount, Product2.Odoo_ID__c, OpportunityId, PricebookEntry.Odoo_ID__c, Quantity, UnitPrice, TotalPrice, Description FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

        Account acc = [SELECT Id, Odoo_ID__c FROM Account WHERE Id = :opportunity.AccountId];
        List<OdooSalesOrderPost.OrderLines> orderLineList = new List<OdooSalesOrderPost.OrderLines>();

        if(opp.Odoo_ID__c == null) {
            odooSalesOrderData.type = 'sale_order';
            attributes.name = opportunity.Name;
            attributes.account_name = (Integer) acc.Odoo_ID__c;
            attributes.start_date = String.valueOf(opportunity.CloseDate);
            attributes.price_list_id = (Integer) opportunity.Pricebook2.Odoo_ID__c;
            attributes.customer_reference = opportunity.Description;
            attributes.memo = opportunity.Description;
            attributes.state = 'draft';
        } else {
            odooSalesOrderData.type = 'sale_order';
            odooSalesOrderData.id = (Integer) opp.Odoo_ID__c;
            attributes.memo = opportunity.Description;
            attributes.customer_reference = opportunity.Description;
        }

        odooSalesOrderData.attributes = attributes;

        for(OpportunityLineItem oli : oppLines){

            OdooSalesOrderPost.OrderLines orderLine = new OdooSalesOrderPost.OrderLines();
            OdooSalesOrderPost.OrderLineAttributes orderLineAttributes = new OdooSalesOrderPost.OrderLineAttributes();
            orderLine.type = 'sale_order_line';


            if(oli.Odoo_ID__c == null) {

                orderLineAttributes.product_id = (Integer) oli.Product2.Odoo_ID__c;
                orderLineAttributes.description = (Integer) oli.Odoo_ID__c == null ? oli.Description : null;
                //orderLine.sale_order_id = (Integer) sOrder.Odoo_ID__c; Need to check what to do here. I don't have the Order Id in Odoo at this point
                orderLineAttributes.product_uom_qty = (Integer) oli.Quantity;
                orderLineAttributes.price_unit = (Double) oli.UnitPrice;
                orderLineAttributes.discount = (Integer) oli.Odoo_ID__c == null ? (Double) oli.Discount : null;
                orderLineAttributes.salesforce_identifier = oli.Id;
            } else {
                orderLine.id = (Integer) oli.Odoo_ID__c;
                orderLineAttributes.product_uom_qty = (Integer) oli.Quantity;
            }

            orderLine.attributes = orderLineAttributes;
            orderLineList.add(orderLine);

        }

        odooSalesOrderData.attributes.lines = orderLineList;
        return odooSalesOrderData;

    }


    public static OdooSalesOrderPost.Data mapOrderToSaleOrder(Order sOrder){

        OdooSalesOrderPost.Data odooSalesOrderData = new OdooSalesOrderPost.Data();
        OdooSalesOrderPost.Attributes attributes = new OdooSalesOrderPost.Attributes();

        //Get all Order_Line__c records related to the current Order__c
        //If the Order_Line__c records are not found, then the Order__c record is not valid

        //System.debug('sOrder.Id: ' + sOrder.Id);
        //System.debug('sOrder: ' + sOrder);

        Order order = [SELECT Id, OrderNumber, Package__r.Odoo_ID__c, Memo__c, Order_Name__c, AccountId, Order_Status__c, Account.Odoo_ID__c, EffectiveDate, Pricebook2.Odoo_ID__c, Customer_Reference__c, Shipping_ID__r.Odoo_ID__c, Invoice_To__r.Odoo_ID__c FROM Order WHERE Id = :sOrder.Id];


        List<OrderItem> orderLines = [SELECT Id, Odoo_Id__c, Odoo_Reward_Id__c, OrderId, Product_Id_Odoo__c, Product2Id, PricebookEntry.Product2.Odoo_ID__c, Quantity, UnitPrice, Discount__c, ServiceDate, TotalPrice, Loyalty_Points__c, Description FROM OrderItem WHERE OrderId = :sOrder.Id];
        Account acc = [SELECT Id, Name, Odoo_ID__c FROM Account WHERE Id = :sOrder.AccountId];
        List<OdooSalesOrderPost.OrderLines> orderLineList = new List<OdooSalesOrderPost.OrderLines>();

        if(sOrder.Odoo_ID__c == null){

        //Transform the Order__c record to a OdooSalesOrder.Data record
        odooSalesOrderData.type = 'sale_order';
        odooSalesOrderData.id = (Integer) sOrder.Odoo_ID__c != null ? (Integer) sOrder.Odoo_ID__c : null;
        attributes.name = sOrder.Odoo_ID__c == null ? sOrder.Order_Name__c : null;
        attributes.account_name = sOrder.Odoo_ID__c == null ? (Integer) acc.Odoo_ID__c: null;
        attributes.start_date = sOrder.Odoo_ID__c == null ? (String) String.valueOf(sOrder.EffectiveDate) : null;
        attributes.price_list_id = sOrder.Odoo_ID__c == null ? (Integer) order.Pricebook2.Odoo_ID__c : null;
        attributes.customer_reference = sOrder.Customer_Reference__c;
        attributes.state = sOrder.Order_Status__c.toLowerCase();
        attributes.shipping_id = (Integer) order.Shipping_ID__r.Odoo_ID__c != null ? (Integer) order.Shipping_ID__r.Odoo_ID__c : null;
        attributes.partner_invoice_id = (Integer) order.Account.Odoo_ID__c != null ? (Integer) order.Account.Odoo_ID__c : null;
        attributes.memo = sOrder.Memo__c;
        attributes.template_id = order.Package__r.Odoo_ID__c != null ? Integer.valueOf(order.Package__r.Odoo_ID__c) : null;

        } else {
            odooSalesOrderData.type = 'sale_order';
            odooSalesOrderData.id = (Integer) sOrder.Odoo_ID__c;
            attributes.state = sOrder.Order_Status__c.toLowerCase();
            attributes.customer_reference = sOrder.Customer_Reference__c;
            attributes.memo = sOrder.Memo__c;
        }

        odooSalesOrderData.attributes = attributes;

        //Transform the Order_Line__c records to a OdooSalesOrder.OrderLines record
        for(OrderItem oli : orderLines){
            //System.debug('oli: ' + oli);
            OdooSalesOrderPost.OrderLines orderLine = new OdooSalesOrderPost.OrderLines();
            OdooSalesOrderPost.OrderLineAttributes orderLineAttributes = new OdooSalesOrderPost.OrderLineAttributes();
            orderLine.type = 'sale_order_line';

            if(oli.Odoo_ID__c == null && oli.Product_Id_Odoo__c != null) {

                orderLineAttributes.product_id = (Integer) oli.Product_Id_Odoo__c;
                //orderLineAttributes.description = (Integer) oli.Odoo_ID__c == null ? oli.Description : null;
                //orderLine.sale_order_id = (Integer) sOrder.Odoo_ID__c; Need to check what to do here. I don't have the Order Id in Odoo at this point
                orderLineAttributes.product_uom_qty = (Integer) oli.Quantity;
                orderLineAttributes.price_unit = (Double) oli.UnitPrice;
                orderLineAttributes.discount = (Integer) oli.Odoo_ID__c == null ? (Double) oli.Discount__c : null;
                orderLineAttributes.loyalty_points = (Integer) oli.Loyalty_Points__c;
                orderLineAttributes.salesforce_identifier = oli.Id;
            } else {
                orderLine.id = (Integer) oli.Odoo_ID__c;
                orderLineAttributes.product_uom_qty = (Integer) oli.Quantity;
            }

            if (oli.Odoo_Reward_Id__c != null) {
                orderLineAttributes.reward_id = (Integer) oli.Odoo_Reward_Id__c;
            }

            orderLine.attributes = orderLineAttributes;
            orderLineList.add(orderLine);
        }

        odooSalesOrderData.attributes.lines = orderLineList;

        return odooSalesOrderData;

    }

    public static String postOpptyToOdoo(OdooSalesOrderPost odooSalesOrder){
        String responseString = '';

        //System.debug('POST');

        String body = JSON.serialize(odooSalesOrder, true);

        Callout callout = Callout.preparePostCallout('sale_order', body);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse res = ch.makeCallout(callout);

        responseString = res.getBody();
        OdooSalesOrderPost odooOrder = OdooSalesOrderPost.parse(responseString);
        //System.debug('odooOrder: ' + odooOrder);

        if(res.getStatusCode() == 200){
            //System.debug('Success');
            parsePostPatchResultOppty(odooOrder);
        }

        if(res.getStatusCode() != 200){
            //System.debug('Error');
            errorLogger(res.getBody(), body, 'create', 'Oppty', String.valueOf(odooSalesOrder.data.Id));
        }

        return responseString;
    }

    public static String patchOpptyToOdoo(OdooSalesOrderPost odooSalesOrder){
        String responseString = '';

        //System.debug('PATCH');

        String body = JSON.serialize(odooSalesOrder, true);

        //System.debug('body: ' + body);

        Callout callout = Callout.preparePatchCallout('sale_order', body, odooSalesOrder.data.Id);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse res = ch.makeCallout(callout);

        responseString = res.getBody();
        OdooSalesOrderPost odooOrder = OdooSalesOrderPost.parse(responseString);
        //System.debug('odooOrder: ' + odooOrder);

        if(res.getStatusCode() == 200){
            //System.debug('Success');
            parsePostPatchResultOppty(odooOrder);
        }

        if(res.getStatusCode() != 200){
            //System.debug('Error');
            Opportunity oppty = [SELECT Id, Odoo_ID__c FROM Opportunity WHERE Name = :odooOrder.data.attributes.name];
            oppty.Sent_to_Odoo__c = false;
            update oppty;
            errorLogger(res.getBody(), body, 'create', 'Opportunity' , String.valueOf(odooOrder.data.Id));
        }

        return responseString;
    }




    public static String postOrderToOdoo(OdooSalesOrderPost odooSalesOrder){
        String responseString = '';

        //System.debug('POST');

        String body = JSON.serialize(odooSalesOrder, true);

        System.debug('body: ' + body);

        Callout callout = Callout.preparePostCallout('sale_order', body);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse res = ch.makeCallout(callout);

        responseString = res.getBody();
        OdooSalesOrderPost odooOrder = OdooSalesOrderPost.parse(responseString);
        System.debug('odooOrder: ' + odooOrder);

        if(res.getStatusCode() == 200){
            //System.debug('Success');
            parsePostPatchResult(odooOrder);
        }

        if(res.getStatusCode() != 200){
            //System.debug('Error');
            errorLogger(res.getBody(), body, 'create', 'Order', String.valueOf(odooSalesOrder.data.Id));
        }

        return responseString;
    }

    public static String patchOrderToOdoo(OdooSalesOrderPost odooSalesOrder){
        String responseString = '';

        //System.debug('PATCH');

        String body = JSON.serialize(odooSalesOrder, true);

        System.debug('body: ' + body);

        Callout callout = Callout.preparePatchCallout('sale_order', body, odooSalesOrder.data.Id);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse res = ch.makeCallout(callout);

        responseString = res.getBody();
        OdooSalesOrderPost odooOrder = OdooSalesOrderPost.parse(responseString);
        System.debug('odooOrder: ' + odooOrder);
        System.debug('res.getStatusCode(): ' + res.getStatusCode());
        System.debug('odooSalesOrder.data.attributes.name: ' + odooSalesOrder.data.attributes.name);

        if(res.getStatusCode() == 200){
            System.debug('Success');
            parsePostPatchResult(odooOrder);
        }

        if(res.getStatusCode() != 200){
            System.debug('Error');
            Order order = [SELECT Id, Odoo_ID__c FROM Order WHERE Odoo_ID__c = :odooSalesOrder.data.Id];
            order.Sent_to_Odoo__c = false;
            System.debug('order: ' + order);
            update order;
            errorLogger(res.getBody(), body, 'create', 'Order', String.valueOf(odooSalesOrder.data.Id));
        }

        return responseString;
    }


    public static void parsePostPatchResult(OdooSalesOrderPost odooOrder){

        List<OrderItem> orderLinesToUpdate = new List<OrderItem>();
        List<OrderItem> orderLinesToCreate = new List<OrderItem>();

       System.debug('odooOrder.data.attributes: ' +odooOrder.data.attributes);

        Order order = [SELECT Id, Odoo_ID__c FROM Order WHERE Order_Name__c = :odooOrder.data.attributes.name];
        order.Odoo_ID__c = odooOrder.data.Id;
        order.Shipping_ID__r = odooOrder.data.attributes.shipping_id != null ? new Account(Odoo_ID__c = odooOrder.data.attributes.shipping_id) : null;
        order.Invoice_To__r = odooOrder.data.attributes.invoice_id != null ? new Account(Odoo_ID__c = odooOrder.data.attributes.invoice_id) : null;
        order.Sent_to_Odoo__c = false;
        order.Warehouse_ID__c = odooOrder.data.attributes.warehouse_id;
        order.PDF__c = odooOrder.data.attributes.pdf != null ? odooOrder.data.attributes.pdf : null;
        for(OdooSalesOrderPost.OrderLines data : odooOrder.data.attributes.lines){
            //System.debug('data: ' + data);
            OrderItem orderLine = new OrderItem();
            orderLine.Odoo_ID__c = data.Id;
            orderLine.UnitPrice = data.attributes.list_price;
            orderLine.Quantity = data.attributes.product_uom_qty;
            orderLine.PricebookEntry = new PricebookEntry(Odoo_ID__c = String.valueOf(data.attributes.product_id) + '-' +String.valueOf(odooOrder.data.attributes.price_list_id));
            orderLine.Order = new Order(Odoo_ID__c = odooOrder.data.Id);
            if(data.attributes.salesforce_identifier != null){
                orderLine.Id = data.attributes.salesforce_identifier;
                orderLinesToUpdate.add(orderLine);
            }else{
                orderLinesToCreate.add(orderLine);
            }
        }

        update order;
        update orderLinesToUpdate;
        insert orderLinesToCreate;
    }

        public static void parsePostPatchResultOppty(OdooSalesOrderPost odooOrder){

        List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLinesToCreate = new List<OpportunityLineItem>();
        //system.debug('order name ' + odooOrder.data.attributes.name);

        Opportunity opp = [SELECT Id, Odoo_ID__c FROM Opportunity WHERE Name = :odooOrder.data.attributes.name AND Account.Odoo_ID__c = :odooOrder.data.attributes.account_name];
        opp.Odoo_ID__c = odooOrder.data.Id;
        opp.PDF__c = odooOrder.data.attributes.pdf != null ? odooOrder.data.attributes.pdf : null;
        //opp.Sent_to_Odoo__c = false;
        for(OdooSalesOrderPost.OrderLines data : odooOrder.data.attributes.lines){
            //System.debug('data: ' + data);
            OpportunityLineItem oppLine = new OpportunityLineItem();
            oppLine.Odoo_ID__c = data.Id;
            oppLine.UnitPrice = data.attributes.list_price;
            oppLine.Quantity = data.attributes.product_uom_qty;
            oppLine.PricebookEntry = new PricebookEntry(Odoo_ID__c = String.valueOf(data.attributes.product_id) + '-' +String.valueOf(odooOrder.data.attributes.price_list_id));
            oppLine.Opportunity = new Opportunity(Odoo_ID__c = odooOrder.data.Id);
            if(data.attributes.salesforce_identifier != null){
                oppLine.Id = data.attributes.salesforce_identifier;
                if(oppLinesToCreate.contains(oppLine) == false) {
                    oppLinesToUpdate.add(oppLine);
                }
            }else{
                oppLinesToCreate.add(oppLine);
            }
        }

        update opp;
        try {
            Database.SaveResult[] oppLineUpserts = Database.update(oppLinesToUpdate, false);
        } catch (Exception e) {
            System.debug('e: ' + e);
        }
        insert oppLinesToCreate;
    }

    public static void errorLogger(String errorMessage, String payload, String operation, String objectName, String odooId){

        System.debug('logging error');

        String sobjectType = objectName;
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Error_Message__c = 'Error Message: ' + errorMessage;
        errorLog.Payload__c = String.valueOf(payload).left(30000);
        errorLog.DML_Operation__c = operation;
        errorLog.Object__c = sobjectType;

        if(objectName == 'Order' && odooId != null){
            errorLog.Order__r = new Order(Odoo_ID__c = Integer.valueOf(odooId));
        }

        insert errorLog;

    }


}