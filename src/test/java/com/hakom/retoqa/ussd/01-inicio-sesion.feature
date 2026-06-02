@grpc
Feature: Inicio de sesión USSD - Llamada inicial

  Background:
    * def UssdPayloads = Java.type('com.hakom.retoqa.grpc.UssdPayloads')

  Scenario: Llamada inicial solo modifica msisdn y ussdString
    * def customMsisdn = msisdn
    * def customDial = ussdDial
    * def ussdRequest = UssdPayloads.initial(customMsisdn, customDial)
    * match ussdRequest ==
      """
      {
        gwTransId: 2,
        ussd_service_op: 'USSD_SERVICE_PROCESS_UNSTRUCTURED_SS_REQUEST',
        msisdn: '#(customMsisdn)',
        ussdString: '#(customDial)',
        ussdGwId: 'USSDGWS101'
      }
      """
    * def response = ussdInitial(customMsisdn, customDial)
    * def sessionId = response.sessionId
    * match response.error == 'OK'
    * match response.ussd_service_op == 'USSD_SERVICE_UNSTRUCTURED_SS_REQUEST'
    * match response.ussdString contains 'Bienvenido al sistema USSD'

  Scenario: sessionId se obtiene en la primera respuesta
    * def response = openSession(msisdn)
    * def sessionId = response.sessionId
    * match sessionId == '#regex .+_.+'
    * karate.set('sessionId', sessionId)
