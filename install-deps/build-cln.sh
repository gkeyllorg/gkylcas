#!/bin/bash

source ./build-opts.sh

# Edit to suite your system
PREFIX=$GKYLSOFT/cln-1.3.7
# Location where dependency sources will be downloaded
DEP_SOURCES=$GKYLSOFT/dep_src/

mkdir -p $DEP_SOURCES
cd $DEP_SOURCES

# delete old checkout and builds
rm -rf cln-*

curl -L https://www.ginac.de/CLN/cln-1.3.7.tar.bz2 > cln-1.3.7.tar.bz2
bunzip2 cln-1.3.7.tar.bz2
tar xvf cln-1.3.7.tar
cd cln-1.3.7
./configure --prefix=$PREFIX
make -j
make install

# soft-link 
ln -sfn $PREFIX $GKYLSOFT/cln


