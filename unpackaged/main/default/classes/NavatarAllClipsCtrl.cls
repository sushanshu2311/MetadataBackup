/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle All Clips Page 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Hema
****************************************************************************************************/
public with sharing class NavatarAllClipsCtrl
 {
  public static map<string,string> iconNameMap=new map<string,string>();
  public static List<String> sobjectList =  new List<String>{ 'Account', 'Contact', 'navpeII_dev18__Pipeline__c', 'navpeII_dev18__Fund__c', 'navpeII_dev18__Fundraising__c', 'navpeII_dev18__Theme__c', 'User'}; //Modified by Hema 19-04-2023
      @AuraEnabled
    public static List<AllClipsPageWrapper> getAllClipsRecords(List<String> clipsIdList){
        try{
        
        List<AllClipsPageWrapper> clipsWrapperList = new List<AllClipsPageWrapper>();
        if(schema.sobjecttype.Clip__c.isaccessible()){
        getObjIconNames();       
        AllClipsPageWrapper clipRecWrapper = new AllClipsPageWrapper();
        
        String clipField1 = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field1').Value__c;
        String clipField2 = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field2').Value__c;     
         
         List<Sobject> sobjList = new List<Sobject>();
           if(clipsIdList.size()>0 && clipsIdList != Null){ 
               List<String> recordIdList = clipsIdList;
               sobjList = NavatarAllThemesCtrl.fetchSObjectData(clipField1,clipField2,'','','','','Notes__c,CreatedDate,CreatedBy.Name,(SELECT User__r.Name,Deal__r.Name,Fundraising__r.Name,Fund__r.Name,Account__r.Name,Contact__r.Name FROM Clip_Relations__r),(SELECT Theme__r.Name,Clip__r.Name FROM Theme_Relations__r WHERE Clip__c != Null )','Clip__c',' WHERE ID IN: recordIdList',recordIdList,' ORDER BY CreatedDate DESC LIMIT 49990'); 
           }
            else{
            sobjList= NavatarAllThemesCtrl.fetchSObjectData(clipField1,clipField2,'','','','','Notes__c,CreatedDate,CreatedBy.Name,(SELECT User__r.Name,Deal__r.Name,Fundraising__r.Name,Fund__r.Name,Account__r.Name,Contact__r.Name FROM Clip_Relations__r),(SELECT Theme__r.Name,Clip__r.Name FROM Theme_Relations__r WHERE Clip__c != Null )','Clip__c','',clipsIdList,' ORDER BY CreatedDate DESC LIMIT 49990'); 
            }    
         
            for(sObject clipRec :sobjList){
                Map<String,List<NavatarAcuityCtrl.ReferenceWrapper>> clipsRefMap = new Map<String,List<NavatarAcuityCtrl.ReferenceWrapper>>(); 
            Map<String,List<ClipsTagReference>> clipsTagsMap = new Map<String,List<ClipsTagReference>>(); 
            List<String> clipRelationList = new List<String>();
            Map<String,List<String>> clipRelationMap = new  Map<String,List<String>>();
            List<NavatarAcuityCtrl.ReferenceWrapper>  refWrapperList = new List<NavatarAcuityCtrl.ReferenceWrapper>();
            String strClipsTagsPDF='';
            Integer index=0;
            List<ClipsTagReference> clipRefList = new List<ClipsTagReference>();
            ClipsTagReference clipRef = new ClipsTagReference();
            AllClipsPageWrapper tempRec = clipRecWrapper.clone();
                
            tempRec.Id = String.valueOf(clipRec.get('Id'));
            tempRec.Name = String.valueOf(clipRec.get(clipField1));
            tempRec.Summary  =  NavatarAllThemesCtrl.checkCreateableFields( Schema.sObjectType.Clip__c.getsObjectType(), new List<String>{clipField2}) ? String.valueOf(clipRec.get(clipField2)) : ''; 
            tempRec.Notes =  NavatarAllThemesCtrl.checkCreateableFields( Schema.sObjectType.Clip__c.getsObjectType(), new List<String>{'navpeII_dev18__Notes__c'}) ? String.valueOf(clipRec.get('navpeII_dev18__Notes__c')) : '';
            tempRec.CreatedBy  = (String)clipRec.getSobject('CreatedBy').get('Name');
             Datetime clipValue = Datetime.valueOf(clipRec.get('CreatedDate'));
            Date clipDate = date.newinstance(clipValue.year(), clipValue.month(), clipValue.day());    
            tempRec.CreatedDate  = String.valueOf(clipDate.format());
                
                if(schema.sobjecttype.Clip_Relation__c.isaccessible()){
                if(clipRec.getSObjects('Clip_Relations__r') != null && clipRec.getSObjects('Clip_Relations__r').size()>0){
                    for(Clip_Relation__c clipRel :clipRec.getSObjects('Clip_Relations__r')){
                        if(clipRel != null){
                               
                NavatarAcuityCtrl.ReferenceWrapper  tempRefWrapper =new NavatarAcuityCtrl.ReferenceWrapper() ;
				//Modified by Hema W.R.T Security Fix - 00039930	
                if( clipRel.Account__r.Name != null){
                    tempRefWrapper = getRefData(clipRel.Account__r.Name,iconNameMap.get(String.valueOf(clipRel.Account__r.Id.getsobjecttype())),clipRel.Account__r.Id);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,clipRel.Account__r.Name,'/'+clipRel.Account__r.Id,iconNameMap.get(String.valueOf(clipRel.Account__r.Id.getsobjecttype())));
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+clipRel.Account__r.Name);
                      refWrapperList.add(tempRefWrapper);
                     if(clipsRefMap.containsKey(String.valueOf(clipRel.Account__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(clipRel.Account__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(clipRel.Account__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                     
                      if(clipRelationMap.containsKey(String.valueOf(clipRel.Account__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(clipRel.Account__r.Id.getsobjecttype())).add(clipRel.Account__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(clipRel.Account__r.Id.getsobjecttype()),new List<String>{clipRel.Account__r.Name});

                     }
                     
                      if(clipsTagsMap.containsKey(String.valueOf(clipRel.Account__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(clipRel.Account__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(clipRel.Account__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }
                     
                    
                }
				//Modified by Hema W.R.T Security Fix - 00039930	
                if( clipRel.Contact__r.Name != null){
                    tempRefWrapper = getRefData(clipRel.Contact__r.Name,iconNameMap.get(String.valueOf(clipRel.Contact__r.Id.getsobjecttype())),clipRel.Contact__r.Id);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,clipRel.Contact__r.Name,'/'+clipRel.Contact__r.Id,iconNameMap.get(String.valueOf(clipRel.Contact__r.Id.getsobjecttype())));
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+clipRel.Contact__r.Name);
                      refWrapperList.add(tempRefWrapper);
                     if(clipsRefMap.containsKey(String.valueOf(clipRel.Contact__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(clipRel.Contact__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(clipRel.Contact__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                    
                     if(clipRelationMap.containsKey(String.valueOf(clipRel.Contact__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(clipRel.Contact__r.Id.getsobjecttype())).add(clipRel.Contact__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(clipRel.Contact__r.Id.getsobjecttype()),new List<String>{clipRel.Contact__r.Name});

                     }
                    if(clipsTagsMap.containsKey(String.valueOf(clipRel.Contact__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(clipRel.Contact__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(clipRel.Contact__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }
                }
				//Modified by Hema W.R.T Security Fix- 00039930	
                if(clipRel.Deal__r.Name != null){
                    tempRefWrapper = getRefData(clipRel.Deal__r.Name,iconNameMap.get(String.valueOf(clipRel.Deal__r.Id.getsobjecttype())),clipRel.Deal__r.Id);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,clipRel.Deal__r.Name,'/'+clipRel.Deal__r.Id,iconNameMap.get(String.valueOf(clipRel.Deal__r.Id.getsobjecttype())));
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+clipRel.Deal__r.Name);
                     refWrapperList.add(tempRefWrapper);
                    
                     if(clipsRefMap.containsKey(String.valueOf(clipRel.Deal__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(clipRel.Deal__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(clipRel.Deal__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                    
                     if(clipRelationMap.containsKey(String.valueOf(clipRel.Deal__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(clipRel.Deal__r.Id.getsobjecttype())).add(clipRel.Deal__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(clipRel.Deal__r.Id.getsobjecttype()),new List<String>{clipRel.Deal__r.Name});

                     }
                     if(clipsTagsMap.containsKey(String.valueOf(clipRel.Deal__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(clipRel.Deal__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(clipRel.Deal__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }
                }
				//Modified by Hema W.R.T Security Fix- 00039930	
                if( clipRel.Fund__r.Name != null){
                    tempRefWrapper = getRefData(clipRel.Fund__r.Name,iconNameMap.get(String.valueOf(clipRel.Fund__r.Id.getsobjecttype())),clipRel.Fund__r.Id);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,clipRel.Fund__r.Name,'/'+clipRel.Fund__r.Id,iconNameMap.get(String.valueOf(clipRel.Fund__r.Id.getsobjecttype())));
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+clipRel.Fund__r.Name);
                      refWrapperList.add(tempRefWrapper);
                     
                      if(clipsRefMap.containsKey(String.valueOf(clipRel.Fund__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(clipRel.Fund__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(clipRel.Fund__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                     
                     if(clipRelationMap.containsKey(String.valueOf(clipRel.Fund__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(clipRel.Fund__r.Id.getsobjecttype())).add(clipRel.Fund__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(clipRel.Fund__r.Id.getsobjecttype()),new List<String>{clipRel.Fund__r.Name});

                     }
                     if(clipsTagsMap.containsKey(String.valueOf(clipRel.Fund__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(clipRel.Fund__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(clipRel.Fund__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }
                }
				//Modified by Hema W.R.T Security Fix- 00039930	
                if( clipRel.Fundraising__r.Name != null){
                    tempRefWrapper = getRefData(clipRel.Fundraising__r.Name,iconNameMap.get(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype())),clipRel.Fundraising__r.Id);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,clipRel.Fundraising__r.Name,'/'+clipRel.Fundraising__r.Id,iconNameMap.get(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype())));
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+clipRel.Fundraising__r.Name);
                      refWrapperList.add(tempRefWrapper);
                      if(clipsRefMap.containsKey(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                     
                      if(clipRelationMap.containsKey(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype())).add(clipRel.Fundraising__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype()),new List<String>{clipRel.Fundraising__r.Name});

                     }
                      if(clipsTagsMap.containsKey(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(clipRel.Fundraising__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }
                }
				//Modified by Hema W.R.T Security Fix- 00039930
                if( clipRel.User__r.Name != null){
                    tempRefWrapper = getRefData(clipRel.User__r.Name,'standard:user',null);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,clipRel.User__r.Name,null,'standard:user');
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+clipRel.User__r.Name);
                     refWrapperList.add(tempRefWrapper);
                      if(clipsRefMap.containsKey(String.valueOf(clipRel.User__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(clipRel.User__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(clipRel.User__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                     if(clipRelationMap.containsKey(String.valueOf(clipRel.User__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(clipRel.User__r.Id.getsobjecttype())).add(clipRel.User__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(clipRel.User__r.Id.getsobjecttype()),new List<String>{clipRel.User__r.Name});

                     }
                     if(clipsTagsMap.containsKey(String.valueOf(clipRel.User__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(clipRel.User__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(clipRel.User__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }
                     
                 }
                        }          
                    }
                }
                }
				
                if(schema.sobjecttype.Theme_Relation__c.isaccessible()){
                if(clipRec.getSObjects('Theme_Relations__r') != null && clipRec.getSObjects('Theme_Relations__r').size()>0){
                    for(Theme_Relation__c themeRel :clipRec.getSObjects('Theme_Relations__r')){
					//Modified by Hema W.R.T Security Fix- 00039930	
                if( themeRel.Theme__r.Name != null){
                             NavatarAcuityCtrl.ReferenceWrapper  tempRefWrapper =new NavatarAcuityCtrl.ReferenceWrapper() ;
                    /* Added by Hema - To return the theme icon - 00035142*/
                    tempRefWrapper = getRefData(themeRel.Theme__r.Name,'custom:custom100',themeRel.Theme__r.Id);
                    ClipsTagReference clipTempRec = clipRef.clone();
                    clipTempRec = getClipRefData(index++,themeRel.Theme__r.Name,'/'+themeRel.Theme__r.Id,'custom:custom100');
                    clipRefList.add(clipTempRec);
                    strClipsTagsPDF+=(', '+themeRel.Theme__r.Name);
                     refWrapperList.add(tempRefWrapper);
                     if(clipsRefMap.containsKey(String.valueOf(themeRel.Theme__r.Id.getsobjecttype()))){
                         clipsRefMap.get(String.valueOf(themeRel.Theme__r.Id.getsobjecttype())).add(tempRefWrapper);
                     }
                     else{
                         clipsRefMap.put(String.valueOf(themeRel.Theme__r.Id.getsobjecttype()),new List<NavatarAcuityCtrl.ReferenceWrapper>{tempRefWrapper});

                     }
                     if(clipRelationMap.containsKey(String.valueOf(themeRel.Theme__r.Id.getsobjecttype()))){
                         clipRelationMap.get(String.valueOf(themeRel.Theme__r.Id.getsobjecttype())).add(themeRel.Theme__r.Name);
                     }
                     else{
                         clipRelationMap.put(String.valueOf(themeRel.Theme__r.Id.getsobjecttype()),new List<String>{themeRel.Theme__r.Name});

                     }
                    
                    if(clipsTagsMap.containsKey(String.valueOf(themeRel.Theme__r.Id.getsobjecttype()))){
                         clipsTagsMap.get(String.valueOf(themeRel.Theme__r.Id.getsobjecttype())).add(clipTempRec);
                     }
                     else{
                         clipsTagsMap.put(String.valueOf(themeRel.Theme__r.Id.getsobjecttype()),new List<ClipsTagReference>{clipTempRec});

                     }   
                        }
                    }
                }  
                }    
            List<NavatarAcuityCtrl.ReferenceWrapper>  updatedRefWrapperList = new List<NavatarAcuityCtrl.ReferenceWrapper>();
            List<ClipsTagReference>  updatedClipsTagWrapperList = new List<ClipsTagReference>();
            List<String> clipsTagList = new List<String>();
            for(String sobj: sobjectList){
                if(clipsRefMap.get(sobj) != Null && clipsRefMap.get(sobj).size()>0){
                    Map<String,NavatarAcuityCtrl.ReferenceWrapper> sortedRefMap = new Map<String,NavatarAcuityCtrl.ReferenceWrapper>();
                    List<String> sortedList = new List<String>();
                    List<NavatarAcuityCtrl.ReferenceWrapper> sortedWrapList = new List<NavatarAcuityCtrl.ReferenceWrapper>();
                    for( NavatarAcuityCtrl.ReferenceWrapper refRec : clipsRefMap.get(sobj)){
                        sortedRefMap.put(refRec.Name,refRec);
                        sortedList.add(refRec.Name);
                        sortedList.sort();                        
                    }
                    for(String rec: sortedList){
                        sortedWrapList.add(sortedRefMap.get(rec));
                    }
               updatedRefWrapperList.addAll(sortedWrapList);
                }
                
                 if(clipRelationMap.get(sobj) != Null && clipRelationMap.get(sobj).size()>0){
                     List<String> sortedList = new List<String>();
                     sortedList = clipRelationMap.get(sobj);
                     sortedList.sort();
                     clipsTagList.addAll(sortedList);
                }
                
                if(clipsTagsMap.get(sobj) != Null && clipsTagsMap.get(sobj).size()>0){
                     Map<String,ClipsTagReference> sortedRefMap = new Map<String,ClipsTagReference>();
                    List<String> sortedList = new List<String>();
                    List<ClipsTagReference> sortedWrapList = new List<ClipsTagReference>();
                    for( ClipsTagReference refRec : clipsTagsMap.get(sobj)){
                        sortedRefMap.put(refRec.tag,refRec);
                        sortedList.add(refRec.tag);
                        sortedList.sort();                        
                    }
                    for(String rec: sortedList){
                        if(rec != Null){
                        sortedWrapList.add(sortedRefMap.get(rec));
                        }     
                    }
               updatedClipsTagWrapperList.addAll(sortedWrapList);
                }
                
            }
            
            tempRec.ClipsTagsPDF=strClipsTagsPDF.removeStart(',');
            tempRec.ClipsTagsRef=  updatedClipsTagWrapperList; 
             tempRec.ClipsTags=  clipsTagList; 
            tempRec.ClipsTagsWrapper =  updatedRefWrapperList;
            clipsWrapperList.add(tempRec);
        }
       
        //return clipsWrapperList;
        }
      return clipsWrapperList;
      }
        catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    
    /*
* Purpose :  Wrapper Class to load the themes data
*/
    
    public class AllClipsPageWrapper{
        @AuraEnabled  public string Id ;
        @AuraEnabled  public string Name {get;set;}
        @AuraEnabled  public string Summary {get;set;}
        @AuraEnabled  public string CreatedBy {get;set;}
        @AuraEnabled  public String CreatedDate {get;set;}
        @AuraEnabled  public String Notes{get;set;}
        @AuraEnabled  public List<String> ClipsTags ;
        @AuraEnabled  public String ClipsTagsPDF{get;set;}
        @AuraEnabled  public List<ClipsTagReference> ClipsTagsRef ;
        @AuraEnabled  public List<NavatarAcuityCtrl.ReferenceWrapper> ClipsTagsWrapper ;
    }
    
   /*
* Purpose :  Wrapper Class to handle Clips related tags
*/ 
    public class ClipsTagReference{
        @AuraEnabled  public Integer index ;
        @AuraEnabled  public string tag ;
        @AuraEnabled  public string tagRef ;
        @AuraEnabled  public string iconName ;
    }
    
 /*
* Purpose :  Get the wrapper for the respective clip record
* input : index - to update the index for the record
        : Name - Name of the taged recod
        : recId : record id of the tagged record
* returns ClipsTagReference
*/ 
     @AuraEnabled 
    public static ClipsTagReference getClipRefData(Integer index,String Name,String recId,String iconName){
        ClipsTagReference clipRef = new ClipsTagReference();
        clipRef.index=index;
        clipRef.tag=Name;
        clipRef.tagRef= recId;
        clipRef.iconName= iconName;
        return clipRef;
    }
  /*
* Purpose :  Get the wrapper for the respective clip record
* input : Name -Name of the taged recod
        : iconName - iconname of the related object
        : recId : record id of the tagged record
* returns NavatarAcuityCtrl.ReferenceWrapper
*/     
    
    @AuraEnabled   
    public static NavatarAcuityCtrl.ReferenceWrapper getRefData(String Name, String iconName, String recId){
        NavatarAcuityCtrl.ReferenceWrapper rw = new NavatarAcuityCtrl.ReferenceWrapper();
        rw.name = Name;
        if(recId != null){
            rw.nameRef = '/'+recId;
        }
        rw.iconName = iconName;
        return rw;
    }
    
  
    /*
* Purpose : get all the themes data based on the search term
* Input : searchTerm     [themes fetched based on the search term]     
* Returns : Data displayed on table returns as AllThemePageWrapper
*/
    
    @AuraEnabled(cacheable=true) public static List<AllClipsPageWrapper> getSearchedThemes(String searchTerm){
        try{
            Set<String> clipIdSet = new Set<String>();
			String clipField2 = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field2').Value__c;
            if(schema.sobjecttype.Clip__c.isaccessible()){
            
            String searchQuery =  'FIND '+'\'*"'+String.escapeSingleQuotes(searchTerm)+'"*\'' +' IN ALL FIELDS RETURNING  navpeII_dev18__Clip__c (Id,Name';
           String searchQuery1 =  'FIND '+'\'*"'+String.escapeSingleQuotes(searchTerm)+'*"\'' +' IN ALL FIELDS RETURNING  navpeII_dev18__Clip__c (Id,Name';
		   
		     //  Added by Hema - W.R.T Secuity Fix	
                if(NavatarAllThemesCtrl.checkCreateableFields( Schema.sObjectType.Clip__c.getsObjectType(), new List<String>{clipField2})){	
                       searchQuery +=   ','+clipField2;	
                       searchQuery1 +=   ','+clipField2;	
                 }	
                if(NavatarAllThemesCtrl.checkCreateableFields( Schema.sObjectType.Clip__c.getsObjectType(), new List<String>{'navpeII_dev18__Notes__c'})){	
                       searchQuery +=   ',navpeII_dev18__Notes__c';	
                       searchQuery1 +=   ',navpeII_dev18__Notes__c';	
                 }	
                	
                 searchQuery +=   ')';	
                 searchQuery1 +=   ')';  	
             //  Added by Hema - W.R.T Secuity Fix 
                
             List<Clip__c> clipList = new List<Clip__c>();
            if(Schema.sObjectType.Clip__c.isAccessible()){
                Search.SearchResults searchResultsClip = Search.find(searchQuery,AccessLevel.USER_MODE); 
                Search.SearchResults searchResultsClip1 = Search.find(searchQuery1,AccessLevel.USER_MODE);
                
                List<Search.SearchResult> searchResultCliplist=new List<Search.SearchResult>();
                searchResultCliplist= searchResultsClip.get('navpeII_dev18__Clip__c');
                searchResultCliplist = searchResultsClip1.get('navpeII_dev18__Clip__c');
                
                for(Search.SearchResult sr:searchResultCliplist){
                    navpeII_dev18__Clip__c clipRec = (navpeII_dev18__Clip__c) sr.getSObject();
                    clipList.add(clipRec);
                    clipIdSet.add(string.ValueOf(clipRec.Id));
                }
            }    
            }
            
            if(schema.sobjecttype.Clip_Relation__c.isaccessible()){   
            Map<String,String> clipRelMap = new Map<String,String>();
            List<navpeII_dev18__Clip_Relation__c> clipRelationList = [SELECT Id,navpeII_dev18__Account__r.Name,navpeII_dev18__Contact__r.Name,navpeII_dev18__Fund__r.Name,navpeII_dev18__Fundraising__r.Name,navpeII_dev18__Deal__r.Name,navpeII_dev18__User__r.Name,navpeII_dev18__Clip__r.Id,navpeII_dev18__Clip__r.Name FROM  navpeII_dev18__Clip_Relation__c WHERE navpeII_dev18__Clip__c != Null LIMIT 49990];
            for(navpeII_dev18__Clip_Relation__c clipRel : clipRelationList){
			 //Added by Hema W.R.T Security Fix

				 clipRelMap.put(clipRel.navpeII_dev18__Clip__r.Id+'-'+clipRel.Id,	
                  ((schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__Account__c.isaccessible())? clipRel.navpeII_dev18__Account__r.Name : '') +','+( (schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__Contact__c.isaccessible())? clipRel.navpeII_dev18__Contact__r.Name: '') +','+ ((schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__Fund__c.isaccessible())? clipRel.navpeII_dev18__Fund__r.Name: '')+','+( (schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__Fundraising__c.isaccessible())? clipRel.navpeII_dev18__Fundraising__r.Name: '') +','+ ((schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__Deal__c.isaccessible())? clipRel.navpeII_dev18__Deal__r.Name :'') +','+( (schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__Clip__c.isaccessible())? clipRel.navpeII_dev18__Clip__r.Name: '')+','+( (schema.sobjecttype.navpeII_dev18__Clip_Relation__c.Fields.navpeII_dev18__User__c.isaccessible())? clipRel.navpeII_dev18__User__r.Name : '') );
            }
            for(String clipId : clipRelMap.keySet() ){
                if( clipRelMap.get(clipId) != Null && clipRelMap.get(clipId).containsIgnoreCase(searchTerm)){
                    clipIdSet.add(clipId.split('-')[0]);
                }
            }
          }     
               
            if(schema.sobjecttype.Theme_Relation__c.isaccessible()){    
            Map<String,String> themeRelMap = new Map<String,String>();
            List<navpeII_dev18__Theme_Relation__c> themeRelList = [SELECT Id,navpeII_dev18__Theme__r.Name,navpeII_dev18__Clip__r.Name FROM navpeII_dev18__Theme_Relation__c WHERE navpeII_dev18__Clip__c != Null LIMIT 49990];
            for(Theme_Relation__c themeRec:themeRelList){
			//Added by Hema W.R.T Security Fix
                themeRelMap.put(themeRec.navpeII_dev18__clip__r.Id+'-'+themeRec.Id,schema.sobjecttype.Theme_Relation__c.Fields.navpeII_dev18__Theme__c.isaccessible()? themeRec.navpeII_dev18__Theme__r.Name:'');
            }
            for(String clipId : themeRelMap.keySet() ){
               if( themeRelMap.get(clipId) != Null && themeRelMap.get(clipId).containsIgnoreCase(searchTerm)){
                    clipIdSet.add(clipId.split('-')[0]);
                } 
            }
           }     
            List<AllClipsPageWrapper> allClipsPageWrapperList = new List<AllClipsPageWrapper>();
            List<String> clipIdList = new List<String>();
            clipIdList.addAll(clipIdSet);
            if( clipIdList.size()>0){
                allClipsPageWrapperList = getAllClipsRecords(clipIdList);
            } 
            return allClipsPageWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
     
     
     // to store api response
     public class FromJSON{
         @AuraEnabled public cls_colors[] colors;
         @AuraEnabled public boolean custom;
         @AuraEnabled public cls_icons[] icons;
         @AuraEnabled public String label;    //DemoObjects
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
     
     public static void getObjIconNames(){
     List<string> objectAPIName= new List<String>{'Account','Contact','navpeII_dev18__Pipeline__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c','Clip__c','navpeII_dev18__Theme__c'}; //Modified by Hema 19-04-2023
    String layoutResponse;
    string endpointurl ='/services/data/v41.0/tabs';
         if(!test.isRunningTest()){
             layoutResponse = AcuityPECommonUtility.getDescribeResponse(endpointurl);
             list<FromJSON> layout = (list<FromJSON>)System.JSON.deserialize(layoutResponse ,  list<FromJSON>.class);
             string objectName='';
             for(string objName: objectAPIName){
                 for(FromJSON tab:layout) {
                    
                     /*added profile label check for user by shashank in AA3.0 */
                     if(objName == tab.sobjectName && tab.label!='Profile'){
                         for(cls_icons icn : tab.icons){
                             if(icn.height == 0 && icn.theme== 'theme4' ){
                                 String objType = icn.url.split('/')[6]; //standard
                                 String tempName = icn.url.split('/')[7]; // account.svg
                                 objectName = tempName.split('\\.')[0]; //account
                                 iconNameMap.put(objName,objType+':'+objectName);                               
                             }
                         }
                     }
                     
                 }
             }
         }     
     }
 }