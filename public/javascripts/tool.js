// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function disableEnterKey(e)
{
     var key;

     if(window.event)
          key = window.event.keyCode;     //IE
     else
          key = e.which;     //firefox

     if(key == 13)
          return false;
     else
          return true;
};



 //Function to hide one element and show another.  Takes two element id's as params
function swap(id1, id2) {
  var elem1, elem2, vis1, vis2;
  if( document.getElementById ) { // this is the way the standards work
    elem1 = document.getElementById(id1);
    elem2 = document.getElementById(id2);
 
	  if(elem1.className == "hidden" && elem2.className == "shown") {
	    elem1.className = "shown";
	    elem2.className = "hidden";
	  } else {
	    elem1.className = "hidden";
	    elem2.className = "shown";
	  }
  } 
}


/*control showing or hiding the more info popup field on miscellaneous module*/

function show_more(){
  if(document.getElementById('more_info').style.display == 'none')
     {
       document.getElementById('more_info').style.display = 'block';
     }
  
}

function hide_more(){
  if(document.getElementById('more_info').style.display == 'block')
     {
       document.getElementById('more_info').style.display = 'none';
       document.getElementById('mod_more_info').value = "";
       tinyMCE.updateContent('mod_more_info');
     }

}

function checkEm() {
        var checkBoxes = document.getElementsByName('comment_ids[]');
        var checkMaster = $('checkMaster');
        var i = 0;

        if(checkMaster.hasClassName("unchecked")) {
          //We need to do the opposite...check all boxes
          for(i = 0; i < checkBoxes.length; i++) {
            checkBoxes[i].checked = true;
          }
          checkMaster.className = "checked";
        } else if(checkMaster.hasClassName("checked")) {
          //All boxes are checked, so let's uncheck em
          for(i = 0; i < checkBoxes.length; i++) {
            checkBoxes[i].checked = false;
          }
          checkMaster.className = "unchecked";
        }
      }
/*
 *   GBS - Google Book Classes
 *
 *   Copyright 2008 by Godmar Back godmar@gmail.com 
 *
 *   License: This software is released under the LGPL license,
 *   See http://www.gnu.org/licenses/lgpl.txt
 *
 *   $Id: gbsclasses.js,v 1.6 2008/04/27 03:17:14 gback Exp gback $
 *
 *   Instructions:
 *   ------------
 *
 *  Add <script type="text/javascript" src="gbsclasses.js"></script>
 *  to your document.
 */

