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

public class OdooConfigSyncQueueable implements Queueable, Database.AllowsCallouts {

    public Integer offset = 0;
    public Integer limiter = 500;
    public Boolean isSandbox;
    public String environment;



    public OdooConfigSyncQueueable(){

        this.offset = offset;
        this.limiter = limiter;
        this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        this.environment = this.isSandbox ? 'Sandbox' : 'Production';
    }


    public void execute(QueueableContext context){
        syncConfigs();
    }

    public void syncConfigs(){

        List<Odoo_Config__c> configs = new List<Odoo_Config__c>();

        List<String> typesToGet = new List<String>{'User', 'Sale_Invoice_Grouping','Fiscal_Position', 'Delivery_Carrier', 'Ranking', 'Labels'};
        for(String configType : typesToGet){
            configs.addAll(getConfig(configType));
        }

        //Clean the Odoo_Config__c table
        List<Odoo_Config__c> oldConfigs = [SELECT Id FROM Odoo_Config__c];
        delete oldConfigs;

        //Insert the new configs
        insert configs;



    }

    public List<Odoo_Config__c> getConfig(String configType){

        List<Odoo_Config__c> configs = new List<Odoo_Config__c>();
        HttpResponse response = doCallOut(configType);

        if(response.getStatusCode() == 200){

            OdooConfig confResponse = OdooConfig.parse(response.getBody());
            System.debug('User Response: ' + confResponse);
            for(OdooConfig.Data data : confResponse.data){
                Odoo_Config__c config = new Odoo_Config__c();
                config.Text_Value__c = data.attributes.name;
                config.Identifier__c = data.id;
                config.Table__c = configType;
                configs.add(config);
            }
        }
        else{
            return null;
        }
        return configs;

    }

    public HttpResponse doCallOut(String configType){

        Callout callout = Callout.prepareCallout(this.environment, configType, offset, limiter);
        CalloutHandler handler = new CalloutHandler();
        HttpResponse response = handler.makeCallout(callout);
        return response;

    }



}