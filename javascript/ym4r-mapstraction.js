function addCodeToFunction(func,code){
    if(func == undefined)
	return code;
    else{
	return function(){
	    func();
	    code();
	}
    }
}

function addDataToMarker(marker,options){
    if(options.label)
	marker.setLabel(options.label);
    if(options.infoBubble)
	marker.setInfoBubble(options.infoBubble);
    if(options.icon)
	marker.setIcon(options.icon)
    return marker;
}

Marker.prototype.setIcon = function(iconUrl){
    this.iconUrl = iconUrl;
}

Marker.prototype.toYahoo = function() {
    var ymarker;
    if(this.iconUrl){
	ymarker = new YMarker(this.location.toYahoo(),new YImage(this.iconUrl));
    }else{
	ymarker = new YMarker(this.location.toYahoo());
    }
  
    if(this.labelText) {
	ymarker.addLabel(this.labelText);
    }
    
    if(this.infoBubble) {
	var theInfo = this.infoBubble;
	YEvent.Capture(ymarker, EventsList.MouseClick, function() {ymarker.openSmartWindow(theInfo); }); 
    }
    
    return ymarker;
} 

Marker.prototype.toGoogle = function() {
    var options = new Object();
    if(this.labelText) {
	options.title =  this.labelText;
    }
    if(this.iconUrl){
	options.icon = new GIcon(G_DEFAULT_ICON,this.iconUrl);
    }
    var gmarker = new GMarker(this.location.toGoogle(),options);
    
    if(this.infoBubble) {
	var theInfo = this.infoBubble;
	GEvent.addListener(gmarker, "click", function() {
	    gmarker.openInfoWindowHtml(theInfo);
        });
    }
    return gmarker;
}

Marker.prototype.toMicrosoft = function() {
  var pin = new VEPushpin(this.pinID,this.location.toMicrosoft(),this.iconUrl,this.labelText,this.infoBubble);
  return pin;
}

//MarkerGroup
//Method to add and remove marker group to a Mapstraction map

Mapstraction.prototype.addMarkerGroup = function(markerGroup){
    markerGroup.initalize(this);
}

Mapstraction.prototype.removeMarkerGroup = function(markerGroup){
    markerGroup.hide();
}

function MarkerGroup(markers,visible){
    this.visible = visible == undefined ? true : visible;
    this.markers = markers;
}

MarkerGroup.prototype.initalize = function(map){
    this.map = map;
    if(this.visible){
	for(var i = 0 , len = this.markers.length; i < len; i++){
	    this.map.addMarker(this.markers[i]);
	}
    }
}

MarkerGroup.prototype.show = function(){
    if(!this.visible){
	if(this.map != undefined){
	    for(var i = 0 , len = this.markers.length; i < len; i++){
		this.map.addMarker(this.markers[i]);
	    }
	}
	this.visible = true;
    }
}

MarkerGroup.prototype.hide = function(){
    if(this.visible){
	if(this.map != undefined){
	    for(var i = 0 , len = this.markers.length; i < len; i++){
		this.map.removeMarker(this.markers[i])
	    }
	}
	this.visible = false;
    }
}

MarkerGroup.prototype.toggle = function(){
    if(this.visible){
	this.hide();
    }else{
	this.show();
    }
}

