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

# 'dev' user
RUN useradd --create-home dev
ADD dev-sudoer /etc/sudoers.d/dev-sudoer
ENV HOME /home/dev

# workspace
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME ['/var/shared']

USER dev

# ssh agent "forwarding"
RUN mkdir /home/dev/.ssh
RUN touch /home/dev/.ssh/known_hosts
ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

ADD tmux.conf /home/dev/.tmux.conf
ADD gitignore /home/dev/.gitignore
ADD gitconfig /home/dev/.gitconfig
ADD git_template /home/dev/.git_template
ADD vimrc /home/dev/.vimrc
ADD vim /home/dev/.vim
ADD bash_profile /home/dev/.bash_profile
ADD bundle /home/dev/.bundle

RUN sudo chown -R dev:dev /home/dev

RUN sudo pacman -S --noconfirm puppet
RUN sudo gem install librarian-puppet --no-user-install
ADD Puppetfile /tmp/Puppetfile
WORKDIR /tmp
RUN librarian-puppet install
ADD manifests /tmp/manifests
ADD files /tmp/files
RUN puppet apply --modulepath=/tmp/modules /tmp/manifests/init.pp

RUN sudo rm -r /tmp/*

WORKDIR /var/shared

ENTRYPOINT ["/usr/bin/tmux", "-2u"]

CMD ["new-session"]
