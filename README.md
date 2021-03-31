**Pi-Hole & Cloudflared DoH (DNS-over-HTTPS) Docker**
=============
**(Not Working Due To Technical Difficulties, Do Not Pull This Yet)**

**DONT USE YOUR OWN PIHOLE DOCKER COMPOSE, OTHERWISE DoH WILL NOT BE CONFIGURED**

After install, please restore your backup to the new pihole installation.

Do not mess up with the DNS settings in the new pihole installation, otherwise your DoH might not work.
___
This docker completes this tutorial (https://docs.pi-hole.net/guides/dns/cloudflared/) and uses it to install DoH on a new pihole installation (https://hub.docker.com/r/pihole/pihole). No matter the age of this docker, it should work, unless, pihole changes their repo, docker-compose.yml, or if cloudflared changes their config layout, or if they change their cloudflared download link. If for some reason it fails to work, please contact me using the contact info at the end of this README. 
___
Default password: admin

You can change the default password by using this command: (pihole-doh is the default docker name in the docker-compose.yml file provided)
```command
sudo docker exec -it DOCKER_NAME pihole -a -p
```
___
Docker Compose:
```yml
version: "3"

services:
  pihole-doh:
    container_name: pihole-doh
    image: azamserver/pihole-doh:latest
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
    environment:
      TZ: 'America/New_York'
      DNS1: '127.0.0.1#5053'
    volumes:
      - './etc-pihole/:/etc/pihole/'
      - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
    cap_add:
      - NET_ADMIN
```
____
For those wondering, this is the Dockerfile file for the cloudflared docker:
```yml
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
    && mkdir -p /etc/pihole-doh/logs/pihole \
    && chmod +x /etc/startup

ENTRYPOINT ["/etc/startup"]
```
___
For those wondering, this is the script the docker runs on startup:
```startup
#!/bin/bash

cd /etc/pihole-doh/logs/pihole && nohup /s6-init &
cloudflared
```
___

Contact:

Name: Ali Azam

Email: ali@azam.email
