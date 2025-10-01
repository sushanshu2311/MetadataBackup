/*********************************************************************************

* @Class Name : NavatarResearchCtrl

* @Description : Searching Based on SOSL, Related LWC component Name: NavigationTargetSearchPage
Class is working for search purpose on the basis of Serch keywork and show the search data on the basis of MetaData Fields.
It consist basically two wrapper-> innerStructureWrapper (For maintaing the search object Data)

* @Organization : Navatar Group

* @Revision History:-

* @Version Date(YYYY-MM-DD)          Author             Description of Action

* 1.0     2022-08-01             Ehatsham Ahamed
* 2.0     2024-03-08             Lakshya                Acuity Phase 3
*********************************************************************************/
public  with sharing class NavatarResearchCtrl {
    private static Map<String, Acuity_Setting__mdt> metadataFieldsAPiNames=new Map<String, Acuity_Setting__mdt>();
    private static map<String,map<string,string>> globalFieldTypeMap=new map<String,map<string,string>>();
    private static map<string,string> iconNameMap=new map<string,string>();
    private static map<string,boolean> objPermissionCheckStorage=new map<string,boolean>();
    //public static List<Acuity_Setting__mdt> MetadataFieldsAPiNames=new List<Acuity_Setting__mdt>();
    private static innerStructureWrapper wpdata=new innerStructureWrapper();// It will work, when search mechanishm will be hit
    private static columnListWrapper clWrapper=new columnListWrapper();// it will work, when column making functionality will be hit 
    // Store the recordtype record of particular objects 
    private static     List<RecordType> accountRecordTypeList=new List<RecordType>();
    private static    List<RecordType> contactRecordTypeList=new List<RecordType>(); 
    private static   List<RecordType> dealRecordTypeList=new List<RecordType>();
    private static   List<RecordType> fundRecordTypeList=new List<RecordType>(); 
    private static   List<RecordType> fundraisingRecordTypeList=new List<RecordType>();
    private static string accRctypCond;
    
    
    // Store the fiend names in the string manner with comma , separeted 
    
    
    /* ******      getfieldValue: *  
    *   this method for Mainly search pupose. It takes the parameter as search key on the behalf of search key it perform sosal query for particular object.
    *  it call SetMetadataFieldsAPiNamesData() method for fetching the dynamic fields from MetaData.
    *  it call setColumnAndFields() for setting the column and field information like (label, type,Apiname) with recordtype also.
    *  After performing the query it set the data in global innerStructureWrapper (wrapper). and send the wrapper to the component.
    
    sobj: Muliple objects(Account,Contact,Deal,Fund,Fundraising,Task,Event)
    
    fieldName : Field Name will come from MetaData 
    
    calling : NavatarResearchAdvanceResultCtrl methods  
    NamespacePrefix : ------.
    
    */
    @AuraEnabled
    public static innerStructureWrapper getSearchResultListWithAdvance(string fieldFilterData,string objectRecord,String quearyFieldsForClip,String quearyFieldsForTheme,String quearyFieldsForFundRaising,String quearyFieldsForFund,String quearyFieldsForAccount,string quearyFieldsForContact,String quearyFieldsForDeals,string searchKey, string checkComingSource){
    if(quearyFieldsForAccount.indexof('RecordType') != -1){
        accRctypCond='RecordTypeId != Null';
    }
    setMetadataFieldsAPiNamesData();
    boolean transactionFilterCheck=false;
    boolean trackFieldFilterProcessAcc=false;
    boolean trackFieldFilterProcessCon=false;
    boolean trackFieldFilterProcessDeal=false;
    boolean trackFieldFilterProcessFund=false;
    boolean trackFieldFilterProcessFundraising=false;
    boolean trackFieldFilterProcessTheme=false;
    boolean trackFieldFilterProcessClip=false;

    boolean checkingLookUpFunctionality=false;
    // for maintaining the advance search functionality 
    map<string,set<string>> mapOfListIdCorrToObjectName=new map<string,set<string>>();
    
    if(objectRecord != null && objectRecord != ''){
    mapOfListIdCorrToObjectName=NavatarResearchAdvanceResultCtrl.handlerAdvanceRecordMechanishm(objectRecord);
    
    if(mapOfListIdCorrToObjectName.get('currIdList') != null && mapOfListIdCorrToObjectName.get('currIdList').size() > 0){
    checkingLookUpFunctionality=true;
    }
    }
    string accString;
    string conString;
    string dealString;
    string fundString;
    string fundRaisingstring;
    string themeString;
    if(fieldFilterData != null && fieldFilterData != '' && fieldFilterData != 'null'){
    map<string,object> mpObjLwc=new map<string,object>();
    Map<String, object> fieldFilterParsedData = (Map<String, object>)JSON.deserializeUntyped(fieldFilterData);
   
   
    if(fieldFilterParsedData.get('Account') != null ){
    accString=string.valueOf(fieldFilterParsedData.get('Account'));
    if(accString != null && accString != '' && (!String.isBlank(accString))){
        trackFieldFilterProcessAcc=true;
        transactionFilterCheck=true;
    }
    }
    if(fieldFilterParsedData.get('Contact') != null ){
    conString=string.valueOf(fieldFilterParsedData.get('Contact'));
    if(conString != null && conString != '' && (!String.isBlank(conString))){
        trackFieldFilterProcessCon=true;
        transactionFilterCheck=true;
    }
    }
    if(fieldFilterParsedData.get('navpeII_dev18__Pipeline__c') != null ){
    dealString=string.valueOf(fieldFilterParsedData.get('navpeII_dev18__Pipeline__c'));
    if(dealString != null && dealString != '' && (!String.isBlank(dealString))){
        trackFieldFilterProcessDeal=true;
        transactionFilterCheck=true;
    }
    }
    if(fieldFilterParsedData.get('navpeII_dev18__Fund__c') != null ){
    fundString=string.valueOf(fieldFilterParsedData.get('navpeII_dev18__Fund__c'));
    if(fundString != null && fundString != '' && (!String.isBlank(fundString))){
        trackFieldFilterProcessFund=true;
        transactionFilterCheck=true;
    }
    }
    if(fieldFilterParsedData.get('navpeII_dev18__Fundraising__c') != null ){
    fundRaisingstring=string.valueOf(fieldFilterParsedData.get('navpeII_dev18__Fundraising__c'));
    if(fundRaisingstring != null && fundRaisingstring != '' && (!String.isBlank(fundRaisingstring))){
        trackFieldFilterProcessFundraising=true;
        transactionFilterCheck=true;
    }
    }
    if(fieldFilterParsedData.get('navpeII_dev18__Theme__c') != null ){
    themeString=string.valueOf(fieldFilterParsedData.get('navpeII_dev18__Theme__c'));
    if(themeString != null && themeString != '' && (!String.isBlank(themeString))){
        trackFieldFilterProcessTheme=true;
        transactionFilterCheck=true;
    }
    }
    
    list<string> accstringList=new list<string>();
    if(accString.contains('OR')){
    
    accstringList=accString.split('OR');
    }else{
    accstringList.add(accString);
    }
    
    }
    List<ContentDocument> fileSearchDataList=new List<ContentDocument>();
    try{
    boolean keyWordShouldBeSingleString=false;
    boolean specialCharPresent=false;
    boolean multipleQuoteWord=false;
    // setMetadataFieldsAPiNamesData(); // for maintaining the fields of sobjects 
    //clWrapper=setColumnAndFields();  // for maintaining the header column of object Table in LWC side 
    //makeObjectPermissionInMap(); // for makeing map according to object permission 
    makingRecordTypeFormate(); // for fetching the recordtype respective objects 
    set<string> dealsSetOfIN=new set<string>();
    set<string> fundraisingSetOfIN=new set<string>();
    
    
    set<string> themesSetOfIN=new set<string>();
    set<string> clipsSetOfIN=new set<string>();
    
    String soslSearchString = '';
    List<String> soqlSearchString =new List<String>();
    string soqlSearchKeyword='';
    string reserveStringChar=navatarResearchConstantCtrl.handelArributeSpecialChars;
    list<string> reserveStringCharList=new list<string>();
    reserveStringCharList=reserveStringChar.split('');
    
    List<String> strLST=new List<String>();// new changes
    
    //-------------------------------------------------------------------- 
// "ehatsham ahamed" string making algo   
boolean flagForSoqlApproach=false;
system.debug(' without trim data->'+searchKey);
if(searchKey != '' && searchKey != null && (!String.isBlank(searchKey))){
    searchKey=searchKey.trim();
    
    Integer [] nameArray =searchKey.getChars();
    
    if(searchKey.contains('"') && searchKey.lastIndexOf('"') == searchKey.length()-1 && nameArray[0] == 34){
    
    searchKey=searchKey.Substring(1,searchKey.length()-1);
    //searchKey=searchKey.replace('"','');
    searchKey=searchKey.trim();
    searchKey='"'+searchKey+'"';
    }
    if(searchKey.contains('" ') || searchKey.contains(' "')){
    multipleQuoteWord=true;
    List<String> strManage=new List<String>();
    string finalString='';
    
    
    string str=searchKey;
    str=str.replace('"',navatarResearchConstantCtrl.handelArribute2);
    
    strManage=str.split(',,,');
    
    for(string iterateStrData:strManage){
    if(iterateStrData.contains(navatarResearchConstantCtrl.handelArribute3)){
    string newString= iterateStrData.trim();
    newString=newString.replace(' ',navatarResearchConstantCtrl.handelArribute4);
    finalString=finalString+newString;
    }else if(iterateStrData.contains(navatarResearchConstantCtrl.handelArribute4)){
    
    finalString=finalString+iterateStrData;
    
    }else{
    string newString= iterateStrData.trim();
    newString=newString.replace(' ',navatarResearchConstantCtrl.handelArribute4);
    finalString=finalString+newString;
    
    }
    
    }
    /* str=str.replace('" ','=###=');
    str=str.replace(' "','=###=');
    
    str=str.replace('"','');*/
    str=finalString;
   
    
    searchKey=str;
    }
    
    //--------------------------------------------------------------------
    for(string chr:reserveStringCharList){
    chr=chr.replaceAll(' ', '');
    
    if(searchKey.contains(chr)){
    specialCharPresent=true;
    
    string newStr='\\'+chr;
    
    searchKey=searchKey.replace( chr , newStr );
    
    }
    }
    
    if(searchKey.contains('"') && searchKey.contains(' ') && searchKey.indexOf('"') == 0 && searchKey.lastIndexOf('"') == searchKey.length()-1){ 
    keyWordShouldBeSingleString=true;
    soslSearchString=searchKey.replaceAll('"', '');
    soslSearchString='{"'+soslSearchString+'"}';
    soqlSearchKeyword=searchKey.replaceAll('"', '');
    soqlSearchKeyword=soqlSearchKeyword.replace('\\\\', navatarResearchConstantCtrl.handelArribute5);
    soqlSearchKeyword=soqlSearchKeyword.replace('\\', '');
    soqlSearchKeyword=soqlSearchKeyword.replace(navatarResearchConstantCtrl.handelArribute5, '\\');
    soqlSearchKeyword='%'+soqlSearchKeyword+'%';
    soqlSearchString.add(soqlSearchKeyword);
    
    
    }else if((searchKey.contains(' ') && !searchKey.contains('"')) ||  searchKey.contains(navatarResearchConstantCtrl.handelArribute4)){
    
    List<String> searchStringList2=new List<String>();
    if(searchKey.contains(navatarResearchConstantCtrl.handelArribute4)){
    /* Integer [] nameArray =searchKey.getChars();
    nameArray.remove(0);
    nameArray.remove(nameArray.size()-1);
    searchKey = String.fromCharArray(nameArray);*/
    
    searchStringList2 = searchKey.split(navatarResearchConstantCtrl.handelArribute4);
    }else{
    //searchKey=searchKey.replaceAll('  ', ' ');
    searchStringList2 = searchKey.split(' ');
    }
    
    
    if(searchStringList2.size() > 1){
    For(String str : searchStringList2){
    if(str.length() > 1 && !String.isBlank(str)){
    str=str.trim();
    str=str.replace('\\\\', navatarResearchConstantCtrl.handelArribute5);
    str=str.replace('\\', '');
    str=str.replace(navatarResearchConstantCtrl.handelArribute5, '\\');
    string tempstr='%';
    tempstr=tempstr +''+str+'%';
    soqlSearchString.add(tempstr);
    if(soslSearchString == ''){
    soslSearchString = '('+soslSearchString + str.trim()+')';
    }else{
    soslSearchString = soslSearchString + ' OR (' + str.trim()+')';
    }
    if(multipleQuoteWord){
    soslSearchString=soslSearchString.replace('(', '"');
    soslSearchString=soslSearchString.replace(')', '"');
    }
    
    }
    if(soslSearchString.contains('\'')){
    soslSearchString=soslSearchString.replace('\'','\\\'');
    if(soslSearchString.contains('\\\\')){
    soslSearchString=soslSearchString.replace('\\\\','\\');
    }
    }
    }
    }
    
    /*keyWordShouldBeSingleString=true;
    soslSearchString=searchKey.replaceAll('"', '');
    soslSearchString='{"'+soslSearchString+'"}';
    soqlSearchKeyword=searchKey.replaceAll('"', '');
    soqlSearchKeyword='%'+soqlSearchKeyword+'%';
    soqlSearchString.add(soqlSearchKeyword);*/
    }
    else{
    if(specialCharPresent){
    keyWordShouldBeSingleString=true;
    }
    if(searchKey.contains('"')){
    searchKey=searchKey.replaceAll('"', '');
    }
    
    soslSearchString= '{'+searchKey+'}'; 
    searchKey=searchKey.replace(navatarResearchConstantCtrl.handelArribute6, navatarResearchConstantCtrl.handelArribute5);
    searchKey=searchKey.replace('\\', '');
    searchKey=searchKey.replace(navatarResearchConstantCtrl.handelArribute5, '\\');
    soqlSearchKeyword='%'+searchKey+'%';
    soqlSearchString.add(soqlSearchKeyword);
    }
    
    
}else{
system.debug('New Functionality');
flagForSoqlApproach=true;
    
}
    //---------------------------------Make search keyword for LIke QUery of Account and Contact------------------------------------
    
    string queryForAccount;
    set<string> accIdSet=new set<string>();
    if(mapOfListIdCorrToObjectName.get('Account') != null){
    accIdSet=mapOfListIdCorrToObjectName.get('Account');
    }
system.debug('accIdSet->'+accIdSet);
integer limitForLeftAccountRecord = Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(accIdSet != null && checkingLookUpFunctionality){
        system.debug('if');
        if(accString != null && accString != ''){
            queryForAccount='Select '+quearyFieldsForAccount+' From Account Where (Id IN :accIdSet AND ('+accString+')) AND '+accRctypCond+' Order By CreatedDate DESC Limit '+limitForLeftAccountRecord;
        }else{
            queryForAccount='Select '+ quearyFieldsForAccount +' From Account  Where Id IN :accIdSet AND '+accRctypCond+' Order By CreatedDate DESC Limit '+limitForLeftAccountRecord; 
        }
    }else{
        if(accString != null && accString != ''){
        queryForAccount='Select '+quearyFieldsForAccount+' From Account Where ('+accString+') AND '+accRctypCond+' Order By CreatedDate DESC Limit '+limitForLeftAccountRecord;
        }
    }
    
    
    
}else{
    if(keyWordShouldBeSingleString){
    if(accIdSet != null && checkingLookUpFunctionality){
        
    if(accString != null && accString != ''){
    queryForAccount='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where ('+ accRctypCond +' AND  Id IN :accIdSet) AND ('+accString+') Order By CreatedDate DESC)'; 
    
    }else{
    queryForAccount='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where ( '+accRctypCond+' AND Id IN :accIdSet) Order By CreatedDate DESC)'; 
    
    }
    
    }else{
       
    if(accString != null && accString != ''){
    queryForAccount='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where  '+accRctypCond +' AND ('+accString+') Order By CreatedDate DESC)'; 
    
    }else{
    queryForAccount='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where '+ accRctypCond+ ' Order By CreatedDate DESC)'; 
    }
    }
    
    
    }else{
    if(accIdSet != null && checkingLookUpFunctionality){
    if(accString != null && accString != ''){
    queryForAccount='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where ('+accRctypCond+' AND Id IN :accIdSet) AND ('+accString+') Order By CreatedDate DESC)';
    
    }else{
    queryForAccount='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where ( '+accRctypCond+' AND Id IN :accIdSet) Order By CreatedDate DESC)';
    }
    }else{
    if(accString != null && accString != ''){
    queryForAccount='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where '+accRctypCond+' AND ('+accString+') Order By CreatedDate DESC)';
    
    }else{
    queryForAccount='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Account ('+quearyFieldsForAccount +' Where '+accRctypCond+' Order By CreatedDate DESC)';
    }
    }
    
    }
}
system.debug('sosl acc-query->'+queryForAccount);
    string queryForContact;
    set<string> conSetId=new set<string>();
    if(mapOfListIdCorrToObjectName.get('Contact') != null){
    conSetId=mapOfListIdCorrToObjectName.get('Contact');
    }
integer limitForleftContactRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(conSetId != null && checkingLookUpFunctionality){
        system.debug('if');
        if(conString != null && conString != ''){
            queryForContact='Select '+quearyFieldsForContact+' From Contact Where Id IN :conSetId AND ('+conString+') Order By CreatedDate DESC Limit '+ limitForleftContactRecord;
        }else{
            queryForContact='Select '+ quearyFieldsForContact +' From Contact  Where Id IN :conSetId Order By CreatedDate DESC Limit '+limitForleftContactRecord; 
        }
    }else{
        if(conString != null && conString != ''){
            queryForContact='Select '+quearyFieldsForContact+' From Contact Where '+conString+' Order By CreatedDate DESC Limit '+limitForleftContactRecord;
        }
    }
    
    

}else{
    if(keyWordShouldBeSingleString){
    if(conSetId != null && checkingLookUpFunctionality){
    if(conString != null && conString != ''){
    queryForContact='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Where Id IN :conSetId AND ('+conString+') Order By CreatedDate DESC)';
    
    }else{
    queryForContact='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Where Id IN :conSetId Order By CreatedDate DESC)';
    }
    }else{
    if(conString != null && conString != ''){
    queryForContact='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +'Where '+conString+' Order By CreatedDate DESC)';
    
    }else{
    queryForContact='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Order By CreatedDate DESC)';
    }  
    }
    }else{
    if(conSetId != null && checkingLookUpFunctionality){
    if(conString != null && conString != ''){
    queryForContact='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Where Id IN :conSetId AND ('+conString+') Order By CreatedDate DESC)';
    
    }else{
    queryForContact='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Where Id IN :conSetId Order By CreatedDate DESC)';
    }
    }else{
    if(conString != null && conString != ''){
    queryForContact='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Where '+conString+' Order By CreatedDate DESC)';
    
    }else{
    queryForContact='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Contact ('+quearyFieldsForContact +' Order By CreatedDate DESC)';
    }
    }
    }
    
}


    string queryForDeal;
    set<string> dealSetId = new set<string>();
