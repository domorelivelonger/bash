apt update && apt upgrade -y && apt install htop wget mc curl pwgen ncdu screen nmap httping net-tools redir -y


sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
