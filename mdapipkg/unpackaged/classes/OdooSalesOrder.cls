/**
 * Created by fpardon on 07/09/2023.
 */

public with sharing class OdooSalesOrder {

    public List<Data> data;
    public Data dataSingle;
    public Meta meta;

    public class Meta {
        public Integer total;
        public Integer size;
        public Integer limit_x;
        public Integer offset;
    }

    public class Data {
        public Integer Id;
        public String type;
        public Attributes attributes;
    }

    public class Attributes {
        public Integer account_name;
        public Integer invoice_id;
        public Decimal amount;
        public String name;
        public String start_date;
        public Integer price_list_id;
        public Integer shipping_id;
        public String state;
        public String customer_reference;
        public List<OrderLines> lines;
        public String warehouse_id;
        public List<String> tracking_reference;
    }

    public class OrderLines {
        public Integer Id;
        public OrderLineAttributes attributes;
    }

    public class OrderLineAttributes {
        public String description;
        public Integer sale_order_id;
        public Integer product_id;
        public Decimal quantity;
        public Decimal product_uom_qty;
        public Decimal list_price;
        public String start_date;
        public Decimal total_price;
        public Decimal discount;
        public String uom_name;
        public Decimal qty_delivered;
        public Decimal qty_invoiced;
        public String salesforce_identifier;
        public Decimal loyalty_points;
    }

    public static OdooSalesOrder parse(String json) {
        //System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        return (OdooSalesOrder) System.JSON.deserialize(json, OdooSalesOrder.class);
    }

    public static OdooSalesOrder.Data parseOrderData(String json) {
        //System.debug('json: ' + json);
        json = json.replace('data', 'dataSingle'); // Assuming 'data' won't appear anywhere else in your JSON string
        //System.debug('json: ' + json);
        OdooSalesOrder order = new OdooSalesOrder();
        OdooSalesOrder.Data result = new OdooSalesOrder.Data();

        try {
            order = (OdooSalesOrder) System.JSON.deserialize(json, OdooSalesOrder.class);
            result = order.dataSingle;
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
            // Handle exception as needed
        }

        return order.dataSingle;
    }

}