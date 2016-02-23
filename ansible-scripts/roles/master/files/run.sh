#!/usr/bin/env bash

docker exec zookeeper /usr/local/zookeeper/bin/zkServer.sh start
docker exec mesos_master nohup mesos-master start
docker exec mesos_slave nohup mesos-slave start
docker exec marathon nohup marathon
