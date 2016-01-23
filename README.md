# suse-pkg-monitoring

## Description

...

## Installing

### Prerequisites for Ubuntu 14.04.3

* Follow instructions from https://docs.docker.com/engine/installation/ubuntulinux/

```
# apt-get install git
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F76221572C52609D
# cat > /etc/apt/sources.list.d/docker.list
deb https://apt.dockerproject.org/repo ubuntu-trusty main
# apt-get update
# apt-get purge lxc-docker
# apt-get install docker-engine
```

## Git clone

```
# git clone https://github.com/eduardoj/suse-pkg-monitoring.git
# cd suse-pkg-monitoring
```

## Build docker container

Ensure you have ~900MB free space on your system.

```
# docker build --rm -t opensuse-demo .
```

## Running the application

```
# docker run --name pkg-monitoring -p 8080:8080 -t opensuse-demo
Server available at http://127.0.0.1:8080
```

* Open web browser at: http://127.0.0.1:8080

* Open other terminal and enter the docker machine, and install an arbitrary package:

```
# docker exec -i -t pkg-monitoring bash
bash-4.2# zypper install hello
```
... and watch the web browser.
