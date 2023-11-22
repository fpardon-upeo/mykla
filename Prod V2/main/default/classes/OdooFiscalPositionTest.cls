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

@IsTest
private class OdooFiscalPositionTest {


    @IsTest
    static void test() {
        String jsonString =
                '{'+
                        '    "meta": {'+
                        '        "total": 7,'+
                        '        "size": 7,'+
                        '        "limit": 1000,'+
                        '        "offset": 0'+
                        '    },'+
                        '    "data": ['+
                        '        {'+
                        '            "id": 1,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "National regime"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 4,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "Intra-Community Regime"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 3,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "Export"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 5,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "Co-contracting Regime"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 22,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "Vrijgesteld van BTW"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 49,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "Intercompany (voor GB-rek)"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 50,'+
                        '            "type": "account_fiscal_position",'+
                        '            "attributes": {'+
                        '                "name": "Eigen company (voor GB rek)"'+
                        '            }'+
                        '        }'+
                        '    ]'+
                        '}';
        OdooFiscalPosition parser = OdooFiscalPosition.parse(jsonString);
        System.assert(parser != null);
    }
}