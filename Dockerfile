FROM base/archlinux:2014.07.03

ENV LANG en_US.UTF-8

# update sources and already installed packages
# (https://wiki.archlinux.org/index.php/pacman#Partial_upgrades_are_unsupported)
RUN pacman -Syu --noconfirm

# upgrade pacman database
RUN pacman-db-upgrade

# build basics
RUN pacman -S --noconfirm base-devel curl man openssh sudo wget unzip yajl

# development basics
RUN pacman -S --noconfirm git vim tmux

# my things
RUN pacman -S --noconfirm bash-completion ctags docker gtypist parallel ruby-mustache
RUN curl https://thoughtbot.github.io/rcm/dist/rcm-1.2.3.tar.gz | tar xz && \
  cd rcm-1.2.3 && \
  ./configure && make && make install

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

# clojure
RUN sudo pacman -S --noconfirm jdk8-openjdk
RUN sudo wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
  --output-document /usr/bin/lein
RUN sudo chmod a+x /usr/bin/lein

# ruby
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

# node
RUN git clone https://github.com/OiNutter/nodenv.git /home/dev/.nodenv
RUN git clone https://github.com/OiNutter/node-build.git /home/dev/.nodenv/plugins/node-build

# go
RUN sudo pacman -S --noconfirm go

# rust
RUN sudo pacman -S --noconfirm rust

ADD dotfiles /home/dev/.dotfiles
RUN rcup -v

RUN mkdir -p /home/dev/.vim/bundle
RUN /tmp/github-install .vim/bundle Shougo/neobundle.vim
RUN /home/dev/.vim/bundle/neobundle.vim/bin/neoinstall vimproc.vim

ADD profile.d/*.sh /etc/profile.d/

RUN sudo chown -R dev:dev /home/dev

ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

WORKDIR /var/shared

CMD ["/usr/bin/tmux", "-2u", "new-session"]