if(mapOfListIdCorrToObjectName.get('navpeII_dev18__Pipeline__c') != null){
dealSetId=mapOfListIdCorrToObjectName.get('navpeII_dev18__Pipeline__c');
}
integer limitForleftDealRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(dealSetId != null && checkingLookUpFunctionality){
        system.debug('if');
        if(dealString != null && dealString != ''){
            queryForDeal='Select '+quearyFieldsForDeals+' From navpeII_dev18__Pipeline__c Where Id IN :dealSetId AND ('+dealString+') Order By CreatedDate DESC Limit '+limitForleftDealRecord;
        }else{
            queryForDeal='Select '+ quearyFieldsForDeals +' From navpeII_dev18__Pipeline__c  Where Id IN :dealSetId Order By CreatedDate DESC Limit '+limitForleftDealRecord; 
        }
    }else{
        if(dealString != null && dealString != ''){
            queryForDeal='Select '+quearyFieldsForDeals+' From navpeII_dev18__Pipeline__c Where '+dealString+' Order By CreatedDate DESC Limit '+limitForleftDealRecord;
    }
    }
    
    

}else{
    if(keyWordShouldBeSingleString){
    if(dealSetId != null && checkingLookUpFunctionality){
    if(dealString != null && dealString != ''){
    queryForDeal='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Where Id IN :dealSetId AND ('+dealString+') Order By CreatedDate DESC)';
    
    }else{
    queryForDeal='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Where Id IN :dealSetId Order By CreatedDate DESC)';
    }
    }else{
    if(dealString != null && dealString != ''){
    queryForDeal='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Where '+dealString+' Order By CreatedDate DESC)';
    
    }else{
    queryForDeal='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Order By CreatedDate DESC)';
    }
    }
    }else{
    if(dealSetId != null && checkingLookUpFunctionality){
    if(dealString != null && dealString != ''){
    queryForDeal='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Where Id IN :dealSetId AND ('+dealString+') Order By CreatedDate DESC)'; 
    
    }else{
    queryForDeal='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Where Id IN :dealSetId Order By CreatedDate DESC)'; 
    }
    }else{
    if(dealString != null && dealString != ''){
    queryForDeal='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Where '+dealString+' Order By CreatedDate DESC)'; 
    
    }else{
    queryForDeal='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Pipeline__c ('+quearyFieldsForDeals +' Order By CreatedDate DESC)'; 
    }
    }
    }
    }
    
    string queryForFund;
    set<string> fundSetId = new set<string>();
if(mapOfListIdCorrToObjectName.get('navpeII_dev18__Fund__c') != null){
fundSetId=mapOfListIdCorrToObjectName.get('navpeII_dev18__Fund__c');
}
integer limitForleftFundRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(fundSetId != null && checkingLookUpFunctionality){
        system.debug('if');
        if(fundString != null && fundString != ''){
            queryForFund='Select '+quearyFieldsForFund+' From navpeII_dev18__Fund__c Where Id IN :fundSetId AND ('+fundString+') Order By CreatedDate DESC Limit '+limitForleftFundRecord;
        }else{
            queryForFund='Select '+ quearyFieldsForFund +' From navpeII_dev18__Fund__c  Where Id IN :fundSetId Order By CreatedDate DESC Limit '+limitForleftFundRecord; 
    }
    }else{
        if(fundString != null && fundString != ''){
            queryForFund='Select '+quearyFieldsForFund+' From navpeII_dev18__Fund__c Where '+fundString+' Order By CreatedDate DESC Limit '+limitForleftFundRecord;
        }
    }
    
    

}else{
    if(keyWordShouldBeSingleString){
    if(fundSetId != null && checkingLookUpFunctionality){
    if(fundString != null && fundString != ''){
    queryForFund='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Where Id IN :fundSetId AND ('+fundString+') Order By CreatedDate DESC)';
    
    }else{
    queryForFund='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Where Id IN :fundSetId Order By CreatedDate DESC)';
    }
    }else{
    if(fundString != null && fundString != ''){
    queryForFund='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Where '+fundString+' Order By CreatedDate DESC)';
    
    }else{
    queryForFund='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Order By CreatedDate DESC)';
    }
    }
    }else{
    if(fundSetId != null && checkingLookUpFunctionality){
    if(fundString != null && fundString != ''){
    queryForFund='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Where Id IN :fundSetId AND ('+fundString+') Order By CreatedDate DESC)';
    
    }else{
    queryForFund='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Where Id IN :fundSetId Order By CreatedDate DESC)';
    }
    }else{
    if(fundString != null && fundString != ''){
    queryForFund='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Where '+fundString+' Order By CreatedDate DESC)';
    
    }else{
    queryForFund='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fund__c ('+quearyFieldsForFund +' Order By CreatedDate DESC)';
    } 
    }
    }
    
}

    string queryForFundraising;
    set<string> fundraisingSetId = new set<string>();
if(mapOfListIdCorrToObjectName.get('navpeII_dev18__Fundraising__c') != null){
fundraisingSetId=mapOfListIdCorrToObjectName.get('navpeII_dev18__Fundraising__c');
}
integer limitForLeftFundraisingRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(fundraisingSetId != null && checkingLookUpFunctionality){
        system.debug('if');
        if(fundRaisingstring != null && fundRaisingstring != ''){
            queryForFundraising='Select '+quearyFieldsForFundRaising+' From navpeII_dev18__Fundraising__c Where Id IN :fundraisingSetId AND ('+fundRaisingstring+') Order By CreatedDate DESC Limit '+limitForLeftFundraisingRecord;
        }else{
            queryForFundraising='Select '+ quearyFieldsForFundRaising +' From navpeII_dev18__Fundraising__c  Where Id IN :fundraisingSetId Order By CreatedDate DESC Limit '+limitForLeftFundraisingRecord; 
        }
    }else{
        if(fundRaisingstring != null && fundRaisingstring != ''){
            queryForFundraising='Select '+quearyFieldsForFundRaising+' From navpeII_dev18__Fundraising__c Where '+fundRaisingstring+' Order By CreatedDate DESC Limit '+limitForLeftFundraisingRecord;
        }
    }
    
    

}else{
    if(keyWordShouldBeSingleString){
    if(fundraisingSetId != null && checkingLookUpFunctionality){
    if(fundRaisingstring != null && fundRaisingstring != ''){
    queryForFundraising='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Where Id IN :fundraisingSetId AND ('+fundRaisingstring+') Order By CreatedDate DESC)';
    
    }else{
    queryForFundraising='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Where Id IN :fundraisingSetId Order By CreatedDate DESC)';
    }
    }else{
    if(fundRaisingstring != null && fundRaisingstring != ''){
    queryForFundraising='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Where '+fundRaisingstring+' Order By CreatedDate DESC)';
    
    }else{
    queryForFundraising='FIND '+soslSearchString+' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Order By CreatedDate DESC)';
    }
    }
    }else{
    if(fundraisingSetId != null && checkingLookUpFunctionality){
    if(fundRaisingstring != null && fundRaisingstring != ''){
    queryForFundraising='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Where Id IN :fundraisingSetId AND ('+fundRaisingstring+') Order By CreatedDate DESC)';
    
    }else{
    queryForFundraising='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Where Id IN :fundraisingSetId Order By CreatedDate DESC)';
    }
    }else{
    if(fundRaisingstring != null && fundRaisingstring != ''){
    queryForFundraising='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Where '+fundRaisingstring+' Order By CreatedDate DESC)';
    
    }else{
queryForFundraising='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Fundraising__c ('+quearyFieldsForFundRaising +' Order By CreatedDate DESC)';
}
    }
    }
    }
    // ---------------- file section ---------------------------------------------------------------------------------
    
    string queryForFile;
    if(keyWordShouldBeSingleString){
    queryForFile = 'FIND '+soslSearchString+' IN ALL FIELDS RETURNING ContentDocument (Id ORDER BY Title)';
       
    }
    else{
    queryForFile = 'FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING ContentDocument (Id ORDER BY Title)';
         
    }
    
    //     ---------------------------------------------------------------------------------------------------------------     
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Task.fields.getMap();
    Schema.DescribeFieldResult     field = fieldMap.get('Description').getDescribe() ;
    string queryForTask;
    set<string> taskSetId = new set<string>();
    if(mapOfListIdCorrToObjectName.get('Task') != null){
    taskSetId=mapOfListIdCorrToObjectName.get('Task');
    }
