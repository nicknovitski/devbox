FROM nicknovitski/archlinux-devbox:latest

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
WORKDIR /var/shared

ENTRYPOINT ["/usr/bin/tmux", "-2u"]

CMD ["new-session"]
