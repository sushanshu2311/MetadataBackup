({
	doInit : function(component, event, helper) {
        document.title = "Navatar Support";
         var sPageURL = decodeURIComponent(window.location); //You get the whole decoded URL of the page.
        // var sURLVariables = String(sPageURL).split('&')[1];
        // var helparticlename=(sURLVariables.split('=')[1]).split('.')[0];
        // console.log('ArticleName= ',helparticlename);
        var link = document.querySelector("link[rel~='icon']");
    if (!link) {
        link = document.createElement('link');
        link.rel = 'icon';
        document.head.appendChild(link);
    }
    link.href = '/resource/navpeII_dev18__NavatarIcon';
	}
})