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

locals {
  project = var.project
  env     = var.env
  common_tags = {
    Project     = local.project
    Environment = local.env
  }
}

locals {
  name_suffix = "${var.project}-${var.env}"
}