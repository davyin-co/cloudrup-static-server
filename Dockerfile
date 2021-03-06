FROM ubuntu:20.04
ENV TERM="xterm" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    S6_OVERLAY_VERSION="2.2.0.3" \
    GOSU_VERSION=1.12 \
    AEGIR_UID=1000 \
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[00m\]@\h: \[\033[01;36m\]\w\[\033[00m\] \[\t\]\n\$ '

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && \
    /tmp/s6-overlay-amd64-installer / && \
    rm /tmp/s6-overlay-amd64-installer && \
    apt-get update -qq && \
    apt-get install -y software-properties-common tzdata apache2 sudo rsync git-core unzip wget vim openssh-server logrotate && \
    add-apt-repository -y ppa:ondrej/apache2 && \
    addgroup --gid ${AEGIR_UID} aegir && \
    adduser --uid ${AEGIR_UID} --gid ${AEGIR_UID} --system --home /var/aegir aegir && \
    adduser aegir www-data && \
    usermod aegir -s /bin/bash && \
    a2enmod rewrite && \
    a2enmod speling && \
    a2enmod ssl && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod remoteip && \
    a2enmod headers  && \
    ## install gotpl
    gotpl_url="https://github.com/wodby/gotpl/releases/download/0.1.5/gotpl-linux-amd64-0.1.5.tar.gz" && \
    wget -qO- "${gotpl_url}" | tar xz -C /usr/local/bin && \
    ## isntall gosu
    arch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch" && \
    chmod +x gosu && \
    mv gosu /usr/local/bin && \
    mkdir -p /var/aegir/config/static
COPY rootfs /
#USER aegir
WORKDIR /var/aegir
VOLUME /var/aegir

ENTRYPOINT ["/init"]
