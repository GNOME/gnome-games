// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.RetroInputManager : Object {
	private Retro.Core core;
	private Retro.Controller core_view_joypad;
	private GamepadMonitor gamepad_monitor;
	private Retro.Controller?[] controllers;
	private int core_view_joypad_port;
	private bool present_analog_sticks;

	public RetroInputManager (Retro.Core core, Retro.CoreView view, bool present_analog_sticks) {
		this.core = core;
		this.present_analog_sticks = present_analog_sticks;

		core_view_joypad = view.as_controller (Retro.ControllerType.JOYPAD);
		core.set_keyboard (view);

		var default_joypad = view.as_controller (Retro.ControllerType.JOYPAD);
		var default_mouse = view.as_controller (Retro.ControllerType.MOUSE);
		var default_pointer = view.as_controller (Retro.ControllerType.POINTER);
		core.set_default_controller (port, default_joypad);
		core.set_default_controller (port, default_mouse);
		core.set_default_controller (port, default_pointer);

		gamepad_monitor = GamepadMonitor.get_instance ();
		gamepad_monitor.foreach_gamepad ((gamepad) => {
			var port = controllers.length;
			var retro_gamepad = new RetroGamepad (gamepad, present_analog_sticks);
			controllers += retro_gamepad;
			core.set_controller (port, retro_gamepad);
			gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		});

		core_view_joypad_port = controllers.length;
		controllers += core_view_joypad;
		core.set_controller (core_view_joypad_port, core_view_joypad);
		gamepad_monitor.gamepad_plugged.connect (handle_gamepad_plugged);
	}

	private void handle_gamepad_plugged (Gamepad gamepad) {
		// Plug this gamepad to the port where the CoreView's joypad was
		// plugged as a last resort.
		var port = core_view_joypad_port;
		var retro_gamepad = new RetroGamepad (gamepad, present_analog_sticks);
		controllers[port] = retro_gamepad;
		core.set_controller (port, retro_gamepad);
		gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));

		// Assign the CoreView's joypad to another unplugged port if it
		// exists and return.
		for (var i = core_view_joypad_port; i < controllers.length; i++) {
			if (controllers[i] == null) {
				// Found an unplugged port and so assigning core_view_joypad to it
				core_view_joypad_port = i;
				controllers[core_view_joypad_port] = core_view_joypad;
				core.set_controller (core_view_joypad_port, core_view_joypad);

				return;
			}
		}

		// Now it means that there is no unplugged port so append the
		// CoreView's joypad to ports.
		core_view_joypad_port = controllers.length;
		controllers += core_view_joypad;
		core.set_controller (core_view_joypad_port, core_view_joypad);
	}

	private void handle_gamepad_unplugged (int port) {
		if (core_view_joypad_port > port) {
			// Remove the controller and shift the CoreView's joypad to
			// "lesser" port.
			controllers[core_view_joypad_port] = null;
			core.remove_controller (core_view_joypad_port);
			core_view_joypad_port = port;
			controllers[core_view_joypad_port] = core_view_joypad;
			core.set_controller (core_view_joypad_port, core_view_joypad);
		}
		else {
			// Just remove the controller as no need to shift the
			// CoreView's joypad.
			controllers[port] = null;
			core.remove_controller (port);
		}
	}
}
