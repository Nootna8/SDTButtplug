SDTButtplug

This mod is made for SuperDeepthroat with it's modloader. Which can be found at: https://www.undertow.club/downloads/sdt-loader.1828/

It sends realtime data to supported sex toys using buttplug via intiface. Which can be found at: https://intiface.com/desktop/

Todo's:
 - Reduce/Fix movement stutter
 - Load the websocket URL via a settings file
 - Vibrate action on cumming
 - Support position from animtools. Only the blowjob animation work now
 - Support more buttplug actions. Only linear with 1 axis is supported now
 - Socket reconnecting. Only tries to connect at game start, need to restart if a timeout occurs
 
How to use:
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
	- Nativate to %appdata%\Macromedia\Flash Player\#Security\FlashPlayerTrust\. If the folder don't exist, create them.
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