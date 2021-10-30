/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-21
* @description This is a helper class for Event_TicketValidationMachineManagement trigger. It supports only AFTER INSERT context.
********************************************************************************************************/
public without sharing class Event_TicketValidationMachineManagement implements TriggerInterface {
  public void beforeInsert(List<sObject> newList) {
  }

  public void afterInsert(List<sObject> newList) {
    Event_TicketValidationMachineManagement.recalcCardsInsertTrips(newList);
  }

  public void beforeUpdate(List<sObject> newList, Map<Id, sObject> oldMap) {
  }

  public void afterUpdate(List<sObject> newList, Map<Id, sObject> oldMap) {
  }

/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-21
* @description This method update fields on a Card and creates a Trip with Event data  after the Event is published.
* @param List<RFID_TicketValidationMachine__e>
********************************************************************************************************/
  public static void recalcCardsInsertTrips(List<RFID_TicketValidationMachine__e> newlist) {  
    try {
      Set<String> eventCardTags = new Set<String>();
      Set<String> eventSubstationNames= new Set<String>();
      for (RFID_TicketValidationMachine__e event : newlist) {
        eventCardTags.add(event.RFID_Tag__c);
        eventSubstationNames.add(event.RFID_Station__c);
      }

      Map<String, ERDC_Card__c> cardsByName = Event_TicketValidationMachineManagement.getCardsByName(eventCardTags);
      Map<String, ERDC_Station__c> substationsByName = Event_TicketValidationMachineManagement.getSubstationsByName(eventSubstationNames);
      if (cardsByName == null || substationsByName == null) return;

      List<ERDC_Trip__c> tripsToInsert = new List<ERDC_Trip__c>();
      List<ERDC_Card__c> cardsToUpdate = new List<ERDC_Card__c>();
      for (RFID_TicketValidationMachine__e event : newlist) {
        
        ERDC_Trip__c newTrip = new ERDC_Trip__c(
          ERDC_Station__c = substationsByName.get(event.RFID_Station__c).Id,
          ERDC_Line__c = substationsByName.get(event.RFID_Station__c).ERDC_Line__r.Id,
          ERDC_Card__c = cardsByName.get(event.RFID_Tag__c).Id
        );
        tripsToInsert.add(newTrip);

        cardsByName.get(event.RFID_Tag__c).ERDC_Available_Trips__c = event.RFID_Available_Trips__c;
        cardsToUpdate.add(cardsByName.get(event.RFID_Tag__c));
      }

      if (!cardsToUpdate.isEmpty()) update cardsToUpdate;
      if (!tripsToInsert.isEmpty()) insert tripsToInsert;
    }
    catch(Exception e) {
      LogsUtility.logMessage(e, 'Event_TicketValidationMachineManagement.updateCard');
    }
  }

/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-23
* @description This method returns a map of Cards by Cards Name
* @param Set<String>
********************************************************************************************************/
  public static  Map<String, ERDC_Card__c> getCardsByName(Set<String> cardNames) {
    if (cardNames.isEmpty()) return null;

    Map<String, ERDC_Card__c> cardsByName = new Map<String,ERDC_Card__c>();
    List<ERDC_Card__c> cards = [
      SELECT Id,
        Name,
        ERDC_Available_Trips__c
      FROM ERDC_Card__c
      WHERE ERDC_Card__c.Name IN :cardNames
    ];
    if (cards.isEmpty()) return null;

    for (ERDC_Card__c card : cards) {
      cardsByName.put(card.Name, card);   
    }
    return cardsByName;
  }

/********************************************************************************************************
* @author Andrei Banu
* @date 2021-10-23
* @description This method returns a map of Substations by Substations Name
* @param Set<String>
********************************************************************************************************/
  public static  Map<String, ERDC_Station__c> getSubstationsByName(Set<String> substationNames) {
    if (substationNames.isEmpty()) return null;

    Map<String, ERDC_Station__c> substationsByName = new Map<String,ERDC_Station__c>();
    List<ERDC_Station__c> substations = [
      SELECT Id,
        Name,
        ERDC_Line__r.Id 
      FROM ERDC_Station__c
      WHERE Name IN :substationNames
      AND RecordType.Id = :ERDC_GlobalUtilityConstants.SUBSTATION_RECORD_TYPE_ID
    ];
    if (substations.isEmpty()) return null;

    for (ERDC_Station__c substation : substations){
      substationsByName.put(substation.Name, substation);
    }
    return substationsByName;
  }
}