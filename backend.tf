data "aws_ami" "backend_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

locals {
  backend_user_data = <<EOF
#!/bin/bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install npm consul -y
sudo npm install pm2 --global
cd /home/ubuntu
mkdir backend
wget https://backend-hc-step1.s3-us-west-2.amazonaws.com/backend.tar.gz
tar -xvzf backend.tar.gz -C backend/
cd backend
cp .env.sample .env
sed -i "s/TYPEORM_HOST=mydbaddr/TYPEORM_HOST=${module.db.this_db_instance_address}/g" .env
source .env
sudo npm i
sudo npm run build
sudo pm2 install typescript
sudo npm run migrations
sudo pm2 start src/main.ts
EOF
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.17.0"

  name        = "lb-sg-${local.name_suffix}"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.common_tags
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.4.0"


  name = "lb-${random_string.lb_id.result}-${local.name_suffix}"

  internal = false

  security_groups = [module.lb_security_group.this_security_group_id]
  subnets         = module.vpc.public_subnets

  number_of_instances = length(module.ec2_backend)
  instances           = module.ec2_backend.*.id

  listener = [{
    instance_port     = "3030"
    instance_protocol = "HTTP"
    lb_port           = "3030"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:3030/"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  tags = local.common_tags
}

module "ec2_backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~>2.0"

  instance_count = var.backend_instance_count

  name                        = "backend-${var.env}"
  ami                         = data.aws_ami.backend_ami.id
  instance_type               = "t2.micro"
  key_name                    = "tf_lab_key"
  subnet_ids                  = module.vpc.public_subnets[count.index % length(module.vpc.private_subnets)]
  vpc_security_group_ids      = [module.security_group_backend.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.backend_user_data)

  tags = local.common_tags

}
