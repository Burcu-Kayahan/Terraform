provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev_vpc" {
    cidr_block = var.cidr[0]
}

resource "aws_subnet" "dev_mehmet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = var.cidr[1]

  tags = {
    Name = "dev_mehmet"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = var.cidr[2]
    gateway_id = aws_internet_gateway.dev_igw.id
  }
}

resource "aws_route_table_association" "dev_bağlama" {
  subnet_id      = aws_subnet.dev_mehmet.id
  route_table_id = aws_route_table.dev_rt.id
}

resource "aws_security_group" "dev_sec_gr" {
  name        = "dev_sec_gr"
  description = "https,http,ssh"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}

ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "dev_sec_gr"
  }
}

