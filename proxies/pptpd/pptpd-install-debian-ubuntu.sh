#!/bin/bash
apt install pptpd ppp iptables iproute2 -y && \
    echo 'option /etc/ppp/pptpd-options' > /etc/pptpd.conf && \
    echo 'pidfile /var/run/pptpd.pid' >> /etc/pptpd.conf && \
    echo 'localip 192.168.47.1' >> /etc/pptpd.conf && \
    echo 'remoteip 192.168.47.100-199' >> /etc/pptpd.conf && \
    echo 'name pptpd' > /etc/ppp/pptpd-options && \
    echo 'refuse-pap' >> /etc/ppp/pptpd-options && \
    echo 'refuse-chap' >> /etc/ppp/pptpd-options && \
    echo 'refuse-mschap' >> /etc/ppp/pptpd-options && \
    echo 'require-mschap-v2' >> /etc/ppp/pptpd-options && \
    echo 'require-mppe-128' >> /etc/ppp/pptpd-options && \
    echo 'proxyarp' >> /etc/ppp/pptpd-options && \
    echo 'nodefaultroute' >> /etc/ppp/pptpd-options && \
    echo 'lock' >> /etc/ppp/pptpd-options && \
    echo 'nobsdcomp' >> /etc/ppp/pptpd-options && \
    echo 'novj' >> /etc/ppp/pptpd-options && \
    echo 'novjccomp' >> /etc/ppp/pptpd-options && \
    echo 'nologfd' >> /etc/ppp/pptpd-options

rm -rf /etc/resolv.conf
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
echo 'nameserver 2001:4860:4860::8888' >> /etc/resolv.conf
echo 'nameserver 2001:4860:4860::8844' >> /etc/resolv.conf

echo 'test * test *' > /etc/ppp/chap-secrets

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -I INPUT -p gre -j ACCEPT
iptables -I INPUT -p tcp --dport 1723 -m state --state NEW -j ACCEPT
iptables-save > /etc/iptables.up.rules
ufw allow 1723
systemctl restart ufw
/etc/init.d/pptpd restart
