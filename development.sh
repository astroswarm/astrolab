#!/usr/bin/env sh

export ARCH=x86_64
export ASTROSWARM_API_HOST=172.19.0.1:3001
export HOST_DATA_DIR=/tmp
export PORTAINER_DATA_DIR=/tmp
export RACK_ENV=development
export SHARED_DIR=/tmp

echo -n "172.18.0.1" > $HOST_DATA_DIR/lan_ip_address
