FROM ubuntu

MAINTAINER ali azam <ali@azam.email>

EXPOSE 5053/tcp

EXPOSE 5053/udp

RUN apt-get update

RUN apt-get -y upgrade

RUN apt-get -y autoremove --purge

RUN apt-get -y install wget

RUN wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb

RUN apt-get install ./cloudflared-stable-linux-amd64.deb

RUN mkdir /etc/cloudflared/

RUN touch /etc/cloudflared/config.yml

RUN echo "proxy-dns: true" >> /etc/cloudflared/config.yml

RUN echo "proxy-dns-port: 5053" >> /etc/cloudflared/config.yml

RUN echo "proxy-dns-upstream:" >> /etc/cloudflared/config.yml

RUN echo "  - https://1.1.1.1/dns-query" >> /etc/cloudflared/config.yml

RUN echo "  - https://1.0.0.1/dns-query" >> /etc/cloudflared/config.yml

RUN cloudflared service install --legacy

ENTRYPOINT ["cloudflared"]
