FROM base/archlinux:2014.07.03

RUN pacman -S --noconfirm git
RUN pacman -S --noconfirm vim
RUN pacman -S --noconfirm tmux
RUN pacman -S --noconfirm base-devel curl man openssh sudo wget unzip

RUN pacman -S --noconfirm bash-completion
RUN pacman -S --noconfirm ctags
RUN pacman -S --noconfirm docker
RUN pacman -S --noconfirm gtypist
RUN pacman -S --noconfirm parallel

ADD tmux.conf /home/dev/.tmux.conf
ADD gitignore /home/dev/.gitignore
ADD gitconfig /home/dev/.gitconfig
ADD git_template /home/dev/.git_template
ADD vimrc /home/dev/.vimrc
ADD vim /home/dev/.vim
ADD bash_profile /home/dev/.bash_profile
ADD bundle /home/dev/.bundle

RUN pacman -Sy --noconfirm puppet
RUN su - dev -c "gem install librarian-puppet"
ADD Puppetfile /tmp/Puppetfile
WORKDIR /tmp
RUN /home/dev/.gem/ruby/2.1.0/bin/librarian-puppet install
ADD manifests /tmp/manifests
ADD files /tmp/files
RUN LANG=en_US.UTF-8 puppet apply --modulepath=/tmp/modules /tmp/manifests/init.pp
RUN rm -r /tmp/*

WORKDIR /var/shared

ENTRYPOINT ["/usr/bin/tmux", "-2u"]

CMD ["new-session"]
