@grpc
Feature: Opción 1 - Consultar saldo

  Background:
    * def session = openSession(msisdn)
    * def sessionId = session.sessionId

  Scenario: Navegar al menú y consultar saldo
    * def response = ussdContinue(sessionId, msisdn, '1')
    * print response
    * match response.error == 'OK'
    * match response.sessionId == sessionId
    * match response.msisdn == msisdn
    * match response.ussdString == '#regex (?i).*saldo.*'
