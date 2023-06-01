provider "aws" {
    region = var.bolge
}

resource "aws_vpc" "dev_vpc" {
    cidr_block = var.cidr

    tags = {
      Name = "${var.env_prefix}"
    }
}
