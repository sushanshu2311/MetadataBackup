/****************************************************************************************************

** Module Name : Clips

** Description : Used open save clips popup

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
({
    handleModalClose : function(component, event, helper) {
        component.find("overlayLib1").notifyClose();
		
	}
})