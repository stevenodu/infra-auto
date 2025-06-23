#!/bin/bash
GITHUB_TOKEN="$${GITHUB_TOKEN:-}"

set -o errexit
set -o nounset

# Update system
sudo apt update -y && sudo apt upgrade -y

# Install and start SSM Agent
curl "https://s3.amazonaws.com/amazon-ssm-${AWS_REGION}/latest/debian_amd64/amazon-ssm-agent.deb" -o "ssm-agent.deb"
sudo dpkg -i ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent


# Install NGINX and Git
sudo apt install nginx git -y

# Replace default NGINX config
echo "server {
    listen 80;
    server_name localhost;

    location / {
        root /var/www/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }
}" | sudo tee /etc/nginx/sites-available/default > /dev/null

# Create directory
sudo mkdir -p /var/www/html

# Clone your personal site
cd /var/www/html
if [ -n "$GITHUB_TOKEN" ]; then
  sudo git clone https://${GITHUB_TOKEN}@github.com/stevenodu/odurates.git .
else
  echo "WARNING: GITHUB_TOKEN is not set. Skipping repo clone." >> /var/log/bootstrap.log
fi

# Restart NGINX
sudo systemctl restart nginx
