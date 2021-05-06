public class TBEdit.Window : Gtk.ApplicationWindow {
    private Json.Parser json_parser;
    private WebKit.WebView web_view;
    private File text_file;

    public File file { get; construct set; }

    private string get_extension_for_type (string type) {
        switch (type) {
            case "net.daringfireball.markdown":
            return "markdown";
            default:
            return "txt";
        }
    }

    public Window (Gtk.Application application, File file) {
        Object (application: application,
                file: file);

        var textbundle_info_file = file.resolve_relative_path ("info.json");

        json_parser = new Json.Parser ();
        try {
            json_parser.load_from_file (textbundle_info_file.get_path ().replace (" ", "\\ "));
        } catch (Error err) {
            warning (@"unable to load info.json for $(file.get_basename ()): $(err.message)");
        }

        var type = json_parser
            .get_root ()
            .get_object ()
            .get_string_member_with_default ("type", "net.daringfireball.markdown");

        set_default_size (400, 300);

        var save_button = new Gtk.Button ();

        save_button.label = "Save";
        save_button.clicked.connect (save);

        var header_bar = new Gtk.HeaderBar ();

        header_bar.show_close_button = true;
        header_bar.pack_end (save_button);

        set_titlebar (header_bar);

        web_view = new WebKit.WebView ();

        web_view.web_context.register_uri_scheme ("asset", (request) => {
            var request_path = request.get_path ();

            if (request_path.has_prefix ("/"))
                request_path = request_path[1:];

            debug (@"fetching $request_path");
            request.finish (
                File.new_build_filename (file.get_path (), "assets", request_path).read (), -1, null);
        });
        web_view.web_context.register_uri_scheme ("gresource", (request) => {
            InputStream @is = null;
            try {
                @is = resources_open_stream (request.get_path (), ResourceLookupFlags.NONE);
            } catch (Error e) {
                warning (e.message);
            }
            request.finish (@is, -1, null);
        });

        var scrolled_window = new Gtk.ScrolledWindow (null, null);

        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (web_view);

        add (scrolled_window);
        show_all ();

        text_file = File.new_build_filename (file.get_path (), @"text.$(get_extension_for_type (type))");
        text_file.load_contents_async.begin (null, (obj, res) => {
            try {
                uint8[] contents;
                string etag;

                text_file.load_contents_async.end (res, out contents, out etag);

                var template = (string) resources_lookup_data (
                    "/com/paysonwallach/tbedit/main.html", ResourceLookupFlags.NONE).get_data ();
                debug (template);

                var view = template.replace ("</textarea>",
                @"$(html_escape ((string) contents))</textarea>");
                // debug (view);

                web_view.load_bytes (
                    new Bytes (view.data),
                    null, null, null);
            } catch (Error e) {
                warning (e.message);
            }
        });
    }

    public void save () {
        this.web_view.run_javascript.begin ("window.hmd.hyperMD.getValue();", null, (obj, res) => {
            try {
                var result = this.web_view.run_javascript.end (res);
                text_file.replace_contents_async.begin (
                        result.get_js_value ().to_string ().data,
                        null, false, FileCreateFlags.NONE, null, (obj, res) => {
                    string etag;
                    try {
                        text_file.replace_contents_async.end (res, out etag);
                    } catch (Error e) {
                        warning (e.message);
                    }
                });
            } catch (Error e) {
                warning (e.message);
            }
            // this.web_view.run_javascript.begin ("window.hmd.hyperMD.cursorCoords(true);")
        });
    }

    private string html_escape (string s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("assets/", "asset:///");
    }
}
