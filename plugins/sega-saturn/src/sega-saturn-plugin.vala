// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SegaSaturnPlugin : Object, Plugin {
	private const string CUE_MIME_TYPE = "application/x-cue";
	private const string SEGA_SATURN_MIME_TYPE = "application/x-saturn-rom";
	private const string PLATFORM_ID = "SegaSaturn";
	private const string PLATFORM_NAME = _("Sega Saturn");
	private const string PLATFORM_UID_PREFIX = "sega-saturn";

	private static RetroPlatform platform;

	static construct {
		string[] mime_types = { CUE_MIME_TYPE, SEGA_SATURN_MIME_TYPE };
		platform = new RetroPlatform (PLATFORM_ID, PLATFORM_NAME, mime_types, PLATFORM_UID_PREFIX);
	}

	public Platform[] get_platforms () {
		return { platform };
	}

	public string[] get_mime_types () {
		return {
			CUE_MIME_TYPE,
			SEGA_SATURN_MIME_TYPE,
		};
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (CUE_MIME_TYPE);
		factory.add_mime_type (SEGA_SATURN_MIME_TYPE);

		return { factory };
	}

	public RunnerFactory[] get_runner_factories () {
		var factory = new RetroRunnerFactory (platform);

		return { factory };
	}

	private static string get_uid (SegaSaturnHeader header) throws Error {
		var product_number = header.get_product_number ();
		var areas = header.get_areas ();

		return @"$PLATFORM_UID_PREFIX-$product_number-$areas".down ();
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var file = uri.to_file ();
		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();

		File bin_file;
		switch (mime_type) {
		case CUE_MIME_TYPE:
			var cue = new CueSheet (file);
			bin_file = get_binary_file (cue);

			break;
		case SEGA_SATURN_MIME_TYPE:
			bin_file = file;

			break;
		default:
			throw new SegaSaturnError.INVALID_FILE_TYPE ("Invalid file type: expected %s or %s but got %s for file %s.", CUE_MIME_TYPE, SEGA_SATURN_MIME_TYPE, mime_type, uri.to_string ());
		}

		var header = new SegaSaturnHeader (bin_file);
		header.check_validity ();

		var uid = new Uid (get_uid (header));
		var title = new FilenameTitle (uri);
		var media = new GriloMedia (title, SEGA_SATURN_MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});

		var game = new Game (uid, uri, title, platform);
		game.set_cover (cover);

		return game;
	}

	private static File get_binary_file (CueSheet cue) throws Error {
		if (cue.tracks_number == 0)
			throw new SegaSaturnError.INVALID_CUE_SHEET ("The file “%s” doesn’t have a track.", cue.file.get_uri ());

		var track = cue.get_track (0);
		var file = track.file;

		if (file.file_format != CueSheetFileFormat.BINARY && file.file_format != CueSheetFileFormat.UNKNOWN)
			throw new SegaSaturnError.INVALID_CUE_SHEET ("The file “%s” doesn’t have a valid binary file format.", cue.file.get_uri ());

		if (!track.track_mode.is_mode1 ())
			throw new SegaSaturnError.INVALID_CUE_SHEET ("The file “%s” doesn’t have a valid track mode for track %d.", cue.file.get_uri (), track.track_number);

		var file_info = file.file.query_info ("*", FileQueryInfoFlags.NONE);
		if (file_info.get_content_type () != SEGA_SATURN_MIME_TYPE)
			throw new SegaSaturnError.INVALID_FILE_TYPE ("The file “%s” doesn’t have a valid Sega Saturn binary file.", cue.file.get_uri ());

		return file.file;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof (Games.SegaSaturnPlugin);
}
