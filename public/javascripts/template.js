//open links in new window
//<a href="document.html" rel="external">external link</a>

function externalLinks() {  
 if (!document.getElementsByTagName) return;  
 var anchors = document.getElementsByTagName("a");  
 for (var i=0; i<anchors.length; i++) {  
   var anchor = anchors[i];  
   if (anchor.getAttribute("href") &&  
       anchor.getAttribute("rel") == "external")  
     anchor.target = "_blank";  
 }  
}  
window.onload = externalLinks;

 //Function to hide one element and show another.  Takes two element id's as params. Used in comments
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



// -------------------------------------------------------------------
// Switch Content Script- By Dynamic Drive, available at: http://www.dynamicdrive.com
// Created: Jan 5th, 2007
// April 5th, 07: Added ability to persist content states by x days versus just session only
// March 27th, 08': Added ability for certain headers to get its contents remotely from an external file via Ajax (2 variables below to customize)
// -------------------------------------------------------------------

var switchcontent_ajax_msg='<em>Loading...</em>' //Customize message to show while fetching Ajax content (if applicable)
var switchcontent_ajax_bustcache=true //Bust cache and refresh fetched Ajax contents when page is reloaded/ viewed again?

function switchcontent(className, filtertag){
	this.className=className
	this.collapsePrev=false //Default: Collapse previous content each time
	this.persistType="none" //Default: Disable persistence
	//Limit type of element to scan for on page for switch contents if 2nd function parameter is defined, for efficiency sake (ie: "div")
	this.filter_content_tag=(typeof filtertag!="undefined")? filtertag.toLowerCase() : ""
	this.ajaxheaders={} //object to hold path to ajax content for corresponding header (ie: ajaxheaders["header1"]='external.htm')
}

switchcontent.prototype.setStatus=function(openHTML, closeHTML){ //PUBLIC: Set open/ closing HTML indicator. Optional
	this.statusOpen=openHTML
	this.statusClosed=closeHTML
}

switchcontent.prototype.setColor=function(openColor, closeColor){ //PUBLIC: Set open/ closing color of switch header. Optional
	this.colorOpen=openColor
	this.colorClosed=closeColor
}

switchcontent.prototype.setPersist=function(bool, days){ //PUBLIC: Enable/ disable persistence. Default is false.
	if (bool==true){ //if enable persistence
		if (typeof days=="undefined") //if session only
			this.persistType="session"
		else{ //else if non session persistent
			this.persistType="days"
			this.persistDays=parseInt(days)
		}
	}
	else
		this.persistType="none"
}

switchcontent.prototype.collapsePrevious=function(bool){ //PUBLIC: Enable/ disable collapse previous content. Default is false.
	this.collapsePrev=bool
}

switchcontent.prototype.setContent=function(index, filepath){ //PUBLIC: Set path to ajax content for corresponding header based on header index
	this.ajaxheaders["header"+index]=filepath
}

switchcontent.prototype.sweepToggle=function(setting){ //PUBLIC: Expand/ contract all contents method. (Values: "contract"|"expand")
	if (typeof this.headers!="undefined" && this.headers.length>0){ //if there are switch contents defined on the page
		for (var i=0; i<this.headers.length; i++){
			if (setting=="expand")
				this.expandcontent(this.headers[i]) //expand each content
			else if (setting=="contract")
				this.contractcontent(this.headers[i]) //contract each content
		}
	}
}


switchcontent.prototype.defaultExpanded=function(){ //PUBLIC: Set contents that should be expanded by default when the page loads (ie: defaultExpanded(0,2,3)). Persistence if enabled overrides this setting.
	var expandedindices=[] //Array to hold indices (position) of content to be expanded by default
	//Loop through function arguments, and store each one within array
	//Two test conditions: 1) End of Arguments array, or 2) If "collapsePrev" is enabled, only the first entered index (as only 1 content can be expanded at any time)
	for (var i=0; (!this.collapsePrev && i<arguments.length) || (this.collapsePrev && i==0); i++)
		expandedindices[expandedindices.length]=arguments[i]
	this.expandedindices=expandedindices.join(",") //convert array into a string of the format: "0,2,3" for later parsing by script
}


//PRIVATE: Sets color of switch header.

switchcontent.prototype.togglecolor=function(header, status){
	if (typeof this.colorOpen!="undefined")
		header.style.color=status
}


