project(
  'com.paysonwallach.tbedit',
  'vala', 'c',
  version: '0.1.0'
)

gnome = import('gnome')

vala = meson.get_compiler('vala')

vapi_dir = join_paths(meson.current_source_dir(), 'vapi')

as_resources = gnome.compile_resources(
  'as-resources',
  join_paths('dist', meson.project_name() + '.gresource.xml'),
  source_dir: 'dist'
)

conf = configuration_data()
conf.set_quoted('APPLICATION_ID', meson.project_name())

config_h = configure_file(
  output: 'config.h',
  configuration: conf
)

config_inc_dir = include_directories('.')

config_dep = declare_dependency(
  dependencies: vala.find_library('config', dirs: vapi_dir),
  sources: config_h
)

add_project_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  language:'c'
)

executable(
  meson.project_name(),
  'src/Application.vala',
  'src/Window.vala',
  as_resources,
  include_directories: config_inc_dir,
  dependencies: [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    dependency('webkit2gtk-4.0'),
    config_dep
  ],
  install: true
)
