variable "aws_region" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  region = var.aws_region
  # Define the source AMI filter for Ubuntu 20.04
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "packer-ubuntu-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
}
