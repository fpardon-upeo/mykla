/**
 * @Version: 1.0
 * @Author: Upeo
 * @Copyright: 2021 Upeo Consulting
 * @Uses:
 *
 * -----------------------------------------------------------------------------------------------
 * Description: Callout class, used to store callout information
 * -----------------------------------------------------------------------------------------------
 * Revision No. 	Author 			Date 			Description
 * 1.0 			Upeo 		12/08/2023 		Initial version
 * -----------------------------------------------------------------------------------------------
 *
 * Created: 12/08/2023
 * Last Updated: 12/08/2023
 *
 * Unit tests:
 *
 * -----------------------------------------------------------------------------------------------
*/


public class Callout {

    @AuraEnabled public String name;
    @AuraEnabled public String type;
    @AuraEnabled public String endpoint;
    @AuraEnabled public String body;
    @AuraEnabled public String method;
    @AuraEnabled public Map<String, String> headers;
    @AuraEnabled public String timeout;
    @AuraEnabled public String retry;

    public static Callout prepareCallout(String environment, String dataType, Integer offset, Integer limiter){

        Callout callout = new Callout();
        Map<String, String> headers = new Map<String, String>();
        Odoo_Endpoint_Config__mdt calloutConfig = [SELECT Endpoint__c, Method__c FROM Odoo_Endpoint_Config__mdt WHERE Environment__c = :environment AND DeveloperName =:dataType LIMIT 1];
        System.debug('Callout config: ' + calloutConfig);
        callout.endpoint = 'callout:Odoo' + '/' + calloutConfig.Endpoint__c + '?offset=' + offset + '&limit=' + limiter;
        callout.method = calloutConfig.Method__c;
        callout.timeout = '120000';
        return callout;
    }

    public static Callout prepareCallbackCallout(String environment, String dataType, String identifier){

        Callout callout = new Callout();
        Odoo_Endpoint_Config__mdt calloutConfig = [SELECT Endpoint__c, Method__c FROM Odoo_Endpoint_Config__mdt WHERE Environment__c = :environment AND DeveloperName =:dataType LIMIT 1];
        System.debug('Callout config: ' + calloutConfig);
        callout.endpoint = 'callout:OdooSync' + '/' + calloutConfig.Endpoint__c + '/' + identifier;
        callout.headers = new Map<String, String>();
        callout.headers.put('Accept', 'application/json');
        callout.headers.put('Authorization', '8F1vuCBE5cPhaEU5bK3_ZXv53u89gHF-YRp0wJk4SfA');
        System.debug('Callout endpoint: ' + callout.endpoint);
        callout.method = calloutConfig.Method__c;
        return callout;
    }
    public static Callout preparePostCallout(String endpoint, String body){

        Callout callout = new Callout();
        callout.endpoint = 'callout:Odoo' + '/' + endpoint;
        callout.method = 'POST';
        callout.headers = new Map<String, String>();
        callout.headers.put('Content-Type', 'application/json');
        callout.headers.put('Accept', 'application/json');
        callout.body = body;
        callout.timeout = '120000';
        return callout;
    }

    public static Callout preparePatchCallout(String endpoint, String body,Integer identifier){

        System.debug('Callout body: ' + body);

        Callout callout = new Callout();
        callout.endpoint = 'callout:Odoo' + '/' + endpoint + '/' + identifier;
        callout.method = 'PATCH';
        callout.headers = new Map<String, String>();
        callout.headers.put('Content-Type', 'application/json');
        callout.headers.put('Accept', 'application/json');
        callout.body = body;
        callout.timeout = '120000';
        return callout;
    }






}