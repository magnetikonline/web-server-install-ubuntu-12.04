#!/bin/bash

DIRNAME=`dirname $0`
VNSTAT_BIN="$DIRNAME/vnstati"
VNSTAT_CONF="$DIRNAME/vnstat.conf"
IMAGE_OUT_DIR="/var/www/00/_vnstat768438"
INTERFACE="eth0"


$VNSTAT_BIN --config $VNSTAT_CONF -i $INTERFACE -s -o $IMAGE_OUT_DIR/00summary.png
$VNSTAT_BIN --config $VNSTAT_CONF -i $INTERFACE -h -o $IMAGE_OUT_DIR/01hourly.png
$VNSTAT_BIN --config $VNSTAT_CONF -i $INTERFACE -d -o $IMAGE_OUT_DIR/02daily.png
$VNSTAT_BIN --config $VNSTAT_CONF -i $INTERFACE -m -o $IMAGE_OUT_DIR/03monthly.png
