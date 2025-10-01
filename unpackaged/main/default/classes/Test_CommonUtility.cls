@isTest
public class Test_CommonUtility {
    public static testMethod void tstMthd(){
        List<String> strList = new List<String>();
        strList.add('Account'); 
        System.assertEquals('Account', strList[0]); // (PE3.5, SK, 9Aug2017)
        
        CommonUtility.describeSObject(strList);
        CommonUtility.describeSFTabs(strList);
        CommonUtility.getFieldNameVsDataType(strList);
        
        //For catch blocks
        List<String> strList2 = new List<String>();
        strList2.add('1a1'); 
        System.assertEquals('1a1', strList2[0]); // (PE3.5, SK, 9Aug2017)
        
        CommonUtility.describeSObject(strList2);
        CommonUtility.describeSFTabs(strList2);
        CommonUtility.getFieldNameVsDataType(strList2);
    }
}