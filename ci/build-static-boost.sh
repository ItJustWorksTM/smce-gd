#!/bin/sh

BOOST_ARK_BASENAME=$(echo $1 | sed "s/^/boost_/;s/\./_/g")
wget -qOboost_src.tgz https://boostorg.jfrog.io/artifactory/main/release/$1/source/$BOOST_ARK_BASENAME.tar.gz
tar -xzf ./boost_src.tgz
mkdir boost_root
cd $BOOST_ARK_BASENAME
./bootstrap.sh --prefix=../boost_root/
./b2 link=static cflags='-fPIC' install
cd ../
export BOOST_ROOT="$(pwd)/boost_root"
