#!/bin/bash

PID="/run/nginx.pid"


if [ ! -f "$PID" ]; then
	echo "Nginx not currently running"
	exit
fi

kill -HUP `cat $PID`
