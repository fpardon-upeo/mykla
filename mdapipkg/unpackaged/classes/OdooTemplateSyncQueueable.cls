/**
 * Created by fpardon on 07/09/2023.
 */

public class OdooTemplateSyncQueueable implements Queueable, Database.AllowsCallouts {

    public Integer offset;
    public Integer limiter = 200;
    public Boolean isSandbox;
    public String environment;

    /* Constructors */

    public OdooTemplateSyncQueueable(Integer offset, Integer limiter){
        this.offset = offset;
        this.limiter = limiter;
        this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        this.environment = this.isSandbox ? 'Sandbox' : 'Production';
    }

    public void execute(QueueableContext context){
        syncTemplates(offset, limiter);
    }

    public void syncTemplates(Integer offset, Integer limiter) {

        Callout callout = Callout.prepareCallout(this.environment, 'Package', offset, limiter);
        CalloutHandler calloutHandler = new CalloutHandler();
        HttpResponse response = calloutHandler.makeCallout(callout);

        //If the response is 200, parse the response and upsert the products
        if (response.getStatusCode() == 200) {
            OdooTemplate templateData = OdooTemplate.parse(response.getBody());
            parseOdooTemplates(templateData);
        }
    }

    public static void parseOdooTemplates(OdooTemplate templateData){

        List<Package__c> packages = new List<Package__c>();
        List<Package_Line__c> packageLines = new List<Package_Line__c>();

        for(OdooTemplate.data data : templateData.data){

            Package__c packageRec = new Package__c();
            packageRec.Name = data.attributes.name;
            packageRec.Odoo_Id__c = data.id;
            packageRec.Date_From__c = data.attributes.date_from != null ? Date.valueOf(data.attributes.date_from) : null;
            packageRec.Date_To__c = data.attributes.date_to != null ? Date.valueOf(data.attributes.date_to) : null;
            packageRec.Package_Type__c = data.attributes.package_type;
            //convert the allowed_pricelist_ids to a string separated by ;
            String allowedPricelists = '';
            for(String pricelist : data.attributes.allowed_pricelist_ids){
                allowedPricelists += pricelist + ';';
            }
            System.debug('allowedPricelists: ' + allowedPricelists);
            packageRec.Allowed_PriceList_Ids__c = allowedPricelists;
            packages.add(packageRec);
            for(OdooTemplate.template_line_ids templateLine : data.attributes.template_line_ids) {

                if(allowedPricelists == null || allowedPricelists == ''){
                    Package_Line__c packageLine = new Package_Line__c();
                    packageLine.Package__r = new Package__c(Odoo_Id__c = data.id);
                    packageLine.Product__r = new Product2(Odoo_ID__c = templateLine.attributes.product_id);
                    packageLine.Quantity__c = templateLine.attributes.uom_qty;
                    packageLine.Odoo_Id__c = templateLine.id;
                    packageLine.External_Id__c = templateLine.id + '-' + '0';
                    if(packageLines.contains(packageLine) == false){
                    packageLines.add(packageLine);
                    }

                } else {
                    for (String priceList : data.attributes.allowed_pricelist_ids) {
                        Package_Line__c packageLine = new Package_Line__c();
                        packageLine.Package__r = new Package__c(Odoo_Id__c = data.id);
                        packageLine.Product__r = new Product2(Odoo_ID__c = templateLine.attributes.product_id);
                        packageLine.Quantity__c = templateLine.attributes.uom_qty;
                        packageLine.Odoo_Id__c = templateLine.id + Integer.valueOf(priceList);
                        packageLine.External_Id__c = templateLine.id + '-' + priceList;
                        packageLine.Price_Book__r = new Pricebook2(Odoo_Id__c = Integer.valueOf(priceList));
                        if(packageLines.contains(packageLine) == false){
                            packageLines.add(packageLine);
                        }
                    }
                }
            }
        }

        Schema.SObjectField pId = Package__c.Fields.Odoo_ID__c;
        Schema.SObjectField plId = Package_Line__c.Fields.External_Id__c;

        System.debug('upserting packages');
        List<Database.UpsertResult> packageUpserts = DMLHandler.upsertRecordsWithReturn(pId, packages);
        System.debug('upserting package lines');
        List<Database.UpsertResult> packageLineUpserts = DMLHandler.upsertRecordsWithReturn(plId, packageLines);

        OdooTemplate.meta meta = templateData.meta;

        System.debug('meta: ' + meta);

        if(meta.offset + meta.limit_x < meta.total){
            system.debug('meta.offset: ' + meta.offset);
            system.debug('meta.limit_x: ' + meta.limit_x);
            system.debug('meta.total: ' + meta.total);
            OdooTemplateSyncQueueable sync = new OdooTemplateSyncQueueable(meta.offset + meta.limit_x, meta.limit_x );
            System.enqueueJob(sync);
        } else {
            System.debug('No more records to sync');
            PackageLineHandlerBatch packageBatch = new PackageLineHandlerBatch();
            Id batchId = Database.executeBatch(packageBatch, 100);
        }
    }

}