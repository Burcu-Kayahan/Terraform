variable "num_of_buckets" {
    default = 2
}

variable "s3-bucket-name" {
    default = "dene-s3-bucket-variable"
}

variable "users" {
  default = ["yassa", "varrol", "harbiiye"]
  type = list(string)
}

variable "cidr-blocks" {
    default = [{cidr_block ="10.0.0.0/16", name = "dev-vpc"},{cidr_block="10.0.10.0/24", name ="dev-subnet"},{cidr_block="172.31.48.0/20" ,name = "subnet-2"}]
    type = list(object({cidr_block=string, name=string}))
}


