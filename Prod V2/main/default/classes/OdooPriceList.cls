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

public class OdooPriceList{
    public meta meta{get;set;}
    public list<data> data{get;set;}
    public class meta{
        public Integer offset{get;set;}
        public Integer limit_x{get;set;}
        public Integer size{get;set;}
        public Integer total{get;set;}
    }
    public class data{
        public Integer id{get;set;}
        public attributes attributes{get;set;}
        public String type{get;set;}
    }
    public class attributes{
        public String name{get;set;}
        public Boolean active{get;set;}
    }

    public static OdooPriceList parse(String json){
        json = json.replace('limit', 'limit_x');
        return (OdooPriceList) System.JSON.deserialize(json, OdooPriceList.class);
    }
}