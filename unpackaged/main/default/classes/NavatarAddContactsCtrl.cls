/*********************************************************************************

* @Class Name : NavatarAddContactsCtrl

* @Description : Select contact functionality for adding Firm's Contacts to the Theme

* @Organization : Navatar Group

* @Revision History:-

* @Version Date(YYYY-MM-DD)      Author     	Description of Action

* 1.0        2024-03-08          Lakshya        Acuity Phase 3

*********************************************************************************/
public with sharing class NavatarAddContactsCtrl {
	public static Map<String, Set<String>> objIdVsActIdsMap = new Map<String, Set<String>>();
	public static columnListWrapper clWrapper = new columnListWrapper();
	public static String quearyFieldsForContact;
	public static Map<String,List<String>> conIdVsInteractionId = new Map<String,List<String>>();
	public static String nSpace=[SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix+'__';

	// method is responsible to get the columns to display for Select and review contacts section
	@auraEnabled
	public static inviteResponse getNavatarSetupData() {
		inviteResponse res = new inviteResponse();
		try {
			String defaultString = 'AddInviteTarget:';
			String defaultString1 = 'AddInviteTarget:';
			String defaultString2 = 'AddInviteTarget:';
			Map<String, Schema.SObjectField> accFieldMap = Schema.SObjectType.Account.fields.getMap();
			Map<String, Schema.SObjectField> conFieldMap = Schema.SObjectType.Contact.fields.getMap();
			Map<String, Schema.SObjectField> conRoleFieldMap = Schema.SObjectType.navpeII_dev18__Fundraising_Contact__c.fields.getMap();
			//Added "Value__c != null" by LK on 2024-07-15 to fix 00046306
			List<Acuity_Setting__mdt> settingsList = [
				SELECT DeveloperName, Value__c
				FROM Acuity_Setting__mdt
				WHERE (DeveloperName LIKE 'Acuity_AddContacts_SearchG_Field%' OR DeveloperName LIKE '%Acuity_AddContacts_ReviewG_ThemeField%' OR DeveloperName LIKE '%Acuity_AddContacts_ReviewG_FundField%') AND (Value__c != null)
				ORDER BY DeveloperName ASC 
				Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()
			];
			for(Acuity_Setting__mdt conField : settingsList){
				String fieldDeveloperName = conField.DeveloperName;
				String value = conField.Value__c;
				
				if(fieldDeveloperName.startsWith('Acuity_AddContacts_SearchG_Field')){
					string localVar = '';
					if (value != 'Meetings') {
						localVar = String.valueOf(conField.value__c);
						Schema.DescribeFieldResult field;
						if (conFieldMap.containsKey(localVar)) {
							field = conFieldMap.get(localVar).getDescribe();
							defaultString += 'Contact:';
						} else {
							localVar = localVar.split('\\.').get(1);
							field = accFieldMap.get(localVar).getDescribe();
							defaultString += 'Account:';
						}
						defaultString += localVar + ':' + field.getLabel() + ':';
						if (String.valueOf(field.getType()) == 'PICKLIST') {
							defaultString += 'string:' + ',';
						} else {
							String s = field.getType() + '';
							defaultString += s.toLowerCase() + ',';
						}
					} else if (conField.value__c == 'Meetings') {
						defaultString += 'Custom:Meetings:#Meetings:Number' + ',';
					}
				}
				else if(fieldDeveloperName.startsWith('Acuity_AddContacts_ReviewG_ThemeField') && !fieldDeveloperName.startsWith('Acuity_AddContacts_ReviewG_FundField')
				){
					string localVar1 = '';
				if (conField.value__c != null) {
					localVar1 = String.valueOf(conField.value__c);
					Schema.DescribeFieldResult field;
					if (conFieldMap.containsKey(localVar1)) {
						field = conFieldMap.get(localVar1).getDescribe();
						defaultString1 += 'Contact:';
					} else {
						localVar1 = localVar1.split('\\.').get(1);
						field = accFieldMap.get(localVar1).getDescribe();
						defaultString1 += 'Account:';
					}

					defaultString1 += localVar1 + ':' + field.getLabel() + ':';
					if (String.valueOf(field.getType()) == 'PICKLIST') {
						defaultString1 += 'string:' + ',';
					} else {
						String s = field.getType() + '';
						defaultString1 += s.toLowerCase() + ',';
					}
				}
				}
				else if(fieldDeveloperName.startsWith('Acuity_AddContacts_ReviewG_FundField')){
					string localVar2 = '';
					if (conField.value__c != null) {
						localVar2 = String.valueOf(conField.value__c);
						Schema.DescribeFieldResult field;
						if (conFieldMap.containsKey(localVar2)) {
							field = conFieldMap.get(localVar2).getDescribe();
							defaultString2 += 'Contact:';
						} else if(accFieldMap.containsKey(localVar2)){
							localVar2 = localVar2.split('\\.').get(1);
							field = accFieldMap.get(localVar2).getDescribe();
							defaultString2 += 'Account:';
						}
						else if (conField.value__c == 'Account.Name') {
							localVar2 = localVar2.split('\\.').get(1);
							field = accFieldMap.get(localVar2).getDescribe();
							defaultString2 += 'Account:';
						}
						else {
							//localVar2 = localVar2.split('\\.').get(1);
							field = conRoleFieldMap.get(localVar2).getDescribe();
							defaultString2 += 'navpeII_dev18__Fundraising_Contact__c:';
						}
						defaultString2 += localVar2 + ':' + field.getLabel() + ':';
						
						if (String.valueOf(field.getType()) == 'PICKLIST') {
							defaultString2 += 'string:' + ',';
						} else {
							String s = field.getType() + '';
							defaultString2 += s.toLowerCase() + ',';
						}
						System.debug('default-->'+defaultString2);
					}
				}
			}
			res.defaultStringSearch = defaultString.removeEnd(',');
			res.namespacePrefix = nSpace;
			res.defaultStringReview = defaultString1.removeEnd(',');
			res.defaultStringDeal = defaultString2.removeEnd(',');
			res.status = 'success';
		} catch (Exception ex) {
			res.status = ex.getMessage() + '-' + ex.getStackTraceString();
		}
		return res;
	}

	// Method used to query records to show, it will work in case of Lazy Loading also
	/*
    mainQuery : - Query to Execute
    existingIdSet :- it will contains the Id of existing queried records, helpful in load more situation
    accountData : - Data of accounts related to Theme
    filterString :- Filter to be applied to the query
    */
	@auraEnabled
	public static inviteResponse getInitQuery(
		string mainQuery,
		list<String> existingIdSet,
		list<String> accountData,
		String filterString
		) {
		inviteResponse res = new inviteResponse();
		try {
			String refField1 = Acuity_Setting__mdt.getInstance('Acuity_AddContacts_SearchG_Field1').Value__c;
			String refField2 = Acuity_Setting__mdt.getInstance('Acuity_AddContacts_SearchG_Field2').Value__c;
			List<sobject> sobjResults = new List<sobject>(database.query(mainQuery));
			Map<String, SObject> conMap = new Map<String, SObject>(database.query(mainQuery));

			res.conMap = conMap;
			res.sobjResults = sobjResults; // new List<sobject>(database.query(mainQuery));
			Map<String, Integer> conWrap = prepareConFinalMap(accountData, res.sobjResults);
			List<Object> response = new List<object>();
			for (String k : conMap.keySet()) {
				String conMap2 = JSON.serialize(conMap.get(k));
				Map<String, Object> conMap1 = (Map<String, Object>) System.JSON.deserializeUntyped(conMap2);
				if (conWrap.containsKey(k)) {
					conMap1.put('Meetings', (Object) conWrap.get(k));
				}
				response.add(conMap1);
			}
			res.response = response;
			res.conInfoWrapper = conWrap;
			res.status = 'success';
			res.ConInteraction = conIdVsInteractionId;
		} catch (Exception Ex) {
			//Added ternary condition by Lakshya on 2021-12-16 to resolve 00030338
			//Before : res.status = Ex.getMessage();
			res.status = String.isBlank(filterString)
				? Ex.getMessage()
				: 'Your filter logic is imprecise or incorrect. Please use correct format for filter logic. e.g.- 1 AND 2 , 1 OR 2, (1 OR 2) AND 3 etc';
		}
		return res;
	}
	//Purpose : Gets Meeting info for particular contacts
	/*
	 *  accountData: Firms data selected while adding to theme
	 *  objs: list of Sobject for which meeting count is to be calculated
	 */
	public static Map<String, Integer> prepareConFinalMap(list<String> accountData, List<SObject> objs) {
		try {
			Map<String,Contact> conMap = new Map<String,Contact>([Select Id From Contact Where AccountId IN: accountData Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
			//List<Contact> cons = [SELECT Id, Name FROM Contact WHERE AccountId IN :accountData];
			List<String> conIds = new List<String>();
			conIds.addAll(conMap.keySet());
			Map<String, Integer> meetMp = new Map<String, Integer>();
			List<ConWrapper> conInfo = new List<ConWrapper>();
			processMeetingCallInfo(conIds, 'Event', ' WHERE RelationId IN :conIds AND Relation.Type = \'Contact\'');
			processMeetingCallInfo(conIds, 'Task', ' WHERE RelationId IN :conIds AND Relation.Type = \'Contact\' AND Task.TaskSubType = \'Call\'');	// changes #00041797,#00041926,#00042252 for bug #00041528 fixes by salauddin sheikh
			for (SObject conId : objs) {
				if (conId != null) {
					List<String> actIdList = new List<String>();
					Integer meetingCallCount = objIdVsActIdsMap.containsKey(String.valueOf(conId.get('id')))
						? objIdVsActIdsMap.get(String.valueOf((conId.get('id')))).size()
						: 0;

					meetMp.put(conId.Id, meetingCallCount);
					if (objIdVsActIdsMap.containsKey(String.valueOf(conId.get('id')))) {
						actIdList.addAll(objIdVsActIdsMap.get(String.valueOf(conId.get('id'))));
					}
					conIdVsInteractionId.put(conId.Id, actIdList);
				}
			}
			return meetMp;
		} catch (Exception e) {
			throw new AuraHandledException(
				'Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'
			);
		}
	}
	// this method is create the query on the basis of custom criteria.
	/*
	 *   getqueryjson: Advance Filter conditions.
	 *   pageName: Page Name for Advance Filter
	 *   FilterString: if Any Filter logic mentioned in Advance Filter
	 */
	@auraEnabled
	public static inviteResponse executeQuery1(string getqueryjson, string pageName, string FilterString) {
		inviteResponse res = new inviteResponse();
		try {
			res.status = 'success';
			list<selectioncriteria> selection1 = new List<selectioncriteria>();
			string Namespaceprefix1_new = '';
			string fnlquery = '';
			string fnlquery_contact = '';
			if (getqueryjson != null) {
				System.JSONParser parser = JSON.createParser(getqueryjson);
				selection1 = (list<selectioncriteria>) parser.readValueAs(list<selectioncriteria>.class); // Read the value and create a wrapper class list
				map<string, string> Criterialst = new Map<string, string>();
				clsOne_filter clsactivityobj = new clsOne_filter();
				string getrowContact = '';
				string getrowContactSRN = '';
				String fields = '';
				for (selectioncriteria criteria1 : selection1) {
					string fieldvalue = criteria1.field;
					list<string> fldlist = fieldvalue.split(':');

					if (fldlist[0] == 'Account') {
						switch on pageName{
							when 'CMF' {
								fields = 'Legal_Name__r.' + fldlist[1];
							} 
							when 'MEF' {
								fields = 'Contact__r.Account.' + fldlist[1];
							}
							when 'CMFC' {
								fields = 'Institution__r.' + fldlist[1];
							}
							when 'MI','CMFA' {
								fields = 'Account.' + fldlist[1];
							}
							when 'MEP' {
								fields = Namespaceprefix1_new + 'Contact__r.Account.' + fldlist[1];
							}
							when 'DAIT' {
								fields = Namespaceprefix1_new + 'Contact.Account.' + fldlist[1];
							}
							when 'DAIT_ConRole' {
								fields = Namespaceprefix1_new + 'Account__r.' + fldlist[1];
							}
							when 'DAIT_AccContactTab' {
								fields = 'Account.' + fldlist[1];
							}
						}
					} else if (fldlist[0] == 'Contact') {
						switch on pageName{
							when 'MI' {
								fields = 'Contact.' + fldlist[1];
							} 
							when 'CMF' ,'CMFA' {
								fields = fldlist[1];
							}
							when 'CMFC' {
								fields = 'Contact__r.' + fldlist[1];
							}
							when 'DAIT' {
								fields = 'Contact.' + fldlist[1];
							}
							when 'DAIT_ConRole' {
								fields = Namespaceprefix1_new + 'Contact__r.' + fldlist[1];
							}
							when 'DAIT_AccContactTab' {
								fields = 'Contact.' + fldlist[1];
							}
							when 'MEP' {
								fields = Namespaceprefix1_new + 'Contact__r.' + fldlist[1];
							}
							when else {
								fields = 'Contact__r.' + fldlist[1];
							}
						}
					}

					if (criteria1.Value == null) {
						criteria1.Value = '';
					}

					string getrow = '';
					if (fldlist[3].toUpperCase() == 'REFERENCE')
						getrow = clsactivityobj.operatorOperation(
							fields,
							fldlist[3].toUpperCase(),
							criteria1.Operator,
							criteria1.Value,
							string.valueof(UserInfo.getLocale())
						);
						else if((fldlist[3].toUpperCase() == 'PICKLIST'|| fldlist[3].toUpperCase() == 'MULTIPICKLIST') && (criteria1.Operator == 'IN:' || criteria1.Operator == 'NOT IN:') ){ // #00042408 added filter fixes by salauddin sheikh
							string op = '';
							if(criteria1.Operator == 'IN:'){
								op = '=';
							}
							else{
								op= '!=';
							}
							getrow = clsactivityobj.operatorOperation(
							fields,
							fldlist[3].toUpperCase(),
							op,
							criteria1.Value,
							string.valueof(UserInfo.getLocale())
						);
						}
					else
						getrow = clsactivityobj.operatorOperation(
							fields,
							fldlist[3].toUpperCase(),
							criteria1.Operator,
							criteria1.Value,
							string.valueof(UserInfo.getLocale())
						);

					Boolean isTaskApp = false;

					if (!isTaskApp) {
						Criterialst.put(criteria1.serialnumber, getrow);
					}
				}
				//Updated by Qadir Khan on 03-April-2017
				if (FilterString != '' || Test.isRunningTest()) {
					set<string> num = new Set<String>{ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' };
					list<string> filterlogiclist = FilterString.split(',');
	

					for (integer i = 0; i < filterlogiclist.size(); i++) {
						if (num.contains(filterlogiclist[i])) {
							if (pageName == 'DAIT') {
								if (!String.isBlank(fnlquery)) {
									fnlquery = fnlquery + ' ' + Criterialst.get(filterlogiclist[i]);
								} else {
									fnlquery = Criterialst.get(filterlogiclist[i]);
								}
							} else {
								if (Criterialst.get(filterlogiclist[i]).contains('Contact')) {
									if (!String.isBlank(fnlquery_contact)) {
										fnlquery_contact = fnlquery_contact + ' ' + Criterialst.get(filterlogiclist[i]);
									} else {
										fnlquery_contact = Criterialst.get(filterlogiclist[i]);
									}
								} else {
									if (!String.isBlank(fnlquery)) {
										fnlquery = fnlquery + ' ' + Criterialst.get(filterlogiclist[i]);
									} else {
										fnlquery = Criterialst.get(filterlogiclist[i]);
									}
								}
							}
							if (fnlquery_contact != '' && fnlquery != '') {
								fnlquery = fnlquery + ' @@@@ ' + fnlquery_contact;
							} else {
								fnlquery = fnlquery;
							}
						} else {
							fnlquery = fnlquery + ' ' + filterlogiclist[i];
						}
					}
				} else {
					for (string s1 : Criterialst.keyset()) {
						if (pageName != 'DAIT') {
							if (!String.isBlank(fnlquery)) {
								fnlquery = fnlquery + ' OR ' + Criterialst.get(s1); // bug #00041207 fixes by salauddin sheikh
							} else {
								fnlquery = Criterialst.get(s1);
							}
						} else {
							if (Criterialst.get(s1).contains('Contact')) {
								if (!String.isBlank(fnlquery_contact)) {
									fnlquery_contact = fnlquery_contact + ' OR ' + Criterialst.get(s1); // bug #00041207 fixes by salauddin sheikh
								} else {
									fnlquery_contact = Criterialst.get(s1);
								}
							} else {
								if (!String.isBlank(fnlquery)) {
									fnlquery = fnlquery + ' OR ' + Criterialst.get(s1);	// bug #00041207 fixes by salauddin sheikh
								} else {
									fnlquery = Criterialst.get(s1);
								}
							}
						}
					}
					//Modified by Anshika Ahuja as filter was not working if criteria starts from Contact object
					if (fnlquery_contact != '' && fnlquery == '') {
						fnlquery = fnlquery_contact;
					}
					//Modification ended Anshika Ahuja
					if (fnlquery_contact != '' && fnlquery != '') {
						fnlquery = fnlquery + ' @@@@ ' + fnlquery_contact;
					} else {
						fnlquery = fnlquery;
					}
				}
				res.whereClause = fnlquery;
			}
		} catch (Exception Ex) {
			res.status = Ex.getMessage() + ' - ' + Ex.getStackTraceString();
		}
		return res;
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
    public static string addToThemeRecord(boolean addAllContactForEachFirm,string themeIdValue, list<string> accountList , list<string> contactList , list<string> dealList , list<string> fundList , list<string> fundraisingList , list<string> themeList , list<string> clipList, list<string> interactionList  ){   //changes for new research functionality on 27-03-2023 by Salauddin Sheikh
		try{
		// LWC COMMING DATA'S MAP  for Matching 
		List<String> messageToDisplay = new List<String>();
		map<string,list<string>> mapOfLWCThemeRelationRespObject=new map<string,list<string>>();
		mapOfLWCThemeRelationRespObject.put('Account',accountList);
		mapOfLWCThemeRelationRespObject.put('Contact',contactList);
		mapOfLWCThemeRelationRespObject.put('Fund',fundList);   //Change Fund to Deal by Salauddin Sheikh
		mapOfLWCThemeRelationRespObject.put('Target',fundraisingList); //Change FundRaising to Target by Salauddin Sheikh
		mapOfLWCThemeRelationRespObject.put('Clip',clipList);
		mapOfLWCThemeRelationRespObject.put('Theme',themeList);
		if(interactionList != null){    //changes for new research functionality on 27-03-2023 by Salauddin Sheikh
			for(string str:interactionList){
			if(str.startsWith('00T')){
				mapOfLWCThemeRelationRespObject.put('Task',interactionList);
			}else{
				mapOfLWCThemeRelationRespObject.put('Event',interactionList);
			}
			}
		}
		if(mapOfLWCThemeRelationRespObject.containsKey('Task')){    //changes for new research functionality on 27-03-2023 by Salauddin Sheikh
			boolean flagForTask=false;
			List<Task> taskList=new List<Task>();
			taskList=[Select Id ,navpeII_dev18__Related_Associations__c From Task Where Id In: mapOfLWCThemeRelationRespObject.get('Task') Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
			//Start changes for new research functionality from 11th april code by Salauddin Sheikh
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
		
		if(mapOfLWCThemeRelationRespObject.containsKey('Event')){   //changes for new research functionality on 27-03-2023 by Salauddin Sheikh
			boolean flagForEvent=false;
			List<Event> eventList=new List<Event>();
			eventList=[Select Id ,navpeII_dev18__Related_Associations__c From Event Where Id In: mapOfLWCThemeRelationRespObject.get('Event') Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
			for(Event evtData:eventList){
				string updatedRelatedAssociationIds='';
				
				
				if(evtData.navpeII_dev18__Related_Associations__c != null && evtData.navpeII_dev18__Related_Associations__c != ''){
					if(evtData.navpeII_dev18__Related_Associations__c.indexOf(themeIdValue) == -1){
					updatedRelatedAssociationIds=evtData.navpeII_dev18__Related_Associations__c+','+themeIdValue;
					}
				}else{
					updatedRelatedAssociationIds=themeIdValue;
				}
				
				evtData.navpeII_dev18__Related_Associations__c=updatedRelatedAssociationIds;
				
				flagForEvent=true;
			}
			if(flagForEvent){
				update eventList;
			}
			
		}
		//End changes for new research functionality from 11th april code by Salauddin Sheikh
		//---------------------------------------------------------------------------------------------------------------------------------------------------------------
		Boolean isInserted = false;
		List<navpeII_dev18__Theme_Relation__c> themeRelationList = new List<navpeII_dev18__Theme_Relation__c>();
		List<navpeII_dev18__Theme_Relation__c> newThemeRelationList = new List<navpeII_dev18__Theme_Relation__c>();
		string currThemeId=themeIdValue;
		
		list<string> accId=new list<string>();
		list<string> conId=new list<string>();
		list<string> dealId=new list<string>();
		list<string> fundId=new list<string>();
		list<string> fundraisingId=new list<string>();
		list<string> clipId=new list<string>(); 
		list<string> themeId=new list<string>();
		if(currThemeId != null && currThemeId != ''){ 
			Integer forLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
		String query = 'Select Id,'+nSpace+'Contact__c,'+nSpace+'Account__c,'+nSpace+'Fund__c,'+nSpace+'Fundraising__c,'+nSpace+'Clip__c,'+nSpace+'theme__c from  '+nSpace+'Theme_Relation__c Where '+nSpace+'theme__c =: currThemeId Limit ' + forLimit; //Changes Fund__c to Deal__c, Fundraising__c to Target__c by Salauddin Sheikh
		list<navpeII_dev18__Theme_Relation__c> trDataList=new list<navpeII_dev18__Theme_Relation__c>();
		trDataList=Database.query(query);
		
		
		if(trDataList.size() > 0){
		
		
		for(navpeII_dev18__Theme_Relation__c trJunction:trDataList){
		if(trJunction.navpeII_dev18__contact__c != null ){
		conId.add(trJunction.navpeII_dev18__contact__c);
		}
		if(trJunction.navpeII_dev18__Account__c != null ){
		accId.add(trJunction.navpeII_dev18__Account__c);
		}
		// Commented Code refering to object navpeII_dev18__Pipeline__c by Salauddin Sheikh
		/*if(trJunction.Deal__c != null ){
		dealId.add(trJunction.Deal__c);
		}*/
		
		//Change Fund__c to Deal__c by Salauddin Sheikh
		if(trJunction.navpeII_dev18__Fund__c != null ){
		fundId.add(trJunction.navpeII_dev18__Fund__c);
		}
		//Change Fundraising__c to Target__c by Salauddin Sheikh
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
		//mapOfRefIdCorTheme.put('Deal',dealId);    // Commented Code refering to object navpeII_dev18__Pipeline__c by Salauddin Sheikh
		mapOfRefIdCorTheme.put('Fund',fundId);      //Change Fund to Deal by Salauddin Sheikh
		mapOfRefIdCorTheme.put('Target',fundraisingId);     //Change FundRaising to Target by Salauddin Sheikh
		mapOfRefIdCorTheme.put('Clip',clipId);
		mapOfRefIdCorTheme.put('Theme',themeId);
		//=========================================================================================================================================================
		
		
		for(string str:mapOfLWCThemeRelationRespObject.keySet()){
		for(string IdFromLwc:mapOfLWCThemeRelationRespObject.get(str)){
		if(str != 'Task' && str!='Event'){ //for bug #00039206 fixes by Salauddin Sheikh
			//System.debug(mapOfRefIdCorTheme.get(str).contains(IdFromLwc));
			
		if(!mapOfRefIdCorTheme.get(str).contains(IdFromLwc)){
			navpeII_dev18__Theme_Relation__c tr=new navpeII_dev18__Theme_Relation__c();
		if(str == 'Account'){
		
		tr.navpeII_dev18__Account__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}else if(str == 'Contact'){
		
		tr.navpeII_dev18__Contact__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}
		//Changes Fund__c to Deal__c And Fund to Deal by Salauddin Sheikh
		else if(str == 'Fund'){
		
		tr.navpeII_dev18__Fund__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}
		//Changes FundRaising__c to Target__c And FundRaising to Target by Salauddin Sheikh
		else if(str == 'Fundraising'){
		
		tr.navpeII_dev18__Fundraising__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}else if(str == 'Clip'){
		
		tr.navpeII_dev18__Clip__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}else if(str == 'Theme'){
		
		tr.navpeII_dev18__Other_Theme__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()){
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
			//System.debug('inside else-->'+IdFromLwc);
			navpeII_dev18__Theme_Relation__c tr=new navpeII_dev18__Theme_Relation__c();
		if(str == 'Account'){
		
		tr.navpeII_dev18__Account__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}else if(str == 'Contact'){
		
		tr.navpeII_dev18__Contact__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}
		//Changes Fund__c to Deal__c And Fund to Deal by Salauddin Sheikh
		else if(str == 'Fund'){
		
		tr.navpeII_dev18__Fund__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}
		//Changes FundRaising__c to Target__c And FundRaising to Target by Salauddin Sheikh
		else if(str == 'Fundraising'){
		
		tr.navpeII_dev18__Fundraising__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}else if(str == 'Clip'){
		
		tr.navpeII_dev18__Clip__c=IdFromLwc;
		tr.navpeII_dev18__Theme__c = currThemeId;
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		}
		else if(str == 'Theme'){
		
			tr.navpeII_dev18__Other_Theme__c=IdFromLwc;
			tr.navpeII_dev18__Theme__c = currThemeId;
			if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Other_Theme__c.isCreateable()){
			newThemeRelationList.add(tr);
			}
		}
		
		}
		}
		
		}   
		//Updated msg by LK on 2024-05-10 to fix 00045610
		String messageData = 'Contact(s) was associated with the Theme.'; // modified message for bug #00042205 fixes by salauddin sheikh
		messageToDisplay.add(messageData);
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
		//system.debug('Ehatsham tr list data -->'+tr);
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
		newThemeRelationList.add(tr);
		}
		
		}
		}
		String messageData = 'All Contact was successfully added to your Theme.';
		messageToDisplay.add(messageData);
		}
		if(newthemeRelationList.size()>0){
			//System.debug('relation-->'+newthemeRelationList);
		
		if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isCreateable()){
			//if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Other_Theme__c.isCreateable()  && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Contact__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Theme__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Fundraising__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Fund__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Deal__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.Account__c.isCreateable()){
				if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Theme__c.isCreateable()){
		insert newThemeRelationList; 
		String messageData='Contact was successfully added to your Theme.';
		
		System.debug(messageToDisplay);
		return messageToDisplay[0];
			}else{
			String messageData=' Error - Field level permission is not availible on navpeII_dev18__Theme_Relation__c object ';
		return messageData;
			}
		
		}else{
			String messageData='You do not have permission to edit the records. Please contact your Navatar Administrator.';
			return messageData;
		}
		
		
		}else{
		String messageData='Theme is related to selected categories.';	// modified message for bug #00042205 fixes by salauddin sheikh
		messageToDisplay.add(messageData);
		System.debug(messageToDisplay);
		return messageToDisplay[0];
		
		}
		
		}catch(exception e ){
		string message='Error Occured While Loading Component : <<'+e.getMessage()+'>>';
		return message;
		}
    }
	
	//* this method is uded Processes info for meetings
	/*
	 * conIda : contact ids
	 * objeName: event or task
	 * whereClause: condition
	 */
	public static void processMeetingCallInfo(List<String> conIds, String objName, String whereClause) {
		try {
			//Modified the for loop on 2022-10-06 to fix the Assigned To issue
			Integer forLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
			String isWhatClause3 = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsWhat') != null) ? ' ,IsWhat ' : '';
			//System.debug('event relation-->'+(Schema.getGlobalDescribe().get('EventRelation') != null));
			//System.debug('task relation-->'+(Schema.getGlobalDescribe().get('TaskRelation') != null));
			if((Schema.getGlobalDescribe().get('EventRelation') != null) && (Schema.getGlobalDescribe().get('TaskRelation') != null)){ 
			for (sObject actRec : Database.query('SELECT Id, OwnerId, (SELECT RelationId FROM ' + objName + 'Relations' + whereClause + ') FROM ' +objName+ ' Limit ' + forLimit)
			) {
				//System.debug('check--->'+actRec.getSObjects(objName + 'Relations'));
				for (sObject actRelRec : actRec.getSObjects(objName + 'Relations')) {
					processRelObjIds(String.valueOf(actRelRec.get('RelationId')), String.valueOf(actRec.get('Id')));
				}
			}
		}
		} catch (Exception e) {
			throw new AuraHandledException(
				'Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'
			);
		}
	}
	//Method to Map related object along side activity IDs set
	/*
	 * ids  :    [Related Object IDs to be processed]
	 * actId  :  [Activity ID to be mapped]
	 *
	 */
	public static void processRelObjIds(String ids, ID actId) {
		try {
			for (String recId : ids.split(',')) {
				Set<String> idSet = new Set<String>();
				if (objIdVsActIdsMap.containsKey(recId)) {
					idSet = objIdVsActIdsMap.get(recId);
				} else {
					idSet = new Set<String>();
				}
				idSet.add(actId);
				objIdVsActIdsMap.put(recId, idSet);
			}
		} catch (Exception e) {
			throw new AuraHandledException(
				'Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'
			);
		}
	}

	
	public class selectioncriteria { // class for selection criteria
		public string serialnumber { get; set; }
		public string field { get; set; }
		public string Operator { get; set; }
		public string Value { get; set; }
	}

	public class inviteResponse {
		@auraEnabled
		public string status;
		@auraEnabled
		public string whereClause;
		@auraEnabled
		public string defaultStringSearch;
		@auraEnabled
		public string defaultStringReview;
		@AuraEnabled
		public string defaultStringDeal;
		@auraEnabled
		public string nameSpacePrefix;
		@auraEnabled
		public list<sobject> sobjResults;
		@auraEnabled
		public list<object> response;
		@AuraEnabled
		public Map<String, Integer> conInfoWrapper;
		@AuraEnabled
		public Map<String, SObject> conMap;
		@AuraEnabled
		public Map<String, String> objectLabelMap;
		@AuraEnabled
		public Map<String, String> objectPluMap;
		@AuraEnabled
		public Map<String,List<String>> ConInteraction;
	}
	public class wrapperforColumn { // internal structure of the column wrapper list
		@AuraEnabled
		public string fieldName;
		@AuraEnabled
		public string fieldLabel;
		@AuraEnabled
		public string fieldType;
	}
	public class columnListWrapper {
		// for columns ---------------------> for maintaing the dynamic column as per user willing
		@AuraEnabled
		public List<wrapperforColumn> contactListColumns = new List<wrapperforColumn>();
		@AuraEnabled
		public List<String> objectAccessList = new List<String>();
		@AuraEnabled
		public String errorMessage;
	}
	public class ConWrapper {
		@AuraEnabled
		public String recId; //Record ID
		@AuraEnabled
		public String Name; //Record Name
		@AuraEnabled
		public Integer meetingCallCount; //Meeting Call count
		@AuraEnabled
		public String AccountId;
		@AuraEnabled
		public String Account;
		@AuraEnabled
		public String Name_Account;
		@AuraEnabled
		public String Name_Account_label;
		@AuraEnabled
		public String Name_Contact;
		@AuraEnabled
		public String Name_Contact_label;
		@AuraEnabled
		public String Title;
		@AuraEnabled
		public String Title_Contact;
		@AuraEnabled
		public String Type_Account;
		@AuraEnabled
		public Date touchPoint;
		// @AuraEnabled public Date navpeII_dev18__Last_Touch_Point__c_Contact;
	}
}