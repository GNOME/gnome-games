vala_sources = [
  'desktop-error.vala',
  'desktop-icon.vala',
  'desktop-plugin.vala',
  'desktop-title.vala',
  'desktop-tracker-uri-query.vala',
]

c_args = [
  '-DG_LOG_DOMAIN="GamesDesktop"'
]

desktop_resources = gnome.compile_resources (
  'desktop',
  'desktop.gresource.xml',
  c_name: 'resources'
)

gio_unix_dep = dependency ('gio-unix-2.0')

dependencies = [
  gnome_games_dep,
  gio_unix_dep,
]

shared_module (
  'games-' + plugin_name + '-plugin',
  vala_sources + desktop_resources,
  dependencies: dependencies,
  c_args: c_args,
  install: true,
  install_dir: plugins_dir
)
