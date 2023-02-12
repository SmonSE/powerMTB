import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.ActivityMonitor;
using Toybox.FitContributor as Fit;

class powerMTBView extends WatchUi.SimpleDataField {

    hidden var sValue  as Numeric;                      // Speed
    hidden var mValue  as Numeric;                      // Distance
    hidden var wValue  as Numeric;                      // Watt
    hidden var aValue  as Numeric;                      // Ascent
    hidden var dValue  as Numeric;                      // Ambient Pressure
    hidden var hValue  as Numeric;                      // Heartrate
    hidden var avValue as Numeric;                      // Watt Average
    hidden var asValue as Numeric;                      // Average Speed
    hidden var kgValue as Numeric;                      // Watt / kg

    hidden var bikeEquipWeight  as Numeric;
    hidden var cdA              as Numeric;
    hidden var airDensity       as Numeric;
    hidden var rollingDrag      as Numeric;
    hidden var ground           as Numeric;
    hidden var distance         as Numeric;
    hidden var version          as Numeric;

    var startWatt = false;                              // Set Watt value at the beginning to avoid empty data field
    var start = false;                                  // Set StartPresure once at the beginning
    var stopCount = false;                              // Stop Counting if speed is 0
    var updateStatus = false;                           // Watt Update: true= 1sec; false=10m

    var weightOverall = 0;                              // Gewicht Fahrer + Bike + Equipment
    var weightRider = 0;                                // Gewicht Fahrer (value wird aus Garmin Profil geholt und überschrieben)
    var g = 9.81;                                       // Die Fallbeschleunigung hat auf der Erde den Wert g = 9,81 ms2
                             
    var Pa = 0;                                         // Pa = Luftwiderstand
    var Pr = 0;                                         // Pr = Rollwiderstand / Rollreibungszahl
    var Pc = 0;                                         // Pc = Steigungswiderstand
    var Pm = 0;                                         // Pm = Mechanische Widerstand
    var k = 0;                                          // Steigung in %
    
    var startPressure = 0;
    var paMeter = 0;
    var climbP = 0;
    var calcPressure = 0;

    var powerTotal = 0;
    var powerOverall = 0;
    var powerAverage = 0;
    var powerCount = 0;
    var newDistance = 0.00;

    var fitField1;
    var fitField2;
    var fitField3;

