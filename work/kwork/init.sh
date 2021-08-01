#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
IP="159.69.180.115"
EMAIL="a@dev.nku.su"
DOMAIN="dev.nku.su"
SSH_OPTIONS="-o StrictHostKeyChecking=no -o ConnectionAttempts=60"
release=$(ssh $SSH_OPTIONS root@$IP lsb_release -cs)
rm ~/.ssh/known_hosts

ssh $SSH_OPTIONS root@$IP <<EOF
apt update
apt upgrade -y

apt install curl gnupg2 ca-certificates lsb-release apt-utils libterm-readkey-perl libswitch-perl -y

apt install snapd -y
snap install core
snap refresh core
EOF

ssh $SSH_OPTIONS root@$IP <<EOF
snap install --classic certbot
EOF

ssh $SSH_OPTIONS root@$IP <<EOF
ln -s /snap/bin/certbot /usr/bin/certbot
echo "Getting SSL"
certbot certonly --standalone -m $EMAIL -d $DOMAIN  --agree-tos -n 
echo "Let's Encrypt SSL done"
echo "--------------------------------------------------------------------------------------------------------"
openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
EOF
ssh $SSH_OPTIONS root@$IP <<EOF
echo "deb http://security.ubuntu.com/ubuntu bionic-security main" | sudo tee -a /etc/apt/sources.list.d/bionic.list
apt update
apt-cache policy libssl1.0-dev 
apt install libssl1.0-dev -y
EOF

echo "Nginx instalaltion"

ssh $SSH_OPTIONS root@$IP <<EOF
echo "deb http://nginx.org/packages/mainline/ubuntu $release nginx" > /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
gpg --dry-run --quiet --import --import-options show-only /tmp/nginx_signing.key
mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
apt update

apt install nginx -y
EOF

scp server/nginx.conf root@$IP:/etc/nginx/nginx.conf


echo "Clear all iptables rules"
ssh $SSH_OPTIONS root@$IP <<EOF
echo "history" >> etc/iptables.up.rules.old
iptables-save >> /etc/iptables.up.rules.old
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
EOF

ssh $SSH_OPTIONS root@$IP <<EOF
nginx -s reload

curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt update

apt install -y nodejs
npm install -g npm@latest
npm install -g pm2@latest 
pm2 startup

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 1723



apt update
apt full-upgrade -y
apt autoclean
apt autoremove
apt clean
EOF


ssh $SSH_OPTIONS root@$IP <<EOF
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
sed -i 's%*filter%*filter\n-A ufw-before-input -p 47 -j ACCEPT%g' /etc/ufw/before.rules
sed -i 's%*filter%*filter\n-A ufw-before-output -p 47 -j ACCEPT%g' /etc/ufw/before.rules
sed -i 's%# drop INVALID packets (logs these in loglevel medium and higher)%# drop INVALID packets (logs these in loglevel medium and higher)\n-A ufw-before-input -p 47 -j ACCEPT%g' /etc/ufw/before.rules
sed -i "s%# Don't delete these required lines, otherwise there will be errors%# Don't delete these required lines, otherwise there will be errors\n*nat%g" /etc/ufw/before.rules
sed -i 's%*nat%*nat \n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -o eth0 -j MASQUERADE\nCOMMIT\n%g' /etc/ufw/before.rules
EOF





ssh $SSH_OPTIONS root@$IP <<EOF
ufw disable
ufw --force enable
echo "y" | sudo ufw enable
EOF


echo "PPTPD SERVER INSTALLATION"
ssh $SSH_OPTIONS root@$IP <<EOF
apt install pptpd ppp iptables iproute2 -y
EOF
echo "Done --------------------------------------------------------------------------------------"
ssh $SSH_OPTIONS root@$IP <<EOF
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "pidfile /var/run/pptpd.pid" >> /etc/pptpd.conf
echo "localip 10.10.10.1" >> /etc/pptpd.conf
echo "remoteip 10.10.10.2-199" >> /etc/pptpd.conf
echo "name pptpd" > /etc/ppp/pptpd-options
echo "refuse-pap" >> /etc/ppp/pptpd-options
echo "refuse-chap" >> /etc/ppp/pptpd-options
echo "refuse-mschap" >> /etc/ppp/pptpd-options
echo "require-mschap-v2" >> /etc/ppp/pptpd-options
echo "require-mppe-128" >> /etc/ppp/pptpd-options
echo "proxyarp" >> /etc/ppp/pptpd-options
echo "nodefaultroute" >> /etc/ppp/pptpd-options
echo "lock" >> /etc/ppp/pptpd-options
echo "nobsdcomp" >> /etc/ppp/pptpd-options
echo "novj" >> /etc/ppp/pptpd-options
echo "novjccomp" >> /etc/ppp/pptpd-options
echo "nologfd" >> /etc/ppp/pptpd-options
EOF

ssh $SSH_OPTIONS root@$IP <<EOF
rm -rf /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 2001:4860:4860::8888" >> /etc/resolv.conf
echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
EOF



ssh $SSH_OPTIONS root@$IP <<EOF
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p

EOF

ECHO "Enter User and Password for PPTPD"

read -p "PPTPD Username: " uservar
read -sp "PPTPD Password: " passvar

ssh $SSH_OPTIONS root@$IP <<EOF
echo "$uservar * $passvar *" >> /etc/ppp/chap-secrets
EOF

ssh $SSH_OPTIONS root@$IP <<EOF
systemctl restart pptpd
systemctl enable pptpd
systemctl enable nginx
systemctl restart nginx
EOF




