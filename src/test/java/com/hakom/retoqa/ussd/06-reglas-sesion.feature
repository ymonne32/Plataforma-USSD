@grpc
Feature: Reglas obligatorias de sesión stateful

  Scenario: sessionId y msisdn se mantienen en llamadas posteriores
    * def first = openSession(msisdn)
    * def sessionId = first.sessionId
    * def second = ussdContinue(sessionId, msisdn, '1')
    * match second.sessionId == sessionId
    * match second.msisdn == msisdn
    * match second.gwTransId == gwTransId
    * match second.ussdGwId == ussdGwId
    * match second.ussdCoreId == ussdCoreId
    * match second.type == 'PULL'

  Scenario: Request posterior solo altera ussdString y sessionId (estructura fija)
    * def first = openSession(msisdn)
    * def sessionId = first.sessionId
    * def UssdPayloads = Java.type('com.hakom.retoqa.grpc.UssdPayloads')
    * def ussdRequest = UssdPayloads.subsequent(sessionId, msisdn, '1')
    * match ussdRequest.gwSessionId == 0
    * match ussdRequest.gwTransId == 2
    * match ussdRequest.sessionId == sessionId
    * match ussdRequest.ussd_service_op == 'USSD_SERVICE_UNSTRUCTURED_SS_REQUEST'
    * match ussdRequest.msisdn == msisdn
    * match ussdRequest.ussdGwId == 'USSDGWS101'
    * match ussdRequest.ussdCoreId == 'USSD-HAC-CORA1'
    * match ussdRequest.type == 'PULL'
    * match ussdRequest.ussdString == '1'