//PRIVATE: Sets status indicator HTML of switch header.

switchcontent.prototype.togglestatus=function(header, status){
	if (typeof this.statusOpen!="undefined")
		header.firstChild.innerHTML=status
}


//PRIVATE: Contracts a content based on its corresponding header entered

switchcontent.prototype.contractcontent=function(header){
	var innercontent=document.getElementById(header.id.replace("-title", "")) //Reference content container for this header
	innercontent.style.display="none"
	this.togglestatus(header, this.statusClosed)
	this.togglecolor(header, this.colorClosed)
}


//PRIVATE: Expands a content based on its corresponding header entered

switchcontent.prototype.expandcontent=function(header){
	var innercontent=document.getElementById(header.id.replace("-title", ""))
	if (header.ajaxstatus=="waiting"){//if this is an Ajax header AND remote content hasn't already been fetched
		switchcontent.connect(header.ajaxfile, header)
	}
	innercontent.style.display="block"
	this.togglestatus(header, this.statusOpen)
	this.togglecolor(header, this.colorOpen)
}

// -------------------------------------------------------------------
// PRIVATE: toggledisplay(header)- Toggles between a content being expanded or contracted
// If "Collapse Previous" is enabled, contracts previous open content before expanding current
// -------------------------------------------------------------------

switchcontent.prototype.toggledisplay=function(header){
	var innercontent=document.getElementById(header.id.replace("-title", "")) //Reference content container for this header
	if (innercontent.style.display=="block")
		this.contractcontent(header)
	else{
		this.expandcontent(header)
		if (this.collapsePrev && typeof this.prevHeader!="undefined" && this.prevHeader.id!=header.id) // If "Collapse Previous" is enabled and there's a previous open content
			this.contractcontent(this.prevHeader) //Contract that content first
	}
	if (this.collapsePrev)
		this.prevHeader=header //Set current expanded content as the next "Previous Content"
}


// -------------------------------------------------------------------
// PRIVATE: collectElementbyClass()- Searches and stores all switch contents (based on shared class name) and their headers in two arrays
// Each content should carry an unique ID, and for its header, an ID equal to "CONTENTID-TITLE"
// -------------------------------------------------------------------

switchcontent.prototype.collectElementbyClass=function(classname){ //Returns an array containing DIVs with specified classname
	var classnameRE=new RegExp("(^|\\s+)"+classname+"($|\\s+)", "i") //regular expression to screen for classname within element
	this.headers=[], this.innercontents=[]
	if (this.filter_content_tag!="") //If user defined limit type of element to scan for to a certain element (ie: "div" only)
		var allelements=document.getElementsByTagName(this.filter_content_tag)
	else //else, scan all elements on the page!
		var allelements=document.all? document.all : document.getElementsByTagName("*")
	for (var i=0; i<allelements.length; i++){
		if (typeof allelements[i].className=="string" && allelements[i].className.search(classnameRE)!=-1){
			if (document.getElementById(allelements[i].id+"-title")!=null){ //if header exists for this inner content
				this.headers[this.headers.length]=document.getElementById(allelements[i].id+"-title") //store reference to header intended for this inner content
				this.innercontents[this.innercontents.length]=allelements[i] //store reference to this inner content
			}
		}
	}
}


//PRIVATE: init()- Initializes Switch Content function (collapse contents by default unless exception is found)

