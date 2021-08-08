apt update
apt -y upgrade
apt full-upgrade -y
apt autoremove -y

sed -i 's/stretch/buster/g' /etc/apt/sources.list
sed -i 's/stretch/buster/g' /etc/apt/sources.list.d/*.list
apt update
apt -y upgrade
apt full-upgrade
systemctl reboot
