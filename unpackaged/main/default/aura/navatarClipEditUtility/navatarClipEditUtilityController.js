({
    
    handleMessage: function(component, event, helper) {
        if (event != null && event.getParams() != null) {
            let params = event.getParams();
            var utilityAPI = component.find("utilitybar");
            var utilityIdFinal;
            utilityAPI.getAllUtilityInfo().then(function(response) {
                var utilityBarString =  JSON.stringify(response);
                //alert('message '+params.message)
                var editUtilityValue = {'messageBody':params.message};
                component.find("clipIdChannel").publish(editUtilityValue);
                let clipUtilittyId ='';
                for(var d in response) {
                    if(response[d].utilityLabel == 'Clips' || response[d].utilityLabel == 'Clip') {
                        clipUtilittyId = response[d].id;
                        break;
                    }
                }
                
                var myUtilityInfo = response[3];
                utilityAPI.openUtility({
                    utilityId: clipUtilittyId
                });
            })
            .catch(function(error) {
                console.log(error);
            });
            
        }
    }
})