({
	doInit : function(component, event, helper) {
    document.title = "Navatar Support";
    var link = document.querySelector("link[rel~='icon']");
    if (!link) {
    link = document.createElement('link');
    link.rel = 'icon';
    document.head.appendChild(link);
    }
link.href = '/resource/navpeII_dev18__NavatarLogo';
	}

  
});