FROM base/archlinux:2014.07.03

RUN pacman -Syu --noconfirm

RUN pacman -S --noconfirm git
RUN pacman -S --noconfirm vim
RUN pacman -S --noconfirm tmux
RUN pacman -S --noconfirm base-devel curl man openssh sudo wget unzip

RUN pacman -S --noconfirm bash-completion
RUN pacman -S --noconfirm ctags
RUN pacman -S --noconfirm docker
RUN pacman -S --noconfirm gtypist
RUN pacman -S --noconfirm parallel

RUN useradd --create-home dev
ADD dev-sudoer /etc/sudoers.d/dev-sudoer
ENV HOME /home/dev

RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME ['/var/shared']

RUN mkdir /home/dev/.ssh
RUN touch /home/dev/.ssh/known_hosts
ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

ENV LANG en_US.UTF-8

USER dev

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
