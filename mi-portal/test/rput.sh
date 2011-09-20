#! /bin/sh
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
