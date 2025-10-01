/* 
New Implimentation:
Developer       :   Sameeksha Sahu
Project         :   Navigation & SDG 
Date            :   30/July/2019

Description     :   navigationType functionality added to categorised  all navigation record 
Developer       :   Aditya Sharma
Project         :   PE V4.7 
Date            :   20 April 2021

Description     :  Show up in Navigation Menu based on the enable/disable setting on Navatar 
                    Setup
Developer       :   Rahul Kumar Kasaundhan
Project         :   PE V4.7  
Date            :   22/June/2021
Description     :   This class will fetch all navigation record for Utility bar edge menu  
*/
public with sharing class navatarEdgeMenuCntlr{
    Public static map<String,String> mapRecordTypeNameToId = new map<String,String>(); 
    Public static map<String,String> mapListViewNameToId = new map<String,String>(); 
    Public static map<String,String> mapIdToUrl = new map<String,String>(); 
    
	//This method fetch all the parent and child label navigation record and return JSON to component
    @AuraEnabled
    public static responseWrapper getJson(String navigationType){ // addded parameter utilityType by Aditya PEv4.7 20 April 2021
		try{
			string strJson = '';
			List<Navigation> lstNavItems = new List<Navigation>();
			List<Navigation> lstChildNavItems = new List<Navigation>();
			Set<String> navSetuplist = new Set<String>();
			String key = '';
			
			//Create a map of sobject+record type name vs recordtypeid
			for(RecordType rt : [SELECT id,developerName,sobjecttype  FROM RecordType]){
				key = rt.sobjectType+'#'+rt.developerName;
				mapRecordTypeNameToId.put(key.toUpperCase(),rt.id);
			}
			//Create a map of sobject+list view name vs id
			for(ListView lv : [SELECT Id, DeveloperName, SobjectType FROM ListView]){
				key = lv.sobjectType+'#'+lv.developerName;
				mapListViewNameToId.put(key.toUpperCase(),lv.id);
			}
            
            //start changes for PEv4.7 by Aditya 26 April 2021
            //Added navigationTypeParent, removed else condition & modified if condition by Lakshya on 20210427 [PE v4.7]
            String navQuery = '';
            String strNavigationType = '';
            String navigationTypeParent = '';
            if(String.isNotBlank(navigationType)){
            	strNavigationType = 'WHERE Navigation_Type__c=\'' + String.escapeSingleQuotes(navigationType)+ '\'';
                navigationTypeParent = 'AND Navigation_Type__c=\'' + String.escapeSingleQuotes(navigationType) + '\'';
            }
			navSetuplist = getNavatarSettings(); //get list of page name with Like conditions by RahulK (22-06-2021)
            navQuery = 'SELECT id, Name, Order__c, URL__c, Quick_Create_Object__c, Quick_Create_Record_Type__c, List_View_Object__c, List_View_Name__c, Activities_Button_API_Name__c, Navigation_Type__c,(SELECT id, Name, Order__c, URL__c, Quick_Create_Object__c, Quick_Create_Record_Type__c, List_View_Object__c, List_View_Name__c, Activities_Button_API_Name__c, Navigation_Type__c FROM Parent__r '+ strNavigationType + ' AND (Not URL__c Like :navSetuplist) ORDER By Order__c nulls last) FROM Navigation__c WHERE parent__c = null ' + navigationTypeParent + ' AND (Not URL__c Like :navSetuplist) ORDER By Order__c nulls last';
            List<Navigation__c> navList = Database.query(navQuery);
            
            //end changes for PEv4.7 by Aditya 26 April 2021
            //Phase 3 CR changes: query the Activities_Button_API_Name__c field.
            for(Navigation__c objNav : navList)
			{
				Navigation navObj = new Navigation();
				navObj = updateNodeOnQuickCreate(objNav); 
				navObj.expanded = false;
				lstChildNavItems = new List<Navigation>();
				if(navObj.id!= null){
					for(Navigation__c objNavChild : objNav.Parent__r){
						Navigation navObjchild = updateNodeOnQuickCreate(objNavChild); 
						if(navObjchild.id != null)
							lstChildNavItems.add(navObjchild);
					}
					if(lstChildNavItems.size() > 0){
						navObj.nodes = lstChildNavItems;
					}else{
						navObj.nodes = new List<Navigation>();
					}
					lstNavItems.add(navObj);
                    
				}
			}
			responseWrapper objRes = new responseWrapper();
			objRes.jsonStr = JSON.serialize(lstNavItems).replace(',"nodes":[]','');
			objRes.mapIdToUrl = mapIdToUrl;
			return objRes;
		}
		catch(Exception ex) {
            System.debug('Exception....'+ex);
            return null;
        }
    }
    
	//This method prepare node id for tree and check record type is createable or not 
    private static Navigation updateNodeOnQuickCreate(Navigation__c objNav){
        String key = '';
        Navigation navLabel = new Navigation();
        //Check restrict parent action if child exists. Bug id:00028035
        
        if(String.isNotBlank(objNav.Quick_Create_Object__c) && String.isBlank(objNav.URL__c) && objNav.Parent__r.size() == 0){
            if(Schema.getGlobalDescribe().get(objNav.Quick_Create_Object__c)!= null && (Schema.getGlobalDescribe().get(objNav.Quick_Create_Object__c).getDescribe().isCreateable())){
                navLabel.text = '<span class=\'wordBlockClass\'>'+objNav.Name+'</span>';
                navLabel.id = 'create<@>' + objNav.Quick_Create_Object__c; 
                // Phase 3 CR changes: get the activity button api name.
				if(String.isNotBlank(objNav.Activities_Button_API_Name__c)){
                    navLabel.id += '<btnapi>' + objNav.Activities_Button_API_Name__c+'<objlbl>' +Schema.getGlobalDescribe().get('Task').getDescribe().getLabel(); 
                }				
                key = objNav.Quick_Create_Object__c+'#'+objNav.Quick_Create_Record_Type__c;
                if(String.isNotBlank(objNav.Quick_Create_Record_Type__c) && mapRecordTypeNameToId.containsKey(key.toUpperCase())){
                    navLabel.id += '<RT>' + mapRecordTypeNameToId.get(key.toUpperCase()); 
                }
            }
        }
        else{
            navLabel.text = '<span class=\'wordBlockClass\'>'+objNav.Name+'</span>';
            navLabel.id = objNav.id;
            
        }
        //Check to restrict parent action if child exists. Bug id:00028033
		if(objNav.Parent__r.size() ==0){
			if(String.isNotBlank(objNav.URL__c)){
				mapIdToUrl.put(objNav.id,objNav.URL__c);
			}
			else if(String.isNotBlank(objNav.List_View_Object__c) && String.isBlank(objNav.List_View_Name__c)){
				mapIdToUrl.put(objNav.id,'/lightning/o/'+objNav.List_View_Object__c+'/home');
			}
			else if(String.isNotBlank(objNav.List_View_Object__c) && String.isNotBlank(objNav.List_View_Name__c)){
				key = objNav.List_View_Object__c+'#'+objNav.List_View_Name__c;
				if(mapListViewNameToId.containsKey(key.toUpperCase())){
					mapIdToUrl.put(objNav.id,'/lightning/o/'+objNav.List_View_Object__c+'/list?filterName='+mapListViewNameToId.get(key.toUpperCase()));
				}
			}
		}
        return navLabel;
    }
	/*
	* @Description  : Returns list of page name with Like conditions where  Navatar settings is not enable
	* @Parameter    : No Parameter requreied for this 
    * @Develoepr    : RahulK (22-06-2021)
	*/
    public static set<string> getNavatarSettings(){
        Set<String> navSetuplist = new Set<String>(); 
        try {
            List<Org_Setting__mdt> lstORGmdt = new List<Org_Setting__mdt>();
			
					if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.IsActive__c.isAccessible() && 
					Schema.sObjectType.Org_Setting__mdt.Fields.DeveloperName.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.Label.isAccessible())
					{
						lstORGmdt = [SELECT Id, IsActive__c, DeveloperName, Label FROM Org_Setting__mdt  where IsActive__c = false LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
					}

					for(Org_Setting__mdt orgSetObj : lstORGmdt){ 
						if(orgSetObj.DeveloperName.toLowercase() == 'Bulk_Email_Setting'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility.strNameSpacePrefix+'Bulk_Email%'); 

						}
						else if(orgSetObj.DeveloperName.toLowercase() == 'Deal_Creation'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility.strNameSpacePrefix+'Deal_Creation%'); 
						}
						else if(orgSetObj.DeveloperName.toLowercase() == 'Ind_Inv_Creation'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility.strNameSpacePrefix+'IndividualInvestor%'); 
						}
						else if(orgSetObj.DeveloperName.toLowercase() == 'Commitment_Creation'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility.strNameSpacePrefix+'CommitmentCreation%');
						}
                        if(Test.isRunningTest()){
                            navSetuplist.add('%/apex/pem_dev__Deal_Creation%');
                        }
					}
            } 
            catch (Exception ex){
                system.debug('getNavatarSettings: Exception: ' +  ex.getLineNumber()+'--'+ex.getMessage() );
            }
        	System.debug('???navSetuplist???????'+navSetuplist);

        	return navSetuplist;

    } 
       
	//wrapper class for navigation
    public class Navigation
    {
        public string text;
        public boolean expanded;
        public List<Navigation> nodes;
        public string id;
    }
    
    public Class responseWrapper{
        @AuraEnabled public string jsonStr;
        @AuraEnabled public map<String,String> mapIdToUrl;
    }
}