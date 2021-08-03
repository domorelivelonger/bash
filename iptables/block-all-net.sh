#block all internet with exclude
#Block internet on client server
# create chains for iptables
sudo iptables -N ALLOWVPN
sudo iptables -N BLOCKALL
# allow access for the interfaces loopback, tun, and tap
sudo iptables -A OUTPUT -o tun+ -j ACCEPT;
sudo iptables -A OUTPUT -o tap+ -j ACCEPT;
sudo iptables -A OUTPUT -o lo+ -j ACCEPT;
# route outgoing data via our created chains
sudo iptables -A OUTPUT -j ALLOWVPN;
sudo iptables -A OUTPUT -j BLOCKALL;
# allow connections to certain IP addresses with no active VPN
sudo iptables -A ALLOWVPN -d 8.8.8.8 -j ACCEPT
#add new ip if you want allow connect to some ip or from some ip to server
#sudo iptables -A ALLOWVPN -d 8.8.8.8 -j ACCEPT
# block all disallowed connections
sudo iptables -A BLOCKALL -j DROP
