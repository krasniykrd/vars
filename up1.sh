#!/bin/bash

if [ "$script_type" == "up" ]; then
	sudo nohup openvpn --config /etc/openvpn/s2s/s2s.conf &
fi