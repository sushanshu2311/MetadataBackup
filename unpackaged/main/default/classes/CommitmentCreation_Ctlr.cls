/*********************************************************************************
** Module Name : CommitmentCreation_Ctlr
** Description : to validate date and curreny on commitment creation page.
** Throws : NA
** Calls : NA
** Test Class : TestCommitmentCreation_Ctlr
**
** Organization : Navatar Group
**
** Revision History:-
** Version   Date        Author       WO#  Description of Action
** 3.5       2016-06-2  Sachin Kumar  NA   to validate date and curreny on commitment creation page.
*********************************************************************************/

global with sharing Class CommitmentCreation_Ctlr 
{

    public CommitmentCreation_Ctlr(CommitmentCreationHelper_Ctlr controller) {
    }
    
    
    /*
    Description : This method is use to validate the date. 
    Param: Sting
    Retun Type: boolean
    */
    WebService static boolean getValidDate(String comtDate) 
    {
        try {
            
            Date checkDate = Date.parse(comtDate);
            
            return true;
        } catch (Exception objExcp) {
            
            return false;
        }
        
    }
    
    
    /*
    Description : This method is use to validate the amount. 
    Param: Sting
    Retun Type: boolean
    */
    WebService static boolean getValidAmount(String comtAmount)
    {
        
        try {
            
            Decimal checkAmount = Decimal.valueOf(comtAmount);
            
            return true;
        } catch (Exception objExcp) {
            
            return false;
        }
        
    }
    
    
}