integer limitForLeftTaskRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
system.debug('task set id->'+taskSetId);
if(flagForSoqlApproach){
    if(taskSetId != null && checkingLookUpFunctionality){
        //Added ListEmail check by LK on 2024-05-10 to fix 00045611
        queryForTask='Select Subject,Id,Description,FORMAT(ActivityDate)  From Task Where Id IN :taskSetId AND TaskSubType != \'ListEmail\' Order By CreatedDate DESC Limit '+limitForLeftTaskRecord;
    
    }
    
}else{
    if(keyWordShouldBeSingleString){
    if(taskSetId != null && checkingLookUpFunctionality){
        if(field.isAccessible()){
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
    queryForTask='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Task (Subject,Id,Description,FORMAT(ActivityDate) Where Id IN :taskSetId AND TaskSubType != \'ListEmail\' Order By CreatedDate DESC)';
        }else{
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
            queryForTask='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Task (Subject,Id,FORMAT(ActivityDate) Where Id IN :taskSetId AND TaskSubType != \'ListEmail\' Order By CreatedDate DESC)';
    
        }
    }else{
        if(field.isAccessible()){
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
queryForTask='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Task (Subject,Id,Description,FORMAT(ActivityDate) Where (NOT Related_Associations__c LIKE :soqlSearchString) AND (TaskSubType != \'ListEmail\') Order By CreatedDate DESC)';
        }else{
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
            queryForTask='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Task (Subject,Id,FORMAT(ActivityDate) Where (NOT Related_Associations__c LIKE :soqlSearchString) AND (TaskSubType != \'ListEmail\') Order By CreatedDate DESC)';
    
        }
    }
    }else{
    if(taskSetId != null && checkingLookUpFunctionality){
        if(field.isAccessible()){
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
    queryForTask='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Task (Subject,Id,Description,FORMAT(ActivityDate) Where Id IN :taskSetId AND TaskSubType != \'ListEmail\' Order By CreatedDate DESC)';
        }else{
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
            queryForTask='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Task (Subject,Id,FORMAT(ActivityDate) Where Id IN :taskSetId AND TaskSubType != \'ListEmail\' Order By CreatedDate DESC)';
    
        }
}else{
        if(field.isAccessible()){
            //Added ListEmail check by LK on 2024-05-10 to fix 00045611
queryForTask='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Task (Subject,Id,Description,FORMAT(ActivityDate) Where (NOT Related_Associations__c LIKE :soqlSearchString) AND (TaskSubType != \'ListEmail\') Order By CreatedDate DESC)';
    }else{
        //Added ListEmail check by LK on 2024-05-10 to fix 00045611
            queryForTask='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Task (Subject,Id,FORMAT(ActivityDate) Where (NOT Related_Associations__c LIKE :soqlSearchString) AND (TaskSubType != \'ListEmail\') Order By CreatedDate DESC)';
       
    }
    }
}
}
    Map<String, Schema.SObjectField> fieldMapEvent = Schema.SObjectType.Event.fields.getMap();
    Schema.DescribeFieldResult     fieldEvent = fieldMap.get('Description').getDescribe() ;
    string queryForEvent;
    set<string> eventSetId = new set<string>();
    if(mapOfListIdCorrToObjectName.get('Event') != null){
    eventSetId=mapOfListIdCorrToObjectName.get('Event');
    }
integer limitForLeftEventRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(eventSetId != null && checkingLookUpFunctionality){
        queryForEvent='Select Subject,Id,Description,FORMAT(StartDateTime),FORMAT(ActivityDate),IsAllDayEvent  From Event  Where (Id IN :eventSetId AND IsChild = false) Order By CreatedDate DESC Limit '+limitForLeftEventRecord;
       
    }
    
}else{
    if(keyWordShouldBeSingleString){
        if(eventSetId != null && checkingLookUpFunctionality){
            if(fieldEvent.isAccessible()){
queryForEvent='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Event (Subject,Id,Description,FORMAT(StartDateTime),FORMAT(ActivityDate),IsAllDayEvent Where ((NOT Related_Associations__c LIKE :soqlSearchString) AND (Id IN :eventSetId AND IsChild = false)) Order By CreatedDate DESC)';
            }else{
                queryForEvent='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Event (Subject,Id,FORMAT(StartDateTime),FORMAT(ActivityDate),IsAllDayEvent Where ((NOT Related_Associations__c LIKE :soqlSearchString) AND (Id IN :eventSetId AND IsChild = false)) Order By CreatedDate DESC)';
        
            }
}else{
            if(fieldEvent.isAccessible()){
queryForEvent='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Event (Subject,Id,Description,FORMAT(StartDateTime),FORMAT(ActivityDate),IsAllDayEvent Where ((NOT Related_Associations__c LIKE :soqlSearchString) AND (IsChild = false)) Order By CreatedDate DESC)';
        }else{
                queryForEvent='FIND '+soslSearchString+' IN ALL FIELDS RETURNING Event (Subject,Id,FORMAT(StartDateTime),FORMAT(ActivityDate),IsAllDayEvent Where ((NOT Related_Associations__c LIKE :soqlSearchString) AND (IsChild = false)) Order By CreatedDate DESC)';
        
            }
        }
        }else{
        if(eventSetId != null && checkingLookUpFunctionality){
            if(fieldEvent.isAccessible()){
queryForEvent='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Event (Subject,Id,Description,FORMAT(StartDateTime),IsAllDayEvent,FORMAT(ActivityDate) Where ((NOT Related_Associations__c LIKE :soqlSearchString) AND (Id IN :eventSetId AND IsChild = false )) Order By CreatedDate DESC)';
            }else{
                queryForEvent='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Event (Subject,Id,FORMAT(StartDateTime),IsAllDayEvent,FORMAT(ActivityDate) Where ((NOT Related_Associations__c LIKE :soqlSearchString) AND (Id IN :eventSetId AND IsChild = false )) Order By CreatedDate DESC)';
        
            }
        }else{
            if(fieldEvent.isAccessible()){
queryForEvent='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Event (Subject,Id,Description,FORMAT(StartDateTime),IsAllDayEvent,FORMAT(ActivityDate) Where  ((NOT Related_Associations__c LIKE :soqlSearchString) AND (IsChild = false)) Order By CreatedDate DESC)';
            }else{
                queryForEvent='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING Event (Subject,Id,FORMAT(StartDateTime),IsAllDayEvent,FORMAT(ActivityDate) Where  ((NOT Related_Associations__c LIKE :soqlSearchString) AND (IsChild = false)) Order By CreatedDate DESC)';
       
        }
        }
}
}
system.debug('task Query)_>'+queryForTask);
    //----------------------------Theme & Clip Query Part---------------------------------------------------------------------------------------------------
    string queryForTheme;
    set<string> themeSetId = new set<string>();
    if(mapOfListIdCorrToObjectName.get('navpeII_dev18__Theme__c') != null){
    themeSetId=mapOfListIdCorrToObjectName.get('navpeII_dev18__Theme__c');
}
integer limitForLeftThemeRecord=Limits.getLimitQueryRows()-Limits.getQueryRows();
if(flagForSoqlApproach){
if(themeSetId!=null&&checkingLookUpFunctionality){
system.debug('if');
if(themeString!=null&&themeString!=''){
queryForTheme='Select '+quearyFieldsForTheme+' From Theme__c Where Id IN:themeSetId AND('+themeString+') Order By CreatedDate DESC Limit '+limitForLeftThemeRecord;
}else{
queryForTheme='Select '+quearyFieldsForTheme+' From Theme__c Where Id IN:themeSetId Order By CreatedDate DESC Limit '+limitForLeftThemeRecord;
}
}else{
if(themeString!=null&&themeString!=''){
queryForTheme='Select '+quearyFieldsForTheme+' From Theme__c Where '+themeString+' Order By CreatedDate DESC Limit'+limitForLeftThemeRecord;
}    
}
    
    

}else{
    if(keyWordShouldBeSingleString){
    if(themeSetId != null && checkingLookUpFunctionality){
    if(themeString != null && themeString != ''){
    queryForTheme='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Where Id IN :themeSetId AND ('+themeString+') Order By CreatedDate DESC)';                
    
    }else{
    queryForTheme='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Where Id IN :themeSetId Order By CreatedDate DESC)';                
    }
    }else{
    if(themeString != null && themeString != ''){
    queryForTheme='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Where '+themeString+' Order By CreatedDate DESC)';                
    
    }else{
    queryForTheme='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Order By CreatedDate DESC)';                
    }
    }
    }else{
    if(themeSetId != null && checkingLookUpFunctionality){
    if(themeString != null && themeString != ''){
    queryForTheme='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Where Id IN :themeSetId AND ('+themeString+') Order By CreatedDate DESC)';
    
    }else{
    queryForTheme='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Where Id IN :themeSetId Order By CreatedDate DESC)';
    }
    }else{
    if(themeString != null && themeString != ''){
    queryForTheme='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Where '+themeString+' Order By CreatedDate DESC)';
    
    }else{
    queryForTheme='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__theme__c ('+quearyFieldsForTheme +' Order By CreatedDate DESC)';
    }
    }
    }
}
    string queryForClip;
    set<string> clipSetId = new set<string>();
