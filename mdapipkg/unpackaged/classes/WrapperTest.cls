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
@IsTest
private class WrapperTest {
    @IsTest
    static void testOdooPostResponse() {

        String postResponse = '{"id": 1}';
        OdooPostResponse.Data response = OdooPostResponse.parse(postResponse);
    }
}