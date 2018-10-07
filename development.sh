#!/usr/bin/env bash

export ASTROSWARM_API_HOST=$(ipconfig getifaddr en0):3001
export HOST_DATA_DIR=/tmp
export PORTAINER_DATA_DIR=/tmp
export RACK_ENV=development
export SHARED_DIR=/tmp
export SYSLOG_PATH=/private/var/log/system.log
export WPA_SUPPLICANT_PATH=/tmp/wpa_supplicant.conf
export ETH_ADDRESS_FILE=/tmp/eth0_address
export PASTEBINIT_URI=http://$(ipconfig getifaddr en0):3002/
export PASTEBINIT_USERNAME=astro
export PASTEBINIT_PASS=swarm
export BRAIN_GO_ARCH=amd64

touch $WPA_SUPPLICANT_PATH
echo -n $(ipconfig getifaddr en0) > $HOST_DATA_DIR/lan_ip_address
echo -n $(ifconfig en0 | awk '/ether/{print $2}' | sed s/\://g) > $ETH_ADDRESS_FILE
