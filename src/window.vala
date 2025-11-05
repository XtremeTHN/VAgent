using Gtk;

[GtkTemplate (ui = "/com/github/XtremeTHN/VAgent/window.ui")]
public class Window : Adw.Window {
    [GtkChild]
    unowned Label subtitle;

    [GtkChild]
    unowned DropDown users_dropdown;

    [GtkChild]
    unowned PasswordEntry password_entry;

    [GtkChild]
    unowned Adw.Spinner spinner;

    [GtkChild]
    unowned Revealer revealer;

    [GtkChild]
    unowned Label error_label;

    public signal void done ();

    private string cookie;
    private unowned List<Polkit.Identity?>? idents;
    private Cancellable cancellable;

    private PolkitAgent.Session? polkit_session = null;
    private Polkit.Identity? polkit_identity = null;

    private ulong on_show_error_id;
    private ulong on_show_info_id;
    private ulong on_completed_id;
    private ulong on_request_id;

    public bool cancelled = false;

    public Window (string msg, string cookie, List<Polkit.Identity?>? idents, Cancellable cancellable) {
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.EXCLUSIVE);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);

        subtitle.label = msg;

        this.cookie = cookie;
        this.idents = idents;
        this.cancellable = cancellable;

        cancellable.cancelled.connect (cancel);
        close_request.connect (() => {
            cancel ();
            return false;
        });

        users_dropdown.notify["selected-item"].connect (on_selected_user_change);
        populate_dropdown ();

        init_session ();
        password_entry.grab_focus ();
    }

    [GtkCallback]
    private void authenticate () {
        set_sensitive (false);
        spinner.set_visible (true);

        if (polkit_session == null)
            init_session ();

        revealer.set_reveal_child (false);

        polkit_session.response (password_entry.get_text ());
    }

    void init_session () {
        if (polkit_session != null)
            deinit_session ();

        polkit_session = new PolkitAgent.Session (polkit_identity, cookie);
        on_show_error_id = polkit_session.show_error.connect (on_show_error);
        on_show_info_id = polkit_session.show_info.connect (on_show_info);
        on_completed_id = polkit_session.completed.connect (on_completed);
        on_request_id = polkit_session.request.connect (on_request);

        polkit_session.initiate ();
    }

    void deinit_session () {
        if (polkit_session == null)
            return;

        SignalHandler.disconnect (polkit_session, on_show_error_id);
        SignalHandler.disconnect (polkit_session, on_show_info_id);
        SignalHandler.disconnect (polkit_session, on_completed_id);
        SignalHandler.disconnect (polkit_session, on_request_id);

        polkit_session = null;
    }

    void reset_session () {
        deinit_session ();
        password_entry.set_text ("");
        password_entry.grab_focus ();
        init_session ();
    }

    void on_show_error (string text) {
        error_label.set_label (text);
        revealer.set_reveal_child (true);
    }

    void on_show_info (string text) {
        message (text);
    }

    void on_completed (bool authorized) {
        set_sensitive (true);
        spinner.set_visible (false);

        if (!authorized) {
            on_show_error ("Invalid password");
            reset_session ();
        } else if (cancellable.is_cancelled ())
            reset_session ();
        else
            done ();
    }

    private void on_request (string request, bool echo_on) {
        // idk what this function does
        if (!request.has_prefix ("Password:")) {
            password_entry.placeholder_text = request;
        }
    }

    void on_selected_user_change () {
        var selected_user = users_dropdown.selected;

        polkit_identity = idents.nth_data (selected_user);
        reset_session ();
    }

    void populate_dropdown () {
        var model = new StringList (null);

        foreach (unowned Polkit.Identity? ident in idents) {
            unowned Posix.Passwd? pwd = Posix.getpwuid (((Polkit.UnixUser) ident).get_uid ());

            if (pwd == null)
                continue;
            model.append (pwd.pw_name);
        }

        users_dropdown.set_model (model);
        users_dropdown.set_selected (0);
        on_selected_user_change ();
    }

    void cancel () {
        if (polkit_session == null)
            polkit_session.cancel ();

        cancelled = true;
        done ();
    }
}