#!/bin/bash

if [ "$script_type" == "up" ]; then
	S2SPID=`ps aux | grep openvpn | grep s2s | grep -v "nohup" | awk -F" " '{print $2}'`
	if [ -z "$VAR" ]; then
	else
		sudo kill -9 $S2SPID
	fi
	sudo nohup openvpn --config /etc/openvpn/keys/s2s/s2s.conf &
fi