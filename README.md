# Onyx-Boox-Wallpaper-Fix
A PowerShell script to completely block intrusive factory default images on any Onyx Boox e-readers
# Universal Boox Factory-Art Blocker & Screensaver Syncer

A lightweight PowerShell automation script that forces Onyx Boox e-readers to strictly rotate user-provided screensavers, permanently suppressing the intrusive default factory artwork.

## Supported Devices
* Tested exclusively on **Onyx Boox Go 6 (Firmware 4.2re)**.
* Designed with backward and forward compatibility for Boox devices running Android 9 through Android 11+.

## Prerequisites
## Prerequisites
1. **Enable USB Debugging** on your Boox device (Go to Settings > App Management > Development Options > Enable USB Debugging).  my device had a popup when it detected it was plugged into a pc, but your mileage may vary.
2. Connect your Boox to your Windows PC via a stable USB cable.
3. Your custom screensaver artwork must be placed inside the device's internal storage folder under `Pictures\Screensaver`. (When connected to a PC, this shows up inside your Boox device's main drive space under the `Pictures` folder. The script will automatically create the `Screensaver` directory if it does not exist).
4. Ensure you have `adb.exe` installed on your PC. If you do not have it, you can get the official standalone binaries directly from the official [Google Android SDK Platform Tools Download Page](https://developer.android.com/tools/releases/platform-tools). 
   * Windows Users can download the zip payload instantly via this [Direct Google Download Link](https://dl.google.com/android/repository/platform-tools-latest-windows.zip). Extract the folder directly to `C:\platform-tools\`.   do not extract to the default location as that may make the adb database hidden from this script.


## How to Use
1. Download `generalbooxscreensaverfix.ps1` from this repository. 
2. run powershell as administrator - run the program `generalbooxscreensaverfix.ps1`.
   you can type powershell into the windows search bar and click run as admin.  then right click the script and "copy as path"-- using that info you can use the run command "&" and the path like thus-- & "C:\tools\platform-tools\generalbooxscreensaverfix.ps1"  --
   if the window will not allow you to run scripts you can use --   powershell -ExecutionPolicy Bypass -File "C:\tools\platform-tools\generalbooxscreensaverfix.ps1"      -- where the copy as path should be substituted for where your scrript is actually located.
4. Follow the on-screen terminal text. Once finished, tap your Boox power button twice to sleep/wake the screen and verify the results.

## Note on Low Battery
If your Boox device battery falls below 15-20%, Android's internal power-saving framework may temporarily discard custom configuration paths to save RAM. If default images suddenly return after a low-battery event, simply charge your device and if that alone does not fix the issue then re-run this script again to lock your custom images back in place.

The script can also, possibly, be overwritten by plugging the boox into a pc, adding new pics to the folder or even possibly rebooting/crashing if the boox decides to be cheeky.  The answer in those cases is simple though.  
If the script fails after it has been working, then simply charge the device above 30%, then hold the power button until a soft reset occurs. Next, plug the boox back into your pc and run the script again to redo the changes that boox undid.  I hope this helps because i spent a lot of time and frustation on this but the end result is much better.  

#free for use and reproduction
This is open source and I encourage anyone to freely edit and fix this for their devices as I only own the boox go6 v4.2rel and cannot test it on other devices to be sure it is a one-size-fits all that i hope it is. 

## License
Distributed under the MIT License. See `LICENSE` for more information.
