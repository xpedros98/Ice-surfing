import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class firstappMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.getId() == "acc") {
            System.println("acc item");
        }
    }

}