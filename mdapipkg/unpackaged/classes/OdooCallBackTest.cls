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
 * Created: 24/10/2023
 * Last Updated: 24/10/2023
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
@IsTest
public class OdooCallBackTest {

    @IsTest
    static void test(){

        String callBack = '{"type:":"ir.actions.client","ids": [1,2,3,4,5,6,7,8,9,10]}';
        OdooCallback callBackObj = OdooCallback.parse(callBack);


    }

}