/**
 * @Version: 1.0
 * @Author: Upeo
 * @Copyright: 2021 Upeo Consulting
 * @Uses:
 *
 * -----------------------------------------------------------------------------------------------
 * Description: Validator for Callout objects
 * Apex test methods cannot perform actual callouts to external services.
 * Instead, you can use callout mocks to simulate callouts.
 * A callout mock is an Apex class that defines an HTTP response for a callout
 * You can use callout mocks for testing both single and multi-callout functionality
 * -----------------------------------------------------------------------------------------------
 * Revision No. 	Author 			Date 			Description
 * 1.0 			Upeo 		12/08/2023 		Initial version
 * -----------------------------------------------------------------------------------------------
 * Dependencies: Callout
 * Created: 12/08/2023
 * Last Updated: 12/08/2023
 *
 * Unit tests:
 * -----------------------------------------------------------------------------------------------
*/

@IsTest
private class CalloutHandlerTest {
    @IsTest
    static void testMakeCalloutNoBody() {

        //Create a mock JSON body
        //For this test the contents of the body are not important
        //I added a real body purely as an example
        String mockBody = '{'+
                '    \"articles\": ['+
                '        {'+
                '            \"article\": \"130595\",'+
                '            \"ean\": \"4019238318036\",'+
                '            \"priceRate\": \"235.50\",'+
                '            \"promoType\": \"none\",'+
                '            \"supplier\": ['+
                '                {'+
                '                    \"id\": \"6576\",'+
                '                    \"quantity1\": \"> 50\",'+
                '                    \"deliveryDate1\": \"2022-11-17\",'+
                '                    \"quantity2\": \"\",'+
                '                    \"deliveryDate2\": \"\",'+
                '                    \"quantity3\": \"\",'+
                '                    \"deliveryDate3\": \"\",'+
                '                    \"prices\": ['+
                '                        {'+
                '                            \"type\": \"d1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d3\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p3\",'+
                '                            \"value\": \"\"'+
                '                        }'+
                '                    ]'+
                '                },'+
                '                {'+
                '                    \"id\": \"12226\",'+
                '                    \"quantity1\": \"10\",'+
                '                    \"deliveryDate1\": \"2022-11-17\",'+
                '                    \"quantity2\": \"\",'+
                '                    \"deliveryDate2\": \"\",'+
                '                    \"quantity3\": \"\",'+
                '                    \"deliveryDate3\": \"\",'+
                '                    \"prices\": ['+
                '                        {'+
                '                            \"type\": \"d1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d3\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p3\",'+
                '                            \"value\": \"\"'+
                '                        }'+
                '                    ]'+
                '                }'+
                '            ]'+
                '        }'+
                '    ],'+
                '    \"count\": 500'+
                '}';
        //Create a SingleRequestMock
        SingleRequestMock singleRequestMock = new SingleRequestMock(
                200,
                'OK',
                mockBody,
                null
        );

        //Create a map of String to HTTPCalloutMock
        //This is used to map the endpoint to the mock response
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://api.myjson.com/bins/1f3xjq', singleRequestMock);

        //Set the mock callout mode
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        //Now run the test
        Test.startTest();
        Callout callout = new Callout();
        callout.endpoint = 'https://api.myjson.com/bins/1f3xjq';
        callout.method = 'GET';
        callout.headers = new Map<String, String>();
        callout.headers.put('Content-Type', 'application/json');
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);
        System.assertNotEquals(null, response);
        Test.stopTest();

    }

    @IsTest
    static void testMakeCalloutWithBody() {

        //Create a mock JSON body
        //For this test the contents of the body are not important
        //I added a real body purely as an example
        String mockBody = '{'+
                '    \"articles\": ['+
                '        {'+
                '            \"article\": \"130595\",'+
                '            \"ean\": \"4019238318036\",'+
                '            \"priceRate\": \"235.50\",'+
                '            \"promoType\": \"none\",'+
                '            \"supplier\": ['+
                '                {'+
                '                    \"id\": \"6576\",'+
                '                    \"quantity1\": \"> 50\",'+
                '                    \"deliveryDate1\": \"2022-11-17\",'+
                '                    \"quantity2\": \"\",'+
                '                    \"deliveryDate2\": \"\",'+
                '                    \"quantity3\": \"\",'+
                '                    \"deliveryDate3\": \"\",'+
                '                    \"prices\": ['+
                '                        {'+
                '                            \"type\": \"d1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d3\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p3\",'+
                '                            \"value\": \"\"'+
                '                        }'+
                '                    ]'+
                '                },'+
                '                {'+
                '                    \"id\": \"12226\",'+
                '                    \"quantity1\": \"10\",'+
                '                    \"deliveryDate1\": \"2022-11-17\",'+
                '                    \"quantity2\": \"\",'+
                '                    \"deliveryDate2\": \"\",'+
                '                    \"quantity3\": \"\",'+
                '                    \"deliveryDate3\": \"\",'+
                '                    \"prices\": ['+
                '                        {'+
                '                            \"type\": \"d1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"d3\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p1\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p2\",'+
                '                            \"value\": \"\"'+
                '                        },'+
                '                        {'+
                '                            \"type\": \"p3\",'+
                '                            \"value\": \"\"'+
                '                        }'+
                '                    ]'+
                '                }'+
                '            ]'+
                '        }'+
                '    ],'+
                '    \"count\": 500'+
                '}';
        //Create a SingleRequestMock
        SingleRequestMock singleRequestMock = new SingleRequestMock(
                200,
                'OK',
                mockBody,
                null
        );

        //Create a map of String to HTTPCalloutMock
        //This is used to map the endpoint to the mock response
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://api.myjson.com/bins/1f3xjq', singleRequestMock);

        //Set the mock callout mode
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        //Now run the test
        Test.startTest();
        Callout callout = new Callout();
        callout.endpoint = 'https://api.myjson.com/bins/1f3xjq';
        callout.method = 'GET';
        callout.headers = new Map<String, String>();
        callout.headers.put('Content-Type', 'application/json');
        callout.body = 'test body';
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);
        System.assertNotEquals(null, response);
        Test.stopTest();
    }

}