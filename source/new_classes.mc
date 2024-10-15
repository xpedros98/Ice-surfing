using Toybox.WatchUi;

class MyTextPickerDelegate extends WatchUi.TextPickerDelegate {

    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) {
        name = text;

        // Save new player.
        Application.Storage.setValue("compete"+global_i.toString(), name + " : " + compete_cnt);
        System.println("New saved player: " + global_i + " : " + Application.Storage.getValue("compete"+global_i.toString()));

        // Update ranking.
        for (var j=global_i+1; j<4; j++) {
            curr_val = Application.Storage.getValue("compete"+j.toString());
            Application.Storage.setValue("compete"+j.toString(), previous_player);
            previous_player = curr_val;
        }

        return true;
    }

    function onCancel() {
        return true;
    }
}

class MyInputDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(key) {
        if (WatchUi has :TextPicker) {
            if (key.getKey() == WatchUi.KEY_MENU) {
                WatchUi.pushView(
                    new WatchUi.TextPicker(name),
                    new MyTextPickerDelegate(),
                    WatchUi.SLIDE_DOWN
                );
            }
        }
        return true;
    }
}