#!/bin/bash
work_dir=$1
ip=`/sbin/ifconfig eth0|grep inet|grep -v inet6|awk '{print $2}'|cut -d : -f2`
hostname=`hostname`

#config mesos master env
sed -i s/MESOS_IP=.*/MESOS_IP=${ip}/ ${work_dir}/docker-compose/master/mesos_master_env
sed -i s@MESOS_ZK=.*@MESOS_ZK=zk://${ip}:2181/mesos@ ${work_dir}/docker-compose/master/mesos_master_env
sed -i s/MESOS_HOSTNAME=.*/MESOS_HOSTNAME=${ip}/ ${work_dir}/docker-compose/master/mesos_master_env

#config marathon image env
sed -i s@MARATHON_MASTER=.*@MARATHON_MASTER=zk://${ip}:2181/mesos@ ${work_dir}/docker-compose/master/marathon_env
sed -i s@MARATHON_ZK=.*@MARATHON_ZK=zk://${ip}:2181/marathon@ ${work_dir}/docker-compose/master/marathon_env
sed -i s/MARATHON_HOSTNAME=.*/MARATHON_HOSTNAME=${ip}/ ${work_dir}/docker-compose/master/marathon_env

#config mesos slave env
# sed -i s/MESOS_IP=.*/MESOS_IP=${ip}/ ${work_dir}/docker-compose/master/mesos_slave_env
# sed -i s/MESOS_HOSTNAME=.*/MESOS_HOSTNAME=${hostname}/ ${work_dir}/docker-compose/master/mesos_slave_env
# sed -i s@MESOS_MASTER=.*@MESOS_MASTER=zk://${ip}:2181/mesos@ ${work_dir}/docker-compose/master/mesos_slave_env
