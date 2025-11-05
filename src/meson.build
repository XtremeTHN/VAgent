kagent_sources = ['main.vala', 'window.vala', 'agent.vala', 'background.vala']

kagent_deps = [
  dependency('gtk4'),
  dependency('glib-2.0'),
  dependency('polkit-agent-1'),
  dependency('gtk4-layer-shell-0'),
  dependency('polkit-gobject-1'),
  dependency('libadwaita-1', version: '>= 1.4'),
  meson.get_compiler('vala').find_library('posix'),
]

blueprints = custom_target(
  'blueprints',
  input: files(
    # LIST YOUR BLUEPRINT FILES HERE
    'window.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

kagent_sources += gnome.compile_resources(
  'kagent-resources',
  'kagent.gresource.xml',
  dependencies: blueprints,
  c_name: 'kagent',
)

add_project_arguments(['-g', '--save-temps'], language: 'vala')

executable(
  'vagent',
  kagent_sources,
  dependencies: kagent_deps,
  install: true,
  c_args: [
    '-DPOLKIT_AGENT_I_KNOW_API_IS_SUBJECT_TO_CHANGE',
  ],
)