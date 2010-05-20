#! /QOpenSys/usr/bin/sh

#
# @file build.sh
#
# Build script of this subproject.
# @remark This scipt file is supported to run in the PASE environment.
#

USAGE="usage: ./build.sh [params-to-make ...]"

# debug
echo "build.sh >>>> what i get: $*"

# change current directory
DIR=$(dirname $0)
cd $DIR

# debug
echo "build.sh >>>> where am i: $DIR"

# run make
make $*

# debug
echo "build.sh >>>> after invoking make ... "
