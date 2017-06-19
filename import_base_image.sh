#!/usr/bin/env sh

if [ $(uname -m) = "x86_64" ]; then
  docker pull debian:latest
  docker tag debian:latest base:latest
elif uname -m | grep "arm" > /dev/null; then
  docker pull resin/rpi-raspbian:jessie-20170614
  docker tag resin/rpi-raspbian:jessie-20170614 base:latest
else
  echo "Invalid architecture"
fi
