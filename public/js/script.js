function keyHandler(e){var key=window.event?e.keyCode:e.which;switch(key){case 27:{$('body').toggle();}
break;case 37:if(prev!=""){document.location.href=document.URL+"/prev";}
break;case 39:if(next!="")
{document.location.href=document.URL+"/next";}
break;case 18:{document.location.href="/";}
break;}}