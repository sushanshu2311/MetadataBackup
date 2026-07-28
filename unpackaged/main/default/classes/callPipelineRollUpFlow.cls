/********************************************************************************************************************************
Developer               :   Mohammad Ubaid
Product Version         :   PE 4.0
Date of Creation        :   22/01/2019
Purpose of Creation     :   Flow to update Contact and Account invoke from updateContDealQualty and updateAccDealQualty triggers
********************************************************************************************************************************/

Public class callPipelineRollUpFlow {
    
    @future
    public static void dealQualityAndShownForContact(set<Id> finalContact)
    {
        map<string,object> conMap = new map<string,object>();
        conMap.put('finalContact' , finalContact);
        system.debug('conMap::Before:::::' + conMap);
        Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Contact  avgQualityOnContFlow = new Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Contact(conMap);
        avgQualityOnContFlow.start();
        system.debug('conMap::After:::::');
    }
    
    @future
    public static void dealQualityAndShownForAccount(set<Id> finalAccount)
    {
        map<string,object> AccMap = new map<string,object>();
        AccMap.put('finalAccount' , finalAccount);
        system.debug('AccMap::Before:::::' + AccMap);
        Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Account  avgQualityOnAccFlow = new Flow.Interview.Calculate_DealQuality_and_Deal_Shown_on_Account(AccMap);
        avgQualityOnAccFlow.start();
        system.debug('AccMap::After:::::');
    }
    
}