resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "my_vpc_publicsb" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_vpc_publicsb"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_vpc_publicsb.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "my_sec_gr" {
  name        = "dev_sec_gr"
  description = "dev_sec_gr_http_https_ssh"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "ssh"
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
    Name = "dev_sec_gr_http_https_ssh"
  }
}

resource "aws_key_pair" "terraformkey" {
  key_name   = "tfkey"
  public_key = file("C:/Users/Burcu/.ssh/tfkey.pub")
}

resource "aws_instance" "web_server" {
  ami                    = "ami-02396cdd13e9a1257"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraformkey.id
  vpc_security_group_ids = [aws_security_group.my_sec_gr.id]
  subnet_id              = aws_subnet.my_vpc_publicsb.id
  user_data              = file("userdata")
             
  tags = {
    Name = "web_server"
  }

/*
  lifecycle {
    prevent_destroy = true
}
*/

}

output "public_ip" {
  value = aws_instance.web_server.public_ip
  
}








