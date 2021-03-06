/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Gee;

namespace IndicatorKDEConnect {
    public class FirstTimeWizard : Gtk.Window {
        private KDEConnectManager manager;
        private HashSet<DeviceManager> list;
        
        public FirstTimeWizard (KDEConnectManager manager) {
            this.default_width = 600;
            this.default_height = 500;
            this.set_icon_name("kdeconnect");
            this.manager = manager;

            var stack = new Gtk.Stack ();
            stack.margin = 20;
            stack.homogeneous = true;
            stack.set_transition_duration (1000);
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);

            stack.add_named (create_connect_page (), 
                             "connect");

            stack.add_named (create_pair_page (), 
                             "pair");

            stack.add_named (create_finish_page (), 
                             "finish");

            stack.visible_child_name = "finish";

            this.add (stack);
            this.show_all ();

            list = new HashSet<DeviceManager> ();
            
            manager.device_added.connect ((id) => {
                if (stack.visible_child_name == "connect"){
                    stack.visible_child_name = "pair";
                    var d = new DeviceManager (id);
                    d.trusted_status_changed.connect ((trusted)=> {
                        if (trusted && stack.visible_child_name == "pair")
                            stack.visible_child_name = "finish";
                    });
                    list.add (d);
                }
            }); 
        }

        private Gtk.Widget create_connect_page () {
            return create_box (Gtk.Orientation.HORIZONTAL,
                    _("<b>Are you ready for your first device pairing?</b>\n\n")+
                    _("Now connect your devices using wifi connection.\n")+
                    _("Tethering should work too!\n")+
                    _("If you have Firewall running, please open port 1714-1764 for TCP and UDP\n\n")+
                    _("Launch KDE Connect in your Android which you can download from ")+
                    """<a href="https://play.google.com/store/apps/details?id=org.kde.kdeconnect_tp">"""+
                    _("Google Play</a>"),
                    Config.PACKAGE_DATADIR+"/icons/hicolor/256x256/apps/kdeconnect.png");
        }

        private Gtk.Widget create_pair_page () {
            return create_box (Gtk.Orientation.VERTICAL,
                    _("Everytime there is a new device connected, a new indicator will appear in your panel.\n")+
                    _("There, you can pair and see its status\n\n")+
                    _("<b>Now try to pair your device</b>"),
                    Config.PACKAGE_DATADIR+"/indicator.jpg");
        }

        private Gtk.Widget create_finish_page () {
            return create_box (Gtk.Orientation.VERTICAL,
                    _("<b>Great! your device is all set</b>\n\n")+
                    _("Now you can enable or disable modules on KDE Connect settings.\n")+
                    _("Indicator already added to autostart.\n")+
                    _("Enjoy!"),
                    Config.PACKAGE_DATADIR+"/startup.jpg");
        }
        
        private Gtk.Box create_box (Gtk.Orientation orientation, string markup, string image_path) {
            var box = new Gtk.Box (orientation, 10);

            box.pack_start (new Gtk.Image.from_file (image_path));

            var l = new Gtk.Label (null);
            l.set_markup (markup);
            l.wrap = true;
            l.justify = Gtk.Justification.LEFT;
            box.pack_start (l);

            return box;
        }
    }
}
