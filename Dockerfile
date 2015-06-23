FROM binhex/arch-base:2015062200

ENV LANG en_US.UTF-8

# update sources and already installed packages
# (https://wiki.archlinux.org/index.php/pacman#Partial_upgrades_are_unsupported)
RUN pacman -Syu --noconfirm

# upgrade pacman database
RUN pacman-db-upgrade

RUN pacman -S --noconfirm base-devel man openssh wget unzip yajl \
  git vim tmux bash-completion ctags docker gtypist parallel ruby-mustache links weechat
RUN curl https://thoughtbot.github.io/rcm/dist/rcm-1.2.3.tar.gz | tar xz && \
  cd rcm-1.2.3 && \
  ./configure && make && make install

RUN curl -L https://github.com/github/hub/releases/download/v2.2.1/hub-linux-amd64-2.2.1.tar.gz | tar xz
RUN mv hub-linux-amd64-2.2.1/man/hub.1 /usr/local/man/man1/
RUN mv hub-linux-amd64-2.2.1/hub /usr/local/bin/
RUN mv hub-linux-amd64-2.2.1/etc/hub.bash_completion.sh /etc/profile.d/

RUN wget https://github.com/zimbatm/direnv/releases/download/v2.6.0/direnv.linux-amd64 -O /usr/local/bin/direnv
RUN chmod +x /usr/local/bin/direnv

ADD github-install /tmp/

RUN /tmp/github-install /usr/local/lib jimeh/tmuxifier
RUN ln -s /usr/local/lib/tmuxifier/bin/tmuxifier /usr/local/bin

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
RUN /tmp/github-install /home/dev/.rbenv/plugins \
  ianheggie/rbenv-binstubs \
  nicknovitski/rbenv-gem-update \
  sstephenson/rbenv-default-gems \
  sstephenson/rbenv-gem-rehash \
  tpope/rbenv-communal-gems \
  tpope/rbenv-ctags \
  tpope/rbenv-sentience

# node
RUN git clone https://github.com/wfarr/nodenv.git /home/dev/.nodenv

# go
RUN sudo pacman -S --noconfirm go

# rust
RUN sudo pacman -S --noconfirm rust

ADD dotfiles /home/dev/.dotfiles
RUN rcup -v
RUN vim +PlugInstall +qall
ADD profile.d/*.sh /etc/profile.d/

RUN sudo chown -R dev:dev /home/dev

ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

WORKDIR /var/shared

CMD ["/usr/bin/tmux", "-2u", "new-session"]
