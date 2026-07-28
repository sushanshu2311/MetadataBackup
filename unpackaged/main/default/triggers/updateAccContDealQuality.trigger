/*********************************************************************************************************************
Developer           :   Mohammad Ubaid
Product Version     :   PE 4.0
Date of Creation    :   22/01/2019
Purpose of Creation :   Flow to update Contact and Account based on Source Contact/Company and Deal Quality Score
						This trigger call flow
***********************************************************************************************************************/

trigger updateAccContDealQuality on navpeII__Pipeline__c(after insert , after update , after delete , after Undelete) 
{
   
        SET<ID> finalContact = new SET<ID>();
        SET<ID> finalAccount = new SET<ID>();
        map<string,object> conMap = new map<string,object>();
        map<string,object> AccMap = new map<string,object>();
        
        if(Trigger.isInsert || Trigger.isUndelete){
            for(navpeII__Pipeline__c  ppl : Trigger.new){
                if(ppl.navpeII__Source_Contact__c != null)
                    finalContact.add(ppl.navpeII__Source_Contact__c);
                if(ppl.navpeII__Source_Company__c != null)
                    finalAccount.add(ppl.navpeII__Source_Company__c);
            }
        }
        
        if(Trigger.isUpdate){
            for(navpeII__Pipeline__c pplNewUp : Trigger.new){
				if((pplNewUp.navpeII__Source_Contact__c != trigger.oldmap.get(pplNewUp.Id).navpeII__Source_Contact__c) || (pplNewUp.navpeII__Deal_Quality_Score__c != trigger.oldmap.get(pplNewUp.Id).navpeII__Deal_Quality_Score__c)){
					if(pplNewUp.navpeII__Source_Contact__c != null)
						finalContact.add(pplNewUp.navpeII__Source_Contact__c);
					if(trigger.oldmap.get(pplNewUp.Id).navpeII__Source_Contact__c != null)
						finalContact.add(trigger.oldmap.get(pplNewUp.Id).navpeII__Source_Contact__c);
				}
                    
				if(pplNewUp.navpeII__Source_Company__c != trigger.oldmap.get(pplNewUp.Id).navpeII__Source_Company__c || (pplNewUp.navpeII__Deal_Quality_Score__c != trigger.oldmap.get(pplNewUp.Id).navpeII__Deal_Quality_Score__c)){
					if(pplNewUp.navpeII__Source_Company__c != null)
						finalAccount.add(pplNewUp.navpeII__Source_Company__c);
					if(trigger.oldmap.get(pplNewUp.Id).navpeII__Source_Company__c != null)
						finalAccount.add(trigger.oldmap.get(pplNewUp.Id).navpeII__Source_Company__c);
				}	
            }
        }
        
        if(Trigger.isDelete){
            for(navpeII__Pipeline__c  pplOldDel : Trigger.old){
                if(pplOldDel.navpeII__Source_Contact__c != null)
                    finalContact.add(pplOldDel.navpeII__Source_Contact__c);
                if(pplOldDel.navpeII__Source_Company__c != null)
                    finalAccount.add(pplOldDel.navpeII__Source_Company__c);
            }
        }
       
        if(finalContact.size()>0){
            conMap.put('finalContact' , finalContact);
            system.debug('conMap::Before:::::' + conMap);
            Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Contact  avgQualityOnContFlow = new Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Contact(conMap);
            avgQualityOnContFlow.start();
            system.debug('conMap::After:::::');
        }
        
        if(finalAccount.size()>0){
            AccMap.put('finalAccount' , finalAccount);
            system.debug('AccMap::Before:::::' + AccMap);
            Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Account  avgQualityOnAccFlow = new Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Account(AccMap);
            avgQualityOnAccFlow.start();
            system.debug('AccMap::After:::::');
        } 
    
    
}