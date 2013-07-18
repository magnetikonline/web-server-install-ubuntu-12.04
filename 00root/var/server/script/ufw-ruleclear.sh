#!/bin/bash

ufw delete limit 22/tcp
ufw delete allow 80/tcp
#ufw delete allow 443/tcp
