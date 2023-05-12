provider "aws" {
  region = "us-east-1"

}


resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {


    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id                  = aws_vpc.myapp-vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.avail_zone
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

# resource "aws_route_table" "myapp-route-table" {
#   vpc_id = aws_vpc.myapp-vpc.id
#   route {

#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {

#     Name : "${var.env_prefix}-rtb"
#   }
# }


resource "aws_internet_gateway" "myapp-igw" {

  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id      = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
}

resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "http, ssh, https"
  vpc_id      = aws_vpc.myapp-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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


# resource "aws_default_security_group" "default-sg" { 
#     vpc_id = aws_vpc.myapp-vpc.id 


#     ingress{ 
#         from_port = 22 
#         to_port = 22 
#         protocol = "tcp"
#         cidr_blocks = [var.my_ip]
#     }

#     ingress { 
#         from_port = 8080
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"] 
#     }

#     egress { 
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     tags = {
#         Name: "${var.env_prefix}-default-sg" 
#     }
# }

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "dev-server" {
  value = aws_instance.myapp-server.public_ip

}

resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.myapp-subnet-1.id
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = var.my_private_key
  user_data                   = file("userdata.sh")

  tags = {
    Name : "${var.env_prefix}-server"
  }
}





