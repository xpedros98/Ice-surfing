import Toybox.Graphics;
import Toybox.WatchUi;

var info;
var ice_hole;
var subject;
var penguin;
var turtle;
var fish;
var penguin_off;
var turtle_off;
var lab1;
var lab2;
var podium;
var p1;
var p2;
var p3;
var podium_list;
var curr_val;
var lab;
var winner;
var game_over;

var i_dim;
var p_dim;
var t_dim;
var n_dim;
var vynil_dim;
var s_dim;
var f_dim;

var vynil1;
var vynil2;
var scroll1;
var scroll2;
var next;
var prev;

var x_center;
var y_center;
var distance_to_point;
var flag_s1 = false;
var flag_s2 = false;
var penguin_flag = true;
var new_winner = false;
var winner_flag = false;
var last_winner = 0;
var game_over_flag = false;
var last_game_over = 0;

var info_flag = true;
var last_info;
var info_T = 2500;  // Showing info timeout.
var fishing = false;
var last_fish;
var fish_T = 2000;
var fish_i = 0;
var v_dir = 0;
var last_fish_i = fish_i;
var f_x = 0;
var f_y = 0;
var f_A = 150;
var f_m = 2;

class firstappView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        info = findDrawableById("info");

        ice_hole = findDrawableById("hole0");
        subject = findDrawableById("turtle1");
        penguin = findDrawableById("penguin_on");
        turtle = findDrawableById("turtle_on");
        penguin_off = findDrawableById("penguin_off");
        turtle_off = findDrawableById("turtle_off");
        
        p_dim = penguin.getDimensions();
        t_dim = turtle.getDimensions();                
        i_dim = ice_hole.getDimensions();

        next = findDrawableById("next");
        prev = findDrawableById("prev");

        n_dim = next.getDimensions();

        vynil1 = findDrawableById("vynil1");
        vynil2 = findDrawableById("vynil2");
        scroll1 = findDrawableById("scroll1");
        scroll2 = findDrawableById("scroll2");
        lab1 = findDrawableById("lab1");
        lab2 = findDrawableById("lab2");

        vynil_dim = vynil1.getDimensions();
        s_dim = scroll1.getDimensions();

        podium = findDrawableById("podium");

        p1 = findDrawableById("p1");
        p2 = findDrawableById("p2");
        p3 = findDrawableById("p3");
        podium_list = [p1, p2, p3];

        lab = findDrawableById("lab");
        winner = findDrawableById("winner");
        game_over = findDrawableById("game_over");
        last_info = System.getTimer();

        fish = findDrawableById("fish0");
        last_fish = System.getTimer();
        f_dim = fish.getDimensions();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.clear();

        // Application.Storage.setValue("compete"+1.toString(), "fuera");
        // Application.Storage.setValue("compete"+2.toString(), "fuera");
        // Application.Storage.setValue("compete"+3.toString(), "fuera");

        var now = System.getTimer();
        if (info_flag) {
            disable_all();
            info.setVisible(true);
            subject.setVisible(true);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_YELLOW);
            dc.drawEllipse(140, 140, 150, 150);
            dc.fillEllipse(140, 140, 150, 150);

            penguin_flag = true;
            subject = findDrawableById("penguin");
            p_x = 120;
            p_y = 115;
            subject.setLocation(p_x, p_y);
            info.draw(dc);
            subject.draw(dc);
        }
        else {
            if (toggle_view) {
                disable_all();
                subject = penguin_flag ? findDrawableById("penguin") : findDrawableById("turtle1");
                ice_hole.setVisible(true);
                subject.setVisible(true);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
                dc.drawEllipse(140, 140, 150, 150);
                dc.fillEllipse(140, 140, 150, 150);
                if (compete_flag) {
                    // Update visual timer.
                    dc.setPenWidth(20);
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_ORANGE);
                    dc.drawEllipse(140, 140, 140, 140);
                    if (0.9 < (now-last_compete_init)/compete_T) { dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_YELLOW); }
                    else { dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_YELLOW); }
                    dc.drawArc(140, 140, 140, Graphics.ARC_CLOCKWISE, 90, 90-360*(now-last_compete_init)/compete_T);
                    
                    // Update score.
                    dc.setPenWidth(1);
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_ORANGE);
                    dc.drawEllipse(140, 23, 20, 20);
                    dc.fillEllipse(140, 23, 20, 20);
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(140, 3, Graphics.FONT_MEDIUM, Lang.format("$1$", [compete_cnt.format("%.0i")]), Graphics.TEXT_JUSTIFY_CENTER);
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(140, 3, Graphics.FONT_MEDIUM, Lang.format("$1$", [compete_cnt.format("%.0f")]), Graphics.TEXT_JUSTIFY_CENTER);
                }
                else {
                    dc.setPenWidth(20);
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
                    dc.drawEllipse(140, 140, 140, 140);
                    dc.setPenWidth(1);
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
                    dc.drawEllipse(140, 23, 20, 20);
                    dc.fillEllipse(140, 23, 20, 20);
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(140, 3, Graphics.FONT_MEDIUM, "?", Graphics.TEXT_JUSTIFY_CENTER);
                }

                // Enable game.
                dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_YELLOW);
                var dim = subject.getDimensions();
                // dc.drawEllipse(e_x, e_y, Re_x, Re_y);
                // dc.drawEllipse(p_x+dim[0]/2, p_y+dim[1]/2, 0, 0);
                if (is_in_ellipse(p_x+dim[0]/2, p_y+dim[1]/2, i_x+i_dim[0]/2, i_y+i_dim[1]/2, i_dim[0]/3, i_dim[1]/3)) {
                    i_x = Math.rand() % 2*0.9*max_R;
                    max_i_y = Math.sqrt(Math.pow(0.9*max_R, 2)-Math.pow(i_x-(0.9*max_R), 2));
                    i_y = Math.rand() % 2*max_i_y;
                    
                    // Hide and set a new ice hole randomly.
                    i_hole = Math.rand() % 4;
                    ice_hole = findDrawableById("hole" + i_hole.toString());
                    compete_cnt += 1;
                }

                if (fishing) {
                    if (fish_i != last_fish_i) {
                        last_fish_i = fish_i;
                        fish = findDrawableById("fish" + fish_i.toString());  // 0: yellow; 1: blue
                    }
                    fish.setVisible(true);
                    f_x = fish_i ? f_x - 320/(fish_T/Tms) : f_x + 320/(fish_T/Tms);
                    f_y = (f_m*f_x + (v_dir ? 320 : 0) / Math.sqrt(Math.pow(f_m, 2)) + f_A*Math.sin(4*Math.PI*f_x/320));
                    fish.setLocation(f_x, f_y);
                    // dc.drawEllipse(f_x+f_dim[0]/2, f_y+f_dim[1]/2, f_dim[0], f_dim[1]);
                }

                ice_hole.setLocation(i_x, i_y);
                subject.setLocation(p_x, p_y);
                // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_GREEN);
                // dc.setPenWidth(3);
                // dc.drawLine(140, 140, p_x, p_y);
                ice_hole.draw(dc);
                subject.draw(dc);
                fish.draw(dc);
            }
            else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_YELLOW);
                dc.drawEllipse(140, 140, 150, 150);
                dc.fillEllipse(140, 140, 150, 150);
                
                disable_all();
                switch (curr_screen) {
                    case -1:
                        podium.setVisible(true);
                        next.setVisible(true);
                        podium.draw(dc);

                        for (var i=0; i<3; i++) {
                            // podium_list[i].setText(" ");
                            curr_val = Application.Storage.getValue("compete"+(i+1).toString());
                            if (curr_val and curr_val.toString().find(":") != null) {
                                // System.println("Listed "+(i+1)+" :"+curr_val.toString());
                                podium_list[i].setText(curr_val.toString());
                                podium_list[i].setVisible(true);
                                podium_list[i].draw(dc);
                            }
                        }
                        break;
                    case 0:
                        vynil1.setVisible(true);
                        vynil2.setVisible(true);
                        scroll1.setVisible(true);
                        scroll2.setVisible(true);
                        lab1.setVisible(true);
                        lab2.setVisible(true);
                        next.setVisible(true);
                        prev.setVisible(true);
                        
                        x_center = 67+vynil_dim[0]/2;
                        y_center = 50+vynil_dim[1]/2;
                        // dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW);
                        if (flag_s1) { dc.drawEllipse(s1_x+s_dim[0]/2, s1_y+s_dim[1]/2, s_dim[0], s_dim[1]); }
                        if (flag_s2) { dc.drawEllipse(s2_x+s_dim[0]/2, s2_y+s_dim[1]/2, s_dim[0], s_dim[1]); }

                        // distance_to_point  = Math.sqrt(Math.pow((coords[0] - x_center), 2) + Math.pow((coords[1] - y_center), 2));
                        if (flag_s1) {
                            var angle = Math.atan2(coords[1] - y_center, coords[0] - x_center);
                            angle = angle < 0 ? -1*angle : angle;
                            new_s_x = x_center + 30 * Math.cos(angle);
                            new_s_y = y_center + 30 * Math.sin(angle);
                            if (67 < new_s_x and new_s_x < 67+vynil_dim[0] and 50 < new_s_y and new_s_y < 50+vynil_dim[1]){
                                s1_x = new_s_x - s_dim[0]/2;
                                s1_y = (50+vynil_dim[1]/2.2 < new_s_y ? 50+vynil_dim[1]/2 - (new_s_y - 50-vynil_dim[1]/2) : new_s_y) - s_dim[1]/2;
                                max_a = angle < 0 ? -1*(Math.PI-angle)/Math.PI*a_limit : (Math.PI-angle)/Math.PI*a_limit;
                                lab1.setText("g="+Lang.format("$1$", [max_a.format("%.0d")]));
                            }
                            // dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW);
                            // dc.drawEllipse(new_s_x, new_s_y, 20, 20);
                        }
                        scroll1.setLocation(s1_x, s1_y);

                        x_center = 67+vynil_dim[0]/2;
                        y_center = 170+vynil_dim[1]/2;

                        // distance_to_point = Math.sqrt(Math.pow((coords[0] - x_center), 2) + Math.pow((coords[1] - y_center), 2));
                        if (flag_s2) {
                            var angle = Math.atan2(coords[1] - y_center, coords[0] - x_center);
                            angle = angle < 0 ? -1*angle : angle;
                            new_s_x = x_center + 30 * Math.cos(angle);
                            new_s_y = y_center + 30 * Math.sin(angle);
                            if (67 < new_s_x and new_s_x < 67+vynil_dim[0] and 170 < new_s_y and new_s_y < 170+vynil_dim[1]){
                                s2_x = new_s_x - s_dim[0]/2;
                                s2_y = (170+vynil_dim[1]/2.2 < new_s_y ? 170+vynil_dim[1]/2 - (new_s_y - 170-vynil_dim[1]/2) : new_s_y) - s_dim[1]/2;
                                max_v = angle < 0 ? -1*(Math.PI-angle)/Math.PI*v_limit : (Math.PI-angle)/Math.PI*v_limit;
                                lab2.setText("v="+Lang.format("$1$", [max_v.format("%.0d")]));
                            }
                        }
                        scroll2.setLocation(s2_x, s2_y);
                        vynil1.draw(dc);
                        vynil2.draw(dc);
                        dc.setPenWidth(3);
                        dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_YELLOW);
                        dc.drawArc(67+vynil_dim[0]/2, 50+vynil_dim[1]/2, 30, Graphics.ARC_CLOCKWISE, (180-1), 0);
                        dc.drawArc(67+vynil_dim[0]/2, 170+vynil_dim[1]/2, 30, Graphics.ARC_CLOCKWISE, (180-1), 0);
                        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_YELLOW);
                        dc.drawArc(67+vynil_dim[0]/2, 50+vynil_dim[1]/2, 30, Graphics.ARC_CLOCKWISE, (180-1), (180-2) - max_a/a_limit*(180-3));
                        dc.drawArc(67+vynil_dim[0]/2, 170+vynil_dim[1]/2, 30, Graphics.ARC_CLOCKWISE, (180-1), (180-2) - max_v/v_limit*(180-3));
                        scroll1.draw(dc);
                        scroll2.draw(dc);
                        
                        break;
                    case 1:
                        prev.setVisible(true);
                        if (penguin_flag) {
                            penguin.setVisible(true);
                            turtle_off.setVisible(true);
                        }
                        else {
                            penguin_off.setVisible(true);
                            turtle.setVisible(true);
                        }
                        penguin_off.draw(dc);
                        turtle_off.draw(dc);
                        penguin.draw(dc);
                        turtle.draw(dc);
                        break;
                    default:
                        System.println("Default?");
                }
                lab1.draw(dc);
                lab2.draw(dc);
                next.draw(dc);
                prev.draw(dc);
            }

        }
        // Winner pop up like message.
        if (new_winner and 2000 < (now-last_winner)) {
            last_winner = now;
            new_winner = false;
            winner_flag = true;
        }
        else if (!new_winner and (now-last_winner) < 2000) {
            winner.setVisible(true);
            winner.draw(dc);
            lab.setVisible(true);
            lab.setText("New winner " + global_i + "!");
            lab.draw(dc);
        }
        else if (winner_flag and 2000 < (now-last_winner)) {
            winner_flag = false;
            // Save player.
            WatchUi.pushView(
                new WatchUi.TextPicker(name),
                new MyTextPickerDelegate(),
                WatchUi.SLIDE_DOWN
            );
        }

        // Game over pop up like message.
        if (game_over_flag and 2000 < (now-last_game_over)) {
            last_game_over = now;
            game_over_flag = false;
        }
        else if (!game_over_flag and (now-last_game_over) < 2000) {
            game_over.setVisible(true);
            game_over.draw(dc);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}