/****************************************************************************************************
  
    ** Module Name : Acuity 2.1 - Import Note
    ** Description : Used for generate random number for import note and fetch the file content after file inserted into org & delete the file.
    ** Organization : Navatar Group
    ** Product Name & Version : Acuity 2.1
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2024-01-21          Sudhanshu      fetch file content and delete file record 
****************************************************************************************************/
public with sharing class NavatarGetImportNotesModalCtrl {
   /*
     * Purpose : Generate Random number for import ID;
     * Returns : return random number
    */
    @AuraEnabled
    public static string getImportID(){
        Integer len=8;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));		// Statndard function for generate random number
        String randomNumber = str.substring(0, len);
        String impStr = 'NavatarImp' + randomNumber;
        system.debug('Random Number-' + randomNumber);
        system.debug('StateCode-' + impStr);
        return impStr;
    }
    
    /*
     * Purpose : Get the uploaded file content from ContentVersion object and delete the file record from ContentDocument
     * Input : Import ID    
     * Returns : Uploaded file content
    */
    @AuraEnabled
    public static string getRecord(string ID){
           // for holding file content
           string textString ='';           
            try{        
                system.debug('Import ID ----'+ID);
                list<ContentVersion> newCV = [Select Id, ContentDocumentId, VersionData From ContentVersion Where Title = :ID AND IsLatest = true];
                    // if file exist in content version
                	if(newCV.size()>0){
                        Blob fileBody = newCV[newCV.size()-1].VersionData;
                        textString = fileBody.toString();
                    }
                 list<ContentDocument> conDocument = [Select Id, Title, FileExtension, CreatedDate From ContentDocument Where Title = :ID];
                    // if file exist in ContentDocument
                	if(conDocument.size()>0){  
                        if (Schema.sObjectType.ContentDocument.isDeletable()) {
                            delete conDocument;
                        }
                    }
                return textString;
            }
            catch(Exception e){
               return textString=e.getMessage();
                
            }
        
    }
}