#!/bin/bash
ulimit -n 600000
ulimit -u 600000
/root/ndppd/ndppd -d -c /root/ndppd/ndppd.conf
/root/3proxy/bin/3proxy /root/3proxy/3proxy.cfg

ip -6 addr add 2a09:ffff:0000:0000:0000:0000:0000:0002/64 dev ens18 
ip -6 route add default via 2a09:ffff:0000:0000:0000:0000:0000:0001
ip -6 route add local 2a09:ffff:0000:0000:0000:0000:0000:0000/48 dev lo
exit 0
