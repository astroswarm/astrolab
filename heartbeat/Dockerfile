FROM base:latest

RUN apt-get -y update
RUN apt-get -y install curl

CMD while echo $(curl --silent --request POST --data "" http://$(cat $HOST_DATA_DIR/lan_ip_address):$BRAIN_WAN_PORT/api/heartbeat); do sleep ${HEARTBEAT_INTERVAL_IN_SECONDS:-60}; done
