@e2e @grpc
Feature: Flujo completo USSD - Menú principal y opciones

  Scenario: Recorrer menú: saldo, volver, estado cuenta y salir
    # 1) Inicio *999#
    * def r0 = openSession(msisdn)
    * def sessionId = r0.sessionId
    * match r0.ussdString contains menuWelcomeContains

    # 2) Consultar saldo
    * def r1 = ussdContinue(sessionId, msisdn, '1')
    * match r1.sessionId == sessionId
    * match r1.ussdString == '#regex (?i).*saldo.*'

    # 3) Nueva sesión para probar otra opción del menú
    * def rMenu = openSession(msisdn)
    * def sessionId = rMenu.sessionId

    # 4) Estado de cuenta
    * def r3 = ussdContinue(sessionId, msisdn, '3')
    * match r3.sessionId == sessionId

    # 5) Salir
    * def r4 = ussdContinue(sessionId, msisdn, '4')
    * match r4.sessionId == sessionId
    * print 'Flujo completo finalizado:', r4.ussdString
