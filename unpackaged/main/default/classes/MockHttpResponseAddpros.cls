@isTest
global class MockHttpResponseAddpros implements HttpCalloutMock 
{
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');        
        res.setHeader('Content-Type', 'application/json');           
        res.setBody('{"reportMetadata":{"groupingsDown" :[],"sortBy" : [{"sortOrder" : "Asc"}]}}'); 
        System.assertNotEquals('MI1test', res.getBody()); // (PE3.5, SK, 9Aug2017)
                  
        return res;
    } 
         
}