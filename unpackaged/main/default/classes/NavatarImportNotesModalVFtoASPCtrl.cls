/****************************************************************************************************
  
    ** Module Name : Acuity 3.0 - Import Note
    ** Description : Controller class for VF page.
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Acuity 2.1
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2024-02-02          Sudhanshu      Controller class for VF page to call asp.net page.
****************************************************************************************************/
public with sharing class NavatarImportNotesModalVFtoASPCtrl {
    public NavatarImportNotesModalVFtoASPCtrl() {
        param1='';
    }
    // For holding first url parameter
 	public string param1{get;set;}

    // For holding first url parameter
 	public string param2{get;set;}

     // call this variable on VF page directly i.e. {!ResponseMsg}
     public string ResponseMsg{get{ processRequest(); return ''; }set; }
     
     
      /*
      * Purpose : Get the Url parameter   
     */
     public void processRequest(){
         // for holding url parameters values into map
         param2 = getNamespacePrefix();
         Map<String, object> parametersMap=new Map<String, object>();
         // Check for parameters
         if (ApexPages.currentPage() != null && ApexPages.currentPage().getParameters()!=null 
             && ApexPages.currentPage().getParameters().size()>0){
             parametersMap=ApexPages.currentPage().getParameters();
            }
 
         for(String key: parametersMap.keyset()){
             System.debug('Key'+key);
             if(key=='importID'){
                 param1=parametersMap.get(key)+'';
              }
          }
       }

     /*
     * Purpose : Fetches namespace prefix
     * Returns : Namespaceprefix to be used as a String
     */
    public static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl' LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())].NamespacePrefix;
        } catch (Exception e) {
            throw new AuraHandledException(e + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
}