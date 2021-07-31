#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

clear
CUR_DIR=$(pwd)

if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!"
    exit 1
fi

echo "#############################################################"
echo "# PPTP VPN Auto Install"
echo "# Env: Debian/Ubuntu"
echo "# Created by Domorelivelonger on 2021.07.31"
echo "# Author Url: http://webxdata.com"
echo "# Version: 1.0"
echo "#############################################################"
echo ""

apt-get -y update
apt-get -y install pptpd

cat >>/etc/pptpd.conf<<EOF
localip 10.10.10.1
remoteip 10.10.10.2-254
EOF

cp /etc/ppp/pptpd-options /etc/ppp/pptpd-options.old

cat >/etc/ppp/pptpd-options<<EOF
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
debug
dump
lock
nobsdcomp
novj
novjccomp
logfile /var/log/pptpd.log
EOF

cat >>/etc/ppp/chap-secrets<<EOF
test * test *
EOF

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p

iptables-save > /etc/iptables.down.rules

iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -j MASQUERADE
#iptables -I FORWARD -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1300

iptables-save > /etc/iptables.up.rules


/etc/init.d/pptpd restart



ufw allow 1723
cp /etc/sysctl.conf /etc/sysctl.conf.original
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf
sysctl -p

iptables -I INPUT -p tcp --dport 1723 -m state --state NEW -j ACCEPT
iptables -I INPUT -p gre -j ACCEPT
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -s 172.20.1.0/24 -j TCPMSS  --clamp-mss-to-pmtu

iptables-save > /etc/iptables.up.rules
