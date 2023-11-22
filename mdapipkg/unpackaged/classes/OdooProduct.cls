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

public with sharing class OdooProduct {

    public List<Data> data{get;set;}
    public meta meta{get;set;}

    public class meta{
        public Integer offset{get;set;}
        public Integer limit_x{get;set;}
        public Integer size{get;set;}
        public Integer total{get;set;}
    }

    public class Data{
        public Attributes attributes{get;set;}
        public String type{get;set;}
        public Integer id{get;set;}
    }
    public class Attributes{
        public List<String> family{get;set;}
        public String cnk_code{get;set;}
        public String description{get;set;}
        public String type{get;set;}
        public String code{get;set;}
        public String uom_name{get;set;}
        public String external_id{get;set;}
        public Decimal list_price{get;set;}
        public String display_url{get;set;}
        public Decimal available_qty{get;set;}
        public Boolean active{get;set;}
        public Boolean end_of_life{get;set;}
        public Integer owner{get;set;}
        public String collection{get;set;}
        public String name{get;set;}
        public Map<String, Decimal> prices{get;set;}

    }

    public static OdooProduct parse(String json) {
        System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        json = json.replace('"prices": []', '"prices": {}');
        return (OdooProduct) System.JSON.deserialize(json, OdooProduct.class);
    }

}