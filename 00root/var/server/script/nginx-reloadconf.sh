#!/bin/bash

PID="/run/nginx.pid"


if [ ! -f "$PID" ]; then
	echo "Nginx not running"
	exit
fi

kill -HUP `cat $PID`
