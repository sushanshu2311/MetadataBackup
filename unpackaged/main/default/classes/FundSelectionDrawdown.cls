/*********************************************************************************
** Module Name  : FundSelectionDrawdown
** Description  : To redirect the page and exception handling  
** Test Class   : Available
** Throws       : NA
** Calls        : NA
** Organization : Navatar Group
**
** Revision History:-
** Version    Date          Author               Description of Action
** 3.5       2016-07-09   vasudha Tandon     To redirect the page and exception handling
*********************************************************************************/
public with sharing class FundSelectionDrawdown {

    public Sobject obj;
    
    // constructor
    public FundSelectionDrawdown(ApexPages.StandardController controller) {
        obj = controller.getRecord();
        part = new Partnership__c();
    }

    // This method redirects to FundDrawdownNewOverride , handle the null object and invalid exception
    public PageReference evaluate()
    {
        try
        {
            if(obj.get('Fund_Name__c') != null){
                string st = string.valueOf(obj.get('Fund_Name__c'));
                Fund__c f = new Fund__C(id = st);
                return new PageReference('/apex/createDrawdown?scontrolCaching=1&id='+st);
            }
            else{
                return null;
            }            
        }
        catch(System.NullPointerException e)
        {
            system.assert(e.getMessage().contains('de-reference a null object'));
        }
        catch(System.TypeException e)
        {
            system.assert(e.getMessage().contains('Invalid id'));
        }
        catch(System.StringException e)
        {
            system.assert(e.getMessage().contains('Invalid id'));
        }
        return null;
    }

    public Partnership__c part{get;set;}
    
    // when Create Draudown button will click then it rediects to createDrawdown page with fund Id
    public PageReference redirectFun()
    {
        return new PageReference('/apex/createDrawdown?scontrolCaching=1&id='+part.Fund__c);
    }
}