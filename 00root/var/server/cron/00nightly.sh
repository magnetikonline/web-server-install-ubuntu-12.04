#!/bin/bash -e

DIRNAME=$(dirname "$0")


ntpdate ntp.ubuntu.com
logrotate /etc/logrotate.conf
