/*    
    Developed By: Sameer Rath  
    Edited date: 17/02/2015  
    Project: Axial Integration  
    Functionality: This wrapper class is to hold the whole information that has been sent from client to create a Navatar Deal in Axial web service.
*/
Public With Sharing Class NavatarDealCreate{
    Public AccountWrrap Company_Name{get;set;} // Used to Hold the pipeline company information
    Public String External_ID{get;set;} // Used to Hold the pipeline External ID 
    Public String Name{get;set;} // Used to Hold the pipeline name 
    Public string Log_In_Date{get;set;} // Used to Hold the pipeline Log in date value
    Public String Stage{get;set;} // Used to Hold the pipeline stage value
    Public String Deal_Type{get;set;} // Used to Hold the pipeline deal type
    Public String Transaction_Type{get;set;} // Used to Hold the pipeline transaction type value
    Public string source{get;set;} // Used to Hold the pipeline source  
    Public String Data_Currency{get;set;} // Used to Hold the pipeline data currency
    Public string Revenue{get;set;} // Used to Hold the pipeline Revenue
    Public String Revenue_Range{get;set;} // Used to Hold the pipeline Revenue Range
    Public string Investment_Size{get;set;} // Used to Hold the pipeline investment size
    Public String Deal_Size_Range{get;set;} // Used to Hold the pipeline deal size range
    Public string EBITDA{get;set;} // Used to Hold the pipeline EBITDA
    Public String EBITDA_Range{get;set;} // Used to Hold the pipeline EBITDA RANGE 
    Public string EBIT{get;set;} // Used to Hold the pipeline EBIT
    Public String Enterprise_Value{get;set;} // Used to Hold the pipeline enterprise value 
    Public AccountWrrap Source_Firm{get;set;} // Used to Hold the pipeline source information
    
    
    Public Class AccountWrrap{
    Public String External_ID{get;set;} // Used to hold the account external id value
    Public String Source{get;set;} // Used to hold the account source value
    Public String Name{get;set;} // Used to hold the account name
    Public String Website{get;set;} // Used to hold the account website
    Public String Industry{get;set;} // Used to hold the account Industry
    Public String Geographic_Region{get;set;} // Used to hold the account Geographic region
    Public String Employees{get;set;} // Used to hold the account Employee
    Public String Street{get;set;} // Used to hold the account street
    Public String City{get;set;} // Used to hold the account city information
    Public String State{get;set;} // Used to hold the account state information
    Public String Postal_Code{get;set;} // Used to hold the account postal code information
    Public String Country{get;set;} // Used to Hold the account country information
    Public ContactWrrap Contact{get;set;} // Used to Hold the related contact information 
    }
    
    Public Class ContactWrrap{
        Public String External_ID{get;set;} // Used to hold the contact external id
        Public String First_Name{get;set;} // Used to hold the contact First name 
        Public String Last_Name{get;set;} // Used to hold the contact Last Name 
        Public String Mailing_Street{get;set;} // Used to hold the contact Mailing street information
        Public String Mailing_City{get;set;} // Used to hold the contact Mailing City information
        Public String Mailing_State{get;set;} // Used to hold the contact Mailing State information 
        Public String Mailing_Postal_Code{get;set;} // Used to hold the contact Mailing Postal Code information
        Public String Mailing_Country{get;set;} // Used to hold the contact Mailing Country information
        Public String Email{get;set;} // Used to hold the contact Email
        Public String Phone{get;set;} // Used to hold the contact Phone
    }
  
}