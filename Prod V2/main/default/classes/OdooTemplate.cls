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
/**
@Description:

@Change Log:

@Dependencies:

@Test Classes:

*/

public class OdooTemplate {

        public meta meta{get;set;}
        public list<data> data{get;set;}
        public class template_line_ids{
            public String type{get;set;}
            public attributes attributes{get;set;}
            public Integer id{get;set;}
        }
        public class meta{
            public Integer offset{get;set;}
            public Integer size{get;set;}
            public Integer limit_x{get;set;}
            public Integer total{get;set;}
        }
        public class data{
            public String type{get;set;}
            public attributes attributes{get;set;}
            public Integer id{get;set;}
        }
        public class attributes{
            public Integer product_id{get;set;}
            public list<template_line_ids> template_line_ids{get;set;}
            public String package_type{get;set;}
            public Decimal uom_qty{get;set;}
            public list<String> allowed_pricelist_ids{get;set;}
            public String name{get;set;}
            public String date_from{get;set;}
            public Integer validation_days{get;set;}
            public String date_to{get;set;}
        }

    public static OdooTemplate parse(String json) {
        json = json.replace('limit', 'limit_x');
        return (OdooTemplate) System.JSON.deserialize(json, OdooTemplate.class);
    }

}