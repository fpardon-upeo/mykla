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

public with sharing class SearchableComboboxController {

    @AuraEnabled
    public static List<String> getObjectValues() {
        List<String> objectValues = new List<String>();
        List<Odoo_Config__c> odooConfigs = [SELECT Id, Name, Text_Value__c FROM Odoo_Config__c Where Table__c = 'Labels'];
        for(Odoo_Config__c odooConfig : odooConfigs) {
            objectValues.add(odooConfig.Text_Value__c);
        }
        System.debug('objectValues: ' + objectValues);
        return objectValues;
    }

    @AuraEnabled
    public static String getAccountLabels(String recordId){
        return [SELECT Id, Labels__c FROM Account Where Id = :recordId].Labels__c;
    }

    @AuraEnabled
    public static String getLeadLabels(String recordId){
        return [SELECT Id, Labels__c FROM Lead Where Id = :recordId].Labels__c;
    }

}