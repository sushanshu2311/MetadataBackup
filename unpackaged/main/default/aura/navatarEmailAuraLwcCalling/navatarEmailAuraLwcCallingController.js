({
    navToLwcComp: function (component) {
        let navToComp = $A.get("e.force:navigateToComponent");
        navToComp.setParams({
            componentDef: "c:navatarEmailContactsLwc",
            componentAttributes: {
                recordId: component.get("v.recordId")
            }
        });
        navToComp.fire();
        let dismissActionPanel = $A.get("e.force:closeQuickAction");
        setTimeout(function () { dismissActionPanel.fire(); }, 1);
    }
})