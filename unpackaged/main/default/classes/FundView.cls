/*  Added Functionality:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   02/03/2009
        Throws                  :   NA
        Calls                   :   NA
        Test Class              :   94% coverage
        Purpose of Creation     :   Listed below:
                                    1. To provide extra functionality to Standard Account Controller.
                                    
        Revision History:-
        Version    Date         Author            Description of Action
        3.5        2016-07-26   Vasudha Tandon     To Send user local to vf page and for multicurrency functinality
*/
public with sharing class FundView {
// Added "with sharing" keyword for security purpose.


    private final Account tempAccount;
    public string locale_info{get;set;}  
    public Id lpId{get; set;}
    public string NameSpacePrefix{get; set;}
    Integer recCount;
    public boolean isCurrency{get;set;}   /*variable  to check if multicurrency is enabled in class or not  */
    public string localeString{get;set;}  /*variable  to check locale of the user  */
    public string strCurrencySystembol{get;set;}/*variable  to check default currency of the user  */
    

    public FundView(ApexPages.StandardController controller) {
        this.tempAccount = (Account)controller.getRecord();        
        strCurrencySystembol = UserInfo.getDefaultCurrency();
        string user_id=Userinfo.getUserId();
        localeString=UserInfo.getLocale();
        lpId = ApexPages.currentPage().getParameters().get('id');
        isCurrency=Schema.getGlobalDescribe().containsKey('CurrencyType');
        NameSpacePrefix=CommonUtility.strNameSpacePrefix;
    }
    
  
}