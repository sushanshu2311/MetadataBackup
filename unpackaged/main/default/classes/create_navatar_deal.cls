/*    
    Developer: Sameer Rath , 
    Edited Date: 26/02/2015 
    Project: Axial Integration   
    Functionality: Get the information to create navatar deal through web service and set the response for the same. 
*/

@RestResource(urlMapping='/create_navatar_deal/*')
global with sharing class create_navatar_deal {
public class MyException extends Exception{} // Hold the Exception that generated from this class 
/*
    Developer: Sameer Rath
    Functionality: Declaration of POST method for Axial webservice 
*/
      @HttpPOST
      global static void doPost() {
        NavatarDealCreate server_Obj = new NavatarDealCreate(); // Hold all the parameters sent from the client
        RestResponse res = RestContext.response; // Hold the response for the web service
        saveDeal_Axial server_Method = new saveDeal_Axial(); //Hold the instance of the class for verify and save the data  
        RestRequest req = RestContext.request ; // Hold the request from the web service
        try{  
             Blob blobBody = req.requestBody;
             string body = blobBody.toString(); 
             try{
                 try{
                 server_Obj = (NavatarDealCreate)JSON.deserialize(body, NavatarDealCreate.class);
                 }
                 catch(exception ex){
                     throw new MyException('{"statusId":"400","exception":"Service Error due to bad Request."}');
                 }
                 server_Method.parameterReview(server_Obj);
                 server_Method.saveRecord(server_Obj);
                 res.responsebody = blob.valueOf('{"Message":"Deal created Sucessfully."}');
             }
             catch(exception ex){
                 server_Method.Error_Handling(ex.getMessage()); 
             }
         }
         catch(exception ex){
             server_Method.Error_Handling('{"statusId":"400","exception":"Service Error due to bad Request."}'); 
         }
    }
}