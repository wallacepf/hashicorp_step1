output "db_address" {
  value = "${module.db.this_db_instance_address}:${module.db.this_db_instance_port}"
}

output "db_azs" {
  value = module.db.this_db_instance_availability_zone
}

output "backend_api_url" {
  value = "http://${module.ec2_backend.public_ip[0]}:3030"
}

output "backend_az" {
  value = module.ec2_backend.availability_zone
}

output "app_url" {
  value = "http://${module.ec2_frontend.public_ip[0]}"
}