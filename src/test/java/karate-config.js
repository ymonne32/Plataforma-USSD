function fn() {
  var UssdGrpcClient = Java.type('com.hakom.retoqa.grpc.UssdGrpcClient');
  var UssdPayloads = Java.type('com.hakom.retoqa.grpc.UssdPayloads');

  var grpcHost = karate.properties['grpc.host'] || '181.224.248.52';
  var grpcPort = karate.properties['grpc.port'] || '9898';
  var msisdn = karate.properties['msisdn'] || '541122556664';
  var rechargeAmount = karate.properties['recharge.amount'] || '100';

  var client = UssdGrpcClient.getInstance();

  function parseResponse(jsonString) {
    return JSON.parse(jsonString);
  }

  function ussdInitial(customMsisdn, customUssdString) {
    var dial = customUssdString || UssdPayloads.USSD_DIAL;
    var phone = customMsisdn || msisdn;
    var request = UssdPayloads.initial(phone, dial);
    var raw = client.call(request);
    return parseResponse(raw);
  }

  function ussdContinue(sessionId, customMsisdn, userInput) {
    var phone = customMsisdn || msisdn;
    var request = UssdPayloads.subsequent(sessionId, phone, userInput);
    var raw = client.call(request);
    return parseResponse(raw);
  }

  function openSession(customMsisdn) {
    var res = ussdInitial(customMsisdn, null);
    karate.set('sessionId', res.sessionId);
    karate.set('lastResponse', res);
    return res;
  }

  return {
    grpcHost: grpcHost,
    grpcPort: grpcPort,
    msisdn: msisdn,
    rechargeAmount: rechargeAmount,
    ussdDial: UssdPayloads.USSD_DIAL,
    gwTransId: UssdPayloads.GW_TRANS_ID,
    ussdGwId: UssdPayloads.USSD_GW_ID,
    ussdCoreId: UssdPayloads.USSD_CORE_ID,
    menuWelcomeContains: 'Bienvenido al sistema USSD',
    client: client,
    ussdInitial: ussdInitial,
    ussdContinue: ussdContinue,
    openSession: openSession,
    parseUssdResponse: parseResponse
  };
}
