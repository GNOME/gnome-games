// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.SnapshotManager : Object {
	private const int MAX_AUTOSAVES = 5;

	public delegate void SnapshotFunc (Snapshot snapshot) throws Error;

	private Game game;
	private string core_id;

	private Snapshot[] snapshots;

	public SnapshotManager (Game game, string core_id) throws Error {
		this.game = game;
		this.core_id = core_id;

		var dir_path = get_snapshots_dir ();
		var dir_file = File.new_for_path (dir_path);

		if (!dir_file.query_exists ()) {
			dir_file.make_directory_with_parents ();

			snapshots = {};
			return;
		}

		var dir = Dir.open (dir_path);

		snapshots = {};
		string snapshot_name = null;

		while ((snapshot_name = dir.read_name ()) != null) {
			if (snapshot_name == "global")
				continue;

			var snapshot_path = Path.build_filename (dir_path, snapshot_name);
			snapshots += Snapshot.load (game.platform, core_id, snapshot_path);
		}

		qsort_with_data (snapshots, sizeof (Snapshot), Snapshot.compare);
	}

	private string get_snapshots_dir () throws Error {
		var uid = game.uid;
		var core_id_prefix = core_id.replace (".libretro", "");

		return Path.build_filename (Application.get_data_dir (),
		                            "savestates",
		                            @"$uid-$core_id_prefix");
	}

	public Snapshot[] get_snapshots () {
		return snapshots;
	}

	public bool has_snapshots () {
		return snapshots.length > 0;
	}

	public Snapshot? get_latest_snapshot () {
		if (has_snapshots ())
			return snapshots[0];

		return null;
	}

	private void trim_autosaves () {
		int n_autosaves = 1;

		foreach (var snapshot in snapshots) {
			if (!snapshot.is_automatic)
				continue;

			if (n_autosaves < MAX_AUTOSAVES) {
				n_autosaves++;
				continue;
			}

			snapshot.delete_from_disk ();
		}
	}

	private string create_new_snapshot_name () throws Error {
		var list = new List<int> ();
		var regex = new Regex (_("New snapshot %s").printf ("([1-9]\\d*)"));

		foreach (var snapshot in snapshots) {
			if (snapshot.is_automatic)
				continue;

			MatchInfo match_info = null;

			if (regex.match (snapshot.name, 0, out match_info)) {
				var number = match_info.fetch (1);
				list.prepend (int.parse (number));
			}
		}

		list.sort ((a, b) => a - b);

		// Find the next available name for a new manual snapshot
		int next_number = 1;
		foreach (var number in list) {
			if (number != next_number)
				break;

			next_number++;
		}

		return _("New snapshot %s").printf (next_number.to_string ());
	}

	public Snapshot create_snapshot (bool is_automatic, SnapshotFunc save_callback) throws Error {
		// Make room for the new automatic snapshot
		if (is_automatic)
			trim_autosaves ();

		var creation_date = new DateTime.now ();
		var path = Path.build_filename (get_snapshots_dir (),
		                                creation_date.to_string ());

		var snapshot = Snapshot.create_empty (game, core_id, path);

		snapshot.is_automatic = is_automatic;
		snapshot.name = is_automatic ? null : create_new_snapshot_name ();
		snapshot.creation_date = creation_date;

		save_callback (snapshot);
		snapshot.write_metadata ();

		snapshot = snapshot.move_to (path);

		Snapshot[] new_snapshots = {};

		new_snapshots += snapshot;
		foreach (var s in snapshots)
			new_snapshots += s;

		snapshots = new_snapshots;

		return snapshot;
	}

	public void delete_snapshot (Snapshot snapshot) {
		Snapshot[] new_snapshots = {};

		foreach (var s in snapshots)
			if (snapshot != s)
				new_snapshots += s;

		snapshots = new_snapshots;

		snapshot.delete_from_disk ();
	}
}
