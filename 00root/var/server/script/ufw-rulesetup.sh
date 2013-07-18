#!/bin/bash

ufw logging off
ufw default deny incoming
ufw default allow outgoing


ufw limit 22/tcp
ufw allow 80/tcp
#ufw allow 443/tcp
