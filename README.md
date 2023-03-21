**Pi-Hole & Cloudflared DoH (DNS-over-HTTPS) Docker**
=============
This docker image is now offically supported by the Docker-Sponsored Open Source program and should now be built whenever Pi-Hole updates.

Even though the last commit on this repository may be old, unless stated so, this project is still being mantained. No commits just mean that there is nothing for me to update.
___
If you would like to support this project, you can donate here:

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate?business=P7FNV8MU6ECR6&no_recurring=0&item_name=To+Keep+Projects%2C+Like+Pi-Hole+DOH%2C+Alive&currency_code=USD)
___
**DONT USE YOUR OWN PIHOLE DOCKER COMPOSE, OTHERWISE DoH WILL NOT BE CONFIGURED**

After install, please restore your backup to the new pihole installation.

Do not mess up with the DNS settings in the new pihole installation, otherwise your DoH might not work.
___
This docker completes this tutorial (https://docs.pi-hole.net/guides/dns/cloudflared/) and uses it to install DoH on a new pihole installation (https://hub.docker.com/r/pihole/pihole). No matter the age of this docker, it should work, unless, pihole changes their repo, docker-compose.yml, or if cloudflared changes their config layout, or if they change their cloudflared download link. If for some reason it fails to work, please contact me using the contact info at the end of this README. 

More Info on What DoH is: https://en.wikipedia.org/wiki/DNS_over_HTTPS
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
For those wondering, this is the Dockerfile file for this docker:
```yml
FROM pihole/pihole

MAINTAINER ali azam <ali@azam.email>

EXPOSE 53:53/tcp 53:53/udp 67:67/udp 80:80/tcp

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y autoremove --purge \
    && apt-get -y install wget \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && apt-get install ./cloudflared-linux-amd64.deb \
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
```config.yml
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
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
