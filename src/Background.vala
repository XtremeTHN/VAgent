class KAgent.Background : Gtk.ApplicationWindow {
    public Background () {
        var app = new App ();

        Object (
                application: app
        );

        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_namespace (this, "kagent_background");
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);

        set_opacity (app.background_opacity);
    }
}