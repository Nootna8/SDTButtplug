// Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
// License: New BSD License

package net.gimite.websocket {

import flash.display.Sprite;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.utils.setTimeout;

/**
  * Provides JavaScript API of WebSocket.
  */
public class WebSocketMain extends Sprite implements IWebSocketLogger{
  
  private var callerUrl:String;
  private var debug:Boolean = false;
  private var manualPolicyFileLoaded:Boolean = false;
  private var webSockets:Object = {};
  private var eventQueue:Array = [];
  
  public function WebSocketMain() {
	
	var params:Object = root.loaderInfo.parameters;
	if(params.insecure === 'true') {
		log("configuring \"insecure\" workaround");
	    Security.allowDomain("*");
	    // Also allows HTTP -> HTTPS call. Since we have already allowed arbitrary domains, allowing
	    // HTTP -> HTTPS would not be more dangerous.
	    Security.allowInsecureDomain("*");
	}
	
    ExternalInterface.addCallback("setCallerUrl", setCallerUrl);
    ExternalInterface.addCallback("setDebug", setDebug);
    ExternalInterface.addCallback("create", create);
    ExternalInterface.addCallback("send", send);
    ExternalInterface.addCallback("close", close);
    ExternalInterface.addCallback("destroy", destroy);
    ExternalInterface.addCallback("loadManualPolicyFile", loadManualPolicyFile);
    ExternalInterface.addCallback("receiveEvents", receiveEvents);
    ExternalInterface.call("WebSocket.__onFlashInitialized");
  }
  
  public function setCallerUrl(url:String):void {
    callerUrl = url;
  }
  
  public function setDebug(val:Boolean):void {
    debug = val;
    if (val) {
      log("debug enabled");
    }
  }
  
  private function loadDefaultPolicyFile(wsUrl:String):void {
    var policyUrl:String = "xmlsocket://" + URLUtil.getServerName(wsUrl) + ":843";
    log("policy file: " + policyUrl);
    Security.loadPolicyFile(policyUrl);
  }
  
  public function loadManualPolicyFile(policyUrl:String):void {
    log("policy file: " + policyUrl);
    Security.loadPolicyFile(policyUrl);
    manualPolicyFileLoaded = true;
  }
  
  public function log(message:String):void {
    if (debug) {
      ExternalInterface.call("WebSocket.__log", encodeURIComponent("[WebSocket] " + message));
    }
  }
  
  public function error(message:String):void {
    ExternalInterface.call("WebSocket.__error", encodeURIComponent("[WebSocket] " + message));
  }
  
  private function parseEvent(event:WebSocketEvent):Object {
    var webSocket:WebSocket = event.target as WebSocket;
    var eventObj:Object = {};
    eventObj.type = event.type;
    eventObj.webSocketId = webSocket.getId();
    eventObj.readyState = webSocket.getReadyState();
    eventObj.protocol = webSocket.getAcceptedProtocol();
    if (event.message !== null) {
      eventObj.message = event.message;
    }
    if (event.wasClean) {
      eventObj.wasClean = event.wasClean;
    }
    if (event.code) {
      eventObj.code = event.code;
    }
    if (event.reason !== null) {
      eventObj.reason = event.reason;
    }
    return eventObj;
  }

	public function destroy(webSocketId:String):void {
		if(debug)
			log('Flash: destroying WebSocket ' + webSocketId);
		var webSocket:WebSocket = webSockets[webSocketId];
		webSocket.removeEventListener("open", onSocketEvent);
		webSocket.removeEventListener("close", onSocketEvent);
		webSocket.removeEventListener("error", onSocketEvent);
		webSocket.removeEventListener("message", onSocketEvent);
		delete webSockets[webSocketId];
		if(debug)
			log('Flash: destroyed WebSocket ' + webSocketId);
	}
  
  public function create(
      webSocketId:String,
      url:String, protocols:Array,
      proxyHost:String = null, proxyPort:int = 0,
      headers:String = null):void {
    if (!manualPolicyFileLoaded) {
      loadDefaultPolicyFile(url);
    }
    var newSocket:WebSocket = new WebSocket(
        webSocketId, url, protocols, getOrigin(), proxyHost, proxyPort,
        getCookie(url), headers, this);
    newSocket.addEventListener("open", onSocketEvent);
    newSocket.addEventListener("close", onSocketEvent);
    newSocket.addEventListener("error", onSocketEvent);
    newSocket.addEventListener("message", onSocketEvent);
    webSockets[webSocketId] = newSocket;
  }
  
  public function send(webSocketId:String, encData:String):int {
    var webSocket:WebSocket = webSockets[webSocketId];
    return webSocket.send(encData);
  }
  
  public function close(webSocketId:String):void {
    var webSocket:WebSocket = webSockets[webSocketId];
    webSocket.close();
  }
  
  public function receiveEvents():Object {
    var result:Object = eventQueue;
    eventQueue = [];
    return result;
  }
  
  private function getOrigin():String {
    return (URLUtil.getProtocol(this.callerUrl) + "://" +
      URLUtil.getServerNameWithPort(this.callerUrl)).toLowerCase();
  }
  
  private function getCookie(url:String):String {
    if (URLUtil.getServerName(url).toLowerCase() ==
        URLUtil.getServerName(this.callerUrl).toLowerCase()) {
      return ExternalInterface.call("function(){return document.cookie}");
    } else {
      return "";
    }
  }
  
  /**
   * Socket event handler.
   */
  public function onSocketEvent(event:WebSocketEvent):void {
    var eventObj:Object = parseEvent(event);
    eventQueue.push(eventObj);
    processEvents();
  }
  
  /**
   * Process our event queue.  If javascript is unresponsive, set
   * a timeout and try again.
   */
  public function processEvents():void {
    if (eventQueue.length == 0) return;
    if (!ExternalInterface.call("WebSocket.__onFlashEvent")) {
      setTimeout(processEvents, 100);
    }
  }
  
}

}
