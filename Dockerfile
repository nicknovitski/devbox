FROM base/archlinux

RUN useradd dev
RUN mkdir /home/dev && chown -R dev: /home/dev

# provision with puppet
RUN pacman -Sy --noconfirm puppet
RUN gem install librarian-puppet
ADD Puppetfile /tmp/Puppetfile
WORKDIR /tmp
RUN /.gem/ruby/2.1.0/bin/librarian-puppet install
ADD manifests /tmp/manifests
ADD files /tmp/files
RUN LANG=en_US.UTF-8 puppet apply --modulepath=/tmp/modules /tmp/manifests/init.pp
RUN rm -r /tmp/*

RUN mkdir /home/dev/src/
RUN touch /home/dev/src/placeholder
run chown -R dev:dev /home/dev/src
VOLUME ['/home/dev/src']

WORKDIR /home/dev
ENV HOME /home/dev
USER dev

CMD /usr/bin/tmux -2u
