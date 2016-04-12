#!/usr/bin/env bash

dir=$1
cd ${dir}/docker-compose/slave
docker-compose stop
echo 'y' | docker-compose rm

rm -rf /var/mesos_slave/
