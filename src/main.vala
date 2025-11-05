namespace VAgent {
    public double opacity = 0.5;

    public class App : Adw.Application {
        public App () {
            Object (application_id: "com.github.XtremeTHN.VAgent", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
        }

        int init () {
            var listener = new Agent ();

            try {
                var subject = new Polkit.UnixSession.for_process_sync (Posix.getpid (), null);
                listener.register (PolkitAgent.RegisterFlags.NONE, subject, "/com/github/XtremeTHN/VAgent", null);
            } catch (Error e) {
                critical ("Couldn't register the agent: %s", e.message);
                return 1;
            }

            return 0;
        }

        public static int main (string[] args) {
            var app = new App ();
            return app.run (args);
        }

        protected override int command_line (ApplicationCommandLine cmd) {
            var args = cmd.get_arguments ();
            var ctx = new OptionContext ();

            OptionEntry[] entries = {
                { "opacity", 'o', OptionFlags.NONE, OptionArg.DOUBLE, ref opacity, "Sets the background opacity. Range from 0 to 1", "OPACITY" }
            };

            ctx.add_main_entries (entries, null);

            try {
                ctx.parse_strv (ref args);
            } catch (Error e) {
                cmd.printerr ("Couldn't parse arguments: %s\n", e.message);
                return 1;
            }

            if (opacity > 1 || opacity < 0) {
                cmd.printerr_literal ("Only values between 0 and 1 are allowed.\n");
                opacity = 0.5;
            }

            if (cmd.is_remote) {
                cmd.printerr_literal ("VAgent is already running\n");
                return 2;
            }

            hold ();
            return init ();
        }
    }
}