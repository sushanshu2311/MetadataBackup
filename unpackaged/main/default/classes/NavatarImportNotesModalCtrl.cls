/****************************************************************************************************
  
    ** Module Name : Acuity 2.1 - Import Note
    ** Description : Rest class for insert record into content version object.
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Acuity 2.1
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2024-02-02          Sudhanshu      insert record into content version 
****************************************************************************************************/
@RestResource(urlMapping='/NavatarImportNotesModalCtrl/*')
global class NavatarImportNotesModalCtrl {
    @HttpPost
    global static String doPost(String jsonData) {
        //Stores the message
        string insertResult='';
        
        try{
            system.debug('=======jsonData====='+jsonData);
            Blob encodedJsonData = EncodingUtil.base64Decode(jsonData);			// Encoding json data 
            system.debug('=======encodedJsonData ====='+encodedJsonData);
            string jsonStr = encodedJsonData.toString();				
            Fileinfo deserializedFileData = (Fileinfo)JSON.deserialize(jsonStr,Fileinfo.class);  // deserialized json into wrapper class
            system.debug('=======deserializedFileData====='+deserializedFileData);
            
            //Condition for deserializedFileData is not null
            if(deserializedFileData !=null)
            {
              try{
                    if(deserializedFileData.isError == false){

                    
                        ContentVersion  contentVersionRec = new ContentVersion();		// object created for ContentVersion
                        contentVersionRec.Title = deserializedFileData.ImportID;
                        contentVersionRec.ContentLocation = 'S';
                        contentVersionRec.PathOnClient = contentVersionRec.Title +'.txt';
                        contentVersionRec.VersionData = Blob.valueOf(deserializedFileData.Description);
                        //Schema.sObjectType.Account.isUpdateable()
                        if (Schema.sObjectType.ContentVersion.isCreateable()) {
                        // Record inserted into object 
                        insert contentVersionRec;
                        publishEvent(deserializedFileData.ImportID,'Success');
                        }
                    }
                    else {
                        publishEvent(deserializedFileData.ImportID,deserializedFileData.Description);
                    }
                    insertResult='OK';								// Message for record inserted successfully

                }
                catch(Exception ex){             
                    system.debug('Error while inserting data into content version.'+ex.getMessage());
                    insertResult=ex.getMessage();					// Exception message 
                }                             
            }
        }
        catch(Exception e) 
        {
            System.debug('The following exception has occurred in Update Fund webservice: ' + e.getMessage());
            insertResult=e.getMessage();							// Exception Message
        }
       return insertResult;										// Return the Message
    } 

    public static void publishEvent(String ID, String Msg ){
        navpeII_dev18__Navatar_ImportNotes_Event__e event = new navpeII_dev18__Navatar_ImportNotes_Event__e();
        event.navpeII_dev18__ImportNotes_Message__c = Msg;
        event.navpeII_dev18__ImportNotes_ID__c =ID ;
        EventBus.publish(event);
    }
    
    /*
     * Purpose : Wrapper to store file information
    */
    public class Fileinfo
    {
        // for holding content of file
        public string Description;
        // for holding import ID 
        public string ImportID; 
        
        public Boolean isError;
    }  
}