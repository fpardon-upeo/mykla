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

/**
 * Created by fpardon on 07/09/2023.
 */

public with sharing class OdooSalesOrderPost {

    public Meta meta;
    public Data data;

    public class Meta {
        public Integer total;
        public Integer size;
        public Integer limit_x;
        public Integer offset;
    }

    public class Data {
        public Integer id;
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
        public String pdf;
        public String memo;
        public Integer template_id;
        public Integer partner_invoice_id;
    }

    public class OrderLines {
        public Integer id;
        public String type;
        public OrderLineAttributes attributes;
    }

    public class OrderLineAttributes {
        public String description;
        public Integer sale_order_id;
        public Integer product_id;
        public Decimal quantity;
        public Decimal price_unit;
        public Decimal list_price;
        public Decimal product_uom_qty;
        public String start_date;
        public Decimal total_price;
        public Decimal discount;
        public String uom_name;
        public Decimal qty_delivered;
        public Decimal qty_invoiced;
        public String salesforce_identifier;
        public Decimal loyalty_points;
        public Integer reward_id;
    }

    public static OdooSalesOrderPost parse(String json) {
        System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        return (OdooSalesOrderPost) System.JSON.deserialize(json, OdooSalesOrderPost.class);
    }

}