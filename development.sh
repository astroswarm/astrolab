#!/usr/bin/env sh

export ASTROSWARM_API_HOST=172.19.0.1:3001
export BRAIN_CONTEXT=../brain
export HEARTBEAT_CONTEXT=../heartbeat
export HOST_DATA_DIR=/tmp
export PORTAINER_DATA_DIR=/tmp
export RACK_ENV=development
export SHARED_DIR=/tmp
export SYSLOG_PATH=/private/var/log/system.log
export WPA_SUPPLICANT_PATH=/tmp/wpa_supplicant.conf
export PASTEBINIT_URI=http://$(ipconfig getifaddr en0):3002/
export PASTEBINIT_USERNAME=astro
export PASTEBINIT_PASS=swarm
export BRAIN_GO_VERSION=1.10
export BRAIN_GO_ARCH=amd64

touch $WPA_SUPPLICANT_PATH
echo -n $(ipconfig getifaddr en0) > $HOST_DATA_DIR/lan_ip_address
