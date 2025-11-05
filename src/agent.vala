public class VAgent.Agent : PolkitAgent.Listener {
    private SourceFunc? cb;
    public async override bool initiate_authentication (string action_id, string message, string icon_name, Polkit.Details details, string cookie, GLib.List<Polkit.Identity> identities, GLib.Cancellable? cancellable) throws Polkit.Error {
        if (identities == null)
            return false;

        var bg = new Background ();
        var window = new Window (message, cookie, identities, cancellable);
        cb = initiate_authentication.callback;
        window.done.connect (on_done);
        bg.present ();
        window.present ();

        yield;

        window.destroy ();
        bg.close ();

        if (window.cancelled)
            throw new Polkit.Error.CANCELLED ("Authentication dialog was cancelled");

        return true;
    }

    void on_done () {
        cb ();
    }
}