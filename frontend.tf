data "aws_ami" "frontend_ami" {
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
  frontend_user_data = <<EOF
#!/bin/bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install npm consul -y
cd /home/ubuntu
mkdir frontend
wget https://frontend-hc-step1.s3-us-west-2.amazonaws.com/frontend.tar.gz
tar -xvzf frontend.tar.gz -C frontend/
cd frontend
npm i
echo "API_URL=http://${module.backend.backend_ip[0]}:3030" > .env
source .env
npm run build
sudo npm start
EOF
}

module "ec2_frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~>2.0"

  instance_count = 1

  name                        = "frontend-${random_string.random.id}"
  ami                         = data.aws_ami.frontend_ami.id
  instance_type               = var.frontend_instance_type
  key_name                    = "tf_lab_key"
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group_frontend.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.frontend_user_data)


  tags = local.common_tags

}
