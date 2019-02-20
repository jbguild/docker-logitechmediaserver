FROM debian:stable-slim

ARG DEBIAN_FRONTEND="noninteractive"
RUN echo "Install packages required by Logitech Media Server" \
  && apt-get update -qq \
  && apt-get install -qy \
    apt-utils \
    locales \
    tzdata \
    wget \
    lame \
    faad \
    flac \
    sox \
    libio-socket-ssl-perl \
    libnet-ssleay-perl \
  && apt-get clean -yq \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LC_ALL="C.UTF-8" LANG="en-US.UTF-8" LANGUAGE="en_US.UTF-8"
RUN echo "Set up locales" && locale-gen $LANG

ARG LMS_VER="7.9.2"
RUN echo "Install Logitech Media Server" \
  && wget -O /tmp/lms.deb $(wget -qO- "http://www.mysqueezebox.com/update/?version=$LMS_VER&revision=1&geturl=1&os=deb$ARCH") \
  && dpkg -i /tmp/lms.deb \
  && apt-get install -fq \
  && apt-get remove -qy wget \
  && apt-get autoremove -qy \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PUID="1000" PGID="1000"
RUN echo "Setup directories and start it up" \
  && addgroup --gid ${PGID} squeezeboxserver \
  && usermod -u ${PUID} -g squeezeboxserver squeezeboxserver \
  && mkdir -p /mnt/Music /mnt/Playlists \
  && chown -R squeezeboxserver:squeezeboxserver /etc/squeezeboxserver /var/lib/squeezeboxserver /var/log/squeezeboxserver /mnt/Playlists \
  && cp -pr /etc/squeezeboxserver /etc/squeezeboxserver.orig

VOLUME /mnt/Music /mnt/Playlists

EXPOSE 3483 3483/udp 9000 9090

COPY init /
ENTRYPOINT ["/init"]
CMD ["/usr/sbin/squeezeboxserver", "--user", "squeezeboxserver", "--prefsdir", "/var/lib/squeezeboxserver", "--logdir", "/var/log/squeezeboxserver", "--cachedir", "/var/lib/squeezeboxserver"]

