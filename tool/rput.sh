#! /bin/sh

# This file is part of i5/OS Programmer's Toolkit.
# 
# Copyright (C) 2010, 2011  Junlei Li (李君磊).
# 
# i5/OS Programmer's Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# i5/OS Programmer's Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with i5/OS Programmer's Toolkit.  If not, see <http://www.gnu.org/licenses/>.

#
# @file rput.sh
#
# Put local files to an IBM i server via `lftp' recursively
#
# Usage: rput.sh host-name host-dir file-name ...
#

# Check number of input arguments
if [ $# -lt 3 ]
then
    echo "Usage: rput.sh host-name host-dir file-name ..."
    return 1
fi

HOST_NAME=$1
HOST_DIR=$2
LFTP_CMD="cd $HOST_DIR;"

# Generate lftp commands for each file in the input file-name list
shift 2
for f in $*
do
    LFTP_CMD="$LFTP_CMD put -O $(dirname $f) $f;"
done

LFTP_CMD=$LFTP_CMD" by"
echo "command: '"$LFTP_CMD"'"
lftp -e "$LFTP_CMD" $HOST_NAME
