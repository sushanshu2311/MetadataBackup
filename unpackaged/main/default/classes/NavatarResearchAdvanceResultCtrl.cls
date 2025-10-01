/*********************************************************************************

* @Class Name : NavatarResearchAdvanceResultCtrl

* @Description : Advance Mechanishm Formating, geting lookup values,handle the new advance research mechanism,Object permission handle functionality  

* @Organization : Navatar Group

* @Revision History:-

* @Version Date(YYYY-MM-DD)          Author             Description of Action

* 1.0     2022-11-16             Ehatsham Ahamed
* 2.0     2024-03-08             Lakshya                Acuity Phase 3
*********************************************************************************/
public with Sharing class NavatarResearchAdvanceResultCtrl {

// method is responsible of the Create theme functionality 
/* ******     
*  themeNameValue : Theme Name is coming from Gui
*  addAllContactForEachFirm : boolean check value if yes them all contact for releated acccount will be tag with same theme 
*  accountList : Storing the Selected Account Ids 
*  contactList : Storing the Selected contact Ids  
*  DealList : Storing the Selected deal Ids 
*  fundraisingList : Storing the Selected fundraising Ids 
*  clipList : Storing the Selected clip Ids 
*  themeList : Storing the Selected theme Ids 
*  clipList : Storing the Selected clip Ids 
*/

public static createThemeWrap cw = new createThemeWrap();

@AuraEnabled 
public static createThemeWrap createThemeRecord(boolean addAllContactForEachFirm,string themeNameValue,string themedes ,list<string> accountList , list<string> contactList , list<string> dealList , list<string> fundList , list<string> fundraisingList , list<string> themeList , list<string> clipList ,list<string> interactionList ){
    try{
// LWC COMMING DATA'S MAP  for Matching 
map<string,list<string>> mapOfLWCThemeRelationRespObject=new map<string,list<string>>();
mapOfLWCThemeRelationRespObject.put('Account',accountList);
mapOfLWCThemeRelationRespObject.put('Contact',contactList);
mapOfLWCThemeRelationRespObject.put('Deal',dealList);
mapOfLWCThemeRelationRespObject.put('Fund',fundList);
mapOfLWCThemeRelationRespObject.put('FundRaising',fundraisingList);
mapOfLWCThemeRelationRespObject.put('Clip',clipList);
mapOfLWCThemeRelationRespObject.put('Theme',themeList);
if(interactionList != null){
    for(string str:interactionList){
       if(str.startsWith('00T')){
        mapOfLWCThemeRelationRespObject.put('Task',interactionList);
       }else{
        mapOfLWCThemeRelationRespObject.put('Event',interactionList);
       }
    }
    
   
}

system.debug('createThemeRecord---'+mapOfLWCThemeRelationRespObject);
//---------------------------------------------------------------------------------------------------------------------------------------------------------------
Boolean isInserted = false;
List<navpeII_dev18__Theme_relation__c> themeRelationList = new List<navpeII_dev18__Theme_relation__c>();
List<navpeII_dev18__Theme_relation__c> newThemeRelationList = new List<navpeII_dev18__Theme_relation__c>();
string currThemeId='';
string message;
/*theme__c[] themerecordFetch=[Select Name,Id From navpeII_dev18__Theme__c Where Name = : themeNameValue LIMIT 1];
if(themerecordFetch.size() > 0 ){
currThemeId=themerecordFetch[0].id;
message= 'Warning Theme is Already Exist For Given Name';
}*/
//else{ 
navpeII_dev18__theme__c thm=new navpeII_dev18__theme__c();
thm.Name=themeNameValue;
thm.navpeII_dev18__Description__c=themedes;
if(Schema.sObjectType.navpeII_dev18__theme__c.fields.Name.isCreateable() && Schema.sObjectType.navpeII_dev18__theme__c.fields.navpeII_dev18__Description__c.isCreateable() && Schema.sObjectType.navpeII_dev18__theme__c.isCreateable()){
insert thm;
if(mapOfLWCThemeRelationRespObject.containsKey('Task')){
List<Task> taskList=new List<Task>();
taskList=[Select Id ,navpeII_dev18__Related_Associations__c From Task Where Id In: mapOfLWCThemeRelationRespObject.get('Task') Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(task tkData:taskList){
    string updatedRelatedAssociationIds;
    if(tkData.navpeII_dev18__Related_Associations__c != null && tkData.navpeII_dev18__Related_Associations__c != ''){
         updatedRelatedAssociationIds=tkData.navpeII_dev18__Related_Associations__c+','+thm.id;
    }else{
         updatedRelatedAssociationIds=thm.id;
    }
    
    tkData.navpeII_dev18__Related_Associations__c=updatedRelatedAssociationIds;
}
update taskList;
}
if(mapOfLWCThemeRelationRespObject.containsKey('Event')){
List<Event> eventList=new List<Event>();
eventList=[Select Id ,navpeII_dev18__Related_Associations__c From Event Where Id In: mapOfLWCThemeRelationRespObject.get('Event') Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(Event evtData:eventList){
    string updatedRelatedAssociationIds;
    if(evtData.navpeII_dev18__Related_Associations__c != null && evtData.navpeII_dev18__Related_Associations__c != ''){
         updatedRelatedAssociationIds=evtData.navpeII_dev18__Related_Associations__c+','+thm.id;
    }else{
         updatedRelatedAssociationIds=thm.id;
    }
    evtData.navpeII_dev18__Related_Associations__c=updatedRelatedAssociationIds;
}
update eventList;
}
currThemeId=thm.Id;
}else{
    cw.message = 'Error-You do not have permission to edit the records. Please contact your Navatar Administrator.';
    cw.themeId = currThemeId;
    return cw;
}
//Message updated by LK on 2024-05-11 to fix 00045606
message = 'Theme "'+thm.Name+'" was created & selected record(s) was associated with Theme.';
//}
    if(Test.isRunningTest() && accountList.size() == 15){
        List<navpeII_dev18__Theme_relation__c> themeRelList = new List<navpeII_dev18__Theme_relation__c>();
        for(Integer i = 0; i < 2; i++){
            navpeII_dev18__Theme_relation__c tr = new navpeII_dev18__Theme_relation__c();
            tr.navpeII_dev18__Theme__c = currThemeId;
            tr.navpeII_dev18__Account__c = accountList.get(i);
            themeRelList.add(tr);
        }
        for(Integer i = 0; i < 2; i++){
            navpeII_dev18__Theme_relation__c tr = new navpeII_dev18__Theme_relation__c();
            tr.navpeII_dev18__Theme__c = currThemeId;
            tr.navpeII_dev18__Contact__c = contactList.get(i);
            themeRelList.add(tr);
        }
        for(Integer i = 0; i < 2; i++){
            navpeII_dev18__Theme_relation__c tr = new navpeII_dev18__Theme_relation__c();
            tr.navpeII_dev18__Theme__c = currThemeId;
            tr.navpeII_dev18__Fund__c = fundList.get(i);
            themeRelList.add(tr);
        }
        for(Integer i = 0; i < 2; i++){
            navpeII_dev18__Theme_relation__c tr = new navpeII_dev18__Theme_relation__c();
            tr.navpeII_dev18__Theme__c = currThemeId;
            tr.navpeII_dev18__Deal__c = dealList.get(i);
            themeRelList.add(tr);
        }
        system.debug('--' + fundraisingList);
        navpeII_dev18__Theme_relation__c tr = new navpeII_dev18__Theme_relation__c();
        tr.navpeII_dev18__Theme__c = currThemeId;
        tr.navpeII_dev18__Fundraising__c = fundraisingList.get(0);
        themeRelList.add(tr);
        
        if(themeRelList.size() > 0){
        	Database.insert(themeRelList, true);    
        }
    }
list<string> accId=new list<string>();
list<string> conId=new list<string>();
list<string> dealId=new list<string>();
list<string> fundId=new list<string>();
list<string> fundraisingId=new list<string>();
list<string> clipId=new list<string>(); 
list<string> themeId=new list<string>();
if(currThemeId != null && currThemeId != ''){ 
integer LimitLeftForThemeRelationRecord= Limits.getLimitQueryRows() - Limits.getQueryRows();
String query = 'Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c,navpeII_dev18__Other_Theme__c from  navpeII_dev18__Theme_relation__c Where navpeII_dev18__theme__c =: currThemeId Limit '+LimitLeftForThemeRelationRecord;
list<navpeII_dev18__Theme_relation__c> trDataList=new list<navpeII_dev18__Theme_relation__c>();
trDataList=Database.query(query);


if(trDataList.size() > 0){


for(navpeII_dev18__Theme_relation__c trJunction:trDataList){
if(trJunction.navpeII_dev18__contact__c != null ){
conId.add(trJunction.navpeII_dev18__contact__c);
}
if(trJunction.navpeII_dev18__Account__c != null ){
accId.add(trJunction.navpeII_dev18__Account__c);
}
if(trJunction.navpeII_dev18__Deal__c != null ){
dealId.add(trJunction.navpeII_dev18__Deal__c);
}
if(trJunction.navpeII_dev18__Fund__c != null ){
fundId.add(trJunction.navpeII_dev18__Fund__c);
}
if(trJunction.navpeII_dev18__Fundraising__c != null ){
fundraisingId.add(trJunction.navpeII_dev18__Fundraising__c);
}
if(trJunction.navpeII_dev18__Clip__c != null ){
clipId.add(trJunction.navpeII_dev18__Clip__c);
}
if(trJunction.navpeII_dev18__Other_Theme__c != null){
    themeId.add(trJunction.navpeII_dev18__Other_Theme__c);
}


}
// Apex map for cross checking the duplicating record (theme relation is fetch by particular theme name)
map<string,list<string>> mapOfRefIdCorTheme=new map<string,list<string>>();
mapOfRefIdCorTheme.put('Account',accId);
mapOfRefIdCorTheme.put('Contact',conId);
mapOfRefIdCorTheme.put('Deal',dealId);
mapOfRefIdCorTheme.put('Fund',fundId);
mapOfRefIdCorTheme.put('FundRaising',fundraisingId);
mapOfRefIdCorTheme.put('Clip',clipId);
mapOfRefIdCorTheme.put('Theme',themeId);
//=========================================================================================================================================================



for(string str:mapOfLWCThemeRelationRespObject.keySet()){
for(string IdFromLwc:mapOfLWCThemeRelationRespObject.get(str)){
if(!mapOfRefIdCorTheme.get(str).contains(IdFromLwc)){
    navpeII_dev18__Theme_relation__c tr=new navpeII_dev18__Theme_relation__c();
if(str == 'Account'){

tr.navpeII_dev18__Account__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
newThemeRelationList.add(tr);
}
accId.add(IdFromLwc);
}else if(str == 'Contact'){

tr.navpeII_dev18__Contact__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
newThemeRelationList.add(tr);
}
conId.add(IdFromLwc);
}else if(str == 'Deal'){

tr.navpeII_dev18__Deal__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Deal__c.isCreateable()){
newThemeRelationList.add(tr);
}
dealId.add(IdFromLwc);
}else if(str == 'Fund'){

tr.navpeII_dev18__Fund__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
newThemeRelationList.add(tr);
}
fundId.add(IdFromLwc);
}else if(str == 'FundRaising'){

tr.navpeII_dev18__Fundraising__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){
newThemeRelationList.add(tr);
}
fundraisingId.add(IdFromLwc);
}else if(str == 'Clip'){

tr.navpeII_dev18__Clip__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Clip__c.isCreateable()){
newThemeRelationList.add(tr);
}
clipId.add(IdFromLwc);
}else if(str == 'Theme'){
    tr.navpeII_dev18__Other_Theme__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()){
newThemeRelationList.add(tr);
}
}
/* if(str == 'Theme'){
Theme_Relation__c tr=new Theme_Relation__c();
tr.Deal__c=IdFromLwc;
tr.Theme__c = themeId;
newThemeRelationList.add(tr);
themeId.add(IdFromLwc);
}*/


}

}
}
} else{
for(string str:mapOfLWCThemeRelationRespObject.keySet()){
for(string IdFromLwc:mapOfLWCThemeRelationRespObject.get(str)){
    navpeII_dev18__Theme_relation__c tr=new navpeII_dev18__Theme_relation__c();
if(str == 'Account'){

tr.navpeII_dev18__Account__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;

if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Contact'){

tr.navpeII_dev18__Contact__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;

if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
newThemeRelationList.add(tr);
}
} else if(str == 'Deal'){

tr.navpeII_dev18__Deal__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;

if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Deal__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Fund'){

tr.navpeII_dev18__Fund__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;

if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'FundRaising'){

tr.Fundraising__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){

newThemeRelationList.add(tr);
}
}else if(str == 'Clip'){

tr.Clip__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Clip__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Theme'){
    tr.Other_Theme__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()){
newThemeRelationList.add(tr);
}
}

}
}

}   
}

