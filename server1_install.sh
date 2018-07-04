#!/bin/bash

SERVER_IP=`curl -s https://api.ipify.org`
SERVER2_IP=$1
SERVER2_PASS=$2
useradd -M -r -s /bin/bash ovpn
echo "ovpn    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
cd /root
apt update && apt -y install openvpn git sshpass python3 zip
sed -i 's/#AUTOSTART=\"all\"/AUTOSTART=\"all\"/' /etc/default/openvpn
git clone https://github.com/OpenVPN/easy-rsa.git
git clone https://github.com/krasniykrd/vars.git
cd /root/easy-rsa/easyrsa3
cp -f /root/vars/vars /root/easy-rsa/easyrsa3/vars
sed -i 's/#CN#/VPNService/' vars
cp -f /root/vars/server.conf /etc/openvpn
cp -f /root/vars/up1.sh /etc/openvpn
chmod +x /etc/openvpn/up1.sh
sed -i 's/#SUBNET#/10.1.1.0/' /etc/openvpn/server.conf
sed -i 's/#UP#/\/etc\/openvpn\/up1.sh/' /etc/openvpn/server.conf
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa gen-req server nopass
./easyrsa sign-req server server
mkdir -p /etc/openvpn/keys
mkdir -p /etc/openvpn/keys/s2s
mkdir -p /root/configs
mkdir -p /etc/openvpn/ccd
cp -f /root/easy-rsa/easyrsa3/pki/ca.crt /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/issued/server.crt /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/private/server.key /etc/openvpn/keys
cp -f /root/easy-rsa/easyrsa3/pki/dh.pem /etc/openvpn/keys
cp -f /root/vars/s2s.conf /etc/openvpn/keys/s2s
cp -f /root/vars/s2s.sh /etc/openvpn/keys/s2s
chmod +x /etc/openvpn/keys/s2s/s2s.sh
sed -i "s/#SERVER#/$SERVER2_IP/" /etc/openvpn/keys/s2s/s2s.conf
cd /etc/openvpn/keys/s2s
sshpass -p $SERVER2_PASS sftp -o StrictHostKeyChecking=no root@$SERVER2_IP:/root/easy-rsa/easyrsa3/pki/ca.crt
sshpass -p $SERVER2_PASS sftp -o StrictHostKeyChecking=no root@$SERVER2_IP:/root/easy-rsa/easyrsa3/pki/issued/s2s.crt
sshpass -p $SERVER2_PASS sftp -o StrictHostKeyChecking=no root@$SERVER2_IP:/root/easy-rsa/easyrsa3/pki/private/s2s.key
sshpass -p $SERVER2_PASS sftp -o StrictHostKeyChecking=no root@$SERVER2_IP:/root/easy-rsa/easyrsa3/pki/dh.pem
cd /root/easy-rsa/easyrsa3
cp -f /root/vars/vars /root/easy-rsa/easyrsa3/vars
sed -i 's/#CN#/Client/' vars
./easyrsa gen-req client nopass
./easyrsa sign-req client client
cp -f /root/vars/client.ovpn /root/easy-rsa/easyrsa3
sed -i 's/#SERVER#/$SERVER_IP/' /root/easy-rsa/easyrsa3/client.ovpn
zip -9 /root/configs/client.zip /root/easy-rsa/easyrsa3/client.ovpn /root/easy-rsa/easyrsa3/pki/ca.crt /root/easy-rsa/easyrsa3/pki/issued/client.crt /root/easy-rsa/easyrsa3/pki/private/client.key /root/easy-rsa/easyrsa3/pki/dh.pem
cd /root/configs
nohup python3 -m http.server 80 &
systemctl daemon-reload
service openvpn restart
echo "Successfully installed"
echo "Config available on http://"$SERVER_IP"/client.zip"

