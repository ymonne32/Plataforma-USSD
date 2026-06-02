@smoke @grpc
Feature: Smoke - Conexión gRPC USSD

  Background:
    * configure logPrettyRequest = true
    * configure logPrettyResponse = true

  Scenario: El servidor responde a la marcación inicial *999#
    * def response = openSession(msisdn)
    * print response
    * match response.error == 'OK'
    * match response.msisdn == msisdn
    * match response.sessionId == '#string'
    * match response.ussdString contains menuWelcomeContains
    * match response.ussdString contains '1. Consultar saldo'
    * match response.ussdString contains '2. Recargar'
    * match response.ussdString contains '3. Estado de cuenta'
    * match response.ussdString contains '4. Salir'
    * match response.ussdGwId == ussdGwId
    * match response.type == 'PULL'
