#!/bin/bash

SERVER_IP=`curl -s https://api.ipify.org`

useradd -M -r -s /bin/bash ovpn
echo "ovpn    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
cd /root
apt update && apt -y install openvpn git
sed -i 's/#AUTOSTART=\"all\"/AUTOSTART=\"all\"/' /etc/default/openvpn
systemctl daemon-reload
git clone https://github.com/OpenVPN/easy-rsa.git
git clone https://github.com/krasniykrd/vars.git
cd /root/easy-rsa/easyrsa3
cp -f /root/vars/vars /root/easy-rsa/easyrsa3/vars
sed -i 's/#CN#/VPNService/' vars
cp -f /root/vars/server.conf /etc/openvpn
sed -i 's/push redirect-gateway def1//' /etc/openvpn/server.conf
cp -f /root/vars/up2.sh /etc/openvpn
chmod +x /etc/openvpn/up2.sh
sed -i 's/#SUBNET#/10.1.2.0/' /etc/openvpn/server.conf
sed -i 's/#UP#/\/etc\/openvpn\/up2.sh/' /etc/openvpn/server.conf
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa gen-req server nopass
./easyrsa sign-req server server
mkdir -p /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/ca.crt /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/issued/server.crt /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/private/server.key /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/dh.pem /etc/openvpn/keys
cp -f /root/vars/vars /root/easy-rsa/easyrsa3/vars
sed -i 's/#CN#/S2S/' vars
./easyrsa gen-req s2s nopass
./easyrsa sign-req client s2s
service openvpn restart
echo "Successfully installed"
