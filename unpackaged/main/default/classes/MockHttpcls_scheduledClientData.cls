@isTest
global class MockHttpcls_scheduledClientData implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');        
        response.setHeader('Content-Type','application/json');
        response.setBody('');
        return response;
    }
    
    global class MockGenerator_scheduledClientData_SMTP implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');        
            response.setHeader('Content-Type','');
            response.setBody('');
            return response;
        }      
    }
    
    global class MockGenerator_scheduledClientData_NotFound implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('NotFound');        
            response.setHeader('Content-Type','');
            response.setBody('');
            return response;
        }      
    }
}