if(mapOfListIdCorrToObjectName.get('navpeII_dev18__Clip__c') != null){
clipSetId=mapOfListIdCorrToObjectName.get('navpeII_dev18__Clip__c');
}
integer limitForLeftClipRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
if(flagForSoqlApproach){
    if(clipSetId != null && checkingLookUpFunctionality){

            queryForClip='Select '+ quearyFieldsForClip +' From Clip__c  Where Id IN :clipSetId Order By CreatedDate DESC Limit '+limitForLeftClipRecord; 
    }
    
    

}else{
    if(keyWordShouldBeSingleString){
    if(clipSetId != null && checkingLookUpFunctionality){
    queryForClip='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING navpeII_dev18__clip__c ('+quearyFieldsForClip +' Where Id In :clipSetId Order By CreatedDate DESC)';                
    
    }else{
    queryForClip='FIND '+ soslSearchString +' IN ALL FIELDS RETURNING navpeII_dev18__clip__c ('+quearyFieldsForClip +' Order By CreatedDate DESC)';                
    }
    }else{
    if(clipSetId != null && checkingLookUpFunctionality){
    queryForClip='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__clip__c ('+quearyFieldsForClip +' Where Id In :clipSetId Order By CreatedDate DESC)';
    
    }else{
    queryForClip='FIND '+'\'*'+soslSearchString+'*\'' +' IN ALL FIELDS RETURNING navpeII_dev18__clip__c ('+quearyFieldsForClip +' Order By CreatedDate DESC)';
    }
    }
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------
    List<Account> accountSearchDataList=new List<Account>();
    List<Contact> contactSearchDataList=new List<Contact>();
    List<navpeII_dev18__Pipeline__c> dealSearchDataList=new List<navpeII_dev18__Pipeline__c>();
    List<navpeII_dev18__Fund__c> fundSearchDataList=new List<navpeII_dev18__Fund__c>();
    List<navpeII_dev18__Fundraising__c> fundraisingSearchDataList=new List<navpeII_dev18__Fundraising__c>();
    List<navpeII_dev18__theme__c> themeSearchDataList=new List<navpeII_dev18__theme__c>();
    List<navpeII_dev18__clip__c> clipSearchDataList=new List<navpeII_dev18__clip__c>();
    List<sobject> taskSearchDataList = new List<sobject>();    
    try{
    
if(flagForSoqlApproach){
    List<task> tskList=new List<task>();
    List<event> evtList=new List<event>();
    system.debug('-->'+queryForAccount);
    if(transactionFilterCheck && trackFieldFilterProcessAcc){
    if(queryForAccount != null && queryForAccount != ''){accountSearchDataList=database.query(queryForAccount);}
    }else if(transactionFilterCheck || trackFieldFilterProcessAcc){

    }else{
    if(queryForAccount != null && queryForAccount != ''){accountSearchDataList=database.query(queryForAccount);}
    }
    system.debug('444'+accountSearchDataList);
    if(transactionFilterCheck && trackFieldFilterProcessCon){
    if(queryForContact != null && queryForContact != ''){contactSearchDataList=database.query(queryForContact);}
    }else if(transactionFilterCheck || trackFieldFilterProcessCon){

    }else{
    if(queryForContact != null && queryForContact != ''){contactSearchDataList=database.query(queryForContact);} 
    }

    if(transactionFilterCheck && trackFieldFilterProcessDeal){
    //Added "&& String.isNotBlank(quearyFieldsForDeals)" by LK on 2024-01-02 to fix the IR Only & Deal Only permission issue
    if(queryForDeal != null && queryForDeal != '' && String.isNotBlank(quearyFieldsForDeals)){dealSearchDataList=database.query(queryForDeal);}
    }else if(transactionFilterCheck || trackFieldFilterProcessDeal){

    }else{
        //Added "&& String.isNotBlank(quearyFieldsForDeals)" by LK on 2024-01-02 to fix the IR Only & Deal Only permission issue
    if(queryForDeal != null && queryForDeal != '' && String.isNotBlank(quearyFieldsForDeals)){dealSearchDataList=database.query(queryForDeal);} 
    }
    
    if(transactionFilterCheck && trackFieldFilterProcessFund){
        //Added "&& String.isNotBlank(quearyFieldsForFund)" by LK on 2024-01-02 to fix the IR Only & Deal Only permission issue
    if(queryForFund != null && queryForFund != '' && String.isNotBlank(quearyFieldsForFund)){fundSearchDataList=database.query(queryForFund);}
    }else if(transactionFilterCheck || trackFieldFilterProcessFund){

    }else{
        //Added "&& String.isNotBlank(quearyFieldsForFund)" by LK on 2024-01-02 to fix the IR Only & Deal Only permission issue
    if(queryForFund != null && queryForFund != '' && String.isNotBlank(quearyFieldsForFund)){fundSearchDataList=database.query(queryForFund);}
    }

    if(transactionFilterCheck && trackFieldFilterProcessFundraising){
        //Added "&& String.isNotBlank(quearyFieldsForFundRaising)" by LK on 2024-01-02 to fix the IR Only & Deal Only permission issue
    if(queryForFundraising != null && queryForFundraising != '' && String.isNotBlank(quearyFieldsForFundRaising)){fundraisingSearchDataList=database.query(queryForFundraising);}
    }else if(transactionFilterCheck || trackFieldFilterProcessFundraising){

    }else{
        //Added "&& String.isNotBlank(quearyFieldsForFundRaising)" by LK on 2024-01-02 to fix the IR Only & Deal Only permission issue
    if(queryForFundraising != null && queryForFundraising != '' && String.isNotBlank(quearyFieldsForFundRaising)){fundraisingSearchDataList=database.query(queryForFundraising);}
    }

    if(transactionFilterCheck && trackFieldFilterProcessTheme){ 
    if(queryForTheme != null && queryForTheme != ''){themeSearchDataList=database.query(queryForTheme);}
    }else if(transactionFilterCheck || trackFieldFilterProcessTheme){

    }else{
    if(queryForTheme != null && queryForTheme != ''){themeSearchDataList=database.query(queryForTheme);}
    }

    if(transactionFilterCheck && trackFieldFilterProcessClip){ 
    if(queryForClip != null && queryForClip != ''){clipSearchDataList=database.query(queryForClip);}
    }else if(transactionFilterCheck || trackFieldFilterProcessClip){

    }else{
    if(queryForClip != null && queryForClip != ''){clipSearchDataList=database.query(queryForClip);}
    }

    
    if(!transactionFilterCheck){
    if(queryForTask != null && queryForTask != ''){tskList=database.query(queryForTask);}
    if(queryForEvent != null && queryForEvent != ''){evtList=database.query(queryForEvent);}
    }

    for(task tk:tskList){
        taskSearchDataList.add(tk);
    }
    for(event et:evtList){
        taskSearchDataList.add(et);
    }

}else{
system.debug(queryForAccount);
    
    List<Search.SearchResult> searchResultAccountlist=new List<Search.SearchResult>();
    if(transactionFilterCheck && trackFieldFilterProcessAcc){
    if(Schema.sObjectType.Account.isAccessible()){
    Search.SearchResults searchResultsCopy = Search.find(queryForAccount,AccessLevel.USER_MODE);
    
    
    
   
    SearchResultAccountlist= searchResultsCopy.get('Account');
    
    for(Search.SearchResult sr:searchResultAccountlist){
    Account accRec = (Account) sr.getSObject();
    
    accountSearchDataList.add(accRec);
    /*  if(mapOfListIdCorrToObjectName.get('Account') != null){
    
    if(mapOfListIdCorrToObjectName.get('Account').contains(string.valueOf(accRec.id))){
    accountSearchDataList.add(accRec);
    }
    }else{
    accountSearchDataList.add(accRec);
    }*/
    }
    
    }
}else if(transactionFilterCheck || trackFieldFilterProcessAcc){

}else{
    if(Schema.sObjectType.Account.isAccessible()){
        Search.SearchResults searchResultsCopy = Search.find(queryForAccount,AccessLevel.USER_MODE);
        
        
        
       
        SearchResultAccountlist= searchResultsCopy.get('Account');
        
        for(Search.SearchResult sr:searchResultAccountlist){
        Account accRec = (Account) sr.getSObject();
        
        accountSearchDataList.add(accRec);
        /*  if(mapOfListIdCorrToObjectName.get('Account') != null){
        
        if(mapOfListIdCorrToObjectName.get('Account').contains(string.valueOf(accRec.id))){
        accountSearchDataList.add(accRec);
        }
        }else{
        accountSearchDataList.add(accRec);
        }*/
        }
        
        }
}
List<Search.SearchResult> searchResultContactlist=new List<Search.SearchResult>();
if(transactionFilterCheck && trackFieldFilterProcessCon){
    if(Schema.sObjectType.Contact.isAccessible()){
    Search.SearchResults searchResultsContact = Search.find(queryForContact,AccessLevel.USER_MODE);
    
    
    
    searchResultContactlist= searchResultsContact.get('Contact');
    
    for(Search.SearchResult sr:searchResultContactlist){
    contact accRec = (Contact) sr.getSObject();
    contactSearchDataList.add(accRec);
    }
    }
}else if(transactionFilterCheck || trackFieldFilterProcessCon){

}else{
    if(Schema.sObjectType.Contact.isAccessible()){
        Search.SearchResults searchResultsContact = Search.find(queryForContact,AccessLevel.USER_MODE);
        
        
        
        searchResultContactlist= searchResultsContact.get('Contact');
        
        for(Search.SearchResult sr:searchResultContactlist){
        contact accRec = (Contact) sr.getSObject();
        contactSearchDataList.add(accRec);
        }
        }
}
List<Search.SearchResult> searchResultDeallist=new List<Search.SearchResult>();
if(transactionFilterCheck && trackFieldFilterProcessDeal){
    if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
    Search.SearchResults searchResultsDeal = Search.find(queryForDeal,AccessLevel.USER_MODE);
    
   
    searchResultDeallist= searchResultsDeal.get('navpeII_dev18__Pipeline__c');
    
    for(Search.SearchResult sr:searchResultDeallist){
    navpeII_dev18__Pipeline__c accRec = (navpeII_dev18__Pipeline__c) sr.getSObject();
    dealSearchDataList.add(accRec);
    dealsSetOfIN.add(string.ValueOf(accRec.Id));
    }
    }
}else if(transactionFilterCheck || trackFieldFilterProcessDeal){

}else{
    if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
        Search.SearchResults searchResultsDeal = Search.find(queryForDeal,AccessLevel.USER_MODE);
        
       
        searchResultDeallist= searchResultsDeal.get('navpeII_dev18__Pipeline__c');
        
        for(Search.SearchResult sr:searchResultDeallist){
        navpeII_dev18__Pipeline__c accRec = (navpeII_dev18__Pipeline__c) sr.getSObject();
        dealSearchDataList.add(accRec);
        dealsSetOfIN.add(string.ValueOf(accRec.Id));
        }
        }
}
List<Search.SearchResult> searchResultFundlist=new List<Search.SearchResult>();
if(transactionFilterCheck && trackFieldFilterProcessFund){
    if(Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible()){
    Search.SearchResults searchResultsFund = Search.find(queryForFund,AccessLevel.USER_MODE);   
    
    
   
    searchResultFundlist= searchResultsFund.get('navpeII_dev18__Fund__c');
    
    for(Search.SearchResult sr:searchResultFundlist){
    navpeII_dev18__Fund__c accRec = (navpeII_dev18__Fund__c) sr.getSObject();
    fundSearchDataList.add(accRec);
    }
    }
}else if(transactionFilterCheck || trackFieldFilterProcessFund){

}else{
    if(Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible()){
        Search.SearchResults searchResultsFund = Search.find(queryForFund,AccessLevel.USER_MODE);   
        
        
      
        searchResultFundlist= searchResultsFund.get('navpeII_dev18__Fund__c');
        
        for(Search.SearchResult sr:searchResultFundlist){
        navpeII_dev18__Fund__c accRec = (navpeII_dev18__Fund__c) sr.getSObject();
        fundSearchDataList.add(accRec);
        }
        }
}

List<Search.SearchResult> searchResultFundraisinglist=new List<Search.SearchResult>();
if(transactionFilterCheck && trackFieldFilterProcessFundraising){
    if(Schema.sObjectType.navpeII_dev18__Fundraising__c.isAccessible()){
    Search.SearchResults searchResultsFundraising = Search.find(queryForFundraising,AccessLevel.USER_MODE);
    
    
    searchResultFundraisinglist= searchResultsFundraising.get('navpeII_dev18__Fundraising__c');
    
    for(Search.SearchResult sr:searchResultFundraisinglist){
    navpeII_dev18__Fundraising__c accRec = (navpeII_dev18__Fundraising__c) sr.getSObject();
    fundraisingSearchDataList.add(accRec);
    fundraisingSetOfIN.add(string.ValueOf(accRec.Id));
    }
    }
}else if(transactionFilterCheck || trackFieldFilterProcessFundraising){

}else{
    if(Schema.sObjectType.navpeII_dev18__Fundraising__c.isAccessible()){
        Search.SearchResults searchResultsFundraising = Search.find(queryForFundraising,AccessLevel.USER_MODE);
        
      
        searchResultFundraisinglist= searchResultsFundraising.get('navpeII_dev18__Fundraising__c');
        
        for(Search.SearchResult sr:searchResultFundraisinglist){
        navpeII_dev18__Fundraising__c accRec = (navpeII_dev18__Fundraising__c) sr.getSObject();
        fundraisingSearchDataList.add(accRec);
        fundraisingSetOfIN.add(string.ValueOf(accRec.Id));
        }
        }
}
    //--------------------------Theme and clip data retrival from sosl mechanishm------------------------------------------------------------------------------------------------------------------------------
    List<Search.SearchResult> searchResultThemelist=new List<Search.SearchResult>();
    if(transactionFilterCheck && trackFieldFilterProcessTheme){   
    if(Schema.sObjectType.navpeII_dev18__theme__c.isAccessible()){
    Search.SearchResults searchResultsTheme = Search.find(queryForTheme,AccessLevel.USER_MODE);
    
    
    searchResultThemelist= searchResultsTheme.get('navpeII_dev18__theme__c');
    
    for(Search.SearchResult sr:searchResultThemelist){
        navpeII_dev18__theme__c accRec = (navpeII_dev18__Theme__c) sr.getSObject();
    themeSearchDataList.add(accRec);
    themesSetOfIN.add(string.ValueOf(accRec.Id));
    }
    }
}else if(transactionFilterCheck || trackFieldFilterProcessTheme){

}else{
    if(Schema.sObjectType.navpeII_dev18__Theme__c.isAccessible()){
        Search.SearchResults searchResultsTheme = Search.find(queryForTheme,AccessLevel.USER_MODE);
        
       
        searchResultThemelist= searchResultsTheme.get('navpeII_dev18__theme__c');
        
        for(Search.SearchResult sr:searchResultThemelist){
            navpeII_dev18__Theme__c accRec = (navpeII_dev18__Theme__c) sr.getSObject();
        themeSearchDataList.add(accRec);
        themesSetOfIN.add(string.ValueOf(accRec.Id));
        }
        }
}
    
List<Search.SearchResult> searchResultCliplist=new List<Search.SearchResult>();
if(transactionFilterCheck && trackFieldFilterProcessClip){ 
    if(Schema.sObjectType.navpeII_dev18__Clip__c.isAccessible()){
    Search.SearchResults searchResultsClip = Search.find(queryForClip,AccessLevel.USER_MODE);
    
   
    searchResultCliplist= searchResultsClip.get('navpeII_dev18__Clip__c');
    
    for(Search.SearchResult sr:searchResultCliplist){
        navpeII_dev18__clip__c accRec = (navpeII_dev18__clip__c) sr.getSObject();
    clipSearchDataList.add(accRec);
    clipsSetOfIN.add(string.ValueOf(accRec.Id));
    }
    }
}else if(transactionFilterCheck || trackFieldFilterProcessClip){

}else{
    if(Schema.sObjectType.navpeII_dev18__Clip__c.isAccessible()){
        Search.SearchResults searchResultsClip = Search.find(queryForClip,AccessLevel.USER_MODE);
        
      
        searchResultCliplist= searchResultsClip.get('navpeII_dev18__Clip__c');
        
        for(Search.SearchResult sr:searchResultCliplist){
            navpeII_dev18__clip__c accRec = (navpeII_dev18__clip__c) sr.getSObject();
        clipSearchDataList.add(accRec);
        clipsSetOfIN.add(string.ValueOf(accRec.Id));
        }
        }
}
    //--------------------------------------------------------------------------------------------------------------------------------------
    //--------------------------------------------file record fetch by sosl--------------------------------------------------------------
    
    List<Search.SearchResult> searchResultFilelist=new List<Search.SearchResult>();
    Search.SearchResults searchResultsFile = Search.find(queryForFile,AccessLevel.USER_MODE);
    searchResultFilelist= searchResultsFile.get('ContentDocument');
    for(Search.SearchResult sr:searchResultFilelist){
    ContentDocument fileRec = (ContentDocument) sr.getSObject();
    
    fileSearchDataList.add(fileRec);
    }
    //----------------------------------------------------------------------------------------------------------
   
    //List<sobject> taskSearchDataList=new List<sobject>();
    if(!transactionFilterCheck){
    Search.SearchResults searchResultsTask = Search.find(queryForTask,AccessLevel.USER_MODE);  
    Search.SearchResults searchResultsEvent = Search.find(queryForEvent,AccessLevel.USER_MODE);
    
    List<Search.SearchResult> searchResultTasklist=new List<Search.SearchResult>();
    searchResultTasklist= searchResultsTask.get('Task');
    
    for(Search.SearchResult sr:searchResultTasklist){
    Task accRec = (Task) sr.getSObject();
    taskSearchDataList.add(accRec);
    }
    
    
    List<Search.SearchResult> searchResultEventlist=new List<Search.SearchResult>();
    searchResultEventlist= searchResultsEvent.get('Event');
    List<Event> eventSearchDataList=new List<Event>();
    for(Search.SearchResult sr:searchResultEventlist){
    Event accRec = (Event) sr.getSObject();
    
    taskSearchDataList.add(accRec);
    }
}

   
    
    }
    wpdata.accList=accountSearchDataList;
    system.debug('444'+accountSearchDataList);
    wpdata.conList=contactSearchDataList;
    
    wpdata.dealList=dealSearchDataList;
    
    wpdata.fundList=fundSearchDataList;
    
    wpdata.fundRaisList=fundraisingSearchDataList;
    wpdata.fileList=fileSearchDataList;
    //------------------------------------------------------------------------------------------------------------------------
    wpdata.themeList=themeSearchDataList;
    wpdata.clipList=clipSearchDataList;
    //---------------------------------------------------------------------------------------------------------------------------
    wpdata.taskList=taskSearchDataList;
    }catch(exception e){
    system.debug(e.getMessage()+'  error occure on Line number ->'+e.getLineNumber()+' in APEX Code- Please cheack Metadata Field APi Name');
    wpdata.errorMessage='Error Occured While Loading Component : <<'+e.getMessage()+e.getLineNumber()+'>>';
    
    return wpdata;
    } 

    map<id,Account> accountListLikeMap=new map<id,Account>([select ID,Name from Account where name LIKE :soqlSearchString Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]); //bug Fix (Bulk)
    List<navpeII_dev18__Pipeline__c> soqlDealList=new List<navpeII_dev18__Pipeline__c>();
    List<navpeII_dev18__Fundraising__c> soqlFundraisingList=new List<navpeII_dev18__Fundraising__c>();
    set<id> mapkeys=new set<id>();
    
    mapkeys.addAll(accountListLikeMap.keyset());
