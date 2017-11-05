#!/usr/bin/env sh

export ASTROSWARM_API_HOST=172.19.0.1:3001
export BRAIN_CONTEXT=../brain
export HEARTBEAT_CONTEXT=../heartbeat
export HOST_DATA_DIR=/tmp
export PORTAINER_DATA_DIR=/tmp
export RACK_ENV=development
export SHARED_DIR=/tmp
export SYSLOG_PATH=/tmp/syslog

echo -n $(ipconfig getifaddr en0) > $HOST_DATA_DIR/lan_ip_address
echo "Dummy log entry" >> $SYSLOG_PATH
