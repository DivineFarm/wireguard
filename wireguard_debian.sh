#!/bin/bash

# Determine the Internet facing network interface
# You can use a command like the following to determine the internet-facing interface
# interface=$(command to determine the internet-facing interface)

# Change ens6 on all the relevant lines with the interface name
# Replace "ens6" with the actual interface name in the following commands

# Install Docker
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo systemctl enable docker
sudo apt install docker-compose git -y

# Install Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Install Wireguard-ui under docker
docker run -d --name wireguard-ui -e LOGIN_PAGE=1 -e BIND_ADDRESS=0.0.0.0:5000 --net=host -v /path/data:/db -v /etc/wireguard:/etc/wireguard --restart unless-stopped --privileged minimages/wireguard-ui

# Setup the network
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo apt install ufw -y
sudo ufw allow 22/tcp
sudo ufw allow 5000/tcp
sudo ufw allow 9443/tcp
sudo ufw allow 51820/udp
sudo ufw reload
sudo ufw enable

# Get the network interface name
NETWORK_INTERFACE=$(ifconfig | grep -oP 'inet\b{1,2}')

# Get the IP address of the network interface
IP_ADDRESS=$(ifconfig | grep -oP "inet\b{1,2} \(${IP_ADDR})")

# Replace SERVER-IP with the machine's IP
MACHINE_IP=$(echo $IP_ADDRESS | cut -d/ -f 1)

# Echo the lines with the replaced IP
echo "web-ui: http://$MACHINE_IP:5000   (admin/admin)"
echo "Portainer: https://$MACHINE_IP:9443 (admin/password change request at first login)"

# Additional instructions
echo "To change the password to the Wireguard UI:"
echo "1- login to portainer"
echo "2- Go to containers"
echo "3- on the wireguard-ui container, click on exec console"
echo "4- Connect"
echo "5- on the shell, type: vi db/server/users.json"
echo "6- change the password of the file and save by typing \"esc\" key, then typing (without the quotes) \":wq\" and Enter"
echo "7- on the shell again, type \"reboot\""

