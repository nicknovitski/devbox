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

define vim::bundle () {
  $github = split($title, '/')
  github::checkout { $title:
    path => "/home/dev/.vim/bundle/${github[1]}",
  }
}

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
  vim::bundle { [
      'bling/vim-airline',
      'godlygeek/tabular',
      'kien/ctrlp.vim',
      'majutsushi/tagbar',
      'mhinz/vim-signify',
      'matze/vim-move',
      'othree/html5.vim',
      'rodjek/vim-puppet',
      'scrooloose/syntastic',
      'tpope/vim-abolish',
      'tpope/vim-bundler',
      'tpope/vim-commentary',
      'tpope/vim-dispatch',
      'tpope/vim-endwise',
      'tpope/vim-eunuch',
      'tpope/vim-fugitive',
      'tpope/vim-pathogen',
      'tpope/vim-repeat',
      'tpope/vim-rails',
      'tpope/vim-rake',
      'tpope/vim-sensible',
      'tpope/vim-surround',
      'tpope/vim-tbone',
      'tpope/vim-unimpaired',
      'tpope/vim-vinegar',
  ]: }

  # ruby
  include rbenv
  vim::bundle { 'tpope/vim-rbenv': }
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
