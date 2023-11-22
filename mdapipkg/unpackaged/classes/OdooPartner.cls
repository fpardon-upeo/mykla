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
 * Created: 31/08/2023
 * Last Updated: 31/08/2023
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

public class OdooPartner {

    public List<Data> data;
    public Data dataSingle;
    public Meta meta;

    public class Attributes {
        public String name;
        public Integer parent_odoo;
        public String street;
        public String city;
        public String postal_code;
        public String country_iso_code;
        public String description_html;
        public String email;
        public String mobile;
        public String phone;
        public String website;
        public String language;
        public Integer pricelist_odoo_id;
        public String title;
        public String vat;
        public String company_type;
        public String type;
        public String salesforce_identifier;
        public Integer ranking;
        public List<Integer> labels;
        public String distribution_channel;
        public String sub_distribution_channel;
        public Integer sales_person;
        public Integer fiscal_position;
        public Double loyalty_points;
        public Integer delivery_method;
        public Boolean sale_order_on_invoice_line;
        public Integer client_support;
        public String start;
        public String end_Z;
        public Boolean active;
        public String operation;
        public Boolean prospect;
        public String website_url;
        public Integer invoicing_criteria_id;
        public List<Integer> loyalty_program_ids;
    }

    public class Data {
        public Integer id;
        public String type;
        public Attributes attributes;
    }

    public class Meta {
        public Integer total;
        public Integer size;
        public Integer limit_x;
        public Integer offset;
    }

    public static OdooPartner parse(String json) {
        System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        return (OdooPartner) System.JSON.deserialize(json, OdooPartner.class);
    }

    public static OdooPartner.Data parsePartnerData(String json) {
        System.debug('json: ' + json);
        json = json.replace('data', 'dataSingle'); // Assuming 'data' won't appear anywhere else in your JSON string
        System.debug('json: ' + json);
        OdooPartner partner = new OdooPartner();
        OdooPartner.Data result = new OdooPartner.Data();

        try {
            partner = (OdooPartner) System.JSON.deserialize(json, OdooPartner.class);
            result = partner.dataSingle;
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
            // Handle exception as needed
        }

        return partner.dataSingle;
    }
}