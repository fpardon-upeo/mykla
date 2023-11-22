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

public class OdooPostResponse {

    public class Data {
        public Integer id;
    }

    public static OdooPostResponse.Data parse(String json) {
        return (OdooPostResponse.Data) System.JSON.deserialize(json, OdooPostResponse.Data.class);
    }

}