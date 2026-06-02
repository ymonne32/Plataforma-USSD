@grpc
Feature: Opción 2 - Recargar

  Background:
    * def session = openSession(msisdn)
    * def sessionId = session.sessionId

  Scenario: Recargar solicita monto y actualiza saldo
    * def stepMenu = ussdContinue(sessionId, msisdn, '2')
    * match stepMenu.error == 'OK'
    * match stepMenu.sessionId == sessionId
    * print 'Pantalla recarga:', stepMenu.ussdString
    # El servidor suele pedir monto; enviamos monto configurable
    * def stepAmount = ussdContinue(sessionId, msisdn, rechargeAmount)
    * print stepAmount
    * match stepAmount.error == 'OK'
    * match stepAmount.sessionId == sessionId
    * match stepAmount.msisdn == msisdn
  # Validación flexible: confirmación de recarga o nuevo saldo
    * def msg = stepAmount.ussdString
    * def okRecarga = msg.contains('recarga') || msg.contains('Recarga') || msg.contains('saldo') || msg.contains('exitos')
    * match okRecarga == true
