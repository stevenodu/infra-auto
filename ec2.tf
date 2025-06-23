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

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    GITHUB_TOKEN = var.aws-integration-token
  })

  tags = {
    Name = "Oduorates-WebsiteServer"
  }
}