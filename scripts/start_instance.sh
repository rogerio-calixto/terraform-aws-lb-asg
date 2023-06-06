#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip -u awscliv2.zip
sudo ./aws/install
rm -f awscliv2.zip
cd /var/www/html
sudo rm index.nginx-debian.html
sudo aws s3 --recursive cp s3://buck-devops/repository/website/ .