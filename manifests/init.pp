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
  git::ignore { 'vim':
    ignore => [
      '[._]*.s[a-w][a-z]',
      '[._]s[a-w][a-z]',
      '*.un~',
      'Session.vim',
      '.netrwhist',
      '*~',
    ],
  }
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

class git {
  package { 'git': }
  include git::template
  git::alias {
    'ci': command      => 'commit';
    'co': command      => 'checkout';
    'br': command      => 'branch';
    'rb': command      => 'rebase';
    'rbc': command     => 'rebase --continue';
    'rba': command     => 'rebase --abort';
    'st': command      => 'status';
    'dc': command      => 'diff --cached';
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
  concat { '/home/dev/.gitignore': ensure => present }
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
}

define git::ignore($ignore) {
  $lines = join($ignore, "\n")
  concat::fragment { "~/gitignore :: ${title}":
    target  => '/home/dev/.gitignore',
    content => "# ${title}\n${lines}\n"
  }
}

define git::config($section, $setting, $value) {
  ini_setting { "global git config set ${section}.${setting} to ${value}":
    ensure  => present,
    path    => '/home/dev/.gitconfig',
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

class git::prompt {
  profile::section { '/tmp/files/enable-git-prompt.sh': }
}

class git::template {
  git::config { 'set template dir':
    section => 'init',
    setting => 'templatedir',
    value   => '~/.git_template',
  }
  file { '~/.git_template':
    ensure => directory,
    path   => '/home/dev/.git_template',
  }
  file { '~/.git_template/hooks':
    ensure  => directory,
    require => File['~/.git_template'],
    path    => '/home/dev/.git_template/hooks',
  }
}

define git::hook($source = '', $content = file($source)) {
  file { "~/.git_template/hooks/${title}":
    ensure  => present,
    require => File['~/.git_template/hooks'],
    path    => "/home/dev/.git_template/hooks/${title}",
    mode    => 772,
    content  => $content,
  }
}

class git::ctags {
  #http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
  $exec_ctags = "#!/bin/sh\n.git/hooks/ctags >/dev/null 2>&1 &"
  git::hook {
    'ctags': source => '/tmp/files/git_ctags';
    'post-commit': content => $exec_ctags;
    'post-merge': content => $exec_ctags;
    'post-checkout': content => $exec_ctags;
    'post-rewrite': source => '/tmp/files/git_post-rewrite';
  }
  git::alias { 'ctags': command => '!.git/hooks/ctags' }
  git::ignore { 'ctags': ignore => ['tags'] }
}

class profile {
  concat { '/home/dev/.profile': ensure => present }
}

define profile::line($line = $title) {
  concat::fragment { "~/.profile: ${line}":
    target  => '/home/dev/.profile',
    content => "${line}\n",
  }
}

define profile::section($source = $title) {
  concat::fragment { "add ${name} to ~/.tmux.conf":
    target => '/home/dev/.profile',
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

class tmux {
  package { 'tmux': }
  concat { '/home/dev/.tmux.conf': ensure => present }
}

class tmux::mouse {
  tmux::conf { '/tmp/files/tmux_mouse.conf': }
}

class tmux::solarized {
  tmux::conf { '/tmp/files/tmux_solarized.conf': }
}

class tmux::vim {
  tmux::conf { '/tmp/files/tmux_vim.conf': }
}

define tmux::conf($source = $title) {
  concat::fragment { "add ${source} to ~/.tmux.conf":
    target => '/home/dev/.tmux.conf',
    source => $source,
  }
}

class tmux::default-shell {
  profile::section { '/tmp/files/tmux.sh': }
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
  include tmux
  include tmux::mouse
  include tmux::default-shell
  tmux::conf { '/tmp/files/tmux.conf': }
  include tmux::solarized
  include tmux::vim
  vim::rc { 'cool tmux cursors':
    source => '/tmp/files/tmux.vim',
  }

  include git
  include git::prompt
  git::user { 'Nick Novitski': email => 'nicknovitski@gmail.com' }
  git::alias {
    'praise': command  => 'blame';
    'extract':
      command => 'filter-branch --prune-empty --subdirectory-filter';
    'grep-sed': # search-and-replace
      command=> '!sh -c \'git grep -l \"$1\" | xargs sed -i \"s/$1/$2/g\"\' -';
  }

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
  include ruby::bundler::binstubs

  package { 'ctags': }
  include git::ctags

  # node
  include nodenv
  include nodenv::node-build
  nodenv::plugin { [
    'nicknovitski/nodenv-default-packages',
  ]: }
}
