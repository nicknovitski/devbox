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

class vim($plugins = []) {
  package { 'vim': }
  class { 'vim::pathogen': }
  vim::bundle { $plugins: }
  file { 'ftplugin':
    require => Class['vim::pathogen'],
    ensure => directory,
    path   => '/home/dev/.vim/ftplugin',
  }
  concat { '/home/dev/.vimrc': ensure => present }
}

define vim::bundle () {
  require vim::pathogen
  $github = split($title, '/')
  github::checkout { $title:
    path => "/home/dev/.vim/bundle/${github[1]}",
  }
}

define vim::ftplugin($source = '', $content = file($source)) {
  file { "ftplugin/${name}.vim":
    require => File['ftplugin'],
    path    => "/home/dev/.vim/ftplugin/${name}.vim",
    content => $content,
  }
}

define vim::rc($source = '', $content = file($source)) {
  concat::fragment { "add ${name} to vimrc":
    target  => '/home/dev/.vimrc',
    content => $content,
  }
}

define vim::colorscheme($repo, $vimrc = '') {
  vim::bundle { $repo: }
  vim::rc { 'hold':
    content => "\" Colors\n${vimrc}\ncolorscheme ${name}"
  }
}

class vim::pathogen {
  github::checkout { 'tpope/vim-pathogen': path => '/home/dev/.vim' }
}

define github::checkout($path) {
  vcsrepo { "latest ${name}":
    ensure   => latest,
    revision => 'master',
    path     => $path,
    source   => "https://github.com/${name}.git",
  }
}

class git::prompt {
  profile::section { '/tmp/files/enable-git-prompt.sh': }
}

class profile {
  concat { '/home/dev/.bash_profile': ensure => present }
}

define profile::line($line = $title) {
  concat::fragment { "~/.bash_profile: ${line}":
    target  => '/home/dev/.bash_profile',
    content => "${line}\n",
  }
}

define profile::section($source = $title) {
  concat::fragment { "add ${name} to ~/.bash_profile":
    target => '/home/dev/.bash_profile',
    source => $source,
  }
}

define env () {
  $github = split($title, '/')
  github::checkout { $title: path => "/home/dev/.${github[1]}" }
  profile::section { "/tmp/files/${github[1]}.sh": }
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

class ruby::bundler::binstubs {
  file { '~/.bundle':
    ensure => directory,
    path   => '/home/dev/.bundle',
  }
  file { '~/.bundle/config':
    ensure  => present,
    path    => '/home/dev/.bundle/config',
  }
  file_line { 'BUNDLE_BIN':
    require => File['~/.bundle/config'],
    path    => '/home/dev/.bundle/config',
    line    => 'BUNDLE_BIN: .bundle/bin',
  }
  file_line { 'BUNDLE_PATH':
    require => File['~/.bundle/config'],
    path    => '/home/dev/.bundle/config',
    line    => 'BUNDLE_PATH: .bundle/gem',
  }
}

node default {
  package { [
    'bash-completion',
    'docker',
    'gtypist',
    'parallel',
  ]: }
  exec { 'yes | pacman -Syu': timeout => 0 }

  include profile
  vim::rc { 'cool tmux cursors':
    source => '/tmp/files/tmux.vim',
  }

  include git::prompt

  class { 'vim':
    plugins => [
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
      'tpope/vim-repeat',
      'tpope/vim-rails',
      'tpope/vim-rake',
      'tpope/vim-sensible',
      'tpope/vim-surround',
      'tpope/vim-tbone',
      'tpope/vim-unimpaired',
      'tpope/vim-vinegar',
    ],
  }
  profile::line { 'export EDITOR=vim': }
  vim::rc { 'common settings':
    source => '/tmp/files/vimrc',
  }
  vim::colorscheme { 'solarized':
    repo  => 'altercation/vim-colors-solarized',
    vimrc => "set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1",
  }

  # ruby
  vim::ftplugin { 'ruby':
    source => '/tmp/files/ruby.vim',
  }
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
  profile::section { '/tmp/files/ruby.sh': }
  include ruby::bundler::binstubs

  package { 'ctags': }

  # node
  include nodenv
  include nodenv::node-build
  nodenv::plugin { [
    'nicknovitski/nodenv-default-packages',
  ]: }
}
