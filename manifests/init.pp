File {
  owner => 'dev',
}

Vcsrepo {
  owner    => 'dev',
  provider => git,
}

Exec {
  path => [
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],
}

Package {
  ensure => latest
}

Concat { owner => 'dev' }

define github::checkout($path) {
  vcsrepo { "latest ${name}":
    ensure   => latest,
    revision => 'master',
    path     => $path,
    source   => "https://github.com/${name}.git",
  }
}

define env () {
  $github = split($title, '/')
  github::checkout { $title: path => "/home/dev/.${github[1]}" }
}

define env::plugin($host) {
  $github = split($title, '/')
  github::checkout { $title:
    require => Class[$host],
    path => "/home/dev/.${host}/plugins/${github[1]}",
  }
}

class nodenv {
  env { 'OiNutter/nodenv': }
}

class nodenv::node-build {
  nodenv::plugin { 'OiNutter/node-build': }
}

define nodenv::plugin () {
  env::plugin { $title: host => 'nodenv' }
}

class rbenv {
  env { 'sstephenson/rbenv': }
}

class rbenv::ruby-build {
  rbenv::plugin { 'sstephenson/ruby-build': }
}

define rbenv::plugin () {
  env::plugin { $title: host => 'rbenv' }
}

class rbenv::default_gems($gems) {
  rbenv::plugin { 'sstephenson/rbenv-default-gems': }
  file { 'rbenv default gems':
    require => Class['rbenv'],
    path    => '/home/dev/.rbenv/default-gems',
    content => join($gems, "\n"),
  }
}

class pyenv {
  env { 'yyuu/pyenv': }
}

node default {
  # ruby
  include rbenv
  include rbenv::ruby-build
  rbenv::plugin { [
    'ianheggie/rbenv-binstubs',
    'sstephenson/rbenv-gem-rehash',
    'tpope/rbenv-communal-gems',
    'tpope/rbenv-ctags',
    'tpope/rbenv-sentience',
  ]: }
  class { 'rbenv::default_gems':
    gems => [
      'gem-ctags',
      'bundler',
      'flay',
      'flog',
      'git-bump',
      'raygun',
      'rubocop',
    ]
  }

  # node
  include nodenv
  include nodenv::node-build
  nodenv::plugin { [
    'nicknovitski/nodenv-default-packages',
  ]: }
}
