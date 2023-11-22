/**

Created: 30/08/2023
Last Updated: 30/08/2023

@Description: Main class for handling the parsing and upsert of accounts and contacts from Odoo

@Change Log:
    30/08/2023 - Upeo - Initial Creation
    30/08/2023 - Upeo - Added parsePartnerToAccount method
    30/08/2023 - Upeo - Added mapAccount method
    30/08/2023 - Upeo - Added mapContact method
    30/08/2023 - Upeo - Added parseDMLResults method

@Dependencies:
    DMLHandler.cls

@Test Classes:

*/

public without sharing class OdooPartnerService {

    //********************************************************* Main *********************************************************//

    /**
     * @description:
     * Parses and handles the upsert of an account or contact from a PartnerWrapper.Data object
     * The PartnerWrapper.Data object is the data object returned from the Odoo API
     *
     * @param partnerBody accepts a PartnerWrapper.Data object
     * @param partnerType accepts a string with the value of either 'Company' or 'Contact'
     * @return List<String> - the ids of the upserted accounts or contacts
     */

    public static Map<Integer, String> parsePartnerToAccount(List<OdooPartner.Data> partnerBody, String partnerType){

        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        Map<Integer, String> odooIdToSalesforceId = new Map<Integer, String>();
        Schema.SObjectField aId = Account.Fields.Odoo_ID__c;
        Schema.SObjectField cId = Contact.Fields.Odoo_ID__c;
        String recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer' LIMIT 1].Id;
        String recordTypeProspect = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Prospect' LIMIT 1].Id;

        //system.debug('partnerType: ' + partnerType);
        //system.debug('partnerBody: ' + partnerBody);

        List<Odoo_Config__c> allConfigs = [SELECT Text_Value__c, Table__c, Identifier__c FROM Odoo_Config__c];
        Map<String, Integer> configTextToIdMap = new Map<String, Integer>();
        Map<String, String> configIdentifierToTextMap = new Map<String, String>();
        for(Odoo_Config__c config : allConfigs){
            configTextToIdMap.put(config.Table__c + config.Text_Value__c, Integer.valueOf(config.Identifier__c));
            configIdentifierToTextMap.put(config.Table__c + config.Identifier__c, config.Text_Value__c);
        }

        //system.debug('configTextToIdMap: ' + configTextToIdMap);
        //system.debug('configIdentifierToTextMap: ' + configIdentifierToTextMap);


        //Check what the type attribute value is, based on that we create either a contact or and account

        for(OdooPartner.Data partner : partnerBody){
            odooIdToSalesforceId.put(partner.id, null);
            if((partner.attributes.company_type == 'company' && partnerType == 'company') || (partner.attributes.company_type == 'person' && partnerType == 'person' && partner.attributes.type == 'delivery') || (partner.attributes.company_type == 'person' && partnerType == 'company' && partner.attributes.type == 'delivery')){
                Account account = mapAccount(partner);
                account.RecordTypeId = partner.attributes.prospect ? recordTypeProspect : recordType;
                account.Tax_Status__c = partner.attributes.fiscal_position != null ? configIdentifierToTextMap.get('Fiscal_Position' + partner.attributes.fiscal_position) : null;
                account.Shipping_Ranking__c = partner.attributes.ranking != null ? configIdentifierToTextMap.get('Ranking' + partner.attributes.ranking) : null;
                if(partner.attributes.labels != null){
                    String labels = '';
                    for(Integer label : partner.attributes.labels){
                        labels += configIdentifierToTextMap.get('Labels' + label) + ';';
                    }
                    account.Labels__c = labels;
                }
                account.Delivery_Method__c = partner.attributes.delivery_method != null ? configIdentifierToTextMap.get('Delivery_Carrier' + partner.attributes.delivery_method) : null;
                account.Invoicing_Criteria__c = partner.attributes.invoicing_criteria_id != null ? configIdentifierToTextMap.get('Sale_Invoice_Grouping' + partner.attributes.invoicing_criteria_id) : null;
                account.Client_Support__r = partner.attributes.client_support!= null ? new User(Odoo_Sales_Person__c = configIdentifierToTextMap.get('User' + partner.attributes.client_support)) : null;
                account.Sales_Person__r = partner.attributes.sales_person != null ? new User(Odoo_Sales_Person__c = configIdentifierToTextMap.get('User' + partner.attributes.sales_person)) : null;
                account.Owner = partner.attributes.sales_person != null ? new User(Odoo_Sales_Person__c = configIdentifierToTextMap.get('User' + partner.attributes.sales_person)) : null;
                accounts.add(account);
            }
            if(partner.attributes.company_type == 'person' && partnerType == 'person' && partner.attributes.name != null){
                Contact contact = mapContact(partner);
                contacts.add(contact);
            }
        }

        //system.debug(contacts);

        //Upsert the accounts
        List<Database.UpsertResult> accountUpserts = DMLHandler.upsertRecordsWithReturn(aId, accounts);
        for(Database.UpsertResult result : accountUpserts){
            if(!result.isSuccess()){
                System.debug('result: ' + result);
            }
        }
        Map<Integer, String> accountIdMap = parseDMLResults(accountUpserts, accounts);

        //Upsert the contacts
        List<Database.UpsertResult> contactUpserts = DMLHandler.upsertRecordsWithReturn(cId, contacts);
        for(Database.UpsertResult result : contactUpserts){
            ////system.debug(result);
        }
        Map<Integer, String> contactIdMap = parseDMLResults(contactUpserts, contacts);

        //Merge the two maps
        accountIdMap.putAll(contactIdMap);
        return accountIdMap;
    }

    /**
     * @param accounts: list of accounts to be parsed
     *
     *
     */

    public static void parseAccountToPartner(List<Account> accounts){

        OdooPartner partnerWrapperPost = new OdooPartner();
        List<OdooPartner.Data> partnerWrapperPostData = new List<OdooPartner.Data>();

        OdooPartner partnerWrapperPatch = new OdooPartner();
        List<OdooPartner.Data> partnerWrapperPatchData = new List<OdooPartner.Data>();
        partnerWrapperPatch.data = new List<OdooPartner.Data>();

        for(Account a : accounts){
            //system.debug(a);
            OdooPartner.Data data = mapAccountToPartner(a);
            //system.debug(data);
            if(data.attributes.operation == 'create'){
                data.attributes.operation = null;
                partnerWrapperPostData.add(data);
            }
            else if(data.attributes.operation == 'update'){
                data.attributes.operation = null;
                partnerWrapperPatchData.add(data);
            }
        }

        partnerWrapperPost.data = partnerWrapperPostData;
        partnerWrapperPatch.data = partnerWrapperPatchData;

        if(partnerWrapperPost.data.size() > 0){
            for(OdooPartner.Data d : partnerWrapperPost.data){
                postAccount(d);
            }
        }
        if(partnerWrapperPatch.data.size() > 0){
            for(OdooPartner.Data d : partnerWrapperPatch.data){
                patchAccount(d);
            }
        }

    }

    /**
     * @param contacts: list of contacts to be parsed
     *
     *
     */

    public static void parseContactToPartner(List<Contact> contacts){

        OdooPartner partnerWrapperPost = new OdooPartner();
        partnerWrapperPost.data = new List<OdooPartner.Data>();

        OdooPartner partnerWrapperPatch = new OdooPartner();
        partnerWrapperPatch.data = new List<OdooPartner.Data>();

        for(Contact c : contacts){
            //system.debug(c);
            OdooPartner.Data data = mapContactToPartner(c);
            if(data.attributes.operation == 'create'){
                data.attributes.operation = null;
                partnerWrapperPost.data.add(data);
            }
            else if(data.attributes.operation == 'update'){
                data.attributes.operation = null;
                partnerWrapperPatch.data.add(data);
            }
        }

        if(partnerWrapperPost.data.size() > 0){
            for(OdooPartner.Data d : partnerWrapperPost.data){
                postContact(d);
            }
        }
        if(partnerWrapperPatch.data.size() > 0){
            for(OdooPartner.Data d : partnerWrapperPatch.data){
                patchContact(d);
            }
        }




    }

    //********************************************************* Mappers *********************************************************//

    public static OdooPartner.Data mapAccountToPartner(Account a){

        Account acc = [SELECT Price_Book__r.Odoo_ID__c, Website, Delivery_Method__c, Parent.Odoo_ID__c, Invoicing_Criteria__c, Labels__c, RecordType.DeveloperName, Tax_Status__c, Owner.Odoo_Sales_Person__c, Client_Support__r.Odoo_Sales_Person__c, Delivery_Address__c, Website__c FROM Account WHERE Id = :a.Id];
        Decimal Pricebook2Id = acc.Price_Book__r.Odoo_ID__c;

        Boolean isPatch = a.Odoo_ID__c == null ? false : true;

        List<Integer> labels = new List<Integer>();
        if(acc.Labels__c != null){
            if(acc.Labels__c.contains(';')){
                for(String label : acc.Labels__c.split(';')){
                    labels.add(OdooConfigHelper.getIdentifierFromText(label, 'Labels'));
                }
            }
            else{
                labels.add(OdooConfigHelper.getIdentifierFromText(acc.Labels__c, 'Labels'));
            }
        }

        String website;

        if(acc.Website__c == null){
            website = null;
        } else if(acc.Website__c == 'Cent Pur Cent'){
            website = 'https://www.ordersrigorgeous.be';
        } else {
            website = 'https://www.iak.ordersrigorgeous.be';
        }

        //system.debug('labels: ' + labels);

        OdooPartner.Data data = new OdooPartner.Data();
        data.attributes = new OdooPartner.Attributes();
        data.id = Integer.valueOf(a.Odoo_ID__c) == null ? null : Integer.valueOf(a.Odoo_ID__c);
        data.type = 'res_partner';
        data.attributes.parent_odoo = acc.Parent.Odoo_ID__c != null ? Integer.valueOf(acc.Parent.Odoo_ID__c) : null;
        data.attributes.name = a.Name;
        data.attributes.street = acc.Delivery_Address__c == false ? a.BillingStreet : a.ShippingStreet;
        data.attributes.city = acc.Delivery_Address__c == false ? a.BillingCity : a.ShippingCity;
        data.attributes.postal_code = acc.Delivery_Address__c == false ? a.BillingPostalCode : a.ShippingPostalCode;
        data.attributes.country_iso_code = acc.Delivery_Address__c == false ? a.BillingCountryCode : a.ShippingCountryCode;
        data.attributes.email = Integer.valueOf(a.Odoo_ID__c) == null ? a.Email__c : null;
        data.attributes.language = a.Language__c;
        data.attributes.pricelist_odoo_id = Pricebook2Id != null ? Integer.valueOf(Pricebook2Id): null;
        data.attributes.salesforce_identifier = !isPatch ? a.Id : null;
        data.attributes.labels = labels;
        data.attributes.distribution_channel = a.Channel__c;
        data.attributes.sub_distribution_channel = a.Subchannel__c;
        data.attributes.phone = a.Phone;
        data.attributes.fiscal_position = OdooConfigHelper.getIdentifierFromText(acc.Tax_Status__c, 'Fiscal_Position');
        //data.attributes.loyalty_points = a.Loyaltypoints__c;
        data.attributes.website = website;
        data.attributes.website_url = acc.Website;
        data.attributes.active = a.Active_Customer__c;
        data.attributes.company_type = !isPatch ? 'company' : null;
        data.attributes.type = isPatch && a.Delivery_Address__c == true ? 'delivery' : null;
        data.attributes.vat = !isPatch ? a.VAT_Number__c : null;
        data.attributes.ranking = OdooConfigHelper.getIdentifierFromText(a.Shipping_Ranking__c,'Ranking');
        data.attributes.operation = a.Odoo_ID__c == null ? 'create' : 'update';
        data.attributes.sales_person = acc.Owner.Odoo_Sales_Person__c != null ? OdooConfigHelper.getIdentifierFromText(acc.Owner.Odoo_Sales_Person__c, 'User') : null;
        data.attributes.client_support = acc.Client_Support__r.Odoo_Sales_Person__c != null ? OdooConfigHelper.getIdentifierFromText(acc.Client_Support__r.Odoo_Sales_Person__c, 'User') : null;
        data.attributes.delivery_method = OdooConfigHelper.getIdentifierFromText(a.Delivery_Method__c, 'Delivery_Carrier');
        data.attributes.invoicing_criteria_id = OdooConfigHelper.getIdentifierFromText(a.Invoicing_Criteria__c, 'Sale_Invoice_Grouping');
        data.attributes.prospect = acc.RecordType.DeveloperName == 'Prospect' ? true : false;
        return data;
    }

    public static OdooPartner.Data mapContactToPartner(Contact c){
        OdooPartner.Data data = new OdooPartner.Data();
        data.attributes = new OdooPartner.Attributes();
        data.id = Integer.valueOf(c.Odoo_ID__c) == null ? null : Integer.valueOf(c.Odoo_ID__c);
        data.type = 'res_partner';
        data.attributes.name = c.FirstName + ' ' +c.LastName;
        data.attributes.street = c.MailingStreet;
        data.attributes.city = c.MailingCity;
        data.attributes.postal_code = c.MailingPostalCode;
        data.attributes.country_iso_code = c.MailingCountryCode;
        data.attributes.salesforce_identifier = Integer.valueOf(c.Odoo_ID__c) == null ? c.Id : null;
        data.attributes.company_type = Integer.valueOf(c.Odoo_ID__c) == null ? 'person' : null;
        data.attributes.labels = new List<Integer>();
        data.attributes.distribution_channel = 'B2B';
        data.attributes.sub_distribution_channel = 'Divers';
        data.attributes.email = Integer.valueOf(c.Odoo_ID__c) == null ? c.Email : null;
        data.attributes.pricelist_odoo_id = Integer.valueOf(c.Odoo_ID__c) == null ? Integer.valueOf(c.Odoo_ID__c) : null;
        data.attributes.vat = Integer.valueOf(c.Odoo_ID__c) == null ? '' : null;
        data.attributes.operation = c.Odoo_ID__c == null ? 'create' : 'update';
        //system.debug('data = ' + data);
        return data;
    }


    /**
    *    Handles the upsert of a single Account
    *    @param partnerWrapper - the wrapper containing the account to be upserted
    *    @return String - the id of the upserted account
    */
    public static Account mapAccount(OdooPartner.Data partnerWrapper){

        String website;

        if(partnerWrapper.attributes.website == 'https://www.ordersrigorgeous.be'){
            website = 'Cent Pur Cent';
        } else if(partnerWrapper.attributes.website == 'https://www.iak.ordersrigorgeous.be'){
            website = 'I.am.Klean';
        } else {
            website = null;
        }

        //system.debug('attributes: '+ partnerWrapper.attributes.sales_person);
        Account a = new Account();
        a.Name = partnerWrapper.attributes.name;
        a.Odoo_ID__c = partnerWrapper.id;
        a.Parent = partnerWrapper.attributes.parent_odoo != null ? new Account(Odoo_ID__c = Integer.valueOf(partnerWrapper.attributes.parent_odoo)) : null;
        a.Delivery_Address__c = partnerWrapper.attributes.parent_odoo == null ? true : false;
        a.BillingStreet = partnerWrapper.attributes.parent_odoo == null ? partnerWrapper.attributes.street : null;
        a.BillingCity = partnerWrapper.attributes.parent_odoo == null ? partnerWrapper.attributes.city : null;
        a.BillingPostalCode = partnerWrapper.attributes.parent_odoo == null ? partnerWrapper.attributes.postal_code : null;
        a.BillingCountryCode = partnerWrapper.attributes.parent_odoo == null ? partnerWrapper.attributes.country_iso_code : null;
        a.ShippingStreet = partnerWrapper.attributes.parent_odoo != null ? partnerWrapper.attributes.street : null;
        a.ShippingCity = partnerWrapper.attributes.parent_odoo != null ? partnerWrapper.attributes.city : null;
        a.ShippingPostalCode = partnerWrapper.attributes.parent_odoo != null ? partnerWrapper.attributes.postal_code : null;
        a.ShippingCountryCode = partnerWrapper.attributes.parent_odoo != null ? partnerWrapper.attributes.country_iso_code : null;
        a.Channel__c = partnerWrapper.attributes.distribution_channel;
        a.Subchannel__c = partnerWrapper.attributes.sub_distribution_channel;
        a.Website = partnerWrapper.attributes.website_url;
        a.Website__c = website;
        a.Email__c = partnerWrapper.attributes.email != null && partnerWrapper.attributes.email.contains('@') ? partnerWrapper.attributes.email : null;
        a.Phone = partnerWrapper.attributes.phone;
        a.Mobile_Phone__c = partnerWrapper.attributes.mobile;
        a.Language__c = partnerWrapper.attributes.language;
        a.Loyaltypoints__c = partnerWrapper.attributes.loyalty_points;
        a.Start__c = partnerWrapper.attributes.start != null ? Date.valueOf(partnerWrapper.attributes.start) : null;
        a.End__c = partnerWrapper.attributes.end_Z != null ? Date.valueOf(partnerWrapper.attributes.end_Z) : null;
        a.SO_Visible_on_Invoice__c = partnerWrapper.attributes.sale_order_on_invoice_line;
        a.Active_Customer__c = partnerWrapper.attributes.active;
        a.VAT_Number__c = partnerWrapper.attributes.vat;
        a.Price_Book__r = new Pricebook2(Odoo_ID__c = partnerWrapper.attributes.pricelist_odoo_id);
        a.Odoo_Parent_Id__c = partnerWrapper.attributes.parent_odoo;

        if(partnerWrapper.attributes.loyalty_program_ids != null && partnerWrapper.attributes.loyalty_program_ids.size() > 0){
            a.Loyalty_Program__r = New Loyalty_Program__c(Odoo_Id__c = partnerWrapper.attributes.loyalty_program_ids[0]);
        }

        //System.debug('Account after mapping: ' + a);

        return a;

    }

    public static Contact mapContact(OdooPartner.Data partnerWrapper){


        Contact c = new Contact();
        if(partnerWrapper.attributes.name.contains(' ')){
            c.FirstName = partnerWrapper.attributes.name.substringBefore(' ');
            c.LastName = partnerWrapper.attributes.name.substringAfter(' ');
        }
        else{
            c.LastName = partnerWrapper.attributes.name;
        }
        c.Odoo_ID__c = partnerWrapper.id;
        c.MailingStreet = partnerWrapper.attributes.street;
        c.MailingCity = partnerWrapper.attributes.city;
        c.MailingPostalCode = partnerWrapper.attributes.postal_code;
        c.Title = partnerWrapper.attributes.title;
        c.Email = partnerWrapper.attributes.email;
        c.Phone = partnerWrapper.attributes.phone;
        c.Language__c = partnerWrapper.attributes.language;
        if(partnerWrapper.attributes.parent_odoo != null){
            try{
                c.Account = new Account(Odoo_ID__c = Integer.valueOf(partnerWrapper.attributes.parent_odoo));
            }
            catch(Exception e){
                //system.debug(e);
            }
        }
        //Extra fields to be mapped
        //system.debug(c);

        return c;

    }

    //********************************************************* Helpers *********************************************************//

    /**
    *   @description: Handles the POST of a single account to Odoo
    *   @param partnerWrapper - the account to be posted
    *   @return void
    */

    public static void postAccount(OdooPartner.Data partnerWrapper){

        system.debug('POST');

        OdooPartner partnerWrapperPost = new OdooPartner();
        partnerWrapperPost.dataSingle = partnerWrapper;

        String body = JSON.serialize(partnerWrapperPost, true);
        body = body.replace('dataSingle', 'data');

        system.debug(body);

        Callout callout = Callout.preparePostCallout('partner', body);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse response = ch.makeCallout(callout);

        String responseString = response.getBody();

        if(response.getStatusCode() == 200){
            //system.debug('Success');
            //system.debug(response.getBody());
            OdooPartner.Data responseWrapper = OdooPartner.parsePartnerData(response.getBody());
            //system.debug(responseWrapper);
            Account a = new Account();
            a.Odoo_ID__c = responseWrapper.id;
            a.Id = partnerWrapper.attributes.salesforce_identifier;
            a.Sent_to_Odoo__c = false;
            //system.debug('Account: ' +a);
            update a;
        }
        else{
            //system.debug('Failure');
            //system.debug(response.getBody());
            Account a = new Account();
            a.Id = partnerWrapper.attributes.salesforce_identifier;
            a.Sent_to_Odoo__c = false;
            update a;
            errorLogger(response.getBody(), body, 'create', 'Account');
        }

    }

    public static void patchAccount(OdooPartner.Data partnerWrapper){

        //system.debug('PATCH');

        OdooPartner partnerWrapperPost = new OdooPartner();
        partnerWrapperPost.dataSingle = partnerWrapper;

        Integer parent_odoo = partnerWrapper.attributes.parent_odoo;
        System.debug('parent_odoo: ' + parent_odoo);

        if(parent_odoo == null){
            partnerWrapperPost.dataSingle.attributes.parent_odoo = 9999999;
        }

        String body = JSON.serialize(partnerWrapperPost, true);
        //system.debug('!!!!!!!!!!!!!!!! ' +body);
        body = body.replace('dataSingle', 'data');
        body = body.replace('9999999', 'null');

        System.debug('body: ' + body);

        String responseString;

        Callout callout = Callout.preparePatchCallout('partner', body, partnerWrapper.id);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse response = ch.makeCallout(callout);


        if(response.getStatusCode() == 200){
            //system.debug('Success');
            //system.debug(response.getBody());
            Account a = new Account();
            a.Odoo_ID__c = partnerWrapper.id;
            a.Sent_to_Odoo__c = false;
            upsert a Odoo_ID__c;
        }
        else{
            Account a = new Account();
            a.Odoo_ID__c = partnerWrapper.id;
            a.Sent_to_Odoo__c = false;
            upsert a Odoo_ID__c;
            //system.debug('Failure');
            //system.debug(response.getBody());
            errorLogger(response.getBody(), body, 'update', 'Account');
        }

    }

    public static void postContact(OdooPartner.Data partnerWrapper){

        OdooPartner partnerWrapperPost = new OdooPartner();
        partnerWrapperPost.dataSingle = partnerWrapper;

        String body = JSON.serialize(partnerWrapperPost, true);
        body = body.replace('dataSingle', 'data');

        Callout callout = Callout.preparePostCallout('partner', body);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse response = ch.makeCallout(callout);

        String responseString = response.getBody();

        if(response.getStatusCode() == 200){
            //system.debug('Success');
            OdooPartner.Data responseWrapper = OdooPartner.parsePartnerData(response.getBody());
            //system.debug(responseWrapper);
            Contact contact = new Contact();
            contact.Odoo_ID__c = responseWrapper.id;
            contact.Id = partnerWrapper.attributes.salesforce_identifier;
            contact.Sent_To_Odoo__c = false;
            update contact;
        }
        else{
            //system.debug('Failure');
            Contact c = new Contact();
            c.Id = partnerWrapper.attributes.salesforce_identifier;
            c.Sent_To_Odoo__c = false;
            update c;
            //system.debug(response.getBody());
            errorLogger(response.getBody(), body, 'create', 'Contact');
        }

    }

    public static void patchContact(OdooPartner.Data partnerWrapper){
        OdooPartner partnerWrapperPost = new OdooPartner();
        partnerWrapperPost.dataSingle = partnerWrapper;

        String body = JSON.serialize(partnerWrapperPost, true);
        body = body.replace('dataSingle', 'data');

        //system.debug('body: ' +body);

        Callout callout = Callout.preparePatchCallout('partner', body, partnerWrapper.id);
        CalloutHandler ch = new CalloutHandler();
        HttpResponse response = ch.makeCallout(callout);

        if(response.getStatusCode() == 200){
            //system.debug('Success');
            OdooPartner.Data responseWrapper = OdooPartner.parsePartnerData(response.getBody());
            Contact contact = new Contact();
            contact.Odoo_ID__c = responseWrapper.id;
            contact.Sent_To_Odoo__c = false;
            upsert contact Odoo_ID__c;
            //system.debug(responseWrapper);
        }
        else{
            //system.debug('Failure');
            Contact c = new Contact();
            c.Odoo_ID__c = partnerWrapper.id;
            c.Sent_To_Odoo__c = false;
            upsert c Odoo_ID__c;
            //system.debug(response.getBody());
            errorLogger(response.getBody(), body, 'update', 'Contact');
        }
    }

    public static Map<Integer, String> parseDMLResults(List<Database.UpsertResult> results, List<SObject> records){

        //Return a list of the ids of the upserted records
        Map<Integer, String> resultMap = new Map<Integer, String>();

        //Loop through the results and add the id to the map if the result is a success
        //Add the error message to the map if the result is a failure
        for(Integer i = 0; i < results.size(); i++){
            Database.UpsertResult result = results[i];
            SObject record = records[i];
            if(result.isSuccess()){
                resultMap.put(Integer.valueOf(record.get('Odoo_ID__c')), record.Id);
            }
            else{
                System.debug(result.getErrors()[0].getMessage());
                System.debug(result.getErrors()[0].getFields());
                resultMap.put(Integer.valueOf(record.get('Odoo_ID__c')), result.getErrors()[0].getMessage());
            }
        }

        return resultMap;

    }

    public static void errorLogger(String errorMessage, String payload, String operation, String objectName){

        String sobjectType = objectName;
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Error_Message__c = 'Error Message: ' + errorMessage;
        errorLog.Payload__c = String.valueOf(payload).left(30000);
        errorLog.DML_Operation__c = operation;
        errorLog.Object__c = sobjectType;

        //insert errorLog;

    }

}