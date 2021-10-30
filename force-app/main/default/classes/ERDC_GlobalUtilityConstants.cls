public without sharing class ERDC_GlobalUtilityConstants {
    public static Id MAIN_STATION_RECORD_TYPE_ID =Schema.SObjectType.ERDC_Station__c.getRecordTypeInfosByDeveloperName().get('ERDC_Main_Station').getRecordTypeId();
    public static Id SUBSTATION_RECORD_TYPE_ID =Schema.SObjectType.ERDC_Station__c.getRecordTypeInfosByDeveloperName().get('ERDC_Substation').getRecordTypeId();
}