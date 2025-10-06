/* application.vala
 *
 * Copyright 2024 Unknown
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace KAgent {
    public double background_opacity = 0.7;
    public bool disable_background;

    public class App : Adw.Application {


        public App () {
            Object (
                    application_id: "com.github.XtremeTHN.KAgent",
                    flags: ApplicationFlags.HANDLES_COMMAND_LINE,
                    register_session: true
            );
        }

        int init () {
            var agent = new Listener ();

            try {
                var subject = new Polkit.UnixSession.for_process_sync (Posix.getpid (), new Cancellable ());
                agent.register (NONE, subject, "/com/github/XtremeTHN/KAgent", new Cancellable ());
            } catch (Error e) {
                critical ("Error while trying to register the authentication agent: %s", e.message);
                return 3;
            }

            hold ();
            return 0;
        }

        protected override int command_line (ApplicationCommandLine cmd) {
            var args = cmd.get_arguments ();
            var ctx = new OptionContext ();

            OptionEntry[] entries = {
                { "opacity", 'o', OptionFlags.NONE, OptionArg.DOUBLE, ref background_opacity, "Sets the background opacity. Range from 0 to 1", "OPACITY" },
                { "disable-background", 'd', OptionFlags.NONE, OptionArg.NONE, ref disable_background, "Disables background" }
            };

            ctx.add_main_entries (entries, null);

            try {
                ctx.parse_strv (ref args);
            } catch (Error e) {
                warning ("Couldn't parse arguments: %s", e.message);
                return 1;
            }

            if (background_opacity > 1 || background_opacity < 0) {
                warning ("Only values between 0 and 1 are allowed.");
                return 2;
            }

            return init ();
        }

        public static int main (string[] args) {
            var app = new App ();
            return app.run (args);
        }
    }
}