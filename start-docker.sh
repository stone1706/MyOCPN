#!/bin/sh -xe

# Start docker and systemd

docker run --privileged -d -ti -e "container=docker"  \
    -v /sys/fs/cgroup:/sys/fs/cgroup -v `pwd`:/opencpn-ci:rw \
    fedora:28   /usr/sbin/init
DOCKER_CONTAINER_ID=$(docker ps | grep fedora | awk '{print $1}')
docker logs $DOCKER_CONTAINER_ID
docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec \
    "bash -xe /opencpn-ci/docker-build.sh 28;
         echo -ne \"------\nEND HTCONDOR-CE TESTS\n\";"
docker ps -a
docker stop $DOCKER_CONTAINER_ID
docker rm -v $DOCKER_CONTAINER_ID

