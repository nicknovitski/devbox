class vim {
  package { 'vim': }
  file { 'ftplugin':
    ensure => directory,
    path   => '/home/vagrant/.vim/ftplugin',
    owner  => 'vagrant',
  }
  concat { '/home/vagrant/.vimrc':
    ensure => present,
    owner  => 'vagrant',
  }
  git::ignore { 'vim':
    ignore => [
      '[a-w][a-z]',
      '[._]s[a-w][a-z]',
      '*.un~',
      'Session.vim',
      '.netrwhist',
      '*~',
    ],
  }
}

define vim::bundle () {
  $github = split($title, '/')
  github::checkout { $title:
    path => "/home/vagrant/.vim/bundle/${github[1]}",
  }
}

define vim::ftplugin($source = '', $content = file($source)) {
  file { "ftplugin/${name}.vim":
    require => File['ftplugin'],
    path    => "/home/vagrant/.vim/ftplugin/${name}.vim",
    owner   => 'vagrant',
    content => $content,
  }
}

define vim::rc($source = '', $content = file($source)) {
  concat::fragment { "add ${name} to vimrc":
    target  => '/home/vagrant/.vimrc',
    content => $content,
  }
}

define vim::colorscheme($repo, $vimrc = '') {
  vim::bundle { $repo: }
  vim::rc { 'hold':
    content => "\" Colors\n${vimrc}\ncolorscheme ${name}"
  }
}

class pathogen {
  github::checkout { 'tpope/vim-pathogen': path => '/home/vagrant/.vim' }
}

define github::checkout($path) {
  vcsrepo { "latest ${name}":
    ensure   => latest,
    revision => 'master',
    provider => git,
    owner    => 'vagrant',
    path     => $path,
    source   => "https://github.com/${name}.git",
  }
}

class git {
  package { 'git': }
  git::alias {
    'ci': command      => 'commit';
    'co': command      => 'checkout';
    'br': command      => 'branch';
    'rb': command      => 'rebase';
    'rbc': command     => 'rebase --continue';
    'rba': command     => 'rebase --abort';
    'st': command      => 'status';
    'dc': command      => 'diff --cached';
    'extract': command => 'filter-branch --prune-empty --subdirectory-filter';
    'praise': command  => 'blame';
  }
  git::config::color { [
    'branch',
    'diff',
    'status',
    'ui',
    'grep',
  ]: }
  git::config { 'git push simple':
    section => 'push',
    setting => 'default',
    value   => 'simple',
  }
  git::config { 'git diff3':
    section => 'merge',
    setting => 'conflictstyle',
    value   => 'diff3',
  }
  git::config { 'git perl grep':
    section => 'grep',
    setting => 'patternType',
    value   => 'perl',
  }
  git::config { 'global ignores':
    section => 'core',
    setting => 'excludesfile',
    value   => '~/.gitignore',
  }
  concat { '/home/vagrant/.gitignore':
    ensure => present,
    owner  => 'vagrant',
  }
  git::config { 'no .orig files':
    section => 'mergetool',
    setting => 'keepBackup',
    value   => 'false',
  }
  git::config { 'just open difftool when I say so':
    section => 'difftool',
    setting => 'prompt',
    value   => 'false',
  }
  git::config { 'just apply patches when I say so':
    section => 'apply',
    setting => 'whitespace',
    value   => 'nowarn',
  }
  git::config { 'only allow fast-forward merges on pulls':
    section => 'pull',
    setting => 'ff',
    value   => 'only',
  }
  git::config { 'autocorrect obvious misspelt commands':
    section => 'help',
    setting => 'autocorrect',
    value   => '1',
  }
}

define git::ignore($ignore) {
  concat::fragment { "~/gitignore :: ${title}":
    target  => '/home/vagrant/.gitignore',
    content => join($ignore, "\n"),
  }
}

define git::config($section, $setting, $value) {
  ini_setting { "global git config set ${section}.${setting} to ${value}":
    ensure  => present,
    path    => '/home/vagrant/.gitconfig',
    section => $section,
    setting => $setting,
    value   => $value,
  }
}

