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
mkdir backend
wget https://backend-hc-step1.s3-us-west-2.amazonaws.com/backend.tar.gz
tar -xvzf backend.tar.gz -C backend/
cd backend
cp .env.sample .env
sed -i "s/TYPEORM_HOST=mydbaddr/TYPEORM_HOST=${module.db.this_db_instance_address}/g" .env
sudo pm2 install typescript
npm run migrations
pm2 start src/main.ts
EOF
}

module "ec2_backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~>2.0"

  instance_count = 1

  name                        = "backend-${var.env}"
  ami                         = data.aws_ami.backend_ami.id
  instance_type               = "t2.micro"
  key_name                    = "tf_lab_key"
  subnet_ids                  = module.vpc.private_subnets
  vpc_security_group_ids      = [module.security_group_backend.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.backend_user_data)


  tags = local.common_tags

}
