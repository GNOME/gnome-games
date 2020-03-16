// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericGame : Object, Game {
	private string _name;
	public string name {
		get {
			if (_name != null)
				return _name;

			try {
				_name = game_title.get_title ();
			}
			catch (Error e) {
				warning (e.message);
			}

			if (_name == null)
				_name = "";

			return _name;
		}
	}

	private Uid game_uid;
	private Uri game_uri;
	private Title game_title;
	private Icon game_icon;
	private Cover game_cover;
	private Platform game_platform;
	private MediaSet? media_set;

	public GenericGame (Uid uid, Uri uri, Title title, Platform platform) {
		game_uid = uid;
		game_uri = uri;
		game_title = title;
		game_platform = platform;
	}

	public Uid get_uid () {
		return game_uid;
	}

	public Uri get_uri () {
		return game_uri;
	}

	public Icon get_icon () {
		if (game_icon == null)
			game_icon = new DummyIcon ();

		return game_icon;
	}

	public void set_icon (Icon icon) {
		game_icon = icon;
	}

	public Cover get_cover () {
		if (game_cover == null)
			game_cover = new DummyCover ();

		return game_cover;
	}

	public void set_cover (Cover cover) {
		game_cover = cover;
	}

	public MediaSet? get_media_set () {
		return media_set;
	}

	public void set_media_set (MediaSet? media_set) {
		this.media_set = media_set;
	}

	public Platform get_platform () {
		return game_platform;
	}
}
