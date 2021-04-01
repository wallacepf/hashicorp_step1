variable "ami_name" {
  type    = string
  default = "backend-v1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "backend-v1" {
  ami_name      = "backend-app1-v1.0-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.backend-v1"]

  provisioner "file" {
    destination = "/home/ubuntu/"
    source      = "../Study/cdond-c3-projectstarter/backend/backend.tar.gz"
  }

  provisioner "shell" {
    inline = [
      "sleep 30",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "sudo apt-get update",
      "sudo apt-get install npm consul -y",
      "sudo npm install pm2 --global",
      "mkdir backend",
      "tar -xvzf backend.tar.gz -C backend/",
      "cd backend",
      "sudo pm2 install typescript"
    ]
  }

}