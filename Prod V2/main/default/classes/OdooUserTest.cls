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
private class OdooUserTest {


    @IsTest
    static void test() {
        String jsonString =
                '{'+
                        '    "meta": {'+
                        '        "total": 51,'+
                        '        "size": 51,'+
                        '        "limit": 1000,'+
                        '        "offset": 0'+
                        '    },'+
                        '    "data": ['+
                        '        {'+
                        '            "id": 2,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Administrator"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1686,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Andrea Lavazza"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1490,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Aurore Micello"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 9,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Backoffice"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1464,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Britt Eyckmans"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 6,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Caroline Rigo"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 12,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Charis Piscicelli"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1562,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Charlotte Van de Paer"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1559,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Cynthia Reekmans"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 11,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Dana Fanelli"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1489,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Elke Verriest"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1553,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Ellen"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1690,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Ellen Barbieur"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1528,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Isabelle Regniers (onkosten)"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1674,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Isaura"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1639,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Isolde Borre"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1465,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Jill Meervis"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1483,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Joke Heedfeld"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1640,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Jolanda de Jonge"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 13,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Julie Hendrickx"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1298,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Justine"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1620,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Katrien Custers"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1178,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Katrien Dierickx"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1560,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Kristoff Van de Paer"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1356,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Laura Coenraets"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 648,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Laurie De Moor"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1561,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Lena Simao"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1513,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Linda Castagna"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1306,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Lisa Hendrickx"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 18,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Lore Carlier"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1739,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Luca Ghizzoni"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1536,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Marie Bols"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1484,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Marijn Steegmans (onkosten)"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1507,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Miranda Van Der Bliek"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1190,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Peggy Bakker"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1481,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Rossana Ieracitano"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1463,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Sandra Venken"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 16,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Sarah Sminate"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 690,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Serena Peeters"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 14,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Shari Magiels"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1529,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Sharon Vanderbeken"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 17,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Sofia Feriani"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1488,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Stefanie Nisen"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 15,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Stéphanie Van Looveren"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1188,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Tanja Kwiecien"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1462,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Tiffany Manion"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1332,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Tom Leyssen"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 7,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Trisha Van Hove"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1466,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Valentina Ferrin"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1557,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Veronique De Vlieger"'+
                        '            }'+
                        '        },'+
                        '        {'+
                        '            "id": 1564,'+
                        '            "type": "users",'+
                        '            "attributes": {'+
                        '                "name": "Veronique Quintens"'+
                        '            }'+
                        '        }'+
                        '    ]'+
                        '}';
        OdooUser parser = OdooUser.parse(jsonString);
        System.assert(parser != null);
    }
}