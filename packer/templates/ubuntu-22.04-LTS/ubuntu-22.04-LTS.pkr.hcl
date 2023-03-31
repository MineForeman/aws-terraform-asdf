packer {
  required_version = ">= 1.7.2"
}

locals {
  region = "ap-southeast-2"
}

source "amazon-ebs" "ubuntu-latest" {
  region = local.region
  ami_name = "ubuntu-latest-${local.region}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_type = "t2.micro"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*" # Changed name to target Ubuntu 22.04
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu-latest"]

  provisioner "shell" {
    inline = ["sudo apt-get update", "sudo apt-get upgrade -y"]
  }
}