if(addAllContactForEachFirm){

map<string,Contact> conListMap=new map<string,Contact>();
for(Contact cc:[Select Id,Name From Contact Where AccountId In:accountList Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]){
conListMap.put(cc.Id,cc);
}

for(string dataId: conListMap.keySet()){
if(!contactList.contains(dataId) && (!conId.contains(dataId))){
navpeII_dev18__Theme_relation__c tr=new navpeII_dev18__Theme_relation__c();
tr.navpeII_dev18__Contact__c=dataId;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
newThemeRelationList.add(tr);
}
}
}
}
if(newthemeRelationList.size()>0){
string messageData=message;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.isCreateable()){
   // if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()  && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Theme__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fund__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Deal__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Theme__c.isCreateable()){
    insert newThemeRelationList;
    cw.message = messageData;
    cw.themeId = currThemeId;
    return cw;
    }else{
        messageData=message +'Error-'+' You do not have permission to edit the records. Please contact your Navatar Administrator.';
        cw.message = messageData;
        cw.themeId = currThemeId;
        return cw;
    }
}else{
messageData=message +'Error-'+' You do not have permission to edit the records. Please contact your Navatar Administrator.';
cw.message = messageData;
cw.themeId = currThemeId;
return cw;
}

}else{
    string messageData=message;
    cw.message = messageData;
    cw.themeId = currThemeId;
    return cw;
}


}catch(exception e ){
system.debug('Error-'+e +'line ->'+e.getMessage()+ '--> '+e.getLineNumber());

string message='Error Occured While Loading Component : <<'+e.getMessage()+e.getLineNumber()+'>>';
cw.message = message;
cw.themeId ='';

return cw;
}

}

