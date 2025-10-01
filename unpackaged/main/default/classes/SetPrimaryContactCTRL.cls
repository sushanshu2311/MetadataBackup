/*  Added Functionality:
    Developer               :  Sourabh Tayal
    Product Version         :  PE 3.5
    Date of Creation        :  07/11/2017
    Date of Last Update     :  07/11/2017
    Last Updated By         :  Sourabh Tayal
    Test Class              :  Test_SetPrimaryContactCTRL
    Purpose of Creation     :  Listed below:
                                1. To set selected FundraingContact for a fundraising as primary.  
                     
*/

public with sharing class SetPrimaryContactCTRL 
{
    public String presentRecordId {get; set;}
    public String FRIds {get; set;}
    public List<Fundraising_Contact__c> selectedApplications {get;set;}
    
    public SetPrimaryContactCTRL(ApexPages.StandardController controller) {
        //
    }
    
    
    public SetPrimaryContactCTRL(ApexPages.StandardSetController controller)
    {
        presentRecordId = ApexPages.currentPage().getParameters().get('id');
        
        FRIds = '';
        selectedApplications = controller.getSelected();
        
        if(Test.isRunningTest())
        {
             // SK: 7Dec2017
            if(Schema.sObjectType.Fundraising_Contact__c.isAccessible() && Schema.sObjectType.Fundraising_Contact__c.Fields.Name.isAccessible())
            {
                selectedApplications  = [Select Id, Name From Fundraising_Contact__c Limit 5];
            }
        }
        
        for(Fundraising_Contact__c obj : selectedApplications )
        {
            if(FRIds == ''){
                FRIds = obj.Id;
            }
            else{
                FRIds += ', ' +obj.Id;
            }
        }
    }
}