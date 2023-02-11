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

#### CrossCountry/Marathon

- Continental Race King:    &nbsp;       Crr = 15,5W  <br />
- Schwalbe Rocket Ron:      &nbsp;       Crr = 16,9W  <br />
- Vittoria Mezcal:          &nbsp;       Crr = 19,3W  <br />
- Schwalbe Racing Ralph:    &nbsp;       Crr = 19,8W  <br />
- Vee Tire Rail Tracker:    &nbsp;       Crr = 24,7W  <br />
- Maxxis Ikon:              &nbsp;       Crr = 27,8W  <br />
- Onza Canis:               &nbsp;       Crr = 29,3W  <br />
- Maxxis Crossmax Pulse:    &nbsp;       Crr = 31,7W  <br />

#### All Mountain

- Schwalbe Nobby Nic Pace Start:   Crr = 19,8W  <br />
- Schwalbe Fat Albert Rear:        Crr = 20,5W  <br />
- Vredestein Black Panther:        Crr = 22,3W  <br />
- WTB Trail Boss Fast Rolling:     Crr = 25,3W  <br />
- Vredestein Black Panther Xtreme: Crr = 25,4W  <br />
- Maxxis Ardent:                   Crr = 27,5W  <br />
- Continental Mountain King:       Crr = 29,8W  <br />
- WTB Trail Boss High Grip:        Crr = 39,3W  <br />
- Schwalbe Nobby Nic Trail Star:   Crr = 39,7W  <br />
- Schwalbe Fat Albert Front:       Crr = 40,0W  <br />

#### Enduro

- Maxxis Minnion DHR2:             Crr = 28,6W  <br />
- Maxxis Shorty:                   Crr = 36,3W  <br /> 
- Onza Citius:                     Crr = 40,2W  <br /> 
- Bontrager SE5:                   Crr = 43,7W  <br /> 
- Schwalbe Magic Marry TrailStart: Crr = 43,7W  <br /> 
- Vee Tire Crown F-ree:            Crr = 43,7W  <br />
- Continental Baron Project:       Crr = 43,8W  <br />



## Build App for use

Follow Programmer's Guide to setup your Windows or Mac. <br />
Download Garmin Connect IQ SDK Manager. <br />
Use the SDK manager to download the latest Connect IQ SDK and devices. <br />
Once the download completes, click Yes when prompted to use the new SDK version as your active SDK. <br />
Close the SDK Manager. <br />
Install under Visual Studio Code the Monkey C Extension. <br />

In VS Code, click Ctrl + Shift + P (Command + Shift + P on Mac) and select "Monkey C: build for device". <br />
- Select were the .prg fiel should be stored. <br />
- Choose Debig or Release (I am using debug). <br />

Connect your device (Edge 130) with data cable to you PC/Mac and move the .prg file under APPS. <br />


## Useful Documentation

https://developer.garmin.com/connect-iq/programmers-guide/ <br />
https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox.html <br />
https://developer.garmin.com/connect-iq/compatible-devices/ <br />

