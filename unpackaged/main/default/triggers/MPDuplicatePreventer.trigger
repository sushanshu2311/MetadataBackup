trigger MPDuplicatePreventer on Marketing_Prospect__c(before insert, before update) 
    {
        /*  New Implimentation:
            Developer               :   Ajay Agnihotri
            Product Version         :   MnA 2.1
            Date of Creation        :   18/Aug/2012
            Purpose of Creation     :   To check for 2000 Marketing Prospects in associated Marketing Initiative also to handle duplicate Marketing Prospects .
        */    
        set<id> martempid = new set<id>();
        set<id> marketId=new set<id>();
        list<Marketing_Prospect__c> mProspet= new list<Marketing_Prospect__c>(); 
        list<Marketing_Prospect__c> mProspett=new list<Marketing_Prospect__c>(); 
        map<id,id> mapofcontacts=new map<id,id>();
        map<id,id> mapofcontactss=new map<id, id>(); 
        if(!AddProspect_Ctlr.triggerenabled){
            for(Marketing_Prospect__c marketingProspObj:Trigger.New)
            {      
                if(marketingProspObj.Marketing_Initiative__c != null)
                    marketId.add(marketingProspObj.Marketing_Initiative__c);                
            }
            
            for(Marketing_Prospect__c marketpros:[select id,Contact__c,Marketing_Initiative__c  from Marketing_Prospect__c where Marketing_Initiative__c IN :marketId])
            {
                mapofcontacts.put(marketpros.Contact__c,marketpros.Marketing_Initiative__c);                

            } 
            for(Marketing_Prospect__c marketingProspObj:Trigger.New)
            {
                if((trigger.isInsert && mapofcontacts.containsKey(marketingProspObj.Contact__c)) || (trigger.isUpdate && ((trigger.newMap.get(marketingProspObj.Id).contact__c != trigger.oldMap.get(marketingProspObj.Id).contact__c)|| (trigger.newMap.get(marketingProspObj.Id).Marketing_Initiative__c != trigger.oldMap.get(marketingProspObj.Id).Marketing_Initiative__c))))
                {
                    marketingProspObj.adderror('Marketing prospect record already exists');
                }
            
            }
        }       
    }