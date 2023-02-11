# PowerMTB SimpleDataField for Edge130

## TRAIN BY WATTS

The trend in cycling is that the current performance is measured in watts/kg. This allows a relatively accurate evaluation, 
with which training progress can be measured. Watt measuring systems offer clear advantages compared to a training analysis via the heart rate, 
but are quite expensive and therefore mainly found in amateur and professional areas.
Since I don't want to spend the money for such a power meter at the moment (> 500€), I'm trying to develop a data field for my Garmin Edge 130, 
which calculates this power and displays it in plausible values.

I compared the watt calculation with a roller trainer and Zwift, where I calculate identical values on the flat and without a headwind.
The biggest problem at the moment is that I can't include the wind force (headwind) in my calculations. 
There are devices on the market that integrate such values using sensors, which the Edge unfortunately does not provide.

## Garmin Edge Screenshot


![Screenshot](readme.png)


## Rolling Resistance Tires:


######CrossCountry/Marathon

  Continental Race King:           Crr = 15,5W => 0.0031
  
  Schwalbe Rocket Ron:             Crr = 16,9W => 0.0034
  
  Vittoria Mezcal:                 Crr = 19,3W => 0.0039
  
  Schwalbe Racing Ralph:           Crr = 19,8W => 0.0040
  
  Vee Tire Rail Tracker:           Crr = 24,7W => 0.0050
  
  Maxxis Ikon:                     Crr = 27,8W => 0.0056
  
  Onza Canis:                      Crr = 29,3W => 0.0059
  
  Maxxis Crossmax Pulse:           Crr = 31,7W => 0.0064


######All Mountain

  Schwalbe Nobby Nic Pace Start:   Crr = 19,8W => 0.0038
  
  Schwalbe Fat Albert Rear:        Crr = 20,5W => 0.0041
  
  Vredestein Black Panther:        Crr = 22,3W => 0.0045
  
  WTB Trail Boss Fast Rolling:     Crr = 25,3W => 0.0051
  
  Vredestein Black Panther Xtreme: Crr = 25,4W => 0.0051
  
  Maxxis Ardent:                   Crr = 27,5W => 0.0056
  
  Continental Mountain King:       Crr = 29,8W => 0.0060
  
  WTB Trail Boss High Grip:        Crr = 39,3W => 0.0080
  
  Schwalbe Nobby Nic Trail Star:   Crr = 39,7W => 0.0080
  
  Schwalbe Fat Albert Front:       Crr = 40,0W => 0.0081


######Enduro

Maxxis Minnion DHR2:             Crr = 28,6W => 0.0058

Maxxis Shorty:                   Crr = 36,3W => 0.0074

Onza Citius:                     Crr = 40,2W => 0.0081

Bontrager SE5:                   Crr = 43,7W => 0.0089

Schwalbe Magic Marry TrailStart: Crr = 43,7W => 0.0089

Vee Tire Crown F-ree:            Crr = 43,7W => 0.0089

Continental Baron Project:       Crr = 43,8W => 0.0089


## Build App for use

Follow Programmer's Guide to setup your Windows or Mac.

Download Garmin Connect IQ SDK Manager.

Use the SDK manager to download the latest Connect IQ SDK and devices.

Once the download completes, click Yes when prompted to use the new SDK version as your active SDK.

Close the SDK Manager.

Install under Visual Studio Code the Monkey C Extension.

In VS Code, click Ctrl + Shift + P (Command + Shift + P on Mac) and select "Monkey C: build for device".
- Select were the .prg fiel should be stored.
- Choose Debig or Release (I am using debug).

Connect your device (Edge 130) with data cable to you PC/Mac and move the .prg file under APPS.


## Useful Documentation

https://developer.garmin.com/connect-iq/programmers-guide/

https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox.html

https://developer.garmin.com/connect-iq/compatible-devices/

