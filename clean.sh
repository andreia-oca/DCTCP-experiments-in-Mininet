#!/bin/bash

if [ "$UID" != "0" ]; then
    echo "Please run as root"
    exit 0
fi

rm -rf output/
sudo mn -c