switchcontent.prototype.init=function(){
	var instanceOf=this
	this.collectElementbyClass(this.className) //Get all headers and its corresponding content based on shared class name of contents
	if (this.headers.length==0) //If no headers are present (no contents to switch), just exit
		return
	//If admin has changed number of days to persist from current cookie records, reset persistence by deleting cookie
	if (this.persistType=="days" && (parseInt(switchcontent.getCookie(this.className+"_dtrack"))!=this.persistDays))
		switchcontent.setCookie(this.className+"_d", "", -1) //delete cookie
	// Get ids of open contents below. Four possible scenerios:
	// 1) Session only persistence is enabled AND corresponding cookie contains a non blank ("") string
	// 2) Regular (in days) persistence is enabled AND corresponding cookie contains a non blank ("") string
	// 3) If there are contents that should be enabled by default (even if persistence is enabled and this IS the first page load)
	// 4) Default to no contents should be expanded on page load ("" value)
	var opencontents_ids=(this.persistType=="session" && switchcontent.getCookie(this.className)!="")? ','+switchcontent.getCookie(this.className)+',' : (this.persistType=="days" && switchcontent.getCookie(this.className+"_d")!="")? ','+switchcontent.getCookie(this.className+"_d")+',' : (this.expandedindices)? ','+this.expandedindices+',' : ""
	for (var i=0; i<this.headers.length; i++){ //BEGIN FOR LOOP
		if (typeof this.ajaxheaders["header"+i]!="undefined"){ //if this is an Ajax header
			this.headers[i].ajaxstatus='waiting' //two possible statuses: "waiting" and "loaded"
			this.headers[i].ajaxfile=this.ajaxheaders["header"+i]
		}
		if (typeof this.statusOpen!="undefined") //If open/ closing HTML indicator is enabled/ set
			this.headers[i].innerHTML='<span class="status"></span>'+this.headers[i].innerHTML //Add a span element to original HTML to store indicator
		if (opencontents_ids.indexOf(','+i+',')!=-1){ //if index "i" exists within cookie string or default-enabled string (i=position of the content to expand)
			this.expandcontent(this.headers[i]) //Expand each content per stored indices (if ""Collapse Previous" is set, only one content)
			if (this.collapsePrev) //If "Collapse Previous" set
			this.prevHeader=this.headers[i]  //Indicate the expanded content's corresponding header as the last clicked on header (for logic purpose)
		}
		else //else if no indices found in stored string
			this.contractcontent(this.headers[i]) //Contract each content by default
		this.headers[i].onclick=function(){instanceOf.toggledisplay(this)}
	} //END FOR LOOP
	switchcontent.dotask(window, function(){instanceOf.rememberpluscleanup()}, "unload") //Call persistence method onunload
}


// -------------------------------------------------------------------
// PRIVATE: rememberpluscleanup()- Stores the indices of content that are expanded inside session only cookie
// If "Collapse Previous" is enabled, only 1st expanded content index is stored
// -------------------------------------------------------------------

//Function to store index of opened ULs relative to other ULs in Tree into cookie:
switchcontent.prototype.rememberpluscleanup=function(){
	//Define array to hold ids of open content that should be persisted
	//Default to just "none" to account for the case where no contents are open when user leaves the page (and persist that):
	var opencontents=new Array("none")
	for (var i=0; i<this.innercontents.length; i++){
		//If persistence enabled, content in question is expanded, and either "Collapse Previous" is disabled, or if enabled, this is the first expanded content
		if (this.persistType!="none" && this.innercontents[i].style.display=="block" && (!this.collapsePrev || (this.collapsePrev && opencontents.length<2)))
			opencontents[opencontents.length]=i //save the index of the opened UL (relative to the entire list of ULs) as an array element
		this.headers[i].onclick=null //Cleanup code
	}
	if (opencontents.length>1) //If there exists open content to be persisted
		opencontents.shift() //Boot the "none" value from the array, so all it contains are the ids of the open contents
	if (typeof this.statusOpen!="undefined")
		this.statusOpen=this.statusClosed=null //Cleanup code
	if (this.persistType=="session") //if session only cookie set
		switchcontent.setCookie(this.className, opencontents.join(",")) //populate cookie with indices of open contents: classname=1,2,3,etc
	else if (this.persistType=="days" && typeof this.persistDays=="number"){ //if persistent cookie set instead
		switchcontent.setCookie(this.className+"_d", opencontents.join(","), this.persistDays) //populate cookie with indices of open contents
		switchcontent.setCookie(this.className+"_dtrack", this.persistDays, this.persistDays) //also remember number of days to persist (int)
	}
}


// -------------------------------------------------------------------
// A few utility functions below:
// -------------------------------------------------------------------


switchcontent.dotask=function(target, functionref, tasktype){ //assign a function to execute to an event handler (ie: onunload)
	var tasktype=(window.addEventListener)? tasktype : "on"+tasktype
	if (target.addEventListener)
		target.addEventListener(tasktype, functionref, false)
	else if (target.attachEvent)
		target.attachEvent(tasktype, functionref)
}

