#!/usr/bin/env bash

export ASTROSWARM_API_HOST=172.19.0.1:3001
export HOST_DATA_DIR=/tmp
export PORTAINER_DATA_DIR=/tmp
export RACK_ENV=development
export SHARED_DIR=/tmp
export DOCKER_CONTAINERS_DIR=/tmp/var/lib/docker/containers
export SYSLOG_PATH=/private/var/log/system.log
export WPA_SUPPLICANT_PATH=/tmp/wpa_supplicant.conf
export PASTEBINIT_URI=http://$(ipconfig getifaddr en0):3002/
export PASTEBINIT_USERNAME=astro
export PASTEBINIT_PASS=swarm

# Generate some nonsense mock docker logs
rm -rf /tmp/var/lib/docker/containers
mkdir -p /tmp/var/lib/docker/containers/0001
mkdir -p /tmp/var/lib/docker/containers/0002
mkdir -p /tmp/var/lib/docker/containers/0003
mkdir -p /tmp/var/lib/docker/containers/0004
for i in {1..10};
do
  echo "$(base64 /dev/urandom | head -c 100)" >> /tmp/var/lib/docker/containers/0001/0001-json.log
  echo "$(base64 /dev/urandom | head -c 100)" >> /tmp/var/lib/docker/containers/0002/0002-json.log
  echo "$(base64 /dev/urandom | head -c 100)" >> /tmp/var/lib/docker/containers/0003/0003-json.log
  echo "$(base64 /dev/urandom | head -c 100)" >> /tmp/var/lib/docker/containers/0004/0004-json.log
done

touch $WPA_SUPPLICANT_PATH
echo -n $(ipconfig getifaddr en0) > $HOST_DATA_DIR/lan_ip_address