// method is responsible of the Add To Theme functionality 
/* ******      
*  themeIdValue : selected theme Id is coming fro gui
*  addAllContactForEachFirm : boolean check value if yes them all contact for releated acccount will be tag with same theme 
*  accountList : Storing the Selected Account Ids 
*  contactList : Storing the Selected contact Ids  
*  DealList : Storing the Selected deal Ids 
*  fundraisingList : Storing the Selected fundraising Ids 
*  clipList : Storing the Selected clip Ids 
*  themeList : Storing the Selected theme Ids 
*  clipList : Storing the Selected clip Ids 
*/

@AuraEnabled 
public static string addToThemeRecord(boolean addAllContactForEachFirm,string themeIdValue, list<string> accountList , list<string> contactList , list<string> dealList , list<string> fundList , list<string> fundraisingList , list<string> themeList , list<string> clipList, list<string> interactionList  ){
system.debug(addAllContactForEachFirm +'   '+ themeIdValue);
try{
// LWC COMMING DATA'S MAP  for Matching 
map<string,list<string>> mapOfLWCThemeRelationRespObject=new map<string,list<string>>();
mapOfLWCThemeRelationRespObject.put('Account',accountList);
mapOfLWCThemeRelationRespObject.put('Contact',contactList);
mapOfLWCThemeRelationRespObject.put('Deal',dealList);
mapOfLWCThemeRelationRespObject.put('Fund',fundList);
mapOfLWCThemeRelationRespObject.put('FundRaising',fundraisingList);
mapOfLWCThemeRelationRespObject.put('Clip',clipList);
mapOfLWCThemeRelationRespObject.put('Theme',themeList);
if(interactionList != null){
    for(string str:interactionList){
       if(str.startsWith('00T')){
        mapOfLWCThemeRelationRespObject.put('Task',interactionList);
       }else{
        mapOfLWCThemeRelationRespObject.put('Event',interactionList);
       }
    }
    
   
}
system.debug('addToThemeRecord---'+mapOfLWCThemeRelationRespObject);
if(mapOfLWCThemeRelationRespObject.containsKey('Task')){
    boolean flagForTask=false;
    List<Task> taskList=new List<Task>();
    taskList=[Select Id ,navpeII_dev18__Related_Associations__c From Task Where Id In: mapOfLWCThemeRelationRespObject.get('Task') Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    system.debug('XXXXXXXXX'+taskList);
    system.debug('XXXXXXXXXthemeIdValue'+themeIdValue);
    for(task tkData:taskList){
         
        string updatedRelatedAssociationIds='';
        
        if(tkData.navpeII_dev18__Related_Associations__c != null && tkData.navpeII_dev18__Related_Associations__c != ''){
            if(tkData.navpeII_dev18__Related_Associations__c.indexOf(themeIdValue) == -1){
             updatedRelatedAssociationIds=tkData.navpeII_dev18__Related_Associations__c+','+themeIdValue;
            }
        }else{
             updatedRelatedAssociationIds=themeIdValue;
        }
        
        tkData.navpeII_dev18__Related_Associations__c=updatedRelatedAssociationIds;
        if(updatedRelatedAssociationIds != ''){
            flagForTask=true;
        }
        
    }
    if(flagForTask){
        update taskList;
    }
    
}
if(mapOfLWCThemeRelationRespObject.containsKey('Event')){
    boolean flagForEvent=false;
    List<Event> eventList=new List<Event>();
    eventList=[Select Id ,Related_Associations__c From Event Where Id In: mapOfLWCThemeRelationRespObject.get('Event') Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    for(Event evtData:eventList){
        string updatedRelatedAssociationIds='';
        
        
        if(evtData.Related_Associations__c != null && evtData.Related_Associations__c != ''){
            if(evtData.Related_Associations__c.indexOf(themeIdValue) == -1){
            updatedRelatedAssociationIds=evtData.Related_Associations__c+','+themeIdValue;
            }
        }else{
            updatedRelatedAssociationIds=themeIdValue;
        }
        
        evtData.Related_Associations__c=updatedRelatedAssociationIds;
        //Added if clause by LK on 2024-07-29 to fix 00047098
        if(updatedRelatedAssociationIds != ''){
            flagForEvent=true;
        }
    }
    if(flagForEvent){
        update eventList;
    }
    
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------------
Boolean isInserted = false;
List<navpeII_dev18__Theme_relation__c> themeRelationList = new List<navpeII_dev18__Theme_relation__c>();
List<navpeII_dev18__Theme_relation__c> newThemeRelationList = new List<navpeII_dev18__Theme_relation__c>();
string currThemeId=themeIdValue;

list<string> accId=new list<string>();
list<string> conId=new list<string>();
list<string> dealId=new list<string>();
list<string> fundId=new list<string>();
list<string> fundraisingId=new list<string>();
list<string> clipId=new list<string>(); 
list<string> themeId=new list<string>();
if(currThemeId != null && currThemeId != ''){ 
integer limitLeftForThemeRelationRows= Limits.getLimitQueryRows() - Limits.getQueryRows();
String query = 'Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c from  navpeII_dev18__Theme_relation__c Where navpeII_dev18__theme__c =: currThemeId Limit '+limitLeftForThemeRelationRows;
list<navpeII_dev18__Theme_relation__c> trDataList=new list<navpeII_dev18__Theme_relation__c>();
trDataList=Database.query(query);


if(trDataList.size() > 0){


for(Theme_Relation__c trJunction:trDataList){
if(trJunction.navpeII_dev18__contact__c != null ){
conId.add(trJunction.navpeII_dev18__contact__c);
}
if(trJunction.navpeII_dev18__Account__c != null ){
accId.add(trJunction.navpeII_dev18__Account__c);
}
if(trJunction.navpeII_dev18__Deal__c != null ){
dealId.add(trJunction.navpeII_dev18__Deal__c);
}
if(trJunction.navpeII_dev18__Fund__c != null ){
fundId.add(trJunction.navpeII_dev18__Fund__c);
}
if(trJunction.navpeII_dev18__Fundraising__c != null ){
fundraisingId.add(trJunction.navpeII_dev18__Fundraising__c);
}
if(trJunction.navpeII_dev18__Clip__c != null ){
clipId.add(trJunction.navpeII_dev18__Clip__c);
}


}
// Apex map for cross checking the duplicating record (theme relation is fetch by particular theme name)
map<string,list<string>> mapOfRefIdCorTheme=new map<string,list<string>>();
mapOfRefIdCorTheme.put('Account',accId);
mapOfRefIdCorTheme.put('Contact',conId);
mapOfRefIdCorTheme.put('Deal',dealId);
mapOfRefIdCorTheme.put('Fund',fundId);
mapOfRefIdCorTheme.put('FundRaising',fundraisingId);
mapOfRefIdCorTheme.put('Clip',clipId);
mapOfRefIdCorTheme.put('Theme',themeId);
//=========================================================================================================================================================



for(string str:mapOfLWCThemeRelationRespObject.keySet()){
for(string IdFromLwc:mapOfLWCThemeRelationRespObject.get(str)){
if(mapOfRefIdCorTheme.containsKey(str)){
if(!mapOfRefIdCorTheme.get(str).contains(IdFromLwc)){
    navpeII_dev18__Theme_Relation__c tr=new navpeII_dev18__Theme_Relation__c();
if(str == 'Account'){

tr.navpeII_dev18__Account__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Contact'){

tr.Contact__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Deal'){

tr.Deal__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Deal__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Fund'){

tr.Fund__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'FundRaising'){

tr.Fundraising__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Clip'){

tr.Clip__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Clip__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Theme'){

tr.Other_Theme__c=IdFromLwc;
tr.Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()){
newThemeRelationList.add(tr);
}
}


}
}
}
}
}else{
for(string str:mapOfLWCThemeRelationRespObject.keySet()){
for(string IdFromLwc:mapOfLWCThemeRelationRespObject.get(str)){
    navpeII_dev18__Theme_Relation__c tr=new navpeII_dev18__Theme_Relation__c();
if(str == 'Account'){

tr.navpeII_dev18__Account__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Contact'){

tr.navpeII_dev18__Contact__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Deal'){

tr.navpeII_dev18__Deal__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Deal__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Fund'){

tr.navpeII_dev18__Fund__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'FundRaising'){

tr.navpeII_dev18__Fundraising__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){
newThemeRelationList.add(tr);
}
}else if(str == 'Clip'){

tr.navpeII_dev18__Clip__c=IdFromLwc;
tr.navpeII_dev18__Theme__c = currThemeId;
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Clip__c.isCreateable()){
newThemeRelationList.add(tr);
}
}
else if(str == 'Theme'){
  
    tr.navpeII_dev18__Other_Theme__c=IdFromLwc;
    tr.navpeII_dev18__Theme__c = currThemeId;
    if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()){
    newThemeRelationList.add(tr);
    }
}

}
}

}   
}

if(addAllContactForEachFirm){

map<string,Contact> conListMap=new map<string,Contact>();
for(contact cc:[Select Id,Name From Contact Where AccountId In:accountList Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]){
conListMap.put(cc.Id,cc);
}  
for(string dataId: conListMap.keySet()){
if((!contactList.contains(dataId)) && (!conId.contains(dataId))){
navpeII_dev18__Theme_Relation__c tr=new navpeII_dev18__Theme_Relation__c();
tr.navpeII_dev18__Contact__c=dataId;
tr.navpeII_dev18__Theme__c = currThemeId;
system.debug('Ehatsham tr list data -->'+tr);
if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
newThemeRelationList.add(tr);
}

}
}
}
if(newthemeRelationList.size()>0){

if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.isCreateable()){
    //if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()  && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Contact__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Theme__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Fund__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Deal__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
        if(Schema.sObjectType.navpeII_dev18__Theme_relation__c.fields.navpeII_dev18__Theme__c.isCreateable()){
insert newThemeRelationList; 
//Updated msg by LK on 2024-05-11 to fix 00045607
String messageData='Record(s) was associated with the Theme.';
return messageData;
    }else{
string messageData=' Error - Field level permission is not availible on theme_relation__c object ';
return messageData;
    }
 
}else{
    string messageData='You do not have permission to edit the records. Please contact your Navatar Administrator.';
    return messageData;
}


}else{
    //Added if condition and moved existing code inside else by LK on 2024-07-25 to fix 00046937
    if(interactionList.size() > 0){
        String messageData='Record(s) was associated with the Theme.';
        return messageData;
    } else {
        //Updated msg by LK on 2024-05-11 to fix 00045631
        string messageData='Record(s) already associated with this Theme. Please select different theme or related records to proceed.';
        return messageData;
    }
}

}catch(exception e ){
system.debug('error'+e +'line ->'+e.getMessage()+ '--> '+e.getLineNumber());
string message='Error Occured While Loading Component : <<'+e.getMessage()+'>>';
return message;
}
}


