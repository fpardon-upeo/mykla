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

public class OdooInvoiceService {

    public static void parseAccountMoveToInvoice(List<OdooAccountMove.Data> odooInvoices){


        List<Invoice__c> invoices = new List<Invoice__c>();
        List<Invoice_Line__c> invoiceLines = new List<Invoice_Line__c>();

        Schema.SObjectField invId = Invoice__c.Fields.Odoo_Id__c;
        Schema.SObjectField invLineId = Invoice_Line__c.Fields.Odoo_Id__c;

        for(OdooAccountMove.Data odooInvoice : odooInvoices){
            if(Date.valueOf(odooInvoice.attributes.start_date).year() >= Date.today().year()-1) {
                invoices.add(mapAccountMoveToInvoice(odooInvoice));
                if (odooInvoice.attributes.invoice_lines != null) {
                    invoiceLines.addAll(mapAccountMoveLineToInvoiceLine(odooInvoice.attributes.invoice_lines));
                }
            }
        }

        System.debug('invoices: ' + invoices.size());
        System.debug('invoiceLines: ' + invoiceLines.size());

        List<Database.UpsertResult> invoiceUpserts = DMLHandler.upsertRecordsWithReturn(invId, invoices);
        List<Database.UpsertResult> invoiceLineUpserts = DMLHandler.upsertRecordsWithReturn(invLineId, invoiceLines);

        Integer successCount = 0;
        Integer errorCount = 0;

        for(Database.UpsertResult invoiceUpsert : invoiceUpserts){
            if(invoiceUpsert.isSuccess()){
                //System.debug('Invoice upsert success: ' + invoiceUpsert.getId());
                successCount++;
            }else{
                //System.debug('Invoice upsert error: ' + invoiceUpsert.getErrors());
                errorCount++;
            }
        }

        System.debug('Invoice upsert success count: ' + successCount);
        System.debug('Invoice upsert error count: ' + errorCount);

        successCount = 0;
        errorCount = 0;

        for(Database.UpsertResult lineUpsert : invoiceLineUpserts){
            if(lineUpsert.isSuccess()){
                //System.debug('Invoice line upsert success: ' + lineUpsert.getId());
                successCount++;
            }else{
                //System.debug('Invoice line upsert error: ' + lineUpsert.getErrors());
                errorCount++;
            }
        }

        System.debug('Invoice line upsert success count: ' + successCount);
        System.debug('Invoice line upsert error count: ' + errorCount);

    }

    public static Invoice__c mapAccountMoveToInvoice(OdooAccountMove.Data odooInvoice){

        //System.debug('odooInvoice: ' + odooInvoice.attributes.account_name);

        Invoice__c invoice = new Invoice__c();
        invoice.Customer_Account_Name__r = new Account(Odoo_ID__c = odooInvoice.attributes.account_name);
        invoice.Name = odooInvoice.attributes.name;
        invoice.Customer_ref__c = odooInvoice.attributes.customer_ref;
        invoice.Odoo_ID__c = odooInvoice.Id;
        invoice.Payment_state__c = odooInvoice.attributes.payment_state != null ? odooInvoice.attributes.payment_state.replace('_', ' ') : 'unknown';
        invoice.Tax__c = odooInvoice.attributes.tax;
        invoice.Total__c = odooInvoice.attributes.total;
        invoice.Tax_excluded__c = odooInvoice.attributes.tax_excluded;
        invoice.Start_date__c = odooInvoice.attributes.start_date != null ? Date.valueOf(odooInvoice.attributes.start_date) : null;
        invoice.End_date__c = odooInvoice.attributes.end_date != null ? Date.valueOf(odooInvoice.attributes.end_date) : null;
        invoice.Amount_due__c = odooInvoice.attributes.amount_due;
        return invoice;
    }

    public Static List<Invoice_Line__c> mapAccountMoveLineToInvoiceLine(List<OdooAccountMove.InvoiceLines> odooInvoiceLines){
        List<Invoice_Line__c> invoiceLines = new List<Invoice_Line__c>();
        for(OdooAccountMove.InvoiceLines odooInvoiceLine : odooInvoiceLines){
            Invoice_Line__c invoiceLine = new Invoice_Line__c();
            invoiceLine.Invoice__r = new Invoice__c(Odoo_ID__c = odooInvoiceLine.attributes.account_move_id);
            invoiceLine.Odoo_ID__c = odooInvoiceLine.Id;
            invoiceLine.Product__r = new Product2(Odoo_ID__c = odooInvoiceLine.attributes.product_id);
            invoiceLine.Quantity__c = odooInvoiceLine.attributes.quantity;
            invoiceLine.List_price__c = odooInvoiceLine.attributes.list_price;
            invoiceLine.Total_price__c = odooInvoiceLine.attributes.total_price;
            invoiceLine.Discount__c = odooInvoiceLine.attributes.discount;
            invoiceLine.Name = odooInvoiceLine.attributes.description;
            invoiceLines.add(invoiceLine);
        }
        return invoiceLines;
    }

}