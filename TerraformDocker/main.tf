provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev" {
  cidr_block           = var.vpc-cidr-block
  enable_dns_hostnames = true
  tags = {
    Name : "${var.env-prefix}-vpc"
  }
}

resource "aws_subnet" "dev_subnet_1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet-cidr[0]
  availability_zone       = var.av_zone[0]
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.env-prefix}-subnet-1"
  }
}


resource "aws_internet_gateway" "devIgw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "devIgw"
  }
}

resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.dev.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devIgw.id
  }

  tags = {
    Name : "${var.env-prefix}-main-rtb"
  }
}

resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "http, ssh, https"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "myapp-sg"
  }

}

resource "aws_instance" "web" {
  ami                    = "ami-03c7d01cf4dedc891"
  instance_type          = "t2.micro"
  key_name               = "b107-key"
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  subnet_id              = aws_subnet.dev_subnet_1.id
  availability_zone      = "us-east-1a"
  user_data              = file("userdata.sh")

  # connection {
  #   type = "ssh"
  #   host = self.public_ip
  #   user = "ec2-user"
  #   private_key = "mehmet"
  # }

  # provisioner "remote-exec" {
  #   script = file("userdata.sh")
  # }

  # provisioner "file" {
  #   source = "userdata.sh"
  #   destination = "userdata.sh"    
  # }

  # provisioner "local-exec" {
  #  command = "echo ${self.public_ip} > output.txt"
  # }

  tags = {
    Name = "web"
  }
}

output "web" {
  value = aws_instance.web.public_ip
  
}