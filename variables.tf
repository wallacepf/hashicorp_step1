variable "aws_region" {
  default = "us-west-2"
}

variable "project" {
  default = "hashicorp-interview"
}

variable "env" {
  default = "dev"
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

variable "database_subnet_cidr_blocks" {
  default = [
    "10.0.4.0/24",
    "10.0.5.0/24"
  ]
}
