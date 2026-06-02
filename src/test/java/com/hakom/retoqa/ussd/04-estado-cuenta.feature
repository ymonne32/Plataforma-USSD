@grpc
Feature: Opción 3 - Estado de cuenta

  Background:
    * def session = openSession(msisdn)
    * def sessionId = session.sessionId

  Scenario: Mostrar últimos movimientos
    * def response = ussdContinue(sessionId, msisdn, '3')
    * print response
    * match response.error == 'OK'
    * match response.sessionId == sessionId
    * match response.msisdn == msisdn
    * def msg = response.ussdString
    * def okEstado = msg.contains('movimiento') || msg.contains('Movimiento') || msg.contains('cuenta') || msg.contains('Estado') || msg.contains('historial')
    * match okEstado == true
