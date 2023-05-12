provider "aws" {
   
    region = "us-west-1"   
}



resource "aws_vpc" "gelistirici-vpc" {
    cidr_block = var.cidr-blocks[0].cidr_block
    tags = {
        Name : var.cidr-blocks[0].name
        vpc_env = "dev"
    }

}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.gelistirici-vpc.id
    cidr_block = var.cidr-blocks[1].cidr_block
    availability_zone = "us-west-1a"
    tags = { # Değişen yer
        Name : var.cidr-blocks[1].name # Değişen yer
    }
}

resource "aws_s3_bucket" "tf-s3" {
    bucket = "${var.s3-bucket-name}-${count.index}"
    acl    = "private"
    count = var.num_of_buckets
    #for_each =toset(var.users)
    #bucket = "example-s3-bucket-${each.value}"

}

 resource "aws_iam_user" "new-users" {
        for_each = toset(var.users)
    name = each.value
 }

# output "uppercase_users" {
#   value = [for user in var.users : upper(user) ]
# }

data "aws_vpc" "existing_vpc" {
    default = true 

}
resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = var.cidr-blocks[2].cidr_block
    availability_zone = "us-west-1b"
     tags = { # Değişen yer
        Name : var.cidr-blocks[2].name
    }

}

output "dev-vpc-id" {
    value = aws_vpc.gelistirici-vpc.id
}
output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id
}