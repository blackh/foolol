/*
 * $script.js v 1.1
 * http://dustindiaz.com/scriptjs
 * Copyright: Dustin Diaz 2011
 * License: Creative Commons Attribution: http://creativecommons.org/licenses/by/3.0/
 */
(function(h,m){var k=m.getElementsByTagName("script")[0],i={},a={},d={},o=function(){},c={},p="string",g=false,b,n=[],e=function(){return Array.every||function(f,s){for(var r=0,q=f.length;r<q;++r){if(!s(f[r],r,f)){return 0}}return 1}}(),l=function(f,q){e(f,function(t,s,r){q(t,s,r);return 1})};if(!m.readyState&&m.addEventListener){m.addEventListener("DOMContentLoaded",function j(){m.removeEventListener("DOMContentLoaded",j,g);m.readyState="complete"},g);m.readyState="loading"}h.$script=function(t,q,s){var r=typeof q=="function"?q:(s||o),t=typeof t==p?[t]:t,v=typeof q==p?q:t.join(""),f=t.length,u=function(){if(!--f){i[v]=1;r();for(dset in d){e(dset.split("|"),function(w){return(w in i)})&&e(d[dset],function(w){w();d[dset].shift()})}}};if(a[v]){return}l(t,function(y){if(c[y]){return}else{c[y]=a[v]=1}var x=m.createElement("script"),w=0;setTimeout(function(){x.onload=x.onreadystatechange=function(){if((x.readyState&&!(/loaded|complete/.test(x.readyState)))||w){return}x.onload=x.onreadystatechange=null;w=1;u()};x.async=1;x.src=y;k.parentNode.insertBefore(x,k)},25)});return h};$script.ready=function(s,q,r){r=r||o;s=(typeof s==p)?[s]:s;var f=[];!l(s,function(t){(i[t])||f.push(t)})&&e(s,function(t){return(i[t])})?q():(function(t){d[t]=d[t]||[];d[t].push(q);r(f)}(s.join("|")));return $script};setTimeout(function(){b=/loaded|complete/.test(m.readyState)?!l(n,function(q){q()}):!setTimeout(arguments.callee,1)},1);$script.domReady=function(f){b?f():n.push(f)}}(window,document));