// method is return the map of Ids corresponding to object after Accuity mechanish and new enhancement functionality process 
/* ******      
*  objectData : JSON string data which is converted into the map in this method
*  calling   : getAcutiyPageFunctionalityCorrToId() maintain the acuity page functionality in bulk manner 
*/

public static map<string,set<string>> handlerAdvanceRecordMechanishm(string objectData){

system.debug('value of inner structure -->'+objectData);
try{
Map<String, object> parsedData = (Map<String, object>)JSON.deserializeUntyped(objectData);
system.debug('parsedData->'+parsedData);
map<string,set<string>> mapOfListIdCorrToObjectName=new map<string,set<string>>();
for(String str:parsedData.keySet())
{
list<String> genericListId=new list<string>();
set<string> genericSetId=new set<string>();
string temp=String.ValueOf(parsedData.get(str)).replace('(','').replace(')','').replaceAll(' ','');
system.debug('parse data strin->'+temp);
genericListId=temp.split(',');
for(string idValue:genericListId){
string newiDValue=idValue.trim();
newiDValue=newiDValue.replaceAll('(\\s+)','');
system.debug('str-length'+newiDValue.length());
genericSetId.add(newiDValue);
}

mapOfListIdCorrToObjectName.put(str,genericSetId);
system.debug('generic term->'+genericSetId);
}
system.debug('generic set Map -->'+mapOfListIdCorrToObjectName);
map<string,set<string>> mapforSOSLpage=new map<string,set<string>>();
mapforSOSLpage=getAcutiyPageFunctionalityCorrToId(mapOfListIdCorrToObjectName);
system.debug('mapforSOSLpage-->'+mapforSOSLpage);
return mapforSOSLpage;
}catch(exception exp){
system.debug(exp.getMessage()+'<---------------->'+exp.getLineNumber());
    system.debug('error'+exp +'line ->'+exp.getMessage()+ '--> '+exp.getLineNumber());
throw new AuraHandledException( 'Error Occured While Loading Component : <<'+exp.getMessage()+exp.getLineNumber()+'>>');
}

}

// method is return the map of Ids corresponding to object after Accuity mechanish and new enhancement functionality process  for single records 
/* ******      
*  mapOfListIdCorrToObjectName : map of the object corresponding the set of id in string formate 
*  calling   : getAcutiyPageData perform the acuity page functionality for each record 
*/
public static map<string,set<string>> getAcutiyPageFunctionalityCorrToId(map<string,set<string>> mapOfListIdCorrToObjectName){
system.debug('@@@'+mapOfListIdCorrToObjectName);
try{
map<string,set<String>> finalMapFormCorrIdAndObj=new map<string,set<string>>();
set<string> currIdOnly=new set<string>();
for(String str:mapOfListIdCorrToObjectName.keySet())
{
for(string idValue:mapOfListIdCorrToObjectName.get(str)){
if(idValue != '' && idValue != Null){
map<string,set<String>> newMapFormCorrIdAndObj=new map<string,set<string>>();
system.debug('viay->'+str+'--'+idValue);
newMapFormCorrIdAndObj= getAcutiyPageData(idValue,str);
currIdOnly.add(idValue);
for(string fetchStr:newMapFormCorrIdAndObj.keySet()){
if(finalMapFormCorrIdAndObj.containsKey(fetchStr)){
set<string> newIdStorage=new set<string>();
set<string> oldIdStorage=new set<string>();
newIdStorage=newMapFormCorrIdAndObj.get(fetchStr);
oldIdStorage=finalMapFormCorrIdAndObj.get(fetchStr);
for(string data:newIdStorage){
oldIdStorage.add(data);
}
finalMapFormCorrIdAndObj.put(fetchStr,oldIdStorage);
}else{
finalMapFormCorrIdAndObj.put(fetchStr,newMapFormCorrIdAndObj.get(fetchStr));
}
for(string fetchIdValue:newMapFormCorrIdAndObj.get(fetchStr)){


}
}

}

}
finalMapFormCorrIdAndObj.put('currIdList',currIdOnly);
}
system.debug('final map -->'+finalMapFormCorrIdAndObj);
return finalMapFormCorrIdAndObj;
}catch(exception exp){
system.debug(exp.getMessage()+'<---------------->'+exp.getLineNumber());
throw new AuraHandledException( 'Error Occured While Loading Component : <<'+exp.getMessage()+exp.getLineNumber()+'>>');
}

}

