// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/collection-view.ui")]
private class Games.CollectionView : Gtk.Box, UiView {
	private const string CONTRIBUTE_URI = "https://wiki.gnome.org/Apps/Games/Contribute";

	public signal void game_activated (Game game);

	[GtkChild]
	private Hdy.Deck deck;
	[GtkChild]
	private Gtk.Stack header_bar_stack;
	[GtkChild]
	private Hdy.HeaderBar header_bar;
	[GtkChild]
	private Hdy.HeaderBar subview_header_bar;
	[GtkChild]
	private Hdy.HeaderBar selection_mode_header_bar;
	[GtkChild]
	private Hdy.ViewSwitcherTitle view_switcher_title;
	[GtkChild]
	private ErrorInfoBar error_info_bar;
	[GtkChild]
	private SearchBar search_bar;
	[GtkChild]
	private EmptyCollection empty_collection;
	[GtkChild]
	private EmptySearch empty_search;
	[GtkChild]
	private GamesPage games_page;
	[GtkChild]
	private PlatformsPage platforms_page;
	[GtkChild]
	private Gtk.Stack empty_stack;
	[GtkChild]
	private Gtk.Stack viewstack;
	[GtkChild]
	private Hdy.ViewSwitcherBar view_switcher_bar;
	[GtkChild]
	private Hdy.SwipeGroup swipe_group;

	private bool _is_view_active;
	public bool is_view_active {
		get { return _is_view_active; }
		set {
			if (is_view_active == value)
				return;

			_is_view_active = value;

			if (!is_view_active)
				search_mode = false;

			konami_code.reset ();
		}
	}

	private bool _is_collection_empty;
	public bool is_collection_empty {
		get { return _is_collection_empty; }
		set {
			_is_collection_empty = value;
			if (_is_collection_empty)
				empty_stack.visible_child = empty_collection;
			else
				empty_stack.visible_child = viewstack;
		}
	}

	public string[] filtering_terms;
	public string filtering_text {
		 set {
			if (value == null)
				filtering_terms = null;
			else
				filtering_terms = value.split (" ");

			platforms_page.set_filter (filtering_terms);
			games_page.set_filter (filtering_terms);
		}
	}

	public Gtk.Window window { get; construct; }

	private GameModel _game_model;
	public GameModel game_model {
		get { return _game_model; }
		set {
			_game_model = value;

			games_page.game_model = game_model;
			platforms_page.game_model = game_model;

			is_collection_empty = game_model.get_n_items () == 0;
			game_model.items_changed.connect (() => {
				is_collection_empty = game_model.get_n_items () == 0;
			});
		}
	}

	public bool loading_notification { get; set; }
	public bool search_mode { get; set; }

	public bool is_folded { get; set; }
	public bool is_showing_bottom_bar { get; set; }
	public bool is_subview_open { get; set; }
	public bool is_selection_mode { get; set; }
	public bool is_selection_available { get; set; }

	private KonamiCode konami_code;
	private SimpleActionGroup action_group;
	private const ActionEntry[] action_entries = {
		{ "select-all",    select_all },
		{ "select-none",   select_none },
		{ "toggle-select", toggle_select }
	};

	construct {
		var icon_name = Config.APPLICATION_ID + "-symbolic";
		viewstack.child_set (games_page, "icon-name", icon_name);

		swipe_group.add_swipeable (platforms_page.get_leaflet ());

		konami_code = new KonamiCode (window);
		konami_code.code_performed.connect (on_konami_code_performed);

		action_group = new SimpleActionGroup ();
		action_group.add_action_entries (action_entries, this);
		window.insert_action_group ("view", action_group);
	}

	public void show_error (string error_message) {
		error_info_bar.show_error (error_message);
	}

	public bool on_button_pressed (Gdk.EventButton event) {
		return false;
	}

