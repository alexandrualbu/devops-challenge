terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
    access_key = ""
    secret_key = ""
}

resource "aws_vpc" "qed-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "qed-vpc"
  }
}

resource "aws_subnet" "qed-subnet" {
  vpc_id     = aws_vpc.qed-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "qed-subnet"
  }

  depends_on = [ aws_vpc.qed-vpc ]
}

resource "aws_internet_gateway" "qed-gateway" {
  vpc_id = aws_vpc.qed-vpc.id

  tags = {
    Name = "qed-internet-gateway"
  }
}

resource "aws_route_table" "qed-route-table" {
  vpc_id = aws_vpc.qed-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.qed-gateway.id
  }

  tags = {
    Name = "qed-route-table"
  }
}

resource "aws_route_table_association" "qed-route-table" {
  subnet_id      = aws_subnet.qed-subnet.id
  route_table_id = aws_route_table.qed-route-table.id
}


resource "aws_security_group" "qed-sg" {
  vpc_id = aws_vpc.qed-vpc.id

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

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "qed-security-group"
  }

  depends_on = [ aws_vpc.qed-vpc]
}


resource "aws_instance" "qed-instance" {
    ami = "ami-0cf2b4e024cdb6960"
    instance_type = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.qed-sg.id]
    subnet_id                   = aws_subnet.qed-subnet.id
    associate_public_ip_address = true

    tags = {
        Name = "qed-ec2-nodejs"
    }

    user_data = <<-EOF
        #!/bin/bash
        apt update -y
        apt-get install -y docker.io
        service docker start
        usermod -aG docker root
        docker run -d -p 80:3000 alexalbu/qed
    EOF

    depends_on = [  aws_security_group.qed-sg]
}

