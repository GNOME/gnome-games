// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GamepadView : Gtk.DrawingArea {
	private struct InputState {
		bool highlight;
	}

	private Rsvg.Handle handle;
	private new HashTable<string, InputState?> input_state;

	private GamepadViewConfiguration _configuration;
	public GamepadViewConfiguration configuration {
		get { return _configuration; }
		set {
			if (value == configuration)
				return;

			_configuration = value;

			if (value.svg_path == "")
				return;

			try {
				var bytes = resources_lookup_data (value.svg_path, ResourceLookupFlags.NONE);
				var data = bytes.get_data ();

				handle = new Rsvg.Handle.from_data (data);
			}
			catch (Error e) {
				critical ("Could not set up gamepad view: %s", e.message);
			}

			double width, height;
			get_dimensions (out width, out height);

			set_size_request ((int) width, (int) height);

			input_state.foreach_remove (() => true);

			foreach (var path in configuration.input_paths) {
				if (path.path in input_state)
					continue;

				input_state[path.path] = {};
			}

			reset ();
		}
	}

	construct {
		handle = new Rsvg.Handle ();
		configuration = { "", new GamepadInputPath[0] };
		input_state = new HashTable<string, InputState?> (str_hash, str_equal);
	}

	private void get_dimensions (out double width, out double height) {
		bool has_width, has_height, has_viewbox;
		Rsvg.Length handle_width, handle_height;
		Rsvg.Rectangle viewbox;

		handle.get_intrinsic_dimensions (out has_width, out handle_width,
		                                 out has_height, out handle_height,
		                                 out has_viewbox, out viewbox);

		assert (has_width && has_height);

		width = handle_width.length;
		height = handle_height.length;
	}

	public void reset () {
		input_state.foreach ((path, state) => {
			state.highlight = false;
		});

		queue_draw ();
	}

	public bool highlight (GamepadInput input, bool highlight) {
		foreach (var path in configuration.input_paths) {
			if (input != path.input)
				continue;

			input_state[path.path].highlight = highlight;

			queue_draw ();

			return true;
		}

		return false;
	}

	public override bool draw (Cairo.Context context) {
		double x, y, scale;
		calculate_image_dimensions (out x, out y, out scale);

		context.translate (x, y);
		context.scale (scale, scale);

		foreach (var path in configuration.background_paths) {
			Gdk.RGBA color;
			get_style_context ().lookup_color ("theme_fg_color", out color);

			draw_path (context, path, color);
		}

		input_state.for_each ((path, state) => {
			var color_name = state.highlight ? "theme_selected_bg_color" : "theme_fg_color";

			Gdk.RGBA color;
			get_style_context ().lookup_color (color_name, out color);

			draw_path (context, path, color);
		});

		return false;
	}

	private void draw_path (Cairo.Context context, string path, Gdk.RGBA color) {
		context.push_group ();

		handle.render_cairo_sub (context, @"#$path");
		var group = context.pop_group ();

		context.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		context.mask (group);
	}

	private void calculate_image_dimensions (out double x, out double y, out double scale) {
		double width = get_allocated_width ();
		double height = get_allocated_height ();

		double image_width, image_height;
		get_dimensions (out image_width, out image_height);

		scale = double.min (height / image_height, width / image_width);

		x = (width - image_width * scale) / 2;
		y = (height - image_height * scale) / 2;
	}
}
