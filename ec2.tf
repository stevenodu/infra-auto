resource "aws_security_group" "web-sg" {
  name        = "web-access-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSG"
  }
}

resource "aws_instance" "oduorates-ec2" {
  ami                         = "ami-04c66bbcdeb7ae2e1"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.web-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = local.ssm_profile_name

  user_data = <<-EOF
              #!/bin/bash
              GITHUB_TOKEN="${var.aws-integration-token}"
              set -o errexit
              set -o nounset

              # Update system
              sudo apt update -y && sudo apt upgrade -y

              # Install NGINX
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
              sudo git clone https://${GITHUB_TOKEN}@github.com/stevenodu/odurates.git  .
              
              # Restart NGINX
              sudo systemctl restart nginx
              EOF

  tags = {
    Name = "MyWebsiteServer"
  }
}