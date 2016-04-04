#!/bin/bash

# Check that system daemons are running

pid=$(pidof /sbin/rpcbind)
if [ -z "$pid" ]
then
    echo "/sbin/rpcbind not running"
    exit 1
fi

pid=$(pidof /sbin/rpc.statd)
if [ -z "$pid" ]
then
    echo "/sbin/rpc.statd not running"
    exit 1
fi

pid=$(pidof /usr/sbin/rpc.idmapd)
if [ -z "$pid" ]
then
    echo "/usr/sbin/rpc.idmapd not running"
    exit 1
fi

# Check that Node.js is running 
# Future use: this script for Nagios might be useful:
# https://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/check_nfs_health-2Esh/details

pid=$(pidof /usr/local/bin/node)
if [ -z "$pid" ]
then
    echo "/usr/local/bin/node not running"
    exit 1
fi