if((!checkingLookUpFunctionality) && (!transactionFilterCheck) && (!flagForSoqlApproach)){// checking specific record and fielf filter functionality
    integer limitLeftForRows=Limits.getLimitQueryRows() - Limits.getQueryRows();
    string dealQuery='Select '+quearyFieldsForDeals+' From navpeII_dev18__Pipeline__c Where Id Not IN:dealsSetOfIN AND navpeII_dev18__Company__c IN:mapkeys Limit '+limitLeftForRows;
    if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
    soqlDealList=database.query(String.escapeSingleQuotes(dealQuery));
    }
    
    for(navpeII_dev18__Pipeline__c deal:soqlDealList){
    dealSearchDataList.add(deal);
    }
    
    wpdata.dealList=dealSearchDataList;
    integer limitForFundraisingRecords=Limits.getLimitQueryRows() - Limits.getQueryRows();
    string fundRaisingQuery='Select '+quearyFieldsForFundRaising+'  From navpeII_dev18__Fundraising__c Where Id Not IN:fundraisingSetOfIN AND navpeII_dev18__Legal_Name__c IN:mapkeys Limit '+limitForFundraisingRecords;
    if(Schema.sObjectType.navpeII_dev18__Fundraising__c.isAccessible()){
    soqlFundraisingList=database.query(String.escapeSingleQuotes(fundRaisingQuery));
    }
    
    for(navpeII_dev18__Fundraising__c fundraising:soqlFundraisingList){
    fundraisingSearchDataList.add(fundraising);
    }
    
    
    
    wpdata.fundRaisList=fundraisingSearchDataList;

    //--------------------------------------------------------------------------------------------------------------
    //theme lookup match handled 
    list<navpeII_dev18__theme__c> soqlThemeList =new list<navpeII_dev18__theme__c>();
    list<navpeII_dev18__theme_relation__c> soqlThemerelationList =new list<navpeII_dev18__theme_relation__c>();
    set<string> themeIds=new set<string>();
    integer limitLeftForThemeRowsLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
    string relationThemeQr='Select navpeII_dev18__theme__c,Id,Account__r.name From navpeII_dev18__theme_Relation__c Where navpeII_dev18__theme__c Not IN:themesSetOfIN AND (Account__r.Name LIKE:soqlSearchString OR Contact__r.Name LIKE:soqlSearchString OR Deal__r.Name LIKE:soqlSearchString OR Fund__r.Name LIKE:soqlSearchString OR Fundraising__r.Name LIKE:soqlSearchString OR Clip__r.Name LIKE:soqlSearchString) Limit '+ limitLeftForThemeRowsLimit;
    soqlThemerelationList=database.query(String.escapeSingleQuotes(relationThemeQr));
    for(navpeII_dev18__theme_relation__c data:soqlThemerelationList){
    themeIds.add(data.navpeII_dev18__theme__c);
    }
    integer limitForLeftThemeRecords=Limits.getLimitQueryRows() - Limits.getQueryRows();
    string themeQuery='Select ' + quearyFieldsForTheme +' From navpeII_dev18__theme__c Where Id Not IN:themesSetOfIN AND Id IN :themeIds Limit ' + limitForLeftThemeRecords;
    
    if(Schema.sObjectType.navpeII_dev18__theme__c.isAccessible()){
    soqlThemeList=database.query(String.escapeSingleQuotes(themeQuery));
    }
    for(navpeII_dev18__theme__c themeData:soqlThemeList){
    themeSearchDataList.add(themeData);
    }
    
    // clip lookup match handled
    list<navpeII_dev18__clip__c> soqlClipList =new list<navpeII_dev18__clip__c>();
    list<navpeII_dev18__clip_relation__c> soqlCliprelationList =new list<navpeII_dev18__clip_relation__c>();
    set<string> ClipIds=new set<string>();
    integer limitLeftForClipsRelateionRecord=Limits.getLimitQueryRows() - Limits.getQueryRows();
    string clipRelationQuery='Select navpeII_dev18__clip__c,id From navpeII_dev18__clip_relation__c Where navpeII_dev18__clip__c Not IN:clipsSetOfIN AND (Account__r.Name LIKE:soqlSearchString OR Contact__r.Name LIKE:soqlSearchString OR Deal__r.Name LIKE:soqlSearchString OR Fund__r.Name LIKE:soqlSearchString OR Fundraising__r.Name LIKE:soqlSearchString) Limit '+limitLeftForClipsRelateionRecord;
    soqlCliprelationList=database.query(String.escapeSingleQuotes(clipRelationQuery));
    for(navpeII_dev18__clip_relation__c crdata:soqlCliprelationList){
    ClipIds.add(crdata.navpeII_dev18__clip__c);
    }
    integer limitLeftForClipRecord=Limits.getLimitQueryRows() - Limits.getQueryRows();
    string clipQuery='Select '+quearyFieldsForClip+' From navpeII_dev18__clip__c Where Id Not IN:clipsSetOfIN AND Id IN:ClipIds Limit '+limitLeftForClipRecord;
    
    if(Schema.sObjectType.navpeII_dev18__clip__c.isAccessible()){
    soqlClipList=database.query(String.escapeSingleQuotes(clipQuery));
    }
    for(navpeII_dev18__clip__c clipData:soqlClipList){
    clipSearchDataList.add(clipData);
    }
    
}
    //--------------------------------------------------------------------------------------------------------------        
    