switchcontent.connect=function(pageurl, header){
	var page_request = false
	var bustcacheparameter=""
	if (window.ActiveXObject){ //Test for support for ActiveXObject in IE first (as XMLHttpRequest in IE7 is broken)
		try {
		page_request = new ActiveXObject("Msxml2.XMLHTTP")
		} 
		catch (e){
			try{
			page_request = new ActiveXObject("Microsoft.XMLHTTP")
			}
			catch (e){}
		}
	}
	else if (window.XMLHttpRequest) // if Mozilla, Safari etc
		page_request = new XMLHttpRequest()
	else
		return false
	page_request.onreadystatechange=function(){switchcontent.loadpage(page_request, header)}
	if (switchcontent_ajax_bustcache) //if bust caching of external page
		bustcacheparameter=(pageurl.indexOf("?")!=-1)? "&"+new Date().getTime() : "?"+new Date().getTime()
	page_request.open('GET', pageurl+bustcacheparameter, true)
	page_request.send(null)
}

switchcontent.loadpage=function(page_request, header){
	var innercontent=document.getElementById(header.id.replace("-title", "")) //Reference content container for this header
	innercontent.innerHTML=switchcontent_ajax_msg //Display "fetching page message"
	if (page_request.readyState == 4 && (page_request.status==200 || window.location.href.indexOf("http")==-1)){
		innercontent.innerHTML=page_request.responseText
		header.ajaxstatus="loaded"
	}
}

switchcontent.getCookie=function(Name){ 
	var re=new RegExp(Name+"=[^;]+", "i"); //construct RE to search for target name/value pair
	if (document.cookie.match(re)) //if cookie found
		return document.cookie.match(re)[0].split("=")[1] //return its value
	return ""
}

switchcontent.setCookie=function(name, value, days){
	if (typeof days!="undefined"){ //if set persistent cookie
		var expireDate = new Date()
		var expstring=expireDate.setDate(expireDate.getDate()+days)
		document.cookie = name+"="+value+"; expires="+expireDate.toGMTString()
	}
	else //else if this is a session only cookie
		document.cookie = name+"="+value
}

// -------------------------------------------------------------------
// Switch Content Script II (icon based)- By Dynamic Drive, available at: http://www.dynamicdrive.com
// April 8th, 07: Requires switchcontent.js!
// March 27th, 08': Added ability for certain headers to get its contents remotely from an external file via Ajax (2 variables within switchcontent.js to customize)
// -------------------------------------------------------------------

function switchicon(className, filtertag){
	switchcontent.call(this, className, filtertag) //inherit primary properties from switchcontent class
}

switchicon.prototype=new switchcontent //inherit methods from switchcontent class with its properties initialized already
switchicon.prototype.constructor=switchicon

switchicon.prototype.setStatus=null
switchicon.prototype.setColor=null

switchicon.prototype.setHeader=function(openHTML, closeHTML){ //PUBLIC
	this.openHTML=openHTML
	this.closeHTML=closeHTML
}

//PRIVATE: Contracts a content based on its corresponding header entered

switchicon.prototype.contractcontent=function(header){
	var innercontent=document.getElementById(header.id.replace("-title", "")) //Reference content for this header
	innercontent.style.display="none"
	header.innerHTML=this.closeHTML
	header=null
}


//PRIVATE: Expands a content based on its corresponding header entered

switchicon.prototype.expandcontent=function(header){
	var innercontent=document.getElementById(header.id.replace("-title", ""))
	if (header.ajaxstatus=="waiting"){//if this is an Ajax header AND remote content hasn't already been fetched
		switchcontent.connect(header.ajaxfile, header)
	}
	innercontent.style.display="block"
	header.innerHTML=this.openHTML
	header=null
}

//** Tab Content script v2.0- © Dynamic Drive DHTML code library (http://www.dynamicdrive.com)
//** Updated Oct 7th, 07 to version 2.0. Contains numerous improvements:
//   -Added Auto Mode: Script auto rotates the tabs based on an interval, until a tab is explicitly selected
//   -Ability to expand/contract arbitrary DIVs on the page as the tabbed content is expanded/ contracted
//   -Ability to dynamically select a tab either based on its position within its peers, or its ID attribute (give the target tab one 1st)
//   -Ability to set where the CSS classname "selected" get assigned- either to the target tab's link ("A"), or its parent container
//** Updated Feb 18th, 08 to version 2.1: Adds a "tabinstance.cycleit(dir)" method to cycle forward or backward between tabs dynamically
//** Updated April 8th, 08 to version 2.2: Adds support for expanding a tab using a URL parameter (ie: http://mysite.com/tabcontent.htm?tabinterfaceid=0) 

