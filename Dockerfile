FROM pihole/pihole

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

COPY ./startup /etc/startup

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y autoremove --purge \
    && apt-get -y install wget \
    && wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb \
    && apt-get install ./cloudflared-stable-linux-amd64.deb \
    && mkdir /etc/cloudflared/ \
    && touch /etc/cloudflared/config.yml \
    && echo "proxy-dns: true" >> /etc/cloudflared/config.yml \
    && echo "proxy-dns-port: 5053" >> /etc/cloudflared/config.yml \
    && echo "proxy-dns-upstream:" >> /etc/cloudflared/config.yml \
    && echo "  - https://1.1.1.1/dns-query" >> /etc/cloudflared/config.yml \
    && echo "  - https://1.0.0.1/dns-query" >> /etc/cloudflared/config.yml \
    && cloudflared service install --legacy \
    && chmod +x /etc/startup

ENTRYPOINT ["/etc/startup"]
