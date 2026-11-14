#!/bin/bash

source ./build-opts.sh

# Edit to suite your system
PREFIX=$GKYLSOFT/ginac-1.8.10
# Location where dependency sources will be downloaded
DEP_SOURCES=$GKYLSOFT/dep_src/

mkdir -p $DEP_SOURCES
cd $DEP_SOURCES

# delete old checkout and builds
rm -rf ginac-*

curl -L https://www.ginac.de/ginac-1.8.10.tar.bz2 > ginac-1.8.10.tar.bz2
bunzip2 ginac-1.8.10.tar.bz2
tar xvf ginac-1.8.10.tar
cd ginac-1.8.10
PKG_CONFIG_PATH=$GKYLSOFT/cln-1.3.7/lib/pkgconfig ./configure --prefix=$PREFIX --disable-shared
make -j
make install

# soft-link 
ln -sfn $PREFIX $GKYLSOFT/ginac


