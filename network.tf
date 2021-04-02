data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.64.0"

  name = "vpc-${random_string.random.id}"
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

module "security_group_db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>3.0"

  name   = "database"
  vpc_id = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_rules = ["all-all"]
  tags         = local.common_tags
}

module "security_group_backend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>3.0"

  name   = "backend_app1"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3030
      to_port     = 3030
      protocol    = "tcp"
      description = "Access from public subnets"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow outside traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.common_tags
}

module "security_group_frontend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>3.0"

  name   = "frontend_app1"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Access from public subnets"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow outside traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.common_tags
}
