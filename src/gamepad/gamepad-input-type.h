// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_INPUT_TYPE_H
#define GAMES_GAMEPAD_INPUT_TYPE_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_GAMEPAD_INPUT_TYPE (games_gamepad_input_type_get_type ())

/**
 * GamesGamepadInputType:
 * @GAMES_GAMEPAD_INPUT_TYPE_INVALID: an invalid input type
 * @GAMES_GAMEPAD_INPUT_TYPE_AXIS: an axis
 * @GAMES_GAMEPAD_INPUT_TYPE_BUTTON: a button
 *
 * The input types of a standard gamepad.
 **/
typedef enum {
  GAMES_GAMEPAD_INPUT_TYPE_INVALID,
  GAMES_GAMEPAD_INPUT_TYPE_AXIS,
  GAMES_GAMEPAD_INPUT_TYPE_BUTTON,
} GamesGamepadInputType;

GType games_gamepad_input_type_get_type (void) G_GNUC_CONST;

G_END_DECLS

#endif /* GAMES_GAMEPAD_INPUT_TYPE_H */