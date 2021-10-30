public interface TriggerInterface {
  void beforeInsert(List<sObject> newList);

  void afterInsert(List<sObject> newList);

  void beforeUpdate(List<sObject> newList, Map<Id, sObject> oldMap);

  void afterUpdate(List<sObject> newList, Map<Id, sObject> oldMap);
}
