/****************************************************************************************************
** Module Name : Acuity 2.0 - Theme Team
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-12-27         Virendra Kumar
****************************************************************************************************/
public class NavatarThemeTeamHandler {
    /*
    * Purpose : Duplicate check based on Theme, Role and Member
    * Input : newThemeTeam [new theme Team Records] 
    *         oldMap    [old version of Theme Team Records]
    */
    public static void duplicateCheckBasedOnMemberAndRole(List<Theme_Team__c> newThemeTeam , Map<Id,Theme_Team__c> oldMap){
        
        Set<id> themeId = new Set<id>();
        List<String> roles = new List<String>();
        map<Id, Theme_Team__c> roleByMem = new map<Id, Theme_Team__c>();
        Map<Id, Theme_Team__c> themeTeamByMem = new Map<Id, Theme_Team__c>();
        
        for(Theme_Team__c themeTeam :newThemeTeam) {
            
            if((oldMap == null && themeTeam.Member__c != null && themeTeam.Role__c != null && themeTeam.Theme__c != null) || 
               (oldMap != null && (oldMap.get(themeTeam.Id).Member__c != themeTeam.Member__c || oldMap.get(themeTeam.Id).Role__c != themeTeam.Role__c || oldMap.get(themeTeam.Id).Theme__c != themeTeam.Theme__c))) {
                   
                   if(roleByMem.ContainsKey(themeTeam.Member__c) && roleByMem.get(themeTeam.Member__c).Role__c == themeTeam.Role__c && roleByMem.get(themeTeam.Member__c).Theme__c == themeTeam.Theme__c) {
                       themeTeam.addError('Member already exists with the same role.');
                       
                   }else {
                       roleByMem.put(themeTeam.Member__c,themeTeam);
                       roles.add(themeTeam.Role__c);
                       themeId.add(themeTeam.Theme__c);
                   }
               }
        }
        if(!roleByMem.isEmpty()){
            for(Theme_Team__c themeTeam : [SELECT id , Role__c , Member__c, Theme__c FROM Theme_Team__c where Role__c =: roles AND Member__c =: roleByMem.Keyset() AND Theme__c =: themeId]) {
                themeTeamByMem.put(themeTeam.Member__c, themeTeam);
            }
            if(!themeTeamByMem.isEmpty()){
                for(Theme_Team__c themeTeam : newThemeTeam){
                    if(themeTeamByMem.containsKey(themeTeam.Member__c) && themeTeamByMem.get(themeTeam.Member__c).Role__c == themeTeam.Role__c && themeTeamByMem.get(themeTeam.Member__c).Theme__c == themeTeam.Theme__c) {
                        themeTeam.addError('Member already exists with the same role.'); 
                    }
                }	
            }
        }
    }
}