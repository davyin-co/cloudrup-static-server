FROM ubuntu:18.04
ENV TERM="xterm" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    S6_OVERLAY_VERSION="2.1.0.2" \
    AEGIR_UID=1000
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64-installer /tmp/
COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod +x /tmp/s6-overlay-amd64-installer && \
    /tmp/s6-overlay-amd64-installer / && \
    rm /tmp/s6-overlay-amd64-installer && \
    apt-get update -qq && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update -qq && apt-get install -y -qq apache2 sudo rsync git-core unzip wget vim openssh-server && \
    addgroup --gid ${AEGIR_UID} aegir && \
    adduser --uid ${AEGIR_UID} --gid ${AEGIR_UID} --system --home /var/aegir aegir && \
    adduser aegir www-data && \
    usermod aegir -s /bin/bash && \
    a2enmod rewrite && \
    a2enmod speling && \
    a2enmod ssl && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod headers && \
    chown root:root /etc/sudoers.d/aegir && \
    chmod 0440 /etc/sudoers.d/aegir 
COPY rootfs /
#USER aegir
WORKDIR /var/aegir
VOLUME /var/aegir

ENTRYPOINT ["/init"]
