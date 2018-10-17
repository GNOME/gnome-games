// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-page-plugins.ui")]
private class Games.PreferencesPagePlugins: PreferencesPage {
	[GtkChild]
	private Gtk.ListBox list_box;

	construct {
		var register = PluginRegister.get_register ();
		foreach (var plugin_registrar in register)
			add_plugin_registrar (plugin_registrar);
	}

	private void add_plugin_registrar (PluginRegistrar plugin_registrar) {
		var item = new PreferencesPagePluginsItem (plugin_registrar);
		var row = new Gtk.ListBoxRow ();
		row.add (item);
		list_box.add (row);

		item.show ();
		row.show ();
	}
}
