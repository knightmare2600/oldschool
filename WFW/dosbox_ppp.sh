#!/bin/bash
#
# Heavily Modified from: https://www.dosbox.com/wiki/PPP_configuration_on_linux_host
#
# Usage:
# sudo ./isp.sh
#
# This script makes it so you can browse the net with DOSBox and Trumpet Winsock in
# Windows 3.11
#
# LINUX:
#   To use this script simply change the IP addresses below to two unused IP addresses on your network
#   then run with root (needed for port 23/proxyarp)
#
# WINDOWS 3.11:
#   Install Trumpet Winsock
#   Click on 'Dialer->Manual Login'
#   Type: AT (if you see 'ERROR' type AT again)
#   ATDT <LINUX IP ADDRESS>
#   e.g. ATDT 10.10.10.10
#   You should see 'CONNECT'
#   Hit the Escape button and your good to go!
#
# DOSBox Config:
#   Add this to the bottom of your config
#   [serial]
#   serial1=modem listenport:2323
#   serial2=dummy
#   serial3=disabled
#   serial4=disabled
#
## Version 1.0     Soldier Of Fortran     Initial Version
## Version 1.1     Knightmare             Some small edits for OSX

## Pre-flight checks are we a Fruit Computer or a Penguinista?
if [ -f /usr/bin/sw_vers  ]; then
  PRODUCT=`/usr/bin/sw_vers -productName`
elif [ -f /usr/bin/lsb_release ]; then
  PRODUCT="Linux"
fi

## Based on the host OS, enable IP Fowarding
if [ "$PRODUCT"=="Mac OS X" ]; then
  echo "** Enabling IP Forwarding for OSX"
  sudo sysctl -w net.inet.ip.forwarding=1
elif [ "$PRODUCT"=="Linux" ]; then
  echo "** Enabling IP Forwarding for Linux"
  grep -q 1 /proc/sys/net/ipv4/ip_forward || \
    ( sudo echo 1 1>/proc/sys/net/ipv4/ip_forward )
fi

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        echo "** Shutting down ISP"
	echo "** Goodbye 1995"
	pkill -9 pppd
	[ -e "$Serial" ] && rm "$Serial"
	exit 0
}

echo "SoF Presents:"
echo "  1995 ISP Simulator"
echo "Starting Simulator:"
#if [ "$1"=="BT" ]; then
# echo
# echo "
#    ______            ________             _____ 
#   |  __  \          |___  ___|           |__   | () ()
#   | |_/  /             | |                  |  |
#   | ___ <              | |                  |  |
#   | |_/  \     _       | |       _          |  |
#   |______/    (_)      |_|      (_)         |__|"
#elif [ "$1"=="" ]; then
 echo
 echo "   ____   _______   _____   _______     -------
    / __ \ |__   __| /   _ \ |__   __|  -====------
   | (__) |   | |    \  \ \_\   | |    -======------
   |  __  |   | |    /   \ __   | |    --====-------
   | |  | |   | |   |  (\ / /   | |     -----------
   |_|  |_|   |_|    \_____/    |_|       -------"

#fi
echo "** Creating fake ISP"
echo "** Using Serial /tmp/trumpet"

while true
do
    if sleep 0.1 && pgrep socat > /dev/null 2>&1
    then
	sleep 0.1
    else
	echo "** Starting socat listener on port 23"
        sudo socat TCP4-LISTEN:23 PTY,link="/tmp/trumpet" &
    fi
    sleep 0.5
    if pgrep pppd > /dev/null 2>&1
    then
        sleep 1
    else
        sudo pppd "/tmp/trumpet" defaultroute mtu 576 192.168.100.251:192.168.100.252 login proxyarp > /dev/null 2>&1
    fi
done
