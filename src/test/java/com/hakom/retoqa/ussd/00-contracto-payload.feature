@contract
Feature: Contrato de payloads USSD (sin llamada gRPC)

  Scenario: Payload inicial cumple reglas del reto
    * def UssdPayloads = Java.type('com.hakom.retoqa.grpc.UssdPayloads')
    * def ussdRequest = UssdPayloads.initial('541122556664', '*999#')
    * match ussdRequest ==
      """
      {
        gwTransId: 2,
        ussd_service_op: 'USSD_SERVICE_PROCESS_UNSTRUCTURED_SS_REQUEST',
        msisdn: '541122556664',
        ussdString: '*999#',
        ussdGwId: 'USSDGWS101'
      }
      """

  Scenario: Payload posterior cumple reglas del reto
    * def UssdPayloads = Java.type('com.hakom.retoqa.grpc.UssdPayloads')
    * def sessionId = '00000001_test-session-id'
    * def ussdRequest = UssdPayloads.subsequent(sessionId, msisdn, '1')
    * match ussdRequest.sessionId == sessionId
    * match ussdRequest.msisdn == msisdn
    * match ussdRequest.ussdString == '1'
    * match ussdRequest.ussd_service_op == 'USSD_SERVICE_UNSTRUCTURED_SS_REQUEST'
    * match ussdRequest.gwTransId == 2
    * match ussdRequest.ussdGwId == 'USSDGWS101'
    * match ussdRequest.ussdCoreId == 'USSD-HAC-CORA1'
    * match ussdRequest.type == 'PULL'
