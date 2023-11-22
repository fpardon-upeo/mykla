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

public class OdooAccountMove {

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
        public Decimal total;
        public Decimal tax;
        public Decimal tax_excluded;
        public Decimal amount_due;
        public String name;
        public String start_date;
        public String end_date;
        public Integer shipping_id;
        public String state;
        public String payment_state;
        public String customer_ref;
        public List<InvoiceLines> invoice_lines;
    }

    public class InvoiceLines {
        public Integer Id;
        public OrderLineAttributes attributes;
    }

    public class OrderLineAttributes {
        public String description;
        public Integer account_move_id;
        public Integer product_id;
        public Decimal quantity;
        public Decimal list_price;
        public String start_date;
        public Decimal total_price;
        public Decimal discount;
    }

    public static OdooAccountMove parse(String json) {
        //System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        return (OdooAccountMove) System.JSON.deserialize(json, OdooAccountMove.class);
    }

    public static OdooAccountMove.Data parseInvoiceData(String json) {
        //System.debug('json: ' + json);
        json = json.replace('data', 'dataSingle'); // Assuming 'data' won't appear anywhere else in your JSON string
        //System.debug('json: ' + json);
        OdooAccountMove invoice = new OdooAccountMove();
        OdooAccountMove.Data result = new OdooAccountMove.Data();

        try {
            invoice = (OdooAccountMove) System.JSON.deserialize(json, OdooAccountMove.class);
            result = invoice.dataSingle;
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
            // Handle exception as needed
        }

        return invoice.dataSingle;
    }
}