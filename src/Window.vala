public class TBEdit.Window : Gtk.ApplicationWindow {
    public Window (Gtk.Application application, TextBundle text_bundle) {
        Object (
            application: application);

        var web_view_controller = new TextBundleViewController (text_bundle);

        set_default_size (400, 300);

        var save_button = new Gtk.Button ();

        save_button.label = "Save";
        save_button.clicked.connect (web_view_controller.save);

        var header_bar = new Gtk.HeaderBar ();

        header_bar.show_close_button = true;
        header_bar.pack_end (save_button);

        set_titlebar (header_bar);

        var scrolled_window = new Gtk.ScrolledWindow (null, null);

        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (web_view_controller.view);

        add (scrolled_window);
        show_all ();
    }
}
