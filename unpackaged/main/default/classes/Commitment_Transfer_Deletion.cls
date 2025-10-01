public with sharing class Commitment_Transfer_Deletion
{
    private final SObject tempObj;
    private String pageRef;
    private String prevpageRef;
    public Boolean buttonView {get; set;}

    public Commitment_Transfer_Deletion(ApexPages.StandardController controller) {
        this.tempObj = controller.getRecord();
        pageRef = ApexPages.currentPage().getParameters().get('retURL');
        prevpageRef = pageRef;
        buttonView = true;
        if(pageRef != null && pageRef.length() < 15)
            pageRef = '/' + this.tempObj.get('id');
    }

    public PageReference cmt_Cancel()
    {
        PageReference pRef = new PageReference(pageRef);
        pRef.setRedirect(true);
        return pRef;
    }

    public PageReference cmt_Delete()
    {
        Database.DeleteResult dS;
        buttonView = false;
        try
        {
            //(PE3.5, SK, 11Aug2017)
            if(Schema.getGlobalDescribe().get(String.valueOf( Id.valueOf((string)tempObj.id).getSObjectType())).getDescribe().isDeletable()){
                dS = Database.delete(tempObj);
            }
            if(dS.isSuccess()){
                pageRef = prevpageRef;
            }
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0)));
            return null;
        }

        PageReference pRef = new PageReference(pageRef);
        pRef.setRedirect(true);
        return pRef;
    }

    public static testMethod void testcommitmentDelete()
    {
        list<RecordType> RT = new list<RecordType>();
        if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible())
            RT = [select Name from Recordtype where SObjectType='Account'];
        Map<String, ID> mapRT = new Map<String, ID>();
        for(RecordType r : RT)
            mapRT.put(r.Name, r.id);
        Account Inst = new Account(name='Institution',recordTypeId=mapRT.get('Institution'));
        if(Schema.sObjectType.Account.isCreateable()){
          insert Inst;
        }
        
        Account ac=[select name from Account where id=:Inst.id];
        System.assertEquals('Institution',ac.name);
        
        Account LP = new Account(name='LP', parentId=Inst.id, recordTypeId=mapRT.get('Limited Partner'));
        if(Schema.sObjectType.Account.isCreateable()){
          insert LP;
        }
        
        ac=[select name from Account where id=:LP.id];
        System.assertEquals('LP',ac.name);
        
        Account LP1 = new Account(name='LP', parentId=Inst.id, recordTypeId=mapRT.get('Limited Partner'));
        if(Schema.sObjectType.Account.isCreateable()){
          insert LP1;
        }
        
        ac=[select name from Account where id=:LP1.id];
        System.assertEquals('LP',ac.name);
        
        Fund__c fnd = new Fund__c(name = 'Test Fund', Investment_Category__c = 'Fund');
        if(Schema.sObjectType.Fund__c.isCreateable()){
          insert fnd;
        }
        
        Fund__C f=[select name from Fund__C where id=:fnd.id];
        System.assertEquals('Test Fund',f.name);
        
        Partnership__c part = new Partnership__c(name='Test Part', Fund__c=fnd.id);
        if(Schema.sObjectType.Partnership__c.isCreateable()){
          insert part;
        }
        
        Partnership__c p=[select name from Partnership__c where id=:part.id];
        System.assertEquals('Test Part',p.name);
        
        Partnership__c part1 = new Partnership__c(name='Test Part', Fund__c=fnd.id);
        if(Schema.sObjectType.Partnership__c.isCreateable()){
          insert part1;
        }
        
        p=[select name from Partnership__c where id=:part1.id];
        System.assertEquals('Test Part',p.name);
        
        Commitment__c cmt1 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        if(Schema.sObjectType.Commitment__c.isCreateable()){
          insert cmt1;
        }
        
        Commitment__c c1=[select Commitment_Amount_nearest__c from Commitment__c where id=:cmt1.id];
        System.assertEquals(2000000,c1.Commitment_Amount_nearest__c);
        
        Commitment__c cmt2 = new Commitment__c(Limited_Partner__c=LP.id, Partnership__c=part.id, Commitment_Amount_nearest__c=2000000);
        if(Schema.sObjectType.Commitment__c.isCreateable()){
          insert cmt2;
        }
        
        c1=[select Commitment_Amount_nearest__c from Commitment__c where id=:cmt2.id];
        System.assertEquals(2000000,c1.Commitment_Amount_nearest__c);
        
        Transfer__c OT1 = new Transfer__c(Commitment_Name__c=cmt2.Id, Transfer_Amount_nearest__c=1000000, Transfer_to_Limited_Partner__c=LP1.id, Transfer_to_Partnership__c=part1.id, Transfer_Date__c=System.Today());
        if(Schema.sObjectType.Transfer__c.isCreateable()){
          insert OT1;
        }
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cmt1);
        Commitment_Transfer_Deletion c = new Commitment_Transfer_Deletion(sc);
        c.prevpageRef = '/' + c.tempObj.get('id');
        c.pageRef = '/' + c.tempObj.get('id');
        PageReference ref;
        try {
            System.assert(c.cmt_Delete() != ref,'Procedure is only valid for System.DmlException and System.MailException');
            System.assert(c.cmt_Cancel() != ref,'Procedure is only valid for System.DmlException and System.MailException');
            sc = new ApexPages.StandardController(cmt2);
            c = new Commitment_Transfer_Deletion(sc);
            c.prevpageRef = '/' + c.tempObj.get('id');
            c.pageRef = '/' + c.tempObj.get('id');
            System.assert(c.cmt_Delete() == ref,'Procedure is only valid for System.DmlException and System.MailException');
            System.assert(c.cmt_Cancel() != ref,'Procedure is only valid for System.DmlException and System.MailException');
        }
        catch (TypeException ee){
             System.assertEquals('Procedure is only valid for System.DmlException and System.MailException', ee.getMessage());
        }
    }
}