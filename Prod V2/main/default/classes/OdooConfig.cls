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
 * Created: 20/10/2023
 * Last Updated: 20/10/2023
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

public with sharing class OdooConfig {

    public Meta meta;
    public List<Data> data;
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
        public String name;
    }

    public static OdooConfig parse(String json) {
        System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        return (OdooConfig) System.JSON.deserialize(json, OdooConfig.class);
    }

}