public class KAgent.Listener : PolkitAgent.Listener {
    public async override bool initiate_authentication (string action_id, string message, string icon_name,
                                                        Polkit.Details details, string cookie, GLib.List<Polkit.Identity> identities, GLib.Cancellable? cancellable) throws Polkit.Error {

        if (identities == null)
            return false;

        var background = new Background ();
        background.present ();

        var dialog = new Dialog (message, cookie, identities, cancellable);

        dialog.done.connect (() => initiate_authentication.callback ());

        dialog.present ();
        yield;

        background.destroy ();
        dialog.destroy ();

        if (dialog.was_cancelled)
            throw new Polkit.Error.CANCELLED ("Authentication dialog was dismissed by the user");

        return true;
    }
}