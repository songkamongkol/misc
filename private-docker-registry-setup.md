# Setting Up Private Docker Registry

## Goals
Setup Private Docker Registry (v2) with nginx reverse proxy. Nginx will be use for SSL termination.

## Assumptions
* Docker registry host is Debian Jessie
* The account use for this setup has root privilege

## Docker Registry Host - Setup
1. Install nginx on the server that will host the docker registry

        sudo apt-get install nginx

2. Install docker

        su
        apt-get update
        apt-get install wget
        wget -qO- https://get.docker.com/ | sh


3. Create docker registry certificate and key for SSL and copy them to the appropriate location
  
        mkdir -p certs && openssl req   -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key   -x509 -days 365 -out certs/domain.crt`
        cp certs/domain.key /etc/ssl/private/registry.key
        cp certs/domain.crt /etc/ssl/private/registry.crt
  
4. Replace `/etc/nginx/nginx.conf` with this [nginx.conf](https://github.com/songkamongkol/doc/blob/master/nginx.conf) and restart nginx service

        sudo systemctl restart nginx.service
        
5. Start docker registry container 

        docker run --rm --name registry -p 5000:5000 registry:2

## Docker Client - Setup
1. Install docker (see above)
2. Obtain certificate file created from step 3 of the **Docker Registry Host - Setup** section above and place them in the appropriate location
    >In this example, the docker registry hostname is orion-boon.cal.ci.spirentcom.com
        
        mkdir /etc/docker/certs.d/orion-boon.cal.ci.spirentcom.com
        cp domain.crt /etc/docker/certs.d/orion-boon.cal.ci.spirentcom.com/ca.crt

3. Restart docker daemon if it's already running (`docker -d` or `docker daemon`)
4. To pull from the private registry, use the following command
       
        docker pull orion-boon.cal.ci.spirentcom.com/busybox

5. To push to the private registry, use the following commands

        docker tag c16ca5ee96c0 orion-boon.cal.ci.spirentcom.com/busybox 
        docker push orion-boon.cal.ci.spirentcom.com/busybox
        
    > Hash `c16ca5ee96c0` is the image id to be pushed (in the output of `docker images` command)

>Note: For this setup, you do not need to specify any port number (e.g., `:5000`) when referring to the docker registry host


 