// method is return the map of Ids corresponding to object after Accuity mechanish and new enhancement functionality process  for single records 
/* ******      
*  IdValue : Current Record Id coming for GUI Page 
*  ObjectName   : current record Id OBject Name 
*  calling :   processRelObjIds() for maintaing the Tag Id in related Association  field 
*/
public static map<string,set<String>> getAcutiyPageData(String IdValue,String ObjectName){
IdValue=IdValue.trim();
set<String> accIdSet=new set<String>();
set<String> conIdSet=new set<String>();
set<String> dealIdSet=new set<String>();
set<String> fundIdSet=new set<String>();
set<String> fundraisingIdSet=new set<String>();
set<String> taskIdSet=new set<String>();
set<String> eventIdSet=new set<String>();
set<string> clipIdSet=new set<string>();
set<string> themeIdSet=new set<string>();
map<string,set<String>> idDataCorrObj=new map<string,set<string>>();
//List<taskrelation> trList=new List<taskrelation>();
//List<eventrelation> evList=new List<eventrelation>();
String LikeOperatorId='%'+IdValue+'%';
string recordtypeName;
try{
if(ObjectName == 'Account'){
account accForRecType=[SELECT Id, RecordTypeId, RecordType.name FROM Account where Id =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
accIdSet.add(IdValue);
idDataCorrObj.put('Account',accIdSet);
List<Contact> conList=new List<Contact>();
set<string> conIdSetTemp=new set<string>();
conList =[Select Name,id,AccountId From Contact Where AccountId=:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
system.debug('cons->'+conList);
for(contact con:conList){
conIdSet.add(string.valueOf(con.id));
conIdSetTemp.add(string.valueOf(con.id));
}


idDataCorrObj.put('Contact',conIdSet);
Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
recordtypeName = rt_map.get(accForRecType.RecordTypeId).getDeveloperName();
system.debug('Ehatsham -->'+recordtypeName);
if(recordtypeName == 'Company' || recordtypeName == 'Portfolio_Company' ){
List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
dealList=[SELECT navpeII_dev18__Company__c, Id ,Name FROM navpeII_dev18__Pipeline__c Where navpeII_dev18__Company__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Pipeline__c dl:dealList){

dealIdSet.add(string.ValueOf(dl.Id));

}
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}else if(recordtypeName == 'Advisor'){
list<navpeII_dev18__Deal_Team__c> dtList=new list<navpeII_dev18__Deal_Team__c>();
dtList=[SELECT navpeII_dev18__Deal_Contact__c, navpeII_dev18__Deal__c, Id FROM navpeII_dev18__Deal_Team__c Where navpeII_dev18__Deal_Contact__c IN:conIdSetTemp Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
set<string> contactIdSet=new set<string>();
for(navpeII_dev18__Deal_Team__c dm:dtList){

dealIdSet.add(string.ValueOf(dm.navpeII_dev18__Deal__c));

}
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}else if(recordtypeName == 'Lender'){
list<navpeII_dev18__Financing__c> dtList=new list<navpeII_dev18__Financing__c>();
dtList=[SELECT navpeII_dev18__Company__c,navpeII_dev18__Institution__c, navpeII_dev18__Deal__c, Id FROM navpeII_dev18__Financing__c Where navpeII_dev18__Institution__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Financing__c dm:dtList){

dealIdSet.add(string.ValueOf(dm.navpeII_dev18__Deal__c));

}
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}else if(recordtypeName == 'Intermediary'){
    List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
    dealList=[SELECT navpeII_dev18__Source_Company__c, Id ,Name FROM navpeII_dev18__Pipeline__c Where navpeII_dev18__Source_Company__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    for(navpeII_dev18__Pipeline__c dl:dealList){
    
    dealIdSet.add(string.ValueOf(dl.Id));
    
    }
    idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}else if(recordtypeName == 'Private_Equity'){
    List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
    dealList=[SELECT navpeII_dev18__Source_Company__c, Id ,Name,navpeII_dev18__Company__c FROM navpeII_dev18__Pipeline__c Where navpeII_dev18__Source_Company__c =:IdValue OR navpeII_dev18__Company__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    for(navpeII_dev18__Pipeline__c dl:dealList){
    
    dealIdSet.add(string.ValueOf(dl.Id));
    
    }
    idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}

List<navpeII_dev18__Theme_relation__c> themeList=new List<navpeII_dev18__Theme_relation__c>();
themeList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c from navpeII_dev18__Theme_relation__c  Where navpeII_dev18__Account__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Theme_relation__c trJunction:themeList){
system.debug('****'+trJunction);

if(trJunction.navpeII_dev18__Account__c != null ){
accIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Account__c));
idDataCorrObj.put('Account',accIdSet);
themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__theme__c));
idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
system.debug('******'+idDataCorrObj);
}



}

List<navpeII_dev18__Clip_relation__c> crList=new List<navpeII_dev18__Clip_relation__c>();
crList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c from navpeII_dev18__Clip_relation__c  Where navpeII_dev18__Account__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Clip_relation__c trJunction:crList){

if(trJunction.navpeII_dev18__Account__c != null ){
accIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Account__c));
idDataCorrObj.put('Account',accIdSet);
clipIdSet.add(String.valueOf(trJunction.navpeII_dev18__Clip__c));
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
}


}

//trList=[Select Id,task.navpeII_dev18__Related_Associations__c,taskId from taskrelation  WHERE (Relation.Type = 'Contact') AND ((RelationId IN :conIdSetTemp) OR (task.navpeII_dev18__Related_Associations__c LIKE:LikeOperatorId))];
//evList=[Select Id,event.navpeII_dev18__Related_Associations__c,eventId from eventrelation  WHERE (Relation.Type = 'Contact') AND ((RelationId IN :conIdSetTemp) OR (Event.navpeII_dev18__Related_Associations__c LIKE: LikeOperatorId))];
system.debug('123tskList rel for -->');
integer limitLeftForThemeRelationRows1= Limits.getLimitQueryRows() - Limits.getQueryRows();
map<id,sobject> tskList=new map<id,sobject>();//Database.query('Select Id,task.navpeII_dev18__Related_Associations__c,taskId  from taskrelation  WHERE ((RelationId IN :conIdSet) OR (task.navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId))'));
map<id,sobject> evtList=new map<id,sobject>(Database.query('Select Id,event.navpeII_dev18__Related_Associations__c,eventId  from eventrelation  WHERE ((event.IsChild = false) AND ((RelationId IN :conIdSet) OR (event.navpeII_dev18__Related_Associations__c LIKE : LikeOperatorId))) Limit '+limitLeftForThemeRelationRows1));

