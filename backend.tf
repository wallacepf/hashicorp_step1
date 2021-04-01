data "aws_ami" "backend_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["backend-app1-*"]
  }

  depends_on = [
    null_resource.build_backend_image
  ]
}

locals {
  user_data = <<EOF
#!/bin/bash
cd /home/ubuntu/backend
npm run migrations
pm2 start src/main.ts
EOF
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~>2.0"

  instance_count = 1

  name                        = "backend"
  ami                         = data.aws_ami.backend_ami.id
  instance_type               = "t2.micro"
  key_name                    = "tf_lab_key"
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group_backend.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.user_data)


  tags = local.common_tags

}
