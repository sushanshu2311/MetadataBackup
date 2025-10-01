@isTest
global class MockHttpBulkEmail_Ctrl implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) 
    {
        String strTemp = 'aass';
        System.assertNotEquals('MI1test', strTemp); // (PE3.5, SK, 8Aug2017)
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');        
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"type":"folder","id":"3164662885","sequence_id":"0","etag":"0","name":"anurag fund","created_at":"2015-02-24T04:01:37-08:00","modified_at":"2015-02-24T04:01:37-08:00","description":"","size":0,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"2912922567","sequence_id":"0","etag":"0","name":"Navatar Group Testing Dev"},{"type":"folder","id":"2912922663","sequence_id":"0","etag":"0","name":"Potential Investment"}]},"created_by":{"type":"user","id":"230230933","name":"peDev 6-jan-15","login":"1investorportal+pedev_6jan2015@gmail.com"},"modified_by":{"type":"user","id":"230230933","name":"peDev 6-jan-15","login":"1investorportal+pedev_6jan2015@gmail.com"},"trashed_at":null,"purged_at":null,"content_created_at":"2015-02-24T04:01:37-08:00","content_modified_at":"2015-02-24T04:01:37-08:00","owned_by":{"type":"user","id":"230230933","name":"peDev 6-jan-15","login":"1investorportal+pedev_6jan2015@gmail.com"},"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"2912922663","sequence_id":"0","etag":"0","name":"Potential Investment"},"item_status":"active","item_collection":{"total_count":3,"entries":[{"type":"folder","id":"3182682460","sequence_id":"0","etag":"0","name":"anurag insitution"},{"type":"folder","id":"3164662905","sequence_id":"0","etag":"0","name":"BBBB (Common)"},{"type":"folder","id":"3164662985","sequence_id":"0","etag":"0","name":"CCC (Internal)"}],"offset":0,"limit":1000,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}');
        return response;
    }
}