define git::config::color($value = 'auto') {
  git::config { "color git ${name} output":
    section => 'color',
    setting => $title,
    value   => $value,
  }
}

define git::alias($command) {
  git::config { "add git alias ${name}":
    section => 'alias',
    setting => $title,
    value   => $command,
  }
}

define git::user($email) {
  git::config { "git name ${name}":
    section => 'user',
    setting => 'name',
    value   => $title,
  }
  git::config { "git email ${email}":
    section => 'user',
    setting => 'email',
    value   => $email,
  }
}

class profile {
  concat { '/home/vagrant/.profile':
    ensure => present,
    owner  => 'vagrant',
  }
}

define profile::line($line = $title) {
  concat::fragment { "~/.profile: ${line}":
    target  => '/home/vagrant/.profile',
    content => "${line}\n",
  }
}

define profile::section($source = $title) {
  concat::fragment { "add ${name} to ~/.tmux.conf":
    target => '/home/vagrant/.profile',
    source => $source,
  }
}

define env () {
  $github = split($title, '/')
  github::checkout { $title: path => "/home/vagrant/.${github[1]}" }
  profile::section { "/vagrant/files/${github[1]}.sh": }
}

define env::plugin($host) {
  $github = split($title, '/')
  github::checkout { $title:
    require => Class[$host],
    path => "/home/vagrant/.${host}/plugins/${github[1]}",
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
    path    => '/home/vagrant/.rbenv/default-gems',
    owner   => 'vagrant',
    content => join($gems, "\n"),
  }
}

class pyenv {
  env { 'yyuu/pyenv': }
}

class docker {
  package { 'docker': }
  service { 'docker':
    ensure  => running,
    require => Package['docker'],
    enable  => true,
  }
}

class tmux {
  package { 'tmux': }
  concat { '/home/vagrant/.tmux.conf':
    ensure => present,
    owner  => 'vagrant',
  }
  file { '~/.ssh/rc':
    ensure => present,
    owner  => 'vagrant',
    path    => '/home/vagrant/.ssh/rc',
    source => '/vagrant/files/ssh_rc',
  }
}

define tmux::conf($source = $title) {
  concat::fragment { "add ${source} to ~/.tmux.conf":
    target => '/home/vagrant/.tmux.conf',
    source => $source,
  }
}

class tmux::default-shell {
  profile::section { '/vagrant/files/tmux.sh': }
}

node default {
  include profile
  include tmux
  include tmux::default-shell
  tmux::conf { '/vagrant/files/tmux.conf': }
  vim::rc { 'cool tmux cursors':
    source => '/vagrant/files/tmux.vim',
  }

  include docker

  include git
  git::user { 'Nick Novitski': email => 'nicknovitski@gmail.com' }

  include vim
  profile::line { 'export EDITOR=vim': }
  vim::rc { 'common settings':
    source => '/vagrant/files/vimrc',
  }
  vim::colorscheme { 'solarized':
    repo  => 'altercation/vim-colors-solarized',
    vimrc => "set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1",
  }
  include pathogen
  vim::bundle { [
    'airblade/vim-gitgutter',
    'bling/vim-airline',
    'godlygeek/tabular',
    'kien/ctrlp.vim',
    'majutsushi/tagbar',
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
  ]: }

  # ruby
  vim::ftplugin { 'ruby':
    source => '/vagrant/files/ruby.vim',
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
  file { '~/.bundle':
    ensure => directory,
    path   => '/home/vagrant/.bundle',
    owner  => 'vagrant',
  }
  file { '~/.bundle/config':
    ensure  => present,
    require => File['~/.bundle'],
    path    => '/home/vagrant/.bundle/config',
    owner   => 'vagrant',
  }
  file_line { 'bundle binstubs':
    require => File['~/.bundle/config'],
    path    => '/home/vagrant/.bundle/config',
    line    => 'BUNDLE_BIN: .bundle/bin',
  }

  package { 'ctags': }

  # node
  include nodenv
  include nodenv::node-build
  nodenv::plugin { [
    'nicknovitski/nodenv-default-packages',
  ]: }
}
