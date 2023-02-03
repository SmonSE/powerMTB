import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class powerMTBApp extends Application.AppBase {

    hidden var _powerMTBView;

    function initialize() {
        AppBase.initialize();
        _powerMTBView = new powerMTBView(self);
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ _powerMTBView ];
    }

}

function getApp() as powerMTBApp {
    return Application.getApp() as powerMTBApp;
}