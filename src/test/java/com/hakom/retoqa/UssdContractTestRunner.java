package com.hakom.retoqa;

import com.intuit.karate.junit5.Karate;

/** Pruebas de contrato sin llamadas gRPC (perfil Maven {@code offline}). */
class UssdContractTestRunner {

    @Karate.Test
    Karate runContractTests() {
        return Karate.run("classpath:com/hakom/retoqa/ussd/00-contracto-payload.feature")
                .reportDir("target/karate-reports");
    }
}
