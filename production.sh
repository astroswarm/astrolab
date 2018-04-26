#!/usr/bin/env bash

export ASTROSWARM_API_HOST=api.astroswarm.com
export BRAIN_CONTEXT=https://github.com/astroswarm/brain.git
export FRONTEND_CONTEXT=https://github.com/astroswarm/frontend.git
export FRONTEND_DOCKERFILE=Dockerfile.production
export HEARTBEAT_CONTEXT=https://github.com/astroswarm/heartbeat.git
export HOST_DATA_DIR=/host-data
export PORTAINER_DATA_DIR=/mnt/shared/portainer/data
export RACK_ENV=production
export SHARED_DIR=/mnt/shared
export SYSLOG_PATH=/var/log/syslog
export WPA_SUPPLICANT_PATH=/etc/wpa_supplicant/wpa_supplicant.conf
export PASTEBINIT_URI=http://pastebin.astroswarm.com/
export PASTEBINIT_USERNAME=astro
export PASTEBINIT_PASS=swarm
export BRAIN_GO_VERSION=1.10
if [ "$(uname -m)" == "x86_64" ] ; then
  export BRAIN_GO_ARCH=amd64
elif [ "$(uname -m)" == "armv7l" ] ; then
  export BRAIN_GO_ARCH=armv6l
fi
