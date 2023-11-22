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
 * Created: 31/08/2023
 * Last Updated: 31/08/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooProductTest {
    @IsTest
    static void testParse() {

        String json=		'{'+
                '    "data": ['+
                '        {'+
                '            "id": 26263,'+
                '            "type": "product_template",'+
                '            "attributes": {'+
                '                "name": "Apotheek Claeys 11u-12u",'+
                '                "owner": 1298,'+
                '                "active": true,'+
                '                "display_url": null,'+
                '                "external_id": "__export__.product_template_26263_1c72805e",'+
                '                "code": "26263132",'+
                '                "description": "Verkoopnotitie",'+
                '                "family": ['+
                '                    "Services"'+
                '                ],'+
                '                "cnk_code": "26263",'+
                '                "type": "product",'+
                '                "uom_name": "Units",'+
                '                "price": 40.5,'+
                '                "available_qty": 0.0,'+
                '                "end_of_life": true,'+
                '                "collection": "CPC/FR/21"'+
                '            }'+
                '        }'+
                '    ]'+
                '}';

        OdooProduct product = OdooProduct.parse(json);
        System.assertEquals('Apotheek Claeys 11u-12u', product.data[0].attributes.name);
        System.assertEquals(1298, product.data[0].attributes.owner);
        System.assertEquals(true, product.data[0].attributes.active);
        System.assertEquals(null, product.data[0].attributes.display_url);
        System.assertEquals('__export__.product_template_26263_1c72805e', product.data[0].attributes.external_id);
        System.assertEquals('26263132', product.data[0].attributes.code);
        System.assertEquals('Verkoopnotitie', product.data[0].attributes.description);
        System.assertEquals('Services', product.data[0].attributes.family[0]);
        System.assertEquals('26263', product.data[0].attributes.cnk_code);
        System.assertEquals('product', product.data[0].attributes.type);
        System.assertEquals('Units', product.data[0].attributes.uom_name);
        System.assertEquals(0.0, product.data[0].attributes.available_qty);
        System.assertEquals(true, product.data[0].attributes.end_of_life);
        System.assertEquals('CPC/FR/21', product.data[0].attributes.collection);

    }
}