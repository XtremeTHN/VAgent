[GtkTemplate (ui = "/com/github/XtremeTHN/KAgent/dialog.ui")]
public class KAgent.Dialog : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.Label message;

    [GtkChild]
    private unowned Gtk.DropDown users_combo;

    [GtkChild]
    private unowned Gtk.PasswordEntry password;

    [GtkChild]
    private unowned Gtk.Revealer error_revealer;

    [GtkChild]
    private unowned Gtk.Label error_label;

    [GtkChild]
    private unowned Gtk.Button auth_btt;

    private Gtk.StringList users_combo_model;

    public bool was_cancelled;

    public signal void done ();

    private ulong on_show_error_id;
    private ulong on_show_info_id;
    private ulong on_completed_id;
    private ulong on_request_id;

    private ulong on_dropdown_selected_change_id;

    private PolkitAgent.Session? polkit_session = null;
    private Polkit.Identity? polkit_identity = null;

    private string _cookie;
    private unowned List<Polkit.Identity?>? _idents;
    private Cancellable _cancellable;

    public Dialog (string msg, string cookie, List<Polkit.Identity?>? idents, Cancellable cancellable) {
        // GtkLayerShell.init_for_window (this);
        // GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.ON_DEMAND);
        // GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);

        Object (
                application : new App ()
        );

        set_css_classes ({ "dialog", "background" });
        message.label = msg;

        _idents = idents;
        _cookie = cookie;
        _cancellable = cancellable;

        cancellable.cancelled.connect (cancel);

        on_dropdown_selected_change_id = users_combo.notify.connect (on_dropdown_selected_change);

        auth_btt.clicked.connect (authenticate);

        password.grab_focus ();

        close_request.connect (() => {
            cancel ();
            return true;
        });

        update_idents ();
        init_session ();
    }

    private void update_idents () {
        // new model
        users_combo_model = new Gtk.StringList (null);

        int index = 0;
        foreach (unowned Polkit.Identity? ident in _idents) {
            // Getting user name
            unowned Posix.Passwd? pwd = Posix.getpwuid (((Polkit.UnixUser) ident).get_uid ());

            // if the is not null then append it to the model
            if (pwd != null) {
                users_combo_model.append (pwd.pw_name);

                if (index == 0) {
                    users_combo.set_selected (index);
                }
            }

            ++index;
        }

        users_combo.set_model (users_combo_model);

        // Calling this for updating polkit_identity
        on_dropdown_selected_change ();
    }

    private void init_session () {
        if (polkit_session != null) {
            // calling this because we will create a new session
            deinit_session ();
        }

        polkit_session = new PolkitAgent.Session (polkit_identity, _cookie);
        on_show_error_id = polkit_session.show_error.connect (on_show_error);
        on_show_info_id = polkit_session.show_info.connect (on_show_info);
        on_completed_id = polkit_session.completed.connect (on_completed);
        on_request_id = polkit_session.request.connect (on_request);

        polkit_session.initiate ();
    }

    private void on_dropdown_selected_change () {
        uint ident_pos = users_combo.selected;

        deinit_session ();

        // Getting identity from _idents
        polkit_identity = _idents.nth_data (ident_pos);

        init_session ();
    }

    private void deinit_session () {
        if (polkit_session == null) {
            return;
        }
        ;

        SignalHandler.disconnect (polkit_session, on_show_error_id);
        SignalHandler.disconnect (polkit_session, on_show_info_id);
        SignalHandler.disconnect (polkit_session, on_completed_id);
        SignalHandler.disconnect (polkit_session, on_request_id);

        polkit_session = null;
    }

    private void on_show_error (string error) {
        warning (error);
        error_label.label = error;
        error_revealer.set_reveal_child (true);
    }

    private void on_show_info (string text) {
        info (text);
    }

    void reset_session () {
        deinit_session ();
        password.set_text ("");
        password.grab_focus ();
        init_session ();
    }

    private void on_completed (bool authorized) {
        // this get's called when the session is completed

        if (!authorized) {
            // if not authorized, reset password entry, reset session, and request password
            on_show_error ("Incorrect password");
            reset_session ();
            return;
        } else if (_cancellable.is_cancelled ()) {
            // if was cancelled, reset password entry and reset session
            reset_session ();
            return;
        } else {
            // emit done signal
            done ();

            // Disconnect from notify, cuz if i dont disconnect it, an address boundary error will stop the program
            SignalHandler.disconnect (users_combo, on_dropdown_selected_change_id);
        }
    }

    private void authenticate () {
        if (polkit_session == null) {
            init_session ();
        }

        error_revealer.set_reveal_child (false);

        // emiting response signal with the content of password entry
        polkit_session.response (password.get_text ());
    }

    private void on_request (string request, bool echo_on) {
        // idk what this function does
        if (!request.has_prefix ("Password:")) {
            password.placeholder_text = request;
        }
    }

    private void cancel () {
        if (polkit_session != null) {
            polkit_session.cancel ();
        }

        // Disconnect from notify, cuz if i dont disconnect it, an address boundary error will stop the program
        SignalHandler.disconnect (users_combo, on_dropdown_selected_change_id);

        debug ("Authentication cancelled");
        was_cancelled = true;

        done ();
    }
}