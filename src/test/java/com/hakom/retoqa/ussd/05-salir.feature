@grpc
Feature: Opción 4 - Salir

  Background:
    * def session = openSession(msisdn)
    * def sessionId = session.sessionId

  Scenario: Salir finaliza la sesión USSD
    * def response = ussdContinue(sessionId, msisdn, '4')
    * print response
    * match response.error == 'OK'
    * match response.sessionId == sessionId
    * def msg = response.ussdString
    * def okSalida = msg.contains('Gracias') || msg.contains('gracias') || msg.contains('Salir') || msg.contains('salir') || msg.contains('finaliz') || msg.contains('hasta')
    * match okSalida == true
