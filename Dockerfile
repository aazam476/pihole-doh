FROM pihole/pihole

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

RUN apt-get update \
    && apt-get -y install wget \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && apt-get -y purge wget \
    && apt-get install ./cloudflared-linux-amd64.deb \
    && mkdir -p /etc/cloudflared/ 
    
COPY ./config.yml /etc/cloudflared/config.yml

RUN cloudflared service install --legacy
    
COPY ./startup /etc/startup

RUN mkdir -p /etc/pihole-doh/logs/pihole \
    && chmod +x /etc/startup

ENTRYPOINT ["/etc/startup"]
