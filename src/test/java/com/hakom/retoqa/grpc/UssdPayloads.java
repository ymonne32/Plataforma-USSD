package com.hakom.retoqa.grpc;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Construcción de requests según reglas del reto (inicial vs posteriores).
 */
public final class UssdPayloads {

    public static final int GW_TRANS_ID = 2;
    public static final String USSD_GW_ID = "USSDGWS101";
    public static final String USSD_CORE_ID = "USSD-HAC-CORA1";
    public static final String USSD_DIAL = "*999#";
    public static final String OP_INITIAL = "USSD_SERVICE_PROCESS_UNSTRUCTURED_SS_REQUEST";
    public static final String OP_CONTINUE = "USSD_SERVICE_UNSTRUCTURED_SS_REQUEST";

    private UssdPayloads() {
    }

    public static Map<String, Object> initial(String msisdn, String ussdString) {
        Map<String, Object> req = new LinkedHashMap<>();
        req.put("gwTransId", GW_TRANS_ID);
        req.put("ussd_service_op", OP_INITIAL);
        req.put("msisdn", msisdn);
        req.put("ussdString", ussdString);
        req.put("ussdGwId", USSD_GW_ID);
        return req;
    }

    public static Map<String, Object> subsequent(String sessionId, String msisdn, String ussdString) {
        Map<String, Object> req = new LinkedHashMap<>();
        req.put("gwSessionId", 0);
        req.put("gwTransId", GW_TRANS_ID);
        req.put("sessionId", sessionId);
        req.put("ussd_service_op", OP_CONTINUE);
        req.put("msisdn", msisdn);
        req.put("vlr", "");
        req.put("ussdString", ussdString);
        req.put("ussdDataCoding", "GSM7_DEFAULT");
        req.put("error", "OK");
        req.put("ussdCoreId", USSD_CORE_ID);
        req.put("ussdGwId", USSD_GW_ID);
        req.put("type", "PULL");
        return req;
    }
}
