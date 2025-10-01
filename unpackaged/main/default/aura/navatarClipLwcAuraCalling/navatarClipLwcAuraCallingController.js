({
	openProgarm: function(component, event, helper) {
        if (event != null && event.getParams() != null) {
            let params = event.getParams();
            //alert(params.message+'In Aura');
            component.set("v.recordId",params.message);
        }
        var utilityAPI = component.find("utilitybar");
        var utilityIdFinal;
        utilityAPI.getAllUtilityInfo().then(function(response) {
            var utilityBarString =  JSON.stringify(response);
            var myUtilityInfo = response[response.length-1];
            utilityAPI.openUtility({
                utilityId: myUtilityInfo.id
            });
            const payload = {
                source: "Aura",
                messageBody: component.get("v.recordId")
        	};
        	component.find("clipIdChannel").publish(payload);
            var pubsub = component.find('pubsub');            
       })
        .catch(function(error) {
            console.log(error);
        });;
    }
})