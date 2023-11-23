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
 * Created: 18/09/2023
 * Last Updated: 18/09/2023
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
private class OdooPartnerServiceTest {

    @TestSetup
    static void setup() {



        String json=
                '{'+
                '    "meta": {'+
                '        "total": 3,'+
                '        "size": 3,'+
                '        "limit": 3,'+
                '        "offset": 0'+
                '    },'+
                '    "data": ['+
                '        {'+
                '            "id": 105040,'+
                '            "type": "res_partner",'+
                '            "attributes": {'+
                '                "name": "𝑩𝒊𝒂𝒏𝒄𝒂. Jellema",'+
                '                "parent_odoo": null,'+
                '                "street": "Westelijk achterom 11",'+
                '                "city": "Tzum",'+
                '                "postal_code": "8804 ND",'+
                '                "country_iso_code": "NL",'+
                '                "description_html": null,'+
                '                "email": "biancajellema@outlook.com",'+
                '                "mobile": null,'+
                '                "phone": "621687731",'+
                '                "website": null,'+
                '                "language": "nl_BE",'+
                '                "pricelist_odoo_id": 666,'+
                '                "title": null,'+
                '                "vat": null,'+
                '                "company_type": "person",'+
                '                "type": "invoice",'+
                '                "child_ids": ['+
                '                    131259'+
                '                ],'+
                '                "salesforce_identifier": null,'+
                '                "ranking": null,'+
                '                "labels": [],'+
                '                "distribution_channel": null,'+
                '                "sub_distribution_channel": null,'+
                '                "sales_person": null,'+
                '                "fiscal_position": null,'+
                '                "loyalty_points": 0,'+
                '                "disable_loyalty_points": false,'+
                '                "delivery_method": 2,'+
                '                "sale_order_on_invoice_line": false,'+
                '                "client_support": null,'+
                '                "start": null,'+
                '                "end": null,'+
                '                "active": true,'+
                '                "prospect": true'+
                '            }'+
                '        },'+
                '        {'+
                '            "id": 22735,'+
                '            "type": "res_partner",'+
                '            "attributes": {'+
                '                "name": "Arristo",'+
                '                "parent_odoo": null,'+
                '                "street": "Bedrijvenzone Machelen",'+
                '                "city": "Machelen",'+
                '                "postal_code": "1830",'+
                '                "country_iso_code": "BE",'+
                '                "description_html": "<p><br></p>",'+
                '                "email": "sales@arristo.be",'+
                '                "mobile": null,'+
                '                "phone": null,'+
                '                "website": null,'+
                '                "language": "nl_BE",'+
                '                "pricelist_odoo_id": 666,'+
                '                "title": null,'+
                '                "vat": "BE0691733526",'+
                '                "company_type": "company",'+
                '                "type": "contact",'+
                '                "child_ids": [],'+
                '                "salesforce_identifier": null,'+
                '                "ranking": 32,'+
                '                "labels": ['+
                '                    1578'+
                '                ],'+
                '                "distribution_channel": "B2B",'+
                '                "sub_distribution_channel": "Divers",'+
                '                "sales_person": 2,'+
                '                "fiscal_position": 1,'+
                '                "loyalty_points": 0,'+
                '                "disable_loyalty_points": false,'+
                '                "delivery_method": 3,'+
                '                "sale_order_on_invoice_line": true,'+
                '                "client_support": null,'+
                '                "start": null,'+
                '                "end": null,'+
                '                "active": true,'+
                '                "prospect": false'+
                '            }'+
                '        }'+
                '    ]'+
                '}';

        String postJSON=		'{'+
                '    "data": {'+
                '        "id": 22735,'+
                '        "type": "res_partner",'+
                '        "attributes": {'+
                '            "name": "Arristo",'+
                '            "parent_odoo": null,'+
                '            "street": "Bedrijvenzone Machelen",'+
                '            "city": "Machelen",'+
                '            "postal_code": "1830",'+
                '            "country_iso_code": "BE",'+
                '            "description_html": "<p><br></p>",'+
                '            "email": "sales@arristo.be",'+
                '            "mobile": null,'+
                '            "phone": null,'+
                '            "website": null,'+
                '            "language": "nl_BE",'+
                '            "pricelist_odoo_id": 666,'+
                '            "title": null,'+
                '            "vat": "BE0691733526",'+
                '            "company_type": "company",'+
                '            "type": "contact",'+
                '            "child_ids": [],'+
                '            "salesforce_identifier": null,'+
                '            "ranking": 32,'+
                '            "labels": ['+
                '                1578'+
                '            ],'+
                '            "distribution_channel": "B2B",'+
                '            "sub_distribution_channel": "Divers",'+
                '            "sales_person": 2,'+
                '            "fiscal_position": 1,'+
                '            "loyalty_points": 0,'+
                '            "disable_loyalty_points": false,'+
                '            "delivery_method": 3,'+
                '            "sale_order_on_invoice_line": true,'+
                '            "client_support": null,'+
                '            "start": null,'+
                '            "end": null,'+
                '            "active": true,'+
                '            "prospect": true'+
                '        }'+
                '    }'+
                '}';

        String postContactJson=		'{'+
                '    "data": {'+
                '        "id": 105040,'+
                '        "type": "res_partner",'+
                '        "attributes": {'+
                '            "name": "𝑩𝒊𝒂𝒏𝒄𝒂. Jellema",'+
                '            "parent_odoo": null,'+
                '            "street": "Westelijk achterom 11",'+
                '            "city": "Tzum",'+
                '            "postal_code": "8804 ND",'+
                '            "country_iso_code": "NL",'+
                '            "description_html": "<p><br></p>",'+
                '            "email": "biancajellema@outlook.com",'+
                '            "mobile": null,'+
                '            "phone": "621687731",'+
                '            "website": null,'+
                '            "language": "nl_BE",'+
                '            "pricelist_odoo_id": 666,'+
                '            "title": null,'+
                '            "vat": null,'+
                '            "company_type": "person",'+
                '            "type": "invoice",'+
                '            "child_ids": ['+
                '                131259'+
                '            ],'+
                '            "salesforce_identifier": null,'+
                '            "ranking": 6,'+
                '            "labels": [],'+
                '            "distribution_channel": "B2C",'+
                '            "sub_distribution_channel": "Pop_up",'+
                '            "sales_person": null,'+
                '            "fiscal_position": null,'+
                '            "loyalty_points": 0,'+
                '            "disable_loyalty_points": false,'+
                '            "delivery_method": 3,'+
                '            "sale_order_on_invoice_line": false,'+
                '            "client_support": null,'+
                '            "start": null,'+
                '            "end": "2023-09-22 10:13:02",'+
                '            "active": true'+
                '        }'+
                '    }'+
                '}';

        SingleRequestMock mock = new SingleRequestMock(
                200,
                'complete',
                json,
                null
        );

        SingleRequestMock mockPatch = new SingleRequestMock(
                200,
                'complete',
                postJSON,
                null
        );

        SingleRequestMock mockPatchContact = new SingleRequestMock(
                200,
                'complete',
                postContactJson,
                null
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:OdooSync/partner?offset=0&limit=1000', mock);
        endpoint2TestResp.put('callout:Odoo/partner/22735', mockPatch);
        endpoint2TestResp.put('callout:Odoo/partner/105040', mockPatchContact);
        endpoint2TestResp.put('callout:Odoo/partner', mockPatch);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        List<Odoo_Config__c> config = new List<Odoo_Config__c>();
        Odoo_Config__c userAdmin = new Odoo_Config__c();
        userAdmin.Text_Value__c = 'Administrator';
        userAdmin.Table__c = 'User';
        userAdmin.Identifier__c = 2;

        Odoo_Config__c rankingNVT = new Odoo_Config__c();
        rankingNVT.Text_Value__c = 'NVT';
        rankingNVT.Table__c = 'Ranking';
        rankingNVT.Identifier__c = 32;

        Odoo_Config__c rankingC = new Odoo_Config__c();
        rankingC.Text_Value__c = 'C';
        rankingC.Table__c = 'Ranking';
        rankingC.Identifier__c = 6;

        Odoo_Config__c deliveryCarrierBpost = new Odoo_Config__c();
        deliveryCarrierBpost.Text_Value__c = 'Bpost World Business Nl/GER/FR/LUX';
        deliveryCarrierBpost.Table__c = 'Delivery_Carrier';
        deliveryCarrierBpost.Identifier__c = 2;

        Odoo_Config__c deliveryCarrierBPost24 = new Odoo_Config__c();
        deliveryCarrierBPost24.Text_Value__c = 'Bpost Bpack 24h Business BE';
        deliveryCarrierBPost24.Table__c = 'Delivery_Carrier';
        deliveryCarrierBPost24.Identifier__c = 3;

        Odoo_Config__c labelsLeverancier = new Odoo_Config__c();
        labelsLeverancier.Text_Value__c = 'Leverancier';
        labelsLeverancier.Table__c = 'Labels';
        labelsLeverancier.Identifier__c = 1578;

        Odoo_Config__c fiscalPositionNationalRegime = new Odoo_Config__c();
        fiscalPositionNationalRegime.Text_Value__c = 'National Regime';
        fiscalPositionNationalRegime.Table__c = 'Fiscal_Position';
        fiscalPositionNationalRegime.Identifier__c = 1;


        //Add to list
        config.add(userAdmin);
        config.add(rankingNVT);
        config.add(rankingC);
        config.add(deliveryCarrierBpost);
        config.add(deliveryCarrierBPost24);
        config.add(labelsLeverancier);
        config.add(fiscalPositionNationalRegime);

        insert config;

    }

    @IsTest
    private static void testGetPartnerAccounts() {
        setup();

        Pricebook2 pb = new Pricebook2(
                Name = 'Test',
                IsActive = true,
                Odoo_ID__c = 666
        );
        insert pb;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        System.debug('!!!!!!!!!!!!!!!!!!!!' + environment);

        Test.startTest();
        AsyncOptions asyncOptions = new AsyncOptions();
        System.enqueueJob(new OdooPartnerSyncQueueable(0, false, environment, 'company'), asyncOptions);
        Test.stopTest();

        Account a = [SELECT FIELDS(STANDARD), Odoo_ID__c, Channel__c, Subchannel__c, Website__c, Email__c, Mobile_Phone__c, Language__c, Tax_Status__c, Start__c, End__c, Active_Customer__c, VAT_Number__c, Price_Book__c, Delivery_Method__c, Shipping_Ranking__c, Invoicing_Criteria__c, Delivery_Address__c FROM Account LIMIT 1];
        System.debug(a);
        System.assertEquals('Arristo', a.Name);

    }

    @IsTest
    private static void testGetPartnerAccountsPatch() {
        setup();

        Pricebook2 pb = new Pricebook2(
                Name = 'Test',
                IsActive = true,
                Odoo_ID__c = 666
        );
        insert pb;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';
        System.debug('!!!!!!!!!!!!!!!!!!!!' + environment);

        Test.startTest();
        AsyncOptions asyncOptions = new AsyncOptions();
        System.enqueueJob(new OdooPartnerSyncQueueable(0, false, environment, 'company'), asyncOptions);
        Test.stopTest();

        Account a = [SELECT FIELDS(STANDARD), Odoo_ID__c, Channel__c, Subchannel__c, Website__c, Email__c, Mobile_Phone__c, Language__c, Tax_Status__c, Start__c, End__c, Active_Customer__c, VAT_Number__c, Price_Book__c, Delivery_Method__c, Shipping_Ranking__c, Invoicing_Criteria__c, Delivery_Address__c FROM Account LIMIT 1];
        System.debug(a);
        System.assertEquals('Arristo', a.Name);

        List<Account> accounts = new List<Account>();
        accounts.add(a);
        OdooPartnerService.parseAccountToPartner(accounts);

    }


    @IsTest
    private static void testGetPartnerAccountsPost() {
        setup();

        Pricebook2 pb = new Pricebook2(
                Name = 'Test',
                IsActive = true,
                Odoo_ID__c = 666
        );
        insert pb;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        Test.startTest();
        AsyncOptions asyncOptions = new AsyncOptions();
        System.enqueueJob(new OdooPartnerSyncQueueable(0, false, environment, 'company'), asyncOptions);
        Test.stopTest();

        Account a = [SELECT FIELDS(STANDARD), Odoo_ID__c, Channel__c, Subchannel__c, Website__c, Email__c, Mobile_Phone__c, Language__c, Tax_Status__c, Start__c, End__c, Active_Customer__c, VAT_Number__c, Price_Book__c, Delivery_Method__c, Shipping_Ranking__c, Invoicing_Criteria__c, Delivery_Address__c FROM Account LIMIT 1];
        System.debug(a);
        System.assertEquals('Arristo', a.Name);

        List<Account> accountsToPost = new List<Account>();
        a.Odoo_ID__c = null;
        accountsToPost.add(a);
        OdooPartnerService.parseAccountToPartner(accountsToPost);

    }


    @IsTest
    private static void testGetPartnerContacts() {
        setup();

        Pricebook2 pb = new Pricebook2(
                Name = 'Test',
                IsActive = true,
                Odoo_ID__c = 666
        );
        insert pb;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        Test.startTest();
        AsyncOptions asyncOptions = new AsyncOptions();
        System.enqueueJob(new OdooPartnerSyncQueueable(0, false, environment, 'person'), asyncOptions);
        Test.stopTest();



        List<Contact> contacts = new List<Contact>();
        Contact c = [SELECT FIELDS(STANDARD), Odoo_ID__c, Language__c FROM Contact LIMIT 1];
        System.debug(c);
        contacts.add(c);
        OdooPartnerService.parseContactToPartner(contacts);

    }

    @IsTest
    private static void testGetPartnerContactPOST() {
        setup();

        Pricebook2 pb = new Pricebook2(
                Name = 'Test',
                IsActive = true,
                Odoo_ID__c = 666
        );
        insert pb;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';

        Test.startTest();
        AsyncOptions asyncOptions = new AsyncOptions();
        System.enqueueJob(new OdooPartnerSyncQueueable(0, false, environment, 'person'), asyncOptions);
        Test.stopTest();



        List<Contact> contacts = new List<Contact>();
        Contact c = [SELECT FIELDS(STANDARD), Odoo_ID__c, Language__c FROM Contact LIMIT 1];

        List<Contact> contactsToPost = new List<Contact>();
        c.Odoo_ID__c = null;
        contactsToPost.add(c);
        OdooPartnerService.parseContactToPartner(contactsToPost);

    }

}