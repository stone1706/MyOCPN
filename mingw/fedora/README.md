What's here?
============

Tools to build a windows 32-bit executable using the mingw toolchain.

How?
====

sudo dnf builddep opencpn-deps.spec
cd ../../
rm -rf build; mkdir build
cd build;
cmake -DCMAKE_TOOLCHAIN_FILE=../mingw/fedora/minw-toolchain.cmake [...] ..

Notes:
=====
The build requires  updated packages available at
https://copr.fedorainfracloud.org/coprs/leamas/opencpn-mingw/builds/
Here is also the wx3GTK package required to build opencpn on the regular
fedora gcc toolchain.
