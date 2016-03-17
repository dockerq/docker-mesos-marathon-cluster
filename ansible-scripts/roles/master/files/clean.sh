#!/usr/bin/env bash
dir=$1

cd $dir/docker-compose/master
docker-compose stop
echo 'y' | docker-compose rm