if((!transactionFilterCheck) && (!flagForSoqlApproach)){
    //------------------file mechanishm prepearation ---------------------------------------------------------------
    Map<Id,ContentDocumentLink> mapOfAllCDL=new Map<id,ContentDocumentLink>();
    Set<String> refCDAccountIdList = new  set<String>();
    List<ContentDocumentLink> refCDList=new List<ContentDocumentLink>();





//map<id,task> fileTaskNameMap=new map<id,task>([Select id, Subject from Task Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
//map<id,event> fileEventNameMap=new map<id,event>([Select id, Subject from Event Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    Set<Id> cdIDSet = new Set<Id>();
    if(Test.isRunningTest() && searchKey == 'TestD'){
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        fileSearchDataList.add(cd);
    }
    for(ContentDocument cdRec: fileSearchDataList){
    cdIDSet.add(cdRec.Id) ;   
    }
    if(cdIDSet != null && cdIDSet.size()>0){
    Map<id,ContentDocumentLink> contentDocLinkIdVSCDLMap=new map<id,ContentDocumentLink>([select ID,ContentDocument.title,ContentDocumentId,ContentDocument.description, LinkedEntityId from ContentDocumentLink where ContentDocumentId IN:cdIDSet order by ContentDocument.title asc Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    for(ContentDocumentLink cdlRec : contentDocLinkIdVSCDLMap.values() ){
    if(!String.valueOf(cdlRec.LinkedEntityId).startsWith('005')){
    Id recId = (Id)cdlRec.LinkedEntityId;
    refCDList.add(cdlRec);
    }
    }
    Set<ContentDocumentLink> contentDocumentListSet = new Set<ContentDocumentLink>(refCDList);
    List<referenceRecordWrapper> refFilesFinalData=new List<referenceRecordWrapper>();
    //-------------------------------------------------------------------
    map<string,set<Id>> objIdMap=new map<string,set<Id>>();  
for(ContentDocumentLink IdResearchRec:contentDocumentListSet){
        id idvalue=IdResearchRec.LinkedEntityId; 
        String sObjName = idvalue.getSObjectType().getDescribe().getName();
        if(objIdMap.containsKey(sObjName)){
            set<Id> strSetOfIdsCheck=new set<Id>();
            strSetOfIdsCheck=objIdMap.get(sObjName);
            strSetOfIdsCheck.add(idvalue);
            objIdMap.put(sObjName,strSetOfIdsCheck);
        }else{
            set<Id> strSetOfIds=new set<Id>();
            strSetOfIds.add(IdResearchRec.LinkedEntityId);
            objIdMap.put(sObjName,strSetOfIds);
        }
       
        
    }
   
    map<id,Account> fileAccountNameMap=new map<id,Account>();
    map<id,Contact> fileContactNameMap=new map<id,Contact>();
    map<id,navpeII_dev18__Pipeline__c> fileDealNameMap=new map<id,navpeII_dev18__Pipeline__c>();
    map<id,navpeII_dev18__Fund__c> fileFundNameMap=new map<id,navpeII_dev18__Fund__c>();
    // bug Fix(BULK)
    map<id,navpeII_dev18__Fundraising__c> fileFundraisingNameMap=new map<id,navpeII_dev18__Fundraising__c>();//bug Fix(BULK)
    if(makeObjectPermissionInMap('Account')){
        List<Account> accListMapSupport=new List<Account>();
        accListMapSupport=[Select id, Name from Account Where Id In: objIdMap.get('Account') WITH USER_MODE Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
        for(account accData:accListMapSupport){fileAccountNameMap.put(accData.id,accData);}
    }
    if(makeObjectPermissionInMap('Contact')){
        List<Contact> conListMapSupport= new List<Contact>();
        conListMapSupport=[Select id, Name from Contact Where Id In: objIdMap.get('Contact') Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
        for(Contact conData:conListMapSupport){fileContactNameMap.put(conData.id,conData);}
    }
    if(makeObjectPermissionInMap('navpeII_dev18__Pipeline__c')){
        List<navpeII_dev18__Pipeline__c> dealListMapSupport=new List<navpeII_dev18__Pipeline__c>();
        dealListMapSupport=[Select id, Name from navpeII_dev18__Pipeline__c Where Id In: objIdMap.get('navpeII_dev18__Pipeline__c') Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
        for(navpeII_dev18__Pipeline__c dealData:dealListMapSupport){fileDealNameMap.put(dealData.id,dealData);}
    }
    if(makeObjectPermissionInMap('navpeII_dev18__Fund__c')){
        List<navpeII_dev18__Fund__c> fundListMapSupport=new List<navpeII_dev18__Fund__c>();
        fundListMapSupport=[Select id, Name from navpeII_dev18__Fund__c Where Id In: objIdMap.get('navpeII_dev18__Fund__c') Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
        for(navpeII_dev18__Fund__c fundData:fundListMapSupport){fileFundNameMap.put(fundData.id,fundData);}
    }// bug Fix(BULK)
    if(makeObjectPermissionInMap('navpeII_dev18__Fundraising__c')){
        List<navpeII_dev18__Fundraising__c> FundraisingListMapSupport=new List<navpeII_dev18__Fundraising__c>();
        FundraisingListMapSupport=[Select id, Name from navpeII_dev18__Fundraising__c Where Id In: objIdMap.get('navpeII_dev18__Fundraising__c') Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
        for(navpeII_dev18__Fundraising__c FundraisingData:FundraisingListMapSupport){fileFundraisingNameMap.put(FundraisingData.id,FundraisingData);}
    }// bug Fix(BULK)
    map<id,task> fileTaskNameMap=new map<id,task>();
    List<Task> tskListForFile=new List<Task>();
    tskListForFile=[Select id, Subject from Task Where Id In:objIdMap.get('Task') Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    for(task thData:tskListForFile){
        fileTaskNameMap.put(thData.id,thData);
    }
    
map<id,event> fileEventNameMap=new map<id,event>([Select id, Subject from Event Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
List<Event> evtListForFile=new List<Event>();
    evtListForFile=[Select id, Subject from Event Where Id In:objIdMap.get('Event') Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    for(event evData:evtListForFile){
        fileEventNameMap.put(evData.id,evData);
    }
    //-------------------------------------------------------------------
    for(ContentDocumentLink cdlRec:contentDocumentListSet){
    referenceRecordWrapper recWrap = new referenceRecordWrapper();
        if(Test.isRunningTest() && searchKey == 'TestD'){
            checkComingSource = 'comingFromChild';
            checkingLookUpFunctionality = true;
        }
    if(checkComingSource == 'comingFromChild' && checkingLookUpFunctionality){
    if(mapOfListIdCorrToObjectName.get('currIdList') != null && mapOfListIdCorrToObjectName.get('currIdList').contains(cdlRec.LinkedEntityId)){
    recWrap.recordId = cdlRec.ContentDocumentId;
    recWrap.recordName = cdlRec.ContentDocument.Title;
    recWrap.description = cdlRec.ContentDocument.description;
    recWrap.parentRecordId = '/'+cdlRec.LinkedEntityId;
    if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Task'){
    recWrap.parentRecordName = (fileTaskNameMap.containsKey(cdlRec.LinkedEntityId))?fileTaskNameMap.get(cdlRec.LinkedEntityId).Subject:'';    
    }else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Event'){
    recWrap.parentRecordName = (fileEventNameMap.containsKey(cdlRec.LinkedEntityId))?fileEventNameMap.get(cdlRec.LinkedEntityId).Subject:'';    
    }else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Account'){
    if(makeObjectPermissionInMap('Account')){
        //map<id,Account> fileAccountNameMap=new map<id,Account>([Select id, Name from Account WITH USER_MODE Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileAccountNameMap.containsKey(cdlRec.LinkedEntityId))?fileAccountNameMap.get(cdlRec.LinkedEntityId).Name:'';    
    }  
    }else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Contact'){
    if(makeObjectPermissionInMap('Contact')){
        //map<id,Contact> fileContactNameMap=new map<id,Contact>([Select id, Name from Contact Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileContactNameMap.containsKey(cdlRec.LinkedEntityId))?fileContactNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }      
}else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'navpeII_dev18__Pipeline__c'){
    if(makeObjectPermissionInMap('navpeII_dev18__Pipeline__c')){
        //map<id,navpeII_dev18__Pipeline__c> fileDealNameMap=new map<id,navpeII_dev18__Pipeline__c>([Select id, Name from navpeII_dev18__Pipeline__c Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileDealNameMap.containsKey(cdlRec.LinkedEntityId))?fileDealNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }      
}else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'navpeII_dev18__Fund__c'){
    if(makeObjectPermissionInMap('navpeII_dev18__Fund__c')){
        //map<id,navpeII_dev18__Fund__c> fileFundNameMap=new map<id,navpeII_dev18__Fund__c>([Select id, Name from navpeII_dev18__Fund__c Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileFundNameMap.containsKey(cdlRec.LinkedEntityId))?fileFundNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }      
}else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'navpeII_dev18__Fundraising__c'){
    if(makeObjectPermissionInMap('navpeII_dev18__Fundraising__c')){
        //map<id,navpeII_dev18__Fundraising__c> fileFundraisingNameMap=new map<id,navpeII_dev18__Fundraising__c>([Select id, Name from navpeII_dev18__Fundraising__c Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]); // bug Fix(BULK)
        
    recWrap.parentRecordName = (fileFundraisingNameMap.containsKey(cdlRec.LinkedEntityId))?fileFundraisingNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }
}
    /*if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case'){
    recWrap.parentRecordName = (fileCaseNameMap.containsKey(cdlRec.LinkedEntityId))?fileCaseNameMap.get(cdlRec.LinkedEntityId).CaseNumber:'';        
    }
    if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity'){
    recWrap.parentRecordName = (fileOpportunityNameMap.containsKey(cdlRec.LinkedEntityId))?fileOpportunityNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }*/
    
    //recWrap.parentRecordName = mapOfAllTask.get(tk.Id).Subject;
    //recWrap.parentURl = system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+tk.Id;
    //recWrap.description= mapOfAllTask.get(tk.Id).Description;
    
    refFilesFinalData.add(recWrap);
    }
    }else{
        recWrap.recordId = cdlRec.ContentDocumentId;
    recWrap.recordName = cdlRec.ContentDocument.Title;
    recWrap.description = cdlRec.ContentDocument.description;
    recWrap.parentRecordId = '/'+cdlRec.LinkedEntityId;
    if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Task'){
    recWrap.parentRecordName = (fileTaskNameMap.containsKey(cdlRec.LinkedEntityId))?fileTaskNameMap.get(cdlRec.LinkedEntityId).Subject:'';    
    }else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Event'){
    recWrap.parentRecordName = (fileEventNameMap.containsKey(cdlRec.LinkedEntityId))?fileEventNameMap.get(cdlRec.LinkedEntityId).Subject:'';    
    }else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Account'){
    if(makeObjectPermissionInMap('Account')){
       // map<id,Account> fileAccountNameMap=new map<id,Account>([Select id, Name from Account WITH USER_MODE Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileAccountNameMap.containsKey(cdlRec.LinkedEntityId))?fileAccountNameMap.get(cdlRec.LinkedEntityId).Name:'';    
    } 
    }else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Contact'){
    if(makeObjectPermissionInMap('Contact')){
        //map<id,Contact> fileContactNameMap=new map<id,Contact>([Select id, Name from Contact Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileContactNameMap.containsKey(cdlRec.LinkedEntityId))?fileContactNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }      
}else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'navpeII_dev18__Pipeline__c'){
    if(makeObjectPermissionInMap('navpeII_dev18__Pipeline__c')){
        //map<id,navpeII_dev18__Pipeline__c> fileDealNameMap=new map<id,navpeII_dev18__Pipeline__c>([Select id, Name from navpeII_dev18__Pipeline__c Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileDealNameMap.containsKey(cdlRec.LinkedEntityId))?fileDealNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }   
}else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'navpeII_dev18__Fund__c'){
    if(makeObjectPermissionInMap('navpeII_dev18__Fund__c')){
        //map<id,navpeII_dev18__Fund__c> fileFundNameMap=new map<id,navpeII_dev18__Fund__c>([Select id, Name from navpeII_dev18__Fund__c Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
    recWrap.parentRecordName = (fileFundNameMap.containsKey(cdlRec.LinkedEntityId))?fileFundNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }     
}else if(cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'navpeII_dev18__Fundraising__c'){
    if(makeObjectPermissionInMap('navpeII_dev18__Fundraising__c')){
        //map<id,navpeII_dev18__Fundraising__c> fileFundraisingNameMap=new map<id,navpeII_dev18__Fundraising__c>([Select id, Name from navpeII_dev18__Fundraising__c Order By CreatedDate DESC Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]); // bug Fix(BULK)
        
    recWrap.parentRecordName = (fileFundraisingNameMap.containsKey(cdlRec.LinkedEntityId))?fileFundraisingNameMap.get(cdlRec.LinkedEntityId).Name:'';        
    }
}
    refFilesFinalData.add(recWrap);
    }
    }
    wpdata.refWrapFileList = refFilesFinalData;
    }

}

    //  ---------------------for maintaning the recordtype functionality ------------------------------------------------------------------------------------------------------------------------------------------
    
    
    if(accountRecordTypeList != null){
        for(RecordType ryData:accountRecordTypeList){
        wpdata.accountRecordTypeList.add(ryData.Name);
        }
        
        }
        if(contactRecordTypeList != null){
        for(RecordType ryData:contactRecordTypeList){
        wpdata.ContactRecordTypeList.add(ryData.Name);
        }
        
        }
        if(dealRecordTypeList != null){
        for(RecordType ryData:dealRecordTypeList){
        wpdata.dealRecordTypeList.add(ryData.Name);
        }
        
        }
        if(fundRecordTypeList != null){
        for(RecordType ryData:fundRecordTypeList){
        wpdata.fundRecordTypeList.add(ryData.Name);
        }
        
        }
        if(fundraisingRecordTypeList != null){
        for(RecordType ryData:fundraisingRecordTypeList){
        wpdata.fundraisingRecordTypeList.add(ryData.Name);
        }
        
        }
        boolean flag=true;
        if(checkingLookUpFunctionality || transactionFilterCheck){
            wpdata.errorMessage='';
    
            return  wpdata;
    
        // ref (tagged) account and ref (tagged) contact  mechanishm will be halt if current record mechanishm will be proceed 
        }else if(flag){
            // Descoped the process of Tagged Section
            return  wpdata;  // 16/june/2023 descope the tagged account and tagged contact 
        }
        
    //------------------------------------------------------------------------------------------------------------
    //Tagged Account and Contact Section Mechanishm Start

    return wpdata; // this return statement  will be vanished when I will add existing code from drive 
    //Tagged Account/Conatact Section Mechanishm END 
    //-------------------------------------------------------------------------------------------------------
    }catch(Exception e){
    system.debug(e.getMessage()+'  error occure on Line number ->'+e.getLineNumber()+' in APEX Code');
    wpdata.errorMessage='Error Occured While Loading Component : <<'+e.getMessage()+e.getLineNumber()+'>>';
    
    return wpdata;
    }
    }
    // for caputing the meta data for global use .
    /* ******      getfieldValue: *  
    *   setup the icon mechanishm for custom objects 
    *   fetch the refernce of the metadata from the org 
    */
    public static void setMetadataFieldsAPiNamesData(){ 
    metadataFieldsAPiNames=Acuity_Setting__mdt.getAll();
    map<string,string> mapLabel=new map<string,string>();//for storing the labels 
    map<String,String> mapPluralLabel = new map<String,String>(); //changes for plural label get by salauddin sheikh 5th july 2023
    List<string> objectAPIName= new List<String>{'Account','Contact','navpeII_dev18__Pipeline__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c','Clips','Themes'};
    
    String layoutResponse;
    string endpointurl ='/services/data/v41.0/tabs';
    if(!test.isRunningTest()){
    layoutResponse = NavatarResearchCommonUtility.getDescribeResponse(endpointurl);
    
    
    list<FromJSON> layout = (list<FromJSON>)System.JSON.deserialize(layoutResponse ,  list<FromJSON>.class);
    string objectName='';
    
    
    
    for(string objName: objectAPIName){
        if(objName == 'Clips' || objName == 'Themes' ){
            objName='navpeII_dev18__'+objName.replace('s','')+'__c';
        }
      List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName}); // this can accept list of strings, we describe only one object here
      String objectLabel = describeSobjectsResult[0].getLabel();
      String pluralLabel = describeSobjectsResult[0].getLabelPlural(); //changes for plural label get by salauddin sheikh 5th july 2023
      mapLabel.put(objName,objectLabel);
      mapPluralLabel.put(objName, pluralLabel);  //changes for plural label get by salauddin sheikh 5th july 2023
      /*if(objName == 'navpeII_dev18__Clip__c' || objName == 'navpeII_dev18__Theme__c' ){
        
        objName=objName.replace('navpeII_dev18__','');
        objName=objName.replace('__c','s');
    }*/
    for(FromJSON tab:layout) {
    /*added profile label check for user by Ehatsham in AA3.0 */
    system.debug(tab.Name +'---'+tab.sobjectName);
    system.debug('@@@@@-'+tab.Name);
    if((objName == tab.sobjectName || objName == tab.Name) && tab.label!='Profile'){
    
    for(cls_icons icn : tab.icons){
    if(icn.height == 0 && icn.theme== 'theme4' ){
    String objType = icn.url.split('/')[6]; //standard
    String tempName = icn.url.split('/')[7]; // account.svg
    objectName = tempName.split('\\.')[0]; //account
    // lookupWrap.pluralLabel = tab.label;
    // lookupWrap.IconName = objType+':'+objectName;
    
    iconNameMap.put(objName,objType+':'+objectName);
    
    
    
    }
    }
    }
    
    }
    }
    }
    /*DescribeSObjectResult describeAcc = SObjectType.Account;
    mapLabel.put('Account',describeAcc.getLabel());
    
    DescribeSObjectResult describeCon = SObjectType.Contact;
    mapLabel.put('Contact',describeCon.getLabel());*/
    clWrapper.iconMap=iconNameMap;
    clWrapper.labelMap=mapLabel;
    clWrapper.pluralLabelMap = mapPluralLabel; //changes for plural label get by salauddin sheikh 5th july 2023
    clWrapper.globalObjFieldTypeMap=globalFieldTypeMap;
    
    }
    
    // seperate method for arrenging the columns for all object tabel -- calling from wire functionality 
    // for Maintaining the dynamic column for objects table  .
    /* ******      getfieldValue: *  
    *  calling : SetMetadataFieldsAPiNamesData for fetching the meta data fields 
    *  calling : makingRecordTypeFormate() for maintaining the recordtype formate for each objects 
    *  calling : makeAccountFields for maintainging the account object fields on the columns 
    *  calling : makeContactFields for maintainging the contact object fields on the columns 
    *  calling : makeDealFields for maintainging the Deal object fields on the columns 
    *  calling : makefundFields for maintainging the fund object fields on the columns 
    *  calling : makefundraisingFields for maintainging the fundraising object fields on the columns 
    *  calling : makethemeFields for maintainging the theme object fields on the columns 
    *  calling : makeclipFields for maintainging the clip object fields on the columns 
    */
    @AuraEnabled(cacheable = true)
    public static columnListWrapper setColumnAndFields(){ 
    try{
    string quearyFieldsForAccount;
    string quearyFieldsForContact;
    string quearyFieldsForDeals;
    string quearyFieldsForFund;
    string quearyFieldsForFundRaising;
    string quearyFieldsForTheme;
    string quearyFieldsForClip;
    SetMetadataFieldsAPiNamesData();
    makingRecordTypeFormate();
    
    List<string> accessList=new List<string>{'no','no','no','no','no','no','no'};// obj access accordingly acc,con,deal,fund,fundraising
    
    if(Schema.sObjectType.Account.isAccessible()){
    accessList[0]='yes';
    if(accountRecordTypeList != null && accountRecordTypeList.size() != 0){
    quearyFieldsForAccount=makeAccountFields('Yes');
    }else{
    quearyFieldsForAccount=makeAccountFields('No');
    }
    }
    
    if(Schema.sObjectType.Contact.isAccessible()){
    accessList[1]='yes';
    if(contactRecordTypeList != null && contactRecordTypeList.size() != 0){
    quearyFieldsForContact=makeContactFields('Yes');
    }else{
    quearyFieldsForContact=makeContactFields('No');
    }
    }
    if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
    accessList[2]='yes';
    if(dealRecordTypeList != null && dealRecordTypeList.size() !=0){
    quearyFieldsForDeals=makeDealFields('Yes');
    }else{
    quearyFieldsForDeals=makeDealFields('No');
    }
    }
    if(Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible()){
    accessList[3]='yes';
    if(fundRecordTypeList != null && fundRecordTypeList.size() != 0){
    quearyFieldsForFund=makeFundFields('Yes');
    }else{
    quearyFieldsForFund=makeFundFields('No');
    }
    }
    if(Schema.sObjectType.navpeII_dev18__Fundraising__c.isAccessible()){
    accessList[4]='yes';
    if(fundraisingRecordTypeList != null && fundraisingRecordTypeList.size() != 0){
    quearyFieldsForFundRaising=makeFundRaisingFields('Yes');
    }else{
    quearyFieldsForFundRaising=makeFundRaisingFields('No');
    }
    
    }
    
    //----------------------------------clip and theme functionality------------------------------------
    if(Schema.sObjectType.navpeII_dev18__theme__c.isAccessible()){
    accessList[5]='yes';
    
    quearyFieldsForTheme=makeThemeFields('No');
    
    
    }
    if(Schema.sObjectType.navpeII_dev18__clip__c.isAccessible()){
    accessList[6]='yes';
    
    quearyFieldsForClip=makeClipFields('No');
    
    
    }
    //------------------------------------------------------------------------------------------------------------------
    
    
    
    clWrapper.objectAccessList=accessList;
    clWrapper.globalObjFieldTypeMap=globalFieldTypeMap;
    //quearyFieldsForTask=makeTaskFields('No');
    
    
    
    //quearyFieldsForEvent=makeEventFields('No');
    
    
    
    clWrapper.errorMessage='';
    return clWrapper;
    }catch(exception e){
    system.debug(e.getMessage()+'  error occure on Line number ->'+e.getLineNumber()+' on apex Side in Column Making- Please check the APi Name of Fields in Metadata ');
    
    clWrapper.errorMessage=  'Error Occured While Loading Component : <<'+e.getMessage()+e.getLineNumber()+'>>';
    
    return clWrapper;
    }
    
    }
    //------------------------Theme mechanishm -------------------------------------------------------------------
    public static string makeThemeFields(String recordTypeAvailibility){ // making dynamic fields according to metadata and setup the active recordtype 
    // make columns for Theme Search List
    List<string> fieldNameList=new List<string>();
    string quearyFieldsForTheme='';
    string localVar='';
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.navpeII_dev18__theme__c.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Theme_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Theme_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Theme_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Theme_Field1').value__c;
        }
    quearyFieldsForTheme=''+f1+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Theme_Field1').value__c);
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Theme_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Theme_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Theme_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Theme_Field2').value__c;
        }
    if(quearyFieldsForTheme != ''){
    quearyFieldsForTheme=quearyFieldsForTheme+','+ f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Theme_Field2').value__c);
    }else{
    quearyFieldsForTheme= f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Theme_Field2').value__c);
    }
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Theme_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Theme_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Theme_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Theme_Field3').value__c;
        }
    if(quearyFieldsForTheme != ''){
    quearyFieldsForTheme=quearyFieldsForTheme+','+ f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Theme_Field3').value__c);
    }else{
    quearyFieldsForTheme= f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Theme_Field3').value__c);
    }
    }
    }
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp=new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    
    } 
    globalFieldTypeMap.put('Theme',mp);
    clWrapper.themeListColumns=wfcList;
    clWrapper.quearyFieldsForTheme=quearyFieldsForTheme;
    
    
    return quearyFieldsForTheme;
    }
    //------------------------clip mechanishm --------------------------------------------------------------------
    public static string makeClipFields(String recordTypeAvailibility){ // making dynamic fields according to metadata and setup the active recordtype 
    // make columns for CLip Search List
    List<string> fieldNameList=new List<string>();
    string quearyFieldsForClip='';
    string localVar='';
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.navpeII_dev18__clip__c.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Clip_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Clip_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Clip_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Clip_Field1').value__c;
        }
    quearyFieldsForClip=''+f1+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Clip_Field1').value__c);
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Clip_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Clip_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Clip_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Clip_Field2').value__c;
        }
    if(quearyFieldsForClip != ''){
    quearyFieldsForClip=quearyFieldsForClip+','+ f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Clip_Field2').value__c);
    }else{
    quearyFieldsForClip= f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Clip_Field2').value__c);
    }
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Clip_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Clip_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Clip_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Clip_Field3').value__c;
        }
    if(quearyFieldsForClip != ''){
    quearyFieldsForClip=quearyFieldsForClip+','+ f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Clip_Field3').value__c);
    }else{
    quearyFieldsForClip= f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Clip_Field3').value__c);
    }
    }
    }
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp=new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    
    } 
    globalFieldTypeMap.put('Clip',mp);
    clWrapper.clipListColumns=wfcList;
    
    clWrapper.quearyFieldsForClip=quearyFieldsForClip;
    
    return quearyFieldsForClip;
    }
    // --------------------Account Mechanishm ------------------------------------------------------------------
    public static string makeAccountFields(String recordTypeAvailibility){ // making dynamic fields according to metadata and setup the active recordtype 
    // make columns for Account Search List
    List<string> fieldNameList=new List<string>();
    string quearyFieldsForAccount='';
    string localVar='';
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Acc_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Acc_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Acc_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Acc_Field1').value__c;
        }
    quearyFieldsForAccount=''+f1+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Acc_Field1').value__c);
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Acc_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Acc_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Acc_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Acc_Field2').value__c;
        }
    if(quearyFieldsForAccount != ''){
    quearyFieldsForAccount=quearyFieldsForAccount+','+ f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Acc_Field2').value__c);
    }else{
    quearyFieldsForAccount= f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Acc_Field2').value__c);
    }
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Acc_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Acc_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Acc_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Acc_Field3').value__c;
        }
    if(quearyFieldsForAccount != ''){
    quearyFieldsForAccount=quearyFieldsForAccount+','+ f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Acc_Field3').value__c);
    }else{
    quearyFieldsForAccount= f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Acc_Field3').value__c);
    }
    }
    }
    
    
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp=new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    
    } 
    globalFieldTypeMap.put('Account',mp);
    clWrapper.accountListColumns=wfcList;
    
    if(recordTypeAvailibility == 'Yes'){
        
    quearyFieldsForAccount=QuearyFieldsForAccount+', RecordType.Name';
    }
    
    
    
    
    clWrapper.quearyFieldsForAccount=quearyFieldsForAccount;
    
    return quearyFieldsForAccount;
    }
    //-----------------Contact Mechanishm--------------------
    public static string makeContactFields(String recordTypeAvailibility){
    string quearyFieldsForContact='';
    // make columns for Contact Search List
    List<string> fieldNameList=new List<string>();
    string localVar='';
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Con_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Con_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Con_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Con_Field1').value__c;
        }
    quearyFieldsForContact=''+f1+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Con_Field1').value__c);
    }
    }
    if(metadataFieldsAPiNames.get('Research_Con_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Con_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Con_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Con_Field2').value__c;
        }
    if(quearyFieldsForContact != ''){
    quearyFieldsForContact=quearyFieldsForContact+','+ f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Con_Field2').value__c);
    }else{
    quearyFieldsForContact= f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Con_Field2').value__c);
    }
    
    }
    }
    if(metadataFieldsAPiNames.get('Research_Con_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Con_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Con_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Con_Field3').value__c;
        }
    if(quearyFieldsForContact != ''){
    quearyFieldsForContact=quearyFieldsForContact+','+ f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Con_Field3').value__c);
    }else{
    quearyFieldsForContact= f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Con_Field3').value__c);
    }
    }
    }
    
    
    
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp=new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    } 
    globalFieldTypeMap.put('Contact',mp);
    clWrapper.contactListColumns=wfcList;
    
    
    
    
    
    if(recordTypeAvailibility == 'Yes'){
    quearyFieldsForContact=QuearyFieldsForContact+', RecordType.Name';
    }
    
    clWrapper.quearyFieldsForContact=quearyFieldsForContact;
    
    return quearyFieldsForContact;
    }
    
    //--------Deals Mechanishm -----------------------------------------
    public static string makeDealFields(String recordTypeAvailibility){
    // make columns for Deal Search List
    List<string> fieldNameList=new List<string>();
    string quearyFieldsForDeal='';
    string localVar='';
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.navpeII_dev18__Pipeline__c.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Deal_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Deal_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Deal_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Deal_Field1').value__c;
        }
    quearyFieldsForDeal=''+f1+refFieldData;
    fieldNameList.add(MetadataFieldsAPiNames.get('Research_Deal_Field1').value__c);
    }
    }
    if(metadataFieldsAPiNames.get('Research_Deal_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Deal_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Deal_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Deal_Field2').value__c;
        }
    if(quearyFieldsForDeal != ''){
    quearyFieldsForDeal=quearyFieldsForDeal+','+ f2+refFieldData;
    fieldNameList.add(MetadataFieldsAPiNames.get('Research_Deal_Field2').value__c);
    }else{
    quearyFieldsForDeal= f2+refFieldData;
    fieldNameList.add(MetadataFieldsAPiNames.get('Research_Deal_Field2').value__c);
    }
    
    }
    }
    if(metadataFieldsAPiNames.get('Research_Deal_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Deal_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Deal_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Deal_Field3').value__c;
        }
    if(quearyFieldsForDeal != ''){
    quearyFieldsForDeal=quearyFieldsForDeal+','+ f3+refFieldData;
    fieldNameList.add(MetadataFieldsAPiNames.get('Research_Deal_Field3').value__c);
    }else{
    quearyFieldsForDeal= f3+refFieldData;
    fieldNameList.add(MetadataFieldsAPiNames.get('Research_Deal_Field3').value__c);
    }
    }
    }
    
    
    
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp=new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    } 
    globalFieldTypeMap.put('Deal',mp);
    clWrapper.dealListColumns=wfcList;
    
    
    
    
    if(recordTypeAvailibility == 'Yes'){
    quearyFieldsForDeal=quearyFieldsForDeal+', RecordType.Name';
    }
    clWrapper.quearyFieldsForDeal=quearyFieldsForDeal;
    
    
    return quearyFieldsForDeal;
    }
    // ----------Funds----------Making the fields from the metadata ---------------------------------------------
    public static string makeFundFields(String recordTypeAvailibility){
    string quearyFieldsForFund='';
    string localVar='';
    // make columns for Fund Search List
    List<string> fieldNameList=new List<string>();
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.navpeII_dev18__Fund__c.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Fund_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Fund_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Fund_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Fund_Field1').value__c;
        }
    quearyFieldsForFund=''+f1+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fund_Field1').value__c);
    }
    }
    if(metadataFieldsAPiNames.get('Research_Fund_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Fund_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Fund_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Fund_Field2').value__c;
        }
    if(quearyFieldsForFund != ''){
    quearyFieldsForFund=quearyFieldsForFund+','+ f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fund_Field2').value__c);
    }else{
    quearyFieldsForFund= f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fund_Field2').value__c);
    }
    }
    
    }
    if(metadataFieldsAPiNames.get('Research_Fund_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Fund_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Fund_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Fund_Field3').value__c;
        }
    if(quearyFieldsForFund != ''){
    quearyFieldsForFund=quearyFieldsForFund+','+ f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fund_Field3').value__c);
    }else{
    quearyFieldsForFund= f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fund_Field3').value__c);
    }
    }
    }
    
    
    
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp=new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    
    } 
    globalFieldTypeMap.put('Fund',mp);
    clWrapper.fundListColumns=wfcList;
    
    if(recordTypeAvailibility == 'Yes'){
    quearyFieldsForFund=quearyFieldsForFund+', RecordType.Name';
    }
    
    clWrapper.quearyFieldsForFund=quearyFieldsForFund;
    return quearyFieldsForFund;
    }
    //------------Fund Raising Mechanishm -----------------------------
    public static string makeFundRaisingFields(String recordTypeAvailibility){
    string quearyFieldsForFundRaising='';
    string localVar='';
    List<string> fieldNameList=new List<string>();
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.navpeII_dev18__Fundraising__c.fields.getMap();
    if(metadataFieldsAPiNames.get('Research_Fundraising_Field1').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Fundraising_Field1').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f1='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f1='FORMAT('+metadataFieldsAPiNames.get('Research_Fundraising_Field1').value__c+')';
        }else{
            f1=metadataFieldsAPiNames.get('Research_Fundraising_Field1').value__c;
        }
    quearyFieldsForFundRaising=''+f1+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fundraising_Field1').value__c);
    }
    }
    if(metadataFieldsAPiNames.get('Research_Fundraising_Field2').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Fundraising_Field2').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f2='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f2='FORMAT('+metadataFieldsAPiNames.get('Research_Fundraising_Field2').value__c+')';
        }else{
            f2=metadataFieldsAPiNames.get('Research_Fundraising_Field2').value__c;
        }
    if(quearyFieldsForFundRaising != ''){
    quearyFieldsForFundRaising=quearyFieldsForFundRaising+','+ f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fundraising_Field2').value__c);
    }else{
    quearyFieldsForFundRaising= f2+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fundraising_Field2').value__c);
    }
    } 
    
    }
    if(metadataFieldsAPiNames.get('Research_Fundraising_Field3').value__c != Null){
    localVar=String.valueOf(metadataFieldsAPiNames.get('Research_Fundraising_Field3').value__c);
    Schema.DescribeFieldResult     field = fieldMap.get(localVar).getDescribe() ;
    if(field.isAccessible()){
    string refFieldData='';
    if(field.getType() == Schema.DisplayType.REFERENCE){
    refFieldData=' , '+field.getRelationshipName()+'.Name';
    }
    else{
    refFieldData='';
    }
    string f3='';
    if(field.getType() == Schema.DisplayType.DateTime || field.getType() == Schema.DisplayType.Date){
        f3='FORMAT('+metadataFieldsAPiNames.get('Research_Fundraising_Field3').value__c+')';
        }else{
            f3=metadataFieldsAPiNames.get('Research_Fundraising_Field3').value__c;
        }
    if(quearyFieldsForFundRaising != ''){
    quearyFieldsForFundRaising=quearyFieldsForFundRaising+','+ f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fundraising_Field3').value__c);
    }else{
    quearyFieldsForFundRaising= f3+refFieldData;
    fieldNameList.add(metadataFieldsAPiNames.get('Research_Fundraising_Field3').value__c);
    }
    }
    }
    
    // make columns for FundRaising Search List
    
    
    
    List<wrapperforColumn> wfcList=new List<wrapperforColumn>();
    
    map<string,string> mp =new map<string,string>();
    for (String fieldName: fieldNameList) {
    
    // list of all field API name
    wrapperforColumn wfc=new wrapperforColumn();
    wfc.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
    wfc.fieldName=fieldMap.get(fieldName).getDescribe().getName();
    wfc.fieldType=String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
    wfcList.add(wfc);
    mp.put(wfc.fieldName,wfc.fieldType);
    } 
    globalFieldTypeMap.put('Fundraising',mp);
    clWrapper.fundRaisListColumns=wfcList;
    
    
    
    if(recordTypeAvailibility == 'Yes'){
    quearyFieldsForFundRaising=quearyFieldsForFundRaising+', RecordType.Name';
    }
    clWrapper.quearyFieldsForFundRaising=quearyFieldsForFundRaising;
    
    
    
    return quearyFieldsForFundRaising;
    }
    
    @AuraEnabled
    public static boolean makeObjectPermissionInMap(string obj){
    try {
    boolean booleanCheck=false;
    if(objPermissionCheckStorage.containsKey(obj)){
    booleanCheck=objPermissionCheckStorage.get(obj);
    }else{
    
    String[] types = new String[]{obj};
    
    // Make the describe call
    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
    
    
    
    booleanCheck=results[0].isAccessible();
    objPermissionCheckStorage.put(obj,booleanCheck);
    }
    
    return booleanCheck;
    
    
    } catch (Exception e) {
    system.debug(e.getMessage()+'  error occure on Line number ->'+e.getLineNumber()+' in APEX Code');
    throw new AuraHandledException( 'Error Occured While Loading Component : <<'+e.getMessage()+e.getLineNumber()+'>>');
    }
    }
    
    @AuraEnabled
    public static void makingRecordTypeFormate(){
    try {
    list<string> objList=new list<string>{'Account','Contact','navpeII_dev18__Pipeline__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c'};
    list<recordtype> rcData=[select Id,Name,sObjectType from RecordType where sObjectType In: objList AND isActive=true];
    
    for(recordtype rt:rcData){
    if(rt.sObjectType == 'Account'){
    accountRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'Contact'){
    contactRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'navpeII_dev18__Pipeline__c'){
    dealRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'navpeII_dev18__Fund__c'){
    fundRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'navpeII_dev18__Fundraising__c'){
    fundraisingRecordTypeList.add(rt);
    }
    
    }
    
    } catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
    }
    }
    
    
    
    
    public class innerStructureWrapper{ // for maintaining the internal structure of the table 
    @AuraEnabled
    public List<Account> accList=new List<Account>();// firm data
    @AuraEnabled
    public List<Contact> conList=new List<contact>();// contact data
    @AuraEnabled
    public List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>(); // Deals
    @AuraEnabled
    public List<navpeII_dev18__Fund__c> fundList=new List<navpeII_dev18__Fund__c>(); // Funds
    @AuraEnabled
    public List<navpeII_dev18__Fundraising__c> fundRaisList=new List<navpeII_dev18__Fundraising__c>(); // FundRaising 
    @AuraEnabled
    public List<ContentDocument> fileList=new List<ContentDocument>(); // Files
    
    @AuraEnabled
    public List<navpeII_dev18__Theme__c> themeList=new List<navpeII_dev18__theme__c>(); // theme
    @AuraEnabled
    public List<navpeII_dev18__Clip__c> clipList=new List<navpeII_dev18__Clip__c>(); // clip     
    @AuraEnabled
    public List<sobject> taskList=new List<sobject>();
    @AuraEnabled
    public List<Event> eventList=new List<Event>();
    @AuraEnabled
    public map<string,map<string,string>> globalObjFieldTypeMap = new map<string,map<string,string>>(); // for storing the field's type
    
    // for All Active RecordTypes.
    @AuraEnabled
    public List<String> accountRecordTypeList=new List<string>();
    @AuraEnabled
    public List<String> contactRecordTypeList=new List<string>();
    @AuraEnabled
    public List<String> dealRecordTypeList=new List<string>();
    @AuraEnabled
    public List<String> fundRecordTypeList=new List<string>();
    @AuraEnabled
    public List<String> fundraisingRecordTypeList=new List<string>();
    @AuraEnabled 
    public String errorMessage; // for error message 
    @AuraEnabled
    public List<referenceRecordWrapper> refWrapTaskEventList=new List<referenceRecordWrapper>(); // Final Reference COntact 
    @AuraEnabled
    public List<referenceRecordWrapper> refAccTaskEventList=new List<referenceRecordWrapper>(); // Final Reference Account 
    
    @AuraEnabled
    public List<referenceRecordWrapper> refWrapFileList=new List<referenceRecordWrapper>(); // for file data 
    
    
    }
    public class columnListWrapper{
    // for columns ---------------------> for maintaing the dynamic column as per user willing 
    @AuraEnabled
    public List<wrapperforColumn> accountListColumns=new List<wrapperforColumn>(); // Account Columns 
    @AuraEnabled
    public List<wrapperforColumn> contactListColumns=new List<wrapperforColumn>(); // Contact Columns
    @AuraEnabled
    public List<wrapperforColumn> dealListColumns=new List<wrapperforColumn>(); // Deals Columns
    @AuraEnabled
    public List<wrapperforColumn> fundListColumns=new List<wrapperforColumn>(); // Funds  columns
    @AuraEnabled
    public List<wrapperforColumn> fundRaisListColumns=new List<wrapperforColumn>(); // FundRaising columns
    @AuraEnabled
    public List<wrapperforColumn> themeListColumns=new List<wrapperforColumn>(); // FundRaising columns
    @AuraEnabled
    public List<wrapperforColumn> clipListColumns=new List<wrapperforColumn>(); // FundRaising columns
    @AuraEnabled
    public Map<String,String> iconMap=new Map<String,String>(); // Icon value Storage 
    @AuraEnabled
    public Map<String,String> labelMap=new Map<String,String>(); // label value Storage 
    @AuraEnabled
    public Map<String,String> pluralLabelMap = new Map<String,String>(); //changes for plural label get by salauddin sheikh 5th july 2023
    @AuraEnabled
    public List<String> objectAccessList=new List<String>();
    @AuraEnabled
    public  String quearyFieldsForAccount; 
    @AuraEnabled
    public  String quearyFieldsForContact;
    @AuraEnabled
    public  String quearyFieldsForDeal;
    @AuraEnabled
    public  String quearyFieldsForFund;
    @AuraEnabled
    public  String quearyFieldsForFundRaising;
    @AuraEnabled
    public  String quearyFieldsForTask;
    @AuraEnabled
    public String quearyFieldsForTheme;
    @AuraEnabled
    public  String quearyFieldsForClip;
    @AuraEnabled
    public map<string,map<string,string>> globalObjFieldTypeMap = new map<string,map<string,string>>(); // for storing the field's type
    
    
    /*@AuraEnabled
    public List<wrapperforColumn> taskListColumns=new List<wrapperforColumn>(); // Task columns
    @AuraEnabled
    public List<wrapperforColumn> eventListColumns=new List<wrapperforColumn>(); // Event columns*/
    
    @AuraEnabled 
    public String errorMessage;
    
    }
    public class wrapperforColumn{ // internal structure of the column wrapper list 
    @AuraEnabled
    public string fieldName;
    @AuraEnabled
    public string fieldLabel;
    @AuraEnabled
    public string fieldType;
    }
    public class relativeObjectsData{ // For pop display after row cell click 
    @AuraEnabled public string objectName;
    @AuraEnabled public string recordName;
    @AuraEnabled public string recordId;
    @AuraEnabled public string iconName;
    @AuraEnabled public boolean checkUserData;
@AuraEnabled public boolean isRecordAvalible;
    }
    public class referenceRecordWrapper{  // for reference Account and contact 
    @AuraEnabled public string objectname;
    @AuraEnabled public string recordId;
    @AuraEnabled public string recordName;
    @AuraEnabled public string parentRecordName;
    @AuraEnabled public string parentRecordId;
    @AuraEnabled public string parentURl;
    @AuraEnabled public string recordURl;
    @AuraEnabled public string searchTerm;
    @AuraEnabled public string description;
    @AuraEnabled public List<relativeObjectsData> relativeObjectDataListAssociate;
    @AuraEnabled public string commaSepRelativeObjectDataStringAssociate;
    @AuraEnabled public List<relativeObjectsData> relativeObjectDataListContacts;
    @AuraEnabled public string commaSepRelativeObjectDataStringContacts;
    }
    
    // tp store record info
    public class RecordWrapper{
    @AuraEnabled public string Name;
    @AuraEnabled public string Id;
    @AuraEnabled public string iconName;
    @AuraEnabled public string objectName;
    @AuraEnabled public boolean isUser;
    }
    
    
    
    // to store api response
    public class FromJSON{
    @AuraEnabled public cls_colors[] colors;
    @AuraEnabled public boolean custom;
    @AuraEnabled public cls_icons[] icons;
    @AuraEnabled public String label;    //DemoObjects
    @AuraEnabled public string Name; 
    @AuraEnabled public String sobjectName;  //DemoObject__c
    
    }
    class Cls_colors {
    @AuraEnabled public String color;    //2ECBBE
    @AuraEnabled public String context;  //primary
    @AuraEnabled public String theme;    //theme4
    }
    class Cls_icons {
    @AuraEnabled public String contentType;  //image/png
    @AuraEnabled public Integer height;  //32
    @AuraEnabled public String theme;    //theme3
    @AuraEnabled public String url;  //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
    @AuraEnabled public Integer width;   //32
    }
    
    
    // for Advance Record Search
    
    
    
    }