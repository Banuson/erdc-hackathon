/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-21
* @description This is a controller class for ERDC_Map Lightning Web Component
********************************************************************************************************/
public without sharing class ERDC_MapController {
/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-25
* @description This method returns a list of all Main Stations
* @param List<RFID_TicketValidationMachine__e>
********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ERDC_Station__c> getStationInfo(){
        return [
            SELECT Id,
                Name,
                ERDC_Line__c,
                ERDC_Trip_Count__c,
                ERDC_Location__Latitude__s,
                ERDC_Location__Longitude__s,
                (
                    SELECT Id,
                        Name,
                        Erdc_Trip_Count__c
                    FROM Substations__r
                )
            FROM ERDC_Station__c
            WHERE RecordTypeId = :ERDC_GlobalUtilityConstants.MAIN_STATION_RECORD_TYPE_ID
        ];
    }

/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-25
* @description This method returns a list of all Lines
* @param List<RFID_TicketValidationMachine__e>
********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ERDC_Line__c> getLineInfo(){
        return [
            SELECT Id,
                Name,
                ERDC_Coordinates__c,
                ERDC_Map_Color__c            
            FROM ERDC_Line__c
        ];
    }
}