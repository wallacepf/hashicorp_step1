module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~>2.0"

  identifier = "demodb-${random_string.random.id}"

  engine         = "postgres"
  engine_version = "12.5"
  family         = "postgres12"
  instance_class = var.db_instance_type

  allocated_storage     = 20
  max_allocated_storage = 100

  name     = "mydb"
  username = "postgres"
  password = "mysafepwd"
  port     = 5432

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group_db.this_security_group_id]
}