(function() {

gbs = {
    isReady: false,
    readyListeners: new Array()
};

/*****************************************************************/
/*
 * Add an event handler, browser-compatible.
 * This code taken from http://www.dustindiaz.com/rock-solid-addevent/
 * See also http://www.quirksmode.org/js/events_compinfo.html
 *          http://novemberborn.net/javascript/event-cache
 */
function addEvent( obj, type, fn ) {
        if (obj.addEventListener) {
                obj.addEventListener( type, fn, false );
                EventCache.add(obj, type, fn);
        }
        else if (obj.attachEvent) {
                obj["e"+type+fn] = fn;
                obj[type+fn] = function() { obj["e"+type+fn]( window.event ); }
                obj.attachEvent( "on"+type, obj[type+fn] );
                EventCache.add(obj, type, fn);
        }
        else {
                obj["on"+type] = obj["e"+type+fn];
        }
}

/* unload all event handlers on page unload to avoid memory leaks */
var EventCache = function(){
        var listEvents = [];
        return {
                listEvents : listEvents,
                add : function(node, sEventName, fHandler){
                        listEvents.push(arguments);
                },
                flush : function(){
                        var i, item;
                        for(i = listEvents.length - 1; i >= 0; i = i - 1){
                                item = listEvents[i];
                                if(item[0].removeEventListener){
                                        item[0].removeEventListener(item[1], item[2], item[3]);
                                };
                                if(item[1].substring(0, 2) != "on"){
                                        item[1] = "on" + item[1];
                                };
                                if(item[0].detachEvent){
                                        item[0].detachEvent(item[1], item[2]);
                                };
                                item[0][item[1]] = null;
                        };
                }
        };
}();
addEvent(window,'unload',EventCache.flush);
// end of rock-solid addEvent

/**
 * Browser sniffing and document.ready code taken from jQuery.
 *
 * Source: jQuery (jquery.com) 
 * Copyright (c) 2008 John Resig (jquery.com)
 */
var userAgent = navigator.userAgent.toLowerCase();

// Figure out what browser is being used
gbs.browser = {
	version: (userAgent.match( /.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/ ) || [])[1],
	safari: /webkit/.test( userAgent ),
	opera: /opera/.test( userAgent ),
	msie: /msie/.test( userAgent ) && !/opera/.test( userAgent ),
	mozilla: /mozilla/.test( userAgent ) && !/(compatible|webkit)/.test( userAgent )
};

function bindReady() {
	// Mozilla, Opera (see further below for it) and webkit nightlies currently support this event
	if ( document.addEventListener && !gbs.browser.opera)
		// Use the handy event callback
		document.addEventListener( "DOMContentLoaded", gbs.ready, false );
	
	// If IE is used and is not in a frame
	// Continually check to see if the document is ready
	if ( gbs.browser.msie && window == top ) (function(){
		if (gbs.isReady) return;
		try {
			// If IE is used, use the trick by Diego Perini
			// http://javascript.nwbox.com/IEContentLoaded/
			document.documentElement.doScroll("left");
		} catch( error ) {
			setTimeout( arguments.callee, 0 );
			return;
		}
		// and execute any waiting functions
		gbs.ready();
	})();

	if ( gbs.browser.opera )
		document.addEventListener( "DOMContentLoaded", function () {
			if (gbs.isReady) return;
			for (var i = 0; i < document.styleSheets.length; i++)
				if (document.styleSheets[i].disabled) {
					setTimeout( arguments.callee, 0 );
					return;
				}
			// and execute any waiting functions
			gbs.ready();
		}, false);

	if ( gbs.browser.safari ) {
		//var numStyles;
		(function(){
			if (gbs.isReady) return;
			if ( document.readyState != "loaded" && document.readyState != "complete" ) {
				setTimeout( arguments.callee, 0 );
				return;
			}
                        /*
			if ( numStyles === undefined )
				numStyles = jQuery("style, link[rel=stylesheet]").length;
			if ( document.styleSheets.length != numStyles ) {
				setTimeout( arguments.callee, 0 );
				return;
			}
                        */
			// and execute any waiting functions
			gbs.ready();
		})();
	}

	// A fallback to window.onload, that will always work
        addEvent(window, "load", gbs.ready);
}

// end of code taken from jQuery

gbs.ready = function () {
    if (gbs.isReady)
        return;
    gbs.isReady = true;

    for (var i = 0; i < gbs.readyListeners.length; i++) {
        gbs.readyListeners[i]();
    }
}

function trim(s) { 
    return s.replace(/^\s+|\s+$/g, ''); 
};

// Begin GBS code
var gbsKey2Req;         // map gbsKey -> Array<Request>
gbs.ProcessResults = function (bookInfo) {
    for (var i in bookInfo) {
        var result = bookInfo[i];
        // alert("result found for: " + result.bib_key + " " + result.preview);
        req = gbsKey2Req[result.bib_key];
        if (req == null) {
            continue;
        }

        for (var j = 0; j < req.length; j++) {
            req[j].onsuccess(result);
        }
        delete gbsKey2Req[result.bib_key];
    }

    for (var i in gbsKey2Req) {
        req = gbsKey2Req[i];
        if (req == null)
            continue;

        for (var j = 0; j < req.length; j++) {
            req[j].onfailure();
        }
        delete gbsKey2Req[i];
    }
}

// process all spans in a document
function gbsProcessSpans(spanElems) {
    gbsKey2Req = new Object();
    while (spanElems.length > 0) {
        var spanElem = spanElems.pop();
        if (spanElem.expanded)
            continue;

        gbsProcessSpan(spanElem);
    }

    var bibkeys = new Array();
    for (var k in gbsKey2Req)
        bibkeys.push(k);

    if (bibkeys.length == 0)
        return;

    bibkeys = bibkeys.join(",");
    var s = document.createElement("script");
    s.setAttribute("type", "text/javascript");
    // alert("searching for: " + bibkeys);
    s.setAttribute("src", "http://books.google.com/books?jscmd=viewapi&bibkeys=" + bibkeys + "&callback=gbs.ProcessResults");
    document.documentElement.firstChild.appendChild(s);
}

// process a single span
function gbsProcessSpan(spanElem) {
    var cName = spanElem.className;
    if (cName == null)
        return;

    var mReq = {
        span: spanElem, 
        removeTitle: function () {
            this.span.setAttribute('title', '');
        },
        success: new Array(),
        failure: new Array(),
        onsuccess: function (result) {
            for (var i = 0; i < this.success.length; i++)
                try {
                    this.success[i](this, result);
                } catch (er) { }
            this.removeTitle();
        },
        onfailure: function (status) {
            for (var i = 0; i < this.failure.length; i++)
                try {
                    this.failure[i](this, status);
                } catch (er) { }
            this.removeTitle();
        },
        /* get the search item that's sent to GBS
         * The search term may be in the title, or in the body.
         * It's in the body if the title contains a "*".
         * Example:  
         *           <span title="ISBN:0743226720"></span>
         *           <span title="*">ISBN:0743226720</span>
         */
        getSearchItem: function () {
            if (this.searchitem === undefined) {
                var req = this.span.getAttribute('title');
                if (req == "*" || req == "OCLC:*" || req == "LCCN:*") {
                    var text = this.span.innerText || this.span.textContent || "";
                    text = trim(text);
                    this.searchitem = text;     // default

                    switch (req) {
                    case "*":
                        var m = text.match(/^((\d|x){10,13}).*/i);
                        if (m) {
                            this.searchitem = "ISBN:" + m[1];
                        }
                        break;

                    case  "OCLC:*":
                        text = text.replace(/^ocm/, "");
                        this.searchitem = "OCLC:" + text;
                        break;

                    case  "LCCN:*":
                        this.searchitem = "LCCN:" + text;
                        break;
                    }

                    // remove first child only
                    if (this.span.hasChildNodes())
                        this.span.removeChild(this.span.firstChild);
                } else
                    this.searchitem = req.toLowerCase();
            }
            return this.searchitem;
        }
    };

    // wrap the span element in a link to bookinfo[bookInfoProp]
    function linkTo(mReq, bookInfoProp) {
        mReq.success.push(function (mReq, bookinfo) {
            if (bookinfo[bookInfoProp] === undefined)
                return;

            var p = mReq.span.parentNode;
            var s = mReq.span.nextSibling;
            p.removeChild(mReq.span);
            var a = document.createElement("a");
            a.setAttribute("href", bookinfo[bookInfoProp]);
            a.appendChild(mReq.span);
            p.insertBefore(a, s);
        });
    }

    /**
     * See: http://code.google.com/apis/books/getting-started.html
        bib_key
            The identifier used to query this book.
        info_url
            A URL to a page within Google Book Search with information on the book (the about this book page)
        preview_url
            A URL to the preview of the book - this lands the user on the cover of the book. 
            If there only Snippet View or Metadata View books available for a request, no preview url 
            will be returned.
        thumbnail_url
            A URL to a thumbnail of the cover of the book.
        preview
            Viewability state - either "noview", "partial", or "full"
     */
    function addHandler(gbsClass, mReq) {
        switch (gbsClass) {
        case "gbs-thumbnail":
        case "gbs-thumbnail-large":
            mReq.success.push(function (mReq, bookinfo) {
                if (bookinfo.thumbnail_url) {
                    var img = document.createElement("img");
                    var imgurl = bookinfo.thumbnail_url;
                    if (gbsClass == "gbs-thumbnail-large") {
                        imgurl = imgurl.replace(/&zoom=5&/, "&zoom=1&")
                                       .replace(/&pg=PP1&/, "&printsec=frontcover&");
                    }
                    img.setAttribute("src", imgurl);
                    mReq.span.appendChild(img);
                }
            });
            break;

        case "gbs-link-to-preview":
            linkTo(mReq, 'preview_url');
            break;

        case "gbs-link-to-info":
            linkTo(mReq, 'info_url');
            break;

        case "gbs-link-to-thumbnail":
            linkTo(mReq, 'thumbnail_url');
            break;

        case "gbs-if-noview":
        case "gbs-if-partial-or-full":
        case "gbs-if-partial":
        case "gbs-if-full":
            mReq.gbsif = gbsClass.replace(/gbs-if-/, "");
            mReq.success.push(function (mReq, bookinfo) {
                if (mReq.gbsif == "partial-or-full") {
                    var keep = bookinfo.preview == "partial" || bookinfo.preview == "full";
                } else {
                    var keep = bookinfo.preview == mReq.gbsif;
                }
                // remove if availability doesn't match the requested
                if (!keep) {
                    mReq.span.parentNode.removeChild(mReq.span);
                } else {
                    // else, if span was previously hidden, set visibility to "inline"
                    if (mReq.span.style.display == "none") {
                        mReq.span.style.display = "inline";
                    }
                }
            });
            break;

        case "gbs-remove-on-failure":
            mReq.failure.push(function (mReq, status) {
                mReq.span.parentNode.removeChild(mReq.span);
            });
            break;
        // XXX add more here

        default:
            return false;
        }
        return true;
    }

    var isGBS = false;
    var classEntries = cName.split(/\s+/);
    for (var i = 0; i < classEntries.length; i++) {
        if (addHandler(classEntries[i], mReq))
            isGBS = true;
    }

    if (!isGBS)
        return;

    var bibkey = mReq.getSearchItem();
    if (gbsKey2Req[bibkey] === undefined) {
        gbsKey2Req[bibkey] = [ mReq ];
    } else {
        gbsKey2Req[bibkey].push(mReq);
    }
    mReq.span.expanded = true;
}

function gbsReady() {
    var span = document.getElementsByTagName("span");
    var spanElems = new Array();
    for (var i = 0; i < span.length; i++) {
        spanElems[i] = span[span.length - 1 - i];
    }
    gbsProcessSpans(spanElems);
}

gbs.readyListeners.push(gbsReady);

bindReady();

})();



