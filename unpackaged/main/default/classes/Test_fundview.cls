@isTest (SeeAllData='true')
public class Test_fundview
{
    public static testMethod void testAPController() 
    {
        Account aacc=new Account(name='vivek');
        insert aacc;
        System.assertEquals('vivek', aacc.Name); // (PE3.5, SK, 8Aug2017)
        
        FundView  fundviewobj=new FundView (new ApexPages.StandardController(aacc));
        fundviewobj.locale_info='Eu';
        fundviewobj.lpId=aacc.id;
        fundviewobj.NameSpacePrefix='navatar';
        fundviewobj.isCurrency=true;
        fundviewobj.strCurrencySystembol='$';
    }
}