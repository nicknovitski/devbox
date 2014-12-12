FROM base/archlinux:2014.07.03

ENV LANG en_US.UTF-8

# update sources and already installed packages
# (https://wiki.archlinux.org/index.php/pacman#Partial_upgrades_are_unsupported)
RUN pacman -Syu --noconfirm

# build basics
RUN pacman -S --noconfirm base-devel curl man openssh sudo wget unzip yajl

# yaourt
WORKDIR /tmp
RUN curl https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz | tar zx
WORKDIR /tmp/package-query
RUN makepkg --asroot --noconfirm -i
WORKDIR /tmp
RUN curl https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz | tar zx
WORKDIR /tmp/yaourt
RUN makepkg --asroot --noconfirm -i

# development basics
RUN pacman -S --noconfirm git vim tmux

# my things
RUN pacman -S --noconfirm bash-completion ctags docker gtypist parallel
RUN yaourt -Sa --noconfirm rcm-git

ADD github-install /tmp/

# 'dev' user
RUN useradd --create-home dev
ENV HOME /home/dev

# workspace
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME ['/var/shared']

USER dev
ADD sudoers.d/* /etc/sudoers.d/

# vim plugins
RUN mkdir -p /home/dev/.vim/bundle
RUN /tmp/github-install .vim/bundle \
  altercation/vim-colors-solarized \
  bling/vim-airline \
  godlygeek/tabular \
  kien/ctrlp.vim \
  majutsushi/tagbar \
  mhinz/vim-signify \
  matze/vim-move \
  othree/html5.vim \
  rodjek/vim-puppet \
  scrooloose/syntastic \
  tpope/vim-abolish \
  tpope/vim-bundler \
  tpope/vim-commentary \
  tpope/vim-dispatch \
  tpope/vim-endwise \
  tpope/vim-eunuch \
  tpope/vim-fugitive \
  tpope/vim-pathogen \
  tpope/vim-rbenv \
  tpope/vim-repeat \
  tpope/vim-rails \
  tpope/vim-rake \
  tpope/vim-sensible \
  tpope/vim-surround \
  tpope/vim-tbone \
  tpope/vim-unimpaired \
  tpope/vim-vinegar

# rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /home/dev/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /home/dev/.rbenv/plugins/ruby-build
RUN /tmp/github-install .rbenv/plugins \
  ianheggie/rbenv-binstubs \
  nicknovitski/rbenv-gem-update \
  sstephenson/rbenv-default-gems \
  sstephenson/rbenv-gem-rehash \
  tpope/rbenv-communal-gems \
  tpope/rbenv-ctags \
  tpope/rbenv-sentience
ADD dotfiles/rbenv/default-gems /home/dev/.rbenv/
RUN /home/dev/.rbenv/bin/rbenv install 2.1.5
RUN /home/dev/.rbenv/bin/rbenv global 2.1.5

# nodenv
RUN git clone https://github.com/OiNutter/nodenv.git /home/dev/.nodenv
RUN git clone https://github.com/OiNutter/node-build.git /home/dev/.nodenv/plugins/node-build

# go
RUN sudo pacman -S --noconfirm go

ADD dotfiles /home/dev/.dotfiles
RUN rcup -v

ADD profile.d/*.sh /etc/profile.d/

RUN sudo chown -R dev:dev /home/dev

ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

WORKDIR /var/shared

CMD ["/usr/bin/tmux", "-2u", "new-session"]
