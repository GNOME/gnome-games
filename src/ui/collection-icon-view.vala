// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/collection-icon-view.ui")]
private class Games.CollectionIconView : Gtk.Stack {
	public signal void game_activated (Game game);

	private string[] filtering_terms;
	public string filtering_text {
		set {
			filtering_terms = value.split (" ");
			flow_box.invalidate_filter ();
		}
	}

	private ulong model_changed_id;
	private ListModel _model;
	public ListModel model {
		get { return _model; }
		set {
			if (model != null)
				model.disconnect (model_changed_id);

			_model = value;
			clear_content ();
			if (model == null)
				return;

			for (int i = 0 ; i < model.get_n_items () ; i++) {
				var game = model.get_item (i) as Game;
				add_game (game);
			}
			model_changed_id = model.items_changed.connect (on_items_changed);

			flow_box.invalidate_sort ();
		}
	}

	[GtkChild]
	private EmptyCollection empty_collection;
	[GtkChild]
	private Gtk.ScrolledWindow scrolled_window;
	[GtkChild]
	private Gtk.FlowBox flow_box;

	// Current size used by the thumbnails.
	private int game_view_size;

	static construct {
		set_css_name ("gamescollectioniconview");
	}

	construct {
		flow_box.max_children_per_line = uint.MAX;
		flow_box.set_filter_func (filter_box);
		flow_box.set_sort_func (sort_boxes);
	}

	[GtkCallback]
	private void on_child_activated (Gtk.FlowBoxChild child) {
		if (child.get_child () is GameIconView)
			on_game_view_activated (child.get_child () as GameIconView);
	}

	private void on_game_view_activated (GameIconView game_view) {
		game_activated (game_view.game);
	}

	private void on_items_changed (uint position, uint removed, uint added) {
		// FIXME: currently games are never removed, update this function if
		// necessary.
		assert (removed == 0);

		for (uint i = position ; i < position + added ; i++) {
			var game = model.get_item (i) as Game;
			add_game (game);
		}

		update_collection ();
	}

	private void add_game (Game game) {
		var game_view = new GameIconView (game);
		var child = new Gtk.FlowBoxChild ();

		game_view.visible = true;
		game_view.size = game_view_size;
		child.visible = true;

		child.add (game_view);
		flow_box.add (child);
	}

	private void clear_content () {
		flow_box.forall ((child) => { flow_box.remove (child); });
	}

	private bool filter_box (Gtk.FlowBoxChild child) {
		var game_view = child.get_child () as GameIconView;
		if (game_view == null)
			return false;

		if (game_view.game == null)
			return false;

		return filter_game (game_view.game);
	}

	private bool filter_game (Game game) {
		if (filtering_terms.length == 0)
			return true;

		foreach (var term in filtering_terms)
			if (!(term.casefold () in game.name.casefold ()))
				return false;

		return true;
	}

	private int sort_boxes (Gtk.FlowBoxChild child1, Gtk.FlowBoxChild child2) {
		var game_view1 = child1.get_child () as GameIconView;
		var game_view2 = child2.get_child () as GameIconView;

		assert (game_view1 != null);
		assert (game_view2 != null);

		return sort_games (game_view1.game, game_view2.game);
	}

	private int sort_games (Game game1, Game game2) {
		return game1.name.collate (game2.name);
	}

	private void update_collection () {
		if (model.get_n_items () == 0)
			set_visible_child (empty_collection);
		else
			set_visible_child (scrolled_window);
	}

	[GtkCallback]
	private void on_size_allocate (Gtk.Allocation allocation) {
		// If the window's width is less than half the width of a 1920×1080
		// screen, display the game thumbnails at half the size to see more of
		// them rather than a few huge thumbnails, making Games more usable on
		// small screens.
		if (allocation.width < 960)
			set_size (128);
		else
			set_size (256);
	}

	private void set_size (int size) {
		if (game_view_size == size)
			return;

		game_view_size = size;

		flow_box.forall ((child) => {
			var flow_box_child = child as Gtk.FlowBoxChild;

			assert (flow_box_child != null);

			var game_view = flow_box_child.get_child () as GameIconView;

			assert (game_view != null);

			game_view.size = size;
		});
	}
}
