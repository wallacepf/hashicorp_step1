module "backend" {
  source  = "app.terraform.io/myterraformcloud/backend/aws"
  version = "~>1.0.0"

  key_name = "tf_lab_key"

  app_s3_addr  = "https://backend-hc-step1.s3-us-west-2.amazonaws.com/backend.tar.gz"
  db_address   = module.db.this_db_instance_address
  backend_name = "backend-${random_string.random.id}"

  backend_subnets = module.vpc.public_subnets
  security_group  = module.security_group_backend.this_security_group_id

  tags = local.common_tags
}
