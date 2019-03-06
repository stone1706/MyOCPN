#!/bin/sh  -xe

df -h
su -c "dnf install -y sudo dnf-plugins-core"
sudo dnf copr enable -y --nogpgcheck leamas/opencpn-mingw 
sudo dnf builddep  -y /opencpn-ci/mingw/fedora/opencpn-deps.spec
cd /opencpn-ci
rm -rf build; mkdir build; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../mingw/fedora/toolchain.cmake \
    -DOCPN_NEW_SERIAL=OFF\
    ..
make -j2
make package
