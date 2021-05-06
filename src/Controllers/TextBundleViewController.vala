private class TBEdit.TextBundleViewController : Object {
    private TextBundle text_bundle;
    private WebKit.WebView web_view;

    public WebKit.WebView view {
        get {
            return web_view;
        }
    }

    public TextBundleViewController (TextBundle text_bundle) {
        this.text_bundle = text_bundle;

        web_view = new WebKit.WebView ();

        web_view.web_context.register_uri_scheme ("asset", (request) => {
            var request_path = request.get_path ();

            if (request_path.has_prefix ("/"))
                request_path = request_path[1:];

            debug (@"fetching $request_path");
            request.finish (
                File.new_build_filename (text_bundle.root_path, "assets", request_path).read (), -1, null);
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

        load ();
    }

    public void load () {
        text_bundle.text_file.load_contents_async.begin (null, (obj, res) => {
            try {
                uint8[] contents;
                string etag;

                text_bundle.text_file.load_contents_async.end (res, out contents, out etag);

                var template = (string) resources_lookup_data (
                    "/com/paysonwallach/tbedit/main.html", ResourceLookupFlags.NONE).get_data ();
                debug (template);

                var view = template.replace ("</textarea>",
                @"$(html_escape ((string) contents))</textarea>");
                var view_data = new Bytes (view.data);

                web_view.load_bytes (view_data, null, null, null);
            } catch (Error e) {
                warning (e.message);
            }
        });
    }

    public void save () {
        web_view.run_javascript.begin ("window.hmd.hyperMD.getValue();", null, (obj, res) => {
            try {
                var result = web_view.run_javascript.end (res);
                text_bundle.text_file.replace_contents_async.begin (
                        result.get_js_value ().to_string ().data,
                        null, false, FileCreateFlags.NONE, null, (obj, res) => {
                    string etag;
                    try {
                        text_bundle.text_file.replace_contents_async.end (res, out etag);
                    } catch (Error e) {
                        warning (e.message);
                    }
                });
            } catch (Error e) {
                warning (e.message);
            }

            // web_view.run_javascript.begin ("window.hmd.hyperMD.cursorCoords(true);")
        });
    }

    private string html_escape (string s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("assets/", "asset:///");
    }
}
