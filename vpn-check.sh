#!/bin/bash

if ping -c 1 google.com >> /dev/null 2>&1; then
    echo "online"
   
else
    echo "offline"
    /restart-vpn.sh
fi
