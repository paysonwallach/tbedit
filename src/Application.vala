public class TBEdit.Application : Gtk.Application {
    private List<TBEdit.Window> windows;

    public Application () {
        Object (
            application_id: Config.APPLICATION_ID,
            flags: ApplicationFlags.HANDLES_OPEN);
    }

    construct {
        windows = new List<TBEdit.Window> ();
    }

    public override void open (File[] files, string hint) {
        foreach (var file in files) {
            try {
                var window = new TBEdit.Window (this, file);
                windows.append (window);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    public static int main (string[] args) {
        var application = new Application ();
        return application.run (args);
    }
}
