public class TriggerHandler {
  public static void start(TriggerInterface handler, System.TriggerOperation triggerOperation) {
    switch on triggerOperation {
      when BEFORE_INSERT {
        handler.beforeInsert(Trigger.New);
      }
      when AFTER_INSERT {
        handler.afterInsert(Trigger.New);
      }
      when BEFORE_UPDATE {
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
      }
      when AFTER_UPDATE {
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
      }
    }
  }
}