////NO NEED TO EDIT BELOW////////////////////////

function ddtabcontent(tabinterfaceid){
	this.tabinterfaceid=tabinterfaceid //ID of Tab Menu main container
	this.tabs=document.getElementById(tabinterfaceid).getElementsByTagName("a") //Get all tab links within container
	this.enabletabpersistence=true
	this.hottabspositions=[] //Array to store position of tabs that have a "rel" attr defined, relative to all tab links, within container
	this.currentTabIndex=0 //Index of currently selected hot tab (tab with sub content) within hottabspositions[] array
	this.subcontentids=[] //Array to store ids of the sub contents ("rel" attr values)
	this.revcontentids=[] //Array to store ids of arbitrary contents to expand/contact as well ("rev" attr values)
	this.selectedClassTarget="link" //keyword to indicate which target element to assign "selected" CSS class ("linkparent" or "link")
}

ddtabcontent.getCookie=function(Name){ 
	var re=new RegExp(Name+"=[^;]+", "i"); //construct RE to search for target name/value pair
	if (document.cookie.match(re)) //if cookie found
		return document.cookie.match(re)[0].split("=")[1] //return its value
	return ""
}

ddtabcontent.setCookie=function(name, value){
	document.cookie = name+"="+value+";path=/" //cookie value is domain wide (path=/)
}

