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
 * Created: 15/09/2023
 * Last Updated: 15/09/2023
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

public class OdooCallback {

    public Data data;

    public class Data {
        public String type;
        public List<String> ids;
    }

    public static OdooCallback parse(String json) {
        return (OdooCallback) System.JSON.deserialize(json, OdooCallback.class);
    }

}