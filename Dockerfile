FROM base/archlinux

RUN useradd dev
RUN mkdir /home/dev

RUN mkdir /home/dev/src/
RUN touch /home/dev/src/placeholder
VOLUME ['/home/dev/src']

RUN mkdir /home/dev/.ssh
RUN touch /home/dev/.ssh/known_hosts
ENV SSH_AUTH_SOCK /home/dev/.ssh/ssh_auth_sock

ENV HOME /home/dev
RUN chown -R dev:dev /home/dev

RUN groupadd docker
RUN gpasswd -a dev docker

# provision with puppet
RUN pacman -Sy --noconfirm puppet
RUN gem install librarian-puppet
ADD Puppetfile /tmp/Puppetfile
WORKDIR /tmp
RUN /home/dev/.gem/ruby/2.1.0/bin/librarian-puppet install
ADD manifests /tmp/manifests
ADD files /tmp/files
RUN LANG=en_US.UTF-8 puppet apply --modulepath=/tmp/modules /tmp/manifests/init.pp
RUN rm -r /tmp/*

USER dev
WORKDIR /home/dev

CMD /usr/bin/tmux -2u
