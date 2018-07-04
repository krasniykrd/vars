#!/bin/bash

if [ "$script_type" == "up" ]; then
	TUN=`sudo ip a | grep -E -o '10\.1\.2\..+' | awk -F' ' '{print $1}'`
	sudo iptables -t nat -F
	sudo ip r f table 120
	sudo iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -j SNAT --to-source $TUN
	sudo ip rule add from 10.1.1.0/24 lookup 120
	sudo ip route add default via $TUN table 120

fi