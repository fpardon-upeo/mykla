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
 * Created: 19/09/2023
 * Last Updated: 19/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
@IsTest
private class OdooPartnerInvocableTest {

    @TestSetup
    static void setup() {
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
    static void testCompanyPostPatch() {

        Account a = new Account();
        a.Name = 'Upeo';
        a.BillingStreet = 'Rue de la Loi';
        a.BillingPostalCode = '1000';
        a.BillingCity = 'Brussels';
        a.BillingCountry = 'Belgium';
        a.BillingCountryCode = 'BE';
        a.Channel__c = 'B2B';
        a.Subchannel__c = 'Beauty';
        a.Language__c = 'nl_BE';
        a.VAT_Number__c = 'BE123456789';

        insert a;

        String json=		'{'+
                '  "data": {'+
                '    "type": "res_partner",'+
                '    "id": 123,'+
                '    "attributes": {'+
                '      "vat": "BE123456789",'+
                '      "sub_distribution_channel": "Beauty",'+
                '      "street": "Rue de la Loi",'+
                '      "salesforce_identifier": "0017Z00002OidV5QAJ",'+
                '      "ranking": 6,'+
                '      "postal_code": "1000",'+
                '      "name": "Upeo",'+
                '      "language": "nl_BE",'+
                '      "labels": [],'+
                '      "distribution_channel": "B2B",'+
                '      "country_iso_code": "BE",'+
                '      "company_type": "company",'+
                '      "city": "Brussels",'+
                '      "active": false,'+
                '      "prospect": false'+
                '    }'+
                '  }'+
                '}';

        SingleRequestMock mockAccount = new SingleRequestMock(200, 'OK', json, null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/partner', mockAccount);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        OdooPartnerPostPatchInvocable.RequestWrapper request = new OdooPartnerPostPatchInvocable.RequestWrapper();
        request.account = a;
        request.operation = 'create';
        List<OdooPartnerPostPatchInvocable.RequestWrapper> wrapper = new List<OdooPartnerPostPatchInvocable.RequestWrapper>();
        wrapper.add(request);
        OdooPartnerPostPatchInvocable.postPatchAccountToOdoo(wrapper);

        Test.stopTest();



    }

    @IsTest
    static void testContactPostPatch() {

        Account a = new Account();
        a.Name = 'Upeo';
        a.BillingStreet = 'Rue de la Loi';
        a.BillingPostalCode = '1000';
        a.BillingCity = 'Brussels';
        a.BillingCountry = 'Belgium';
        a.BillingCountryCode = 'BE';
        a.Channel__c = 'B2B';
        a.Subchannel__c = 'Beauty';
        a.Language__c = 'nl_BE';
        a.VAT_Number__c = 'BE123456789';

        insert a;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.AccountId = a.Id;

        insert c;

        String json=
                '{'+
                '  "data": {'+
                '    "type": "res_partner",'+
                '    "id": 123,'+
                '    "attributes": {'+
                '      "name": "First Last",'+
                '      "company_type": "person"'+
                '    }'+
                '  }'+
                '}';

        SingleRequestMock mockAccount = new SingleRequestMock(200, 'OK', json, null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:Odoo/partner', mockAccount);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        OdooPartnerContactPostPatchInvocable.RequestWrapper request = new OdooPartnerContactPostPatchInvocable.RequestWrapper();
        request.contact = c;
        List<OdooPartnerContactPostPatchInvocable.RequestWrapper> wrapper = new List<OdooPartnerContactPostPatchInvocable.RequestWrapper>();
        wrapper.add(request);
        OdooPartnerContactPostPatchInvocable.postPatchContactToOdoo(wrapper);

        Test.stopTest();



    }
}