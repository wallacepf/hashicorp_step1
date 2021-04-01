output "s3_frontend_endpoint" {
  value = "http://${module.frontend_s3_bucket.this_s3_bucket_bucket_regional_domain_name}/index.html"
}

output "db_address" {
  value = "${module.db.this_db_instance_address}:${module.db.this_db_instance_port}"
}

output "db_azs" {
  value = module.db.this_db_instance_availability_zone
}

output "backend_api_url" {
  value = "http://${module.ec2.public_ip[0]}:3030"
}

output "backend_az" {
  value = module.ec2.availability_zone
}
