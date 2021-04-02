terraform {
  required_providers {
    aws = {
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "random" {
  length   = 8
  upper    = false
  special = false
}