	public bool on_key_pressed (Gdk.EventKey event) {
		var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

		uint keyval;
		var keymap = Gdk.Keymap.get_for_display (window.get_display ());
		keymap.translate_keyboard_state (event.hardware_keycode, event.state,
		                                 event.group, out keyval, null, null, null);

		if (((event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) &&
		    (((window.get_direction () == Gtk.TextDirection.LTR) && keyval == Gdk.Key.Left) ||
		     ((window.get_direction () == Gtk.TextDirection.RTL) && keyval == Gdk.Key.Right)) &&
		     !is_selection_mode &&
		     deck.navigate (Hdy.NavigationDirection.BACK))
			return true;

		if ((keyval == Gdk.Key.f || keyval == Gdk.Key.F) &&
		    (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK &&
		    !is_collection_empty) {
			if (!search_mode)
				search_mode = true;

			return true;
		}

		if ((keyval == Gdk.Key.question) &&
			(event.state & default_modifiers) == (Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK)) {

			var shortcuts_window = new ShortcutsWindow ();
			shortcuts_window.show_all();

			return true;
		}

		if (is_collection_empty)
			return false;

		if (is_selection_mode && keyval == Gdk.Key.Escape) {
			toggle_select ();
			return true;
		}

		return search_bar.handle_event (event);
	}

	public bool gamepad_button_press_event (Manette.Event event) {
		if (!window.is_active)
			return false;

		if (!get_mapped ())
			return false;

		uint16 button;
		if (!event.get_button (out button))
			return false;

		if (is_collection_empty)
			return false;

		switch (button) {
		case EventCode.BTN_TL:
			if (is_selection_mode)
				return true;

			var views = viewstack.get_children ();
			unowned List<weak Gtk.Widget> current_view = views.find (viewstack.visible_child);

			assert (current_view != null);

			if (current_view.prev != null)
				viewstack.visible_child = current_view.prev.data;

			return true;
		case EventCode.BTN_TR:
			if (is_selection_mode)
				return true;

			var views = viewstack.get_children ();
			unowned List<weak Gtk.Widget> current_view = views.find (viewstack.visible_child);

			assert (current_view != null);

			if (current_view.next != null)
				viewstack.visible_child = current_view.next.data;

			return true;
		default:
			if (viewstack.visible_child == platforms_page)
				return platforms_page.gamepad_button_press_event (event);
			else
				return games_page.gamepad_button_press_event (event);
		}
	}

	public bool gamepad_button_release_event (Manette.Event event) {
		if (!window.is_active)
			return false;

		if (!get_mapped ())
			return false;

		if (viewstack.visible_child == platforms_page)
			return platforms_page.gamepad_button_release_event (event);
		else
			return games_page.gamepad_button_release_event (event);
	}

	public bool gamepad_absolute_axis_event (Manette.Event event) {
		if (!window.is_active)
			return false;

		if (!get_mapped ())
			return false;

		if (viewstack.visible_child == platforms_page)
			return platforms_page.gamepad_absolute_axis_event (event);
		else
			return games_page.gamepad_absolute_axis_event (event);
	}

	private void on_konami_code_performed () {
		if (!is_view_active)
			return;

		try {
			Gtk.show_uri_on_window (window, CONTRIBUTE_URI, Gtk.get_current_event_time ());
		}
		catch (Error e) {
			critical (e.message);
		}
	}

	public void run_search (string query) {
		search_mode = true;
		search_bar.run_search (query);
	}

	private void select_none () {
		platforms_page.select_none ();
		games_page.select_none ();
	}

	private void select_all () {
		if (viewstack.visible_child == platforms_page)
			platforms_page.select_all ();
		else
			games_page.select_all ();
	}

	private void toggle_select () {
		is_selection_mode = !is_selection_mode;
	}

	[GtkCallback]
	private void on_selection_mode_changed () {
		if (is_selection_mode) {
			header_bar_stack.visible_child = selection_mode_header_bar;
		}
		else {
			select_none ();
			header_bar_stack.visible_child = deck;
		}

		update_bottom_bar ();
	}

	[GtkCallback]
	private void on_collection_empty_changed () {
		update_adaptive_state ();
		update_selection_availability ();
	}

	[GtkCallback]
	private void update_selection_availability () {
		is_selection_available = (viewstack.visible_child != platforms_page || !is_folded)
		                          && !is_collection_empty;
	}

	[GtkCallback]
	private void on_loading_notification_closed () {
		loading_notification = false;
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		game_activated (game);
	}

	[GtkCallback]
	private void on_visible_child_changed () {
		if (viewstack.visible_child == games_page)
			games_page.reset_scroll_position ();
		else
			platforms_page.reset ();

		update_selection_availability ();
	}

	[GtkCallback]
	private void on_search_text_notify () {
		filtering_text = search_bar.text;
		if (found_games ())
			empty_stack.visible_child = viewstack;
		else
			empty_stack.visible_child = empty_search;

		// Changing the filtering_text for the PlatformsPage might
		// cause the currently selected sidebar row to become empty and therefore
		// hidden. In this case the first visible row will become selected and
		// this causes the search bar to lose focus so we have to regrab it here
		search_bar.focus_entry ();
	}

	private bool found_games () {
		for (int i = 0; i < game_model.get_n_items (); i++) {
			var game = game_model.get_item (i) as Game;

			if (game.matches_search_terms (filtering_terms))
				return true;
		}

		return false;
	}

	[GtkCallback]
	private void on_folded_changed () {
		if (is_folded) {
			deck.visible_child = is_subview_open ? subview_header_bar : header_bar;
			swipe_group.add_swipeable (deck);
		} else {
			swipe_group.remove_swipeable (deck);
			deck.visible_child = header_bar;
		}

		update_bottom_bar ();
		update_selection_availability ();
	}

	[GtkCallback]
	private void update_bottom_bar () {
		view_switcher_bar.reveal = !is_selection_mode && is_showing_bottom_bar
		                           && (!is_folded || !is_subview_open);
	}

	[GtkCallback]
	private void update_adaptive_state () {
		bool showing_title = view_switcher_title.title_visible;
		is_showing_bottom_bar = showing_title && !is_collection_empty;
	}

	[GtkCallback]
	private void on_subview_back_clicked () {
		deck.navigate (Hdy.NavigationDirection.BACK);
	}
}