    // Set the label of the data field here.
    function initialize(app) {
        SimpleDataField.initialize();
        label = "Watt Ø";

        sValue  = 0.00f;
        mValue  = 0.00f;
        wValue  = 0.00f;
        aValue  = 0.00f;
        dValue  = 0.00f;
        hValue  = 0.00f;
        avValue = 0.00f;
        asValue = 0.00f;
        kgValue = 0.00f;

        weightRider = app.getProperty("riderWeight_prop").toFloat();      // Weight Rider
        bikeEquipWeight = app.getProperty("bike_Equip_Weight").toFloat(); // Weight =  Bike + Equipment
        cdA = app.getProperty("drag_prop").toNumber();                    // Air friction coefficient CwA(m²)
        airDensity = app.getProperty("airDensity_prop").toFloat();        // air density: 1.205 kg/m³
        rollingDrag = app.getProperty("rollingDrag_prop").toFloat();      // Rolling friction coefficient Cr of the tire
        ground = app.getProperty("ground_prop").toNumber();               // Subsurface factor
        distance = app.getProperty("distance_prop").toNumber();           // Update Watt/distance in meter
        version = app.getProperty("appVersion").toString();               // Update App Version

        // Weight of driver and equipment
        weightOverall = weightRider + bikeEquipWeight;

        // Rolling Resistance: 
        rollingDrag = rollingDrag / (weightOverall * 9.81 * 5.56);

        switch ( cdA ) {
            case 1: {
                cdA = 0.28;
                break;
            }
            case 2: {
                cdA = 0.42;
                break;
            }
            case 3: {
                cdA = 0.52;
                break;
            }
            default: {
                cdA = 0.042;
                break;
            }
        }

        switch ( ground ) {
            case 1: {
                ground = 1.0;
                break;
            }
            case 2: {
                ground = 1.5;
                break;
            }
            case 3: {
                ground = 1.8;
                break;
            }
            case 4: {
                ground = 2.5;
                break;
            }
            default: {
                ground = 1.0;
                break;
            }
        }

        switch ( distance ) {
            case 1: {
                distance = 10;
                break;
            }
            case 2: {
                distance = 20;
                break;
            }
            case 3: {
                distance = 30;
                break;
            }
            default: {
                distance = 10;
                break;
            }
        }
    
    // Create the custom FIT data field we want to record.
    fitField1 = SimpleDataField.createField("watt_time", 0, Fit.DATA_TYPE_SINT16, {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"watt", :nativeNum => 20});
    fitField1.setData(0); 

    fitField2 = SimpleDataField.createField("watt_average", 1, Fit.DATA_TYPE_SINT16, {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"watt"});
    fitField2.setData(0);

    fitField3 = SimpleDataField.createField("climb_percent", 2, Fit.DATA_TYPE_SINT16, {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"meter"});
    fitField3.setData(0);  
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {

        // Speed in km/h
        if(info has :currentSpeed){
            if(info.currentSpeed != null){
                sValue = info.currentSpeed as Number * 3.6; 
            } else {
                sValue = 0.00f;
            }
        }

        // Distance
        if(info has :elapsedDistance){
            if(info.elapsedDistance != null){
                mValue = info.elapsedDistance as Number / 1000;
                var mVal = mValue.format("%.3f");
                mValue = mVal.toDouble();
                //Sys.println("DEBUG: mValue(2) :" + mValue + "  " + mVal); 
            } else {
                mValue = 0.00f;
            }
        }

        // Ambient Pressure / Change to Barometer
        if(info has :ambientPressure) {
            if(info.ambientPressure != null) {
                if (start == false) {
                    startPressure = info.ambientPressure as Number; 
                    startPressure = startPressure.toFloat() * 0.0001;
                    //Sys.println("DEBUG: startPressure() :" + startPressure); 
                    start = true;
                } 

                dValue = info.ambientPressure as Number; 
                dValue = dValue.toFloat() * 0.0001;
                //Sys.println("DEBUG: dValue() :" + dValue); 
                
                var checkMValue = mValue.toDouble();
                var checkNewDistance = newDistance.toDouble();
                //Sys.println("DEBUG: onUpdate() check: " + checkMValue + " == " + checkNewDistance);
                if (checkMValue >= checkNewDistance) {
                    newDistance += distance * 0.001;
                    updateStatus = true;

                    if (updateStatus == true) {
                        if (dValue >= startPressure) {
                            calcPressure = dValue - startPressure;
                            paMeter = calcPressure * 8.0;                             
                            paMeter = (paMeter * 100);                 
                            startPressure = dValue;                                              
                            dValue = paMeter;

                            // k = (h/a) * 100 
                            k = (paMeter/distance) * 100;
                            k = k * (-1);
                            //Sys.println("DEBUG: climb(%) :" + k); 

                        } else {
                            calcPressure = dValue - startPressure;
                            paMeter = calcPressure * 8.0;                 
                            paMeter = (paMeter * 100);
                            startPressure = dValue;  
                            dValue = paMeter;

                            //k = (h/a) * 100 
                            k = (paMeter/distance) * 100;
                            k = k * (-1);
                            //Sys.println("DEBUG: climb(%) :" + k);  

                        } 
                    }  
                } 
            } else {
                dValue = 0.00f;
            }
        }

        // Watt
        if(info has :currentSpeed){
            if(info.currentSpeed != null){
                if (updateStatus == true) {

                    // Pr = Cr * m * g * v 
                    Pr = rollingDrag * weightOverall * g * (sValue/3.6);
                    // Pa = 0.5 * p * cdA * v * (v-vw)2 or -> Pa = 0.5 * p * (cdA * ground) * v * (v-vw)2
                    Pa = 0.5 * airDensity * (cdA * ground) * (sValue/3.6) * (sValue/3.6) * (sValue/3.6);
                    // Pc = (k/100) * m * g * v
                    Pc = (k/100) * weightOverall * g * (sValue/3.6);
                    // Pm = (Pr + Pa + Pc) * 0.025
                    Pm = (Pr + Pa + Pc) * 0.025;
                    // powerTotal = Pr + Pa + Pc + Pm
                    powerTotal = Pr + Pa + Pc + Pm;

                    if (sValue > 0 && updateStatus == true) { 

                        if (powerTotal > 0) {                                   // no negativ Watt values
                            wValue = powerTotal;
                            powerCount += 1;

                            powerOverall += powerTotal;                         // Watt Average
                            powerAverage = powerOverall / powerCount;
                            avValue = powerAverage;

                            kgValue = powerAverage / weightRider;               // Watt / KG
                        } else {
                            wValue = 0;
                        }
 
                        // The IQ grafik should not get into negativ value 
                        /*
                        if (k < 0){
                            climbP = k * (-1);
                        } else {
                            climbP = k;
                        }
                        */

                        // Add Values to FitContributor
                        fitField1.setData(wValue.toNumber()); 
                        fitField2.setData(avValue.toNumber());
                        fitField3.setData(climbP.toNumber()); 

                        //Sys.println("DEBUG: Watt ( w ): " + wValue);
                        //Sys.println("DEBUG: Watt ( Ø ): " + avValue);
                        //Sys.println("DEBUG: Climb( % ): " + climbP);
                    }
                }
            } else {
                sValue = 0.00f;
            }
        }

        updateStatus = false;

        var retVal = avValue.format("%d");      // now Average Watt is shown on display
        var retValNb = retVal.toNumber();
        //Sys.println("DEBUG: retVal() :" + retVal); 

        // See Activity.Info in the documentation for available information.
        return retValNb;       
    }
}
