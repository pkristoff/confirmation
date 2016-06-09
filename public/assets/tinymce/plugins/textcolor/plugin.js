tinymce.PluginManager.add("textcolor",function(a){function b(b){var c;return a.dom.getParents(a.selection.getStart(),function(a){var d;(d=a.style["forecolor"==b?"color":"background-color"])&&(c=d)}),c}function c(b){var c,d,e=[];for(d=["000000","Black","993300","Burnt orange","333300","Dark olive","003300","Dark green","003366","Dark azure","000080","Navy Blue","333399","Indigo","333333","Very dark gray","800000","Maroon","FF6600","Orange","808000","Olive","008000","Green","008080","Teal","0000FF","Blue","666699","Grayish blue","808080","Gray","FF0000","Red","FF9900","Amber","99CC00","Yellow green","339966","Sea green","33CCCC","Turquoise","3366FF","Royal blue","800080","Purple","999999","Medium gray","FF00FF","Magenta","FFCC00","Gold","FFFF00","Yellow","00FF00","Lime","00FFFF","Aqua","00CCFF","Sky blue","993366","Red violet","FFFFFF","White","FF99CC","Pink","FFCC99","Peach","FFFF99","Light yellow","CCFFCC","Pale green","CCFFFF","Pale cyan","99CCFF","Light sky blue","CC99FF","Plum"],d=a.settings.textcolor_map||d,d=a.settings[b+"_map"]||d,c=0;c<d.length;c+=2)e.push({text:d[c+1],color:"#"+d[c]});return e}function d(){function b(a,b){var c="transparent"==a;return'<td class="mce-grid-cell'+(c?" mce-colorbtn-trans":"")+'"><div id="'+o+"-"+p++ +'" data-mce-color="'+(a?a:"")+'" role="option" tabIndex="-1" style="'+(a?"background-color: "+a:"")+'" title="'+tinymce.translate(b)+'">'+(c?"&#215;":"")+"</div></td>"}var d,e,f,g,h,k,l,m,n=this,o=n._id,p=0;for(m=n.settings.origin,d=c(m),d.push({text:tinymce.translate("No color"),color:"transparent"}),f='<table class="mce-grid mce-grid-border mce-colorbutton-grid" role="list" cellspacing="0"><tbody>',g=d.length-1,k=0;k<j[m];k++){for(f+="<tr>",h=0;h<i[m];h++)l=k*i[m]+h,l>g?f+="<td></td>":(e=d[l],f+=b(e.color,e.text));f+="</tr>"}if(a.settings.color_picker_callback){for(f+='<tr><td colspan="'+i[m]+'" class="mce-custom-color-btn"><div id="'+o+'-c" class="mce-widget mce-btn mce-btn-small mce-btn-flat" role="button" tabindex="-1" aria-labelledby="'+o+'-c" style="width: 100%"><button type="button" role="presentation" tabindex="-1">'+tinymce.translate("Custom...")+"</button></div></td></tr>",f+="<tr>",h=0;h<i[m];h++)f+=b("","Custom color");f+="</tr>"}return f+="</tbody></table>"}function e(b,c){a.undoManager.transact(function(){a.focus(),a.formatter.apply(b,{value:c}),a.nodeChanged()})}function f(b){a.undoManager.transact(function(){a.focus(),a.formatter.remove(b,{value:null},null,!0),a.nodeChanged()})}function g(c){function d(a){l.hidePanel(),l.color(a),e(l.settings.format,a)}function g(){l.hidePanel(),l.resetColor(),f(l.settings.format)}function h(a,b){a.style.background=b,a.setAttribute("data-mce-color",b)}var j,k,l=this.parent();k=l.settings.origin,tinymce.DOM.getParent(c.target,".mce-custom-color-btn")&&(l.hidePanel(),a.settings.color_picker_callback.call(a,function(a){var b,c,e,f=l.panel.getEl().getElementsByTagName("table")[0];for(b=tinymce.map(f.rows[f.rows.length-1].childNodes,function(a){return a.firstChild}),e=0;e<b.length&&(c=b[e],c.getAttribute("data-mce-color"));e++);if(e==i[k])for(e=0;e<i[k]-1;e++)h(b[e],b[e+1].getAttribute("data-mce-color"));h(c,a),d(a)},b(l.settings.format))),j=c.target.getAttribute("data-mce-color"),j?(this.lastId&&document.getElementById(this.lastId).setAttribute("aria-selected",!1),c.target.setAttribute("aria-selected",!0),this.lastId=c.target.id,"transparent"==j?g():d(j)):null!==j&&l.hidePanel()}function h(){var a=this;a._color?e(a.settings.format,a._color):f(a.settings.format)}var i,j;j={forecolor:a.settings.forecolor_rows||a.settings.textcolor_rows||5,backcolor:a.settings.backcolor_rows||a.settings.textcolor_rows||5},i={forecolor:a.settings.forecolor_cols||a.settings.textcolor_cols||8,backcolor:a.settings.backcolor_cols||a.settings.textcolor_cols||8},a.addButton("forecolor",{type:"colorbutton",tooltip:"Text color",format:"forecolor",panel:{origin:"forecolor",role:"application",ariaRemember:!0,html:d,onclick:g},onclick:h}),a.addButton("backcolor",{type:"colorbutton",tooltip:"Background color",format:"hilitecolor",panel:{origin:"backcolor",role:"application",ariaRemember:!0,html:d,onclick:g},onclick:h})});