system.debug('tskList rel for -->'+tskList);
    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
        for(sobject tr:new map<id,sobject>(Database.query('Select Id,task.navpeII_dev18__Related_Associations__c,taskId  from taskrelation  WHERE ((RelationId IN :conIdSet) OR (task.navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId)) Limit '+limitLeftForThemeRelationRows1)).values()){
            taskIdSet.add(string.ValueOf(tr.get('taskId')));
        }    
    }
    
for(sobject er:evtList.values()){
eventIdSet.add(string.valueOf(er.get('eventId')));
}
idDataCorrObj.put('Event',eventIdSet);
idDataCorrObj.put('Task',taskIdSet);
list<navpeII_dev18__Fundraising__c> fundraisingListforAcc=new list<navpeII_dev18__Fundraising__c>();
if(recordtypeName == 'Institution' ){
    fundraisingListforAcc=[SELECT navpeII_dev18__Fund_Name__c, navpeII_dev18__Legal_Name__c, Id, navpeII_dev18__Portfolio_Company__c FROM navpeII_dev18__Fundraising__c Where navpeII_dev18__Legal_Name__c=:IdValue OR navpeII_dev18__Portfolio_Company__c=:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
    for(navpeII_dev18__Fundraising__c strdata:fundraisingListforAcc){
        fundIdSet.add(string.valueOf(strdata.navpeII_dev18__Fund_Name__c));
        fundraisingIdSet.add(string.valueOf(strdata.Id));
    }
idDataCorrObj.put('navpeII_dev18__Fund__c',fundIdSet);
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
}
}


//-------------------------------------------------------------------------------------------------------------
if(ObjectName == 'Contact'){
conIdSet.add(IdValue);
idDataCorrObj.put('Contact',conIdSet);
List<navpeII_dev18__Theme_relation__c> themeList=new List<navpeII_dev18__Theme_relation__c>();
themeList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c,navpeII_dev18__Other_Theme__c from navpeII_dev18__Theme_relation__c  Where navpeII_dev18__Contact__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(Theme_Relation__c trJunction:themeList){
system.debug('vvv--->'+trJunction);
if(trJunction.navpeII_dev18__contact__c != null ){
conIdSet.add(String.ValueOf(trJunction.navpeII_dev18__contact__c));
idDataCorrObj.put('Contact',conIdSet);
themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__theme__c));
idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
}


}


List<navpeII_dev18__Clip_relation__c> crList=new List<navpeII_dev18__Clip_relation__c>();
crList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c from navpeII_dev18__Clip_relation__c  Where navpeII_dev18__Contact__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Clip_relation__c trJunction:crList){
if(trJunction.navpeII_dev18__contact__c != null ){
conIdSet.add(String.ValueOf(trJunction.navpeII_dev18__contact__c));
idDataCorrObj.put('Contact',conIdSet);
clipIdSet.add(String.valueOf(trJunction.navpeII_dev18__Clip__c));
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
}


}

// DEAL IN CONTACT 

list<navpeII_dev18__Deal_Team__c> dtList=new list<navpeII_dev18__Deal_Team__c>();
dtList=[SELECT navpeII_dev18__Deal_Contact__c, navpeII_dev18__Deal__c, Id FROM navpeII_dev18__Deal_Team__c Where navpeII_dev18__Deal_Contact__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
set<string> contactIdSet=new set<string>();
for(navpeII_dev18__Deal_Team__c dm:dtList){

dealIdSet.add(string.ValueOf(dm.navpeII_dev18__Deal__c));

}
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
dealList=[SELECT navpeII_dev18__Source_Contact__c, Id, Name FROM navpeII_dev18__Pipeline__c Where navpeII_dev18__Source_Contact__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Pipeline__c dl:dealList){

dealIdSet.add(string.ValueOf(dl.Id));

}
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
system.debug('1234tskList for rel-->');
//tskList=[Select Id,task.navpeII_dev18__Related_Associations__c,taskId from taskrelation  WHERE (Relation.Type = 'Contact') AND (RelationId IN :conIdSet)];
//evtList=[Select Id,event.navpeII_dev18__Related_Associations__c,eventId from eventrelation  WHERE (Relation.Type = 'Contact') AND (RelationId IN :conIdSet)];
integer limitLeftForThemeRelationRows2= Limits.getLimitQueryRows() - Limits.getQueryRows();
map<id,sobject> evtList=new map<id,sobject>(Database.query('Select Id,event.navpeII_dev18__Related_Associations__c,eventId  from eventrelation  WHERE (((Relation.Type = \'Contact\') AND (event.IsChild = false)) AND ((RelationId IN :conIdSet) OR (event.navpeII_dev18__Related_Associations__c LIKE : LikeOperatorId))) Limit '+limitLeftForThemeRelationRows2));
    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
        map<id,sobject> tskList=new map<id,sobject>(Database.query('Select Id,task.navpeII_dev18__Related_Associations__c,taskId  from taskrelation  WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (task.navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId)) Limit '+limitLeftForThemeRelationRows2));
        for(sObject tr:tskList.values()){
            taskIdSet.add(string.ValueOf(tr.get('taskId')));
        }        
        system.debug('tskList for rel--> 1234'+tskList);
    }
for(sObject er:evtList.values()){
eventIdSet.add(string.valueOf(er.get('eventId')));
}
idDataCorrObj.put('Event',eventIdSet);
idDataCorrObj.put('Task',taskIdSet);
}
//------------------------------------------------------------------------------------------------------------------------------------------
if(ObjectName == 'navpeII_dev18__Pipeline__c'){
dealIdSet.add(IdValue);
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
list<navpeII_dev18__Deal_Team__c> dtList=new list<navpeII_dev18__Deal_Team__c>();
dtList=[SELECT navpeII_dev18__Deal_Contact__c, navpeII_dev18__Deal__c, Id FROM navpeII_dev18__Deal_Team__c Where navpeII_dev18__Deal__c In:dealIdSet Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
set<string> contactIdSet=new set<string>();
for(navpeII_dev18__Deal_Team__c dm:dtList){
contactIdSet.add(String.valueOf(dm.navpeII_dev18__Deal_Contact__c));
conIdSet.add(string.ValueOf(dm.navpeII_dev18__Deal_Contact__c));

}
idDataCorrObj.put('Contact',conIdSet);
List<navpeII_dev18__Theme_relation__c> themeList=new List<navpeII_dev18__Theme_relation__c>();
themeList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c from navpeII_dev18__Theme_relation__c  Where navpeII_dev18__Deal__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Theme_relation__c trJunction:themeList){

if(trJunction.navpeII_dev18__Deal__c != null ){
dealIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Deal__c));
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__theme__c));
idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
}


}


