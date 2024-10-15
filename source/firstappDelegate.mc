import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Sensor;
import Toybox.Timer;
using Toybox.Math;
using Toybox.System;

var i_x = 125;
var i_y = 125;
var max_i_y = i_y;
var i_hole;
var min_x = 20;
var max_x = 260;
var min_y = 20;
var max_y = 260;
var p_x;
var p_y;
var new_p_x;
var new_p_y;
var v_x = 0;
var v_y = 0;
var a_x = 0;
var a_y = 0;
var max_v = 50;
var max_a = 1500;
var a_limit = 3000;
var v_limit = 300;
var max_R = 135;
var coords = [-1, -1];
var last_coords = coords;
var Tms = 100;
var s1_x = 75;
var s1_y = 75;
var s2_x = 75;
var s2_y = 195;
var new_s_x;
var new_s_y;
var last_click = 0;

var curr_screen = 0;

var timer = new Timer.Timer();
var toggle_view = true;

var compete_timer = new Timer.Timer();
var compete_flag = false;
var compete_cnt = 0;
var compete_T = 15000;
var last_compete_init = 0;
var points_indx;
var previous_player;

var name = "";
var global_i = 3;

class firstappDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        timer.start(method(:loop), Tms, true);
    }

    function loop() {
        var now = System.getTimer();
        var sensorInfo = Sensor.getInfo();
        if (sensorInfo has :accel && sensorInfo.accel != null) {
            var accel = sensorInfo.accel;

            var x = accel[0];
            var y = accel[1];
            var z = accel[2];
            var pitch = Math.atan2(y, Math.sqrt(x^2 + z^2));
            var roll = Math.atan2(-x, z);

            // lab.setText("x: " + x + ", y: " + y + ", z: " + z + "\na: " + max_a + ", v: " + max_v);
            // lab.setText("x: " + x + ", y: " + y + ", z: " + z + "\np: " + pitch + ", r: " + roll);
            a_x = new_val(x.toFloat()/1000, 0, max_a);
            var dim = subject.getDimensions();
            new_p_x = p_x + v_x*Tms/1000 + 0.5*a_x*Tms/1000*Tms/1000;
            if (Math.sqrt(Math.pow(new_p_x+dim[0]/2-max_R, 2)+Math.pow(p_y+dim[1]/2-max_R, 2)) < max_R) { 
                p_x = new_p_x;
            }
            else {
                v_x = 0;
            }
            v_x = v_x + a_x*Tms/1000;
            if (v_x < -1*max_v) { v_x = -1*max_v; }
            else if (max_v < v_x) { v_x = max_v; }

            a_y = new_val(-1*y.toFloat()/1000, 0, max_a);
            new_p_y = p_y + v_y*Tms/1000 + 0.5*a_y*Tms/1000*Tms/1000;
            if (Math.sqrt(Math.pow(p_x+dim[0]/2-max_R, 2)+Math.pow(new_p_y+dim[1]/2-max_R, 2)) < max_R) { 
                p_y = new_p_y;
            }
            else {
                v_y = 0;
            }
            v_y = v_y + a_y*Tms/1000;
            if (v_y < -1*max_v) { v_y = -1*max_v; }
            else if (max_v < v_y) { v_y = max_v; }

            WatchUi.requestUpdate();
        }

        if (info_T < (now - last_info) && info_flag) {
            info_flag = false;
        }

        // (Re)initialize fish to hunt.
        if (fish_T < (now - last_fish)) {
            last_fish = now;
            fishing = !fishing;
            fish_i = Math.rand() % 2;  // Index to fit fishes directions according their image orientation.
            v_dir = Math.rand() % 2;  // Index to set fish Y motion.
            f_x = fish_i ? 320 : 0;
            f_y = v_dir ? -320 : 0;
            f_A = 30 + Math.rand() % 30;
            f_m = 0 < v_dir ? -1-1*(Math.rand() % 2) : 1+Math.rand() % 2;
        }

        // Check fish hunting.
        if (is_in_ellipse(p_x+p_dim[0]/2, p_y+p_dim[1]/2, f_x+f_dim[0]/2, f_y+f_dim[1]/2, f_dim[0], f_dim[1])) {
            compete_timer.start(method(:competition), compete_T-1000, false);
            last_compete_init = System.getTimer() - 1000;
        }

        WatchUi.requestUpdate();
    }

    function new_val(val, min_val, max_val) {
        // if (val < min_val) { val = min_val; }
        // else if (max_val < val) { val = max_val; }
        return min_val + (max_val - min_val)*val;
    }

    function competition() {
        compete_timer.stop();
        compete_flag = false;
        for (var i=1; i<4; i++) {
            global_i = i;
            curr_val = Application.Storage.getValue("compete"+i.toString());
            if (curr_val != null) {
                if (curr_val.toString().find(":") != null) {
                    points_indx = curr_val.find(":");
                    if (curr_val.substring(points_indx+1, null).toFloat() < compete_cnt) {
                        previous_player = curr_val;
                        new_winner = true;
                        break;
                    }
                    else if (global_i == 3) {
                        game_over_flag = true;
                    }
                }
                else if (0 < compete_cnt) {
                    new_winner = true;
                    break;
                }
            }
            else {
                new_winner = true;
                break;
            }
        }
        WatchUi.requestUpdate();
    }

    function onKeyPressed(keyEvent) {
        if (keyEvent.getKey() == 4) {
            compete_flag = !compete_flag;
            if (compete_flag) {
                compete_timer.start(method(:competition), compete_T, false);
                compete_cnt = 0;
                last_compete_init = System.getTimer();
            }
            else {
                compete_timer.stop();
            }

            WatchUi.requestUpdate();
            return true;
        }
        // else if (keyEvent.getKey() == 5) {
        //     System.println("Backed.");

        //     WatchUi.requestUpdate();
        //     return false;
        // }
        
        WatchUi.requestUpdate();
        return true;
    }

    function onTap(clickEvent) {
        var now = System.getTimer();
        coords = clickEvent.getCoordinates();
        if (10 < (now-last_click) and (now-last_click) < 500) {
            // System.println("clicked");
            // System.println(clickEvent.getCoordinates().toString());
            penguin_flag = !penguin_flag;
            last_click = 0;
        }
        else {
            last_click = now;
            if (toggle_view && !info_flag) {
                if (is_in_ellipse(coords[0], coords[1], 140, 23, 20, 20)) {
                    last_info = now;
                    info_flag = true;
                }
            }
            else {
                if (is_in_ellipse(coords[0], coords[1], 10+n_dim[0]/2, 115+n_dim[1]/2, n_dim[0]/2, n_dim[1]/2)) {
                    curr_screen -= 1;
                    curr_screen = curr_screen < -1 ? -1 : curr_screen;
                    // System.println("-1");
                }
                else if (is_in_ellipse(coords[0], coords[1], 220+n_dim[0]/2, 115+n_dim[1]/2, n_dim[0]/2, n_dim[1]/2)) {
                    curr_screen += 1;
                    curr_screen = 1 < curr_screen ? 1 : curr_screen;
                    // System.println("+1");
                }
                if (curr_screen == 1) {
                    if (is_in_ellipse(coords[0], coords[1], 95+p_dim[0]/2, 25+p_dim[1]/2, p_dim[0]/2, p_dim[1]/2)) {
                        penguin_flag = true;
                    }
                    else if (is_in_ellipse(coords[0], coords[1], 70+t_dim[0]/2, 115+t_dim[1]/2, t_dim[0]/2, t_dim[1]/2)) {
                        penguin_flag = false;
                    }
                }
            }
        }
        // System.println("Clicked.");
        WatchUi.requestUpdate();
        return true;
    }

    function onDrag(dragEvent) {
        coords = dragEvent.getCoordinates();
        if (dragEvent.getType() == 0) {
            last_coords = coords;

            if (is_in_ellipse(last_coords[0], last_coords[1], s1_x+s_dim[0]/2, s1_y+s_dim[1]/2, s_dim[0], s_dim[1]) and curr_screen == 0) {
                flag_s1 = true;
            }
            else {
                flag_s1 = false;
            }

            if (is_in_ellipse(last_coords[0], last_coords[1], s2_x+s_dim[0]/2, s2_y+s_dim[1]/2, s_dim[0], s_dim[1]) and curr_screen == 0) {
                flag_s2 = true;
            }
            else {
                flag_s2 = false;
            }
        }
        if (dragEvent.getType() == 2) {
            flag_s1 = false;
            flag_s2 = false;
        }
        
        if (toggle_view) {
            i_x -= last_coords[0] - coords[0];
            i_y -= last_coords[1] - coords[1];
            if (i_x < min_x) { i_x = min_x; }
            else if (max_x < i_x) { i_x = max_x; }
            if (i_y < min_y) { i_y = min_y; }
            else if (max_y < i_y) { i_y = max_y; }
            last_coords = coords;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() as Boolean {
        // var menu = new WatchUi.Menu2({:title=>"My Menu2"});
        // var delegate;
        // menu.addItem(new MenuItem("Acceleration", max_a.toString(), "acc", {}));
        // menu.addItem(new MenuItem("Speed", max_v.toString(), "speed", {}));
        // delegate = new firstappMenuDelegate();
        // WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        toggle_view = !toggle_view;
        WatchUi.requestUpdate();
        return true;
    }
}

function disable_all() as Void {
    info.setVisible(false);
    ice_hole.setVisible(false);
    subject.setVisible(false);
    vynil1.setVisible(false);
    vynil2.setVisible(false);
    scroll1.setVisible(false);
    scroll2.setVisible(false);
    lab1.setVisible(false);
    lab2.setVisible(false);
    next.setVisible(false);
    prev.setVisible(false);
    penguin.setVisible(false);
    penguin_off.setVisible(false);
    turtle.setVisible(false);
    turtle_off.setVisible(false);
    podium.setVisible(false);
    p1.setVisible(false);
    p2.setVisible(false);
    p3.setVisible(false);
    lab.setVisible(false);
    winner.setVisible(false);
    fish.setVisible(false);
    game_over.setVisible(false);
}

function is_in_ellipse(x as Lang.Number, y as Lang.Number, c_x as Lang.Number, c_y as Lang.Number, R_x as Lang.Number, R_y as Lang.Number) as Boolean {
    return (Math.pow((x - c_x), 2) / Math.pow(R_x, 2)) + (Math.pow((y - c_y), 2) / Math.pow(R_y, 2)) <= 1;
}
