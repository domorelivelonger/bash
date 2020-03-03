#!/bin/bash



ipv4=100.100.100.100
portproxy=30000
user=test
pass=testtest
config="/root/3proxy/3proxy.cfg"


echo "daemon" >> $config
echo "maxconn 1000" >> $config
echo "nserver 2001:4860:4860::8844" >> $config
echo "nserver 2001:4860:4860::8888" >> $config
echo "nserver 8.8.8.8" >> $config
echo "nscache 65536" >> $config
echo "timeouts 1 5 30 60 180 1800 15 60" >> $config
echo "setgid 65535" >> $config
echo "setuid 65535" >> $config
echo "flush" >> $config
echo "auth strong" >> $config
echo  "users $user:CL:$pass" >> $config
echo "allow $user" >> $config

for i in `cat ip.list`; do
    echo "proxy -n -a -6 -p$portproxy -i$ipv4 -e$i" >> $config
    ((inc+=1))
    ((portproxy+=1))
	echo "$ipv4:$portproxy:$user:$pass" >> proxylist.txt
done