ddtabcontent.prototype={

	expandit:function(tabid_or_position){ //PUBLIC function to select a tab either by its ID or position(int) within its peers
		this.cancelautorun() //stop auto cycling of tabs (if running)
		var tabref=""
		try{
			if (typeof tabid_or_position=="string" && document.getElementById(tabid_or_position).getAttribute("rel")) //if specified tab contains "rel" attr
				tabref=document.getElementById(tabid_or_position)
			else if (parseInt(tabid_or_position)!=NaN && this.tabs[tabid_or_position].getAttribute("rel")) //if specified tab contains "rel" attr
				tabref=this.tabs[tabid_or_position]
		}
		catch(err){alert("Invalid Tab ID or position entered!")}
		if (tabref!="") //if a valid tab is found based on function parameter
			this.expandtab(tabref) //expand this tab
	},

	cycleit:function(dir, autorun){ //PUBLIC function to move foward or backwards through each hot tab (tabinstance.cycleit('foward/back') )
		if (dir=="next"){
			var currentTabIndex=(this.currentTabIndex<this.hottabspositions.length-1)? this.currentTabIndex+1 : 0
		}
		else if (dir=="prev"){
			var currentTabIndex=(this.currentTabIndex>0)? this.currentTabIndex-1 : this.hottabspositions.length-1
		}
		if (typeof autorun=="undefined") //if cycleit() is being called by user, versus autorun() function
			this.cancelautorun() //stop auto cycling of tabs (if running)
		this.expandtab(this.tabs[this.hottabspositions[currentTabIndex]])
	},

	setpersist:function(bool){ //PUBLIC function to toggle persistence feature
			this.enabletabpersistence=bool
	},

	setselectedClassTarget:function(objstr){ //PUBLIC function to set which target element to assign "selected" CSS class ("linkparent" or "link")
		this.selectedClassTarget=objstr || "link"
	},

	getselectedClassTarget:function(tabref){ //Returns target element to assign "selected" CSS class to
		return (this.selectedClassTarget==("linkparent".toLowerCase()))? tabref.parentNode : tabref
	},

	urlparamselect:function(tabinterfaceid){
		var result=window.location.search.match(new RegExp(tabinterfaceid+"=(\\d+)", "i")) //check for "?tabinterfaceid=2" in URL
		return (result==null)? null : parseInt(RegExp.$1) //returns null or index, where index (int) is the selected tab's index
	},

	expandtab:function(tabref){
		var subcontentid=tabref.getAttribute("rel") //Get id of subcontent to expand
		//Get "rev" attr as a string of IDs in the format ",john,george,trey,etc," to easily search through
		var associatedrevids=(tabref.getAttribute("rev"))? ","+tabref.getAttribute("rev").replace(/\s+/, "")+"," : ""
		this.expandsubcontent(subcontentid)
		this.expandrevcontent(associatedrevids)
		for (var i=0; i<this.tabs.length; i++){ //Loop through all tabs, and assign only the selected tab the CSS class "selected"
			this.getselectedClassTarget(this.tabs[i]).className=(this.tabs[i].getAttribute("rel")==subcontentid)? "selected" : ""
		}
		if (this.enabletabpersistence) //if persistence enabled, save selected tab position(int) relative to its peers
			ddtabcontent.setCookie(this.tabinterfaceid, tabref.tabposition)
		this.setcurrenttabindex(tabref.tabposition) //remember position of selected tab within hottabspositions[] array
	},

	expandsubcontent:function(subcontentid){
		for (var i=0; i<this.subcontentids.length; i++){
			var subcontent=document.getElementById(this.subcontentids[i]) //cache current subcontent obj (in for loop)
			subcontent.style.display=(subcontent.id==subcontentid)? "block" : "none" //"show" or hide sub content based on matching id attr value
		}
	},

	expandrevcontent:function(associatedrevids){
		var allrevids=this.revcontentids
		for (var i=0; i<allrevids.length; i++){ //Loop through rev attributes for all tabs in this tab interface
			//if any values stored within associatedrevids matches one within allrevids, expand that DIV, otherwise, contract it
			document.getElementById(allrevids[i]).style.display=(associatedrevids.indexOf(","+allrevids[i]+",")!=-1)? "block" : "none"
		}
	},

	setcurrenttabindex:function(tabposition){ //store current position of tab (within hottabspositions[] array)
		for (var i=0; i<this.hottabspositions.length; i++){
			if (tabposition==this.hottabspositions[i]){
				this.currentTabIndex=i
				break
			}
		}
	},

	autorun:function(){ //function to auto cycle through and select tabs based on a set interval
		this.cycleit('next', true)
	},

	cancelautorun:function(){
		if (typeof this.autoruntimer!="undefined")
			clearInterval(this.autoruntimer)
	},

	init:function(automodeperiod){
		var persistedtab=ddtabcontent.getCookie(this.tabinterfaceid) //get position of persisted tab (applicable if persistence is enabled)
		var selectedtab=-1 //Currently selected tab index (-1 meaning none)
		var selectedtabfromurl=this.urlparamselect(this.tabinterfaceid) //returns null or index from: tabcontent.htm?tabinterfaceid=index
		this.automodeperiod=automodeperiod || 0
		for (var i=0; i<this.tabs.length; i++){
			this.tabs[i].tabposition=i //remember position of tab relative to its peers
			if (this.tabs[i].getAttribute("rel")){
				var tabinstance=this
				this.hottabspositions[this.hottabspositions.length]=i //store position of "hot" tab ("rel" attr defined) relative to its peers
				this.subcontentids[this.subcontentids.length]=this.tabs[i].getAttribute("rel") //store id of sub content ("rel" attr value)
				this.tabs[i].onclick=function(){
					tabinstance.expandtab(this)
					tabinstance.cancelautorun() //stop auto cycling of tabs (if running)
					return false
				}
				if (this.tabs[i].getAttribute("rev")){ //if "rev" attr defined, store each value within "rev" as an array element
					this.revcontentids=this.revcontentids.concat(this.tabs[i].getAttribute("rev").split(/\s*,\s*/))
				}
				if (selectedtabfromurl==i || this.enabletabpersistence && selectedtab==-1 && parseInt(persistedtab)==i || !this.enabletabpersistence && selectedtab==-1 && this.getselectedClassTarget(this.tabs[i]).className=="selected"){
					selectedtab=i //Selected tab index, if found
				}
			}
		} //END for loop
		if (selectedtab!=-1) //if a valid default selected tab index is found
			this.expandtab(this.tabs[selectedtab]) //expand selected tab (either from URL parameter, persistent feature, or class="selected" class)
		else //if no valid default selected index found
			this.expandtab(this.tabs[this.hottabspositions[0]]) //Just select first tab that contains a "rel" attr
		if (parseInt(this.automodeperiod)>500 && this.hottabspositions.length>1){
			this.autoruntimer=setInterval(function(){tabinstance.autorun()}, this.automodeperiod)
		}
	} //END int() function

}; //END Prototype assignment


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