/***********************************************
* Fixed ToolTip script- © Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/
		
var tipwidth='250px' //default tooltip width
var tipbgcolor='white'  //tooltip bgcolor
var disappeardelay=250  //tooltip disappear speed onMouseout (in miliseconds)
var vertical_offset="5px" //horizontal offset of tooltip from anchor link
var horizontal_offset="5px" //horizontal offset of tooltip from anchor link

/////No further editting needed

var ie4=document.all
var ns6=document.getElementById&&!document.all

if (ie4||ns6)
document.write('<div id="fixedtipdiv" style="visibility:hidden;width:'+tipwidth+';background-color:'+tipbgcolor+'" ></div>')

function getposOffset(what, offsettype){
var totaloffset=(offsettype=="left")? what.offsetLeft : what.offsetTop;
var parentEl=what.offsetParent;
while (parentEl!=null){
totaloffset=(offsettype=="left")? totaloffset+parentEl.offsetLeft : totaloffset+parentEl.offsetTop;
parentEl=parentEl.offsetParent;
}
return totaloffset;
}


function showhide(obj, e, visible, hidden, tipwidth){
if (ie4||ns6)
dropmenuobj.style.left=dropmenuobj.style.top=-500
if (tipwidth!=""){
dropmenuobj.widthobj=dropmenuobj.style
dropmenuobj.widthobj.width=tipwidth
}
if (e.type=="click" && obj.visibility==hidden || e.type=="mouseover")
obj.visibility=visible
else if (e.type=="click")
obj.visibility=hidden
}

function iecompattest(){
return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function clearbrowseredge(obj, whichedge){
var edgeoffset=(whichedge=="rightedge")? parseInt(horizontal_offset)*-1 : parseInt(vertical_offset)*-1
if (whichedge=="rightedge"){
var windowedge=ie4 && !window.opera? iecompattest().scrollLeft+iecompattest().clientWidth-15 : window.pageXOffset+window.innerWidth-15
dropmenuobj.contentmeasure=dropmenuobj.offsetWidth
if (windowedge-dropmenuobj.x < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure-obj.offsetWidth
}
else{
var windowedge=ie4 && !window.opera? iecompattest().scrollTop+iecompattest().clientHeight-15 : window.pageYOffset+window.innerHeight-18
dropmenuobj.contentmeasure=dropmenuobj.offsetHeight
if (windowedge-dropmenuobj.y < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure+obj.offsetHeight
}
return edgeoffset
}

function fixedtooltip(menucontents, obj, e, tipwidth){
if (window.event) event.cancelBubble=true
else if (e.stopPropagation) e.stopPropagation()
clearhidetip()
dropmenuobj=document.getElementById? document.getElementById("fixedtipdiv") : fixedtipdiv
dropmenuobj.innerHTML=menucontents

if (ie4||ns6){
showhide(dropmenuobj.style, e, "visible", "hidden", tipwidth)
dropmenuobj.x=getposOffset(obj, "left")
dropmenuobj.y=getposOffset(obj, "top")
dropmenuobj.style.left=dropmenuobj.x-clearbrowseredge(obj, "rightedge")+"px"
dropmenuobj.style.top=dropmenuobj.y-clearbrowseredge(obj, "bottomedge")+obj.offsetHeight+"px"
}
}

function hidetip(e){
if (typeof dropmenuobj!="undefined"){
if (ie4||ns6)
dropmenuobj.style.visibility="hidden"
}
}

function delayhidetip(){
if (ie4||ns6)
delayhide=setTimeout("hidetip()",disappeardelay)
}

function clearhidetip(){
if (typeof delayhide!="undefined")
clearTimeout(delayhide)
}

