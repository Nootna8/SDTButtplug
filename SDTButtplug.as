package flash
{
	import flash.display.MovieClip;
	import flash.system.Security;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.geom.Point;
	
	import net.gimite.websocket.*;
	import com.adobe.serialization.json.*;
	
	var settings;
	
	var loader;
	var global;
	var her;
	var him;
	
	var websocket:WebSocket;
	var devices:Array = new Array();
	
	var lastUpdate = 0;
	var lastPosition = 0;
	var lastAngle = 0;
	var lastVibration = 0;
	
	var lastState = {
		"cum_in_mouth": 0,
		"cum_in_throat": 0
	};

	var tryReconnect = true;
	var lastSpurting = false;
	var lastFlashing = false;
	
	var offsetPos = 0;
	var offsetUntil = 0;
	
	var defaultSettings = {
		"socketUrl": "ws:--localhost:12345-buttplug",
		"debug": false,

		"hjTwist": false,
		"updateInterval": 50,
		"minimumMove": 0.05,

		"positionMin": 0.1,
		"positionMax": 0.9,
		"smoothing": 1.0,

		"vibrationSpeed": 0.85,
		"vibrationDecay": 0.7,

		"spurtDelay": 100,
		"spurtIntensity": 0.2,
		"spurtVariance": 1.0,

		"reconnectKey": 186 // Semicolon
	};
	
	var connected:Boolean = false;

	public dynamic class ModMain extends MovieClip implements IWebSocketLogger
	{
		public function log(message:String):void {
			if(settings['debug']) {
				loader.updateStatusCol(message, "#0000FF");
				loader.traceDebug(message);
			}
		}
		  
		public function error(message:String):void {
			loader.updateStatusCol("SDTButtplug: " + message, "#FF0000");
			
			if(settings['debug']) {
				loader.traceDebug(message);
			}
		}
		  
	
		public function initl(l)
		{
			loader = l;
			global = loader.g;
			her = loader.her;
			him = global.him;
			
			if(Security.sandboxType != Security.LOCAL_TRUSTED) {
				failedLoading("Sandbox is not trusted");
				return;
			}
			
			var modSettingsLoader = loader.eDOM.getDefinition("Modules.modSettingsLoader") as Class;
			var msl = new modSettingsLoader("SDTButtplug", settingsLoaded);
			msl.addEventListener("settingsNotFound", settingsNotFound);
		}
		
		public function continueLoad()
		{
			loader.addEnterFramePersist(doUpdate);
			loader.registerFunctionPersist(connectIntiface,settings['reconnectKey']);
			connectIntiface();
			loader.unloadMod();
		}
		
		public function failedLoading(message)
		{
			error(message);
			loader.unloadMod();
		}
		
		public function settingsNotFound(e)
		{
			loader.updateStatusCol("SDTButtplug: settings not found, defaults loaded", "#0000FF");
			settings = defaultSettings;
			continueLoad();
		}
		
		public function checkSettings()
		{
			for (var k in defaultSettings) {
				if(settings[k] == null) {
					return false;
				}
			}
			
			settings['positionMin'] = parseFloat(settings['positionMin']);
			settings['positionMax'] = parseFloat(settings['positionMax']);
			settings['vibrationSpeed'] = parseFloat(settings['vibrationSpeed']);
			settings['vibrationDecay'] = parseFloat(settings['vibrationDecay']);
			settings['spurtIntensity'] = parseFloat(settings['spurtIntensity']);
			settings['spurtDelay'] = parseFloat(settings['spurtDelay']);
			settings['spurtVariance'] = parseFloat(settings['spurtVariance']);
			
			return true;
		}
		
		public function settingsLoaded(e)
		{
			settings = e.settings;
			
			if(checkSettings() != true) {
				loader.updateStatusCol("SDTButtplug: invalid config, defaults loaded", "#0000FF");
				settings = defaultSettings;
			}
			else {
				loader.updateStatusCol("SDTButtplug: config file loaded", "#0000FF");
			}
			
			continueLoad();
		}
		
		public function mapValue(value, inMin, inMax, outMin, outMax)
		{
			return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
		}
		
		public function detectSpurting(currentTime, pos)
		{
			if(currentTime < (offsetUntil + 50)) {
				return;
			}

			var spurtIntensity = settings['spurtIntensity'];
			var spurtVariance = settings['spurtVariance'];
			var spurtDelay = settings['spurtDelay'];

			var spurtMod = 1.0 - (him.twitchFactor * spurtVariance);
			var spurtDist = spurtIntensity * spurtMod;

			for (var k in lastState) {
				var v = lastState[k];
				var newv = global.dialogueControl.states[k]._buildLevel;
				
				if(newv > v) {
					if(pos > 0.5) {
						offsetPos = - spurtDist;
					}
					else {
						offsetPos = spurtDist;
					}
					
					offsetUntil = currentTime + spurtDelay;
				}
				
				lastState[k] = newv;
			}
			
			if(him.spurting) {
				if(pos > 0.5) {
					offsetPos = - spurtDist;
				}
				else {
					offsetPos = spurtDist;
				}
				
				offsetUntil = currentTime + spurtDelay;
			}
			
			lastSpurting = him.spurting;
		}
		
		public function doUpdate(f)
		{
			var pos:Number = 0;
			var twist:Number = 0;
			var currentTime = getTimer();
			
			if(global.handJobMode) {
				if(settings['hjTwist']) {
					twist = global.currentHandJobPos.x;
					pos = her.pos;
				}
				else {
					pos = global.currentHandJobPos.x;
				}
			}
			else if(her.isInMouth() && her.penisInMouthDist > 0){
				pos = her.penisInMouthDist / him.currentPenisLength;
			}
			
			detectSpurting(currentTime, pos);
		
			if(offsetUntil > currentTime) {
				pos += offsetPos;
			}
			
			var angle = mapValue(him.penis.rotation, -4, 20, 0, 1);
			pos = mapValue(pos, 0, 1, settings['positionMax'], settings['positionMin']);

			sendPosition(pos, angle, twist);
		}
		
		public function connectIntiface()
		{
			loader.updateStatusCol("SDTButtplug: connecting ...", "#00FF00");

			if (websocket != null) {
				websocket.close();
			}

			var url = settings["socketUrl"].split("-").join("/");
	
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
		
		public function clampPosition(val)
		{
			if(val < 0) {
				return 0;
			}
			
			if(val > 1) {
				return 1;
			}
			
			return val;
		}
		
		public function sendPosition(position, angle, twist)
		{
			if(!connected)
			{
				return;
			}
			
			var currentTime = getTimer();
			var timePassed = currentTime - lastUpdate;
			var positionChange = Math.abs(lastPosition - position);
			
			if(timePassed < settings["updateInterval"]) {
				return;
			}

			for each (var device in devices)
			{
				var request:Object = [];
				
				if(positionChange >= settings["minimumMove"]) {
					var dur = Math.round(timePassed * settings['smoothing']);

					if(device.DeviceMessages.LinearCmd)
					{
						var linear = {
							"LinearCmd": {"Id": 4, "DeviceIndex": device.DeviceIndex, "Vectors": 
							[ {
								"Index": 0, "Duration": dur, "Position": clampPosition(position)
							} ]
							}
						};
						
						if(device.DeviceMessages.LinearCmd.FeatureCount > 12)
						{
							linear['LinearCmd']['Vectors'].push({
								"Index": 10, "Duration": dur, "Position": clampPosition(twist)
							});
						
							linear['LinearCmd']['Vectors'].push({
								"Index": 12, "Duration": dur, "Position": clampPosition(angle)
							});
						}
						
						request.push(linear);
					}
				}
				
				if(device.DeviceMessages.VibrateCmd)
				{
					var vibrate = mapValue(positionChange, 0, 1 - settings['vibrationSpeed'], 0, 1);
					if(vibrate < lastVibration) {
						var vibrationDecay = mapValue(timePassed, 0, 200, 0, settings['vibrationDecay']);
						vibrate = clampPosition(lastVibration - vibrationDecay);
						lastVibration = vibrate;
					}
					lastVibration = vibrate;
				
					request.push({
						"VibrateCmd": {"Id": 5, "DeviceIndex": device.DeviceIndex, "Speeds": [ {
							"Index": 0, "Speed": vibrate
						}]}
					});
				}
				
				if(request.length > 0) {
					websocket.send(JSON.encode(request));
				}
			}
			
			lastUpdate = currentTime;
			lastPosition = position;
			lastAngle = angle;
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
				connected = false;

				if(tryReconnect)
				{
					tryReconnect = false;
					loader.updateStatusCol("SDTButtplug: reconnecting ...", "#0000FF");
					connectIntiface();
				}
				else
				{
					error("Disconnected, reconnectin");
				}
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
					tryReconnect = true;
					
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
