resource "null_resource" "setup_backend" {
  provisioner "local-exec" {
    environment = {
      TYPEORM_HOST = module.db.this_db_instance_address
    }
    working_dir = "${path.module}/../Study/cdond-c3-projectstarter/backend"
    command     = <<-EOT
            echo $TYPEORM_HOST
            rm -rf .env
            mv .env.sample .env
            gsed -i "s/TYPEORM_HOST=mydbaddr/TYPEORM_HOST=$TYPEORM_HOST/g" .env
            cat .env
            npm i
            npm run build
            rm -rf backend.tar.gz
            tar -cvzf backend.tar.gz .
        EOT
  }
}

resource "null_resource" "build_backend_image" {
  provisioner "local-exec" {
    command = <<-EOT
            packer build .
        EOT
  }

  depends_on = [
    null_resource.setup_backend
  ]
}

resource "null_resource" "setup_frontend" {
  provisioner "local-exec" {
    environment = {
      API_URL = "http://${module.ec2.public_ip[0]}:3030"
    }
    working_dir = "${path.module}/../Study/cdond-c3-projectstarter/frontend"
    command     = <<-EOT
            echo $API_URL
            npm i
            npm run build
        EOT
  }

  depends_on = [
    module.ec2
  ]
}
