// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GriloDescription : Object, Description {
	private GriloMedia media;
	private string description;
	private bool resolving;

	public bool has_loaded { get; protected set; }

	public GriloDescription (GriloMedia media) {
		this.media = media;
		media.resolved.connect (on_media_resolved);
		description = "";
	}

	public string get_description () {
		if (resolving || has_loaded)
			return description;

		resolving = true;
		media.try_resolve_media ();

		return description;
	}

	private void on_media_resolved () {
		var grl_media = media.get_media ();

		if (grl_media == null)
			return;

		if (grl_media.length (Grl.MetadataKey.DESCRIPTION) == 0)
			return;

		description = grl_media.get_description ();

		has_loaded = true;
	}
}
