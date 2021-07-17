package flash
{
	import flash.display.MovieClip;
	import flash.system.Security;
	import flash.utils.getTimer;
	
	import net.gimite.websocket.*;
	import com.adobe.serialization.json.*;
	
	var loader;
	var global;
	var her;
	var websocket:WebSocket;
	var devices:Array = new Array();
	var lastUpdate = 0;
	var lastPosition = 0;
	
	var connected = false;
	var debug = false;

    public dynamic class ModMain extends MovieClip implements IWebSocketLogger
    {
	
		public function log(message:String):void {
			if(debug) {
				loader.updateStatusCol(message, "#0000FF");
				loader.traceDebug(message);
			}
		}
		  
		public function error(message:String):void {
			loader.updateStatusCol("SDTButtplug: " + message, "#FF0000");
			
			if(debug) {
				loader.traceDebug(message);
			}
		}
		  
	
		public function initl(l)
		{
			loader = l;
			global = loader.g;
			her = loader.her;
		
			if(Security.sandboxType != Security.LOCAL_TRUSTED) {
				error("Sandbox is not trusted");
				return;
			}
				
			l.addEnterFramePersist(doUpdate);

			connectIntiface();
		
			loader.unloadMod();
		}
		
		function doUpdate(f)
		{
			var pos = 0;
			
			if(her.mouthFull && her.pos > 0) {
				pos = her.pos;
				
				if(pos > 1) {
					pos = 1;
				}
			}
			
			sendPosition(1 - pos);
		}
		
		function connectIntiface()
		{
			loader.updateStatusCol("SDTButtplug: connecting ...", "#00FF00");
		
			var url = "ws://localhost:12345/buttplug";
	
			websocket = new WebSocket(
				"intiface", 
				url, [],
				"SDT",
				null,
				[],
				this
			);
			
			websocket.addEventListener("open", onSocketEvent);
			websocket.addEventListener("close", onSocketEvent);
			websocket.addEventListener("error", onSocketEvent);
			websocket.addEventListener("message", onSocketEvent);
		}
		
		function sendPosition(position)
		{
			if(!connected)
			{
				return;
			}
			
			var timePassed = getTimer() - lastUpdate;
			if(timePassed < 30) {
				return;
			}
			
			var positionChange = Math.abs(lastPosition - position);
			if(positionChange < 0.1) {
				return;
			}
		
			for each (var device in devices)
			{
				if(device.DeviceMessages.LinearCmd)
				{
					var request:Object = [ {
					 "LinearCmd": {"Id": 4, "DeviceIndex": device.DeviceIndex, "Vectors": [ {
						"Index": 0, "Duration": timePassed, "Position": position
					 } ]}
					} ];
					
					websocket.send(JSON.encode(request));
				}
			}
			
			lastUpdate = getTimer();
			lastPosition = position;
		}
		
		public function onSocketEvent(event:WebSocketEvent):void
		{
			if(event.type == "open")
			{
				var request:Object = [ {"RequestServerInfo": {"Id": 1,"ClientName": "SDT","MessageVersion": 1}} ];
				websocket.send(JSON.encode(request));
			}
			
			if(event.type == "close")
			{
				error("disconnected");
				connected = false;
			}
			
			if(event.type == "message")
			{
				var response:Object = JSON.decode(event.message);
				if(!response[0]) {
					return;
				}
				response = response[0];
				if(response.ServerInfo) {
					connected = true;
					
					loader.updateStatusCol("SDTButtplug: connected", "#00FF00");
					
					var request:Object = [ {"StartScanning": {"Id": 2}} ];
					websocket.send(JSON.encode(request));
					request = [ {"RequestDeviceList": {"Id": 3}} ];
					websocket.send(JSON.encode(request));
				}
				
				if(response.DeviceList) {
					devices = response.DeviceList.Devices;
					loader.updateStatusCol("SDTButtplug: device update", "#00FF00");
				}
				
				if(response.DeviceAdded || response.DeviceRemoved) {
					var request:Object = [ {"RequestDeviceList": {"Id": 3}} ];
					websocket.send(JSON.encode(request));
				}
			}
		}
		
	}
}