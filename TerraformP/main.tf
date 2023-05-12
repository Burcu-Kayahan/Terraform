resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "docker-swarm"
  }
}

resource "aws_subnet" "my_vpc_publicsb" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "docker_swarm_public"
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
    Name = "swarm_sec_gr_http_https_ssh"
  }
}



# resource terraform ile oluşturmak için 
# data ise hali hazırda olanı almak için

resource "aws_instance" "web-server" {
  count= var.instance_adedi 
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_vpc_publicsb.id
  availability_zone      = "us-east-1a"
  key_name               = var.anahtar 
  vpc_security_group_ids = [aws_security_group.my_sec_gr.id]

  tags = {
    Name = "docker_swarm"
  }
  /*
  lifecycle {
    prevent_destroy = true #destroy dediğimizde bunun önüne geçmiş oluyor bunu eklemezsek eğer altyapıyı yere indiriyor.
  }
  */ # terraform .tf dosyası içinde hash işareti ile aynı anlama gelir 

}

output "docker_swarm_machine_ip" {
  value = aws_instance.web-server.*.public_ip
}