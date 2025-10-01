@isTest
public class TestListviewpicklist
{
    static TestMethod void Listviewpicklistmethod()
    {
        
        Listviewpicklist lstViewPicklist = new Listviewpicklist();
        lstViewPicklist.getValues();
        lstViewPicklist.getDefaultValue();
        VisualEditor.DataRow  defaultVal= lstViewPicklist.getDefaultValue();    
        System.assertEquals('AllAccounts', defaultVal.getValue()); 
    }
}