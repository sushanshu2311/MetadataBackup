@isTest
global class TestMockHttpResponse implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');        
        res.setHeader('Content-Type', 'application/json');           
        res.setBody('');
        System.assertNotEquals('MI1test', res.getBody()); // (PE3.5, SK, 9Aug2017)
                   
        return res;
    }   
    
    global class TestMockHttpResponseBulkEmail_Ctrl implements HttpCalloutMock
    {
        global HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
             res.setStatusCode(200);
             res.setStatus('OK');        
             res.setHeader('Content-Type', 'application/json');           
             res.setBody('{"attributes":{"describeUrl":"/services/data/v34.0/analytics/reports/00O36000006Zq3qEAC/describe","instancesUrl":"/services/data/v34.0/analytics/reports/00O36000006Zq3qEAC/instances","reportId":"00O36000006Zq3qEAC","reportName":"Field Datatype test","type":"Report"},"allData":true,"factMap":{"T!T":{"aggregates":[{"label":"3","value":3}],"rows":[{"dataCells":[{"label":"0033600000MFAlL","value":"0033600000MFAlLAAX"},{"label":"poctesting01+0312aug@gmail.com","value":"poctesting01+0312aug@gmail.com"},{"label":"12/6/2018","value":"2018-06-12"},{"label":"26/7/2016","value":"2016-07-26"},{"label":"XXXXXXXXX","value":"XXXXXXXXX"}]},{"dataCells":[{"label":"0033600000MEbLE","value":"0033600000MEbLEAA1"},{"label":"1investorportal+1228@gmail.com","value":"1investorportal+1228@gmail.com"},{"label":"8/3/1982","value":"1982-03-08"},{"label":"25/7/2016","value":"2016-07-25"},{"label":"Contact1228","value":"0033600000MEbLEAA1"},{"label":"XXXXXXXX","value":"XXXXXXXX"}]},{"dataCells":[{"label":"0033600000MEXJP","value":"0033600000MEXJPAA5"},{"label":"1investorportal+1281@gmail.com","value":"1investorportal+1281@gmail.com"},{"label":"1/1/2015","value":"2015-01-01"},{"label":"25/7/2016","value":"2016-07-25"},{"label":"Contact 1281","value":"0033600000MEXJPAA5"},{"label":"-","value":null}]}]}},"groupingsAcross":{"groupings":[]},"groupingsDown":{"groupings":[]},"hasDetailRows":true,"reportExtendedMetadata":{"aggregateColumnInfo":{"RowCount":{"acrossGroupingContext":null,"dataType":"int","downGroupingContext":null,"label":"Record Count"}},"detailColumnInfo":{"Contact.Id":{"dataType":"id","label":"Contact ID"},"Contact.Email":{"dataType":"email","label":"EMAIldjk"},"Contact.Birthdate":{"dataType":"date","label":"Birthdate"},"Contact.CreatedDate":{"dataType":"datetime","label":"Created Date"},"Contact.Name":{"dataType":"string","label":"Full Name"},"Contact.navpeII_dev18l__TestEnypted__c":{"dataType":"encryptedstring","label":"TestEnypted"}},"groupingColumnInfo":{}},"reportMetadata":{"aggregates":["RowCount"],"currency":null,"detailColumns":["Contact.Id","Contact.Email","Contact.Birthdate","Contact.CreatedDate","Contact.Name","Contact.navpeII_dev18l__TestEnypted__c"],"developerName":"Field_Datatype_test","division":null,"folderId":"00l360000015aiEAAQ","groupingsAcross":[],"groupingsDown":[],"hasDetailRows":true,"hasRecordCount":true,"historicalSnapshotDates":[],"id":"00O36000006Zq3qEAC","name":"Field Datatype test","reportBooleanFilter":null,"reportFilters":[],"reportFormat":"TABULAR","reportType":{"label":"Rajnish Field Test","type":"navpeII_dev18l__Rajnish_Field_Test__c"},"scope":"user","sortBy":[],"standardDateFilter":{"column":"Contact.CreatedDate","durationValue":"CUSTOM","endDate":"2016-09-12","startDate":"2015-09-12"},"standardFilters":null}}');           
             return res;
        }
    }   
    
    
     global class TestMockHttpResponseBulkEmail_Ctrl1 implements HttpCalloutMock
    {
        global HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
             res.setStatusCode(200);
             res.setStatus('OK');        
             res.setHeader('Content-Type', 'application/json');        
             res.setBody('{"attributes":{"describeUrl":"/services/data/v34.0/analytics/reports/00O36000006ZrUUEA0/describe","instancesUrl":"/services/data/v34.0/analytics/reports/00O36000006ZrUUEA0/instances","reportId":"00O36000006ZrUUEA0","reportName":"Check Sorting Cloumn","type":"Report"},"allData":true,"factMap":{"T!T":{"aggregates":[{"label":"3","value":3}],"rows":[{"dataCells":[{"label":"0033600000MFAlL","value":"0033600000MFAlLAAX"},{"label":"12/6/2018","value":"2018-06-12"},{"label":"false","value":false},{"label":"26/7/2016","value":"2016-07-26"},{"label":"Rajnish Singh","value":"00536000002aDEaAAM"}}}}}');           
             return res;
        }   
    }
       
}