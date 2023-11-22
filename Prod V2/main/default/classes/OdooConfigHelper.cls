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

public with sharing class OdooConfigHelper {

    public static String getTextFromIdentifier(Integer identifier, String tableName) {
        String text = '';

        try {
            text = [SELECT Name FROM Odoo_Config__c WHERE Identifier__c = :identifier AND Table__c =: tableName LIMIT 1].Text_Value__c;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return text;
    }

    public static Integer getIdentifierFromText(String textValue, String tableName){

        Integer identifier;

        try {
            identifier = Integer.valueOf([SELECT Identifier__c FROM Odoo_Config__c WHERE Text_Value__c = :textValue AND Table__c =: tableName LIMIT 1].Identifier__c);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return identifier;
    }

}