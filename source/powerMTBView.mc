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
    hidden var distance           as Numeric;

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
    var totalPressureUp = 0;
    var paMeter = 0;
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
        label = "Watt";

        sValue  = 0.00f;
        mValue  = 0.00f;
        wValue  = 0.00f;
        aValue  = 0.00f;
        dValue  = 0.00f;
        hValue  = 0.00f;
        avValue = 0.00f;
        asValue = 0.00f;
        kgValue = 0.00f;

        weightRider = app.getProperty("riderWeight_prop").toFloat();
        bikeEquipWeight = app.getProperty("bike_Equip_Weight").toFloat(); // Weight =  Bike + Equipment
        cdA = app.getProperty("drag_prop").toNumber();                    // Air friction coefficient Cw*A [m2], CdA = drag area -> Trainer: 0.25, MTB: 0.525, Road: 0.28, 
        airDensity = app.getProperty("airDensity_prop").toFloat();        // air density: 1.205 -> API: 3.2.0 weather can be calculated .. not for edge 130 :(
        rollingDrag = app.getProperty("rollingDrag_prop").toNumber();     // Rolling friction coefficient cr of the tire/ Trainer: 0.004, Race: 0.006, Tour: 0.008, Enduro: 0.009
        ground = app.getProperty("ground_prop").toNumber();               // Subsurface factor: Trainer, Asphalt, Schotterweg, Waldweg
        distance = app.getProperty("distance_prop").toNumber();           // Update Watt/distance in meter

        switch ( cdA ) {
            case 1: {
                cdA = 0.25;
                break;
            }
            case 2: {
                cdA = 0.28;
                break;
            }
            case 3: {
                cdA = 0.45;
                break;
            }
            case 4: {
                cdA = 0.525;
                break;
            }
            default: {
                cdA = 0.00;
                break;
            }
        }

        switch ( rollingDrag ) {
            case 1: {
                rollingDrag = 0.004;
                break;
            }
            case 2: {
                rollingDrag = 0.006;
                break;
            }
            case 3: {
                rollingDrag = 0.008;
                break;
            }
            case 4: {
                rollingDrag = 0.009;
                break;
            }
            default: {
                rollingDrag = 0.00;
                break;
            }
        }

        switch ( ground ) {
            case 1: {
                ground = 0.85;
                break;
            }
            case 2: {
                ground = 1;
                break;
            }
            case 3: {
                ground = 1.5;
                break;
            }
            case 4: {
                ground = 3.0;
                break;
            }
            default: {
                ground = 0.00;
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
            case 4: {
                distance = 40;
                break;
            }
            default: {
                distance = 10;
                break;
            }
        }
    
    // Create the custom FIT data field we want to record.
    fitField1 = SimpleDataField.createField("watt_time", 0, Fit.DATA_TYPE_SINT16, {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"w", :nativeNum => 7});
    fitField1.setData(0); 

    fitField2 = SimpleDataField.createField("watt_kg", 1, Fit.DATA_TYPE_SINT16, {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"watt/kg"});
    fitField2.setData(0);

    fitField3 = SimpleDataField.createField("watt_average", 2, Fit.DATA_TYPE_SINT16, {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"watt/average"});
    fitField3.setData(0);  

    //Sys.println("DEBUG: Properties ( riderWeight     ): " + weightRider);
    //Sys.println("DEBUG: Properties ( bikeEquipWeight ): " + bikeEquipWeight);
    //Sys.println("DEBUG: Properties ( cdA             ): " + cdA);
    //Sys.println("DEBUG: Properties ( airDensity      ): " + airDensity);
    //Sys.println("DEBUG: Properties ( rolling drag    ): " + rollingDrag);
    //Sys.println("DEBUG: Properties ( ground          ): " + ground);

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
                            totalPressureUp += paMeter;      
                            startPressure = dValue;                                              
                            dValue = paMeter;
                            //Sys.println("DEBUG: paMeter( up ) :" + paMeter);

                            // k = (h/a) * 100 
                            k = (paMeter/distance) * 100;
                            k = k * (-1);
                            //Sys.println("DEBUG: steigung( up% ) :" + k);
                        } else {
                            calcPressure = dValue - startPressure;
                            paMeter = calcPressure * 8.0;                 
                            paMeter = (paMeter * 100);
                            //totalPressureUp += paMeter;                   // if Up it will count back to 0  
                            //totalPressureDown += paMeter;                 // if Down it will count Down
                            startPressure = dValue;  
                            dValue = paMeter;
                            //Sys.println("DEBUG: paMeter( down ) :" + paMeter);

                            // k = (h/a) * 100 
                            k = (paMeter/distance) * 100;
                            k = k * (-1);
                            //Sys.println("DEBUG: steigung( down% ) :" + k);
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
                    // Weight of driver and equipment
                    weightOverall = weightRider + bikeEquipWeight;

                    // Pr = C1 * m * g * v 
                    Pr = rollingDrag * weightOverall * g * (sValue/3.6);
                    // Pa = 0.5 * p * cdA * v * (v-vw)2 or -> Pa = 0.5 * p * (cdA * ground) * v * (v-vw)2
                    Pa = 0.5 * airDensity * (cdA * ground) * (sValue/3.6) * ((sValue/3.6) * (sValue/3.6));
                    // Pc = (k/100) * m * g * v
                    Pc = (k/100) * weightOverall * g * (sValue/3.6);
                    // Pm = (Pr + Pa + Pc) * 0.025
                    Pm = (Pr + Pa + Pc) * 0.025;
                    // powerTotal = Pr + Pa + Pc + Pm
                    powerTotal = Pr + Pa + Pc + Pm;

                    if (sValue > 0 && updateStatus == true) { 

                        if (powerTotal > 0) {
                            wValue = powerTotal;
                        } else {
                            wValue = 0;
                        }

                        // Watt Average
                        powerOverall += powerTotal;
                        powerCount += 1;
                        powerAverage = powerOverall / powerCount;
                        avValue = powerAverage;

                        // Watt / KG
                        kgValue = powerAverage / weightRider;

                        // Add Values to FitContributor
                        fitField1.setData(wValue.toNumber()); 
                        fitField2.setData(kgValue.toNumber()); 
                        fitField3.setData(avValue.toNumber());
                    }
                }
            } else {
                sValue = 0.00f;
            }
        }

        updateStatus = false;

        var retVal = wValue.format("%d");
        var retValNb = retVal.toNumber();
        //Sys.println("DEBUG: retVal() :" + retVal); 

        // See Activity.Info in the documentation for available information.
        return retValNb;       
    }
}
