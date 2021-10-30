public without sharing class LogsUtility {
  public static void logMessage(String message) {
    insert new Log__c(Message__c = message);
  }
  
  public static void logMessage(Exception exc, String sourceFunction) {
    String msg = '';
    msg += 'Exception Type: ' + exc.getTypeName() + '\nException Line Nr: ' + exc.getLineNumber();
    if (exc instanceOf DmlException){
        DmlException dmlExc = (DmlException) exc;
        String dmlMsg = '';
        String dmlRecordInErrrorInfo='';
        for (Integer i=0; i< dmlExc.getNumDml();i++){
            dmlMsg = msg + '\nException message: ' + dmlExc.getDmlMessage(i);
            dmlRecordInErrrorInfo = '\nBatch Row#: ' + dmlExc.getDmlIndex(i);
            String fieldsInError = '';
            for (String fieldname: dmlExc.getDmlFieldNames(i)){
                if (fieldsInError == '') fieldsInError = fieldname;
                else fieldsInError += ', ' + fieldname;
            }
            dmlRecordInErrrorInfo  += '\nField in Error ' + fieldsInError;
        }
        msg += dmlMsg + dmlRecordInErrrorInfo + '\nSource' + sourceFunction;
    }
    else {
        msg += '\nException message ' + exc.getMessage();
        msg += '\nSource' + sourceFunction;
    }
    insert new Log__c(Message__c = msg);
  }
}