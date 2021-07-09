rm -f /usr/local/bin/docker-compose
rm -f /usr/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
