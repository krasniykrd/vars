#!/bin/bash

if [ "$script_type" == "up" ]; then
	SERVER_IP=`curl -s https://api.ipify.org`
	sudo iptables -t nat -A POSTROUTING -s 10.1.2.0/24 -j SNAT --to-source $SERVER_IP
fi