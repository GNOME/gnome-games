vapi_dir = datadir / 'vala' / 'vapi'
gamepad_dir = srcdir / 'gamepad'

vala_args = [
  '--vapidir', vapi_dir,
]

c_args = [
  '-I' + gamepad_dir,
  '-DG_LOG_DOMAIN="Games"',
]

vala_sources = [
  'collection/collection.vala',
  'collection/collection-manager.vala',
  'collection/collection-model.vala',
  'collection/dummy-add-collection.vala',
  'collection/favorites-collection.vala',
  'collection/recently-played-collection.vala',
  'collection/user-collection.vala',

  'command/command-error.vala',
  'command/command-runner.vala',

  'core/core.vala',
  'core/cover.vala',
  'core/cover-loader.vala',
  'core/firmware.vala',
  'core/firmware-error.vala',
  'core/firmware-manager.vala',
  'core/game.vala',
  'core/game-callback.vala',
  'core/game-collection.vala',
  'core/game-model.vala',
  'core/game-uri-adapter.vala',
  'core/icon.vala',
  'core/input-capabilities.vala',
  'core/input-mode.vala',
  'core/media.vala',
  'core/media-set/media-set.vala',
  'core/media-set/media-set-error.vala',
  'core/migrator.vala',
  'core/platform.vala',
  'core/platform-model.vala',
  'core/platform-register.vala',
  'core/plugin.vala',
  'core/plugin-register.vala',
  'core/plugin-register-iterator.vala',
  'core/plugin-registrar.vala',
  'core/runner.vala',
  'core/runner-error.vala',
  'core/runner-factory.vala',
  'core/snapshot.vala',
  'core/snapshot-manager.vala',
  'core/title.vala',
  'core/uid.vala',
  'core/uri-game-factory.vala',
  'core/uri-iterator.vala',
  'core/uri-source.vala',

  'database/database.vala',
  'database/database-error.vala',
  'database/database-uri-iterator.vala',
  'database/database-uri-source.vala',

  'dummy/dummy-cover.vala',
  'dummy/dummy-icon.vala',
  'dummy/dummy-platform.vala',

  'gameinfo/gameinfo-doc.vala',
  'gameinfo/gameinfo-error.vala',
  'gameinfo/gameinfo-disc-id-disc-title.vala',
  'gameinfo/gameinfo-disc-id-game-title.vala',

  'gamepad/gamepad-dpad.vala',
  'gamepad/gamepad-input.vala',
  'gamepad/gamepad-mapper.vala',
  'gamepad/gamepad-mapping-builder.vala',
  'gamepad/gamepad-tester.vala',

  'generic/generic-game-uri-adapter.vala',
  'generic/generic-input-capabilities.vala',
  'generic/generic-platform.vala',
  'generic/generic-runner-factory.vala',
  'generic/generic-title.vala',
  'generic/generic-uri-game-factory.vala',

  'grilo/grilo-cover.vala',
  'grilo/grilo-media.vala',

  'keyboard/keyboard-mapper.vala',
  'keyboard/keyboard-mapping-builder.vala',
  'keyboard/keyboard-mapping-manager.vala',
  'keyboard/keyboard-tester.vala',

  'preferences/preferences-page.vala',
  'preferences/preferences-page-controllers.vala',
  'preferences/preferences-page-import-export.vala',
  'preferences/preferences-page-platforms.vala',
  'preferences/preferences-page-platforms-retro-row.vala',
  'preferences/preferences-page-video.vala',
  'preferences/preferences-subpage.vala',
  'preferences/preferences-subpage-gamepad.vala',
  'preferences/preferences-subpage-keyboard.vala',
  'preferences/preferences-window.vala',

  'retro/retro-core.vala',
  'retro/retro-core-manager.vala',
  'retro/retro-core-source.vala',
  'retro/retro-error.vala',
  'retro/retro-firmware.vala',
  'retro/retro-gamepad.vala',
  'retro/retro-input-manager.vala',
  'retro/retro-options.vala',
  'retro/retro-platform.vala',
  'retro/retro-runner.vala',
  'retro/retro-runner-factory.vala',
  'retro/retro-simple-game-uri-adapter.vala',
  'retro/retro-simple-type.vala',
  'retro/retro-simple-types.vala',

  'screen-layout/screen-layout.vala',
  'screen-layout/screen-layout-item.vala',
  'screen-layout/screen-layout-switcher.vala',

  'tracker/mime-type-tracker-uri-query.vala',
  'tracker/tracker-error.vala',
  'tracker/tracker-uri-iterator.vala',
  'tracker/tracker-uri-query.vala',
  'tracker/tracker-uri-source.vala',

  'ui/application.vala',
  'ui/application-window.vala',
  'ui/checkmark-item.vala',
  'ui/collection-action-window.vala',
  'ui/collection-icon-view.vala',
  'ui/collection-list-item.vala',
  'ui/collection-thumbnail.vala',
  'ui/collection-view.vala',
  'ui/collections-main-page.vala',
  'ui/collections-page.vala',
  'ui/display-bin.vala',
  'ui/display-view.vala',
  'ui/error-info-bar.vala',
  'ui/flash-box.vala',
  'ui/fullscreen-box.vala',
  'ui/gamepad-browse.vala',
  'ui/gamepad-view.vala',
  'ui/games-page.vala',
  'ui/game-icon-view.vala',
  'ui/game-thumbnail.vala',
  'ui/gamepad-view-configuration.vala',
  'ui/header-bar-widget.vala',
  'ui/input-mode-switcher.vala',
  'ui/konami-code.vala',
  'ui/media-menu-button.vala',
  'ui/platform-list-item.vala',
  'ui/platforms-page.vala',
  'ui/search-bar.vala',
  'ui/selection-action-bar.vala',
  'ui/snapshot-row.vala',
  'ui/snapshot-thumbnail.vala',
  'ui/snapshots-list.vala',
  'ui/titlebar-box.vala',
  'ui/ui-view.vala',
  'ui/undo-notification.vala',

  'utils/cairo-blur.vala',
  'utils/composite-cover.vala',
  'utils/composite-title.vala',
  'utils/cue-sheet/cue-sheet.vala',
  'utils/cue-sheet/cue-sheet-error.vala',
  'utils/cue-sheet/cue-sheet-file-format.vala',
  'utils/cue-sheet/cue-sheet-file-node.vala',
  'utils/cue-sheet/cue-sheet-track-mode.vala',
  'utils/cue-sheet/cue-sheet-track-node.vala',
  'utils/directory.vala',
  'utils/file-operations.vala',
  'utils/filename-title.vala',
  'utils/fingerprint.vala',
  'utils/grep.vala',
  'utils/local-cover.vala',
  'utils/string-input-stream.vala',
  'utils/unicode.vala',
  'utils/uri.vala',
  'utils/uri-error.vala',
  'utils/xml-doc.vala',

  'credits.vala',
  'main.vala',
]

