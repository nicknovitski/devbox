FROM binhex/arch-base:2015080700

RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen; locale-gen; echo LANG="en_US.UTF-8" > /etc/locale.conf
ENV LANG en_US.UTF-8

# update sources and already installed packages
# (https://wiki.archlinux.org/index.php/pacman#Partial_upgrades_are_unsupported)
RUN pacman -Syu --noconfirm

# upgrade pacman database
RUN pacman-db-upgrade

RUN pacman -S --noconfirm base-devel man openssh wget unzip yajl \
  git tmux bash-completion ctags docker gtypist parallel ruby-mustache links \
  weechat sdcv emacs python2-pip xml2 rlwrap hub

RUN pip2 install awscli neovim

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

USER dev
ADD sudoers.d/* /etc/sudoers.d/

RUN git clone https://aur.archlinux.org/package-query.git /tmp/package-query && \
  cd /tmp/package-query && makepkg --syncdeps --rmdeps && \
  sudo pacman -U --noconfirm package-query*.pkg.tar.xz
RUN git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt && \
  cd /tmp/yaourt && makepkg --syncdeps --rmdeps && \
  sudo pacman -U --noconfirm yaourt*.pkg.tar.xz

RUN yaourt -Sy --noconfirm neovim-git rcm direnv

RUN git clone --recursive https://github.com/syl20bnr/spacemacs ~/.emacs.d

RUN gem install thyme

ADD dotfiles /home/dev/.dotfiles
RUN rcup -v -t docker
RUN sudo wget -q https://raw.githubusercontent.com/travis-ci/travis.rb/master/assets/travis.sh -O /etc/profile.d/travis-autocompletion.sh
ADD profile.d/*.sh /etc/profile.d/

RUN sudo chown -R dev:dev /home/dev

ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

WORKDIR /var/shared

VOLUME ["/home/dev", "/var/shared"]

CMD ["/usr/bin/tmux", "-2uCC", "new-session"]
