**Pi-Hole & Cloudflared DoH (DNS-over-HTTPS) Docker**
=============
**DONT USE YOUR OWN PIHOLE DOCKER COMPOSE, OTHERWISE DoH WILL NOT BE CONFIGURED**

After install, please restore your backup to the new pihole installation.

Do not mess up with the DNS settings in the new pihole installation, otherwise your DoH might not work.
___
This docker completes this tutorial (https://docs.pi-hole.net/guides/dns/cloudflared/) and uses it to install DoH on a new pihole installation (https://hub.docker.com/r/pihole/pihole). No matter the age of this docker, it should work, unless, pihole changes their repo, docker-compose.yml, or if cloudflared changes their config layout, or if they change their cloudflared download link. If for some reason it fails to work, please contact me using the contact info at the end of this README. 

More Info on What DoH is: https://developers.cloudflare.com/1.1.1.1/dns-over-https
___
Default password: admin

You can change the default password in the docker-compose.yml file OR by using this command: (pihole-doh is the default docker name in the docker-compose.yml file provided)
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
      WEBPASSWORD: admin
    volumes:
      - './etc-pihole/:/etc/pihole/'
      - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
    cap_add:
      - NET_ADMIN
```
____
For those wondering, this is the Dockerfile file for the AMD64 docker:
```Dockerfile
FROM pihole/pihole

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y autoremove --purge \
    && apt-get -y install wget \
    && wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb \
    && apt-get install ./cloudflared-stable-linux-amd64.deb \
    && mkdir -p /etc/cloudflared/ 
    
COPY ./config.yml /etc/cloudflared/config.yml

RUN cloudflared service install --legacy
    
COPY ./startup /etc/startup

RUN mkdir -p /etc/pihole-doh/logs/pihole \
    && chmod +x /etc/startup

ENTRYPOINT ["/etc/startup"]
```
___
For those wondering, this is the Dockerfile file for the ARM64V8 docker:
```Dockerfile
FROM pihole/pihole:latest-arm64v8

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y autoremove --purge \
    && apt-get -y install wget \
    && wget https://github.com/cloudflare/cloudflared/releases/download/2021.3.6/cloudflared-linux-arm64 \
    && mv ./cloudflared-linux-arm64 cloudflared \
    && mv ./cloudflared /usr/bin \
    && mkdir -p /etc/cloudflared/ 
    
COPY ./config.yml /etc/cloudflared/config.yml

RUN cloudflared service install --legacy
    
COPY ./startup /etc/startup

RUN mkdir -p /etc/pihole-doh/logs/pihole \
    && chmod +x /etc/startup

ENTRYPOINT ["/etc/startup"]
```
___
For those wondering, this is the Dockerfile file for the ARM32V7 docker:
```Dockerfile
FROM pihole/pihole:latest-arm32v7

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y autoremove --purge \
    && apt-get -y install wget \
    && wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.deb \
    && apt-get install ./cloudflared-stable-linux-arm.deb \
    && mkdir -p /etc/cloudflared/ 
    
COPY ./config.yml /etc/cloudflared/config.yml

RUN cloudflared service install --legacy
    
COPY ./startup /etc/startup

RUN mkdir -p /etc/pihole-doh/logs/pihole \
    && chmod +x /etc/startup

ENTRYPOINT ["/etc/startup"]
```
___
For those wondering, this is the config.yml file cloudflared uses:
```yml
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
```
___
For those wondering, this is the script the docker runs on startup:
```shell
#!/bin/bash

cd /etc/pihole-doh/logs/pihole && nohup /s6-init &
cloudflared
```
___

Contact:

Name: Ali Azam

Email: ali@azam.email
