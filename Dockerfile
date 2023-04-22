FROM pihole/pihole

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

RUN apt-get update \
    && apt-get -y install wget \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && apt-get -y purge wget \
    && apt-get install ./cloudflared-linux-amd64.deb \
    && mkdir -p /etc/cloudflared/ \
    && mkdir -p /etc/s6-overlay/s6-rc.d/cloudflared/dependencies.d \
    && touch /etc/s6-overlay/s6-rc.d/cloudflared/type \
    && touch /etc/s6-overlay/s6-rc.d/cloudflared/run \
    && touch /etc/s6-overlay/s6-rc.d/cloudflared/dependencies.d/base \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/cloudflared \
    && echo 'longrun' >> /etc/s6-overlay/s6-rc.d/cloudflared/type \
    && echo -e '#!/command/with-contenv bash\ncloudflared' >> /etc/s6-overlay/s6-rc.d/cloudflared/run

COPY ./config.yml /etc/cloudflared/config.yml

ENTRYPOINT /s6-init
