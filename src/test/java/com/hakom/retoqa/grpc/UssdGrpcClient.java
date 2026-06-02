package com.hakom.retoqa.grpc;

import com.google.gson.Gson;
import com.google.protobuf.InvalidProtocolBufferException;
import com.google.protobuf.util.JsonFormat;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.StatusRuntimeException;

import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Cliente gRPC para UssdCmd, invocable desde Karate vía Java interop.
 */
public final class UssdGrpcClient {

    private static final Gson GSON = new Gson();
    private static volatile UssdGrpcClient instance;

    private final ManagedChannel channel;
    private final UssdCmdGrpc.UssdCmdBlockingStub stub;

    private UssdGrpcClient(String host, int port) {
        this.channel = ManagedChannelBuilder
                .forAddress(host, port)
                .usePlaintext()
                .build();
        this.stub = UssdCmdGrpc.newBlockingStub(channel);
    }

    public static UssdGrpcClient getInstance() {
        if (instance == null) {
            synchronized (UssdGrpcClient.class) {
                if (instance == null) {
                    String host = System.getProperty("grpc.host", "181.224.248.52");
                    int port = Integer.parseInt(System.getProperty("grpc.port", "9898"));
                    instance = new UssdGrpcClient(host, port);
                }
            }
        }
        return instance;
    }

    public String call(Map<String, Object> request) {
        return callJson(GSON.toJson(request));
    }

    public String callJson(String requestJson) {
        try {
            UssdCmdRequest.Builder builder = UssdCmdRequest.newBuilder();
            JsonFormat.parser().ignoringUnknownFields().merge(requestJson, builder);
            UssdCmdResponse response = stub.ussdCmd(builder.build());
            return JsonFormat.printer().includingDefaultValueFields().print(response);
        } catch (InvalidProtocolBufferException e) {
            throw new IllegalArgumentException("No se pudo serializar la petición USSD: " + e.getMessage(), e);
        } catch (StatusRuntimeException e) {
            throw new RuntimeException(
                    "Error gRPC UssdCmd [" + e.getStatus().getCode() + "]: " + e.getStatus().getDescription(),
                    e);
        }
    }

    public void shutdown() throws InterruptedException {
        channel.shutdown().awaitTermination(5, TimeUnit.SECONDS);
    }
}
