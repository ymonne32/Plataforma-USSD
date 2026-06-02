@ignore @helper
Feature: Helper - Reabrir sesión USSD

  Scenario: Re-marcar *999# cuando no hay opción volver
    * def response = openSession(msisdn)
    * karate.set('sessionId', response.sessionId)
