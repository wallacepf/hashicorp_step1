locals {
  description = var.description
  owner       = var.owner
  common_tags = {
    Description = local.description
    Owner       = local.owner
  }
}

variable "aws_region" {
  default = "us-west-2"
}

variable "description" {
  default = "hashicorp-interview"
}

variable "owner" {
  default = "wallacepf"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/20"
}

variable "public_subnet_cidr_blocks" {
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  default = [
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "backend_instance_count" {
  default = 1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_instance_type" {
  default = "db.t2.micro"
}

