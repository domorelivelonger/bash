apt update
apt -y upgrade
apt full-upgrade -y
apt autoremove -y

sed -i 's/buster/bullseye/g' /etc/apt/sources.list
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/*.list
apt update
apt -y upgrade
apt -y full-upgrade
systemctl reboot
