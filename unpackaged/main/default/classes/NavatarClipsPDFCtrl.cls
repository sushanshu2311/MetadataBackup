/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle Clips Print button to generate pdf 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Hema
****************************************************************************************************/
public with sharing class NavatarClipsPDFCtrl {
    public NavatarAllClipsCtrl.AllClipsPageWrapper clips{get; set;}
    public NavatarClipsPDFCtrl(){
        List<NavatarAllClipsCtrl.AllClipsPageWrapper> clipsList=NavatarAllClipsCtrl.getAllClipsRecords(new List<Id>{ApexPages.currentPage().getParameters().get('id')});
    	if(clipsList.size()>0)
            clips=clipsList[0];
    }
}