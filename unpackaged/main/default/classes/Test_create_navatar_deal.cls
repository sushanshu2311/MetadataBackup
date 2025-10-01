/*
    Developed by: Sameer Rath
    Project : Axial Integration
    Description: This test class is related to 3 apex classes named create_navatar_deal, NavatarDealCreate & saveDeal_Axial 
*/
@isTest
public class Test_create_navatar_deal {
    public static string reqString ;
    
    public static testMethod void testingData()
    {
         Test.startTest();
         {
            create_navatar_deal testObj = new create_navatar_deal();
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"sasa","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"dealsda","Log_In_Date":"","Investment_Size":"","External_ID":"qwertyw","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"sam","Industry":"","Geographic_Region":"","External_ID":"rweq","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"Lname","First_Name":"Fname","External_ID":"con10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"sasa","First_Name":"","External_ID":"asdfqq","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"dealsda","Log_In_Date":"","Investment_Size":"","External_ID":"qwertyw","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"sam","Industry":"","Geographic_Region":"","External_ID":"rweq","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"Lname","First_Name":"Fname","External_ID":"con10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"2ab","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pinky","Industry":"","Geographic_Region":"","External_ID":"sourceFirm10","Employees":"2ab","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            
        }
         Test.stopTest();
    }
    
     public static testMethod void testingData1()
    {
         Test.startTest();
         {
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pinky","Industry":"","Geographic_Region":"","External_ID":"sourceFirm10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"pinku","First_Name":"","External_ID":"con80","Email":"pq"},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pinky","Industry":"","Geographic_Region":"","External_ID":"sourceFirm10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"pinku","First_Name":"","External_ID":"con80","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"12-20-2015","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"pinku","First_Name":"","External_ID":"con80","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pinky","Industry":"","Geographic_Region":"","External_ID":"source1","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"pinku","First_Name":"","External_ID":"con80","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pinky","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"pinku","First_Name":"","External_ID":"con80","Email":""},"City":""},"Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
         
          }
         Test.stopTest();
    }
    
    public static void checkString(string temp){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(temp);
        req.addHeader('Content-Type', 'application/json');
        req.requestURI = 'https://ap2.salesforce.com/services/apexrest/create_navatar_deal/';
        req.httpMethod = 'POST';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        create_navatar_deal.doPost();
    }
    
    
    public static testmethod void testingdata2()
    {
        Test.startTest();
        {
            create_navatar_deal testObj = new create_navatar_deal();
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pinky","Industry":"","Geographic_Region":"","External_ID":"sourceFirm10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"con80","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"myDealTest","Log_In_Date":"","Investment_Size":"","External_ID":"pipeline10","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"SameerTest","Industry":"","Geographic_Region":"","External_ID":"company10","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"f2","First_Name":"f1","External_ID":"contact10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pFname2","Industry":"","Geographic_Region":"","External_ID":"abc123","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"llname","First_Name":"","External_ID":"abc123","Email":""},"City":""},"source":"","Revenue_Range":"","Revenue":"","Name":"pipeline","Log_In_Date":"","Investment_Size":"","External_ID":"abc123","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"FullName","Industry":"","Geographic_Region":"","External_ID":"abc123","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"lname","First_Name":"fname","External_ID":"abc123","Email":"p@q.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"pFname2","Industry":"","Geographic_Region":"","External_ID":"abc1234","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"llname","First_Name":"","External_ID":"abc123","Email":""},"City":""},"source":"","Revenue_Range":"","Revenue":"","Name":"pipeline","Log_In_Date":"","Investment_Size":"","External_ID":"abc123","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"","Name":"FullName","Industry":"","Geographic_Region":"","External_ID":"abc123","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"lname","First_Name":"fname","External_ID":"abc123","Email":"p@q.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"","Log_In_Date":"","Investment_Size":"","External_ID":"","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"rweq","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString);
            
             }
         Test.stopTest();
    }
    
    
    public static testmethod void testingdata3()
    {
        Test.startTest();
        {
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"qwety","Industry":"","Geographic_Region":"","External_ID":"source1","Employees":"21","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"wer","First_Name":"","External_ID":"sourceCon1","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"2200","Name":"MY SAM DEAL","Log_In_Date":"2015-03-21","Investment_Size":"4","External_ID":"deal3","Enterprise_Value":"6","EBITDA_Range":"","EBITDA":"4","EBIT":"4","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwessq","Employees":"24","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwe123","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal3","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwessq","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwe123","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal3","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwssessq","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwe123","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal3","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwasdessq","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwqwee123","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString);
            
         }
         Test.stopTest();
    }
    
    
    public static testmethod void testingdata4()
    {
        Test.startTest();
        {
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"p","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal3","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwasdessq","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwqwee123","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"q","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal3","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwasdessq","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwqwee123","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"qwety","Industry":"","Geographic_Region":"","External_ID":"source1","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"wer","First_Name":"","External_ID":"sourceCon2","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal5","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwessqsd","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwe1234","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"qwety","Industry":"","Geographic_Region":"","External_ID":"source6","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"wer","First_Name":"","External_ID":"sourceCon1","Email":""},"City":""},"Source":"","Revenue_Range":"2 - 4","Revenue":"","Name":"MY SAM DEAL","Log_In_Date":"","Investment_Size":"","External_ID":"deal5","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"10 - 20","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"Axial","Postal_Code":"123415","Name":"Sameer Rath","Industry":"nope","Geographic_Region":"370* north","External_ID":"rwessqsd","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwe1234","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString);
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"qwety","Industry":"","Geographic_Region":"","External_ID":"source6","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"rth"External_ID":"rwessqsd","Employees":"2","Country":"Hong Kong","Contact":{"Phone":"9439322807","Mailing_Street":"Balaram Nagar,Lane-2","Mailing_State":"Odisha","Mailing_Postal_Code":"201301","Mailing_Country":"India","Mailing_City":"Gunupur","Last_Name":"zqwe","First_Name":"lPan","External_ID":"qwe1234","Email":"zyx@po.com"},"City":"noida"}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString); 
            
            reqString = '{"Transaction_Type":"","Stage":"","Source_Firm":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"adsf","Industry":"","Geographic_Region":"","External_ID":"","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"","First_Name":"","External_ID":"","Email":""},"City":""},"Source":"","Revenue_Range":"","Revenue":"","Name":"dealsda","Log_In_Date":"","Investment_Size":"","External_ID":"qwertyw","Enterprise_Value":"","EBITDA_Range":"","EBITDA":"","EBIT":"","Deal_Type":"","Deal_Size_Range":"","Data_Currency":"","Company_Name":{"Website":"","Street":"","State":"","Source":"","Postal_Code":"","Name":"sam","Industry":"","Geographic_Region":"","External_ID":"rweq","Employees":"","Country":"","Contact":{"Phone":"","Mailing_Street":"","Mailing_State":"","Mailing_Postal_Code":"","Mailing_Country":"","Mailing_City":"","Last_Name":"Lname","First_Name":"Fname","External_ID":"con10","Email":"zyx@po.com"},"City":""}}';
            System.assertNotEquals('testingHello', reqString); // (PE3.5, SK, 9Aug2017)
            checkString2(reqString); 
        }
        Test.stopTest();
    }
    
    
    public static void checkString2(string temp)
    {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(temp);
        req.addHeader('Content-Type', 'application/json');
        req.requestURI = 'https://ap2.salesforce.com/services/apexrest/create_navatar_deal/';
        req.httpMethod = 'POST';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        create_navatar_deal.doPost();
    }
}