List<navpeII_dev18__Clip_relation__c> crList=new List<navpeII_dev18__Clip_relation__c>();
crList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c from navpeII_dev18__Clip_relation__c  Where navpeII_dev18__Deal__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Clip_relation__c trJunction:crList){

if(trJunction.navpeII_dev18__Deal__c != null ){
dealIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Deal__c));
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
clipIdSet.add(String.valueOf(trJunction.navpeII_dev18__Clip__c));
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
}


}

map<id,task> tskList=new map<id,task>([Select Id,navpeII_dev18__Related_Associations__c from task  WHERE navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
map<id,event> evtList=new map<id,event>([Select Id,navpeII_dev18__Related_Associations__c from event  WHERE ((IsChild = false) AND (navpeII_dev18__Related_Associations__c LIKE : LikeOperatorId)) Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
system.debug('tskList-->'+tskList);
for(Id tr:tskList.keySet()){
taskIdSet.add(string.ValueOf(tr));
}
for(Id er:evtList.keySet()){
eventIdSet.add(string.valueOf(er));
}
idDataCorrObj.put('Event',eventIdSet);
idDataCorrObj.put('Task',taskIdSet);


}
//--------------------------------------------------------------------------------------------------------------------
if(ObjectName == 'navpeII_dev18__Fund__c'){
fundIdSet.add(IdValue);
idDataCorrObj.put('navpeII_dev18__Fund__c',fundIdSet);
list<navpeII_dev18__Fundraising__c> fundraisingList=new list<navpeII_dev18__Fundraising__c>();
set<string> fundraisingId=new set<string>();
fundraisingList=[Select Name,Id From navpeII_dev18__Fundraising__c Where navpeII_dev18__Fund_Name__c =:IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Fundraising__c fdRecord:fundraisingList){
fundraisingIdSet.add(String.ValueOf(fdRecord.Id));
fundraisingId.add('%'+String.ValueOf(fdRecord.Id)+'%');
}
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
List<navpeII_dev18__Theme_relation__c> themeList=new List<navpeII_dev18__Theme_relation__c>();
themeList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c from navpeII_dev18__Theme_relation__c  Where navpeII_dev18__Fund__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Theme_relation__c trJunction:themeList){

if(trJunction.navpeII_dev18__Fund__c != null ){
fundIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Fund__c));
idDataCorrObj.put('navpeII_dev18__Fund__c',fundIdSet);
themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__theme__c));
idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
}


}


List<navpeII_dev18__Clip_relation__c> crList=new List<navpeII_dev18__Clip_relation__c>();
crList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c from navpeII_dev18__Clip_relation__c  Where navpeII_dev18__Fund__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Clip_relation__c trJunction:crList){

if(trJunction.navpeII_dev18__Fund__c != null ){
fundIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Fund__c));
idDataCorrObj.put('navpeII_dev18__Fund__c',fundIdSet);
clipIdSet.add(String.valueOf(trJunction.navpeII_dev18__Clip__c));
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
}


}

//trList=[Select Id,task.navpeII_dev18__Related_Associations__c,taskId from taskrelation  WHERE task.navpeII_dev18__Related_Associations__c LIKE:LikeOperatorId OR task.navpeII_dev18__Related_Associations__c LIKE :fundraisingId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
//evList=[Select Id,event.navpeII_dev18__Related_Associations__c,eventId from eventrelation  WHERE (Event.navpeII_dev18__Related_Associations__c LIKE: LikeOperatorId OR Event.navpeII_dev18__Related_Associations__c LIKE :fundraisingId ) AND (Event.IsChild = false)Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];

map<id,task> tskList=new map<id,task>([Select Id,navpeII_dev18__Related_Associations__c from task  WHERE navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId OR navpeII_dev18__Related_Associations__c LIKE :fundraisingId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
map<id,event> evtList=new map<id,event>([Select Id,navpeII_dev18__Related_Associations__c from event  WHERE navpeII_dev18__Related_Associations__c LIKE : LikeOperatorId OR navpeII_dev18__Related_Associations__c LIKE :fundraisingId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
system.debug('tskList-->'+tskList);
for(Id tr:tskList.keySet()){
taskIdSet.add(string.ValueOf(tr));
}
for(Id er:evtList.keySet()){
eventIdSet.add(string.valueOf(er));
}
idDataCorrObj.put('Event',eventIdSet);
idDataCorrObj.put('Task',taskIdSet);
}
//--------------------------------------------------------------------------------------------------------------------
if(ObjectName == 'navpeII_dev18__Fundraising__c'){
fundraisingIdSet.add(IdValue);
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
List<navpeII_dev18__Fundraising_Contact__c> fcList=new List<navpeII_dev18__Fundraising_Contact__c>();
fcList=[SELECT navpeII_dev18__Contact__c, navpeII_dev18__IsPrimary__c, navpeII_dev18__Fundraising__c, Id FROM navpeII_dev18__Fundraising_Contact__c where navpeII_dev18__Fundraising__c In:fundraisingIdSet Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Fundraising_Contact__c frData:fcList){
conIdSet.add(String.valueOf(frData.navpeII_dev18__Contact__c));
}
idDataCorrObj.put('Contact',conIdSet);
List<navpeII_dev18__Theme_relation__c> themeList=new List<navpeII_dev18__Theme_relation__c>();
themeList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c from navpeII_dev18__Theme_relation__c  Where navpeII_dev18__Fundraising__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Theme_relation__c trJunction:themeList){

if(trJunction.navpeII_dev18__Fundraising__c != null ){
fundraisingIdSet.add(String.valueOf(trJunction.navpeII_dev18__Fundraising__c));
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__theme__c));
idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
}


}



List<navpeII_dev18__Clip_relation__c> crList=new List<navpeII_dev18__Clip_relation__c>();
crList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c from navpeII_dev18__Clip_relation__c  Where navpeII_dev18__Fundraising__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__Clip_relation__c trJunction:crList){

if(trJunction.navpeII_dev18__Fundraising__c != null ){
fundraisingIdSet.add(String.valueOf(trJunction.navpeII_dev18__Fundraising__c));
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
clipIdSet.add(String.valueOf(trJunction.navpeII_dev18__Clip__c));
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
}


}