resources = gnome.compile_resources(
  'org.gnome.Games',
  'org.gnome.Games.gresource.xml',
  c_name: 'resources'
)

event_codes_dep = valac.find_library ('event-codes', dirs: gamepad_dir)

dependencies = [
  config_dep,

  archive_dep,
  gio_dep,
  glib_dep,
  grilo_dep,
  gtk_dep,
  handy_dep,
  m_dep,
  manette_dep,
  retro_gtk_dep,
  rsvg_dep,
  soup_dep,
  sqlite_dep,
  tracker_sparql_dep,
  xml_dep,

  valac.find_library ('linux'),
  valac.find_library ('posix'),
  event_codes_dep,
]

gnome_games_exec = executable (
  'gnome-games',
  vala_sources + resources,
  dependencies: dependencies,
  vala_args: vala_args,
  c_args: c_args,
  include_directories: confinc,
  export_dynamic: true,
  install: true
)

search_provider_c_args = [
  '-DG_LOG_DOMAIN="GamesSearchProvider"',
]

search_provider_sources = [
  'search-provider.vala',
]

search_provider_deps = [
  config_dep,

  gio_dep,
  glib_dep,
  gtk_dep,
  sqlite_dep,
]

executable (
  'gnome-games-search-provider',
  search_provider_sources,
  dependencies: search_provider_deps,
  c_args: search_provider_c_args,
  include_directories: confinc,
  install: true,
  install_dir: libexecdir
)

plugin_dependencies = [
  archive_dep,
  gio_dep,
  glib_dep,
  gtk_dep,
  retro_gtk_dep,
  soup_dep,
  tracker_sparql_dep,

  event_codes_dep,
]

gnome_games_dep = declare_dependency (
  dependencies: plugin_dependencies,
  link_with: gnome_games_exec,
  include_directories: srcinc
)
