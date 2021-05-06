public class TBEdit.TextBundle : Object {
    private File file;
    private File _text_file;
    private string _root_path;

    private static Json.Parser json_parser;

    public string root_path {
        get {
            return _root_path;
        }
    }

    public File text_file {
        get {
            return _text_file;
        }
    }

    private static string get_extension_for_type (string type) {
        switch (type) {
            case "net.daringfireball.markdown":
                return "markdown";
            case "public.html":
                return "html";
            case "public.text":
            default:
                return "txt";
        }
    }

    static construct {
        json_parser = new Json.Parser ();
    }

    public TextBundle (File file) {
        this.file = file;
        _root_path = file.get_path ();

        var textbundle_info_file = file.resolve_relative_path ("info.json");

        try {
            json_parser.load_from_file (textbundle_info_file.get_path ().replace (" ", "\\ "));
        } catch (Error err) {
            warning (@"unable to load info.json for $(file.get_basename ()): $(err.message)");
        }

        var type = json_parser
            .get_root ()
            .get_object ()
            .get_string_member_with_default ("type", "net.daringfireball.markdown");

        _text_file = File.new_build_filename (file.get_path (), @"text.$(get_extension_for_type (type))");
    }
}
