# SDTButtplug

SDTButtplug is a mod made for SuperDeepthroat with it's modloader. Which can be found at: https://www.undertow.club/downloads/sdt-loader.1828/

It sends realtime data to supported sex toys using buttplug via intiface. Which can be found at: https://intiface.com/desktop/

Todo's: feel free to send a Pull Request!
 - Socket reconnecting. Only tries to connect at game start, need to restart if a timeout occurs
 - OSR2, support is already there on the mod side. The buttplug side is pending ( https://github.com/buttplugio/buttplug/issues/397 )
 
# How to use:
 - Install and start buttplug:
	- Download and install intiface: https://intiface.com/desktop/
	- Open intiface, go to the Server Status tab and click START SERVER
 - Get SDT
	- Register an account / login with your account at https://www.undertow.club/
	- Download and extract the SDT Loader package: https://www.undertow.club/threads/sdt-loader.3338/
	- Download Flash Player projector and put the exe in your Loader folder. You can get this here: https://www.adobe.com/support/flashplayer/debug_downloads.html
 - Install the mod
	 - Download the SDTButtplug.swf from this repo
	 - Create a folder in your loader package Loader/Mods/SDTButtplug
	 - Copy the SDTButtplug.swf to Loader/Mods/SDTButtplug/Mod.swf
	 - Add a line to Loader/Mods/CharacterFolders.txt, which reads: SDTButtplug:SDTButtplug
 - Set up SDT as trusted for flash
	- Go to your AppData folder by hitting WIN+R, type in %appdata%, then press Enter
	- Nativate to %appdata%\\Macromedia\\Flash Player\\#Security\FlashPlayerTrust\\. If the folder don't exist, create them.
	- Create a file named: SDT.cfg
	- Add the full path to your Loader folder to SDT.cfg, you can do this with notepad. Don't forget to save.
 - Launch
    - Run the Flash Player projector from your Loader folder.
	- Go to File -> Open -> Browse
	- Open the Loader.swf in your Loader folder
	- Click OK
	- Click Play
	- Hit Y on your keyboard
	- Click the character icon on the left
	- Scroll to the right, click on SDTButtplug
	- In the top right it should show "SDTButtplug: connected" after a few seconds
	- Power on your sex toy
	- Done
	
You can press ';' to reconnect

If the mod doesn't load anything (Screen says Loading Finished without any mention of SDTButtplug). Try making a fresh .swf, this is done by deleting SDTButtplug.swf and running Compile.bat, the newly generated SDTButtplug.swf might work better.
It's a stupid fix which shouldn't change anything, but for some people it seems to fix the problem. Flash right ...

# Configuration:

If you want to tweak the configuration, copy SDTButtplug.txt from the repo to Loader/Settings/SDTButtplug.txt. You can edit the file with notepad, then save and restart the game.
Make sure the game also says: "SDTButtplug: config file loaded".

Depending on your device/setup you might want to edit the config for a better response.

Too much stuttering (For example with a Vorze A10 Piston)
```
updateInterval=150
minimumMove=0.05
smoothing=2
```

Not responsive enough (For example with an OSR2 / SR6)
```
updateInterval=0
minimumMove=0.005
smoothing=1
predictive=
```

Other animations not working
```
animTools=1
```

Edit these to your liking and let us know when you've found the Golden settings for a specific device!