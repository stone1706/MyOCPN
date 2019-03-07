#!/usr/bin/env bash

# bailout on errror
set -xe


mkdir -p build && cd build
if [[ "$OCPN_TARGET" == "linux" ]];
  then cmake -DCMAKE_BUILD_TYPE=Debug ..
  make -sj2
  make package
elif [[ "$OCPN_TARGET" == "osx" ]]; then
  test -z "$TRAVIS_TAG" && CI_BUILD=OFF || CI_BUILD=ON; echo CI_BUILD:$CI_BUILD
  if [ -z "$TRAVIS_TAG" ]; then
    # CI build, include commit ID
    cmake -DOCPN_CI_BUILD=ON -DOCPN_USE_LIBCPP=ON \
      -DwxWidgets_CONFIG_EXECUTABLE=/tmp/wx312_opencpn50_macos109/bin/wx-config \
      -DwxWidgets_CONFIG_OPTIONS="--prefix=/tmp/wx312_opencpn50_macos109" \
      -DCMAKE_INSTALL_PREFIX=/tmp/opencpn -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
      ..
  else
    # Build from tag, include the version number only
    cmake -DOCPN_CI_BUILD=OFF -DOCPN_USE_LIBCPP=ON \
      -DwxWidgets_CONFIG_EXECUTABLE=/tmp/wx312_opencpn50_macos109/bin/wx-config \
      -DwxWidgets_CONFIG_OPTIONS="--prefix=/tmp/wx312_opencpn50_macos109" \
      -DCMAKE_INSTALL_PREFIX=/tmp/opencpn -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
      ..
  fi
  make -sj2
  mkdir -p /tmp/opencpn/bin/OpenCPN.app/Contents/MacOS
  mkdir -p /tmp/opencpn/bin/OpenCPN.app/Contents/SharedSupport/plugins
  chmod 644 /usr/local/lib/lib*.dylib
  make install
  make install # Dunno why the second is needed but it is, otherwise
               # plugin data is not included in the bundle
  make create-dmg
elif [[ "$OCPN_TARGET" == "mingw" ]]; then
  HERE="$PWD/.."  # FIXME, this is a cludge...
  docker run --privileged -d -ti -e "container=docker"  \
      -v /sys/fs/cgroup:/sys/fs/cgroup \
      -v $HERE:/opencpn-ci:rw \
      fedora:28   /usr/sbin/init
  DOCKER_CONTAINER_ID=$(docker ps | grep fedora | awk '{print $1}')
  docker logs $DOCKER_CONTAINER_ID
  docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec \
      "bash -xe /opencpn-ci/docker-build.sh 28;
           echo -ne \"------\nEND OPENCPN-CI BUILD\n\";"
  docker ps -a
  docker stop $DOCKER_CONTAINER_ID
  docker rm -v $DOCKER_CONTAINER_ID
fi