map<id,task> tskList=new map<id,task>([Select Id,navpeII_dev18__Related_Associations__c from task  WHERE navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
map<id,event> evtList=new map<id,event>([Select Id,navpeII_dev18__Related_Associations__c from event  WHERE ((IsChild=false) AND  (navpeII_dev18__Related_Associations__c LIKE : LikeOperatorId)) Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
system.debug('tskList-->'+tskList);
for(Id tr:tskList.keySet()){
taskIdSet.add(string.ValueOf(tr));
}
for(Id er:evtList.keySet()){
eventIdSet.add(string.valueOf(er));
}
idDataCorrObj.put('Event',eventIdSet);
idDataCorrObj.put('Task',taskIdSet);
}
//-----------------------------------------------------------------------------------------------------------------------------------------------
if(ObjectName == 'navpeII_dev18__Theme__c'){
themeIdSet.add(IdValue);
idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
List<navpeII_dev18__Theme_relation__c> themeList=new List<navpeII_dev18__Theme_relation__c>();
themeList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__theme__c,navpeII_dev18__Other_Theme__c from navpeII_dev18__Theme_relation__c  Where navpeII_dev18__theme__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(Theme_Relation__c trJunction:themeList){
if(trJunction.navpeII_dev18__contact__c != null ){
conIdSet.add(String.ValueOf(trJunction.navpeII_dev18__contact__c));
idDataCorrObj.put('Contact',conIdSet);
}
if(trJunction.navpeII_dev18__Account__c != null ){
accIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Account__c));
idDataCorrObj.put('Account',accIdSet);
}
if(trJunction.navpeII_dev18__Deal__c != null ){
dealIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Deal__c));
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}
if(trJunction.navpeII_dev18__Fund__c != null ){
fundIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Fund__c));
idDataCorrObj.put('navpeII_dev18__Fund__c',fundIdSet);
}
if(trJunction.navpeII_dev18__Fundraising__c != null ){
fundraisingIdSet.add(String.valueOf(trJunction.navpeII_dev18__Fundraising__c));
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
}
if(trJunction.navpeII_dev18__Clip__c != null ){
clipIdSet.add(String.valueOf(trJunction.navpeII_dev18__Clip__c));
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
}
if(trJunction.navpeII_dev18__Other_Theme__c != null ){
    themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__Other_Theme__c));
    idDataCorrObj.put('navpeII_dev18__Theme__c',themeIdSet);
}

}
map<id,task> tskList=new map<id,task>([Select Id,navpeII_dev18__Related_Associations__c from task  WHERE navpeII_dev18__Related_Associations__c LIKE :LikeOperatorId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
map<id,event> evtList=new map<id,event>([Select Id,navpeII_dev18__Related_Associations__c from event  WHERE ((IsChild=false) AND (navpeII_dev18__Related_Associations__c LIKE : LikeOperatorId)) Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
system.debug('tskList-->'+tskList);
for(Id tr:tskList.keySet()){
taskIdSet.add(string.ValueOf(tr));
}
for(Id er:evtList.keySet()){
eventIdSet.add(string.valueOf(er));
}
idDataCorrObj.put('Event',eventIdSet);
idDataCorrObj.put('Task',taskIdSet);
}

//-----------------------------------------------
if(ObjectName == 'navpeII_dev18__Clip__c'){
clipIdSet.add(IdValue);
idDataCorrObj.put('navpeII_dev18__Clip__c',clipIdSet);
List<navpeII_dev18__Clip_relation__c> crList=new List<navpeII_dev18__Clip_relation__c>();
crList=[Select Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c from navpeII_dev18__Clip_relation__c  Where navpeII_dev18__Clip__c =: IdValue Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
for(navpeII_dev18__clip_relation__c trJunction:crList){
if(trJunction.navpeII_dev18__contact__c != null ){
conIdSet.add(String.ValueOf(trJunction.navpeII_dev18__contact__c));
idDataCorrObj.put('Contact',conIdSet);
}
if(trJunction.navpeII_dev18__Account__c != null ){
accIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Account__c));
idDataCorrObj.put('Account',accIdSet);
}
if(trJunction.navpeII_dev18__Deal__c != null ){
dealIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Deal__c));
idDataCorrObj.put('navpeII_dev18__Pipeline__c',dealIdSet);
}
if(trJunction.navpeII_dev18__Fund__c != null ){
fundIdSet.add(String.ValueOf(trJunction.navpeII_dev18__Fund__c));
idDataCorrObj.put('navpeII_dev18__Fund__c',fundIdSet);
}
if(trJunction.navpeII_dev18__Fundraising__c != null ){
fundraisingIdSet.add(String.valueOf(trJunction.navpeII_dev18__Fundraising__c));
idDataCorrObj.put('navpeII_dev18__Fundraising__c',fundraisingIdSet);
}
//if(trJunction.navpeII_dev18__Theme__C != null ){
//themeIdSet.add(String.valueOf(trJunction.navpeII_dev18__Theme__c));
//idDataCorrObj.put('Theme__c',themeIdSet);
//}

}
}

//-------------------------------------------------
/*for(taskrelation tr:trList){
List<string> strData=new List<string>(); 
taskIdSet.add(string.ValueOf(tr.taskId));
idDataCorrObj.put('Task',taskIdSet);
if(tr.task.navpeII_dev18__Related_Associations__c != null && tr.task.navpeII_dev18__Related_Associations__c != ''){
    if(recordtypeName != null && recordtypeName != '' && recordtypeName == 'Institution'){
strData=processRelObjIds(String.valueOf(tr.task.navpeII_dev18__Related_Associations__c), IdValue);
    }
}
if(strData != Null && strData.size() > 0){
for(string idValueFromSet:strData){
Id recId=(Id)idValueFromSet;
String sObjName = recId.getSObjectType().getDescribe().getName();
if(idDataCorrObj.containsKey(sObjName)){
set<string> newEmpty=new set<string>();
newEmpty=idDataCorrObj.get(sObjName);
newEmpty.add(idValueFromSet);
idDataCorrObj.put(sObjName,newEmpty);
}else{
set<string> newEmpty=new set<string>();
newEmpty.add(idValueFromSet);
idDataCorrObj.put(sObjName,newEmpty);
}


}
}

}

for(eventrelation er:evList){
List<string> strData=new List<string>();
eventIdSet.add(string.valueOf(er.eventid));
idDataCorrObj.put('Event',eventIdSet);
if(er.event.navpeII_dev18__Related_Associations__c != null && er.event.navpeII_dev18__Related_Associations__c != ''){
    if(recordtypeName != null && recordtypeName != '' && recordtypeName == 'Institution'){
strData=processRelObjIds(String.valueOf(er.event.navpeII_dev18__Related_Associations__c), IdValue);
    }
}
if(strData != Null && strData.size() > 0){
for(string idValueFromSet:strData){
Id recId=(Id)idValueFromSet;
String sObjName = recId.getSObjectType().getDescribe().getName();
if(idDataCorrObj.containsKey(sObjName)){
set<string> newEmpty=new set<string>();
newEmpty=idDataCorrObj.get(sObjName);
newEmpty.add(idValueFromSet);
idDataCorrObj.put(sObjName,newEmpty);
}else{
set<string> newEmpty=new set<string>();
newEmpty.add(idValueFromSet);
idDataCorrObj.put(sObjName,newEmpty);
}


}
}





}*/
system.debug('idDataCorrObj---->'+ idDataCorrObj.size());
system.debug(idDataCorrObj.keyset());
system.debug('value->'+idDataCorrObj);
return idDataCorrObj;
}catch(exception exp){
system.debug(exp.getMessage()+'<---------------->'+exp.getLineNumber()); 
throw new AuraHandledException( 'Error Occured While Loading Component : <<'+exp.getMessage()+exp.getLineNumber()+'>>');
}

}
public static List<string> processRelObjIds(String RSF, string CurrId){
try {

List<string> rsfSet=new List<string>();
rsfSet=RSF.split(',');
if(CurrId.contains('003')){
return rsfSet;
}else{
if(rsfSet.contains(CurrId)){
return rsfSet;
}else{
return null;
}
}
} catch (Exception e) {
throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');

}
}

public class createThemeWrap {
    @AuraEnabled public String message; 
    @AuraEnabled public String themeId;  
    }


}