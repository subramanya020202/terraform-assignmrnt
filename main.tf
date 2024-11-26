resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.custom_vpc.id
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for SSH and HTTP (NGINX)
resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Part 2: EC2 Instances

# Public EC2 Instance (NGINX)
resource "aws_instance" "public_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.ec2_key.key_name
  security_groups = [aws_security_group.nginx_sg.id]  # CORRECT

  associate_public_ip_address = true

  tags = {
    Name = "PublicVM"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
}

# Private EC2 Instance
resource "aws_instance" "private_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  key_name               = aws_key_pair.ec2_key.key_name
  security_groups = [aws_security_group.nginx_sg.id]  # CORRECT



  tags = {
    Name = "PrivateVM"
  }

  associate_public_ip_address = false
}

# Define the SSH Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "terraform-key"  # Choose a key name
  public_key = file("~/.ssh/id_rsa.pub")  
}
