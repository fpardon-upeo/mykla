/**
 * @Version: 1.0
 * @Author: Frederik
 * @Copyright: 2023 Upeo Consulting
 * @Uses:
 * @Description: Helper class to facilitate bulk upserts and inserts. Logging is done via the logger classes
 * @Created: 16/11/2022
 * @Last Updated: 16/11/2022
 * @Unit tests: DMLHandlerTest
 * @Change log:
 * -----------------------------------------------------------------------------------------------
*/

public class DMLHandler {

//----------------------------------------DML METHODS---------------------------------------------------//


    public static void upsertRecords(Schema.SObjectField f, List<SObject> records){
        Database.UpsertResult[] results = Database.upsert(records, f,false);
        parseUpsertResult(results, records);
    }

    public static List<Database.UpsertResult> upsertRecordsWithReturn(Schema.SObjectField f, List<sObject> records){
        Database.UpsertResult[] results = Database.upsert(records, f,false);
        parseUpsertResult(results, records);
        return results;
    }



//----------------------------------------HELPER METHODS--------------------------------------------------//


    public static void parseUpsertResult(List<Database.UpsertResult> results, List<SObject> records){

        List<Error_Log__c> errorLogs = new List<Error_Log__c>();

        for(Integer i=0; i < results.size(); i++){
            if(results[i].isSuccess()){
                //do nothing
                //system.debug('Success');
            } else {
                // Operation failed, so get all errors
                for(Database.Error err : results[i].getErrors()) {
                    Error_Log__c errorLog = errorLogger(err, records[i], 'Upsert');
                    errorLogs.add(errorLog);
                    //System.debug('err.getStatusCode() = ' + err.getStatusCode());
                    //System.debug('err.getMessage() = ' + err.getMessage());
                }
            }
        }
        //insert errorLogs;
    }


    public static Error_Log__c errorLogger(Database.Error err, SObject payload, String operation){

        String sobjectType = String.valueOf(payload.getSObjectType());
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Error_Message__c = err.getStatusCode() + ': ' + err.getMessage();
        errorLog.Fields__c = err.getFields().toString();
        errorLog.Payload__c = String.valueOf(payload).left(30000);
        errorLog.DML_Operation__c = operation;
        errorLog.Object__c = sobjectType;
        return errorLog;
    }


}