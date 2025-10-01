({
  
    handleModalClose : function(component, event, helper) {

       console.log('Aura closemodal');
       
        component.find("overlayLib").notifyClose();

     console.log('notified');

    }
    
   

})