package com.hakom.retoqa;

import com.hakom.retoqa.grpc.UssdGrpcClient;
import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.AfterAll;

class UssdTestRunner {

    @Karate.Test
    Karate runUssdFeatures() {
        return Karate.run("classpath:com/hakom/retoqa/ussd")
                .tags("@grpc")
                .reportDir("target/karate-reports");
    }

    @AfterAll
    static void shutdownGrpc() throws InterruptedException {
        UssdGrpcClient.getInstance().shutdown();
    }
}
