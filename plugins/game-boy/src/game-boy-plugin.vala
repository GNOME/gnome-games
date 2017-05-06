// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GameBoyPlugin : Object, Plugin {
	private const string GAME_BOY_PREFIX = "game-boy";
	private const string GAME_BOY_MIME_TYPE = "application/x-gameboy-rom";
	private const string GAME_BOY_PLATFORM = "GameBoy";

	// Similar to GAME_BOY_PREFIX for simplicity and backward compatibility.
	private const string GAME_BOY_COLOR_PREFIX = "game-boy";
	private const string GAME_BOY_COLOR_MIME_TYPE = "application/x-gameboy-color-rom";
	private const string GAME_BOY_COLOR_PLATFORM = "GameBoyColor";

	public string[] get_mime_types () {
		return {
			GAME_BOY_MIME_TYPE,
			GAME_BOY_COLOR_MIME_TYPE,
		};
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (GAME_BOY_MIME_TYPE);
		factory.add_mime_type (GAME_BOY_COLOR_MIME_TYPE);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var file = uri.to_file ();
		var header = new GameBoyHeader (file);

		string prefix;
		string mime_type;
		string platform;
		if (header.is_classic ()) {
			prefix = GAME_BOY_PREFIX;
			platform = GAME_BOY_PLATFORM;
			mime_type = GAME_BOY_MIME_TYPE;
		}
		else if (header.is_color ()) {
			prefix = GAME_BOY_COLOR_PREFIX;
			platform = GAME_BOY_COLOR_PLATFORM;
			mime_type = GAME_BOY_COLOR_MIME_TYPE;
		}
		else
			assert_not_reached ();

		var uid = new FingerprintUid (uri, prefix);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, mime_type);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (platform, { mime_type });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.GameBoyPlugin);
}
